-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67313

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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

function Init()
	indicator:name("step - vhf - adaptive vma")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("MA Calculation")
	indicator.parameters:addInteger("Period1", "VMA Period", "", 14, 1, 2000)
	indicator.parameters:addInteger("Period2", "VHF Period", "", 0, 0, 2000)
	indicator.parameters:addDouble("Size", "Step Size (in Pips)", "", 1, 0, 200000)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1, Period2
local first
local source = nil
local noise
local Average
local alpha
local Size
local Average_Data
local Direction
local Up, Down
-- Routine
function Prepare(nameOnly)
	source = instance.source

	Period1 = instance.parameters.Period1
	Period2 = instance.parameters.Period2
	Size = instance.parameters.Size

	if Period2 <= Period1 then
		Period2 = Period1
	end

	local Parameters = Period1 .. ", " .. Period2 .. ", " .. Size

	local name = profile:id() .. "(" .. instance.source:name() .. ", " .. Parameters .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Up = instance.parameters.Up
	Down = instance.parameters.Down

	alpha = 2.0 / (1.0 + math.max(Period1, 1))

	first = source:first() + Period2

	noise = instance:addInternalStream(0, 0)
	Average_Data = instance:addInternalStream(0, 0)
	Direction = instance:addInternalStream(0, 0)

	Average = instance:addStream("Average", core.Line, " Average", "Average", Up, first)
	Average:setWidth(instance.parameters.width)
	Average:setStyle(instance.parameters.style)
	Average:setPrecision(math.max(2, source:getPrecision()))
end

-- Indicator calculation routine
function Update(period, mode)
	noise[period] = math.abs(source[period] - source[period - 1])

	if period < first then
		Average_Data[period] = source[period]
		return
	end

	local vhf = 0
	local Noise = mathex.sum(noise, period - Period2, period)
	if (Noise > 0) then
		local min, max = mathex.minmax(source, period - Period2, period)
		vhf = (max - min) / Noise
	end

	Average_Data[period] = Average_Data[period - 1] + (alpha * vhf * 2) * (source[period] - Average_Data[period - 1])

	if Size > 0 then
		Average[period] = round(Average_Data[period] / (Size * source:pipSize()), 0) * (Size * source:pipSize())
	else
		Average[period] = Average_Data[period]
	end

	if Average[period] > Average[period - 1] then
		Direction[period] = 1
	elseif Average[period] < Average[period - 1] then
		Direction[period] = -1
	else
		Direction[period] = Direction[period - 1]
	end

	if Direction[period] == 1 then
		Average:setColor(period, Up)
	else
		Average:setColor(period, Down)
	end
end

function round(num, idp)
	if idp and idp > 0 then
		local mult = 10 ^ idp
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end
