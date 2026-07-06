-- Id: 19823
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65403

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("Jurik_MACD indicator")
    indicator:description("v.2 2018-08-12")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("FastJma", "Fast Jma", "", 12)
    indicator.parameters:addDouble("FastPhase", "Fast Phase", "", 0)
    indicator.parameters:addBoolean("FastDouble", "Fast Double", "", false)
    indicator.parameters:addInteger("SlowJma", "Slow Jma", "", 26)
    indicator.parameters:addDouble("SlowPhase", "Slow Phase", "", 0)
    indicator.parameters:addBoolean("SlowDouble", "Slow Double", "", false)
    indicator.parameters:addInteger("SignalJma", "Signal Jma", "", 9)
    indicator.parameters:addDouble("SignalPhase", "Signal Phase", "", 0)
    indicator.parameters:addBoolean("SignalDouble", "Signal Double", "", false)

    indicator.parameters:addString("Price", "Price", "", "Close")
    indicator.parameters:addStringAlternative("Price", "Close", "", "Close")
    indicator.parameters:addStringAlternative("Price", "Open", "", "Open")
    indicator.parameters:addStringAlternative("Price", "High", "", "High")
    indicator.parameters:addStringAlternative("Price", "Low", "", "Low")
    indicator.parameters:addStringAlternative("Price", "Median", "", "Median")
    indicator.parameters:addStringAlternative("Price", "Typical", "", "Typical")
    indicator.parameters:addStringAlternative("Price", "Weighted", "", "Weighted")
    indicator.parameters:addStringAlternative("Price", "Average (high+low+open+close)/4", "", "Average (high+low+open+close)/4")
    indicator.parameters:addStringAlternative("Price", "Average median body (open+close)/2", "", "Average median body (open+close)/2")
    indicator.parameters:addStringAlternative("Price", "Trend biased price", "", "Trend biased price")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi close", "", "Heiken ashi close")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi open", "", "Heiken ashi open")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi high", "", "Heiken ashi high")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi low", "", "Heiken ashi low")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi median", "", "Heiken ashi median")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi typical", "", "Heiken ashi typical")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi weighted", "", "Heiken ashi weighted")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi average", "", "Heiken ashi average")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi median body", "", "Heiken ashi median body")
    indicator.parameters:addStringAlternative("Price", "Heiken ashi trend biased price", "", "Heiken ashi trend biased price")

    indicator.parameters:addBoolean("HistogramOnSlope", "Histogram On Slope", "", true)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("MACDclr", "MACD Color", "MACD Color", core.rgb(0, 0, 255))
    indicator.parameters:addColor("Sclr", "Signal Color", "Signal Color", core.rgb(255, 255, 0))
    indicator.parameters:addColor("H1clr", "Histogram 1 Color", "Histogram 1 Color", core.rgb(128, 0, 0))
    indicator.parameters:addColor("H2clr", "Histogram 2 Color", "Histogram 2 Color", core.rgb(255, 0, 0))
    indicator.parameters:addColor("H3clr", "Histogram 3 Color", "Histogram 3 Color", core.rgb(0, 128, 0))
    indicator.parameters:addColor("H4clr", "Histogram 4 Color", "Histogram 4 Color", core.rgb(0, 255, 0))
end

local first
local source = nil
local FastJma
local FastPhase
local FastDouble
local SlowJma
local SlowPhase
local SlowDouble
local SignalJma
local SignalPhase
local SignalDouble
local Price
local HistogramOnSlope
local JMACD, Signal, Hist
local trend, slope

local HAopen, HAclose, HAhigh, HAlow

local bsmax = 5
local bsmin = 6
local volty = 7
local vsum = 8
local avolty = 9

local wrk = {}

function GetPrice(index)
    if Price == "Close" then
        return source.close[index]
    elseif Price == "Open" then
        return source.open[index]
    elseif Price == "High" then
        return source.high[index]
    elseif Price == "Low" then
        return source.low[index]
    elseif Price == "Median" then
        return (source.high[index] + source.low[index]) / 2
    elseif Price == "Typical" then
        return (source.high[index] + source.low[index] + source.close[index]) / 3
    elseif Price == "Weighted" then
        return (source.high[index] + source.low[index] + 2 * source.close[index]) / 4
    elseif Price == "Average (high+low+open+close)/4" then
        return (source.high[index] + source.low[index] + source.open[index] + source.close[index]) / 4
    elseif Price == "Average median body (open+close)/2" then
        return (source.open[index] + source.close[index]) / 2
    elseif Price == "Trend biased price" then
        if source.close[index] > source.open[index] then
            return (source.high[index] + source.close[index]) / 2
        else
            return (source.low[index] + source.close[index]) / 2
        end
    elseif Price == "Heiken ashi close" then
        return HAclose[index]
    elseif Price == "Heiken ashi open" then
        return HAopen[index]
    elseif Price == "Heiken ashi high" then
        return HAhigh[index]
    elseif Price == "Heiken ashi low" then
        return HAlow[index]
    elseif Price == "Heiken ashi median" then
        return (HAhigh[index] + HAlow[index]) / 2
    elseif Price == "Heiken ashi typical" then
        return (HAhigh[index] + HAlow[index] + HAclose[index]) / 3
    elseif Price == "Heiken ashi weighted" then
        return (HAhigh[index] + HAlow[index] + 2 * HAclose[index]) / 4
    elseif Price == "Heiken ashi average" then
        return (HAclose[index] + HAopen[index] + HAhigh[index] + HAlow[index]) / 4
    elseif Price == "Heiken ashi median body" then
        return (HAopen[index] + HAclose[index]) / 2
    else
        if HAclose[index] > HAopen[index] then
            return (HAhigh[index] + HAclose[index]) / 2
        else
            return (HAlow[index] + HAclose[index]) / 2
        end
    end
end

function iSmooth(price, length, phase, i, s)
    if length <= 1 then
        return price
    end

    local r = i
    local k
    if r == first then
        for k = 0, 6, 1 do
            wrk[k + s][r] = price
        end
        for k = 7, 9, 1 do
            wrk[k + s][r] = 0
        end

        return price
    end

    local len1 = math.max(math.log(math.sqrt(0.5 * (length - 1))) / math.log(2) + 2, 0)
    local pow1 = math.max(len1 - 2, 0.5)
    local del1 = price - wrk[bsmax + s][r - 1]
    local del2 = price - wrk[bsmin + s][r - 1]
    local div = 1 / (10 + 10 * (math.min(math.max(length - 10, 0), 100)) / 100)
    local forBar = math.min(r, 10)

    wrk[volty + s][r] = 0
    if math.abs(del1) > math.abs(del2) then
        wrk[volty + s][r] = math.abs(del1)
    elseif math.abs(del1) < math.abs(del2) then
        wrk[volty + s][r] = math.abs(del2)
    end

    wrk[vsum + s][r] = wrk[vsum + s][r - 1] + (wrk[volty + s][r] - wrk[volty + s][r - forBar]) * div
    wrk[avolty + s][r] = wrk[avolty + s][r - 1] + (2 / (math.max(4 * length, 30) + 1)) * (wrk[vsum + s][r] - wrk[avolty + s][r - 1])

    local dVolty
    if wrk[avolty + s][r] > 0 then
        dVolty = wrk[volty + s][r] / wrk[avolty + s][r]
    else
        dVolty = 0
    end
    if (dVolty > math.pow(len1, 1 / pow1)) then
        dVolty = math.pow(len1, 1 / pow1)
    end

    if dVolty < 1 then
        dVolty = 1
    end

    local pow2 = math.pow(dVolty, pow1)
    local len2 = math.sqrt(0.5 * (length - 1)) * len1
    local Kv = math.pow(len2 / (len2 + 1), math.sqrt(pow2))

    if del1 > 0 then
        wrk[bsmax + s][r] = price
    else
        wrk[bsmax + s][r] = price - Kv * del1
    end

    if del2 < 0 then
        wrk[bsmin + s][r] = price
    else
        wrk[bsmin + s][r] = price - Kv * del2
    end

    local R = math.max(math.min(phase, 100), -100) / 100 + 1.5
    local beta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    local alpha = math.pow(beta, pow2)

    wrk[0 + s][r] = price + alpha * (wrk[0 + s][r - 1] - price)
    wrk[1 + s][r] = (price - wrk[0 + s][r]) * (1 - beta) + beta * wrk[1 + s][r - 1]
    wrk[2 + s][r] = (wrk[0 + s][r] + R * wrk[1 + s][r])
    wrk[3 + s][r] = (wrk[2 + s][r] - wrk[4 + s][r - 1]) * math.pow((1 - alpha), 2) + math.pow(alpha, 2) * wrk[3 + s][r - 1]
    wrk[4 + s][r] = (wrk[4 + s][r - 1] + wrk[3 + s][r])

    return wrk[4 + s][r]
end

function Prepare(nameOnly)
    source = instance.source
    FastJma = instance.parameters.FastJma
    FastPhase = instance.parameters.FastPhase
    FastDouble = instance.parameters.FastDouble
    SlowJma = instance.parameters.SlowJma
    SlowPhase = instance.parameters.SlowPhase
    SlowDouble = instance.parameters.SlowDouble
    SignalJma = instance.parameters.SignalJma
    SignalPhase = instance.parameters.SignalPhase
    SignalDouble = instance.parameters.SignalDouble
    Price = instance.parameters.Price
    HistogramOnSlope = instance.parameters.HistogramOnSlope
    first = source:first() + 2

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    HAopen = instance:addInternalStream(first, 0)
    HAclose = instance:addInternalStream(first, 0)
    HAhigh = instance:addInternalStream(first, 0)
    HAlow = instance:addInternalStream(first, 0)

    trend = instance:addInternalStream(first, 0)
    slope = instance:addInternalStream(first, 0)

    JMACD = instance:addStream("JMACD", core.Line, name .. ".JMACD", "JMACD", instance.parameters.MACDclr, first)
    JMACD:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, first)
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Hist = instance:addStream("Hist", core.Bar, name .. ".Hist", "Hist", instance.parameters.H1clr, first)
    Hist:setPrecision(math.max(2, instance.source:getPrecision()));

    for i = 0, 59 do
        wrk[i] = instance:addInternalStream(first, 0);
    end
end

function Update(period, mode)
    if period >= first then
        if period == first then
            HAopen[period] = (source.open[period] + source.close[period]) / 2
        else
            HAopen[period] = (HAopen[period - 1] + HAclose[period - 1]) / 2
        end
        HAclose[period] = (source.open[period] + source.close[period] + source.low[period] + source.high[period]) / 4
        HAlow[period] = math.min(source.low[period], HAopen[period], HAclose[period])
        HAhigh[period] = math.max(source.high[period], HAopen[period], HAclose[period])

        JMACD[period] =
            iDSmooth(GetPrice(period), FastJma, FastPhase, FastDouble, period, 0) -
            iDSmooth(GetPrice(period), SlowJma, SlowPhase, SlowDouble, period, 20)

        Signal[period] = iDSmooth(JMACD[period], SignalJma, SignalPhase, SignalDouble, period, 40)

        trend[period] = trend[period - 1]
        slope[period] = slope[period - 1]

        if JMACD[period] > 0 then
            trend[period] = 1
        elseif JMACD[period] < 0 then
            trend[period] = -1
        end

        if JMACD[period] > JMACD[period - 1] then
            slope[period] = 1
        elseif JMACD[period] < JMACD[period - 1] then
            slope[period] = -1
        end

        Hist[period] = JMACD[period]

        if HistogramOnSlope then
            if trend[period] > 0 and slope[period] > 0 then
                Hist:setColor(period, instance.parameters.H1clr)
            elseif trend[period] > 0 and slope[period] < 0 then
                Hist:setColor(period, instance.parameters.H2clr)
            elseif trend[period] < 0 and slope[period] < 0 then
                Hist:setColor(period, instance.parameters.H3clr)
            else
                Hist:setColor(period, instance.parameters.H4clr)
            end
        else
            if trend[period] > 0 then
                Hist:setColor(period, instance.parameters.H1clr)
            else
                Hist:setColor(period, instance.parameters.H3clr)
            end
        end
    end
end

function iDSmooth(_price, _length, _phase, _double, _index, _s)
    if _double then
        return iSmooth(
            iSmooth(_price, math.sqrt(_length), _phase, _index, _s),
            math.sqrt(_length),
            _phase,
            _index,
            _s + 10
        )
    else
        return iSmooth(_price, _length, _phase, _index, _s)
    end
end
