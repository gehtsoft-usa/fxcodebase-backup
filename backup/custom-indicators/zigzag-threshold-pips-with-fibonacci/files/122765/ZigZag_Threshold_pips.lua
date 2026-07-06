-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67155

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("ZigZag Threshold (pips)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Swing");
    indicator:setTag("Version", "1")

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
    indicator.parameters:addInteger("min_threshold", "Threshold, pips", "", 0);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Zig_color", "Zig color", "Color of ZigZag", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Zag_color", "Zag color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthZigZag", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleZigZag", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;
local min_threshold;

local first;
local source = nil;

-- Streams block
local ZigC;
local ZagC;
local out;
local HighMap = nil;
local LowMap = nil;

-- Routine
function Prepare()
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
    min_threshold = instance.parameters.min_threshold;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
    instance:name(name);
    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first);
    out:setWidth(instance.parameters.widthZigZag);
    out:setStyle(instance.parameters.styleZigZag);
    ZigC = instance.parameters.Zig_color;
    ZagC = instance.parameters.Zag_color;

    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
    SearchMode = instance:addInternalStream(0, 0);
    Peak = instance:addInternalStream(0, 0);
end

local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;

-- optimization hint
local peak_count = 0;

local lastperiod = -1;

function GetPeak(offset)
    local peak;
    peak = peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = out:getBookmark(peak);
    if peak < 0 then
        return -1;
    end
    return peak;
end

function ReplaceLastPeak(period, mode, peak)
    --peak_count = peak_count + 1;
    out:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1;
    out:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function GetLastHigh(period)
    if period == -1 then
        return -1;
    end
    for i = period, 0, -1 do
        if HighMap[i] ~= 0 then
            return i;
        end
    end
    return -1;
end

function GetLastLow(period)
    if period == -1 then
        return -1;
    end
    for i = period, 0, -1 do
        if LowMap[i] ~= 0 then
            return i;
        end
    end
    return -1;
end

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1;

    if period == lastperiod then
        return ;
    end

    if period < lastperiod then
        lastlow = nil;
        lasthigh = nil;
        peak_count = 0;
    end

    lastperiod = period;

    if period >= Depth then
        -- fill high/low maps
        local range = period - Depth + 1;
        local val;
        local i;
        -- get the lowest low for the last depth periods
        val = mathex.min(source.low, range, period);
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lastlow = val;
            -- if current low is higher for more than Deviation pips, ignore
            local highIndex = GetLastHigh(period);
            local lowIndex = GetLastLow(highIndex);
            if (source.low[period] - val) > (source:pipSize() * Deviation) then
                val = nil;
            elseif (highIndex ~= -1 and lowIndex ~= -1 and (HighMap[highIndex] - val) < min_threshold * source:pipSize()) then
                val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = 0;
                    end
                end
            end
        end

        if source.low[period] == val then
            LowMap[period] = val;
        else
            LowMap[period] = 0;
        end
        -- get the lowest low for the last depth periods
        val = mathex.max(source.high, range, period);
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lasthigh = val;
            local lowIndex = GetLastLow(period);
            local highIndex = GetLastHigh(lowIndex);
            -- if current low is higher for more than Deviation pips, ignore
            if (val - source.high[period]) > (source:pipSize() * Deviation) then
                val = nil;
            elseif (highIndex ~= -1 and lowIndex ~= -1 and (val - LowMap[lowIndex]) < min_threshold * source:pipSize()) then
                val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = 0;
                    end
                end
            end
        end

        if source.high[period] == val then
            HighMap[period] = val;
        else
            HighMap[period] = 0
        end

        local start;
        local last_peak;
        local last_peak_i;
        local prev_peak;
        local searchMode = searchBoth;

        i = GetPeak(-4);
        if i == -1 then
            prev_peak = nil;
        else
            prev_peak = i;
        end

        start = Depth;
        i = GetPeak(-3);
        if i == -1 then
            last_peak_i = nil;
            last_peak = nil;
        else
            last_peak_i = i;
            last_peak = Peak[i];
            searchMode = SearchMode[i];
            start = i;
        end
		
        peak_count = peak_count - 3;

        for i = start, period, 1 do
            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = HighMap[i];
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = LowMap[i];
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        if Peak[prev_peak] > LowMap[i] then
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZagC);
                            out:setColor(prev_peak, ZigC);
                        else
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC);
                            out:setColor(prev_peak, ZagC);
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC);
                    out:setColor(last_peak_i, ZagC);
                    prev_peak = last_peak_i;
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i, ZigC);
                        out:setColor(prev_peak, ZagC);
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    if  last_peak > LowMap[i] then
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC);
                        out:setColor(last_peak_i, ZigC);
                    else
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC);
                        out:setColor(last_peak_i, ZagC);
                    end
                    prev_peak = last_peak_i;
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            end
        end
    end
end