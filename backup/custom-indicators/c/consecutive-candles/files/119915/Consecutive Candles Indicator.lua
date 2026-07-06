-- Id: 21675
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66261

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

-- Indicator profile initialization routine

function Init()
	indicator:name("Consecutive Candles")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "", 1)

	indicator.parameters:addString("Method", "Method", "Method", "Pips")
	indicator.parameters:addStringAlternative("Method", "Pips", "Pips", "Pips")
	indicator.parameters:addStringAlternative("Method", "Count", "Count", "Count")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128))
	indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL)

	indicator.parameters:addInteger("Size", "Size", "", 10)
	indicator.parameters:addInteger("width", "Line width", "", 5, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first
local source = nil

local Oscillator
local Count
local Period
local Method
local Size
local Label
-- Routine
function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Period = instance.parameters.Period
	Method = instance.parameters.Method
	Size = instance.parameters.Size
	Label = instance.parameters.Label

	source = instance.source

	first = source:first()

	Count = instance:addInternalStream(0, 0)
	Oscillator = instance:addInternalStream(0, 0)

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period, mode)
	if period < first then
		return
	end

	if source[period] > source[period - 1] and source[period - 1] > source[period - 2] then
		Oscillator[period] = Oscillator[period - 1] + math.abs(source[period] - source[period - 1]) / source:pipSize()
		Count[period] = Count[period - 1] + 1
	elseif source[period] < source[period - 1] and source[period - 1] < source[period - 2] then
		Oscillator[period] = Oscillator[period - 1] - math.abs(source[period] - source[period - 1]) / source:pipSize()
		Count[period] = Count[period - 1] - 1
	elseif source[period] > source[period - 1] and source[period - 1] < source[period - 2] then
		Oscillator[period] = math.abs(source[period] - source[period - 1]) / source:pipSize()
		Count[period] = 1
	elseif source[period] < source[period - 1] and source[period - 1] > source[period - 2] then
		Oscillator[period] = -math.abs(source[period] - source[period - 1]) / source:pipSize()
		Count[period] = -1
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

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
		context:createPen(
			3,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.Neutral
		)
		context:createFont(4, "Arial", Size, Size, 0)
		init = true
	end

	local first = math.max(source:first(), context:firstBar())
	local last = math.min(context:lastBar(), source:size() - 1)

	for i = first, last, 1 do
		if
			((i ~= source:size() - 1) and ((Count[i] > 0 and Count[i + 1] < 0) or (Count[i] < 0 and Count[i + 1] > 0))) or
				(i == source:size() - 1)
		 then
			P = Previous(i)
			x2, x = context:positionOfBar(i)
			x1, x = context:positionOfBar(P)

			visible, y1 = context:pointOfPrice(source[P])
			visible, y2 = context:pointOfPrice(source[i])

			if math.abs(Count[i]) < Period then
				context:drawLine(3, x1, y1, x2, y2)
			elseif Count[i] > 0 then
				context:drawLine(1, x1, y1, x2, y2)
			else
				context:drawLine(2, x1, y1, x2, y2)
			end

			if Method == "Pips" then
				text = win32.formatNumber(Oscillator[i], false, 2)
			else
				text = win32.formatNumber(Count[i], false, 0)
			end

			text_width, text_height = context:measureText(4, text, 0)

			if Count[i] < 0 then
				context:drawText(4, text, Label, -1, x1 - text_width / 2, y2, x1 + text_width / 2, y2 + text_height, 0)
			else
				context:drawText(4, text, Label, -1, x1 - text_width / 2, y2 - text_height, x1 + text_width / 2, y2, 0)
			end
		end
	end
end

function Previous(i)
	local Return = 0

	for x = i, first, -1 do
		Return = x
		if (Count[i] > 0 and Count[x] < 0) or (Count[i] < 0 and Count[x] > 0) then
			break
		end
	end

	return Return
end
