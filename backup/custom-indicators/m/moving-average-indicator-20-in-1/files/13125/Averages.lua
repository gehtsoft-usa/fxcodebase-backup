--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Averages indicator");
    indicator:description("Averages indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local MainBuff = nil;
local ColorMode, UPclr, DNclr;
local updateParams;
local UpdateFunction;
local name;


function Prepare(onlyName)
    source = instance.source;
    local Method = instance.parameters.Method;

    if Method == "IE/2" then
        Method = "IE_2";
    end

    Period = instance.parameters.Period;
    ColorMode = instance.parameters.ColorMode;

    if _G[Method .. "Init"] == nil or _G[Method .. "Update"] == nil then
        assert(false, "The method " .. Method .. " is unknown");
    end

    name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.Method .. "," .. Period .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    ColorMode = instance.parameters.ColorMode;
    UPclr = instance.parameters.UPclr;
    DNclr = instance.parameters.DNclr;

    updateParams = _G[Method .. "Init"](source, Period);
    UpdateFunction = _G[Method .. "Update"];

    MainBuff = instance:addStream("MainBuff", core.Line, name .. ".MA", "MA", instance.parameters.MainClr, updateParams.first);
    MainBuff:setWidth(instance.parameters.widthLinReg);
    MainBuff:setStyle(instance.parameters.styleLinReg);

    first = updateParams.first;
    updateParams.buffer = MainBuff;
end

function Update(period, mode)
    if period >= first then
        UpdateFunction(updateParams, period, mode);
        if ColorMode then
            if MainBuff[period] > MainBuff[period - 1] then
                MainBuff:setColor(period, UPclr);
            elseif MainBuff[period] < MainBuff[period - 1] then
                MainBuff:setColor(period, DNclr);
            end
        end
    end
end

-- =============================================================================
-- Implementations
-- =============================================================================


--
-- Simple moving average
--
function MVAInit(source, n)
    local  p = {};
    p.first = source:first() + n - 1;
    p.n = n;
    p.offset = n - 1;
    p.source = source;
    return p;
end

function MVAUpdate(params, period, mode)
    params.buffer[period] = mathex.avg(params.source, period - params.offset, period);
end

--
-- Exponential moving average
--
function EMAInit(source, n)
    local p = {};
    p.first = source:first();
    p.k = 2.0 / (n + 1.0);
    p.source = source;
    return p;
end

function EMAUpdate(params, period, mode)
    if period == params.first then
        params.buffer[period] = params.source[period];
    else
        params.buffer[period] = (1 - params.k) * params.buffer[period - 1] + params.k * params.source[period];
    end
end

--
-- Kaufman moving average
--
function KAMAInit(source, n)
    local p = {};
    p.first = source:first()+1;
    p.first1 = source:first()+n;
    p.n=n;
    p.source = source;
    p.INT = instance:addInternalStream(p.first, 0);
    return p;
end

function KAMAUpdate(params, period, mode)
    params.INT[period] = math.abs(params.source[period]-params.source[period-1]);
    params.buffer[period]=nil;
    if period>=params.first1 then
        local value=0;
        if period==params.first1 then
         value=params.source[period];
        else
         value=params.buffer[period-1];
        end
        local er=0;
        er=core.sum(params.INT,period-params.n+1,period);
        if er~=0 then
         er=math.abs(params.source[period]-params.source[period-params.n+1])/er;
        end
        local sc=er*0.6015+0.0645;
        sc=sc*sc;
        params.buffer[period]=value+sc*(params.source[period]-value);
    end
end

--
-- Linear-weighted moving average
--
function LWMAInit(source, n)
    local  p = {};
    p.first = source:first() + n - 1;
    p.n = n;
    p.offset = n - 1;
    p.source = source;
    return p;
end

function LWMAUpdate(params, period, mode)
    params.buffer[period] = mathex.lwma(params.source, period - params.offset, period);
end

--
-- Wilders smooting average
--
function WilderInit(source, n)
    local p = {};
    p.n = n;
    p.n1 = 2 * n - 1;
    p.k = 2.0 / (p.n1 + 1.0);
    p.first = source:first() + p.n1 - 1;
    p.source = source;
    return p;
end

function WilderUpdate(params, period, mode)
    if period == params.first then
        params.buffer[period] = mathex.avg(source, period - params.n + 1, period);
    else
        params.buffer[period] = ((params.source[period] - params.buffer[period - 1]) * params.k) + params.buffer[period - 1];
    end
end

--
-- SMMA (smoothed moving average)
--
function SMMAInit(source, n)
    local  p = {};
    p.first = source:first() + n - 1;
    p.n = n;
    p.source = source;
    return p;
end

function SMMAUpdate(params, period, mode)
    if period == params.first then
        params.buffer[period] = mathex.avg(params.source, period - params.n + 1, period);
    else
        params.buffer[period] = (params.buffer[period - 1] * (params.n - 1) + params.source[period]) / params.n;
    end
end

--
-- GeoMean
--
function GeoMeanInit(source, n)
    local  p = {};
    p.first = source:first() + n - 1;
    p.n = n;
    p.exp = 1 / n;
    p.offset = n - 1;
    p.source = source;
    return p;
end

function GeoMeanUpdate(params, period, mode)
    local i, s, src;
    s = 1;
    src = params.source;
    for i = period - params.offset, period, 1 do
        s = s * src[i];
    end
    params.buffer[period] = math.pow(s, params.exp);
end

--
-- SineWMA: Sine weighted moving average
--
function SineWMAInit(source, n)
    local p = {};
    p.source = source;
    p.n = n;
    p.offset = n - 1;
    p.sine = {};
    p.first = source:first() + n - 1;

    local i, w;
    w = 0;
    for i = 1, n, 1 do
        p.sine[i] = math.sin(math.pi * (n - i + 1) / (n + 1));
        w = w + p.sine[i];
    end

    p.weight = w;
    p.alwaysZero = (w == 0);

    return p;
end

function SineWMAUpdate(params, period, mode)
    local sum = 0;
    if not params.alwaysZero then
        local src = params.source;
        local sine = params.sine;
        local n = params.n;
        local p = period - n;
        for i = 1, n, 1 do
            sum = sum + src[p + i] * sine[i];
        end
        sum = sum / params.weight;
    end
    params.buffer[period] = sum;
end

--
-- TriMA: Triangular Moving Average
--
function TriMAInit(source, n)
    local p = {};
    p.source = source;
    p.n = n;
    p.len = math.ceil((n + 1) / 2);
    p.first1 = source:first() + p.len - 1;
    p.mabuffer = instance:addInternalStream(p.first1, 0);
    p.first = p.first1 + p.len - 1;
    p.offset = p.len - 1;
    return p;
end

function TriMAUpdate(params, period, mode)
    local off = params.offset;
    if period == params.first then
        -- fill sma's before the first value
        local i;
        for i = params.first1, params.first, 1 do
            params.mabuffer[i] = mathex.avg(params.source, i - off, i);
        end
    else
        params.mabuffer[period] = mathex.avg(params.source, period - off, period);
    end
    params.buffer[period] = mathex.avg(params.mabuffer, period - off, period);
end

--
-- LSMA: Least Square Moving Average (or EPMA, Linear Regression Line)
--
function LSMAInit(source, n)
    local p = {};
    p.source = source;
    p.n = n;
    p.offset = p.n - 1;
    p.first = source:first() + n - 1;
    return p;
end

function LSMAUpdate(params, period, mode)
    params.buffer[period] = mathex.lreg(params.source, period - params.offset, period);
end

--
-- HMA: Hull Moving Average by Alan Hull
--
function HMAInit(source, n)
    assert(n >= 4, "n must be at least 4");
    local p = {};
    p.source = source;
    p.n = n;
    p.len = n;
    p.halflen = math.max(math.floor(p.len / 2), 1);

    p.first1 = source:first() + p.halflen - 1;
    p.lwma1 = instance:addInternalStream(p.first1, 0);

    p.first2 = source:first() + p.len - 1;
    p.lwma2 = instance:addInternalStream(p.first2, 0);

    p.first3 = math.max(p.first1, p.first2);
    p.tmp = instance:addInternalStream(p.first3, 0);

    p.len1 = math.max(math.floor(math.sqrt(n)), 1) - 1;
    p.first = p.first3 + p.len1 - 1;
    return p;
end

function HMAUpdate(params, period, mode)
    if period == params.first then
        local i;
        local src = params.source;

        for i = params.first1, period, 1 do
            params.lwma1[i] = mathex.lwma(params.source, i - params.halflen + 1, i);
        end

        for i = params.first2, period, 1 do
            params.lwma2[i] = mathex.lwma(params.source, i - params.len + 1, i);
        end

        for i = params.first3, period, 1 do
            params.tmp[i] = 2 * params.lwma1[i] - params.lwma2[i];
        end
    else
        params.lwma1[period] = mathex.lwma(params.source, period - params.halflen + 1, period);
        params.lwma2[period] = mathex.lwma(params.source, period - params.len + 1, period);
        params.tmp[period] = 2 * params.lwma1[period] - params.lwma2[period];
    end
    params.buffer[period] = mathex.lwma(params.tmp, period - params.len1 + 1, period);
end

--
-- Zero-lag EMA
--
function ZeroLagEMAInit(source, n)
    local p = {};
    p.alpha = 2.0 / (n + 1.0);
    p.lag = math.ceil((n - 1) / 2);
    p.first = source:first() + p.lag;
    p.source = source;
    return p;
end

function ZeroLagEMAUpdate(params, period, mode)
    if period == params.first then
        params.buffer[period] = params.source[period];
    else
        params.buffer[period] = params.alpha * (2 * params.source[period] - params.source[period - params.lag]) +
                                (1 - params.alpha) * params.buffer[period - 1];
    end
end

--
-- DEMA: Double Exponential Moving Average (DEMA)
-- DEMA(n) = 2 * EMA(n) - EMA(EMA(n), n)
--
function DEMAInit(source, n)
    local p = {};
    p.first = source:first();
    p.k = 2.0 / (n + 1.0);
    p.ema = instance:addInternalStream(p.first, 0);
    p.ema2 = instance:addInternalStream(p.first, 0);
    p.source = source;
    return p;
end

function DEMAUpdate(params, period, mode)
    if period == params.first then
        params.ema[period] = params.source[period];
        params.ema2[period] = params.source[period];
        params.buffer[period] = params.source[period];
    else
        local ema, ema2, k, k1;
        ema = params.ema;
        ema2 = params.ema2;
        k = params.k;
        k1 = 1 - params.k;

        ema[period] = k1 * ema[period - 1] + k * params.source[period];
        ema2[period] = k1 * ema2[period - 1] + k * ema[period];
        params.buffer[period] = 2 * ema[period] - ema2[period];
    end
end

--
-- T3: T3 by T.Tillson
-- T3 = DEMA(DEMA(DEMA)))
--
function T3Init(source, n)
    local p = {};

    p.dema1 = DEMAInit(source, n);
    p.dema1.buffer = instance:addInternalStream(p.dema1.first, 0);
    p.dema2 = DEMAInit(p.dema1.buffer, n);
    p.dema2.buffer = instance:addInternalStream(p.dema2.first, 0);
    p.dema3 = DEMAInit(p.dema2.buffer, n);
    p.dema3.buffer = nil;
    p.first = p.dema3.first;
    return p;
end

function T3Update(params, period, mode)
    if params.dema3.buffer == nil then
        params.dema3.buffer = params.buffer;
    end
    DEMAUpdate(params.dema1, period, mode);
    DEMAUpdate(params.dema2, period, mode);
    DEMAUpdate(params.dema3, period, mode);
end

--
-- ITrend
--
function ITrendInit(source, n)
    local p = {}, alpha;
    p.first = source:first() + 2;
    p.first7 = p.first + 7;

    alpha = 2.0 / (n + 1.0);
   
    p.k = alpha;
    p.k1 = (alpha - alpha * alpha / 4);
    p.k2 = 0.5 * alpha * alpha;
    p.k3 = (alpha - 0.75 * alpha * alpha);
    p.k4 = 2 * (1 - alpha);
    p.k5 = (1 - alpha) * (1 - alpha);
   
    p.source = source;
    return p;
end

function ITrendUpdate(params, period, mode)
    local src = params.source;
    if period <= params.first7 then
        params.buffer[period] = (src[period] + 2 * src[period - 1] + src[period - 2]) / 4;
    else
        params.buffer[period] = params.k1 * src[period] + params.k2 * src[period - 1] - params.k3 * src[period - 2] +
                                params.k4 * params.buffer[period - 1] - params.k5 * params.buffer[period - 2];
    end
end

--
-- Median: the floating median
--
function MedianInit(source, n)
    local p = {};
    p.source = source;
    p.first = source:first() + n - 1;
    p.middle = math.ceil((n - 1) / 2);
    if p.middle * 2 == (n - 1) then
        p.even = true;
    else
        p.even = false;
    end
    p.array = {};
    p.n = n;
    local i = 1, n, 1 do
        p.array[i] = 0;
    end
    return p;
end

function MedianUpdate(params, period, mode)
    local i, arr, n, src;
    arr = params.array;
    n = params.n;
    src = params.source;
    for i = 1, n, 1 do
        arr[i] = src[period - n + i];
    end
    table.sort(arr);
    if params.even then
        params.buffer[period] = arr[params.middle];
    else
        params.buffer[period] = (arr[params.middle] + arr[params.middle + 1]) / 2;
    end
end

--
-- REMA - Regularized moving average
--          Rp + alpha*(close - Rp) + lambda*(Rp + (Rp-Rpp))
--   REMA = ------------------------------------------------
--                    1 + lambda
-- Lamda is 0.5
--
function REMAInit(source, n)
    local p = {};
    p.first = source:first();
    p.first3 = source:first() + 2;
    p.k = 2.0 / (n + 1.0);
    p.source = source;
    return p;
end

function REMAUpdate(params, period, mode)
    if period <= params.first3 then
        params.buffer[period] = params.source[period];
    else
        local rp = params.buffer[period - 1];
        local rpp = params.buffer[period - 2];
        params.buffer[period] = (params.k * params.source[period] + (1 - params.k) * rp + 0.5 * (2 * rp - rpp)) / 1.5;
    end
end

--
-- ILRS: Integral of Linear Regression Slope
-- ILRS = LINEARREGSLOPE(PRICE, PERIOD) + AVERAGE(PRICE, PERIOD);
--
function ILRSInit(source, n)
    local p = {};
    p.source = source;
    p.n = n;
    p.offset = p.n - 1;
    p.first = source:first() + n - 1;
    return p;
end

function ILRSUpdate(params, period, mode)
    local from = period - params.offset;
    params.buffer[period] = mathex.lregSlope(params.source, from, period) + mathex.avg(params.source, from, period);
end

--
-- IE/2:
-- IE/2 = (ILRS + LSMA) / 2
--
function IE_2Init(source, n)
    local p = {};
    p.source = source;
    p.n = n;
    p.offset = p.n - 1;
    p.first = source:first() + n - 1;
    return p;
end

function IE_2Update(params, period, mode)
    local from = period - params.offset;
    params.buffer[period] = (mathex.lregSlope(params.source, from, period) + mathex.avg(params.source, from, period) + mathex.lreg(params.source, from, period)) / 2;
end

--
-- TriMA: Triangular Moving Average generalized
--
function TriMAgenInit(source, n)
    local p = {};
    p.source = source;
    p.n = n;
    p.len = math.floor((n + 1) / 2);
    p.len2 = math.ceil((n + 1) / 2);
    p.first1 = source:first() + p.len - 1;
    p.mabuffer = instance:addInternalStream(p.first1, 0);
    p.first = p.first1 + p.len2 - 1;
    p.offset = p.len - 1;
    p.offset2 = p.len2 - 1;
    return p;
end

function TriMAgenUpdate(params, period, mode)
    local off = params.offset;
    if period == params.first then
        -- fill sma's before the first value
        local i;
        for i = params.first1, params.first, 1 do
            params.mabuffer[i] = mathex.avg(params.source, i - off, i);
        end
    else
        params.mabuffer[period] = mathex.avg(params.source, period - off, period);
    end
    params.buffer[period] = mathex.avg(params.mabuffer, period - params.offset2, period);
end

--
-- JSmooth
--
--
function JSmoothInit(source, n)
    local p = {};
    p.first = source:first();
    p.first3 = source:first() + 3;
    p.alpha = 0.45 * (n - 1) / (0.45 * (n - 1) + 2);
    p.alpha1 = 1 - p.alpha;
    p.alpha1_2 = math.pow((1 - p.alpha), 2);
    p.alpha_2 = math.pow(p.alpha, 2)
    p.a1 = instance:addInternalStream(source:first(), 0);
    p.a2 = instance:addInternalStream(source:first(), 0);
    p.a3 = instance:addInternalStream(source:first(), 0);
    p.a4 = instance:addInternalStream(source:first(), 0);
    p.source = source;
    return p;
end

function JSmoothUpdate(params, period, mode)
    if period < params.first3 then
        params.a1[period] = params.source[period];
        params.a2[period] = 0;
        params.a3[period] = params.source[period];
        params.a4[period] = 0;
        params.buffer[period] = params.source[period];
    else
        local price = params.source[period];
        params.a1[period]     = params.alpha1 * price + params.alpha * params.a1[period - 1];
        params.a2[period]     = (price - params.a1[period]) * params.alpha1 + params.alpha * params.a2[period - 1];
        params.a3[period]     = params.a1[period] + params.a2[period];
        params.a4[period]     = (params.a3[period] - params.buffer[period - 1]) * params.alpha1_2 + params.alpha_2 * params.a4[period - 1];
        params.buffer[period] = params.buffer[period - 1] + params.a4[period];
    end
end

