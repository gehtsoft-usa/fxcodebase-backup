-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60884
-- Id: 12126

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Consecutive candle range")
	indicator:description("Consecutive candle range")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "Period", 5)
	indicator.parameters:addInteger("Lookback", "Look back period", "Period", 0)

	indicator.parameters:addBoolean("Extend", "Extend", "", false)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Top", "Color of Top Line", "Color of Top Line", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Bottom", "Color of Bottom Line", "Color of Bottom Line", core.rgb(255, 0, 0))

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addInteger("Size", "Font Size", "", 25)
	indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period

local first
local source = nil
local Count
-- Streams block
local Top, Bottom
local Size
local Color
local Cell
local Lookback
local Extend
-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	Top = instance.parameters.Top
	Bottom = instance.parameters.Bottom
	Size = instance.parameters.Size
	Color = instance.parameters.Color
	Lookback = instance.parameters.Lookback
	Extend = instance.parameters.Extend
	source = instance.source
	first = source:first()
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")"
	instance:name(name)
	if nameOnly then
		return
	end
	Count = instance:addInternalStream(0, 0)

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	if period < first then
		return
	end

	Count[period] = Count[period - 1]

	if source.close[period] > source.open[period] then
		if source.close[Count[period - 1]] < source.open[Count[period - 1]] then
			Count[period] = period
		end
	elseif source.close[period] < source.open[period] then
		if source.close[Count[period - 1]] > source.open[Count[period - 1]] then
			Count[period] = period
		end
	end

	core.host:execute("setStatus", tostring(period - Count[period] + 1))
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if not init then
		Cell = context:pixelsToPoints(Size)
		context:createPen(1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, Top)
		context:createPen(2, context:convertPenStyle(instance.parameters.style), instance.parameters.width, Bottom)
		context:createFont(3, "Wingdings", Cell, Cell, 0)

		init = true
	end

	local firstBar, lastBar = context:firstBar(), context:lastBar()

	if Lookback == 0 then
		firstBar = math.max(firstBar, first)
		lastBar = math.min(lastBar, source:size() - 2)
	else
		lastBar = source:size() - 2
		firstBar = math.max(lastBar - Lookback, first)
	end

	x3, x = context:positionOfBar(source:size() - 1)

	for i = firstBar, lastBar, 1 do
		if (i - Count[i] + 1) >= Period and Count[i + 1] == i + 1 then
			if source.close[i] > source.open[i] then
				x1, x = context:positionOfBar(i)
				x2, x = context:positionOfBar(Count[i])

				visible, y1 = context:pointOfPrice(source.high[i])
				visible, y2 = context:pointOfPrice(source.low[Count[i]])
				context:drawText(3, "\234", Color, -1, x1 - Cell / 2, y1 - Cell, x1 + Cell / 2, y1, 0)
				context:drawText(3, "\233", Color, -1, x2 - Cell / 2, y2, x2 + Cell / 2, y2 + Cell, 0)
			else
				x2, x = context:positionOfBar(i)
				x1, x = context:positionOfBar(Count[i])

				visible, y1 = context:pointOfPrice(source.high[Count[i]])
				visible, y2 = context:pointOfPrice(source.low[i])

				context:drawText(3, "\234", Color, -1, x1 - Cell / 2, y1 - Cell, x1 + Cell / 2, y1, 0)
				context:drawText(3, "\233", Color, -1, x2 - Cell / 2, y2, x2 + Cell / 2, y2 + Cell, 0)
			end

			if Extend then
				context:drawLine(1, context:left(), y1, x3, y1)
				context:drawLine(2, context:left(), y2, x3, y2)
			else
				context:drawLine(1, x1, y1, x3, y1)
				context:drawLine(2, x2, y2, x3, y2)
			end
		end
	end
end
