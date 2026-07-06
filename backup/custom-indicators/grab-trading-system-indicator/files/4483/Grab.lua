-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2164

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
	indicator:name("GRAB")
	indicator:description("GRAB")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("Frame", "MA Frame", "", 34, 2, 1000)
	indicator.parameters:addString("M", "Method for avegage", "", "EMA")
	indicator.parameters:addStringAlternative("M", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("M", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("M", "LWMA", "", "LWMA")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("U1", "Up in Up Trend Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("U2", "Down in Up Trend Color", "", core.rgb(0, 200, 0))
	indicator.parameters:addColor("D1", "Up in Down Trend Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("D2", "Down in Down Trend Color", "", core.rgb(200, 0, 0))
	indicator.parameters:addColor("N1", "Up in Neutral Trend Color", "", core.rgb(128, 128, 128))
	indicator.parameters:addColor("N2", "Down in Neutral Trend Color", "", core.rgb(100, 100, 100))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Frame = nil
local M = nil

local open = nil
local close = nil
local high = nil
local low = nil

--local MA = nil;
local HMA = nil
local LMA = nil

local U1, U2, D1, D2, N1, N2

function Prepare(nameOnly)
	M = instance.parameters.M
	Frame = instance.parameters.Frame
	source = instance.source

	U1 = instance.parameters.U1
	U2 = instance.parameters.U2
	D1 = instance.parameters.D1
	D2 = instance.parameters.D2
	N1 = instance.parameters.N1
	N2 = instance.parameters.N2

	local name = profile:id() .. "(" .. source:name() .. ", " .. M .. ", " .. Frame .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	assert(core.indicators:findIndicator(M) ~= nil, M .. " indicator must be installed")
	HMA = core.indicators:create(M, source.high, Frame)
	LMA = core.indicators:create(M, source.low, Frame)

	first = HMA.DATA:first()

	open = instance:addStream("open", core.Line, name, "", core.rgb(255, 0, 0), first)
	high = instance:addStream("high", core.Line, name, "", core.rgb(255, 0, 0), first)
	low = instance:addStream("low", core.Line, name, "", core.rgb(255, 0, 0), first)
	close = instance:addStream("close", core.Line, name, "", core.rgb(255, 0, 0), first)
	instance:createCandleGroup("", "", open, high, low, close)
end

-- Indicator calculation routine
function Update(period, mode)
	HMA:update(mode)
	LMA:update(mode)

	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		return
	end

	if source.close[period] > math.max(HMA.DATA[period], LMA.DATA[period]) then
		if source.close[period] > source.open[period] then
			open:setColor(period, U1)
		else
			open:setColor(period, U2)
		end
	elseif source.close[period] < math.min(HMA.DATA[period], LMA.DATA[period]) then
		if source.close[period] > source.open[period] then
			open:setColor(period, D1)
		else
			open:setColor(period, D2)
		end
	elseif
		source.close[period] > math.min(HMA.DATA[period], LMA.DATA[period]) and
			source.close[period] < math.max(HMA.DATA[period], LMA.DATA[period])
	 then
		if source.close[period] > source.open[period] then
			open:setColor(period, N1)
		else
			open:setColor(period, N1)
		end
	end
end
