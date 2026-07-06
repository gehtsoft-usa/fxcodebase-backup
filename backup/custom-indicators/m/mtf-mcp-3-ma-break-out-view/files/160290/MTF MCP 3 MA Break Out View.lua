-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=76252

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

function Init()
    indicator:name("MTF MCP 3 MA Break Out View")
    indicator:description("MTF MCP 3 MA Break Out View")
    indicator:requiredSource(core.Bar)
    indicator:type(core.View)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector", "Multiple currency pair")
    indicator.parameters:addStringAlternative(
        "Type",
        "Multiple currency pair",
        "Multiple currency pair",
        "Multiple currency pair"
    )
    indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair", "AllCurrencyPair")
 
    indicator.parameters:addInteger("InstrumentType", "Instrument Type", "Instrument Type", 0)
    indicator.parameters:addIntegerAlternative("InstrumentType","All","",0)
    indicator.parameters:addIntegerAlternative("InstrumentType","Forex","",1)
    indicator.parameters:addIntegerAlternative("InstrumentType","Indices","",2)
    indicator.parameters:addIntegerAlternative("InstrumentType","Commodity","",3)
    indicator.parameters:addIntegerAlternative("InstrumentType","Treasury","",4)
    indicator.parameters:addIntegerAlternative("InstrumentType","Bullion","",5)
    indicator.parameters:addIntegerAlternative("InstrumentType","Shares","",6)
    indicator.parameters:addIntegerAlternative("InstrumentType","FXIndex","",7)	
    indicator.parameters:addIntegerAlternative("InstrumentType","CFD Shares","",8)
    indicator.parameters:addIntegerAlternative("InstrumentType","Crypto","",9)	


    indicator.parameters:addGroup("1. MA")	 
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");		
    indicator.parameters:addInteger("Period1", "MA Period", "Period", 13);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");	
	

    indicator.parameters:addGroup("2. MA")	 
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");		
    indicator.parameters:addInteger("Period2", "MA Period", "Period", 48);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	


    indicator.parameters:addGroup("3. MA")	 
	indicator.parameters:addString("Price3", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price3", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price3", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price3", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price3","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price3", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price3", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price3", "WEIGHTED", "", "weighted");		
    indicator.parameters:addInteger("Period3", "MA Period", "Period", 200);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");			
	
  
	indicator.parameters:addBoolean("Confirmation", "Trend Confirmation", "", true)
 	

    indicator.parameters:addBoolean("bidask", "Bid/ask", "", false)
    indicator.parameters:setFlag("bidask", core.FLAG_BIDASK)

    for i = 1, 20, 1 do
        indicator.parameters:addGroup(i .. ". Currency Pair ")
        Add(i)
    end
	
	


    indicator.parameters:addGroup("Time Frame Selector")
    AddTimeFrame(1, "m1", false)
    AddTimeFrame(2, "m5", false)
    AddTimeFrame(3, "m15", true)
    AddTimeFrame(4, "m30", false)
    AddTimeFrame(5, "H1", true)
    AddTimeFrame(6, "H2", false)
    AddTimeFrame(7, "H3", false)
    AddTimeFrame(8, "H4", false)
    AddTimeFrame(10, "H8", true)
    AddTimeFrame(9, "H6", false)
    AddTimeFrame(11, "D1", false)
    AddTimeFrame(12, "W1", false)
    AddTimeFrame(13, "M1", false)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.COLOR_LABEL )
    indicator.parameters:addColor("Up", "OB Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "OS Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128))
 

    indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70, 0, 100)


end

function AddTimeFrame(id, FRAME, DEFAULT)

    indicator.parameters:addGroup(FRAME)
    indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT)
	
	
	indicator.parameters:addString("SignalDirection".. id, "Direction", "Direction", "Any")
    indicator.parameters:addStringAlternative("SignalDirection".. id,"Up","","Up")
    indicator.parameters:addStringAlternative("SignalDirection".. id,"Down","","Down")
    indicator.parameters:addStringAlternative("SignalDirection".. id,"Any","","Any")	
    
end



function Add(id)
    local Init = {
        "EUR/USD",
        "USD/JPY",
        "GBP/USD",
        "USD/CHF",
        "EUR/CHF",
        "AUD/USD",
        "USD/CAD",
        "NZD/USD",
        "EUR/GBP",
        "EUR/JPY",
        "GBP/JPY",
        "CHF/JPY",
        "GBP/CHF",
        "EUR/AUD",
        "EUR/CAD",
        "AUD/CAD",
        "AUD/JPY",
        "CAD/JPY",
        "NZD/JPY",
        "GBP/CAD"
    }

    if id <= 5 then
        indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", true)
    else
        indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", false)
    end
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id])
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
	
	
	 
 
   -- indicator.parameters:addBoolean("Invert" .. id, "Invers Signal", "", false)	
    
 
end
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local iTF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
local TF = {}
 
local pauto = "(%a%a%a)/(%a%a%a)"
local Color
local Source = {}
local Size
local transparency
local loading = {}
local source
local Pair = {}
local Count
local Type 
local Point = {} 
local Num
local ShowCells
local Up, Down, Neutral
 
local Indicator = {} 
local Period, Power, Deviation; 
local InstrumentType;
local HISTORY_LOADING_ID = 1000

local SignalDirection={};
--local Invert={};
local Filter={};
local FilterCount;

local Indicator1={};
local Indicator2={};
local Indicator3={};

local First=true;
-- Routine
function Prepare(nameOnly)

    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
	
	
	Price1 = instance.parameters.Price1;
	Method1 = instance.parameters.Method1;
	Period1 = instance.parameters.Period1;
 
 	Price2 = instance.parameters.Price2;
	Method2 = instance.parameters.Method2;
	Period2 = instance.parameters.Period2;
	
	
	Price3 = instance.parameters.Price3;
	Method3 = instance.parameters.Method3;	
 	Period3 = instance.parameters.Period3;  

    Confirmation = instance.parameters.Confirmation;	
	
	InstrumentType= instance.parameters.InstrumentType; 
    
    Color = instance.parameters.Color
    Size = instance.parameters.Size
 
    Type = instance.parameters.Type
    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Neutral = instance.parameters.Neutral
  
 
    Pair={}; 
	
    Num = 0
    for i = 1, 13, 1 do
 

        if instance.parameters:getBoolean("Use" .. i) then
            Num = Num + 1
            TF[Num] = iTF[i]
			SignalDirection[Num] = instance.parameters:getString("SignalDirection" .. i)
        end
    end	
	
    if Type == "Multiple currency pair" then
        Count = 0
        for i = 1, 20, 1 do
   
            if instance.parameters:getBoolean("Dodaj" .. i)
			and (core.host:findTable("offers"):find("Instrument",instance.parameters:getString("Pair" .. i)).InstrumentType == InstrumentType or InstrumentType== 0 )
			then
                Count = Count + 1
                Pair[Count] = instance.parameters:getString("Pair" .. i)
                Point[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize
				--Invert[Count]=instance.parameters:getBoolean("Invert" .. i)
				
			  
				 
            end
        end
    elseif Type == "AllCurrencyPair" then
        Pair, Count, Point = getInstrumentList()
    end



    local ID = 0
	
 
  
        for i = 1, Count, 1 do
            Source[i] = {}
            loading[i] = {}
			Indicator1[i] = {}
			Indicator2[i] = {}
			Indicator3[i] = {} 

            for j = 1, Num, 1 do
                ID = ID + 1
                Source[i][j] =
                    core.host:execute(
                    "getHistory",
                    HISTORY_LOADING_ID + ID,
                    Pair[i],
                    TF[j],
                    0,
                    0,
                    instance.parameters.bidask
                )
                loading[i][j] = true
				
				
				
			Indicator1[i][j]= core.indicators:create(Method1, Source[i][j][Price1], Period1);			
	        Indicator2[i][j] = core.indicators:create(Method2, Source[i][j][Price2], Period2);				
	        Indicator3[i][j] = core.indicators:create(Method3, Source[i][j][Price3], Period3);		
              
            end
        end
 
 
    instance:ownerDrawn(true)
    core.host:execute("subscribeTradeEvents", 999, "offers")
    instance:initView("MTF MCP 3 MA Break Out View", 0, 1, instance.parameters.bidask, true)

    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
    open:setVisible(false)
	
	    core.host:execute ("setTimer", 1, 5);
		
	First=true;	
end

function getInstrumentList()
    local list = {}
    local point = {}

    local count = 0
    local row, enum

    enum = core.host:findTable("offers"):enumerator()
    row = enum:next()
    while row ~= nil do
	    if  row.InstrumentType == InstrumentType or InstrumentType== 0 then
        count = count + 1
        list[count] = row.Instrument
        point[count] = row.PointSize
		end
        row = enum:next()
    end

    return list, count, point
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, success, message, message1, message2)

    if cookie >= HISTORY_LOADING_ID then
        local i
        local ID = 0

        for i = 1, Count, 1 do
            for j = 1, Num, 1 do
                ID = ID + 1
                if cookie == (HISTORY_LOADING_ID + ID) then
                    loading[i][j] = false
                end
            end
        end

        local FLAG = false
        local Number = 0

        for i = 1, Count, 1 do
            for j = 1, Num, 1 do
                if loading[i][j] then
                    FLAG = true
                    Number = Number + 1
                end
            end
        end

        if FLAG then
            core.host:execute("setStatus", "Loading " .. (Count * Num - Number) .. " / " .. Count * Num)
        else
            core.host:execute("setStatus", "Loaded")
            for i = 0, Source[1][1]:size() - 1 do
                instance:addViewBar(Source[1][1]:date(i))             
			  
            end
			
					      
		            Calculate();
		               
        end

        return core.ASYNC_REDRAW
    end
	if cookie == 999 or cookie == 1 then
        local Loading = false
        for i = 1, Count, 1 do
            for j = 1, Num, 1 do
                if loading[i][j] then
                    Loading = true				             
                end
            end
			
			
			
        end
		
		if Loading== false then
		Calculate();
		end
    end
end


function Calculate()

 
    if First then  
	    First=false;
        for i = 1, Count, 1 do		
				for j = 1, Num, 1 do					
				Indicator1[i][j]:update(core.UpdateAll);
			    Indicator2[i][j]:update(core.UpdateAll);	
			    Indicator3[i][j]:update(core.UpdateAll);	
		 		end
	    end		
    else
        for i = 1, Count, 1 do		
				for j = 1, Num, 1 do					
				Indicator1[i][j]:update(core.UpdateLast);
			    Indicator2[i][j]:update(core.UpdateLast);	
			    Indicator3[i][j]:update(core.UpdateLast);	
		 		end
	    end	
	end
end

local top, bottom
local left, right
local xGap
local yGap

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    --shoudn't be called
end

 
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    for i = 1, Count, 1 do
        for j = 1, Num, 1 do
            if loading[i][j] then
                return
            end
        end
    end

 

    top, bottom = context:top(), context:bottom()
    left, right = context:left(), context:right()

    xGap = (right - left) / (Num + 1)
    yGap = (bottom - top) / (Count + 1)

    if xGap > 250 then
        xGap = 250
    end

    for i = 1, Count, 1 do
        for j = 1, Num, 1 do
          
            ViewDraw(context, i, j)
        end
    end
end	
 

function ViewDraw (context, i, j)

    xGap = (right - left) / (Num + 1)
    yGap = (bottom - top) / (Count + 1)


    y1 = bottom - (i + 1) * yGap
    y2 = bottom - (i) * yGap
    y0 = y1 + yGap * 3 / 2

    x1 = right - (j + 1) * xGap
    x2 = right - (j) * xGap

    iwidth = ((xGap / 7) / 100) * Size
    iheight = (yGap / 100) * Size

    context:createFont(7, "Arial", iwidth, iheight, 0)
    context:createFont(8, "Arial", iwidth, iheight/2, 0)
    if j == Num then
        width, height = context:measureText(7, Pair[i], context.CENTER)
        context:drawText(7, Pair[i], Color, -1, x1, y0 - height / 2, x2, y0 + height / 2, context.CENTER, 0)
    end

    if i == Count then
        width, height = context:measureText(7, TF[j], 0)
        context:drawText(7, TF[j], Color, -1, x1 + xGap, y1, x2 + xGap, y2, context.CENTER)
    end
	
	if   not Source[i][j].close:hasData(Source[i][j].close:size() - 1)  
    then
        return
    end
 

            local src_close = Source[i][j].close
            local src_open = Source[i][j].open			
            local ma1 = Indicator1[i][j].DATA
            local ma2 = Indicator2[i][j].DATA
            local ma3 = Indicator3[i][j].DATA
			
            local sz_src = Source[i][j].close:size()-1
            local sz_ma1 = Indicator1[i][j].DATA:size()-1
           local sz_ma2 = Indicator2[i][j].DATA:size()-1	
           local sz_ma3 = Indicator3[i][j].DATA:size()-1	
			
            local c1 = src_close[sz_src ] 
            local o1 = src_open[sz_src ] 	
				
            local m1  = ma1[sz_ma1 ] 			
            local m2 =  ma2[sz_ma2 ]				
            local m3 =  ma3[sz_ma3 ]
 
			
		if c1 > m1 and o1 < m1  and ((Confirmation and m1 > m2 and m2 > m3) or not Confirmation) then
        width, height = context:measureText(7, "Up", 0)
        context:drawText(7, "Up"   , Up   , -1, x1 + xGap, y0 - height / 2  , x2 + xGap, y0 + height / 2 , context.CENTER,0)
	    elseif c1 < m1 and o1 > m1 and ((Confirmation and  m1 < m2 and m2 < m3)  or not Confirmation) then
        width, height = context:measureText(7, "Down", 0)	   
        context:drawText(7, "Down", Down, -1, x1 + xGap, y0 - height / 2  , x2 + xGap, y0 + height / 2 , context.CENTER)		
	    end

 
end
-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=76252

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 