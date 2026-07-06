-- Id: 528
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=876

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("FX5 Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("MACD_Short", "Period of short EMA for MACD", "", 12);
    indicator.parameters:addInteger("MACD_Long", "Period of long EMA for MACD", "", 26);
    indicator.parameters:addInteger("MACD_Signal", "Signal period of MACD", "", 9);
    indicator.parameters:addBoolean("I", "Indicator mode", "Keep true value to display labels and lines. Set this parameter to false when the indicator is used in another indicator.", true);
    indicator.parameters:addColor("D_color", "Color of Divergence line", "", core.rgb(0, 155, 255));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local I;
local DD;
local UP_color;
local DN_color;

local first;
local source = nil;

-- Streams block
local D = nil;
local UP = nil;
local DN = nil;
local MACD = nil;
local lineid = nil;

-- Routine
function Prepare(nameOnly)
    I = instance.parameters.I;
    DD = instance.parameters.DD;
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MACD_Short .. ", " .. instance.parameters.MACD_Long .. ", " .. instance.parameters.MACD_Signal .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MACD = core.indicators:create("MACD", source.close, instance.parameters.MACD_Short,instance.parameters.MACD_Long,instance.parameters.MACD_Signal);
    first = MACD.HISTOGRAM:first();

    D = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", instance.parameters.D_color, first, -1);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
    if I then
        UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
        DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
    else
        UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.D_color, first, -1);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
        DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.D_color, first, -1);
    DN:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)
    -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    pperiod1 = source:serial(period)
    period = period - 1;

    MACD:update(mode);
    if period >= first then
        D[period] = MACD.HISTOGRAM[period];
        if period >= first + 2 then
            processBullish(period - 2);
            processBearish(period - 2);
        end
    end
end

function processBullish(period)
    if isTrough(period) then
        local curr, prev;
        curr = period;
        prev = prevTrough(period);
        if prev ~= nil then
            if MACD.HISTOGRAM[curr] > MACD.HISTOGRAM[prev] and source.low[curr] < source.low[prev] then
                if I then
                    DN:set(curr, MACD.HISTOGRAM[curr], "\225", "Classic bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), MACD.HISTOGRAM[prev], source:date(curr), MACD.HISTOGRAM[curr], DN_color);
                else
                    DN[period] = curr - prev;
                end
            elseif MACD.HISTOGRAM[curr] < MACD.HISTOGRAM[prev] and source.low[curr] > source.low[prev] then
                if I then
                    DN:set(curr, MACD.HISTOGRAM[curr], "\225", "Reversal bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), MACD.HISTOGRAM[prev], source:date(curr), MACD.HISTOGRAM[curr], DN_color);
                else
                    DN[period] = -(curr - prev);
                end
            end
        end

    end
end

function isTrough(period)
    local i;
    if MACD.HISTOGRAM[period] < 0 and MACD.HISTOGRAM[period] < MACD.HISTOGRAM[period - 1] and MACD.HISTOGRAM[period] < MACD.HISTOGRAM[period + 1] then
        for i = period - 1, first, -1 do
            if MACD.HISTOGRAM[i] > 0 then
                return true;
            elseif MACD.HISTOGRAM[period] > MACD.HISTOGRAM[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if MACD.HISTOGRAM[i] <= MACD.HISTOGRAM[i - 1] and MACD.HISTOGRAM[i] < MACD.HISTOGRAM[i - 2] and
           MACD.HISTOGRAM[i] <= MACD.HISTOGRAM[i + 1] and MACD.HISTOGRAM[i] < MACD.HISTOGRAM[i + 2] then
           return i;
        end
    end
    return nil;
end

function processBearish(period)
    if isPeak(period) then
        local curr, prev;
        curr = period;
        prev = prevPeak(period);
        if prev ~= nil then
            if MACD.HISTOGRAM[curr] < MACD.HISTOGRAM[prev] and source.high[curr] > source.high[prev] then
                if I then
                    UP:set(curr, MACD.HISTOGRAM[curr], "\226", "Classic bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), MACD.HISTOGRAM[prev], source:date(curr), MACD.HISTOGRAM[curr], UP_color);
                else
                    UP[period] = curr - prev;
                end
            elseif MACD.HISTOGRAM[curr] > MACD.HISTOGRAM[prev] and source.high[curr] < source.high[prev] then
                if I then
                    UP:set(curr, MACD.HISTOGRAM[curr], "\226", "Reversal bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), MACD.HISTOGRAM[prev], source:date(curr), MACD.HISTOGRAM[curr], UP_color);
                else
                    UP[period] = -(curr - prev);
                end
            end
        end

    end
end

function isPeak(period)
    local i;
    if MACD.HISTOGRAM[period] > 0 and MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period - 1] and MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period + 1] then
        for i = period - 1, first, -1 do
            if MACD.HISTOGRAM[i] < 0 then
                return true;
            elseif MACD.HISTOGRAM[period] < MACD.HISTOGRAM[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if MACD.HISTOGRAM[i] >= MACD.HISTOGRAM[i - 1] and MACD.HISTOGRAM[i] > MACD.HISTOGRAM[i - 2] and
           MACD.HISTOGRAM[i] >= MACD.HISTOGRAM[i + 1] and MACD.HISTOGRAM[i] > MACD.HISTOGRAM[i + 2] then
           return i;
        end
    end
    return nil;
end
