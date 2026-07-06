-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63501 

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

function Init()
	indicator:name("HalfTrend")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Amplitude", "Period", "", 2, 2, 5000)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up Trend color", "Line Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Trend color", "Line Color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width1", "Line Line width", "Line width", 1, 1, 5)
	indicator.parameters:addInteger("style1", "Line Line style", "Line style", core.LINE_SOLID)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first
local source
local Amplitude
local HalfTrend
local High, Low
--local up, dowm;
local Up, Down
local minhighprice, maxlowprice
local trend
-- Routine
function Prepare()
	Amplitude = instance.parameters.Amplitude
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	source = instance.source

	local name = profile:id() .. "(" .. source:name() .. ", " .. Amplitude .. ")"
	instance:name(name)
	if (nameOnly) then
		return
	end
	High = core.indicators:create("MVA", source.high, Amplitude)
	Low = core.indicators:create("MVA", source.low, Amplitude)
	first = Low.DATA:first()
	trend = instance:addInternalStream(0, 0)
	minhighprice = instance:addInternalStream(0, 0);
	maxlowprice = instance:addInternalStream(0, 0);

	HalfTrend = instance:addStream("HalfTrend", core.Line, name .. ".HalfTrend", "HalfTrend", Up, first)
	HalfTrend:setWidth(instance.parameters.width1)
	HalfTrend:setStyle(instance.parameters.style1)
end

-- Indicator calculation routine
function Update(period, mode)
	Low:update(mode)
	High:update(mode)

	if period == first then
		minhighprice[period - 1] = source.low[period]
		maxlowprice[period - 1] = source.high[period]
	end

	if period < first then
		return
	end

	local min, max = mathex.minmax(source, period - Amplitude + 1, period)
	trend[period] = trend[period - 1]
	maxlowprice[period] = maxlowprice[period - 1]
	minhighprice[period] = minhighprice[period - 1]

	if trend[period - 1] == 0 then
		maxlowprice[period] = math.max(min, maxlowprice[period - 1])

		if (High.DATA[period] < maxlowprice[period] and source.close[period] < source.low[period - 1]) then
			trend[period] = 1.0
			minhighprice[period] = max
		end
	else
		minhighprice[period] = math.min(max, minhighprice[period - 1])

		if (Low.DATA[period] > minhighprice[period] and source.close[period] > source.high[period - 1]) then
			trend[period] = 0.0
			maxlowprice[period] = min
		end
	end
	if (trend[period] == 0.0) then
		if (trend[period - 1] ~= 0.0) then
			HalfTrend[period] = HalfTrend[period - 1]
		else
			HalfTrend[period] = math.max(maxlowprice[period], HalfTrend[period - 1])
		end
	else
		if (trend[period - 1] ~= 1.0) then
			HalfTrend[period] = HalfTrend[period - 1]
		else
			HalfTrend[period] = math.min(minhighprice[period], HalfTrend[period - 1])
		end
	end

	if trend[period] == 0 then
		HalfTrend:setColor(period, Up)
	else
		HalfTrend:setColor(period, Down)
	end
end
