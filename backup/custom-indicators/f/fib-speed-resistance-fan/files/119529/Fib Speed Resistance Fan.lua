-- Id: 21527

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66184

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
	indicator:name("Fib Speed Resistance Fan")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addString("Label", "Unique ID", "", "1")

	local i
	for i = 1, 20, 1 do
		if i == 1 then
			Add(i, 0, Coloring(i, 10))
		elseif i == 20 then
			Add(i, 1, Coloring(i, 10))
		else
			Add(i, 0 + (1 / 20) * i, Coloring(i, 10))
		end
	end

	indicator.parameters:addGroup("Style")
	indicator.parameters:addBoolean("Extend", "Extend Lines", "", false)
	indicator.parameters:addBoolean("Background", "Show Background", "", true)
	indicator.parameters:addBoolean("Vertical", "Show Vertical Lines", "", true)
	indicator.parameters:addBoolean("Horizontal", "Show Horizontal Lines", "", true)
	indicator.parameters:addBoolean("Value", "Show Line Value", "", true)
	indicator.parameters:addBoolean("Centre", "Centre the Line", "", false)
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100)
	indicator.parameters:addInteger("Size", "Size of Labels", "", 12)
	indicator.parameters:addInteger("Width", "Line Width", "", 1)

	indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0))
end

local Count = 20
local Num = 0
local xArray = {}
local xSortedArray
local yArray = {}
local ySortedArray
local On = {}
local Extend
local Width
local Value
local Background
function Add(id, Level, Color)
	indicator.parameters:addGroup(id .. ". Zone")
	if id ~= 20 then
		indicator.parameters:addBoolean("On" .. id, "Use This Level", "", true)
	end
	indicator.parameters:addDouble("XLevel" .. id, "X Axis Level", "", Level)
	if id ~= 20 then
		indicator.parameters:addColor("XRainbow" .. id, "X Color", "", Color)
	end
	indicator.parameters:addDouble("YLevel" .. id, "Y Axis Level", "", Level)
	if id ~= 20 then
		indicator.parameters:addColor("YRainbow" .. id, "Y Color", "", Color)
	end
end

function Coloring(value, mid)
	local color

	if value <= mid then
		color = core.rgb(255 * (value / mid), 255, 0)
	else
		color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
	end

	return color
end

local Centre
local first
local source = nil
local Size
local counter = 0
local LAST
local END
local Label

--local font;
local LabelColor

local xx
local yy
local db
local name
local Vertical, Horizontal
local ID = 0
--[[
function ReleaseInstance()
       core.host:execute("deleteFont", font);
end]]
function Sort(old, index, raw, columns)
	local new = old
	local i, j, k, temp

	local ItIs = true

	while ItIs do
		ItIs = false

		for j = 2, columns, 1 do
			if new[index][j] > new[index][j - 1] then
				ItIs = true
				for k = 1, raw, 1 do
					temp = new[k][j - 1]
					new[k][j - 1] = new[k][j]
					new[k][j] = temp
				end
			end
		end
	end

	return new
end

function Prepare(nameOnly)
	Label = instance.parameters.Label
	Value = instance.parameters.Value
	LabelColor = instance.parameters.LabelColor
	Extend = instance.parameters.Extend
	Vertical = instance.parameters.Vertical
	Horizontal = instance.parameters.Horizontal
	Centre = instance.parameters.Centre
	Width = instance.parameters.Width
	Background = instance.parameters.Background

	Size = instance.parameters.Size
	source = instance.source
	first = source:first()

	name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	transparency = instance.parameters.transparency
	if transparency == 100 then
		transparency = 255
	elseif transparency == 0 then
		transparency = 0
	else
		transparency = math.floor(255 * (transparency / 100.0) + 0.5)
	end

	xArray[1] = {}
	xArray[2] = {}
	yArray[1] = {}
	yArray[2] = {}

	local i
	Num = 0
	for i = 1, Count, 1 do
		if i ~= Count and instance.parameters:getBoolean("On" .. i) then
			On[Num + 1] = instance.parameters:getBoolean("On" .. i)
			if On[Num + 1] then
				Num = Num + 1
				xArray[1][Num] = instance.parameters:getDouble("XLevel" .. i)
				yArray[1][Num] = instance.parameters:getDouble("YLevel" .. i)

				yArray[2][Num] = instance.parameters:getDouble("YRainbow" .. i)
				xArray[2][Num] = instance.parameters:getDouble("XRainbow" .. i)
			end
		elseif i == Count then
			Num = Num + 1
			xArray[1][Num] = instance.parameters:getDouble("XLevel" .. i)
			yArray[1][Num] = instance.parameters:getDouble("YLevel" .. i)
			yArray[2][Num] = 0
			xArray[2][Num] = 0
		end
	end

	xSortedArray = Sort(xArray, 1, 2, Num)
	ySortedArray = Sort(yArray, 1, 2, Num)

	require("storagedb")
	db = storagedb.get_db(source:instrument() .. Label)

	core.host:execute("addCommand", 1, Label .. " Start", "")
	core.host:execute("addCommand", 2, Label .. ". Fan Stop", "")
	core.host:execute("addCommand", 3, Label .. ". Fan Reset")

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	local points = context:pixelsToPoints(Size)

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if not init then
		context:createSolidBrush(2, LabelColor)
		context:createPen(1, context.SOLID, Width, LabelColor)
		context:createFont(3, "Arial", points, points, context.ITALIC)

		init = true
	end

	local L1 = tonumber(db:get("L1", 0))
	local L2 = tonumber(db:get("L2", 0))
	local D1 = tonumber(db:get("D1", 0))
	local D2 = tonumber(db:get("D2", 0))

	if L1 == 0 or D1 == 0 or L1 == nil or D1 == nil or D1 == -1 or L2 == 0 or D2 == 0 or L2 == nil or D2 == nil or D2 == -1 then
		return
	end

	local x1, y1, x2, y2, x3, y3
	x1, y1, x2, y2, x3, y3 = Calculate(context, L1, D1, L2, D2, L1, D2)

	if x1 == nil or y1 == nil or y2 == nil or x2 == nil or y3 == nil or x3 == nil then
		return
	end

	local i, xNow, xPrev, yNow, yPrev

	for i = 2, Num, 1 do
		xNow = xSortedArray[1][i]
		xPrev = xSortedArray[1][i - 1]

		yNow = ySortedArray[1][i]
		yPrev = ySortedArray[1][i - 1]

		Triangle(context, x1, y1, x2, y1 + ((y2 - y1) * yNow), x2, y1 + ((y2 - y1) * yPrev), points, ySortedArray[2][i])
		Triangle(
			context,
			x1,
			y1,
			x1 + ((x2 - x1) * xPrev) + 1,
			y2,
			x1 + ((x2 - x1) * xNow) + 1,
			y2,
			points,
			xSortedArray[2][i]
		)
	end

	Point(context, y1, x1, points)
	Point(context, y2, x2, points)

	for i = 1, Num, 1 do
		xNow = xSortedArray[1][i]
		yNow = ySortedArray[1][i]

		if Extend then
			if Horizontal then
				Line(context, context:left(), y1 + ((y2 - y1) * yNow), context:right(), y1 + ((y2 - y1) * yNow), yNow, 1)
			end

			if Vertical then
				Line(context, x1 + ((x2 - x1) * xNow), context:top(), x1 + ((x2 - x1) * xNow), context:bottom(), xNow, 2)
			end
		else
			if Horizontal then
				Line(context, x1, y1 + ((y2 - y1) * yNow), x2, y1 + ((y2 - y1) * yNow), yNow, 1)
			end
			if Vertical then
				Line(context, x1 + ((x2 - x1) * xNow), y1, x1 + ((x2 - x1) * xNow), y2, xNow, 2)
			end
		end
	end
end

function Line(context, x1, y1, x2, y2, X)
	if x1 == nil or x2 == nil or y1 == nil or y2 == nil then
		return
	end

	if Centre then
		x1 = context:indexOfBar(x1)
		x2 = context:indexOfBar(x2)

		x1, x = context:positionOfBar(x1)
		x2, x = context:positionOfBar(x2)
	end

	context:drawLine(1, x1, y1, x2, y2)

	local Text = string.format("%." .. 0 .. "f", X * 100)
	local width, height = context:measureText(3, Text, context.LEFT)

	if Value then
		if Extend then
			context:drawText(3, Text, LabelColor, -1, x1, y1, x1 + width, y1 + height, context.LEFT)
			context:drawText(3, Text, LabelColor, -1, x1, y1, x1 + width, y1 - height, context.LEFT)
			context:drawText(3, Text, LabelColor, -1, x2 - width, y2 + height, x2, y2, context.LEFT)
			context:drawText(3, Text, LabelColor, -1, x2 - width, y2 - height, x2, y2, context.LEFT)
		else
			context:drawText(3, Text, LabelColor, -1, x1, y1 - height, x1 + width, y1, context.LEFT)
			context:drawText(3, Text, LabelColor, -1, x2, y2, x2 + width, y2 + height, context.LEFT)
		end
	end
end

function Calculate(context, L1, D1, L2, D2, L3, D3)
	local index1, index2, index3
	if D1 > source:date(source:size() - 1) then
		index1 = source:size() - 1
	else
		index1 = core.findDate(source, D1, false)
	end

	if D2 > source:date(source:size() - 1) then
		index2 = source:size() - 1
	else
		index2 = core.findDate(source, D2, false)
	end

	if D3 > source:date(source:size() - 1) then
		index3 = source:size() - 1
	else
		index3 = core.findDate(source, D3, false)
	end

	local x1, x = context:positionOfBar(index1)
	local x2, x = context:positionOfBar(index2)
	local x3, x = context:positionOfBar(index3)

	if D1 > source:date(source:size() - 1) then
		x1 =
			x1 +
			(x1 - context:positionOfBar(source:size() - 2)) *
				((D1 - source:date(source:size() - 1)) / (source:date(source:size() - 1) - source:date(source:size() - 2)))
	end

	if D2 > source:date(source:size() - 1) then
		x2 =
			x2 +
			(x2 - context:positionOfBar(source:size() - 2)) *
				((D2 - source:date(source:size() - 1)) / (source:date(source:size() - 1) - source:date(source:size() - 2)))
	end

	if D3 > source:date(source:size() - 1) then
		x3 =
			x3 +
			(x3 - context:positionOfBar(source:size() - 2)) *
				((D3 - source:date(source:size() - 1)) / (source:date(source:size() - 1) - source:date(source:size() - 2)))
	end

	local visible, y1 = context:pointOfPrice(L1)
	local visible, y2 = context:pointOfPrice(L2)
	local visible, y3 = context:pointOfPrice(L3)

	return x1, y1, x2, y2, x3, y3
end

function Triangle(context, x1, y1, x2, y2, x3, y3, points, Color)
	local xOne = nil
	local yOne
	local xTwo = nil
	local yTwo

	local lx1, ly1, lx2, ly2

	if x1 > x2 then
		if xOne == nil or yOne == nil then
			lx1 = context:left()
			ly1 = context:top()
			lx2 = context:left()
			ly2 = context:bottom()
			xOne, yOne = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)
		end

		if xOne == nil or yOne == nil then
			lx1 = context:left()
			ly1 = context:top()
			lx2 = context:right()
			ly2 = context:top()
			xOne, yOne = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)
		end

		if xOne == nil or yOne == nil then
			lx1 = context:left()
			ly1 = context:bottom()
			lx2 = context:right()
			ly2 = context:bottom()
			xOne, yOne = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)
		end
	elseif x1 < x2 then
		lx1 = context:right()
		ly1 = context:top()
		lx2 = context:right()
		ly2 = context:bottom()
		xOne, yOne = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)

		if xOne == nil or yOne == nil then
			lx1 = context:left()
			ly1 = context:top()
			lx2 = context:right()
			ly2 = context:top()
			xOne, yOne = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)
		end

		if xOne == nil or yOne == nil then
			lx1 = context:left()
			ly1 = context:bottom()
			lx2 = context:right()
			ly2 = context:bottom()
			xOne, yOne = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)
		end
	end

	if x1 > x3 then
		if xTwo == nil or yTwo == nil then
			lx1 = context:left()
			ly1 = context:top()
			lx2 = context:left()
			ly2 = context:bottom()
			xTwo, yTwo = math2d.lineIntersection(x1, y1, x3, y3, lx1, ly1, lx2, ly2)
		end

		if xTwo == nil or yTwo == nil then
			lx1 = context:left()
			ly1 = context:top()
			lx2 = context:right()
			ly2 = context:top()
			xTwo, yTwo = math2d.lineIntersection(x1, y1, x3, y3, lx1, ly1, lx2, ly2)
		end

		if xTwo == nil or yTwo == nil then
			lx1 = context:left()
			ly1 = context:bottom()
			lx2 = context:right()
			ly2 = context:bottom()
			xTwo, yTwo = math2d.lineIntersection(x1, y1, x3, y3, lx1, ly1, lx2, ly2)
		end
	elseif x1 < x3 then
		lx1 = context:right()
		ly1 = context:top()
		lx2 = context:right()
		ly2 = context:bottom()
		xTwo, yTwo = math2d.lineIntersection(x1, y1, x3, y3, lx1, ly1, lx2, ly2)

		if xTwo == nil or yTwo == nil then
			lx1 = context:left()
			ly1 = context:top()
			lx2 = context:right()
			ly2 = context:top()
			xTwo, yTwo = math2d.lineIntersection(x1, y1, x3, y3, lx1, ly1, lx2, ly2)
		end

		if xTwo == nil or yTwo == nil then
			lx1 = context:left()
			ly1 = context:bottom()
			lx2 = context:right()
			ly2 = context:bottom()
			xTwo, yTwo = math2d.lineIntersection(x1, y1, x3, y3, lx1, ly1, lx2, ly2)
		end
	end

	if x1 ~= nil and xOne ~= nil and xTwo ~= nil then
		if Background then
			context:drawGradientTriangle(x1, y1, Color, xOne, yOne, Color, xTwo, yTwo, Color, transparency)
		else
			context:createPen(50, context.SOLID, Width, Color)
			context:drawLine(50, x1, y1, xOne, yOne)
		end
	end
end

function Point(context, L, D, points)
	context:drawEllipse(1, -1, D + points, L + points, D - points, L - points, transparency)
end

local pattern = "([^;]*);([^;]*)"
function AsyncOperationFinished(cookie, success, message)
	if cookie ~= 1 and cookie ~= 2 and cookie ~= 3 then
		return
	end
	level, date = string.match(message, pattern, 0)

	if cookie == 1 then
		db:put("L1", tostring(level))
		db:put("D1", tostring(date))
	elseif cookie == 2 then
		db:put("L2", tostring(level))
		db:put("D2", tostring(date))
	elseif cookie == 3 then
		db:put("L1", tostring(0))
		db:put("D1", tostring(0))
		db:put("L2", tostring(0))
		db:put("D2", tostring(0))
	end
end
