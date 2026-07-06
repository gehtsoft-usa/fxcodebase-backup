-- Id: 13420
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
-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=61708

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Curved trend line")
	indicator:description("Curved trend line")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("Type", "Line Type", "", "Polyline")
	indicator.parameters:addStringAlternative("Type", "Polyline", "", "Polyline")
	indicator.parameters:addStringAlternative("Type", "BezierLine", "", "BezierLine")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0))
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
local color
local pattern = "([^;]*);([^;]*)"
local Level = {}
local Date = {}
local db
local Type
-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()

	color = instance.parameters.color
	Type = instance.parameters.Type

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	require("storagedb")
	db = storagedb.get_db(name)

	core.host:execute("addCommand", 1, "1. Point")
	core.host:execute("addCommand", 2, "2. Point")
	core.host:execute("addCommand", 3, "3. Point")
	core.host:execute("addCommand", 4, "4. Point")
	core.host:execute("addCommand", 5, "Reset")

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
	local iLevel, iDate = string.match(message, pattern, 0)

	if cookie == 1 then
		db:put("Level1", iLevel)
		db:put("Date1", iDate)
	elseif cookie == 2 then
		db:put("Level2", iLevel)
		db:put("Date2", iDate)
	elseif cookie == 3 then
		db:put("Level3", iLevel)
		db:put("Date3", iDate)
	elseif cookie == 4 then
		db:put("Level4", iLevel)
		db:put("Date4", iDate)
	elseif cookie == 5 then
		db:put("Level1", 0)
		db:put("Date1", 0)
		db:put("Level2", 0)
		db:put("Date2", 0)
		db:put("Level3", 0)
		db:put("Date3", 0)
		db:put("Level4", 0)
		db:put("Date4", 0)
	end
end

local init
function Draw(stage, context)
	if stage == 2 then
		return
	end

	local First = math.max(first, context:firstBar())
	local Last = math.min(source:size() - 1, context:lastBar())

	Level[1] = tonumber(db:get("Level1", 0))
	Level[2] = tonumber(db:get("Level2", 0))
	Level[3] = tonumber(db:get("Level3", 0))
	Level[4] = tonumber(db:get("Level4", 0))

	Date[1] = tonumber(db:get("Date1", 0))
	Date[2] = tonumber(db:get("Date2", 0))
	Date[3] = tonumber(db:get("Date3", 0))
	Date[4] = tonumber(db:get("Date4", 0))

	points = ownerdraw_points.new()

	if Date[1] ~= 0 and Date[1] >= source:date(First) and Date[1] <= source:date(Last) then
		p = core.host:execute("calculatePositionOfDate", source, Date[1]) --core.findDate (source, Date[1], false)
		if p ~= -1 and p >= First and p <= Last then
			x, x1 = context:positionOfBar(p)
		end

		visible, y = context:pointOfPrice(Level[1])

		points:add(x, y)
	end

	if Date[2] ~= 0 and Date[2] >= source:date(First) and Date[2] <= source:date(Last) then
		p = core.host:execute("calculatePositionOfDate", source, Date[2]) --core.findDate (source, Date[2], false)
		if p ~= -1 and p >= First and p <= Last then
			x, x1 = context:positionOfBar(p)
		end
		visible, y = context:pointOfPrice(Level[2])

		points:add(x, y)
	end

	if Date[3] ~= 0 and Date[3] >= source:date(First) and Date[3] <= source:date(Last) then
		p = core.host:execute("calculatePositionOfDate", source, Date[3]) --core.findDate (source, Date[3], false)
		if p ~= -1 and p >= First and p <= Last then
			x, x1 = context:positionOfBar(p)
		end

		visible, y = context:pointOfPrice(Level[3])

		points:add(x, y)
	end

	if Date[4] ~= 0 and Date[4] >= source:date(First) and Date[4] <= source:date(Last) then
		p = core.host:execute("calculatePositionOfDate", source, Date[4]) --  core.findDate (source, Date[4], false)
		if p ~= -1 and p >= First and p <= Last then
			x, x1 = context:positionOfBar(p)
		end

		visible, y = context:pointOfPrice(Level[4])

		points:add(x, y)
	end

	if not init then
		context:createPen(1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, color)
		init = true
	end

	if Type == "Polyline" then
		context:drawPolyline(1, points, 0)
	elseif Type == "BezierLine" then
		context:drawBezierLine(1, points, 0)
	end
end
