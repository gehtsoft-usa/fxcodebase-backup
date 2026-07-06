-- Id: 21630
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66236
-- Id:

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Two Lines Through Three Points")
	indicator:description("Trend Line Helper")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Claculation")
	indicator.parameters:addInteger("ID", "ID Number", "", 1)
	indicator.parameters:addBoolean("Extend", "Extend", "Extend", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Line Color", "Line Color", core.rgb(0, 0, 255))

	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("ExtendColor", "Extend Line Color", "Line Color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("ExtendWidth", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("ExtendStyle", "Line style", "", core.LINE_DASH)
	indicator.parameters:setFlag("ExtendStyle", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local ID
local Extend
local first
local source = nil
local Color, Slope, Style, Width
local ExtendColor, ExtendSlope, ExtendStyle, ExtendWidth
local db
local pattern = "([^;]*);([^;]*)"

local Level = {}
local Date = {}
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()

	ID = instance.parameters.ID

	local name = ID .. " : " .. profile:id() .. " / " .. source:name()
	instance:name(name)

	if (nameOnly) then
		return
	end

	Date[1] = 0
	Date[2] = 0
	Date[3] = 0

	Color = instance.parameters.Color
	Style = instance.parameters.Style
	Width = instance.parameters.Width
	Slope = instance.parameters.Slope
	Extend = instance.parameters.Extend
	ExtendColor = instance.parameters.ExtendColor
	ExtendStyle = instance.parameters.ExtendStyle
	ExtendWidth = instance.parameters.ExtendWidth
	ExtendSlope = instance.parameters.ExtendSlope

	require("storagedb")
	db = storagedb.get_db(name)

	core.host:execute("addCommand", 1, "1. Point")
	core.host:execute("addCommand", 2, "2. Point")
	core.host:execute("addCommand", 3, "3. Point")
	core.host:execute("addCommand", 4, "Reset")

	instance:ownerDrawn(true)

	core.host:execute("setTimer", 100, 1)
end

function ReleaseInstance()
	core.host:execute("killTimer", 100)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
	if cookie == 1 or cookie == 2 or cookie == 3 then
		_level, _date = string.match(message, pattern, pos)

		db:put(tostring("Level" .. cookie), tostring(_level))
		db:put(tostring("Date" .. cookie), tostring(_date))
	end

	if cookie == 4 then
		for i = 1, 3, 1 do
			db:put(tostring("Level" .. i), tostring(0))
			db:put(tostring("Date" .. i), tostring(0))
		end
	end

	if cookie == 100 then
		Date[1] = db:get(tostring("Date" .. 1), 0)
		Date[2] = db:get(tostring("Date" .. 2), 0)
		Date[3] = db:get(tostring("Date" .. 3), 0)
		Level[1] = db:get(tostring("Level" .. 1), 0)
		Level[2] = db:get(tostring("Level" .. 2), 0)
		Level[3] = db:get(tostring("Level" .. 3), 0)
	end
end

function Draw(stage, context)
	if stage ~= 2 or Date[1] == 0 or Date[2] == 0 then
		return
	end

	context:createPen(1, context:convertPenStyle(Style), Width, Color)
	if Extend then
		context:createPen(2, context:convertPenStyle(ExtendStyle), ExtendWidth, ExtendColor)
	end

	local p1 = core.findDate(source, Date[1], false)
	local p2 = core.findDate(source, Date[2], false)

	if p1 == -1 or p2 == -1 then
		return
	end

	local a, c = math2d.lineEquation(p1, Level[1], p2, Level[2])

	First = math.max(context:firstBar(), p1)
	Last = math.min(source:size() - 1, context:lastBar())

	y1 = a * First + c
	y2 = a * Last + c

	x1, x = context:positionOfBar(First)
	x2, x = context:positionOfBar(Last)
	visible, y1 = context:pointOfPrice(y1)
	visible, y2 = context:pointOfPrice(y2)

	context:drawLine(1, x1, y1, x2, y2)

	if Extend then
		x0, y0 = math2d.lineIntersection(context:left(), context:top(), context:left(), context:bottom(), x1, y1, x2, y2)
		x3, y3 = math2d.lineIntersection(context:right(), context:top(), context:right(), context:bottom(), x1, y1, x2, y2)

		context:drawLine(2, x0, y0, x1, y1)
		context:drawLine(2, x2, y2, x3, y3)
	end

	local p3 = core.findDate(source, Date[3], false)

	if p3 == -1 or Date[3] == 0 then
		return
	end

	local Delta = math.abs(Level[2] - Level[1]) / math.abs(p1 - p2)

	p4 = p3 + 10
	if Level[1] > Level[2] then
		Level[4] = Level[3] + Delta * 10
	else
		Level[4] = Level[3] - Delta * 10
	end

	local a, c = math2d.lineEquation(p3, Level[3], p4, Level[4])

	First = math.max(context:firstBar(), p3)
	Last = math.min(source:size() - 1, context:lastBar())

	y1 = a * First + c
	y2 = a * Last + c

	x1, x = context:positionOfBar(First)
	x2, x = context:positionOfBar(Last)
	visible, y1 = context:pointOfPrice(y1)
	visible, y2 = context:pointOfPrice(y2)

	context:drawLine(1, x1, y1, x2, y2)

	if Extend then
		x0, y0 = math2d.lineIntersection(context:left(), context:top(), context:left(), context:bottom(), x1, y1, x2, y2)
		x3, y3 = math2d.lineIntersection(context:right(), context:top(), context:right(), context:bottom(), x1, y1, x2, y2)

		context:drawLine(2, x0, y0, x1, y1)
		context:drawLine(2, x2, y2, x3, y3)
	end
end
