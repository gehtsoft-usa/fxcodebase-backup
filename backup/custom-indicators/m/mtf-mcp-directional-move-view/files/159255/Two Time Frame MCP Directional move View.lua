-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=75939

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
    indicator:name("Two Time Frame MCP Directional move View")
    indicator:description("Two Time Frame MCP Directional move View")
    indicator:requiredSource(core.Bar)
    indicator:type(core.View)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector", "AllCurrencyPair")
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
	
    indicator.parameters:addGroup("Calculation");	 
	
 	

    indicator.parameters:addBoolean("bidask", "Bid/ask", "", false)
    indicator.parameters:setFlag("bidask", core.FLAG_BIDASK)

    for i = 1, 20, 1 do
        indicator.parameters:addGroup(i .. ". Currency Pair ")
        Add(i)
    end
	
	


    indicator.parameters:addGroup("Time Frame Selector")
    AddTimeFrame(1, "D1" )
    AddTimeFrame(2, "H1" )
 

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.COLOR_LABEL )
    indicator.parameters:addColor("Up", "OB Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "OS Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128))
 

    indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70, 0, 100)


end

function AddTimeFrame(id, TF )

    indicator.parameters:addGroup(id.. ". Time Frame")
  
	
	indicator.parameters:addString("TF".. id, "Time Frame", "", TF);
	indicator.parameters:setFlag("TF".. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("SignalDirection".. id, "Direction", "Direction", "Any")
    indicator.parameters:addStringAlternative("SignalDirection".. id,"Up","","Up")
    indicator.parameters:addStringAlternative("SignalDirection".. id,"Down","","Down")
    indicator.parameters:addStringAlternative("SignalDirection".. id,"Any","","Any")	
    indicator.parameters:addStringAlternative("SignalDirection".. id,"Opposite direction","","Opposite")    
    indicator.parameters:addStringAlternative("SignalDirection".. id,"Same direction","","Same")  

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
local TF={};
-- Routine
function Prepare(nameOnly)

    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    
	InstrumentType= instance.parameters.InstrumentType; 
    
    Color = instance.parameters.Color
    Size = instance.parameters.Size
 
    Type = instance.parameters.Type
    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Neutral = instance.parameters.Neutral
  
 
    Pair={}; 
	
    Num = 2
    for i = 1, 2, 1 do 
         
            TF[i]  = instance.parameters:getString("TF" .. i)
			SignalDirection[i] = instance.parameters:getString("SignalDirection" .. i)
    
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
            Indicator[i] = {}     

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
              
            end
        end
 
 
    instance:ownerDrawn(true)
    core.host:execute("subscribeTradeEvents", 999, "offers")
    instance:initView("Two Time Frame MCP Directional move View", 0, 1, instance.parameters.bidask, true)

    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
    open:setVisible(false)
	
	    core.host:execute ("setTimer", 1, 5);
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

 
FilterCount=0;
 

        for i = 1, Count, 1 do
		
		Signal=true;
		
				for j = 1, Num, 1 do
				
				
							 
							if (Source[i][j].close[Source[i][j].close:size() - 1] >  Source[i][j].open[Source[i][j].open:size() - 1] and SignalDirection[j]=="Down")
							or (Source[i][j].close[Source[i][j].close:size() - 1] <  Source[i][j].open[Source[i][j].open:size() - 1] and SignalDirection[j]=="Up" )		
                            --Opposite
							
							
							then
							Signal=false;
							end
							
							
							-- Opposite
							if j == 1 and SignalDirection[j] == "Opposite" then
								if (
									Source[i][j].close[Source[i][j].close:size() - 1] > Source[i][j].open[Source[i][j].open:size() - 1] and
									Source[i][j + 1].close[Source[i][j + 1].close:size() - 1] > Source[i][j + 1].open[Source[i][j + 1].open:size() - 1]
								) or (
									Source[i][j].close[Source[i][j].close:size() - 1] < Source[i][j].open[Source[i][j].open:size() - 1] and
									Source[i][j + 1].close[Source[i][j + 1].close:size() - 1] < Source[i][j + 1].open[Source[i][j + 1].open:size() - 1]
								) then
									Signal = false
								end
							end

							if j == 2 and SignalDirection[j] == "Opposite" then
								if (
									Source[i][j].close[Source[i][j].close:size() - 1] > Source[i][j].open[Source[i][j].open:size() - 1] and
									Source[i][j - 1].close[Source[i][j - 1].close:size() - 1] > Source[i][j - 1].open[Source[i][j - 1].open:size() - 1]
								) or (
									Source[i][j].close[Source[i][j].close:size() - 1] < Source[i][j].open[Source[i][j].open:size() - 1] and
									Source[i][j - 1].close[Source[i][j - 1].close:size() - 1] < Source[i][j - 1].open[Source[i][j - 1].open:size() - 1]
								) then
									Signal = false
								end
							end

							-- Same
							if j == 1 and SignalDirection[j] == "Same" then
								if (
									Source[i][j].close[Source[i][j].close:size() - 1] > Source[i][j].open[Source[i][j].open:size() - 1] and
									Source[i][j + 1].close[Source[i][j + 1].close:size() - 1] < Source[i][j + 1].open[Source[i][j + 1].open:size() - 1]
								) or (
									Source[i][j].close[Source[i][j].close:size() - 1] < Source[i][j].open[Source[i][j].open:size() - 1] and
									Source[i][j + 1].close[Source[i][j + 1].close:size() - 1] > Source[i][j + 1].open[Source[i][j + 1].open:size() - 1]
								) then
									Signal = false
								end
							end

							if j == 2 and SignalDirection[j] == "Same" then
								if (
									Source[i][j].close[Source[i][j].close:size() - 1] > Source[i][j].open[Source[i][j].open:size() - 1] and
									Source[i][j - 1].close[Source[i][j - 1].close:size() - 1] < Source[i][j - 1].open[Source[i][j - 1].open:size() - 1]
								) or (
									Source[i][j].close[Source[i][j].close:size() - 1] < Source[i][j].open[Source[i][j].open:size() - 1] and
									Source[i][j - 1].close[Source[i][j - 1].close:size() - 1] > Source[i][j - 1].open[Source[i][j - 1].open:size() - 1]
								) then
									Signal = false
								end
							end							

							
			     end
				 
			if Signal== true then
				FilterCount=FilterCount+1;
				Filter[FilterCount]=i;
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
    yGap = (bottom - top) / (FilterCount + 1)

    if xGap > 250 then
        xGap = 250
    end

    for i = 1, FilterCount, 1 do
        for j = 1, Num, 1 do
          
            ViewDraw(context, i, j)
        end
    end
end	
 

function ViewDraw (context, i, j)

--Count
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
        width, height = context:measureText(7, Pair[Filter[i]], context.CENTER)
        context:drawText(7, Pair[Filter[i]], Color, -1, x1, y0 - height / 2, x2, y0 + height / 2, context.CENTER, 0)
    end

    if i == FilterCount then
        width, height = context:measureText(7, TF[j], 0)
        context:drawText(7, TF[j], Color, -1, x1 + xGap, y1, x2 + xGap, y2, context.CENTER)
    end
	
	if   not Source[Filter[i]][j].close:hasData(Source[Filter[i]][j].close:size() - 1)  
    then
        return
    end
 
 
	local Value = ( Source[Filter[i]][j].close[Source[Filter[i]][j].close:size() - 1] -  Source[Filter[i]][j].open[Source[Filter[i]][j].open:size() - 1])/(Source[Filter[i]][j].open[Source[Filter[i]][j].open:size()-1] /100)
	 
 
 
       if Value > 0 then
       context:drawText(8,  string.format("%." .. 2 .. "f", Value), Up, -1, x1 + xGap, y1 + yGap  , x2 + xGap, y1  + yGap +yGap/2 , context.CENTER)
       context:drawText(8, "Up", Up, -1, x1 + xGap, y1 + yGap+yGap/2  , x2 + xGap, y1  + yGap +yGap/2+yGap/2 , context.CENTER)		   
	   
	   elseif Value < 0 then
       context:drawText(8,  string.format("%." .. 2 .. "f", Value), Down, -1, x1 + xGap, y1 + yGap  , x2 + xGap, y1  + yGap +yGap/2 , context.CENTER)	   
       context:drawText(8, "Down", Down, -1, x1 + xGap, y1 + yGap+yGap/2  , x2 + xGap, y1  + yGap +yGap/2+yGap/2 , context.CENTER)		   
	   else
       context:drawText(8,  string.format("%." .. 2 .. "f", Value), Neutral, -1, x1 + xGap, y1 + yGap  , x2 + xGap, y1  + yGap +yGap/2 , context.CENTER)	   
	   end
	  
 
end
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=75939

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