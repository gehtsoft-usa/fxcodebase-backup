-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60446
-- Id: 11364

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
	indicator:name("Fibonacci Spiral")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("Steps", "Steps", "", 10)
	indicator.parameters:addDouble("Ratio", "Ratio", "", 1.35845627)
	indicator.parameters:addString("Method", "Method", "Method", "Clockwise")
	indicator.parameters:addStringAlternative("Method", "Clockwise", "Clockwise", "Clockwise")
	indicator.parameters:addStringAlternative("Method", "Anticlockwise", "Anticlockwise", "Anticlockwise")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addInteger("Width", "Line Width", "", 1)
	indicator.parameters:addString("Label", "Label", "", "1")
	indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("Size", "Size of Labels", "", 15)
end
local Steps
local Width
local first
local source = nil
local Size
local counter = 0
local LAST
local END
local Label
local LabelColor
local db
local name
local Ratio
local Method
function Prepare(nameOnly)
	Label = instance.parameters.Label
	Method = instance.parameters.Method
	Ratio = instance.parameters.Ratio
	Steps = instance.parameters.Steps
	LabelColor = instance.parameters.LabelColor
	Size = instance.parameters.Size
	Width = instance.parameters.Width
	source = instance.source
	first = source:first()

	name = profile:id() .. "(" .. source:name() .. "," .. Steps .. "," .. Ratio .. "," .. Method .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	require("storagedb")
	db = storagedb.get_db(source:instrument() .. Label)

	core.host:execute("addCommand", 1, "Start", "")
	core.host:execute("addCommand", 2, "Stop", "")
	core.host:execute("addCommand", 3, "Reset")

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	local points = context:pixelsToPoints(Size)

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if not init then
		context:createSolidBrush(2, LabelColor)
		context:createPen(1, context.SOLID, Width, LabelColor)
		init = true
	end

	local L1 = tonumber(db:get("L1", 0))
	local L2 = tonumber(db:get("L2", 0))
	local D1 = tonumber(db:get("D1", 0))
	local D2 = tonumber(db:get("D2", 0))

	if L1 == 0 or D1 == 0 or L1 == nil or D1 == nil or D1 == -1 or L2 == 0 or D2 == 0 or L2 == nil or D2 == nil or D2 == -1 then
		return
	end

	local x1, y1, x2, y2
	x1, y1, x2, y2 = Calculate(context, L1, D1, L2, D2)

	if x1 == nil or y1 == nil then
		return
	end

	Point(context, y1, x1, points)

	if x2 == nil or y2 == nil then
		return
	end
	Point(context, y2, x2, points)

	DrawSpiral(context, x1, y1, x2, y2)
end

function DrawSpiral(context, x1, y1, x2, y2)
	local Radius = (math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2))

	local X1 = x1
	local Y1 = y1
	local Theta
	local Angle
	local iRadius

	for Angle = 1, 360 * Steps, 1 do
		Theta = (Angle / 90)
		iRadius = (Radius * Ratio ^ Theta) - Radius

		if Method == "Clockwise" then
			X2 = x1 + iRadius * math.cos(math.rad(Angle))
			Y2 = y1 + iRadius * math.sin(math.rad(Angle))
		else
			X2 = x1 + iRadius * math.cos(math.rad(-Angle))
			Y2 = y1 + iRadius * math.sin(math.rad(-Angle))
		end

		context:drawLine(1, X1, Y1, X2, Y2)

		X1 = X2
		Y1 = Y2
	end
end

function GetAngle(x1, y1, x2, y2, x3, y3)
	local length = math.abs(x3 - x1)
	local correct = math.abs(y2 - y3) / math.abs(y2 - y1)
	local kF = 1 / math.pow(1.18, length / 13)
	local angle = 90 * (1 - correct) * kF
	if y1 > y3 then
		angle = angle * (-1)
	end
	return angle
end

function Point(context, L, D, points)
	context:drawEllipse(1, -1, D + points, L + points, D - points, L - points, transparency)
end

function Calculate(context, L1, D1, L2, D2)
	local index1, index2, index3
	if D1 > source:date(source:size() - 1) then
		index1 = source:size() - 1
	else
		index1 = core.findDate(source, D1, false)
	end

	if D2 > source:date(source:size() - 1) then
		index2 = source:size() - 1
	else
		index2 = core.findDate(source, D2, false)
	end

	local x1, x = context:positionOfBar(index1)
	local x2, x = context:positionOfBar(index2)

	if D1 > source:date(source:size() - 1) then
		x1 =
			x1 +
			(x1 - context:positionOfBar(source:size() - 2)) *
				((D1 - source:date(source:size() - 1)) / (source:date(source:size() - 1) - source:date(source:size() - 2)))
	end

	if D2 > source:date(source:size() - 1) then
		x2 =
			x2 +
			(x2 - context:positionOfBar(source:size() - 2)) *
				((D2 - source:date(source:size() - 1)) / (source:date(source:size() - 1) - source:date(source:size() - 2)))
	end

	local visible, y1 = context:pointOfPrice(L1)
	local visible, y2 = context:pointOfPrice(L2)

	return x1, y1, x2, y2
end

local pattern = "([^;]*);([^;]*)"
function AsyncOperationFinished(cookie, success, message)
	if cookie ~= 1 and cookie ~= 2 and cookie ~= 3 then
		return
	end
	level, date = string.match(message, pattern, 0)

	if cookie == 1 then
		db:put("L1", tostring(level))
		db:put("D1", tostring(date))
	elseif cookie == 2 then
		db:put("L2", tostring(level))
		db:put("D2", tostring(date))
	elseif cookie == 3 then
		db:put("L1", tostring(0))
		db:put("D1", tostring(0))
		db:put("L2", tostring(0))
		db:put("D2", tostring(0))
	end
end
