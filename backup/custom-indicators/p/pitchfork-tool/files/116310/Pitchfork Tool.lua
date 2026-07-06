-- Id: 19870

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61065

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
	indicator:name("Pitchfork Tool")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("Method", "Method", "Method", "Andrews Pitchfork")
	indicator.parameters:addStringAlternative("Method", "Andrews Pitchfork", "Andrews Pitchfork", "Andrews Pitchfork")
	indicator.parameters:addStringAlternative("Method", "Schiff Pitchfork ", "Schiff Pitchfork ", "Schiff Pitchfork")
	indicator.parameters:addStringAlternative(
		"Method",
		"Modified Schiff Pitchfork",
		"Modified Schiff Pitchfork",
		"Modified Schiff Pitchfork"
	)

	indicator.parameters:addBoolean("Extend", "Extend Lines", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addInteger("Size", "Label Size", "", 10)
	indicator.parameters:addInteger("Width", "Line Width", "", 3)
	indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 0))

	indicator.parameters:addFile("input_file", "CSV File", "", "")
	indicator.parameters:addString("input_file_separator", "CSV File Separator", "", ",")
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
local Size
local init = false
local Cell
local Method
local Width
local Extend
local initPoints = nil

function Prepare(nameOnly)
	Color = instance.parameters.Color
	Size = instance.parameters.Size
	Method = instance.parameters.Method
	Width = instance.parameters.Width
	Extend = instance.parameters.Extend
	source = instance.source
	first = source:first()

	name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	core.host:execute("addCommand", 1, "Set A Point", "")
	core.host:execute("addCommand", 2, "Set B Point", "")
	core.host:execute("addCommand", 3, "Set C Point", "")
	core.host:execute("addCommand", 4, "Reset")

	initPoints = parseFile(instance.parameters.input_file, instance.parameters.input_file_separator)

	require("storagedb")
	db = storagedb.get_db(profile:id() .. "(" .. source:name())

	if initPoints ~= nil then
		db:put("AL", tostring(initPoints.AL))
		db:put("AD", tostring(initPoints.AD))
		db:put("BL", tostring(initPoints.BL))
		db:put("BD", tostring(initPoints.BD))
		db:put("CL", tostring(initPoints.CL))
		db:put("CD", tostring(initPoints.CD))
	end

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
		Cell = context:pointsToPixels(Size)
		context:createFont(1, "Wingdings", Cell, Cell, 0)
		context:createPen(2, context.SOLID, context:pointsToPixels(Width), Color)
		init = true
	end

	if AL == 0 or BL == 0 or CL == 0 then
		return
	end

	local p1 = core.findDate(source, AD, false)
	local p2 = core.findDate(source, BD, false)
	local p3 = core.findDate(source, CD, false)

	if p1 == -1 or p2 == -1 or p3 == -1 then
		return
	end

	local x1, y1 = Add(context, AL, p1)
	local x2, y2 = Add(context, BL, p2)
	local x3, y3 = Add(context, CL, p3)

	if x1 == nil or x2 == nil or x3 == nil then
		return
	end

	local X2 = x2
	local Y2 = y2
	local X3 = x3
	Y3 = y3

	if Method == "Andrews Pitchfork" then
		X1 = x1
		Y1 = y1
	elseif Method == "Schiff Pitchfork" then
		X1 = x1
		if y1 > y2 then
			Y1 = y1 - (y1 - y2) / 2
		else
			Y1 = y1 + (y2 - y1) / 2
		end
	elseif Method == "Modified Schiff Pitchfork" then
		X1 = math.min(x1, x2) + (math.max(x1, x2) - math.min(x1, x2)) / 2

		if y1 > y2 then
			Y1 = y1 - (y1 - y2) / 2
		else
			Y1 = y1 + (y2 - y1) / 2
		end
	end

	local mX = math.min(X2, X3) + (math.max(X2, X3) - math.min(X2, X3)) / 2
	local mY = math.min(Y2, Y3) + (math.max(Y2, Y3) - math.min(Y2, Y3)) / 2

	---Srednja Start
	AddNew(context, mY, mX)

	AddNew(context, Y1, X1)

	context:drawLine(2, X1, Y1, mX, mY)
	context:drawLine(2, X2, Y2, X3, Y3)

	--a, c=  math2d.lineEquation (X1, Y1, mX, mY);

	--To calculate y coordinate of a point on the line use
	--y = a * x + c

	--To calculate x coordinate of a point on the line use
	--x = (y - b) / a

	xDelta = mX - X1
	xA = X2 + xDelta
	xB = X3 + xDelta

	yDelta = Y1 - mY
	yA = Y2 - yDelta
	yB = Y3 - yDelta

	AddNew(context, yA, xA)
	AddNew(context, yB, xB)

	--Srednja Mid
	local mXm = math.min(xA, xB) + (math.max(xA, xB) - math.min(xA, xB)) / 2
	local mYm = math.min(yA, yB) + (math.max(yA, yB) - math.min(yA, yB)) / 2

	AddNew(context, mYm, mXm)

	if Extend then
		ex1, ey1, ex2, ey2 =
			math2d.lineRectangleIntersection(context:left(), context:top(), context:right(), context:bottom(), xA, yA, X2, Y2)
		ex3, ey3, ex4, ey4 =
			math2d.lineRectangleIntersection(context:left(), context:top(), context:right(), context:bottom(), xB, yB, X3, Y3)
		ex5, ey5, ex6, ey6 =
			math2d.lineRectangleIntersection(context:left(), context:top(), context:right(), context:bottom(), mX, mY, mXm, mYm)

		if X1 > mX then
			if ex1 ~= nil and ex2 ~= nil then
				x1X = math.min(ex1, ex2)
			else
				x1X = nil
			end
			if ex3 ~= nil and ex4 ~= nil then
				x2X = math.min(ex3, ex4)
			else
				x2X = nil
			end
			if ex5 ~= nil and ex6 ~= nil then
				eX = math.min(ex5, ex6)
			else
				eX = nil
			end
		else
			if ex1 ~= nil and ex2 ~= nil then
				x1X = math.max(ex1, ex2)
			else
				x1X = nil
			end
			if ex3 ~= nil and ex4 ~= nil then
				x2X = math.max(ex3, ex4)
			else
				x2X = nil
			end
			if ex5 ~= nil and ex6 ~= nil then
				eX = math.max(ex5, ex6)
			else
				eX = nil
			end
		end

		if Y1 > mY then
			if ey1 ~= nil and ey2 ~= nil then
				x1Y = math.min(ey1, ey2)
			else
				x1Y = nil
			end
			if ey3 ~= nil and ey4 ~= nil then
				x2Y = math.min(ey3, ey4)
			else
				x2Y = nil
			end
			if ey5 ~= nil and ey6 ~= nil then
				eY = math.min(ey5, ey6)
			else
				eY = nil
			end
		else
			if ey1 ~= nil and ey2 ~= nil then
				x1Y = math.max(ey1, ey2)
			else
				x1Y = nil
			end
			if ey3 ~= nil and ey4 ~= nil then
				x2Y = math.max(ey3, ey4)
			else
				x2Y = nil
			end
			if ey5 ~= nil and ey6 ~= nil then
				eY = math.max(ey5, ey6)
			else
				eY = nil
			end
		end

		if x1X ~= nil and x1Y ~= nil then
			context:drawLine(2, x1X, x1Y, X2, Y2)
		end

		if x2X ~= nil and x2Y ~= nil then
			context:drawLine(2, x2X, x2Y, X3, Y3)
		end

		if eX ~= nil and eY ~= nil then
			context:drawLine(2, mX, mY, eX, eY)
		end
	else
		context:drawLine(2, xA, yA, X2, Y2)
		context:drawLine(2, xB, yB, X3, Y3)
		context:drawLine(2, mX, mY, mXm, mYm)
	end
end

function Parallel(x, y, x1, y1)
	local a = x
	local b = y1 - a * x1

	return a, b
end

function Add(context, L, D)
	if S == -1 or L == 0 then
		return
	end

	x, x1 = context:positionOfBar(D)
	visible, y1 = context:pointOfPrice(L)
	x2 = x1 + Cell / 2
	y2 = y1 + Cell / 2
	context:drawText(1, "\164", Color, -1, x1 - Cell / 2, y1 - Cell / 2, x2, y2, 0)

	return x1, y1
end

function AddNew(context, y2, x2)
	context:drawText(1, "\164", Color, -1, x2 - Cell / 2, y2 - Cell / 2, x2 + Cell / 2, y2 + Cell / 2, 0)
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
	elseif cookie == 4 then
		db:put("AL", tostring(0))
		db:put("AD", tostring(0))
		db:put("BL", tostring(0))
		db:put("BD", tostring(0))
		db:put("CL", tostring(0))
		db:put("CD", tostring(0))
	end
end

function todate(str)
	-- dd/mm/yyyy hh:mm
	local _day, _month, _year, _hour, _minute = string.match(str, "(%d+)/(%d+)/(%d+) (%d+):(%d+)")
	local date = {year = _year, month = _month, day = _day, hour = _hour, min = _minute, sec = 0}
	return core.tableToDate(date)
end

function parseFile(file, separator)
	local f = io.open(file, "r")
	if (f == nil) then
		return nil
	end
	f:close()

	local points = {}
	for line in io.lines(file) do
		local values, values_count = core.parseCsv(line, separator)
		if values_count >= 6 then
			points.AL = tonumber(values[1])
			points.BL = tonumber(values[3])
			points.CL = tonumber(values[5])
			points.AD = todate(values[0])
			points.BD = todate(values[2])
			points.CD = todate(values[4])
			break
		else
			core.host:trace("Impossible to parse points: " .. line)
		end
	end

	return points
end
