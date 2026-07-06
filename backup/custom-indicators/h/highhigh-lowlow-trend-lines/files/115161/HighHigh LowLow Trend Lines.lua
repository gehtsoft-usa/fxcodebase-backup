-- Id: 19139

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65129

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
	indicator:name("HighHigh LowLow Trend Lines")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "Period", 14)
	indicator.parameters:addInteger("Extend", "Extend", "Extend", 14)

	indicator.parameters:addGroup("Style")

	indicator.parameters:addColor("Up", "Color of Up Trend Line", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Color or Down Trend Line", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period, Extend
local first
local source = nil

-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	Extend = instance.parameters.Extend
	source = instance.source
	first = source:first() + Period

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Extend) .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.Up
		)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.Down
		)
		context:createPen(3, context:convertPenStyle(core.LINE_DASH), instance.parameters.width, instance.parameters.Up)
		context:createPen(4, context:convertPenStyle(core.LINE_DASH), instance.parameters.width, instance.parameters.Down)
		init = true
	end

	local first = math.max((source:first() + Period), context:firstBar())
	local last = math.min(context:lastBar(), (source:size() - 1))

	for period = first, last, 1 do
		for Shift = 1, Period, 1 do
			Check(context, period, math.min(source:size() - 1, period + Shift))
		end
	end
end

function Check(context, period, Shift)
	local X1, x = context:positionOfBar(period)
	local visible, High1 = context:pointOfPrice(source.high[period])
	local visible, Low1 = context:pointOfPrice(source.low[period])

	local X2, x = context:positionOfBar(Shift)
	local visible, High2 = context:pointOfPrice(source.high[Shift])
	local visible, Low2 = context:pointOfPrice(source.low[Shift])

	--local a1, c1 = math2d.lineEquation (X1, High1, X2, High2);
	--local a2, c2 = math2d.lineEquation (X1, Low1, X2, Low2);

	local a1, c1 = math2d.lineEquation(period, source.high[period], Shift, source.high[Shift])
	local a2, c2 = math2d.lineEquation(period, source.low[period], Shift, source.low[Shift])

	local Top_Line
	local Bottom_Line
	local Top = true
	local Bottom = true

	if a1 == nil or a2 == nil then
		return
	end

	if a1 > 0 or a2 < 0 then
		return
	end

	for i = period, math.min(source:size() - 1, Shift), 1 do
		Top_Line = a1 * i + c1
		Bottom_Line = a2 * i + c2

		if source.high[i] > Top_Line then
			Top = false
		end

		if source.low[i] < Bottom_Line then
			Bottom = false
		end
	end

	for i = Shift, math.min(source:size() - 1, Shift + Extend), 1 do
		Top_Line = a1 * i + c1
		Bottom_Line = a2 * i + c2

		if source.high[i] > Top_Line then
			Top = false
		end

		if source.low[i] < Bottom_Line then
			Bottom = false
		end
	end

	local X3, x = context:positionOfBar(math.min(source:size() - 1, Shift + Extend))

	Top_Line = a1 * (math.min(source:size() - 1, Shift + Extend)) + c1
	Bottom_Line = a2 * (math.min(source:size() - 1, Shift + Extend)) + c2

	visible, Top_Line = context:pointOfPrice(Top_Line)
	visible, Bottom_Line = context:pointOfPrice(Bottom_Line)

	if Top then
		context:drawLine(1, X1, High1, X2, High2)
		context:drawLine(3, X2, High2, X3, Top_Line)
	end

	if Bottom then
		context:drawLine(2, X1, Low1, X2, Low2)
		context:drawLine(4, X2, Low2, X3, Bottom_Line)
	end
end
