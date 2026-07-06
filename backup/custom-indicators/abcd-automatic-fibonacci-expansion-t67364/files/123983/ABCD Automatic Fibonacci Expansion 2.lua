-- Id: 23971
-- Id: 19698
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67364

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
function Init()
	indicator:name("ABCD Automatic Fibonacci Expansion ")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "Period", 100)

	indicator.parameters:addBoolean("ShowRetr", "Show retracement", "", true)
	indicator.parameters:addString(
		"RetrLevels",
		"Retracement levels",
		"Retracement levels",
		"-0.618, -0.382, -0.272, 0, 0.236, 0.382, 0.5, 0.618, 0.764, 1, 1.272, 1.618"
	)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("Rcolor", "Retracement Color", "", core.rgb(128, 128, 0))
	indicator.parameters:addInteger("Rwidth", "Retracement width", "", 1, 1, 5)
	indicator.parameters:addInteger("Rstyle", "Retracement style", "", core.LINE_DASH)
	indicator.parameters:setFlag("Rstyle", core.FLAG_LINE_STYLE)

	indicator.parameters:addInteger("transparency", "Line Transparency", "", 50)
	indicator.parameters:addInteger("Size", "Text Size", "", 13)

	indicator.parameters:addColor("Label", "Text Color", "", core.COLOR_LABEL)
	indicator.parameters:addBoolean("show_output", "Show output", "", false)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period
local source = nil
local first
-- Streams block
local transparency
local Raw = {}
local Up, Down
local min, max, minpos, maxpos
local Direction
local cPeriod = nil
local cValue = nil
local Size
local Label
local Rlevels, Rcount
local ShowRetr
local pipSize
local show_output;
-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	Size = instance.parameters.Size
	Label = instance.parameters.Label
	ShowRetr = instance.parameters.ShowRetr
	show_output = instance.parameters.show_output;
	source = instance.source

	first = source.close:first()
	local name = profile:id() .. "(" .. source:name() .. "," .. Period .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Rlevels, Rcount = core.parseCsv(instance.parameters.RetrLevels, ",")
	if tonumber(Rlevels[0]) == nil then
		Rcount = 0
	end

	local i
	for i = 0, Rcount - 1, 1 do
		Rlevels[i] = tonumber(Rlevels[i])
	end

	if show_output then
		Up = instance:addStream("UP", core.Dot, "UP", "UP", core.rgb(0, 0, 0), 0, 0)
		Down = instance:addStream("DOWN", core.Dot, "DOWN", "DOWN", core.rgb(0, 0, 0), 0, 0)
	else
		Up = instance:addInternalStream(0, 0)
		Down = instance:addInternalStream(0, 0)
	end

	pipSize = source:pipSize()

	instance:ownerDrawn(true)
end

-- Indicator calculation routine

function Update(period)
	if (period < 6) then
		return
	end
	local curr

	curr = source.high[period - 2]
	if
		(curr > source.high[period - 4] and curr > source.high[period - 3] and curr > source.high[period - 1] and
			curr > source.high[period])
	 then
		Up[period - 2] = 1
	end

	curr = source.low[period - 2]
	if
		(curr < source.low[period - 4] and curr < source.low[period - 3] and curr < source.low[period - 1] and
			curr < source.low[period])
	 then
		Down[period - 2] = 1
	end

	if period < source:size() - 1 or period < Period then
		return
	end

	min, max, minpos, maxpos = mathex.minmax(source, period - Period + 1, period)

	if minpos > maxpos then
		Direction = -1
	else
		Direction = 1
	end

	FindC(period)
end

function FindC(period)
	cPeriod = nil
	cValue = nil

	for index = period, math.max(minpos, maxpos), -1 do
		if Direction == 1 and Down[index] == 1 then
			if cPeriod == nil then
				cPeriod = index
				cValue = source.low[index]
			elseif cValue > source.low[index] then
				cPeriod = index
				cValue = source.low[index]
			end
		elseif Direction == -1 and Up[index] == 1 then
			if cPeriod == nil then
				cPeriod = index
				cValue = source.high[index]
			elseif cValue < source.high[index] then
				cPeriod = index
				cValue = source.high[index]
			end
		end
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
		context:createPen(
			3,
			context:convertPenStyle(instance.parameters.Rstyle),
			context:pointsToPixels(instance.parameters.Rwidth),
			instance.parameters.Rcolor
		)
		transparency = context:convertTransparency(instance.parameters.transparency)
		context:createFont(2, "Arial", Size, Size, 0)
		init = true
	end

	local LastIndex = source:size() - 1

	x2, x = context:positionOfBar(minpos)
	visible, y2 = context:pointOfPrice(min)

	x1, x = context:positionOfBar(maxpos)
	visible, y1 = context:pointOfPrice(max)

	context:drawLine(1, x1, y1, x2, y2, transparency)

	if ShowRetr then
		local i
		local yR, xR, pR
		local right = context:right()
		local Str
		xR = x1
		local w, h
		for i = 0, Rcount - 1, 1 do
			yR = y2 + Rlevels[i] * (y1 - y2)
			pR = min + Rlevels[i] * (max - min)
			pR = math.floor(pR / pipSize + 0.5) * pipSize
			Str = "" .. Rlevels[i] .. "=" .. pR
			w, h = context:measureText(2, Str, 0)
			context:drawLine(3, xR, yR, right, yR, transparency)
			context:drawText(2, Str, Label, -1, xR, yR - h, xR + w, yR, 0)
		end
	end

	if cValue == nil then
		return
	end

	x4, x = context:positionOfBar(cPeriod)
	visible, y4 = context:pointOfPrice(cValue)

	if Direction == 1 then
		context:drawLine(1, math.max(x1, x2), math.min(y1, y2), x4, y4, transparency)
	else
		context:drawLine(1, math.max(x1, x2), math.max(y1, y2), x4, y4, transparency)
	end

	xDelta = math.abs(x1 - x2)

	yDelta = math.abs(y1 - y2)

	if Direction == 1 then
		y5 = y4 - yDelta
	else
		y5 = y4 + yDelta
	end

	visible, yp = context:pointOfPrice(source.close[LastIndex])
	pDelta = math.abs(y5 - yp) / (yDelta / 100)
	pDelta = win32.formatNumber(pDelta, false, 2)

	context:drawLine(1, x4, y4, x4 + xDelta, y5, transparency)

	Price = context:priceOfPoint(y5)
	local text = "Target :" .. win32.formatNumber(Price, false, source:getPrecision()) .. " @ " .. pDelta .. " % "
	width, height = context:measureText(2, text, 0)
	context:drawText(2, text, Label, -1, x4 + xDelta, y5 - height, x4 + xDelta + width, y5, 0)
end
