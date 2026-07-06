-- Id: 17486
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64363

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
	indicator:name("Comets")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("b", "Number of Tails", "", 6)
	indicator.parameters:addInteger("Skip", "Skip Period", "", 6, 1, 1000)
	indicator.parameters:addBoolean("Volume", "Use Volume Correction", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "Line color", "Color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("up", "Up color", "Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("down", "Down color", "Color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("transparency", "Transparency", "Transparency", 50)
	indicator.parameters:addInteger("Size", "Size", "Size", 5)
	indicator.parameters:addBoolean("Historical", "Historical", "", true)
	indicator.parameters:addBoolean("Lines", "Show Lines", "", false)
	indicator.parameters:addBoolean("Magnitude", "Magnitude", "", true)
end

local first
local b
local source
local transparency
local Up, Down
local Size
local Line
local Lines
local Historical
local Skip
local Max
local size
local Sum
local Magnitude
function Prepare(onlyName)
	source = instance.source
	Up = instance.parameters.up
	Down = instance.parameters.down
	b = instance.parameters.b
	Size = instance.parameters.Size
	Historical = instance.parameters.Historical
	Lines = instance.parameters.Lines
	Skip = instance.parameters.Skip
	Volume = instance.parameters.Volume
	Magnitude = instance.parameters.Magnitude
	first = source:first() + b + 1

	name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if onlyName then
		return
	end

	Sum = instance:addInternalStream(0, 0)
	Vol = instance:addInternalStream(0, 0)
	Max = instance:addInternalStream(0, 0)
	size = instance:addInternalStream(0, 0)

	instance:ownerDrawn(true)

	Line = instance:addStream("Line", core.Line, name .. ".Line", "Line", core.rgb(255, 0, 0), first)
	Line:setPrecision(math.max(2, instance.source:getPrecision()))
	Line:setStyle(core.LINE_NONE)
end

function Update(period, mode)
	if period < first then
		return
	end

	Sum[period] = 0
	Vol[period] = 0
	for i = 0, b, 1 do
		Vol[period] = Vol[period] + source.volume[period]

		Sum[period] = Sum[period] + (source.close[period] - source.open[period - i])
	end

	if Volume then
		Sum[period] = Sum[period] * Vol[period]
	end

	Max[period] = mathex.max(Sum, period - b + 1, period)

	Line[period] = source.close[period]

	if Magnitude then
		local value = (Sum[period] / (Max[period] / 100))

		if value >= 0 and value <= 10 then
			size[period] = 1
		elseif value > 10 and value <= 20 then
			size[period] = 2
		elseif value > 20 and value <= 30 then
			size[period] = 3
		elseif value > 30 and value <= 40 then
			size[period] = 4
		elseif value > 40 and value <= 50 then
			size[period] = 5
		elseif value > 50 and value <= 60 then
			size[period] = 6
		elseif value > 60 and value <= 70 then
			size[period] = 7
		elseif value > 70 and value <= 80 then
			size[period] = 8
		elseif value > 80 and value <= 90 then
			size[period] = 9
		elseif value > 90 and value <= 100 then
			size[period] = 10
		end
	else
		size[period] = (Sum[period] / (Max[period] / 100))
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
			context:pointsToPixels(instance.parameters.width),
			instance.parameters.color
		)
		transparency = context:convertTransparency(instance.parameters.transparency)
		init = true
	end
	if Historical then
		Start = math.max(context:firstBar(), first, b)
		End = math.min(context:lastBar(), source:size() - 1)
	else
		Start = source:size() - 1
		End = source:size() - 1
	end

	for period = Start, End, 1 do
		if period % Skip == 0 then
			x2, x = context:positionOfBar(period)
			visible, y2 = context:pointOfPrice(source.close[period])

			context:createFont(2, "Wingdings", (Size / 100) * size[period], (Size / 100) * size[period], 0)

			width, height = context:measureText(2, "/108", context.CENTER)
			if Sum[period] > 0 then
				context:drawText(
					2,
					"\108",
					Up,
					-1,
					x2 - width / 2,
					y2 - height / 2,
					x2 + width / 2,
					y2 + height / 2,
					context.CENTER
				)
			else
				context:drawText(
					2,
					"\108",
					Down,
					-1,
					x2 - width / 2,
					y2 - height / 2,
					x2 + width / 2,
					y2 + height / 2,
					context.CENTER
				)
			end

			for i = 0, b, 1 do
				x1, x = context:positionOfBar(period - i)
				visible, y1 = context:pointOfPrice(source.open[period - i])
				if Lines then
					context:drawLine(1, x1, y1, x2, y2, transparency)
				end
			end
		end
	end
end
