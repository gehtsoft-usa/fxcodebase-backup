-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23584
-- Id: 7454

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Period Min/Max")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	Add(1, 8, false)
	Add(2, 18, false)
	Add(3, 28, false)
	Add(4, 38, false)
	Add(5, 48, true)

	AddLineStyle(1, core.rgb(0, 255, 0))
	AddLineStyle(2, core.rgb(255, 0, 0))
	AddLineStyle(3, core.rgb(0, 0, 255))
	AddLineStyle(4, core.rgb(0, 255, 255))
	AddLineStyle(5, core.rgb(255, 255, 0))

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Label", "Label Color", " ", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("ArrowSize", "Font Size", "", 10)
	indicator.parameters:addBoolean("Pip", "Show  Pip Delta", "", true)
	indicator.parameters:addBoolean("Value", "Show  Price", "", true)
end

function Add(id, Period, Flag)
	indicator.parameters:addGroup(id .. ". Line Calculation")

	indicator.parameters:addBoolean("Line" .. id, "Show Line", "", Flag)
	indicator.parameters:addInteger("Period" .. id, "Line Period", "Period", Period)
	indicator.parameters:addBoolean("Fib" .. id, "Show  Fib. Levels", "", false)

	indicator.parameters:addDouble("L1" .. id, "First Fib. Line Level", "", 38.2)
	indicator.parameters:addDouble("L2" .. id, "Second Fib. Line Level", "", 50)
	indicator.parameters:addDouble("L3" .. id, "Third Fib. Line Level", " ", 61.8)
end

function AddLineStyle(id, color)
	indicator.parameters:addGroup(id .. ". Line Style")
	indicator.parameters:addColor("Color" .. id, " Line Color", " ", color)
	indicator.parameters:addInteger("Width" .. id, "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("Style" .. id, "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("Style" .. id, core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup(id .. ". Fib. Line Style")
	indicator.parameters:addColor("FibColor1" .. id, " Line Color", " ", core.rgb(128, 128, 128))
	indicator.parameters:addInteger("FibWidth1" .. id, "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("FibStyle1" .. id, "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("FibStyle1" .. id, core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup(id .. ". Fib. Line Style")
	indicator.parameters:addColor("FibColor2" .. id, " Line Color", " ", core.rgb(128, 128, 128))
	indicator.parameters:addInteger("FibWidth2" .. id, "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("FibStyle2" .. id, "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("FibStyle2" .. id, core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup(id .. ". Fib. Line Style")
	indicator.parameters:addColor("FibColor3" .. id, " Line Color", " ", core.rgb(128, 128, 128))
	indicator.parameters:addInteger("FibWidth3" .. id, "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("FibStyle3" .. id, "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("FibStyle3" .. id, core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local L1 = {}
local L2 = {}
local L3 = {}
local Fib = {}
local Line = {}
local Period = {}

local Width = {}
local Style = {}
local Color = {}

local FibWidth1 = {}
local FibStyle1 = {}
local FibColor1 = {}

local FibWidth2 = {}
local FibStyle2 = {}
local FibColor2 = {}

local FibWidth3 = {}
local FibStyle3 = {}
local FibColor3 = {}

local first
local source = nil
-- Streams block
local ArrowSize
local font, Label
local Size
local Pip, Value
-- Routine
local First, Second, Third
function Prepare(nameOnly)
	Pip = instance.parameters.Pip
	Value = instance.parameters.Value
	source = instance.source
	first = source:first()
	Label = instance.parameters.Label
	ArrowSize = instance.parameters.ArrowSize

	local s, e
	s, e = core.getcandle(source:barSize(), core.now(), 0)
	Size = e - s

	local name = profile:id() .. "(" .. source:name()

	local i
	for i = 1, 5, 1 do
		Line[i] = instance.parameters:getBoolean("Line" .. i)
		Period[i] = instance.parameters:getInteger("Period" .. i)
		Fib[i] = instance.parameters:getBoolean("Fib" .. i)

		L1[i] = instance.parameters:getDouble("L1" .. i)
		L2[i] = instance.parameters:getDouble("L2" .. i)
		L3[i] = instance.parameters:getDouble("L3" .. i)

		Color[i] = instance.parameters:getDouble("Color" .. i)
		Width[i] = instance.parameters:getInteger("Width" .. i)
		Style[i] = instance.parameters:getInteger("Style" .. i)

		FibColor1[i] = instance.parameters:getDouble("FibColor1" .. i)
		FibWidth1[i] = instance.parameters:getInteger("FibWidth1" .. i)
		FibStyle1[i] = instance.parameters:getInteger("FibStyle1" .. i)

		FibColor2[i] = instance.parameters:getDouble("FibColor2" .. i)
		FibWidth2[i] = instance.parameters:getInteger("FibWidth2" .. i)
		FibStyle2[i] = instance.parameters:getInteger("FibStyle2" .. i)

		FibColor3[i] = instance.parameters:getDouble("FibColor3" .. i)
		FibWidth3[i] = instance.parameters:getInteger("FibWidth3" .. i)
		FibStyle3[i] = instance.parameters:getInteger("FibStyle3" .. i)

		name = name .. ", " .. Period[i]
	end

	instance:name(name .. ")")

	if (not (nameOnly)) then
		font = core.host:execute("createFont", "Arial", ArrowSize, true, false)
	
		local s, e
		s, e = core.getcandle(source:barSize(), core.now(), 0, 0)
	
		Size = e - s
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	if period < source:size() - 1 or not source:hasData(period) then
		return
	end

	local i
	local ID = 1

	for i = 1, 5, 1 do
		if Line[i] and Period[i] ~= 0 and source:first() < source:size() - 1 - Period[i] then
			local min, max
			min, max = mathex.minmax(source, source:size() - 1 - Period[i], source:size() - 1)

			core.host:execute(
				"drawLine",
				ID,
				source:date(source:size() - 1 - Period[i]),
				max,
				source:date(source:size() - 1),
				max,
				Color[i],
				Style[i],
				Width[i]
			)
			ID = ID + 1

			core.host:execute(
				"drawLine",
				ID,
				source:date(source:size() - 1 - Period[i]),
				min,
				source:date(source:size() - 1),
				min,
				Color[i],
				Style[i],
				Width[i]
			)
			ID = ID + 1

			if Value then
				core.host:execute(
					"drawLabel1",
					ID,
					source:date(source:size() - 1) + Size,
					core.CR_CHART,
					max,
					core.CR_CHART,
					core.H_Right,
					core.V_Top,
					font,
					Label,
					string.format("%." .. source:getPrecision() .. "f", max)
				)
				ID = ID + 1

				core.host:execute(
					"drawLabel1",
					ID,
					source:date(source:size() - 1) + Size,
					core.CR_CHART,
					min,
					core.CR_CHART,
					core.H_Right,
					core.V_Top,
					font,
					Label,
					string.format("%." .. source:getPrecision() .. "f", min)
				)
				ID = ID + 1
			end

			if Pip then
				core.host:execute(
					"drawLabel1",
					ID,
					source:date(source:size() - 1 - Period[i]) + Size,
					core.CR_CHART,
					max,
					core.CR_CHART,
					core.H_Right,
					core.V_Top,
					font,
					Label,
					string.format("%." .. 2 .. "f", (max - min) / source:pipSize())
				)
				ID = ID + 1
			end

			local Percent = (max - min) / 100

			if Fib[i] then
				core.host:execute(
					"drawLine",
					ID,
					source:date(source:size() - 1 - Period[i]),
					min + Percent * L1[i],
					source:date(source:size() - 1),
					min + Percent * L1[i],
					FibColor1[i],
					FibStyle1[i],
					FibWidth1[i]
				)
				ID = ID + 1

				core.host:execute(
					"drawLine",
					ID,
					source:date(source:size() - 1 - Period[i]),
					min + Percent * L2[i],
					source:date(source:size() - 1),
					min + Percent * L2[i],
					FibColor2[i],
					FibStyle2[i],
					FibWidth2[i]
				)
				ID = ID + 1

				core.host:execute(
					"drawLine",
					ID,
					source:date(source:size() - 1 - Period[i]),
					min + Percent * L3[i],
					source:date(source:size() - 1),
					min + Percent * L3[i],
					FibColor3[i],
					FibStyle3[i],
					FibWidth3[i]
				)
				ID = ID + 1

				local Lab = ""
				Lab = Lab .. "(" .. L1[i] .. ")"
				if Value then
					Lab = Lab .. "(" .. string.format("%." .. source:getPrecision() .. "f", (min + Percent * L1[i])) .. ")"
				end

				core.host:execute(
					"drawLabel1",
					ID,
					source:date(source:size() - 1) + Size,
					core.CR_CHART,
					min + Percent * L1[i],
					core.CR_CHART,
					core.H_Right,
					core.V_Top,
					font,
					Label,
					Lab
				)
				ID = ID + 1

				Lab = ""
				Lab = Lab .. "(" .. L2[i] .. ")"
				if Value then
					Lab = Lab .. "(" .. string.format("%." .. source:getPrecision() .. "f", (min + Percent * L2[i])) .. ")"
				end

				core.host:execute(
					"drawLabel1",
					ID,
					source:date(source:size() - 1) + Size,
					core.CR_CHART,
					min + Percent * L2[i],
					core.CR_CHART,
					core.H_Right,
					core.V_Top,
					font,
					Label,
					Lab
				)
				ID = ID + 1

				Lab = ""
				Lab = Lab .. "(" .. L3[i] .. ")"
				if Value then
					Lab = Lab .. "(" .. string.format("%." .. source:getPrecision() .. "f", (min + Percent * L3[i])) .. ")"
				end

				core.host:execute(
					"drawLabel1",
					ID,
					source:date(source:size() - 1) + Size,
					core.CR_CHART,
					min + Percent * L3[i],
					core.CR_CHART,
					core.H_Right,
					core.V_Top,
					font,
					Label,
					Lab
				)
				ID = ID + 1
			end
		end
	end
end

function ReleaseInstance()
	core.host:execute("deleteFont", font)
end
