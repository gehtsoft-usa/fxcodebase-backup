-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1613&p=3186#p3186

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Engulfing Bar")
	indicator:description("Bar Helper")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addBoolean("Complet", "Use Complet candle", "", false)
	indicator.parameters:addBoolean("Same", "Same Color Filter", "", false)
	indicator.parameters:addBoolean("ma", "MA Filter", "", false)

	indicator.parameters:addString("Show", "Up/Down Trend Filter", "", "Both")
	indicator.parameters:addStringAlternative("Show", "Both", "", "Both")
	indicator.parameters:addStringAlternative("Show", "Up", "", "Up")
	indicator.parameters:addStringAlternative("Show", "Down", "", "Down")

	indicator.parameters:addInteger("Period", "MA Period", "Period", 50)
	indicator.parameters:addString("Method", "MA Method", "Method", "MVA")
	indicator.parameters:addStringAlternative("Method", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("Method", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("Method", "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA")
	indicator.parameters:addStringAlternative("Method", "WMA", "WMA", "WMA")

	indicator.parameters:addGroup("Style")

	indicator.parameters:addColor("Top", "Color of Bullish bar", "Color of Bullish bar", core.rgb(255, 0, 255))
	indicator.parameters:addColor("Bottom", "Color of Bearish bar", "Color of Bearish bar", core.rgb(0, 0, 0))
	indicator.parameters:addString("Type", "Presentation Type", "", "Arrows")
	indicator.parameters:addStringAlternative("Type", "Arrows", "", "Arrows")
	indicator.parameters:addStringAlternative("Type", "Candles Color", "", "Color")
	indicator.parameters:addStringAlternative("Type", "Background", "", "bg")
	indicator.parameters:addColor("UP", "Color of Up Candle", "Color of Up Candle", core.COLOR_UPCANDLE)
	indicator.parameters:addColor("DOWN", "Color of Down Candle", "Color of Down Candle", core.COLOR_DOWNCANDLE)
	indicator.parameters:addInteger("Transparency", "Background transparency (%)", "", 80, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local UP, DOWN
local Method
local first
local source = nil
local ma, MA
-- Streams block
local up = nil
local down = nil
local Period
local Same = nil
local Bar = nil
local Type
local open = nil
local close = nil
local high = nil
local low = nil
local Complet
local Show
-- Routine
function Prepare(nameOnly)
	source = instance.source
	Complet = instance.parameters.Complet
	Type = instance.parameters.Type
	Same = instance.parameters.Same
	Method = instance.parameters.Method
	ma = instance.parameters.ma
	UP = instance.parameters.UP
	DOWN = instance.parameters.DOWN
	Period = instance.parameters.Period
	Show = instance.parameters.Show

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if (nameOnly) then
		return
	end

	MA = core.indicators:create(Method, source.close, Period)

	first = MA.DATA:first()

	if Type == "Arrows" then
		down = instance:createTextOutput("Up", "Up", "Wingdings", 20, core.H_Center, core.V_Top, instance.parameters.Bottom, 0)
		up = instance:createTextOutput("Down", "Down", "Wingdings", 20, core.H_Center, core.V_Bottom, instance.parameters.Top, 0)
	elseif Type == "Color" then
		open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
		high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first())
		low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
		close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first())
		instance:createCandleGroup("Bars", "", open, high, low, close)
	else
		instance:ownerDrawn(true);
	end
end

local up_pen = 1;
local up_brush = 2;
local down_pen = 3;
local down_brush = 4;
local init = false;
local Transparency;
function Draw(stage, context)
    if stage ~= 0 then
        return;
    end
    if not init then
        context:createPen(up_pen, context.SOLID, 1, UP);
        context:createSolidBrush(up_brush, UP);
        context:createPen(down_pen, context.SOLID, 1, DOWN);
		context:createSolidBrush(down_brush, DOWN);
		Transparency = context:convertTransparency(instance.parameters.Transparency);
        init = true;
	end
	
	for p = context:firstBar(), context:lastBar(), 1 do
		local signal = GetSignal(p);
		if signal == 1 then
			local x, x1, x2 = context:positionOfBar(p);
			local _, y1 = context:pointOfPrice(source.high[p]);
			local _, y2 = context:pointOfPrice(source.low[p]);
			context:drawRectangle(up_pen, up_brush, x1, y1, x2, y2, Transparency);
		elseif signal == -1 then
			local x, x1, x2 = context:positionOfBar(p);
			local _, y1 = context:pointOfPrice(source.high[p]);
			local _, y2 = context:pointOfPrice(source.low[p]);
			context:drawRectangle(down_pen, down_brush, x1, y1, x2, y2, Transparency);
		end
    end 
end

function GetSignal(period)
	if period < first + 1 then
		return nil;
	end
	if Same and
			((source.close[period] > source.open[period] and source.close[period - 1] < source.open[period - 1]) or
				(source.close[period] < source.open[period] and source.close[period - 1] > source.open[period - 1]))
	then
		return nil;
	end

	local Filter = nil
	if ma then
		MA:update(mode)
		if source.close[period] > MA.DATA[period] then
			Filter = true
		elseif source.close[period] < MA.DATA[period] then
			Filter = false
		end
	end

	if (B1(period) or B2(period)) and (Filter == nil or Filter == true) and Show ~= "Down" then
		return 1;
	end

	if (S1(period) or S2(period)) and (Filter == nil or Filter == false) and Show ~= "Up" then
		return -1;
	end
	return nil;
end

function Update(period, mode)
	if Type == "Arrows" then
		up:setNoData(period)
		down:setNoData(period)
		local signal = GetSignal(period);
		if signal == 1 then
			up:set(period, source.low[period], "\225")
		elseif signal == -1 then
			down:set(period, source.high[period], "\226")
		end
	elseif Type == "Color" then
		high[period] = source.high[period]
		low[period] = source.low[period]
		close[period] = source.close[period]
		open[period] = source.open[period]

		if source.close[period] > source.open[period] then
			open:setColor(period, UP)
		else
			open:setColor(period, DOWN)
		end
		local signal = GetSignal(period);
		if signal == 1 then
			open:setColor(period, instance.parameters.Top)
		elseif signal == -1 then
			open:setColor(period, instance.parameters.Bottom)
		end
	end
end

function B1(period)
	if not Complet then
		return false
	end

	if source.low[period] <= math.min(source.low[period - 1], source.high[period - 1]) and
			source.close[period] > math.max(source.low[period - 1], source.high[period - 1])
	then
		return true
	end
end

function S1(period)
	if not Complet then
		return false
	end

	if source.high[period] >= math.max(source.low[period - 1], source.high[period - 1]) and
			source.close[period] < math.min(source.low[period - 1], source.high[period - 1])
	then
		return true
	end
end

function B2(period)
	if Complet then
		return false
	end

	if source.open[period] <= math.min(source.open[period - 1], source.close[period - 1]) and
			source.close[period] > math.max(source.open[period - 1], source.close[period - 1])
	then
		return true
	end
end

function S2(period)
	if Complet then
		return false
	end

	if source.open[period] >= math.max(source.open[period - 1], source.close[period - 1]) and
			source.close[period] < math.min(source.open[period - 1], source.close[period - 1])
	then
		return true
	end
end
