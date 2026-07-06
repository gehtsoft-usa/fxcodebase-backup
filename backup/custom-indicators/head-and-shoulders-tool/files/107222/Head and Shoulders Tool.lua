-- Id: 16388

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63686

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Head and Shoulders Tool")
	indicator:description("Head and Shoulders Tool")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addInteger("CellSize", "Font Size", "Font Size", 10)
	indicator.parameters:addInteger("Transparency", "Target Transparency", "Target Transparency", 50)
	indicator.parameters:addColor("TargetColor", "Target Color", "Target Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("LabelColor", "Label Color", "Label Color", core.rgb(0, 0, 0))
	indicator.parameters:addColor("LineColor", "Line Color", "Label Color", core.rgb(0, 0, 255))

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local LabelColor, CellColor
-- Streams block
local Date = {}
local Level = {}
local Label = {"1", "Left Tip", "3", "Center Tip", "5", "Right"}
local init = false
local db
local pattern = "([^;]*);([^;]*)"
local LineColor
local TargetColor
local Activ = {}
-- Routine
function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	TargetColor = instance.parameters.TargetColor
	LabelColor = instance.parameters.LabelColor
	LineColor = instance.parameters.LineColor

	source = instance.source
	first = source:first()

	instance:ownerDrawn(true)

	require("storagedb")
	db = storagedb.get_db(name)

	core.host:execute("addCommand", 1, "Add 1")
	core.host:execute("addCommand", 2, "Add 2 (Left Tip)")
	core.host:execute("addCommand", 3, "Add 3")
	core.host:execute("addCommand", 4, "Add 4 (Center Tip)")
	core.host:execute("addCommand", 5, "Add 5")
	core.host:execute("addCommand", 6, "Add 6 (Right Tip)")
	core.host:execute("addCommand", 7, "Reset")
end

function AsyncOperationFinished(cookie, success, message)
	if cookie == 1 or cookie == 2 or cookie == 3 or cookie == 4 or cookie == 5 or cookie == 6 then
		local iLevel, iDate = string.match(message, pattern, 0)

		db:put("Level" .. tostring(cookie), tostring(iLevel))
		db:put("Date" .. tostring(cookie), tostring(iDate))
	end

	if cookie == 7 then
		db:put("Level" .. tostring(1), tostring(-1))
		db:put("Date" .. tostring(1), tostring(-1))

		db:put("Level" .. tostring(2), tostring(-1))
		db:put("Date" .. tostring(2), tostring(-1))

		db:put("Level" .. tostring(3), tostring(-1))
		db:put("Date" .. tostring(3), tostring(-1))

		db:put("Level" .. tostring(4), tostring(-1))
		db:put("Date" .. tostring(4), tostring(-1))

		db:put("Level" .. tostring(5), tostring(-1))
		db:put("Date" .. tostring(5), tostring(-1))

		db:put("Level" .. tostring(6), tostring(-1))
		db:put("Date" .. tostring(6), tostring(-1))
	end
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	-- initialize GDI objects
	if not init then
		CellSize = context:pointsToPixels(instance.parameters.CellSize)

		context:createFont(1, "Arial", CellSize, CellSize, context.NORMAL)

		Transparency = context:convertTransparency(instance.parameters.Transparency)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.style),
			context:pointsToPixels(instance.parameters.width),
			LineColor
		)
		context:createPen(
			3,
			context:convertPenStyle(instance.parameters.style),
			context:pointsToPixels(instance.parameters.width),
			TargetColor
		)
		context:createSolidBrush(4, TargetColor)
		init = true
	end

	for i = 1, 6, 1 do
		Date[i], Level[i] = GetData(i)
		ResolveData(i, context)
	end

	if Date[1] ~= -1 or Date[2] ~= -1 then
		DrawLine(context, 1, 2)
	end

	if Date[2] ~= -1 or Date[3] ~= -1 then
		DrawLine(context, 2, 3)
	end

	if Date[3] ~= -1 or Date[4] ~= -1 then
		DrawLine(context, 3, 4)
	end

	if Date[4] ~= -1 or Date[5] ~= -1 then
		DrawLine(context, 4, 5)
	end

	if Date[5] ~= -1 or Date[6] ~= -1 then
		DrawLine(context, 5, 6)
	end

	if Date[1] == -1 or Date[2] == -1 or Date[3] == -1 or Date[4] == -1 or Date[5] == -1 or Date[6] == -1 then
		return
	end

	local Data3 = core.findDate(source, Date[3], false)
	x1, x = context:positionOfBar(Data3)
	visible, y1 = context:pointOfPrice(Level[3])

	local Data5 = core.findDate(source, Date[5], false)
	x2, x = context:positionOfBar(Data5)
	visible, y2 = context:pointOfPrice(Level[5])

	a, c = math2d.lineEquation(x1, y1, x2, y2)

	if a == nil then
		return
	end

	y3 = a * context:right() + c

	context:drawLine(2, x1, y1, context:right(), y3)

	local points_table = ownerdraw_points.new()
	points_table:add(x1, y1)
	points_table:add(context:right(), y3)

	visible, Y1 = context:pointOfPrice(Level[4])

	local Data4 = core.findDate(source, Date[4], false)
	x4, x = context:positionOfBar(Data4)

	Y2 = a * x4 + c
	Delta = math.abs(Y1 - Y2)
	if Level[3] < Level[4] then
		points_table:add(context:right(), y3 + Delta)
		points_table:add(x1, y1 + Delta)
	else
		points_table:add(context:right(), y3 - Delta)
		points_table:add(x1, y1 - Delta)
	end
	context:drawPolygon(3, 4, points_table, Transparency)
end

function DrawLine(context, index1, index2)
	visible, y1 = context:pointOfPrice(Level[index1])
	visible, y2 = context:pointOfPrice(Level[index2])

	local Data1 = core.findDate(source, Date[index1], false)
	local Data2 = core.findDate(source, Date[index2], false)

	if Data1 ~= -1 and Data2 ~= -1 then
		x1, x = context:positionOfBar(Data1)
		x2, x = context:positionOfBar(Data2)
		context:drawLine(2, x1, y1, x2, y2)
	end
end
function GetData(i)
	local iDate = tonumber(db:get("Date" .. tostring(i), 0))
	local iLevel = tonumber(db:get("Level" .. tostring(i), 0))

	return iDate, iLevel
end

function ResolveData(i, context)
	if Date[i] == -1 then
		return
	end

	local Data = core.findDate(source, Date[i], false)

	if Data ~= -1 then
		width, height = context:measureText(1, Label[i], context.BOTTOM + context.VCENTER)

		visible, y = context:pointOfPrice(Level[i])

		if visible then
			x, x1, x2 = context:positionOfBar(Data)
			context:drawText(
				1,
				Label[i],
				LabelColor,
				-1,
				x - width / 2,
				y - height / 2,
				x + width / 2,
				y + height / 2,
				context.BOTTOM + context.VCENTER
			)
		end
	end

	return Data
end

function Update(period)
end
