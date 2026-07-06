-- Id: 13350
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61653

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
	indicator:name("Fractal Based Support/Resistance lines")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addString("Type", " Type", "Type", "High/Low")
	indicator.parameters:addStringAlternative("Type", "High/Low", "High/Low", "High/Low")
	indicator.parameters:addStringAlternative("Type", "Close", "Close", "Close")

	indicator.parameters:addString("Method", " Method", "Method", "Screen")
	indicator.parameters:addStringAlternative("Method", "On Screen Fractal", "On Screen Fractal", "Screen")
	indicator.parameters:addStringAlternative("Method", "All Fractals", "All Fractals", "All")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("R_color", "Color of R", "Color of R", core.rgb(255, 192, 0))
	indicator.parameters:addColor("S_color", "Color of S", "Color of S", core.rgb(0, 192, 255))
	indicator.parameters:addBoolean("Extend", "Extend Line End", "", true)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first
local source = nil
local Extend
local Type
-- Streams block
local up = nil
local down = nil
local Method
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first() + 4
	Method = instance.parameters.Method
	Extend = instance.parameters.Extend
	Type = instance.parameters.Type

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end
	up = instance:addInternalStream(0, 0)
	down = instance:addInternalStream(0, 0)

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period)
	if period < first or not source:hasData(period) then
		up[period] = 0
		down[period] = 0
		return
	end
	-- defect fractals on two periods ago
	local curr

	if Type == "High/Low" then
		curr = source.high[period - 2]
		if
			(curr >= source.high[period - 4] and curr >= source.high[period - 3] and curr >= source.high[period - 1] and
				curr >= source.high[period])
		 then
			up[period - 2] = 1
		end

		curr = source.low[period - 2]
		if
			(curr <= source.low[period - 4] and curr <= source.low[period - 3] and curr <= source.low[period - 1] and
				curr <= source.low[period])
		 then
			down[period - 2] = 1
		end
	else
		curr = source.close[period - 2]
		if
			(curr >= source.close[period - 4] and curr >= source.close[period - 3] and curr >= source.close[period - 1] and
				curr >= source.close[period])
		 then
			up[period - 2] = 1
		end

		curr = source.close[period - 2]
		if
			(curr <= source.close[period - 4] and curr <= source.close[period - 3] and curr <= source.close[period - 1] and
				curr <= source.close[period])
		 then
			down[period - 2] = 1
		end
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	if not init then
		context:createPen(1, context.SOLID, 1, instance.parameters.R_color)
		context:createPen(2, context.SOLID, 1, instance.parameters.S_color)
		init = true
	end
	x2, x = context:positionOfBar(source:size() - 1)

	local Start, Stop
	if Method == "Screen" then
		Start = context:firstBar()
		Stop = context:lastBar()
	else
		Start = source:first()
		Stop = source:size() - 1
	end

	Start = math.max(Start, source:first())
	for period = Start, Stop, 1 do
		if up[period] == 1 then
			if Type == "High/Low" then
				visible, y = context:pointOfPrice(source.high[period])
			else
				visible, y = context:pointOfPrice(source.close[period])
			end
			x1, x = context:positionOfBar(period)
			if Extend then
				context:drawLine(1, x1, y, context:right(), y, 0)
			else
				context:drawLine(1, x1, y, x2, y, 0)
			end
		end

		if down[period] == 1 then
			x1, x = context:positionOfBar(period)
			if Type == "High/Low" then
				visible, y = context:pointOfPrice(source.low[period])
			else
				visible, y = context:pointOfPrice(source.close[period])
			end
			-- context:drawLine (2, x1, y, x2, y, 0);
			if Extend then
				context:drawLine(2, x1, y, context:right(), y, 0)
			else
				context:drawLine(2, x1, y, x2, y, 0)
			end
		end
	end
end
