-- Id: 20363
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Min Max Cycle")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "Period", 25)
	indicator.parameters:addDouble("Level1", "1.Level", "Level", 25)
	indicator.parameters:addDouble("Level2", "2.Level", "Level", 50)
	indicator.parameters:addDouble("Level3", "3.Level", "Level", 75)
	indicator.parameters:addDouble("Level4", "4.Level", "Level", 100)
	indicator.parameters:addDouble("Level5", "5.Level", "Level", 200)

	indicator.parameters:addString("Scale", "Scale", "", "Not fixed")
	indicator.parameters:addStringAlternative("Scale", "Not fixed", "", "Not fixed")
	indicator.parameters:addStringAlternative("Scale", "Fixed on X", "", "Fixed on X")
	indicator.parameters:addStringAlternative("Scale", "Fixed on Y", "", "Fixed on Y")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("CrossColor", "Cross Color", "Line Color", core.rgb(0, 0, 0))
	indicator.parameters:addColor("color_1", "1. Level Color", "Line Color", core.rgb(128, 128, 128))
	indicator.parameters:addColor("color_2", "2. Level Color", "Line Color", core.rgb(128, 128, 128))
	indicator.parameters:addColor("color_3", "3. Level Color", "Line Color", core.rgb(128, 128, 128))
	indicator.parameters:addColor("color_4", "4. Level Color", "Line Color", core.rgb(0, 0, 255))
	indicator.parameters:addColor("color_5", "5. Level Color", "Line Color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width", "Line width", "", 2, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period

local first
local source = nil
local min, max, minpos, maxpos
local transparency
local Level = {}
local Color = {}
local CrossColor
local Scale
-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	CrossColor = instance.parameters.CrossColor
	Scale = instance.parameters.Scale

	source = instance.source
	first = source:first() + Period

	for i = 1, 5, 1 do
		Level[i] = instance.parameters:getDouble("Level" .. i) / 100
		Color[i] = instance.parameters:getColor("color_" .. i)
	end

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")"
	instance:name(name)
	minpos = nil
	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	if period < first or period < source:size() - 1 then
		return
	end

	min, max, minpos, maxpos = mathex.minmax(source, period - Period + 1, period)
end

local init = false

function Draw(stage, context)
	if min == nil then
		return
	end

	if not init then
		for i = 1, 5, 1 do
			context:createPen(i, context:convertPenStyle(instance.parameters.style), instance.parameters.width, Color[i])
		end
		transparency = context:convertTransparency(instance.parameters.transparency)
		context:createPen(6, context:convertPenStyle(instance.parameters.style), instance.parameters.width, CrossColor)

		init = true
	end

	local x1, x = context:positionOfBar(minpos)
	local x2, x = context:positionOfBar(maxpos)
	local visible, y1 = context:pointOfPrice(min)
	local visible, y2 = context:pointOfPrice(max)

	local xd = math.abs(x2 - x1)
	local yd = math.abs(y2 - y1)
	local Distance

	if Scale == "Not fixed" then
		Distance = math.sqrt(xd * xd + yd * yd)
	elseif Scale == "Fixed on X" then
		Distance = xd
	else
		Distance = yd
	end

	if x1 < x2 then
		context:drawLine(6, context:left(), y1, context:right(), y1, transparency)
		context:drawLine(6, x1, context:top(), x1, context:bottom(), transparency)
		for i = 1, 5, 1 do
			context:drawLine(
				i,
				context:left(),
				y1 - Distance * Level[i],
				context:right(),
				y1 - Distance * Level[i],
				transparency
			)
			context:drawLine(
				i,
				context:left(),
				y1 + Distance * Level[i],
				context:right(),
				y1 + Distance * Level[i],
				transparency
			)
			context:drawEllipse(
				i,
				-1,
				math.min(x1, x2) - Distance * Level[i],
				y1 - Distance * Level[i],
				math.min(x1, x2) + Distance * Level[i],
				y1 + Distance * Level[i],
				transparency
			)
		end
	else
		context:drawLine(6, context:left(), y2, context:right(), y2, transparency)
		context:drawLine(6, x2, context:top(), x2, context:bottom(), transparency)
		for i = 1, 5, 1 do
			context:drawLine(
				i,
				context:left(),
				y2 - Distance * Level[i],
				context:right(),
				y2 - Distance * Level[i],
				transparency
			)
			context:drawLine(
				i,
				context:left(),
				y2 + Distance * Level[i],
				context:right(),
				y2 + Distance * Level[i],
				transparency
			)
			context:drawEllipse(
				i,
				-1,
				math.min(x1, x2) - Distance * Level[i],
				y2 - Distance * Level[i],
				math.min(x1, x2) + Distance * Level[i],
				y2 + Distance * Level[i],
				transparency
			)
		end
	end
end
