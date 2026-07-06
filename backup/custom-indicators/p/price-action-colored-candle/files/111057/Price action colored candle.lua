-- Id: 17656
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64452

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
	indicator:name("Price action colored candle")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.COLOR_UPCANDLE)
	indicator.parameters:addColor("Down", "Down color", "", core.COLOR_DOWNCANDLE)
	indicator.parameters:addColor("Close", "Close color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("Size", "Font Size", "", 20)
	indicator.parameters:addInteger("transparency", "Transparency", "", 80)
	indicator.parameters:addBoolean("Show", "Show Zone", "", true)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up, Down
local first
local source = nil
local Show
local open = nil
local close = nil
local high = nil
local low = nil
local Trend
local Last
local Size
local Close
local transparency
local min, max
function Prepare(nameOnly)
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Size = instance.parameters.Size
	Close = instance.parameters.Close
	Show = instance.parameters.Show

	source = instance.source

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	first = source:first()

	Trend = instance:addInternalStream(0, 0)
	Last = instance:addInternalStream(0, 0)
	min = instance:addInternalStream(0, 0)
	max = instance:addInternalStream(0, 0)

	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period, mode)
	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		open:setColor(period, Neutral)
		return
	end

	if source.close[period] > source.high[period - 1] then
		Trend[period] = 1
	elseif source.close[period] < source.low[period - 1] then
		Trend[period] = -1
	else
		Trend[period] = Trend[period - 1]
	end

	if (Trend[period] == 1 and Trend[period - 1] ~= 1) or (Trend[period] == -1 and Trend[period - 1] ~= -1) then
		Last[period] = period
	else
		Last[period] = Last[period - 1]
	end

	Min, Max = mathex.minmax(source, Last[period], period)

	min[period] = Min
	max[period] = Max

	if Trend[period] == 1 then
		open:setColor(period, Up)
	elseif Trend[period] == -1 then
		open:setColor(period, Down)
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createSolidBrush(10, Up)
		context:createSolidBrush(20, Down)
		context:createFont(1, "Wingdings", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
		transparency = context:convertTransparency(instance.parameters.transparency)
		init = true
	end

	local first = math.max(source:first(), context:firstBar())
	local last = math.min(source:size() - 1, context:lastBar())

	text = "\250"
	width, height = context:measureText(1, text, context.RIGHT)
	for period = first, last, 1 do
		visible, y = context:pointOfPrice(source.close[period])
		x, x1, x2 = context:positionOfBar(period)
		context:drawText(1, text, Close, -1, x2 - width, y - height / 2, x2, y + height / 2, context.RIGHT)

		if Show then
			if Trend[period] ~= Trend[period - 1] then
				x, _, x2 = context:positionOfBar(period - 1)
				x, x1 = context:positionOfBar(Last[period - 1])

				visible, y1 = context:pointOfPrice(min[period - 1])
				visible, y2 = context:pointOfPrice(max[period - 1])

				if Trend[period - 1] == 1 then
					context:drawRectangle(-1, 10, x1, y1, x2, y2, transparency)
				else
					context:drawRectangle(-1, 20, x1, y1, x2, y2, transparency)
				end
			end

			if (period == source:size() - 1) or (period == context:lastBar()) then
				x, _, x2 = context:positionOfBar(period)
				x, x1 = context:positionOfBar(Last[period])

				visible, y1 = context:pointOfPrice(min[period])
				visible, y2 = context:pointOfPrice(max[period])

				if Trend[period] == 1 then
					context:drawRectangle(-1, 10, x1, y1, x2, y2, transparency)
				else
					context:drawRectangle(-1, 20, x1, y1, x2, y2, transparency)
				end
			end
		end
	end
end
