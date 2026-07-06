-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2012
-- Id: 1446

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
	indicator:name("MA Price Overlay")
	indicator:description("MA Price Overlay")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addInteger("IN", "Data Source", "", 4)
	indicator.parameters:addIntegerAlternative("IN", "Open", "", 1)
	indicator.parameters:addIntegerAlternative("IN", "High", "", 2)
	indicator.parameters:addIntegerAlternative("IN", "Low", "", 3)
	indicator.parameters:addIntegerAlternative("IN", "Close", "", 4)
	indicator.parameters:addIntegerAlternative("IN", "Median", "", 5)
	indicator.parameters:addIntegerAlternative("IN", "Typical", "", 6)
	indicator.parameters:addIntegerAlternative("IN", "Weighted ", "", 7)
	indicator.parameters:addString("M", "Method for avegage", "", "EMA")
	indicator.parameters:addStringAlternative("M", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("M", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("M", "LWMA", "", "LWMA")
	indicator.parameters:addStringAlternative("M", "TMA", "", "TMA")
	indicator.parameters:addStringAlternative("M", "WMA", "", "WMA")
	indicator.parameters:addStringAlternative("M", "VIDYA", "", "VIDYA")

	indicator.parameters:addInteger("Frame", "MA Frame", "", 34, 2, 1000)

	indicator.parameters:addString("TYPE", "Filter Type", "", "MA")
	indicator.parameters:addStringAlternative("TYPE", "Price", "", "PRICE")
	indicator.parameters:addStringAlternative("TYPE", "MA", "", "MA")
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Frame = nil
local IN = nil
local M = nil

local open = nil
local close = nil
local high = nil
local low = nil

local MA = nil
local TYPE = nil

function Prepare(nameOnly)
	IN = instance.parameters.IN
	TYPE = instance.parameters.TYPE
	M = instance.parameters.M
	Frame = instance.parameters.Frame
	source = instance.source
	first = source:first() + Frame

	local Flag

	if IN == 1 then
		Flag = "Open"
	elseif IN == 2 then
		Flag = "Close"
	elseif IN == 3 then
		Flag = "Low"
	elseif IN == 4 then
		Flag = "Close"
	elseif IN == 5 then
		Flag = "Median"
	elseif IN == 6 then
		Flag = "Typical"
	elseif IN == 7 then
		Flag = "Weighted"
	end

	local name = profile:id() .. "(" .. source:name() .. ", " .. M .. ", " .. Flag .. ", " .. Frame .. ", " .. TYPE .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	assert(core.indicators:findIndicator(M) ~= nil, M .. " indicator must be installed");
	if IN == 1 then
		MA = core.indicators:create(M, source.open, Frame)
	elseif IN == 2 then
		MA = core.indicators:create(M, source.high, Frame)
	elseif IN == 3 then
		MA = core.indicators:create(M, source.low, Frame)
	elseif IN == 4 then
		MA = core.indicators:create(M, source.close, Frame)
	elseif IN == 5 then
		MA = core.indicators:create(M, source.median, Frame)
	elseif IN == 6 then
		MA = core.indicators:create(M, source.typical, Frame)
	elseif IN == 7 then
		MA = core.indicators:create(M, source.weighted, Frame)
	end
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("MACD", "MACD", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
	if period >= first then
		MA:update(mode)

		if TYPE == "EMA" then
			if MA.DATA[period] > MA.DATA[period - 1] then
				open[period] = math.min(source.open[period], source.close[period])
				close[period] = math.max(source.open[period], source.close[period])
				high[period] = source.high[period]
				low[period] = source.low[period]
			else
				open[period] = math.max(source.open[period], source.close[period])
				close[period] = math.min(source.open[period], source.close[period])
				high[period] = source.high[period]
				low[period] = source.low[period]
			end
		else
			if IN == 1 then
				if source.high[period] > MA.DATA[period] then
					open[period] = math.min(source.open[period], source.close[period])
					close[period] = math.max(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				else
					open[period] = math.max(source.open[period], source.close[period])
					close[period] = math.min(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				end
			elseif IN == 2 then
				if source.close[period] > MA.DATA[period] then
					open[period] = math.min(source.open[period], source.close[period])
					close[period] = math.max(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				else
					open[period] = math.max(source.open[period], source.close[period])
					close[period] = math.min(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				end
			elseif IN == 3 then
				if source.low[period] > MA.DATA[period] then
					open[period] = math.min(source.open[period], source.close[period])
					close[period] = math.max(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				else
					open[period] = math.max(source.open[period], source.close[period])
					close[period] = math.min(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				end
			elseif IN == 4 then
				if source.close[period] > MA.DATA[period] then
					open[period] = math.min(source.open[period], source.close[period])
					close[period] = math.max(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				else
					open[period] = math.max(source.open[period], source.close[period])
					close[period] = math.min(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				end
			elseif IN == 5 then
				if source.median[period] > MA.DATA[period] then
					open[period] = math.min(source.open[period], source.close[period])
					close[period] = math.max(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				else
					open[period] = math.max(source.open[period], source.close[period])
					close[period] = math.min(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				end
			elseif IN == 6 then
				if source.typical[period] > MA.DATA[period] then
					open[period] = math.min(source.open[period], source.close[period])
					close[period] = math.max(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				else
					open[period] = math.max(source.open[period], source.close[period])
					close[period] = math.min(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				end
			elseif IN == 7 then
				if source.weighted[period] > MA.DATA[period] then
					open[period] = math.min(source.open[period], source.close[period])
					close[period] = math.max(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				else
					open[period] = math.max(source.open[period], source.close[period])
					close[period] = math.min(source.open[period], source.close[period])
					high[period] = source.high[period]
					low[period] = source.low[period]
				end
			end
		end
	end
end
