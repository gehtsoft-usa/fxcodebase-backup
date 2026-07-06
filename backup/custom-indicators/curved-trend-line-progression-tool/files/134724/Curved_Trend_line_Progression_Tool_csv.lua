-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66833

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
	indicator:name("Curved Trend line Progression Tool")
	indicator:description("Curved Trend line Progression Tool")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Steps", "Steps", "", 10)
	indicator.parameters:addString("ID", "ID", "", "1")

	indicator.parameters:addBoolean("Show", "Channel based on 1. Line", "", false)
	indicator.parameters:addDouble("ChannelWidth", "ChannelWidth in pips ", "", 50)

	indicator.parameters:addBoolean("Last", "Last Three Candles Mode ", "", false)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color1", "Line Color", "Line Color", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color2", "Forecasted Line Color", "Line Color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_DASH)
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

	indicator.parameters:addFile("file", "File, csv", "", "");
	indicator.parameters:addString("separator", "Separator", "", ",")
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local color1
local color2
local Level = {}
local Date = {}
local Steps
local ID
local Show
local ChannelWidth
local Last

function todate(str)
	local _month, _day, _year, _hour, _minute = string.match(str, '(%d+)/(%d+)/(%d+) (%d+):(%d+)');
	local date = {year = _year, month = _month, day = _day, hour = _hour, min = _minute, sec = 0};
	return core.tableToDate(date);
end

-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()

	color1 = instance.parameters.color1
	color2 = instance.parameters.color2
	Steps = instance.parameters.Steps
	ID = instance.parameters.ID
	Last = instance.parameters.Last

	local name = profile:id() .. "(" .. source:name() .. ", " .. ID .. ", " .. Steps .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	ChannelWidth = instance.parameters.ChannelWidth * source:pipSize()

	Show = instance.parameters.Show

	for str_line in io.lines(instance.parameters.file) do 
		local values, values_count = core.parseCsv(str_line, instance.parameters.separator);
		if values_count >= 4 then
			local line = {};
			Level[1] = tonumber(values[1]);
			Level[2] = tonumber(values[3]);
			Level[3] = tonumber(values[5]);
			Date[1] = todate(values[0]);
			Date[2] = todate(values[2]);
			Date[3] = todate(values[4]);
		else
			core.host:trace("Impossible to parse line: " .. str_line);
		end
	end

	instance:ownerDrawn(true)

	core.host:execute("setTimer", 10, 1)
end

function ReleaseInstance()
	core.host:execute("killTimer", 10)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
	if Last then
		period = source:size() - 1

		if period < 3 then
			return
		end

		Level[1] = source[period - 2]
		Level[2] = source[period - 1]
		Level[3] = source[period]

		Date[1] = source:date(period - 2)
		Date[2] = source:date(period - 1)
		Date[3] = source:date(period)
	else
		if cookie == 10 then
			instance:updateFrom(0)
		end
	end

	return core.ASYNC_REDRAW
end

local init
function Draw(stage, context)
	if stage == 2 then
		return
	end

	if not init then
		context:createPen(1, context:convertPenStyle(instance.parameters.style1), instance.parameters.width1, color1)
		context:createPen(2, context:convertPenStyle(instance.parameters.style2), instance.parameters.width2, color2)
		init = true
	end

	points1 = ownerdraw_points.new()
	points2 = ownerdraw_points.new()

	points3 = ownerdraw_points.new()
	points4 = ownerdraw_points.new()

	if
		Date[1] ~= nil and Date[1] ~= 0 and Date[1] >= source:date(source:first()) and
			Date[1] <= source:date(source:size() - 1)
	 then
		p = core.host:execute("calculatePositionOfDate", source, Date[1])
		if p ~= -1 and p >= source:first() and p <= source:size() - 1 then
			x, x1, x1 = context:positionOfBar(p)
		end

		visible, y = context:pointOfPrice(Level[1])

		points1:add(x, y)
	else
		return
	end

	if
		Date[2] ~= nil and Date[2] ~= 0 and Date[2] >= source:date(source:first()) and
			Date[2] <= source:date(source:size() - 1)
	 then
		p = core.host:execute("calculatePositionOfDate", source, Date[2])
		if p ~= -1 and p >= source:first() and p <= source:size() - 1 then
			x, x1, x1 = context:positionOfBar(p)
		end
		visible, y = context:pointOfPrice(Level[2])

		points1:add(x, y)
	end

	if
		Date[3] ~= nil and Date[3] ~= 0 and Date[3] >= source:date(source:first()) and
			Date[3] <= source:date(source:size() - 1)
	 then
		p = core.host:execute("calculatePositionOfDate", source, Date[3])
		if p ~= -1 and p >= source:first() and p <= source:size() - 1 then
			x, x1, x1 = context:positionOfBar(p)
		end

		visible, y = context:pointOfPrice(Level[3])

		points1:add(x, y)
	end

	if
		Date[3] == nil or Date[2] == nil or Date[1] == nil or Date[3] < source:date(source:first()) or
			Date[2] < source:date(source:first()) or
			Date[1] < source:date(source:first()) or
			Date[3] > source:date(source:size() - 1) or
			Date[2] > source:date(source:size() - 1) or
			Date[1] > source:date(source:size() - 1)
	 then
		return
	end

	--2. Line 3. Point Calculation

	x1, y1 = points1:get(0)
	x2, y2 = points1:get(1)
	x3, y3 = points1:get(2)

	local Last = x3
	local Coefficient = ((x3 - x2) / (x2 - x1))

	points2:add(x3, y3)
	for i = 1, Steps, 1 do
		x = Last + (x2 - x1) * Coefficient
		Last = x
		local y = LagrangeInterpolation(x, x1, x2, x3, y1, y2, y3)
		points2:add(x, y)
	end

	context:drawPolyline(1, points1, 0)
	context:drawPolyline(2, points2, 0)

	if Show then
		visible, y1 = context:pointOfPrice(Level[1] + ChannelWidth)
		visible, y2 = context:pointOfPrice(Level[2] + ChannelWidth)
		visible, y3 = context:pointOfPrice(Level[3] + ChannelWidth)

		points3:add(x1, y1)
		points3:add(x2, y2)
		points3:add(x3, y3)

		points4:add(x3, y3)

		context:drawPolyline(1, points1, 0)

		local Last = x3
		local Coefficient = ((x3 - x2) / (x2 - x1))
		for i = 1, Steps, 1 do
			x = Last + (x2 - x1) * Coefficient
			Last = x
			local y = LagrangeInterpolation(x, x1, x2, x3, y1, y2, y3)
			points4:add(x, y)
		end

		context:drawPolyline(1, points3, 0)
		context:drawPolyline(2, points4, 0)
	end
end

function LagrangeInterpolation(x, x1, x2, x3, y1, y2, y3)
	local A = (y1 * (x - x2) * (x - x3)) / ((x1 - x2) * (x1 - x3))
	local B = (y2 * (x - x1) * (x - x3)) / ((x2 - x1) * (x2 - x3))
	local C = (y3 * (x - x1) * (x - x2)) / ((x3 - x1) * (x3 - x2))
	return A + B + C
end
