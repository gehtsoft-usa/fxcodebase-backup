-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12728
-- Id: 6329

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("TrendStopCloud")
	indicator:description("TrendStopCloud")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("First TS Calculation")
	indicator.parameters:addInteger("Period1", "Period", "Period", 10)
	indicator.parameters:addString("Type1", "Triger", "", "Close")
	indicator.parameters:addStringAlternative("Type1", "Close", "", "Close")
	indicator.parameters:addStringAlternative("Type1", "High/Low", "", "High")

	indicator.parameters:addGroup("Second TS Calculation")
	indicator.parameters:addInteger("Period2", "Period", "Period", 15)
	indicator.parameters:addString("Type2", "Triger", "", "Close")
	indicator.parameters:addStringAlternative("Type2", "Close", "", "Close")
	indicator.parameters:addStringAlternative("Type2", "High/Low", "", "High")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40, 0, 100)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1, Period2
local first
local source = nil
local Type1, Type2
-- Streams block
local Short, Long
local SHORT, LONG
local Transparency
-- Routine
function Prepare(nameOnly)
	Transparency = instance.parameters.Transparency
	Type1 = instance.parameters.Type1
	Period1 = instance.parameters.Period1
	Type2 = instance.parameters.Type2
	Period2 = instance.parameters.Period2
	source = instance.source

	Transparency = 100 - Transparency

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Type1) .. ", " .. tostring(Period2) .. ", " .. tostring(Type2) .. ")"
	instance:name(name)
	if nameOnly then
		return;
	end

	assert(core.indicators:findIndicator("TRENDSTOP") ~= nil, "Please, download and install TRENDSTOP.LUA indicator")

	SHORT = core.indicators:create("TRENDSTOP", source, Period1, Type1)
	LONG = core.indicators:create("TRENDSTOP", source, Period2, Type2)

	first = math.max(SHORT.DATA:first(), LONG.DATA:first())

	Short = instance:addStream("Short", core.Line, name, "Short", instance.parameters.Up, first)
	Long = instance:addStream("Long", core.Line, name, "Long", instance.parameters.Down, first)
	instance:createChannelGroup("Cloud", "Trend Cloud", Short, Long, instance.parameters.Up, Transparency)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	if period < first or not source:hasData(period) then
		return
	end

	if period ~= source:size() - 1 then
		SHORT:update(mode)
		LONG:update(mode)
	else
		SHORT:update(core.UpdateAll)
		LONG:update(core.UpdateAll)
	end

	Short[period] = SHORT.DATA[period]
	Long[period] = LONG.DATA[period]
	if Short[period] > Long[period] then
		Short:setColor(period, instance.parameters.Up)
	elseif Short[period] < Long[period] then
		Short:setColor(period, instance.parameters.Down)
	end
end
