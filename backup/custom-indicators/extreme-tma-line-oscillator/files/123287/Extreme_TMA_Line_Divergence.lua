-- Id: 23601
function Init()
    indicator:name("Extreme TMA Line Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("TMA_Period", "TMA period", "", 56);
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 100);
    indicator.parameters:addDouble("ATR_Mult", "ATR multiplier", "", 2);
    indicator.parameters:addDouble("TrendThreshold", "TrendThreshold", "", 0.5);

    indicator.parameters:addBoolean("Redraw", "Redraw", "", true);
    
    indicator.parameters:addString("Method", "Calculation Method", "Method" , "Absolute");
    indicator.parameters:addStringAlternative("Method", "Absolute", "Absolute" , "Absolute");
    indicator.parameters:addStringAlternative("Method", "Relative", "Relative" , "Relative");
    indicator.parameters:addColor("D_color", "Color of Divergence line", "", core.rgb(0, 155, 255));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

local DD;
local UP_color;
local DN_color;

local first;
local source = nil;

local D = nil;
local UP = nil;
local DN = nil;
local ETMA = nil;
local lineid = nil;

function Prepare()
    DD = instance.parameters.DD;
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
    source = instance.source;
    assert(core.indicators:findIndicator("EXTREME_TMA_LINE_OSCILLATOR") ~= nil, "EXTREME_TMA_LINE_OSCILLATOR" .. " indicator must be installed");
    ETMA = core.indicators:create("EXTREME_TMA_LINE_OSCILLATOR", source, instance.parameters.K,instance.parameters.SD,3);
    first = ETMA.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    D = instance:addStream("ETMA", core.Bar, name .. ".ETMA", "ETMA", instance.parameters.D_color, first, -1);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
    UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
    DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

function Update(period, mode)
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    pperiod1 = source:serial(period)
    period = period - 1;

    ETMA:update(mode);
    if period >= first then
        D[period] = ETMA.Oscillator[period];
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
            if ETMA.Oscillator[curr] > ETMA.Oscillator[prev] and source.low[curr] < source.low[prev] then
                if I then
                    DN:set(curr, ETMA.Oscillator[curr], "\225", "Classic bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), ETMA.Oscillator[prev], source:date(curr), ETMA.Oscillator[curr], DN_color);
                else
                    DN[period] = curr - prev;
                end
            elseif ETMA.Oscillator[curr] < ETMA.Oscillator[prev] and source.low[curr] > source.low[prev] then
                DN:set(curr, ETMA.Oscillator[curr], "\225", "Reversal bullish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), ETMA.Oscillator[prev], source:date(curr), ETMA.Oscillator[curr], DN_color);
            end
        end

    end
end

function isTrough(period)
    local i;
    if ETMA.Oscillator[period] < ETMA.Oscillator[period - 1] and ETMA.Oscillator[period] < ETMA.Oscillator[period + 1] then
        for i = period - 1, first, -1 do
            if ETMA.Oscillator[i] > 80 then
                return true;
            elseif ETMA.Oscillator[period] > ETMA.Oscillator[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if ETMA.Oscillator[i] <= ETMA.Oscillator[i - 1] and ETMA.Oscillator[i] < ETMA.Oscillator[i - 2] and
           ETMA.Oscillator[i] <= ETMA.Oscillator[i + 1] and ETMA.Oscillator[i] < ETMA.Oscillator[i + 2] then
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
            if ETMA.Oscillator[curr] < ETMA.Oscillator[prev] and source.high[curr] > source.high[prev] then
                if I then
                    UP:set(curr, ETMA.Oscillator[curr], "\226", "Classic bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), ETMA.Oscillator[prev], source:date(curr), ETMA.Oscillator[curr], UP_color);
                else
                    UP[period] = curr - prev;
                end
            elseif ETMA.Oscillator[curr] > ETMA.Oscillator[prev] and source.high[curr] < source.high[prev] then
                UP:set(curr, ETMA.Oscillator[curr], "\226", "Reversal bearish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), ETMA.Oscillator[prev], source:date(curr), ETMA.Oscillator[curr], UP_color);
            end
        end

    end
end

function isPeak(period)
    local i;
    if ETMA.Oscillator[period] > ETMA.Oscillator[period - 1] and ETMA.Oscillator[period] > ETMA.Oscillator[period + 1] then
        for i = period - 1, first, -1 do
            if ETMA.Oscillator[i] < 20 then
                return true;
            elseif ETMA.Oscillator[period] < ETMA.Oscillator[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if ETMA.Oscillator[i] >= ETMA.Oscillator[i - 1] and ETMA.Oscillator[i] > ETMA.Oscillator[i - 2] and
           ETMA.Oscillator[i] >= ETMA.Oscillator[i + 1] and ETMA.Oscillator[i] > ETMA.Oscillator[i + 2] then
           return i;
        end
    end
    return nil;
end
