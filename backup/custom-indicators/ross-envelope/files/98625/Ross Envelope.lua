-- Id: 13591

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61813

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Ross Envelope")
	indicator:description("Ross Envelope")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addDouble("L1", "1. Level ", "1. Level", 0.146)
	indicator.parameters:addDouble("L2", "2. Level ", "2. Level", 0.236)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Start_Color", "Color of Start", "Color of Start", core.rgb(0, 255, 0))
	indicator.parameters:addColor("End_Color", "Color of End", "Color of End", core.rgb(255, 0, 0))

	indicator.parameters:addColor("Top_Color", "Color of Top", "Color of Top", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Botom_Color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Central_Color", "Color of Central", "Color of Central", core.rgb(0, 0, 255))

	indicator.parameters:addColor(
		"Sub_Top_Color",
		"Color of Top Sub Level",
		"Color of Top Sub Level",
		core.rgb(128, 128, 128)
	)
	indicator.parameters:addColor(
		"Sub_Botom_Color",
		"Color of Bottom Sub Level",
		"Color of Bottom Sub Level",
		core.rgb(128, 128, 128)
	)

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local db
local L1, L2
-- Streams block
local pattern = "([^;]*);([^;]*)"

-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	L1 = instance.parameters.L1
	L2 = instance.parameters.L2

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	require("storagedb")
	db = storagedb.get_db(name)

	core.host:execute("addCommand", 1, "Start")
	core.host:execute("addCommand", 2, "End")
	core.host:execute("addCommand", 3, "Reset")

	instance:ownerDrawn(true)
end

function AsyncOperationFinished(cookie, success, message)
	Level, Date = string.match(message, pattern, 0)

	if cookie == 1 then
		db:put("Start", tostring(Date))
	elseif cookie == 2 then
		db:put("End", tostring(Date))
	elseif cookie == 3 then
		db:put("Start", tostring(0))
		db:put("End", tostring(0))
	end
end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createPen(1, context.DOT, instance.parameters.width, instance.parameters.Start_Color)
		context:createPen(2, context.DOT, instance.parameters.width, instance.parameters.End_Color)

		context:createPen(11, context.SOLID, instance.parameters.width, instance.parameters.Top_Color)
		context:createPen(19, context.SOLID, instance.parameters.width, instance.parameters.Botom_Color)
		context:createPen(16, context.SOLID, instance.parameters.width, instance.parameters.Central_Color)

		context:createPen(12, context.DASH, instance.parameters.width, instance.parameters.Sub_Top_Color)
		context:createPen(18, context.DASH, instance.parameters.width, instance.parameters.Sub_Botom_Color)

		init = true
	end

	local Start = tonumber(db:get("Start", 0))
	local End = tonumber(db:get("End", 0))

	if Start == 0 or End == 0 then
		return
	end

	local X1 = -1
	local X2 = -1

	X1 = core.findDate(source, Start, false)

	if X1 ~= -1 then
		x1, x = context:positionOfBar(X1)
		context:drawLine(1, x1, context:top(), x1, context:bottom())
	end

	X2 = core.findDate(source, End, false)

	if X2 ~= -1 then
		x2, x, x2 = context:positionOfBar(X2)
		context:drawLine(2, x2, context:top(), x2, context:bottom())
	end

	if X1 == -1 or X2 == -1 then
		return
	end

	local min, max = mathex.minmax(source, X1, X2)
	visible, y1 = context:pointOfPrice(max)
	visible, y2 = context:pointOfPrice(min)

	context:drawLine(11, x1, y1, x2, y1)
	context:drawLine(19, x1, y2, x2, y2)

	visible, y3 = context:pointOfPrice(min + (max - min) / 2)
	context:drawLine(16, x1, y3, x2, y3)

	local Delta = (max - min)
	Add(context, 12, x1, x2, max + Delta * L1)
	Add(context, 12, x1, x2, max + Delta * L2)
	Add(context, 12, x1, x2, max + Delta * (-L1))
	Add(context, 12, x1, x2, max + Delta * (-L2))

	Add(context, 18, x1, x2, min + Delta * L1)
	Add(context, 18, x1, x2, min + Delta * L2)
	Add(context, 18, x1, x2, min + Delta * (-L1))
	Add(context, 18, x1, x2, min + Delta * (-L2))
end

function Add(context, Pen, x1, x2, Level)
	visible, y = context:pointOfPrice(Level)
	context:drawLine(12, x1, y, x2, y)
end
