-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=39802&start=30

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
function Init()
    indicator:name("Higher Time Frame Support Resistance");
    indicator:description("Higher Time Frame Support Resistance");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Current / Previous Period ", "Current / Previous" , "Previous");
    indicator.parameters:addStringAlternative("Method", "Current Period", "Current" , "Current");
    indicator.parameters:addStringAlternative("Method", "Previous Period", "Previous" , "Previous");
    indicator.parameters:addStringAlternative("Method", "Both", "Both" , "Both");
     
    indicator.parameters:addString("Type", "Lines/Label ", "Lines/Label" , "Both");
    indicator.parameters:addStringAlternative("Type", "Lines", "Lines" , "Lines");
    indicator.parameters:addStringAlternative("Type", "Labels", "Labels" , "Labels");
    indicator.parameters:addStringAlternative("Type", "Both", "Both" , "Both");
    
    indicator.parameters:addString("Mode", "TODAY or HISTORICAL ", "TODAY or HISTORICAL" , "TODAY");
    indicator.parameters:addStringAlternative("Mode", "TODAY", "TODAY" , "TODAY");
    indicator.parameters:addStringAlternative("Mode", "HISTORICAL", "HISTORICAL" , "HISTORICAL");

    local TF={"m1" , "m5" ,"m15" ,"m30" , "H1" , "H2", "H3" , "H4",  "H6","H8" , "D1" , "W1", "M1"};
    local i;
    for i = 1, 13,1 do
        indicator.parameters:addGroup(i.. ". Time Frame");    
        if i ~= 12 and i ~= 13 then
        	indicator.parameters:addBoolean("On"..i , "Show " ..  TF[i] .. " Frame", "", false);    
        else
        	indicator.parameters:addBoolean("On"..i , "Show " ..  TF[i] .. " Frame", "", true);    
        end
        
        indicator.parameters:addBoolean("Show"..i , "Show Close " ..  TF[i] .. " Frame", "", false);
        indicator.parameters:addBoolean("ShowHL"..i , "Show High/Low " ..  TF[i] .. " Frame", "", true);
        indicator.parameters:addGroup(i.. ". Time Frame Style");    
        indicator.parameters:addColor("Up"..i, "High Color", "", core.rgb(0, 255, 0));
        indicator.parameters:addColor("Down"..i, "Low Color", "", core.rgb(255, 0, 0));
        indicator.parameters:addColor("Close"..i, "Close Color", "", core.rgb(0, 0, 0));
        
        indicator.parameters:addInteger("width"..i, "Line width", "", 1, 1, 5);
        indicator.parameters:addInteger("CurrentStyle"..i, "Current Period Line style", "", core.LINE_SOLID);
        indicator.parameters:setFlag("CurrentStyle"..i, core.FLAG_LINE_STYLE);
        
        indicator.parameters:addInteger("PreviousStyle"..i, "Previous Period Line style", "", core.LINE_DASH);
        indicator.parameters:setFlag("PreviousStyle"..i, core.FLAG_LINE_STYLE);
    end
    
    indicator.parameters:addGroup("Common Parameters");    
    indicator.parameters:addInteger("Size", "Size", "", 10);
    indicator.parameters:addBoolean("ShowLabel" , "Show Labels","", true);
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
end
local CloseColor;
local source;
local ATF={};
local loading={};
local On={};
local SourceData={};
local font, Wingdings, Bold;
local  Size;  
local Up={};
local Down={};
local Close={};
local  No, LabelColor;
local TF={"m1" , "m5" ,"m15" ,"m30" , "H1" , "H2", "H3" , "H4",  "H6","H8" , "D1" , "W1", "M1"};
local Method;
 local Num;
local ShowLabel;
 local offset, weekoffset;
 local Mode;
 local Show={};
local ShowHL = {};
 local width={};
 local CurrentStyle={};
 local PreviousStyle={};
 local Type;
 function Prepare(nameOnly)     
    
    Method= instance.parameters.Method;
    Type= instance.parameters.Type;
    
    Mode= instance.parameters.Mode;
    ShowLabel= instance.parameters.ShowLabel;
    source = instance.source;
    Size= instance.parameters.Size;
    offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
     
    local name =  "(" .. profile:id() .. ","  .. instance.source:name() .. ","  .. Method.. ")"
    
    local i,j ;
    
    
    LabelColor = instance.parameters.Label;    
     
    instance:name(name);
	
	if nameOnly then
        return;
    end
	
    Num=0;

    for j = 1, 13, 1 do
        On[j]=  instance.parameters:getBoolean ("On"..j);
        local s,e, s1, s2; 
        s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
        s1, e1 = core.getcandle(TF[j], core.now(), 0, 0);
        
        if ((e-s)< (e1-s1)) and On[j] then                
            Num=Num+1;                    
            Show[Num]=  instance.parameters:getBoolean ("Show"..j);
            ShowHL[Num] = instance.parameters:getBoolean("ShowHL" .. j);
            Up[Num] =  instance.parameters:getDouble ("Up"..j);
            Down[Num] =  instance.parameters:getDouble ("Down"..j);
            Close[Num]=  instance.parameters:getDouble ("Close"..j);
            width[Num]=  instance.parameters:getInteger ("width"..j);
            CurrentStyle[Num]=  instance.parameters:getInteger ("CurrentStyle"..j);
            PreviousStyle[Num]=  instance.parameters:getInteger ("PreviousStyle"..j);
            ATF[Num]= TF[j];                
            SourceData[Num]  = core.host:execute("getSyncHistory", source:instrument(),  ATF[Num], source:isBid(), 2 , 200 + Num , 100 +Num); 
            loading[Num]  = true;  
        end
    end
     
    instance:ownerDrawn(true);

end
local id=0;


function Draw(stage, context )
    if stage ~= 0 then
        return;
    end

    context:setClipRectangle (  context:left (), context:top(), context:right (), context:bottom());
    local FLAG=false;
    local   j;    
    for j = 1, Num, 1 do
        if loading[j]  then
            FLAG= true;
        end
    end
    if FLAG then
        return;
    end
    id=0;
    local Now;
    local Last=math.min(context:lastBar (), source:size()-1);
    local First=math.max(source:first(), context:firstBar ());
    local period;
    if  Mode=="TODAY"  then
        period= source:size()-1;
        Line(  context,period  );
    else
        for period = First, Last, 1 do
            Line( context,period  );
        end 
    end
end


function Line(  context,period )
    local Now
    for j = 1, Num, 1 do
        local s1, e1;
        Now=Initialization(period,j);
        if Now~= false then
            if  Type~= "Labels"  then
                s1, e1 = core.getcandle(ATF[j], source:date(period),offset, weekoffset);
                if ShowHL[j] then
                    if Method ~= "Previous" then
                        core.host:execute("drawLine", Id(), s1, SourceData[j].high[Now], e1, SourceData[j].high[Now],Up[j], CurrentStyle[j], width[j]);
                        core.host:execute("drawLine", Id(), s1, SourceData[j].low[Now], e1, SourceData[j].low[Now],Down[j], CurrentStyle[j], width[j]);
                    end
                    if Method ~= "Current" then
                        core.host:execute("drawLine", Id(), s1, SourceData[j].high[Now-1], e1, SourceData[j].high[Now-1],Up[j], PreviousStyle[j], width[j]);
                        core.host:execute("drawLine", Id(), s1, SourceData[j].low[Now-1], e1, SourceData[j].low[Now-1],Down[j], PreviousStyle[j], width[j]);
                    end
                end
                if Show[j] then
                    if Method ~= "Previous" then
                        core.host:execute("drawLine", Id(), s1, SourceData[j].close[Now], e1, SourceData[j].close[Now],Close[j], CurrentStyle[j], width[j]);
                    end
                    if Method ~= "Current" then
                        core.host:execute("drawLine", Id(), s1, SourceData[j].close[Now-1], e1, SourceData[j].close[Now-1],Close[j], PreviousStyle[j], width[j]);
                    end
                end
                if ShowLabel then
                    if ShowHL[j] then
                        if Method ~= "Previous" then
                            core.host:execute("drawLabel1", Id(), e1 ,  core.CR_CHART, SourceData[j].high[Now], core.CR_CHART, core.H_Left, core.V_Top, Bold, LabelColor, ATF[j].. " : " .. win32.formatNumber(SourceData[j].high[Now], false, source:getPrecision()));  
                            core.host:execute("drawLabel1", Id(), e1 ,  core.CR_CHART, SourceData[j].low[Now], core.CR_CHART, core.H_Left, core.V_Top, Bold, LabelColor, ATF[j].. " : " ..  win32.formatNumber(SourceData[j].low[Now], false, source:getPrecision())) ; 
                        end
                        if Method ~= "Current" then  
                            core.host:execute("drawLabel1", Id(), e1 ,  core.CR_CHART, SourceData[j].high[Now-1], core.CR_CHART, core.H_Left, core.V_Top, Bold, LabelColor, ATF[j].. " : " ..  win32.formatNumber(SourceData[j].high[Now-1], false, source:getPrecision()));  
                            core.host:execute("drawLabel1", Id(), e1 ,  core.CR_CHART, SourceData[j].low[Now-1], core.CR_CHART, core.H_Left, core.V_Top, Bold, LabelColor, ATF[j].. " : "  .. win32.formatNumber(SourceData[j].low[Now-1], false, source:getPrecision())); 
                        end
                    end
                end
            end
            if  Type~="Lines"  then
                context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
                width1, height1=  context:measureText (1, ATF[j], 0);
                width2, height2=  context:measureText (1, "Previous", 0);
                width3, height3=  context:measureText (1, "Current", 0);
                HShift= (context:right()-context:left())/3;
                X1=context:right() -HShift- width2*2;
                X2=context:right() -HShift +width3;
                context:drawText (1,  "Previous" , LabelColor, -1, X1, context:top()              ,X1 + width2        , context:top()+height2  , 0)    
                context:drawText (1,  "Current", LabelColor, -1,  X2,         context:top()       ,X2 + width3 , context:top()+height3 , 0)                                    
                context:drawText (1,  ATF[j], LabelColor, -1, X1-width1*2,         context:top()+ height1*(j),X1- width1, context:top()+height1*(j+1), 0)        
                xLabel="";
                xLabel= "H: " .. SourceData[j].high[Now-1];
                xLabel= xLabel .. " L: " .. SourceData[j].low[Now-1];
                width4, height4=  context:measureText (1, xLabel, 0);
                context:drawText (1,  xLabel , LabelColor, -1, X1, context:top()+height2*(j)              ,X1 + width4        , context:top()+height2*(j+1)  , 0);
                
                xLabel="";
                xLabel= "H: "  .. SourceData[j].high[Now];
                xLabel= xLabel .. " L: " .. SourceData[j].low[Now];
                width4, height4=  context:measureText (1, xLabel, 0);   
                width6, height6=  context:measureText (1, xLabel, 0);
                context:drawText (1,  xLabel , LabelColor, -1, X2, context:top()+height2*(j)              ,X2 + width6        , context:top()+height2*(j+1)  , 0);    
            end        
        end             
    end
end

function Update(period )

  
end
function Id()
id=id+1;
return id;
end

function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset,weekoffset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
     

    -- candle is not found
    if P < 0    then
        return false;
    else return P;    
    end
            
end    


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Number=0;

    for j = 1, Num, 1 do
          
              if cookie == (100 + j) then
              loading[j]  = true;
              elseif  cookie == (200 + j ) then
              loading[j]  = false;            
             
              end
         
               
                 if loading[j] then
                 FLAG= true;
                 Number=Number+1;
                 end
    end    
   
           
    
    if FLAG then
     core.host:execute ("setStatus", "  Loading "..((Num) - Number) .. " / " .. (Num) );     
    else
    core.host:execute ("setStatus", "Loaded")
     instance:updateFrom(0);
    end
   
        
    return core.ASYNC_REDRAW ;
    
    
end



