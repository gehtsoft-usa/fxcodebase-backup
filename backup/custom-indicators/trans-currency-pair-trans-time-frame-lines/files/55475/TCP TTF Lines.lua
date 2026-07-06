-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32568
-- Id: 8654

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

function Init()
	indicator:name("Trans Currency Pair, Trans Time Frame Lines")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	local i
	for i = 1, 10, 1 do
		Add(i)
	end
end

function getRainbowColour(ratio)
	-- Using HSV colour system, where Hue is changed in proportion to ratio

	ratio = math.max(0, math.min(1, ratio))

	-- NOTE: hue is an angular value and can be 0..360, but it wraps around back to 'red' again
	-- which looks a bit weird so I limit to 300 degrees
	local hue = 300 * (1 - ratio)

	-- Convert back to RGB
	return convertHSVtoRGB(hue, 1, 1)
end

function convertHSVtoRGB(hue, saturation, value)
	-- http://en.wikipedia.org/wiki/HSL_and_HSV
	-- Hue is an angle (0..360), Saturation and Value are both in the range 0..1

	local hi = (math.floor(hue / 60)) % 6
	local f = hue / 60 - math.floor(hue / 60)

	value = value * 255
	local v = math.floor(value)
	local p = math.floor(value * (1 - saturation))
	local q = math.floor(value * (1 - f * saturation))
	local t = math.floor(value * (1 - (1 - f) * saturation))

	if hi == 0 then
		return core.rgb(v, t, p)
	elseif hi == 1 then
		return core.rgb(q, v, p)
	elseif hi == 2 then
		return core.rgb(p, v, t)
	elseif hi == 3 then
		return core.rgb(p, q, v)
	elseif hi == 4 then
		return core.rgb(t, p, v)
	else
		return core.rgb(v, p, q)
	end
end

function Add(i)
	indicator.parameters:addGroup(i .. ". Line Style")
	indicator.parameters:addColor("Color" .. i, "Line Color", "Line Color", getRainbowColour(i / 10))
	indicator.parameters:addInteger("Width" .. i, "Line width", "", 1, 1, 4)
	indicator.parameters:addInteger("Style" .. i, "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("Style" .. i, core.FLAG_LINE_STYLE)
	indicator.parameters:addBoolean("Extend" .. i, "Extend Line", "", true)
end

local first
local source = nil
local Name

local iColor = {}
local iStyle = {}
local iWidth = {}
local Extend = {}
local Period
local Init = true
local db
local clast = {}
local wlast = {}
local slast = {}

function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	Name = instance.parameters.Name

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	db = LoadParameters("DataBase")

	core.host:execute("addCommand", 101, "Add Horizontal Line", "")
	core.host:execute("addCommand", 102, "Add Vertical Line", "")
	core.host:execute("addCommand", 107, "Add Cursor", "")
	core.host:execute("addCommand", 105, "Add 1. Point of Trend Line", "")
	core.host:execute("addCommand", 106, "Add 2. Point of Trend Line", "")
	core.host:execute("addCommand", 104, "Delete Line", "")
	core.host:execute("addCommand", 103, "Reset", "")
	local i

	for i = 1, 10, 1 do
		db:put(tostring(i .. "Color"), tostring(instance.parameters:getColor("Color" .. i)))

		db:put(tostring(i .. "Style"), tostring(instance.parameters:getColor("Style" .. i)))

		db:put(tostring(i .. "Width"), tostring(instance.parameters:getColor("Width" .. i)))

		Extend[i] = instance.parameters:getBoolean("Extend" .. i)

		core.host:execute("addCommand", 200 + i, "Select Line " .. i .. ". Line", "")
	end

	instance:ownerDrawn(true)
end

function LoadParameters(Name)
	local db
	require("storagedb")
	db = storagedb.get_db(Name)
	db:put(tostring("Selected"), tostring(1))
	return db
end

function Update(period)
end

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	local Color = {}
	local Style = {}
	local Width = {}

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	local i, Date1, Level1, Date2, Level2, Type1, Type2, Instrument1, Instrument2
	for i = 1, 10, 1 do
		Color[i] = tonumber(db:get(tostring(i .. "Color"), 0))
		Style[i] = tonumber(db:get(tostring(i .. "Style"), 0))
		Width[i] = tonumber(db:get(tostring(i .. "Width"), 0))

		Date1 = tonumber(db:get(tostring(i .. "Date1"), 0))
		Level1 = tonumber(db:get(tostring(i .. "Level1"), 0))
		Date2 = tonumber(db:get(tostring(i .. "Date2"), 0))
		Level2 = tonumber(db:get(tostring(i .. "Level2"), 0))
		Type1 = tostring(db:get(tostring(i .. "Type1"), 0))
		Type2 = tostring(db:get(tostring(i .. "Type2"), 0))
		Instrument1 = tostring(db:get(tostring(i .. "Instrument1"), 0))
		Instrument2 = tostring(db:get(tostring(i .. "Instrument2"), 0))

		if Type1 == "H" or Type1 == "V" or Type2 == "H" or Type2 == "V" then
			if Type1 == "H" and Instrument1 == source:name() and Level1 ~= 0 then
				visible, y = context:pointOfPrice(Level1)
				context:createPen(1, context:convertPenStyle(Style[i]), context:pixelsToPoints(Width[i]), Color[i])
				context:drawLine(1, context:right(), y, context:left(), y)
			end

			if Type2 == "H" and Instrument2 == source:name() and Level2 ~= 0 then
				visible, y = context:pointOfPrice(Level2)
				context:createPen(1, context:convertPenStyle(Style[i]), context:pixelsToPoints(Width[i]), Color[i])
				context:drawLine(1, context:right(), y, context:left(), y)
			end

			if Type1 == "V" and Date1 ~= 0 then
				p = core.findDate(source, Date1, false)
				x, x1, x2 = context:positionOfBar(p)
				context:createPen(1, context:convertPenStyle(Style[i]), context:pixelsToPoints(Width[i]), Color[i])
				context:drawLine(1, x, context:top(), x, context:bottom())
			end

			if Type2 == "V" and Date2 ~= 0 then
				p = core.findDate(source, Date2, false)
				x, x1, x2 = context:positionOfBar(p)
				context:createPen(1, context:convertPenStyle(Style[i]), context:pixelsToPoints(Width[i]), Color[i])
				context:drawLine(1, x, context:top(), x, context:bottom())
			end
		elseif
			Level1 ~= 0 and Level2 ~= 0 and Instrument1 == source:name() and Instrument2 == source:name() and Type1 == "T" and
				Type2 == "T"
		 then
			visible, y1 = context:pointOfPrice(Level1)
			visible, y2 = context:pointOfPrice(Level2)

			p1 = core.findDate(source, Date1, false)
			p2 = core.findDate(source, Date2, false)
			local x1, x = context:positionOfBar(p1)
			local x2, x = context:positionOfBar(p2)

			context:createPen(1, context:convertPenStyle(Style[i]), context:pixelsToPoints(Width[i]), Color[i])
			context:drawLine(1, x1, y1, x2, y2)

			if Extend[i] then
				ix1, iy1, ix2, iy2 =
					math2d.lineRectangleIntersection(context:left(), context:top(), context:right(), context:bottom(), x1, y1, x2, y2)
				if ix1 ~= nil and ix2 ~= nil then
					context:createPen(1, context:convertPenStyle(core.LINE_DASH), context:pixelsToPoints(Width[i]), Color[i])
					context:drawLine(1, ix1, iy1, x1, y1)
					context:drawLine(1, ix2, iy2, x2, y2)
				end
			end
		end
	end
end

local pattern = "([^;]*);([^;]*)"

function Parse(message)
	if message == nil then
		return 0, 0
	end
	local level, date
	level, date = string.match(message, pattern, 0)

	if level == nil or date == nil then
		return 0, 0
	end
	return tonumber(date), tonumber(level)
end

function AsyncOperationFinished(cookie, success, message)
	local Selected

	if cookie == 107 then
		local Date, Level
		Date, Level = Parse(message)
		Selected = tonumber(db:get("Selected", 0))
		db:put(tostring(Selected .. "Level1"), tostring(Level))
		db:put(tostring(Selected .. "Date1"), tostring(0))
		db:put(tostring(Selected .. "Type1"), tostring("H"))
		db:put(tostring(Selected .. "Instrument1"), tostring(source:name()))

		db:put(tostring(Selected .. "Level2"), tostring(0))
		db:put(tostring(Selected .. "Date2"), tostring(Date))
		db:put(tostring(Selected .. "Instrument2"), tostring(source:name()))
		db:put(tostring(Selected .. "Type2"), tostring("V"))
	elseif cookie == 101 then
		local Date, Level
		Date, Level = Parse(message)
		Selected = tonumber(db:get("Selected", 0))

		db:put(tostring(Selected .. "Level1"), tostring(Level))
		db:put(tostring(Selected .. "Level2"), tostring(0))
		db:put(tostring(Selected .. "Date1"), tostring(0))
		db:put(tostring(Selected .. "Date2"), tostring(0))
		db:put(tostring(Selected .. "Type1"), tostring("H"))
		db:put(tostring(Selected .. "Type2"), tostring(0))
		db:put(tostring(Selected .. "Instrument1"), tostring(source:name()))
		db:put(tostring(Selected .. "Instrument2"), tostring(0))
	elseif cookie == 102 then
		local Date, Level
		Date, Level = Parse(message)
		Selected = tonumber(db:get("Selected", 0))

		db:put(tostring(Selected .. "Level1"), tostring(0))
		db:put(tostring(Selected .. "Level2"), tostring(0))
		db:put(tostring(Selected .. "Date1"), tostring(Date))
		db:put(tostring(Selected .. "Date2"), tostring(0))
		db:put(tostring(Selected .. "Type1"), tostring("V"))
		db:put(tostring(Selected .. "Type2"), tostring(0))
		db:put(tostring(Selected .. "Instrument1"), tostring(source:name()))
		db:put(tostring(Selected .. "Instrument2"), tostring(0))
	elseif cookie == 103 then
		for i = 1, 10, 1 do
			db:put(tostring(i .. "Level1"), tostring(0))
			db:put(tostring(i .. "Date1"), tostring(0))
			db:put(tostring(i .. "Level2"), tostring(0))
			db:put(tostring(i .. "Date2"), tostring(0))
			db:put(tostring(i .. "Color"), tostring(0))
			db:put(tostring(i .. "Style"), tostring(0))
			db:put(tostring(i .. "Width"), tostring(0))
		end
	elseif cookie == 104 then
		Selected = tonumber(db:get("Selected", 0))
		db:put(tostring(Selected .. "Level1"), tostring(0))
		db:put(tostring(Selected .. "Date1"), tostring(0))
		db:put(tostring(Selected .. "Level2"), tostring(0))
		db:put(tostring(Selected .. "Date2"), tostring(0))

		db:put(tostring(Selected .. "Color"), tostring(0))
		db:put(tostring(Selected .. "Style"), tostring(0))
		db:put(tostring(Selected .. "Width"), tostring(0))
	elseif cookie == 105 then
		local Date, Level
		Date, Level = Parse(message)
		Selected = tonumber(db:get("Selected", 0))

		db:put(tostring(Selected .. "Level1"), tostring(Level))
		db:put(tostring(Selected .. "Date1"), tostring(Date))
		db:put(tostring(Selected .. "Type1"), tostring("T"))
		db:put(tostring(Selected .. "Instrument1"), tostring(source:name()))
	elseif cookie == 106 then
		local Date, Level
		Date, Level = Parse(message)
		Selected = tonumber(db:get("Selected", 0))

		db:put(tostring(Selected .. "Level2"), tostring(Level))
		db:put(tostring(Selected .. "Date2"), tostring(Date))
		db:put(tostring(Selected .. "Type2"), tostring("T"))
		db:put(tostring(Selected .. "Instrument2"), tostring(source:name()))
	elseif cookie > 200 then
		db:put(tostring("Selected"), tonumber(cookie - 200))
	end

	Selected = tonumber(db:get("Selected", 0))
	core.host:execute("setStatus", "Selected :" .. Selected)
end
