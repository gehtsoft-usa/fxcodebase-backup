-- Id: 18101
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64641

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
	indicator:name("Richard Donchian Rule")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "Period", 4)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Top", "Top Line Color", "Line Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Bottom", "Bottom Color", "Line Color", core.rgb(255, 0, 0))

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Period

local MinValue, MaxValue
-- Streams block

-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period

	source = instance.source
	first = source:first()

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	MaxValue = instance:addStream("MaxValue", core.Line, name .. ".MaxValue", "MaxValue", instance.parameters.Top, first)
	MaxValue:setVisible(false)
	MinValue = instance:addStream("MinValue", core.Line, name .. ".MinValue", "MinValue", instance.parameters.Top, first)
	MinValue:setVisible(false)

	instance:ownerDrawn(true)
end

function SetOutput(Stream, firstBar, lastBar, Value)
	local i
	for i = firstBar, lastBar, 1 do
		Stream[i] = Value
	end
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	-- initialize GDI objects
	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.Top
		)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.Bottom
		)

		init = true
	end

	local First = math.max(source:first() + Period, context:firstBar())
	local Last = math.min(source:size() - 1, context:lastBar() + Period)

	for period = First, Last, 1 do
		min, max = mathex.minmax(source, period - 1 - Period + 1, period - 1)

		if source.high[period] > max then
			visible, y = context:pointOfPrice(source.high[period])
			x, x1 = context:positionOfBar(period - 1 - Period + 1)
			x, _, x2 = context:positionOfBar(period)
			context:drawLine(1, x1, y, x2, y)
			SetOutput(MaxValue, period - Period, period, source.high[period])
		end

		if source.low[period] < min then
			visible, y = context:pointOfPrice(source.low[period])
			x, x1 = context:positionOfBar(period - 1 - Period + 1)
			x, _, x2 = context:positionOfBar(period)
			context:drawLine(2, x1, y, x2, y)
			SetOutput(MinValue, period - Period, period, source.low[period])
		end
	end
end

function Update(period)
end
