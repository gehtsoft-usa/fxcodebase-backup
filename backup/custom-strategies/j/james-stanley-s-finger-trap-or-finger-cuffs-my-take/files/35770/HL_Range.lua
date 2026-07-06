-- Id: 6835
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=20399

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
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

function Init()
	-- set the indicator name
	indicator:name("Alokasi's High/Low Range Lines")
	indicator:description("Plots High/Low lines based on a lookback period with a specified delay")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	-- parameters needed for calculation
	indicator.parameters:addInteger("nLB", "Lookback period", "", 24, 2, 100000)
	indicator.parameters:addInteger("nD", "Delay period", "", 3, 2, 100000)
	indicator.parameters:addString(
		"rangeType",
		"Range type",
		"Take the ranges from the candle bodies or from the wicks.",
		"Bodies"
	)
	indicator.parameters:addStringAlternative(
		"rangeType",
		"Bodies",
		"Determine the range from the candle bodies",
		"Bodies"
	)
	indicator.parameters:addStringAlternative(
		"rangeType",
		"Wicks",
		"Determine the range from the full length of the candle, including wicks",
		"Wicks"
	)
	-- display parameters
	indicator.parameters:addColor("HL_color", "Indicator line color", "", core.rgb(128, 128, 128))
end

local nLB, nD
local source
local high, low
local fpHL
local iHigh, iLow

function Prepare(nameOnly)
	nLB = instance.parameters.nLB
	nD = instance.parameters.nD
	source = instance.source
	rangeType = instance.parameters.rangeType

	-- Base name of the indicator
	local name =
		profile:id() .. "(" .. source:name() .. ", " .. nLB .. ", " .. nD .. ", " .. instance.parameters.rangeType .. ")"
	instance:name(name)
	if nameOnly then
		return;
	end

	-- internal streams
	if rangeType == "Bodies" then
		iHigh = instance:addInternalStream(source:first())
		iLow = instance:addInternalStream(source:first())
	end

	-- output streams
	fpHL = source:first() + nLB + nD - 1
	high = instance:addStream("high", core.Line, name .. ".High", "High", instance.parameters.HL_color, fpHL)
	low = instance:addStream("low", core.Line, name .. ".Low", "Low", instance.parameters.HL_color, fpHL)
end

function Update(period, mode)
	if rangeType == "Bodies" then
		iHigh[period] = math.max(source.close[period], source.open[period])
		iLow[period] = math.min(source.close[period], source.open[period])
	end

	if period > fpHL then
		if rangeType == "Bodies" then
			high[period] = mathex.max(iHigh, period - nLB - nD, period - nD)
			low[period] = mathex.min(iLow, period - nLB - nD, period - nD)
		else
			high[period] = mathex.max(source.high, period - nLB - nD, period - nD)
			low[period] = mathex.min(source.low, period - nLB - nD, period - nD)
		end
	end
end
