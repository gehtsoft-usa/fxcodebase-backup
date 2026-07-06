-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64686
-- Id: 18204

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
	indicator:name("Since last fractal overlay")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation of Since last advanced fractal (Only)")
	indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 5, 99)

	indicator.parameters:addString("Type", "Indicator", "", "1")
	indicator.parameters:addStringAlternative("Type", "Since last fractal", "", "1")
	indicator.parameters:addStringAlternative("Type", "Since Last Advanced Fractal", "", "2")

	indicator.parameters:addInteger("Period", "Period", "", 10)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up, Down, Neutral
local first
local source = nil

local Type
local Indicator
local Period

local open = nil
local close = nil
local high = nil
local low = nil

local Frame
local One, Two, Three

function Prepare(nameOnly)
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Neutral = instance.parameters.Neutral
	Period = instance.parameters.Period

	Type = instance.parameters.Type
	Frame = instance.parameters.Frame

	source = instance.source

	local name

	if Type == "1" then
		assert(
			core.indicators:findIndicator("SINCE LAST FRACTAL") ~= nil,
			"Please, download and install SINCE LAST FRACTAL.LUA indicator"
		)
		name = profile:id() .. " : " .. source:name() .. " : " .. source:barSize() .. " : " .. "SINCE LAST FRACTAL"
		if not nameOnly then
			Indicator = core.indicators:create("SINCE LAST FRACTAL", source)
		end
	else
		assert(
			core.indicators:findIndicator("SINCE LAST ADVANCED FRACTAL") ~= nil,
			"Please, download and install SINCE LAST ADVANCED FRACTAL.LUA indicator"
		)
		name = profile:id() .. " : " .. source:name() .. " : " .. source:barSize() .. " : " .. "SINCE LAST ADVANCED FRACTAL"
		if not nameOnly then
			Indicator = core.indicators:create("SINCE LAST ADVANCED FRACTAL", source, Frame)
		end
	end

	instance:name(name)
	if nameOnly then
		return;
	end
	first = math.max(Indicator.Up:first(), Indicator.Down:first())

	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		open:setColor(period, Neutral)
		return
	end

	Indicator:update(mode)
	--  green > red and green > x

	if Indicator.Up[period] > Indicator.Down[period] and Indicator.Up[period] > Period then
		open:setColor(period, Up)
	elseif Indicator.Up[period] < Indicator.Down[period] and Indicator.Down[period] > Period then
		open:setColor(period, Down)
	else
		open:setColor(period, Neutral)
	end
end
