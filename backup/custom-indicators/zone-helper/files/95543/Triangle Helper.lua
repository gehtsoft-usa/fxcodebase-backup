-- Id: 12356
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61069

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
	indicator:name("Triangle Helper")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("Size", "Label Size", "", 10)
	indicator.parameters:addDouble("transparency", "Transparency", "", 50)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first
local source = nil
local Color
local db
local name
local init = false
local Size
local Cell
local transparency
--local Extend;
function Prepare(nameOnly)
	Color = instance.parameters.Color

	source = instance.source
	first = source:first()
	Size = instance.parameters.Size

	name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	core.host:execute("addCommand", 1, "Set 1. Triangle Point", "")
	core.host:execute("addCommand", 2, "Set 2. Triangle Point", "")
	core.host:execute("addCommand", 3, "Set 3. Triangle Point", "")

	core.host:execute("addCommand", 5, "Reset")

	require("storagedb")
	db = storagedb.get_db(profile:id() .. "(" .. source:name())

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function Draw(stage, context)
	if stage == 2 then
		return
	end

	local AL = db:get("AL", 0)
	local AD = db:get("AD", 0)

	local BL = db:get("BL", 0)
	local BD = db:get("BD", 0)

	local CL = db:get("CL", 0)
	local CD = db:get("CD", 0)

	if not init then
		transparency = context:convertTransparency(instance.parameters.transparency)
		Cell = context:pointsToPixels(Size)
		context:createPen(1, context.SOLID, context:pointsToPixels(1), Color)
		context:createSolidBrush(2, Color)
		context:createFont(3, "Wingdings", Cell, Cell, 0)
		init = true
	end

	local p1 = core.findDate(source, AD, false)
	local p2 = core.findDate(source, BD, false)

	local p3 = core.findDate(source, CD, false)

	local x1, y1 = Add(context, AL, p1)
	local x2, y2 = Add(context, BL, p2)
	local x3, y3 = Add(context, CL, p3)

	if x1 == nil or x2 == nil or x3 == nil or AD == 0 or BD == 0 or CD == 0 then
		return
	end

	points1 = ownerdraw_points.new()
	points2 = ownerdraw_points.new()
	points1:add(x1, y1)
	points1:add(x2, y2)
	points1:add(x3, y3)

	Zone(context, points1)
end

function Zone(context, points)
	context:drawPolygon(-1, 2, points, transparency)
end

function Add(context, L, D)
	if D == -1 or L == 0 then
		return nil, nil
	end

	x, x1 = context:positionOfBar(D)
	visible, y1 = context:pointOfPrice(L)
	x2 = x1 + Cell / 2
	y2 = y1 + Cell / 2
	context:drawText(3, "\164", Color, -1, x1 - Cell / 2, y1 - Cell / 2, x2, y2, 0)

	return x1, y1
end

local pattern = "([^;]*);([^;]*)"
function AsyncOperationFinished(cookie, success, message)
	local date
	local level

	level, date = string.match(message, pattern, pos)

	if cookie == 1 then
		db:put("AL", tostring(level))
		db:put("AD", tostring(date))
	elseif cookie == 2 then
		db:put("BL", tostring(level))
		db:put("BD", tostring(date))
	elseif cookie == 3 then
		db:put("CL", tostring(level))
		db:put("CD", tostring(date))
	elseif cookie == 5 then
		db:put("AL", tostring(0))
		db:put("AD", tostring(0))
		db:put("BL", tostring(0))
		db:put("BD", tostring(0))
		db:put("CL", tostring(0))
		db:put("CD", tostring(0))
	end
end
