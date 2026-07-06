-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63222

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
	indicator:name("Measurement Box")
	indicator:description("Measurement Box")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addBoolean("Exclude", "Exclude outside the box candles", "", true)
	indicator.parameters:addInteger("Time", "TimeOut in Seconds", "", 60, 1, 100000)

	indicator.parameters:addGroup("Placement")
	indicator.parameters:addString("Y", " Y Placement", "", "Top")
	indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
	indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

	indicator.parameters:addString("X", " X Placement", "", "Left")
	indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
	indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
	indicator.parameters:addInteger("ShiftY", "Shift", "", 0)

	indicator.parameters:addGroup("Label Style")

	indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("Size", "Font Size", "", 12)

	indicator.parameters:addGroup("Box Style")
	indicator.parameters:addColor("color", "Box  Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
	indicator.parameters:addInteger("transparency", "Box Transparency", "", 70)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local x1, x2, y1, y2
local first
local source = nil
local transparency
local DateOne, LevelOne
local DateTwo, LevelTwo
local LabelColor
local Size
local Time
local Exclude
local ShiftY, X, Y
local Data = {}
local Min, Max
-- Routine
function Prepare(nameOnly)
	LabelColor = instance.parameters.LabelColor
	Time = instance.parameters.Time
	Size = instance.parameters.Size
	Exclude = instance.parameters.Exclude
	Y = instance.parameters.Y
	X = instance.parameters.X
	ShiftY = instance.parameters.ShiftY
	source = instance.source
	first = source:first()

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	local s, e
	s, e = core.getcandle(source:barSize(), 0, 0, 0)
	BAR = e - s

	core.host:execute("addCommand", 1001, "First", "")
	core.host:execute("addCommand", 1002, "Second", "")
	core.host:execute("addCommand", 1003, "Reset", "")

	instance:setLabelColor(core.rgb(0, 0, 0))
	instance:ownerDrawn(true)
	core.host:execute("setTimer", 1000, Time)

	x1 = nil
	x2 = nil
	y2 = nil
	y1 = nil
	Angle = nil
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local pattern = "([^;]*);([^;]*)"

function Parse(message)
	local level, date
	level, date = string.match(message, pattern, 0)

	if level == nil or date == nil then
		return nil, nil
	end

	return tonumber(date), tonumber(level)
end

local init = false

function AsyncOperationFinished(cookie, success, message)
	if cookie == 1001 then
		DateOne, LevelOne = Parse(message)
	elseif cookie == 1002 then
		DateTwo, LevelTwo = Parse(message)
	elseif cookie == 1003 or 1000 then
		LevelOne = nil
		LevelTwo = nil
		x1 = nil
		x2 = nil
		y2 = nil
		y1 = nil
	end
end

function Calculation(period)
	if Exclude and source.low[period] > Max and source.high[period] < Min then
		return
	end

	if Data[1] == nil then
		Data[1] = source.open[period]
	end

	Data[2] = source.close[period]
	Delta = (source.high[period] - source.low[period]) / source:pipSize()

	if source.close[period] > source.open[period] then
		Data[3] = Data[3] + Delta
		Data[6] = math.max(Data[6], Delta)
		Data[9] = Data[9] + 1

		if Data[5] == 0 then
			Data[5] = Delta
		else
			Data[5] = math.min(Data[5], Delta)
		end
	else
		Data[4] = Data[4] + Delta
		Data[8] = math.max(Data[8], Delta)
		Data[10] = Data[10] + 1
		if Data[7] == 0 then
			Data[7] = Delta
		else
			Data[7] = math.min(Data[7], Delta)
		end
	end
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		transparency = context:convertTransparency(instance.parameters.transparency)
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.color
		)
		context:createSolidBrush(2, instance.parameters.color)
		context:createFont(1, "Arial", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
		init = true
	end

	if LevelOne == nil or LevelTwo == nil then
		return
	end

	local p1, p2
	if DateTwo <= source:date(source:size() - 1) then
		p2 = core.findDate(source, DateTwo, true)
	else
		p2 = source:size() - 1 + (DateTwo - source:date(source:size() - 1)) / BAR
	end

	if DateOne <= source:date(source:size() - 1) then
		p1 = core.findDate(source, DateOne, true)
	else
		p1 = source:size() - 1 + (DateOne - source:date(source:size() - 1)) / BAR
	end

	local x, x1 = context:positionOfBar(p1)
	local x, x2 = context:positionOfBar(p2)

	local visible1, y1 = context:pointOfPrice(LevelOne)
	local visible2, y2 = context:pointOfPrice(LevelTwo)

	context:drawRectangle(1, 2, x1, y1, x2, y2, transparency)

	Data[1] = nil
	Data[2] = 0
	Data[3] = 0
	Data[4] = 0

	Data[6] = 0
	Data[8] = 0

	Data[5] = 0
	Data[7] = 0

	Data[9] = 0
	Data[10] = 0

	local Last = source:size() - 1
	p1 = math.min(p1, Last)
	p2 = math.min(p2, Last)

	local Start = math.min(p1, p2)
	local Stop = math.max(p1, p2)

	Min = math.min(LevelOne, LevelTwo)
	Max = math.max(LevelOne, LevelTwo)
	for period = Start, Stop, 1 do
		Calculation(period)
	end

	if Data[9] ~= 0 then
		Data[3] = Data[3] / Data[9]
	end
	if Data[10] ~= 0 then
		Data[4] = Data[4] / Data[10]
	end

	local Label = {
		"Open",
		"Close",
		"AverageLong",
		"AverageShort",
		"MinLong",
		"MaxLong",
		"MinShort",
		"MaxShort",
		"Count Long",
		"Count Short",
		"",
		"Start Date",
		"End Date"
	}
	local Index = {1, 2, 4, 5, 7, 8, 10, 11, 13, 14, 15, 17, 18}

	local delim = "\013\010"
	local ttime1 = core.dateToTable(core.host:execute("convertTime", 1, 4, math.min(DateOne, DateTwo)))
	local ttime2 = core.dateToTable(core.host:execute("convertTime", 1, 4, math.max(DateOne, DateTwo)))
	Data[12] = string.format("%02i/%02i %02i:%02i", ttime1.month, ttime1.day, ttime1.hour, ttime1.min)
	Data[13] = string.format("%02i/%02i %02i:%02i", ttime2.month, ttime2.day, ttime2.hour, ttime2.min)

	for i = 1, 13, 1 do
		if Data[i] ~= nil then
			if i ~= 12 and i ~= 13 then
				Value = win32.formatNumber(Data[i], false, source:getPrecision())
			elseif i == 12 and i == 13 then
				Value = Data[i]
			end
		end
		if i == 11 then
			Text1 =
				"Long  : " ..
				win32.formatNumber(Data[9] / ((Data[9] + Data[10]) / 100), false, 2) ..
					" %  Short  : " .. win32.formatNumber(Data[10] / ((Data[9] + Data[10]) / 100), false, 2) .. " %"
		else
			Text1 = Label[i] .. " : " .. Value
		end
		width, height = context:measureText(1, Text1, 0)
		context:drawText(
			1,
			Text1,
			LabelColor,
			-1,
			iX(context, width, 0, 1),
			iY(context, height, Index[i], 0),
			iX(context, width, 0, 2),
			iY(context, height, Index[i], 1),
			0
		)
	end
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
