-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63267

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF MCP Reverse Candles View");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);
  
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");

	indicator.parameters:addString("Live", "Live/End Of Turn", "Live/End Of Turn" , "Live");
    indicator.parameters:addStringAlternative("Live", "Live", "Live" , "Live");
    indicator.parameters:addStringAlternative("Live", "End Of Turn", "End Of Turn" , "End Of Turn");
    
    indicator.parameters:addBoolean("bidask", "Bid/ask", "", false);
    indicator.parameters:setFlag("bidask", core.FLAG_BIDASK);

	for i= 1 ,20, 1 do
        indicator.parameters:addGroup(i..". Currency Pair ");
        Add(i);
	end
	
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m1", false );
	AddTimeFrame (2 , "m5" , false );
	AddTimeFrame (3 , "m15", false );
	AddTimeFrame (4 , "m30" , false  );
	AddTimeFrame (5 , "H1" , true );
	AddTimeFrame (6 , "H2", false );
	AddTimeFrame (7 , "H3" , false );
	AddTimeFrame (8 , "H4", false );
	AddTimeFrame (9 , "H6" , false  );
	AddTimeFrame (10 , "H8" , true );
    AddTimeFrame (11 , "D1", true );
	AddTimeFrame (12 , "W1" , true );
	AddTimeFrame (13 , "M1", true );
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "OB Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "OS Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));

    indicator.parameters:addDouble("minusX", "Vertical spacing", "", 10 , 0, 50);
	indicator.parameters:addDouble("minusY", "Horizontal spacing", "", 10 , 0, 50);
 
 
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 
end

function AddTimeFrame(id , FRAME , DEFAULT  )
	indicator.parameters:addBoolean("Use"..id , "Show "..  FRAME  , "", DEFAULT); 
end

function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();
    end
	
	 
    return list, count,point;
end

 
function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"
			  };
	
    if id <= 5 then	
        indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);
    else
        indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);
    end	
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}; 
local TF={};
local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;
local Source={};
local Size;
local transparency; 
local loading={}; 
local source;
local Pair={};
local  Count; 
local Type;  
local Dodaj={};   
local Point={};
local Use={};
local Num;
local ShowCells;
local Up,  Down,Neutral ;
local minusX, minusY;  
local Live;

local Status={};

local HISTORY_LOADING_ID = 1000;
-- Routine
function Prepare(nameOnly)
  
    Color= instance.parameters.Color; 
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;    
	Type= instance.parameters.Type;  
	Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	Neutral= instance.parameters.Neutral;
	Live= instance.parameters.Live;
	minusX= (instance.parameters.minusX/100);
	minusY= (instance.parameters.minusY/100);
	
	
	 local name = profile:id();
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	 

	 
	if Type== "Multiple currency pair" then 
        Count=0;
        for i= 1, 20 , 1 do	 
            Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
            if Dodaj[i] then
                Count=Count+1;
                Pair[Count]=   instance.parameters:getString ("Pair"..i);	
                Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
            end
        end

	elseif Type== "All currency pair" then 
        Pair, Count,Point = getInstrumentList();
	end
	
	Num=0;
    for i = 1 , 13 , 1 do  
        Use[i]=instance.parameters:getBoolean("Use" .. i);

        if Use[i] then
            Num=Num+1;
            TF[Num]=  iTF[i];	
        end
    end
 
    local ID=0;

        for i = 1, Count, 1 do
            Source[i] ={};
            loading[i] ={}; 
            Status[i]={};

            for j = 1, Num, 1 do
                ID = ID + 1;  
                Source[i][j] = core.host:execute("getHistory", HISTORY_LOADING_ID + ID, Pair[i], TF[j], 0, 0, instance.parameters.bidask);
                loading[i][j] = true;
            end
        end
   

   

    instance:ownerDrawn(true); 
    core.host:execute("subscribeTradeEvents", 999, "offers");
    instance:initView("SSD", 0, 1, instance.parameters.bidask, true);
    
    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0);
    open:setVisible(false);
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie >= HISTORY_LOADING_ID then
        local i;
        local ID = 0;

        for i = 1, Count, 1 do
            for j = 1, Num, 1 do
                ID = ID + 1;
                if cookie == (HISTORY_LOADING_ID + ID) then
                    loading[i][j] = false;
                end
            end
        end

        local FLAG=false; 
        local Number=0;
        
        for i = 1, Count, 1 do
            for j = 1, Num, 1 do
                if loading[i][j] then
                    FLAG = true;
                    Number=Number+1;
                end
            end
        end
        
        if FLAG then
            core.host:execute ("setStatus", "Loading ".. (Count*Num - Number) .. " / " ..  Count*Num );	 
        else
            core.host:execute ("setStatus", "Loaded") 
            for i = 0, Source[1][1]:size() - 1 do
                instance:addViewBar(Source[1][1]:date(i));
               
            end
        end
       
        return core.ASYNC_REDRAW;
    elseif cookie == 999 then
        local Loading = false; 
        for i = 1, Count, 1 do 
            for j = 1, Num, 1 do 
                if loading[i][j] then
                    Loading = true; 
                end
            end 
        end
    end
end

local top, bottom;
local left, right;
local xGap;	 
local yGap;

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
    --shoudn't be called
end

local init = false; 
function Draw(stage, context)
	if stage ~= 2 then
        return;
	end
	
	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
            if loading [i][j] then
                return;
            end
		end	
    end
	

    if not init then
        context:createPen(11, context.SOLID, 1, Up); 
        context:createSolidBrush(12, Up);
        
        context:createPen(21, context.SOLID, 1, Down); 
        context:createSolidBrush(22, Down);
                        
        init = true;
    end
		
	    
    
    top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right();
    

    
    xGap=  (right-left)/(Num+1);	 
    yGap=  (bottom-top)/(Count+1);
            

    if xGap> 250 then
    xGap= 250;
    end
           
    
    
    for i= 1, Count,1 do 	
        for j= 1, Num,1 do  		
         Calculate (context,i, j); 
        end
    end

end	

 

 function Calculate (context,i, j )
   
     
	 
     if  not Source[i][j].close:hasData(Source[i][j].close:size()-1)   
     or  not Source[i][j].close:hasData(Source[i][j].close:size()-2)   
     then
     return;
     end
	 
	 
	 
	

	
	     y1=bottom -(i+1)*yGap;
		y2=bottom -(i )*yGap;
		y0=y1 +yGap*3/2;
		
		x1=right -(j+1)*xGap;
		x2=right -(j )*xGap;
		
		iwidth = ((xGap/7)/100)*Size ;
		iheight=  (yGap/100)*Size;
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
        context:createFont (8, "Wingdings",iwidth*1.77, iheight , 0); 
		
		if j== Num then 
		width, height = context:measureText (7, Pair[i], context.CENTER  ); 
		context:drawText (7, Pair[i], Color, -1, x1, y0-height/2, x2, y0+height/2, context.CENTER, 0);
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap  , y1 ,x2+xGap ,  y2 , context.CENTER   );	
		end
        
		--[[ Short reverse candle
		- current high is higher than previous high;
		- current close is lower than current open= current close is lower than previous close;
		- previous close is higher than previous open;

		Long reverse candle
		- current low is lower than previous low;
		- current close is higher than current open= current close is higher than previous close;
		- previous close is lower than previous open;]]
		local po, p1;
		
		if Live== "Live" then
		p0= Source[i][j].close:size()-1;
		p1= Source[i][j].close:size()-2;
		else
		p0= Source[i][j].close:size()-2;
		p1= Source[i][j].close:size()-3;
		end
		
 
		
		if  Source[i][j].high[p0]>  Source[i][j].high[p1]
		and  Source[i][j].close[p0]<  Source[i][j].open[p0]
		and  Source[i][j].close[p1]>  Source[i][j].open[p1]
		then
		Value= "\226";
		iColor=Down;
		elseif  Source[i][j].low[p0]<  Source[i][j].low[p1]
		and  Source[i][j].close[p0] >  Source[i][j].open[p0]
		and  Source[i][j].close[p1]<  Source[i][j].open[p1]
		then
		Value= "\225";
		iColor=Up;
		else
		Value= "\160";
		iColor=Neutral;
		end
		
		
		width, height = context:measureText (8, Value, 0);  
        context:drawText (8, Value, iColor, -1, x1+xGap , y1+yGap, x2+xGap, y2+yGap, context.CENTER); 
        
	  
 end
 
 
 