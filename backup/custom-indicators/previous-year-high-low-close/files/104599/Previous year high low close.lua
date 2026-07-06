-- Id: 15379
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63105&start=10

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

-- Defines indicator profile properties and indicator parameters
function Init()
	indicator:name("Previous Days High Low")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("High", "High Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Low", "Low Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Close", "Close Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL)

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
	indicator.parameters:addInteger("fontsize", "Font Size", "", 10)
	indicator.parameters:addInteger("transparency", "Line Transparency", "", 50)

	indicator.parameters:addGroup("Placement")
	indicator.parameters:addBoolean("Show", "Show Label", "", false)
	indicator.parameters:addString("Y", " Y Placement", "", "Top")
	indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
	indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

	indicator.parameters:addString("X", " X Placement", "", "Right")
	indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
	indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
	indicator.parameters:addInteger("ShiftY", "Shift", "", 0)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local source = nil
-- Streams block
local transparency
local Source, loading
local ShiftY, X, Y
local Show
local Label
-- Routine
function Prepare(nameOnly)
	source = instance.source
	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Y = instance.parameters.Y
	X = instance.parameters.X
	ShiftY = instance.parameters.ShiftY
	Show = instance.parameters.Show
	Label = instance.parameters.Label

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	Source = core.host:execute("getSyncHistory", source:instrument(), "M1", source:isBid(), 24, 100, 101)
	loading = true

	transparency = instance.parameters.transparency

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading = false
		instance:updateFrom(0)
	elseif cookie == 101 then
		loading = true
	end

	return core.ASYNC_REDRAW
end

local init = false

function Draw(stage, context)
	if stage ~= 2 or loading then
		return
	end

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			context:pointsToPixels(instance.parameters.width),
			instance.parameters.High
		)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.style),
			context:pointsToPixels(instance.parameters.width),
			instance.parameters.Low
		)
		context:createPen(
			3,
			context:convertPenStyle(instance.parameters.style),
			context:pointsToPixels(instance.parameters.width),
			instance.parameters.Close
		)
		context:createFont(4, "Arial", instance.parameters.fontsize, instance.parameters.fontsize, 0)
		init = true
	end

	local High, Low, Close = Find()

	if Close == -1 then
		return
	end

	visible, y1 = context:pointOfPrice(High)
	visible, y2 = context:pointOfPrice(Low)
	visible, y3 = context:pointOfPrice(Close)

	local date = core.dateToTable(core.now())
	local year = date.year
	local date1 = core.datetime(year - 1, 1, 1, 0, 0, 0)
	local date2 = core.datetime(year, 12, 31, 0, 0, 0)
	-- local date2=source:date(source:size()-1);

	local X1 = core.findDate(source, date1, false)
	local X2 = core.findDate(source, date2, false)

	if X1 == -1 or X2 == -1 then
		return
	end

	x1, x = context:positionOfBar(X1)
	x2, x = context:positionOfBar(X2)

	context:drawLine(1, x1, y1, x2, y1, context:convertTransparency(transparency))
	context:drawLine(2, x1, y2, x2, y2, context:convertTransparency(transparency))
	context:drawLine(3, x1, y3, x2, y3, context:convertTransparency(transparency))

	if Show then
		Text = "High : " .. win32.formatNumber(High, false, source:getPrecision())

		i = 1
		width, height = context:measureText(4, Text, 0)
		context:drawText(
			4,
			Text,
			Label,
			-1,
			iX(context, width, 0, 1),
			iY(context, height, i, 0),
			iX(context, width, 0, 2),
			iY(context, height, i, 1),
			0
		)

		Text = "Low : " .. win32.formatNumber(Low, false, source:getPrecision())

		i = 2
		width, height = context:measureText(4, Text, 0)
		context:drawText(
			4,
			Text,
			Label,
			-1,
			iX(context, width, 0, 1),
			iY(context, height, i, 0),
			iX(context, width, 0, 2),
			iY(context, height, i, 1),
			0
		)

		Text = "Close : " .. win32.formatNumber(Close, false, source:getPrecision())

		i = 3
		width, height = context:measureText(4, Text, 0)
		context:drawText(
			4,
			Text,
			Label,
			-1,
			iX(context, width, 0, 1),
			iY(context, height, i, 0),
			iX(context, width, 0, 2),
			iY(context, height, i, 1),
			0
		)
	end
end

function Find()
	local High = -1
	local Low = -1
	local Close = -1

	local date = core.dateToTable(core.now())
	local year = date.year
	local date1 = core.datetime(year - 1, 1, 1, 0, 0, 0)
	local date2 = core.datetime(year - 1, 12, 31, 0, 0, 0)

	local X1 = core.findDate(Source, date1, false)
	local X2 = core.findDate(Source, date2, false)

	if X1 == -1 or X2 == -1 then
		return -1, -1, -1
	end

	Low, High = mathex.minmax(Source, X1, X2)
	Close = Source.close[X2]

	return High, Low, Close
end

function iX(context, width, Shift, x)
	if X == "Left" then
		return context:left() + Shift * width + width * (x - 1)
	else
		return context:right() - width * Shift - width * (1 - (x - 1))
	end
end

function iY(context, height, Index, Line)
	if Y == "Top" then
		return context:top() + Index * height + ShiftY * height + Line * height
	else
		if Line == 1 then
			return context:bottom() - (Index + 1) * height - ShiftY * height + height
		else
			return context:bottom() - (Index + 1) * height - ShiftY * height
		end
	end
end
