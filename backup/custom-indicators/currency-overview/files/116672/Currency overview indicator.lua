-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65175

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Price Action Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Selector");
    Add(1, "m1"); 
    Add(2, "m5"); 
    Add(3, "m15"); 
    Add(4, "m30"); 
    Add(5, "H1"); 
    Add(6, "H2"); 
    Add(7, "H3"); 
    Add(8, "H4" ); 
    Add(9, "H6" ); 
    Add(10, "H8"); 
    Add(11, "D1"); 
    Add(12, "W1"); 
    Add(13, "M1");
    Add(14, "W6"); 
    Add(15, "M12");
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Location", "Label location", "Label location", "Top right");
    indicator.parameters:addStringAlternative("Location", "Top right", "", "Top right");
    indicator.parameters:addStringAlternative("Location", "Top left", "", "Top left");
    indicator.parameters:addStringAlternative("Location", "Bottom right", "", "Bottom right");
    indicator.parameters:addStringAlternative("Location", "Bottom left", "", "Bottom left");
    indicator.parameters:addColor("Label_Color", "Label Color", "", core.COLOR_LABEL);  
    indicator.parameters:addColor("Background_Color", "Background Color", "", core.COLOR_BACKGROUND);  
    indicator.parameters:addInteger("font_size", "Font Size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

function Add(id, TF)
    indicator.parameters:addBoolean("On".. id , "Show " .. TF , "",true);      
end    

local first;
local source = nil;
 
local Count=0;
local iLabel={"m1", "m15","m30", "H1","H2", "H3","H4", "H6", "H8","D1", "W1", "M1","M6", "M12" };
local XLabel = {"Change", "Low", "High", "Pips"};
local Label={};
local Source={};
local loading={};
local location;
local Label_Color;
local Background_Color;
local Size = 10;
local Data1={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
local Data2={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
local Data3={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
local Data4 = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

local iData= {1,1 ,1 ,2,2,2,2,2,2,3,3,4,4,4};
local iShift={1,15,30,1,2,3,4,6,8,1,7,1,6,12};

local X1=(1/24)/60;
local X2=1/24;
local iTime={X1,X1,X1,X2,X2,X2,X2,X2,X2,1,1,30,30,30}

local Data={};
local Shift={};
local Time={};


local TF={"m1", "H1", "D1", "M1"  };
local FIRST={30, 8,  7, 12  }; 

-- Routine
function Prepare(name_only)
    Label_Color=instance.parameters.Label_Color; 
    Background_Color=instance.parameters.Background_Color;
    source = instance.source;
    first=source:first();
    Size = instance.parameters.font_size;
    
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if (name_only) then
        return;
    end
    
    Number=0;
    for i = 1, 14, 1 do
        if  instance.parameters:getBoolean("On" .. i)  then
            Number=Number+1;
            Label[Number]=iLabel[i];
            Data[Number]=iData[i];
            Shift[Number]=iShift[i];
            Time[Number]=iTime[i];
        end
    end
    location = instance.parameters.Location;
    for k= 1, 4, 1  do
        Source[k]  = core.host:execute("getSyncHistory",  source:instrument(),  TF[k], source:isBid(), math.min(300,FIRST[k]), 2000 + k , 1000 +k);          
        loading[k]  = true;       
    end
      
    instance:ownerDrawn(true);
    core.host:execute ("setTimer", 1, 1);
end

function ReleaseInstance()
    core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

    local k;
    local FLAG=false; 
    local Num=0;

    for k = 1, 4, 1 do
        if cookie == (1000 + k) then
            loading[k]  = true;
        elseif  cookie == (2000 + k ) then
            loading[k]  = false;         
        end
        if loading[k] then
            FLAG= true;
            Num=Num+1;
        end
    end    
     

    if not FLAG and cookie== 1 then
        Data1={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
        Data2={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
        Data3={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
        Data4 = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        local Current =source.close[source.close:size()-1];
        local p;
        for i= 1, Number, 1 do
            p= core.findDate (Source[Data[i]], core.now() , false);
            if p~=-1 then
                Data1[i] = (Current - Source[Data[i]].open[p]) / (Source[Data[i]].open[p] / 100);
                Data4[i] = (Current - Source[Data[i]].open[p]) / source:pipSize();
                min,max=mathex.minmax(Source[Data[i]], p,  Source[Data[i]]:size()-1);
                                
                Data2[i] = min;
                Data3[i] = max;
                
                Data1[i]=win32.formatNumber(Data1[i], false, 2);
                Data2[i]=win32.formatNumber(Data2[i], false, source:getPrecision());
                Data3[i]=win32.formatNumber(Data3[i], false, source:getPrecision());
                Data4[i] = win32.formatNumber(Data4[i], false, 1);
            else
                Data1[i]="";
                Data2[i]="";
                Data3[i]="";
                Data4[i] = "";
            end
        end
    end
    
    if FLAG then
        core.host:execute ("setStatus", "  Loading "..((4) - Num) .. " / " .. (4) );     
    else
        core.host:execute ("setStatus", "Loaded");
        instance:updateFrom(0);
    end
    
    return core.ASYNC_REDRAW ;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   
end
 
local init = false;

function GetMaxWidthHeight(context)
    local max_width = 0;
    local max_height = 0;
    for i= 1, Number, 1 do  
        Text=Label[i];
        width, height = context:measureText(1, Text, 0);
        if max_width < width then
            max_width = width;
        end
        if max_height < height then
            max_height = height
        end
        for j = 1, 4, 1 do
            if i == 1 then 
                width, height = context:measureText(1, XLabel[j], 0);
                if max_width < width then
                    max_width = width;
                end
                if max_height < height then
                    max_height = height
                end
            end
            if j == 1 then 
                width, height = context:measureText(1, Data1[i], 0);
                if max_width < width then
                    max_width = width;
                end
                if max_height < height then
                    max_height = height
                end
            end
            if j == 2 then 
                width, height = context:measureText(1, Data2[i], 0);
                if max_width < width then
                    max_width = width;
                end
                if max_height < height then
                    max_height = height
                end
            end
            if j == 3 then 
                width, height = context:measureText(1, Data3[i], 0);
                if max_width < width then
                    max_width = width;
                end
                if max_height < height then
                    max_height = height
                end
            end
            if j == 4 then 
                width, height = context:measureText(1, Data4[i], 0);
                if max_width < width then
                    max_width = width;
                end
                if max_height < height then
                    max_height = height
                end
            end
        end
    end
    return max_width, max_height;
end

function Draw(stage, context)
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
    if stage ~= 2 then
        return;
    end
      
    local k;
    local FLAG=false; 
    for j = 1, 4, 1 do 
        if loading[j] then
            FLAG= true; 
        end
    end   

    if FLAG then
        return;
    end
    if not init then
        context:createSolidBrush (2, Background_Color)
        init = true;
    end

    local max_width, max_height = GetMaxWidthHeight(context);
    local YCellSize = max_height * 1.1; 
    local XCellSize = max_width * 1.1;
    if location == "Top right" then
        context:drawRectangle(-1, 2, context:right() - XCellSize * 4, context:top(), context:right(), context:top() + (Number + 3) * YCellSize);
    end
    if location == "Top left" then
        context:drawRectangle(-1, 2, context:left(), context:top(), context:left() + XCellSize * 5, context:top() + (Number + 3) * YCellSize);
    end
    if location == "Bottom right" then
        context:drawRectangle(-1, 2, context:right() - XCellSize * 4, context:bottom() - (Number + 3) * YCellSize, context:right(), context:bottom());
    end
    if location == "Bottom left" then
        context:drawRectangle(-1, 2, context:left(), context:bottom() - (Number + 3) * YCellSize, context:left() + XCellSize * 5, context:bottom());
    end
    context:createFont(1, "Arial", context:pointsToPixels(Size), context:pointsToPixels(Size), 0);
    for i= 1, Number, 1 do  
        Text = Label[i];
        local y1;
        width, height = context:measureText(1, Text, 0);
        if location == "Top right" then
            y1 = context:top() + YCellSize * 2 + (i - 1) * YCellSize;
            context:drawText(1,  Text, Label_Color, -1,  context:right() - XCellSize * (Number - i), y1, context:right() - XCellSize * Number + width, y1 + height, 0 );
        end
        if location == "Top left" then
            y1 = context:top() + YCellSize * 2 + (i - 1) * YCellSize;
            context:drawText(1,  Text, Label_Color, -1,  context:left() ,  y1,context:left() + width, y1 + height, 0 );
        end
        if location == "Bottom right" then
            y1 = context:bottom() - (Number + 3 - i) * YCellSize;
            context:drawText(1,  Text, Label_Color, -1, context:right() - XCellSize * (Number - i), y1, context:right() - XCellSize * Number + width, y1 + height, 0 );
        end
        if location == "Bottom left" then
            y1 = context:bottom() - (Number + 3 - i) * YCellSize;
            context:drawText(1,  Text, Label_Color, -1, context:left(), y1, context:left() + width, y1 + height, 0 );
        end
        
        for j = 1, 4, 1 do
            local x1;
            if location == "Top right" or location == "Bottom right" then
                x1 = context:right() - (5 - j) * XCellSize;
            else
                x1 = context:left() + XCellSize + (j - 1) * XCellSize;
            end
            if i == 1 then 
                width, height = context:measureText(1, XLabel[j], 0);
                context:drawText(1,  XLabel[j], Label_Color, -1, x1, y1 - YCellSize, x1 + width, y1 - YCellSize + height, 0 );
            end
            if j == 1 then 
                Text = Data1[i];
                width, height = context:measureText(1, Text, 0);
                context:drawText(1,  Text, Label_Color, -1,  x1, y1, x1 + width, y1 + height, 0 );    
            end
            if j == 2 then 
                Text=Data2[i];
                width, height = context:measureText(1, Text, 0);
                context:drawText(1,  Text, Label_Color, -1,  x1, y1, x1 + width, y1 + height, 0 );    
            end
            if j == 3 then 
                Text=Data3[i];
                width, height = context:measureText(1, Text, 0);
                context:drawText(1,  Text, Label_Color, -1,  x1, y1, x1 + width, y1 + height, 0 );
            end
            if j == 4 then 
                Text = Data4[i];
                width, height = context:measureText(1, Text, 0);
                context:drawText(1, Text, Label_Color, -1, x1, y1, x1 + width, y1 + height, 0);
            end
        end
    end
end
