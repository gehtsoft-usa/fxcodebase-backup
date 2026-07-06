-- Id: 11756

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60698

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
	indicator:name("Trend Angle")
	indicator:description("Trend Angle")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "Period", 14)
	indicator.parameters:addDouble("Shift", "Shift", "Shift", 0, 0, 2000)
	indicator.parameters:addString("Method", "Method", "Method", "MVA")
	indicator.parameters:addStringAlternative("Method", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("Method", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("Method", "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA")
	indicator.parameters:addStringAlternative("Method", "WMA", "WMA", "WMA")

	indicator.parameters:addGroup("Placement")
	indicator.parameters:addString("Y", " Y Placement", "", "Top")
	indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
	indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

	indicator.parameters:addString("X", " X Placement", "", "Left")
	indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
	indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("MA_color", "Color of MA", "Color of MA", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Extension_color", "Color of Extension", "Color of Extension", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
	indicator.parameters:addInteger("Size", "Text Size", "", 20)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period
local Method
local X, Y
local first
local source = nil
local Shift
-- Streams block
local MA = nil
local ma
local Size
-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	Method = instance.parameters.Method
	Shift = instance.parameters.Shift
	X = instance.parameters.X
	Y = instance.parameters.Y
	Size = instance.parameters.Size
	source = instance.source

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Method) .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed")
	ma = core.indicators:create(Method, source, Period)
	first = source:first()

	instance:ownerDrawn(true)

	MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.MA_color, first)
	MA:setWidth(instance.parameters.width)
	MA:setStyle(instance.parameters.style)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	ma:update(mode)

	if period < first and source:hasData(period) then
		return
	end

	MA[period] = ma.DATA[period]
end

local init = false

function AngleCalculation(x11, y11, x12, y12)
	return math.atan2((y11 - y12), (x12 - x11)) * 180 / math.pi
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if not init then
		local j
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.Extension_color
		)
		context:createFont(2, "Arial", Size, Size, context.LEFT)
		init = true
	end

	local period = ma.DATA:size() - 1 - Shift

	local x1, x = context:positionOfBar(period - 1)
	local x2, x = context:positionOfBar(period)

	local visible1, y1 = context:pointOfPrice(ma.DATA[period - 1])
	local visible2, y2 = context:pointOfPrice(ma.DATA[period])

	local x3 = nil
	local y3 = nil

	local lx1, ly1, lx2, ly2

	lx1 = context:right()
	ly1 = context:top()
	lx2 = context:right()
	ly2 = context:bottom()
	x3, y3 = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)

	if x3 == nil or y3 == nil or x3 < x2 then
		lx1 = context:left()
		ly1 = context:top()
		lx2 = context:right()
		ly2 = context:top()
		x3, y3 = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)
	end

	if x3 == nil or y3 == nil or x3 < x2 then
		lx1 = context:left()
		ly1 = context:bottom()
		lx2 = context:right()
		ly2 = context:bottom()
		x3, y3 = math2d.lineIntersection(x1, y1, x2, y2, lx1, ly1, lx2, ly2)
	end

	local Angle = AngleCalculation(x1, y1, x2, y2, x1, y1, x2, y1)

	context:drawLine(1, x2, y2, x3, y3)
	local Text = "Line Angle :" .. string.format("%." .. 2 .. "f", Angle)

	local width, height = context:measureText(2, Text, context.LEFT)

	context:drawText(
		2,
		Text,
		instance.parameters.MA_color,
		-1,
		iX(context, width, 0, 1),
		iY(context, height, 3, 2),
		iX(context, width, 0, 2),
		iY(context, height, 3, 3),
		context.LEFT
	)
end

function iX(context, width, Shift, x)
	if X == "Left" then
		return context:left() + Shift * width + width * (x - 1)
	else
		return context:right() - width * Shift - width * (1 - (x - 1))
	end
end

function iY(context, height, Shift, x)
	if Y == "Top" then
		return context:top() + Shift * height + height * (x - 1)
	else
		return context:bottom() - Shift * height + height * (x - 1)
	end
end
