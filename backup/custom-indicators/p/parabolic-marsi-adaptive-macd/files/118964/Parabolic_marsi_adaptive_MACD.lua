-- Id: 21193
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66031

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("Parabolic marsi adaptive MACD")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("1. RSI Calculation")
    indicator.parameters:addInteger("RsiPeriod1", "Period", "", 14)
    indicator.parameters:addDouble("Speed1", "Speed", "", 1.2)

    indicator.parameters:addGroup("2. RSI Calculation")
    indicator.parameters:addInteger("RsiPeriod2", "Period", "", 34)
    indicator.parameters:addDouble("Speed2", "Speed", "", 0.8)

    indicator.parameters:addGroup("SAR Calculation")
    indicator.parameters:addDouble("AccStep", "Speed", "", 0.01)
    indicator.parameters:addDouble("AccLimit", "Speed", "", 0.1)

    indicator.parameters:addInteger("SignalPeriod", "Signal Period", "", 9);
    indicator.parameters:addString("SignalMethod", "Method", "", "Median");
    indicator.parameters:addStringAlternative("SignalMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SignalMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SignalMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SignalMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SignalMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SignalMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SignalMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SignalMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SignalMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SignalMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SignalMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SignalMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SignalMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SignalMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SignalMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SignalMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SignalMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SignalMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SignalMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SignalMethod", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("SignalMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SignalMethod", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("SignalMethod", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("SignalMethod", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("SignalMethod", "VAMA", "", "VAMA");
    
    indicator.parameters:addGroup("MACD Style")
    indicator.parameters:addColor("color11", "Up Trend  Up Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("color12", "Up Trend Down Color", "", core.rgb(0, 200, 0))
    indicator.parameters:addColor("color21", "Down Trend  Up Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("color22", "Down Trend Down Color", "", core.rgb(200, 0, 0))
    indicator.parameters:addColor("signal_color", "Signal Color", "", core.colors().Yellow)
    indicator.parameters:addInteger("signal_width", "Signal Width", "", 1, 1, 5)

    indicator.parameters:addGroup("SAR Style")
    indicator.parameters:addColor("color31", "Up Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("color32", "Down Trend Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local RsiPeriod1, Price1, Speed1, RsiPrice1
local RsiPeriod2, Price2, Speed2, RsiPrice2
local first
local source = nil

local AccStep, AccLimit
local Raw = {}
local macdMi
local RSI = {}

local macd;
local signal;
local workMaRsi = {};
local slope;
local sarDn;
local sarUp;
local saraUp;
local saraDn;
local work = {};
local custom_ma;

function CreateRSI(period)
    rsi = {}
    rsi[0] = core.indicators:create("RSI", source.close, period)
    rsi[1] = core.indicators:create("RSI", source.open, period)
    rsi[2] = core.indicators:create("RSI", source.high, period)
    rsi[3] = core.indicators:create("RSI", source.low, period)
    rsi[4] = core.indicators:create("RSI", source.median, period)
    rsi[5] = core.indicators:create("RSI", source.typical, period)
    rsi[6] = core.indicators:create("RSI", source.weighted, period)
    return rsi;
end

-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    RsiPeriod1 = instance.parameters.RsiPeriod1
    Price1 = instance.parameters.Price1
    Speed1 = instance.parameters.Speed1
    RsiPrice1 = instance.parameters.RsiPrice1

    RsiPeriod2 = instance.parameters.RsiPeriod2
    Price2 = instance.parameters.Price2
    Speed2 = instance.parameters.Speed2
    RsiPrice2 = instance.parameters.RsiPrice2

    AccStep = instance.parameters.AccStep
    AccLimit = instance.parameters.AccLimit

    Period = instance.parameters.Period
    Method = instance.parameters.Method

    source = instance.source

    workMaRsi[0] = instance:addInternalStream(0, 0)
    workMaRsi[1] = instance:addInternalStream(0, 0)
    workMaRsi[2] = instance:addInternalStream(0, 0)
    workMaRsi[3] = instance:addInternalStream(0, 0)
    workMaRsi[4] = instance:addInternalStream(0, 0)
    workMaRsi[5] = instance:addInternalStream(0, 0)
    work[0] = instance:addInternalStream(0, 0)
    work[1] = instance:addInternalStream(0, 0)
    work[2] = instance:addInternalStream(0, 0)
    work[3] = instance:addInternalStream(0, 0)
    work[4] = instance:addInternalStream(0, 0)
    work[5] = instance:addInternalStream(0, 0)
    work[6] = instance:addInternalStream(0, 0)
    macdMi = instance:addInternalStream(0, 0);

    RSI[0] = CreateRSI(RsiPeriod1)
    RSI[1] = CreateRSI(RsiPeriod2)

    macd = instance:addStream("MACD" , core.Bar, "MACD","MACD",instance.parameters.color11,0);
    macd:setPrecision(math.max(2, instance.source:getPrecision()));
    signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.signal_color, 0);
    signal:setPrecision(math.max(2, instance.source:getPrecision()));
    signal:setWidth(instance.parameters.signal_width);
    sarDn = instance:addStream("sarDn", core.Dot, name .. ".sarDn", "sarDn", instance.parameters.color32, 0);
    sarDn:setPrecision(math.max(2, instance.source:getPrecision()));
    sarDn:setWidth(instance.parameters.width3);
    sarUp = instance:addStream("sarUp", core.Dot, name .. ".sarUp", "sarUp", instance.parameters.color31, 0);
    sarUp:setPrecision(math.max(2, instance.source:getPrecision()));
    sarUp:setWidth(instance.parameters.width3);
    saraUp = instance:addStream("saraUp", core.Dot, name .. ".saraUp", "saraUp", instance.parameters.color31, 0);
    saraUp:setPrecision(math.max(2, instance.source:getPrecision()));
    saraUp:setWidth(instance.parameters.width3 + 1);
    saraDn = instance:addStream("saraDn", core.Dot, name .. ".saraDn", "saraDn", instance.parameters.color32, 0);
    saraDn:setPrecision(math.max(2, instance.source:getPrecision()));
    saraDn:setWidth(instance.parameters.width3 + 1);

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator")

    custom_ma = core.indicators:create("AVERAGES", macd, instance.parameters.SignalMethod, instance.parameters.SignalPeriod);
end

-- Indicator calculation routine
function Update(period, mode)
    custom_ma:update(mode);

    local i = period;
    local macdHi = iMaRsi(math.floor(source.high[i]), 0, Speed1, i, 0) - iMaRsi(math.floor(source.high[i]), 1, Speed2, i, 1);
    local macdLo = iMaRsi(math.floor(source.low[i]), 0, Speed1, i, 2) - iMaRsi(math.floor(source.low[i]), 1, Speed2, i, 3);
    macdMi[period] = (macdHi + macdLo) * 0.5;
    macd[i] = iMaRsi(math.floor(macdMi[period]), 0, Speed1, i, 4) - iMaRsi(math.floor(macdMi[period]), 1, Speed2, i, 5);
    signal[i] = custom_ma.DATA[i];
    
    if macd[period] > 0 then
        if macd[period]>  macd[period-1] then
            macd:setColor(period, instance.parameters.color11);
        else
            macd:setColor(period, instance.parameters.color12);
        end
    else
        if macd[period]>  macd[period-1] then
            macd:setColor(period, instance.parameters.color21);
        else
            macd:setColor(period, instance.parameters.color22);
        end
    end
    
    local sarClose, sarPosition, sarChange = iParabolic(macd[i], macd[i], AccStep, AccLimit, i);
    if (sarPosition==1) then
        sarUp[i] = sarClose;
        sarDn[i]  = nil;
    else
        sarDn[i] = sarClose;
        sarUp[i]  = nil;
    end
    saraUp[i] = nil;
    saraDn[i] = nil;
    if (sarChange ~= 0) then
        if (sarPosition==1) then
            saraUp[i] = sarClose;
        else
            saraDn[i] = sarClose;
        end
    end
end

function GetPrice(price)
    if price == 6 then
        return source.weighted;
    elseif price == 1 then
        return source.open;
    elseif price == 2 then
        return source.high;
    elseif price == 3 then
        return source.low;
    elseif price == 4 then
        return source.median;
    elseif price == 5 then
        return source.typical;
    end
    return source.close;
end

function iMaRsi(price, rsi_period, speed, period, Index, mode)
    rsi = RSI[rsi_period][price];
    if rsi == null then
        rsi = RSI[rsi_period][0];
    end
    rsi:update(mode)

    local tprice = GetPrice(price)[period];
    if period > 0 and workMaRsi[Index]:hasData(period - 1) then
        workMaRsi[Index][period] = workMaRsi[Index][period - 1] 
            + (speed * math.abs(rsi.DATA[period] / 100.0 - 0.5)) * (tprice - workMaRsi[Index][period - 1]);
    else
        workMaRsi[Index][period] = tprice;
    end

    return workMaRsi[Index][period]
end

local _high = 0
local _low = 1
local _ohigh = 2
local _olow = 3
local _open = 4
local _position = 5
local _af = 6

function iParabolic(high, low, step, limit, i)
    local pClose, pPosition, pChange;
    pChange = 0;
    work[_ohigh][i] = high;
    work[_olow][i] = low;
    if (i < 1) then
        work[_high][i] = high;
        work[_low][i] = low;
        work[_open][i] = high;
        work[_position][i] = -1;
        return;
    end
    work[_open][i]     = work[_open][i-1];
    work[_af][i]       = work[_af][i-1];
    work[_position][i] = work[_position][i-1];
    work[_high][i]     = math.max(work[_high][i-1], high);
    work[_low][i]      = math.min(work[_low][i-1], low);
    if (work[_position][i] == 1) then
        if (low <= work[_open][i]) then
            work[_position][i] = -1;
            pChange = -1;
            pClose  = work[_high][i];
            work[_high][i] = high;
            work[_low][i]  = low;
            work[_af][i]   = step;
            work[_open][i] = pClose + work[_af][i] * (work[_low][i] - pClose);
            if (work[_open][i] < work[_ohigh][i]) then
                work[_open][i] = work[_ohigh][i];
            end
            if (work[_open][i] < work[_ohigh][i-1]) then
                work[_open][i] = work[_ohigh][i-1];
            end
        else
            pClose = work[_open][i];
            if (work[_high][i] > work[_high][i-1] and work[_af][i] < limit) then
                work[_af][i] = math.min(work[_af][i] + step, limit);
            end
            work[_open][i] = pClose + work[_af][i] * (work[_high][i] - pClose);
            if (work[_open][i]>work[_olow][i]) then
                work[_open][i] = work[_olow][i];
            end
            if (work[_open][i]>work[_olow][i-1]) then
                work[_open][i] = work[_olow][i-1];
            end
        end
    else
        if (high>=work[_open][i]) then
            work[_position][i] = 1;
            pChange = 1;
            pClose  = work[_low][i];
            work[_low][i]  = low;
            work[_high][i] = high;
            work[_af][i]   = step;
            work[_open][i] = pClose + work[_af][i]*(work[_high][i]-pClose);
            if (work[_open][i]>work[_olow][i]) then
                work[_open][i] = work[_olow][i];
            end
            if (work[_open][i]>work[_olow][i-1]) then
                work[_open][i] = work[_olow][i-1];
            end
        else
            pClose = work[_open][i];
            if (work[_low][i]<work[_low][i-1] and work[_af][i]<limit) then
                work[_af][i] = math.min(work[_af][i]+step,limit);
            end
            work[_open][i] = pClose + work[_af][i]*(work[_low][i]-pClose);
            if (work[_open][i]<work[_ohigh][i]) then
                work[_open][i] = work[_ohigh][i];
            end
            if (work[_open][i]<work[_ohigh][i-1]) then
                work[_open][i] = work[_ohigh][i-1];
            end
        end
    end
    pPosition = work[_position][i];
    return pClose, pPosition, pChange;
end
