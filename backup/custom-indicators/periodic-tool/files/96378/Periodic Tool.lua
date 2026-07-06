-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61301
-- Id: 12671

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
	indicator:name("Time projection line")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addColor("StartColor", "Start Line Color", "Start Line Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("StopColor", "Start Line Color", "Start Line Color", core.rgb(255, 0, 0))

	indicator.parameters:addColor("ProjectionColor", "Projection Line Color", "Projection Line Color", core.rgb(0, 0, 255))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local ProjectionColor, StartColor, StopColor
-- Streams block

local db
local pattern = "([^;]*);([^;]*)"
local BL, DL, HL, ML

-- Routine
function Prepare(nameOnly)
	StartColor = instance.parameters.StartColor
	StopColor = instance.parameters.StopColor
	ProjectionColor = instance.parameters.ProjectionColor

	source = instance.source
	first = source:first()

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end
	instance:ownerDrawn(true)

	require("storagedb")
	db = storagedb.get_db(source:name())

	core.host:execute("addCommand", 1, "Select Start")
	core.host:execute("addCommand", 2, "Select Stop")
	core.host:execute("addCommand", 3, "Reset")

	core.host:execute("addCommand", 4, "Horizontal")
	core.host:execute("addCommand", 5, "Vertical")
	core.host:execute("addCommand", 6, "Grid")

	-- db:put("Type","Grid");
end

function AsyncOperationFinished(cookie, success, message)
	if cookie == 1 or cookie == 2 then
		local Level, Date = string.match(message, pattern, 0)

		if cookie == 1 then
			db:put("StartX", Date)
			db:put("StartY", Level)
		elseif cookie == 2 then
			db:put("StopX", Date)
			db:put("StopY", Level)
		end

		Type = tostring(db:get("Type", -1))

		if Type == -1 then
			db:put("Type", "Grid")
		end
	end

	if cookie == 4 then
		db:put("Type", "Horizontal")
	elseif cookie == 5 then
		db:put("Type", "Vertical")
	elseif cookie == 6 then
		db:put("Type", "Grid")
	end

	if cookie == 3 then
		db:put("StartX", -1)
		db:put("StopX", -1)
		db:put("StartY", -1)
		db:put("StopY", -1)
		db:put("Type", "Grid")
	end
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	-- initialize GDI objects
	if not init then
		context:createPen(1, context.SOLID, 1, StartColor)
		context:createSolidBrush(2, StartColor)

		context:createPen(3, context.SOLID, 1, StopColor)
		context:createSolidBrush(4, StopColor)

		context:createPen(5, context.SOLID, 1, ProjectionColor)
		context:createSolidBrush(6, ProjectionColor)

		init = true
	end

	local StartX = tonumber(db:get("StartX", -1))
	local StopX = tonumber(db:get("StopX", -1))
	local Type = tostring(db:get("Type", -1))
	local Index = {}

	if (Type == "Vertical" or Type == "Grid") and (StartX ~= -1 or StopX ~= -1) then
		if StartX ~= -1 then
			Index[1] = core.findDate(source, StartX, false)
		end

		if StopX ~= -1 then
			Index[2] = core.findDate(source, StopX, false)
		end

		if Index[1] ~= nil and Index[1] ~= -1 then
			x1, x = context:positionOfBar(Index[1])
			context:drawLine(1, x1, context:top(), x1, context:bottom(), 0)
		end

		if Index[2] ~= nil and Index[2] ~= -1 then
			x2, x = context:positionOfBar(Index[2])
			context:drawLine(3, x2, context:top(), x2, context:bottom(), 0)
		end

		if not (StartX == -1 or StopX == -1 or Index[1] == -1 or Index[2] == -1) then
			Length = math.abs(x2 - x1)

			for x3 = math.max(x1, x2) + Length, context:right(), Length do
				context:drawLine(5, x3, context:top(), x3, context:bottom(), 0)
			end

			for x3 = math.min(x1, x2) - Length, context:left(), -Length do
				context:drawLine(5, x3, context:top(), x3, context:bottom(), 0)
			end
		end
	end

	local StartY = tonumber(db:get("StartY", -1))
	local StopY = tonumber(db:get("StopY", -1))

	if (Type == "Horizontal" or Type == "Grid") then
		if StartY ~= -1 then
			visible, y1 = context:pointOfPrice(StartY)
			context:drawLine(1, context:left(), y1, context:right(), y1, 0)
		end

		if StopY ~= -1 then
			visible, y2 = context:pointOfPrice(StopY)
			context:drawLine(3, context:left(), y2, context:right(), y2, 0)
		end

		if StartY ~= -1 and StopY ~= -1 then
			Length = math.abs(y2 - y1)

			for y3 = math.max(y1, y2) - Length, context:top(), -Length do
				if y3 ~= y2 and y3 ~= y1 then
					context:drawLine(5, context:left(), y3, context:right(), y3, 0)
				end
			end

			for y3 = math.min(y1, y2) + Length, context:bottom(), Length do
				if y3 ~= y2 and y3 ~= y1 then
					context:drawLine(5, context:left(), y3, context:right(), y3, 0)
				end
			end
		end
	end
end

function Update(period)
end
