-- Id: 13250

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61593

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
	indicator:name("Stairway")
	indicator:description("Stairway")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Up", "Up Steps", "Up Steps", 3)
	indicator.parameters:addInteger("Down", "Down Steps", "Down Steps", 3)
	indicator.parameters:addInteger("ID", "ID", "ID", 1)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Base_color", "Color of Base", "Color of Base", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("Transparency", "Transparency", "Transparency", 50)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Up
local Down

local first
local source = nil

-- Streams block
local Up = nil
local Down = nil
local Up_color, Down_color
local Transparency
local Base_color
local pattern = "([^;]*);([^;]*)"
local db
local ID
-- Routine
function Prepare(nameOnly)
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Up_color = instance.parameters.Up_color
	Down_color = instance.parameters.Down_color
	Base_color = instance.parameters.Base_color
	ID = instance.parameters.ID
	source = instance.source
	first = source:first()

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	require("storagedb")
	db = storagedb.get_db(name .. ID)

	core.host:execute("addCommand", 1, "X1")
	core.host:execute("addCommand", 2, "X2")
	core.host:execute("addCommand", 3, "Reset")

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
	Level, Date = string.match(message, pattern, pos)

	if cookie == 1 then
		db:put("X1Level", tostring(Level))
		db:put("X1Date", tostring(Date))
	elseif cookie == 2 then
		db:put("X2Level", tostring(Level))
		db:put("X2Date", tostring(Date))
	elseif cookie == 3 then
		db:put("X1Level", 0)
		db:put("X1Date", 0)
		db:put("X2Level", 0)
		db:put("X2Date", 0)
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createPen(1, context.SOLID, 1, Up_color)
		context:createSolidBrush(2, Up_color)
		context:createPen(3, context.SOLID, 1, Down_color)
		context:createSolidBrush(4, Down_color)
		context:createPen(5, context.SOLID, 1, Base_color)
		context:createSolidBrush(6, Base_color)
		Transparency = context:convertTransparency(instance.parameters.Transparency)
	end

	local X1Level = tonumber(db:get("X1Level", 0))
	local X2Level = tonumber(db:get("X2Level", 0))
	local X1Date = tonumber(db:get("X1Date", 0))
	local X2Date = tonumber(db:get("X2Date", 0))

	if X1Level == 0 or X2Level == 0 or X1Date == 0 or X2Date == 0 then
		return
	end

	local X1 = core.findDate(source, X1Date, false)
	local X2 = core.findDate(source, X2Date, false)

	if X1 == -1 or X2 == -1 then
		return
	end

	X1, x = context:positionOfBar(X1)
	X2, x = context:positionOfBar(X2)

	x1 = math.min(X1, X2)
	x2 = math.max(X1, X2)

	visible, Y1 = context:pointOfPrice(X1Level)
	visible, Y2 = context:pointOfPrice(X2Level)

	y1 = math.min(Y1, Y2)
	y2 = math.max(Y1, Y2)

	Add(context, x1, y1, x2, y2, 5, 5, 5, 5, 6)

	for i = 1, Up, 1 do
		Calculate(context, x1, y1, x2, y2, -1 * i)
	end

	for i = 1, Down, 1 do
		Calculate(context, x1, y1, x2, y2, i)
	end
end

function Calculate(context, iX1, iY1, iX2, iY2, i)
	local Flag1 = -1
	local Flag2 = -1
	local Flag3 = -1
	local Flag4 = -1

	xDelta = iX2 - iX1
	yDelta = iY2 - iY1

	ix1 = iX1 + math.abs(i) * xDelta
	ix2 = iX2 + math.abs(i) * xDelta

	iy1 = iY1 + i * yDelta
	iy2 = iY2 + i * yDelta

	if i < 0 then
		Flag5 = 2
	else
		Flag5 = 4
	end

	if i == -1 * Up then
		Flag2 = 1
		Flag3 = 1
	elseif i == Down then
		Flag2 = 3
		Flag4 = 3
	end

	Add(context, ix1, iy1, ix2, iy2, Flag1, Flag2, Flag3, Flag4, Flag5)
end

function Add(context, ix1, iy1, ix2, iy2, Flag1, Flag2, Flag3, Flag4, Flag5)
	context:drawRectangle(-1, Flag5, ix1, iy1, ix2, iy2, Transparency)

	if Flag1 ~= -1 then
		context:drawLine(Flag1, ix1, context:top(), ix1, context:bottom(), 0)
	end

	if Flag2 ~= -1 then
		context:drawLine(Flag2, ix2, context:top(), ix2, context:bottom(), 0)
	end

	if Flag3 ~= -1 then
		context:drawLine(Flag3, context:left(), iy1, context:right(), iy1, 0)
	end

	if Flag4 ~= -1 then
		context:drawLine(Flag4, context:left(), iy2, context:right(), iy2, 0)
	end
end
