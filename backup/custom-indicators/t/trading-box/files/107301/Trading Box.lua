-- Id: 16413

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63703

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
	indicator:name("Trading Box")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Zone Style")
	indicator.parameters:addBoolean("Extend", "Extend ", "", true)

	indicator.parameters:addInteger("transparency", "Transparency", "", 50)
	indicator.parameters:addColor("color", "Zone Color", "", core.rgb(0, 255, 0))

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
local transparency
local db
local Date = {}
local Level = {}
local pattern = "([^;]*);([^;]*)"
local Extend

-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	Extend = instance.parameters.Extend

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	instance:ownerDrawn(true)

	require("storagedb")
	db = storagedb.get_db(name)

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
	if Date[i] == -1 then
		return -1
	end

	local Data = core.findDate(source, Date[i], false)

	return Data
end

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	for i = 1, 2, 1 do
		Date[i], Level[i] = GetData(i)

		Date[i] = ResolveData(i)
	end

	if Date[1] == -1 or Date[2] == -1 then
		return
	end

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.color
		)
		transparency = context:convertTransparency(instance.parameters.transparency)
		context:createSolidBrush(2, instance.parameters.color)
		init = true
	end

	visible, y1 = context:pointOfPrice(Level[1])
	visible, y2 = context:pointOfPrice(Level[2])
	if Extend then
		context:drawRectangle(1, 2, context:left(), y1, context:right(), y2, transparency)
	else
		x1, x = context:positionOfBar(Date[1])
		x2, x = context:positionOfBar(Date[2])
		context:drawRectangle(1, 2, x1, y1, x2, y2, transparency)
	end
end
