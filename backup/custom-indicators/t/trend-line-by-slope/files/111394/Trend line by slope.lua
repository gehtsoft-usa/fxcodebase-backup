-- Id: 17786
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64517

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
	indicator:name("Trend line by slope")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("ID", "ID Number", "", 1)
	indicator.parameters:addBoolean("Extend", "Extend Lines", "", false)
	indicator.parameters:addDouble("Slope", "Slope in pips", "", 10)

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

local Activ = {}
-- Routine
function Prepare(nameOnly)
	Color = instance.parameters.Color
	Style = instance.parameters.Style
	Width = instance.parameters.Width
	Slope = instance.parameters.Slope
	Extend = instance.parameters.Extend
	ExtendColor = instance.parameters.ExtendColor
	ExtendStyle = instance.parameters.ExtendStyle
	ExtendWidth = instance.parameters.ExtendWidth
	ExtendSlope = instance.parameters.ExtendSlope
	ID = instance.parameters.ID

	source = instance.source
	first = source:first()

	local name = ID .. " : " .. profile:id() .. " / " .. source:name()
	instance:name(name)
	if nameOnly then
		return
	end

	require("storagedb")
	db = storagedb.get_db(name)

	core.host:execute("addCommand", 1, "Select Start")

	instance:ownerDrawn(true)
end

function AsyncOperationFinished(cookie, success, message)
	if cookie == 1 then
		Level, Date = string.match(message, pattern, pos)

		db:put("Level", tostring(Level))
		db:put("Date", tostring(Date))
	end
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	context:createPen(1, context:convertPenStyle(Style), Width, Color)
	if Extend then
		context:createPen(2, context:convertPenStyle(ExtendStyle), ExtendWidth, ExtendColor)
	end

	local Date = tonumber(db:get("Date", 0))
	local Level = tonumber(db:get("Level", 0))

	if Date == 0 then
		return
	end

	local p1 = core.findDate(source, Date, false)

	if p1 == -1 then
		return
	end

	local a, c = math2d.lineEquation(p1, Level, p1 + 10, (Level + (Slope * source:pipSize() * 10)))

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
end

function Update(period)
end
