-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12728
-- Id: 6708

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
	indicator:name("Trend Stop Overlay")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Trend Stop Calculation")
	indicator.parameters:addInteger("Period", "Period", "Period", 10)
	indicator.parameters:addString("Type", "Triger", "", "Close")
	indicator.parameters:addStringAlternative("Type", "Close", "", "Close")
	indicator.parameters:addStringAlternative("Type", "High/Low", "", "High")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil

local open = nil
local close = nil
local high = nil
local low = nil
local Period, Type
local TS

function Prepare(nameOnly)
	Period = instance.parameters.Period
	Type = instance.parameters.Type

	source = instance.source
	local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Type .. ")"
	instance:name(name)
	if nameOnly then
		return;
	end

    assert(core.indicators:findIndicator("TRENDSTOP") ~= nil, "TRENDSTOP" .. " indicator must be installed");
	TS = core.indicators:create("TRENDSTOP", source, Period, Type)

	first = TS.DATA:first()

	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
	open:setColor(period, instance.parameters.No)

	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		return
	end

	if period ~= source:size() - 1 then
		TS:update(mode)
	else
		TS:update(core.UpdateAll)
	end

	if source.close[period] > TS.DATA[period] then
		open:setColor(period, instance.parameters.Up)
	else
		open:setColor(period, instance.parameters.Dn)
	end
end
