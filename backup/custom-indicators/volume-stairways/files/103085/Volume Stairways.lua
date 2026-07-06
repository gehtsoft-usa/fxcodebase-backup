-- Id: 15004

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62838

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
	indicator:type(core.Oscillator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("ID", "ID", "ID", 1)
	indicator.parameters:addDouble("BaseUnit", "Base Unit", "Base Unit", 10, 1, 100)

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
local Base
local xBase
local BaseUnit
-- Routine
function Prepare(nameOnly)
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Up_color = instance.parameters.Up_color
	Down_color = instance.parameters.Down_color
	Base_color = instance.parameters.Base_color
	BaseUnit = instance.parameters.BaseUnit
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
		db:put("X1Date", tostring(Date))
	elseif cookie == 2 then
		db:put("X2Date", tostring(Date))
	elseif cookie == 3 then
		db:put("X1Date", 0)
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

	local X1Date = tonumber(db:get("X1Date", 0))
	local X2Date = tonumber(db:get("X2Date", 0))

	if X1Date == 0 or X2Date == 0 then
		return
	end

	X1Date = math.min(X1Date, X2Date)
	X2Date = math.max(X1Date, X2Date)

	Base = nil

	Calculate(context, X1Date, X2Date)
end

function Calculate(context, iX1, iX2)
	xDate = iX2 - iX1

	local date1 = iX1
	local date2 = iX2
	local Volume = 0

	while date1 < source:date(source:size() - 1) do
		Volume = Add(context, date1, date2, Volume)

		date1 = date1 + xDate
		date2 = date1 + xDate
	end
end

function Add(context, date1, date2, iVolume)
	local X1 = core.findDate(source, date1, false)
	local X2 = core.findDate(source, date2, false)

	if X1 == -1 or X2 == -1 then
		return iVolume
	end

	local xVolume = mathex.sum(source.volume, X1, X2)

	if source.close[X2] < source.close[X1] then
		xVolume = -1 * xVolume
	end

	if Base == nil then
		Base = math.abs(xVolume)

		Y1 = context:top() + (context:bottom() - context:top()) / 2
		if xVolume > 0 then
			Y2 = Y1 - (context:bottom() - context:top()) / (100 / BaseUnit)
		else
			Y2 = Y1 + (context:bottom() - context:top()) / (100 / BaseUnit)
		end
		xBase = math.abs(Y2 - Y1)
	end

	iVolume = iVolume + xVolume

	X1, x = context:positionOfBar(X1)
	X2, x = context:positionOfBar(X2)

	if xVolume > 0 then
		Y2 = Y1
		Y1 = Y2 - (xVolume / Base) * xBase
		context:drawRectangle(5, 2, X1, Y1, X2, Y2, Transparency)
	elseif xVolume < 0 then
		Y2 = Y1
		Y1 = Y2 - (xVolume / Base) * xBase
		context:drawRectangle(5, 4, X1, Y1, X2, Y2, Transparency)
	else
		context:drawRectangle(5, 6, X1, Y1, X2, Y2, Transparency)
		Y1 = Y1
		Y2 = Y2
	end

	return iVolume
end
