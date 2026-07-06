-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71325

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Year View")
    indicator:description("Year View")
    indicator:requiredSource(core.Bar)
    indicator:type(core.View)

    indicator.parameters:addGroup("Calculation") 
    indicator.parameters:addBoolean("bidask", "Bid/ask", "", false)
    indicator.parameters:setFlag("bidask", core.FLAG_BIDASK)
	
 
	indicator.parameters:addString("Instrument" , "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addInteger("LookBack", "LookBack Period", "LookBack Period", 10)
	
    indicator.parameters:addString("Method", "Method", "Method" , "Percentage");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0))
    indicator.parameters:addColor("Up", "OB Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "OS Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255)) 

    indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70, 0, 100)

 
end


 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local Color
local Source  
local Size
local transparency
local loading 
local source  
local Up, Down, Neutral
local minusX, minusY  
local Instrument; 
local LookBack; 
--local Status = {}
local Year;
local HISTORY_LOADING_ID = 1000
local dayoffset, weekoffset;
local CurrentData;
local Method;
local Point;
-- Routine
function Prepare(nameOnly)
 
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
    Color = instance.parameters.Color
    Size = instance.parameters.Size 
 
    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Neutral = instance.parameters.Neutral  
  
  
    Instrument = instance.parameters.Instrument;
    LookBack = instance.parameters.LookBack;
	Method= instance.parameters.Method;

    Point= core.host:findTable("offers"):find("Instrument", Instrument).PointSize;	

    local ID = 1;
 
 
                Source  =
                    core.host:execute(
                    "getHistory",
                    HISTORY_LOADING_ID + ID,
                    Instrument,
                    "M1" ,
                    0,
                    0,
                    instance.parameters.bidask
                )
                loading  = true
 
       
    local date = core.dateToTable(core.now() );
    Year= date.year; 
    Month= date.month;       
    CurrentData= core.datetime (Year, Month, 28, 1, 1, 1);	
	
    instance:ownerDrawn(true)
    core.host:execute("subscribeTradeEvents", 999, "offers")
    instance:initView("Year View", 0, 1, instance.parameters.bidask, true)

    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0)
    open:setVisible(false)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, success, message, message1, message2)
  
    if cookie >= HISTORY_LOADING_ID then
        local i
        local ID = 1

         
         
                if cookie == (HISTORY_LOADING_ID + ID) then
                    loading  = false
                end
            
    
 

        if loading then
            core.host:execute("setStatus", "Loading "  )
        else
            core.host:execute("setStatus", "Loaded")
            for i = 0, Source :size() - 1 do
                instance:addViewBar(Source:date(i))
               
               
            end
        end

        return core.ASYNC_REDRAW
    elseif cookie == 999 then
            --Indicator[i][j]:update(core.UpdateLast)
        
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

local init = false
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if loading then
	return;
	end
	
	
    if not init then
        context:createPen(11, context.SOLID, 1, Up)
        context:createSolidBrush(12, Up)

        context:createPen(21, context.SOLID, 1, Down)
        context:createSolidBrush(22, Down)

        init = true
    end

    top, bottom = context:top(), context:bottom()
    left, right = context:left(), context:right()

    xGap = (right - left) / (LookBack+1)
    yGap = (bottom - top) / (12+1)

    if xGap > 250 then
        xGap = 250
    end

    for i = 1, LookBack, 1 do
        for j = 1, 12, 1 do
            Calculate(context, i, j)
        end
    end
end


local Months={"January","February","March","April","May","June","July","August","September","October","November","December"}

function Calculate(context, i, j)
   
   
   local Date= core.datetime (Year-i+1, j, 1, 1, 1, 1);	  
   local Candle = core.getcandle("M1", Date, dayoffset, weekoffset); 
   local p = core.findDate(Source, Candle, false); 
  
    y1 = top + (j-1) * yGap
    y2 = top + (j) * yGap 

    x1 = right  -(i + 1) * xGap
    x2 = right - (i) * xGap

    iwidth = ((xGap / 10) / 100) * Size
    iheight = (yGap / 100) * Size

    context:createFont(7, "Arial", iwidth, iheight, 0)

    if j == 1 then
        width, height = context:measureText(7, tostring(Year- i+1), context.CENTER)
        context:drawText(7, tostring(Year- i+1), Color, -1, x1  , y1,  x2  , y2, context.CENTER, 0)
    end

    if i == 1 then
        width, height = context:measureText(7,  Months[j], 0) 
		 context:drawText(7, Months[j], Color, -1, x1 + xGap,y1 + yGap, x2 + xGap, y2 + yGap, context.CENTER)
    end
	
    if Method== "Pips" then
	Value = (Source.close[p]  - Source.open[p])/Point; 	
	else
    Value = (Source.close[p]  - Source.open[p])/(Source.open[p] /100); 
	end
	
    Value= string.format("%." .. 2 .. "f", Value);
	
    if p> 0 and  Source.close:hasData(p) and Date <= CurrentData  then
		   if  Source.close[p]  > Source.open[p]  then
			context:drawText(7, Value, Up, -1, x1 , y1 + yGap, x2 , y2 + yGap, context.CENTER)
		   elseif  Source.close[p]  < Source.open[p]  then
			context:drawText(7, Value, Down, -1, x1 , y1 + yGap, x2 , y2 + yGap, context.CENTER)
			else
			context:drawText(7, Value, Neutral, -1, x1 , y1 + yGap, x2 , y2 + yGap, context.CENTER)
	 
		   end
    end

end