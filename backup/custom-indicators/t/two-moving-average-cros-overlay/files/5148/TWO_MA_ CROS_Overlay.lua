-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2385
-- Id: 1942

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
	indicator:name("TWO MA Cross Overlay")
	indicator:description("TWO MA Cross Overlay")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("First MA Parameters")

	indicator.parameters:addString("IN1", "Price Type", "", "close")
	indicator.parameters:addStringAlternative("IN1", "OPEN", "", "open")
	indicator.parameters:addStringAlternative("IN1", "HIGH", "", "high")
	indicator.parameters:addStringAlternative("IN1", "LOW", "", "low")
	indicator.parameters:addStringAlternative("IN1", "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("IN1", "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("IN1", "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("IN1", "WEIGHTED", "", "weighted")

	indicator.parameters:addString("M1", "Method for avegage", "", "EMA")
	indicator.parameters:addStringAlternative("M1", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("M1", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("M1", "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("M1", "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("M1", "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("M1", "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("M1", "VIDYA", "VIDYA", "VIDYA")
	indicator.parameters:addStringAlternative("M1", "WMA", "WMA", "WMA")
	indicator.parameters:addStringAlternative("M1", "VAMA", "VAMA", "VAMA")

	indicator.parameters:addInteger("Frame1", "MA Frame", "", 34, 2, 1000)

	indicator.parameters:addGroup("Second MA Parameters")

	indicator.parameters:addString("IN2", "Price Type", "", "close")
	indicator.parameters:addStringAlternative("IN2", "OPEN", "", "open")
	indicator.parameters:addStringAlternative("IN2", "HIGH", "", "high")
	indicator.parameters:addStringAlternative("IN2", "LOW", "", "low")
	indicator.parameters:addStringAlternative("IN2", "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("IN2", "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("IN2", "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("IN2", "WEIGHTED", "", "weighted")

	indicator.parameters:addString("M2", "Method for avegage", "", "EMA")
	indicator.parameters:addStringAlternative("M2", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("M2", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("M2", "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("M2", "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("M2", "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("M2", "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("M2", "VIDYA", "VIDYA", "VIDYA")
	indicator.parameters:addStringAlternative("M2", "WMA", "WMA", "WMA")
	indicator.parameters:addStringAlternative("M2", "VAMA", "VAMA", "VAMA")

	indicator.parameters:addInteger("Frame2", "MA Frame", "", 50, 2, 1000)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Frame = {}
local IN = {}
local M = {}

local open = nil
local close = nil
local high = nil
local low = nil

local MA = {}

local Type = {open = "O", close = "C", high = "H", low = "L", median = "M", typical = "T"}

function Prepare(nameOnly)
	IN[1] = instance.parameters.IN1
	IN[2] = instance.parameters.IN2
	M[1] = instance.parameters.M1
	M[2] = instance.parameters.M2
	Frame[1] = instance.parameters.Frame1
	Frame[2] = instance.parameters.Frame2
	local Flag = {}
	Flag[1] = IN[1]
	Flag[2] = IN[2]
	source = instance.source
	local name = profile:id() .. "(" .. source:name() .. ", " .. M[1] .. ", " .. Flag[1] .. ", " .. Frame[1] .. ", " .. M[2] .. ", " .. Flag[2] .. ", " .. Frame[2] .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	
	if M[1] == "VAMA" then
    assert(core.indicators:findIndicator(M[1]) ~= nil, M[1] .. " indicator must be installed");
		MA[1] = core.indicators:create(M[1], source, Frame[1], Type[IN[1]])
	else
		MA[1] = core.indicators:create(M[1], source[IN[1]], Frame[1])
	end

	if M[2] == "VAMA" then
    assert(core.indicators:findIndicator(M[2]) ~= nil, M[2] .. " indicator must be installed");
		MA[2] = core.indicators:create(M[2], source, Frame[2], Type[IN[2]])
	else
		MA[2] = core.indicators:create(M[2], source[IN[2]], Frame[2])
	end

	first = math.max(MA[2].DATA:first(), MA[1].DATA:first())

	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("MACD", "MACD", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
	MA[1]:update(mode)
	MA[2]:update(mode)

	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		open:setColor(period, instance.parameters.Neutral)
		return
	end

	if MA[1].DATA[period] > MA[2].DATA[period] then
		open:setColor(period, instance.parameters.Up)
	elseif MA[1].DATA[period] < MA[2].DATA[period] then
		open:setColor(period, instance.parameters.Down)
	else
		open:setColor(period, instance.parameters.Neutral)
	end
end
