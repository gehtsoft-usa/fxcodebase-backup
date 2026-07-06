-- Id: 16449

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63724

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
	indicator:name("Time indicator")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Zone Style")
	--indicator.parameters:addBoolean("Show", "Show Box ", "", true);
	--indicator.parameters:addBoolean("Save", "Save Data ", "", false);

	indicator.parameters:addInteger("transparency", "Transparency", "", 50)
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0))

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Placement")
	indicator.parameters:addString("Y", " Y Placement", "", "Top")
	indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
	indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

	indicator.parameters:addString("X", " X Placement", "", "Left")
	indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
	indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
	indicator.parameters:addInteger("ShiftY", "Shift", "", 0)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("Size", "Font Size", "", 20)
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local transparency
local db
local Date = {}
local Level = {}

local X, Y
local font
local Label
local Size
local ShiftY

local pattern = "([^;]*);([^;]*)"
--local Show;
local Save
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	Y = instance.parameters.Y
	X = instance.parameters.X
	ShiftY = instance.parameters.ShiftY
	Label = instance.parameters.Label
	Size = instance.parameters.Size
	Save = instance.parameters.Save

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	instance:ownerDrawn(true)

	require("storagedb")
	db = storagedb.get_db(name)

	Level[1] = -1
	Date[1] = -1

	Level[2] = -1
	Date[2] = -1

	core.host:execute("addCommand", 1, "Add 1 ")
	core.host:execute("addCommand", 2, "Add 2 ")
	core.host:execute("addCommand", 3, "Reset")
end

function AsyncOperationFinished(cookie, success, message)
	if cookie == 1 or cookie == 2 then
		local iLevel, iDate = string.match(message, pattern, 0)

		db:put("Level" .. tostring(cookie), tostring(iLevel))
		db:put("Date" .. tostring(cookie), tostring(iDate))
	end

	if cookie == 3 then
		db:put("Level" .. tostring(1), tostring(-1))
		db:put("Date" .. tostring(1), tostring(-1))

		db:put("Level" .. tostring(2), tostring(-1))
		db:put("Date" .. tostring(2), tostring(-1))
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period)
end

function GetData(i)
	local iDate = tonumber(db:get("Date" .. tostring(i), 0))
	local iLevel = tonumber(db:get("Level" .. tostring(i), 0))

	return iDate, iLevel
end

local init = false

function ResolveData(i)
	if Date[i] == -1 or Date[i] == nil then
		return -1
	end

	local Data = core.findDate(source, Date[i], false)

	return Data
end

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	Date[1], Level[1] = GetData(1)
	Date[2], Level[2] = GetData(2)

	local Delta = math.abs(Date[2] - Date[1]) * 86400 + 0.5

	for i = 1, 2, 1 do
		Date[i] = ResolveData(i)
	end

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.color1
		)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.color2
		)
		transparency = context:convertTransparency(instance.parameters.transparency)
		context:createFont(3, "Arial", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)

		init = true
	end

	visible, y1 = context:pointOfPrice(Level[1])
	x1, x = context:positionOfBar(Date[1])

	visible, y2 = context:pointOfPrice(Level[2])
	x2, x = context:positionOfBar(Date[2])

	if Date[1] ~= 1 then
		context:drawLine(1, context:left(), y1, context:right(), y1, 0)
		context:drawLine(1, x1, context:top(), x1, context:bottom(), 0)
	end

	if Date[2] ~= 1 then
		context:drawLine(2, context:left(), y2, context:right(), y2, 0)
		context:drawLine(2, x2, context:top(), x2, context:bottom(), 0)
	end

	if Date[1] == -1 or Date[2] == -1 then
		return
	end

	local h, m, s
	s = math.floor(Delta % 60)
	m = math.floor(Delta / 60) % 60
	h = math.floor(Delta / 3600)
	local Text1 = string.format("%i:%02i:%02i\013\010", h, m, s)

	local i = 1
	width, height = context:measureText(3, Text1, 0)
	context:drawText(
		3,
		Text1,
		Label,
		-1,
		iX(context, width, 0, 1),
		iY(context, height, i, 0),
		iX(context, width, 0, 2),
		iY(context, height, i, 1),
		0
	)
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
