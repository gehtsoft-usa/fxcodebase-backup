-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=275

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
function Init()
    indicator:name("ZigZag");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
	
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("ZigZag_color", "Color of ZigZag", "Color of ZigZag", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;

local first;
local source = nil;

-- Streams block
local ZigZag = nil;
local HighMap = nil;
local LowMap = nil;

-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ZigZag = instance:addStream("ZigZag", core.Line, name, "ZigZag", instance.parameters.ZigZag_color, first);
	ZigZag:setWidth(instance.parameters.width);
    ZigZag:setStyle(instance.parameters.style);
    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
end

local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;

-- optimization hint
local g_last_peak_date = nil;
local g_last_peak = nil;
local g_prev_peak_date = nil;
local g_searchMode = nil;


function Update(period, mode)
    if period <= Depth then
        -- inital calculation or re-calculation appeared
        lastlow = nil;
        lasthigh = nil;

        g_last_peak_date = nil;
        g_last_peak = nil;
        g_prev_peak_date = nil;
        g_searchMode = nil;
    else
       -- fill high/low maps
        local range = core.rangeTo(period, Depth);
        local val;
        local i;
        -- get the lowest low for the last depth periods
        val = core.min(source.low, range);
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lastlow = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (source.low[period] - val) > (source:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = nil;
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
        val = core.max(source.high, range);
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lasthigh = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (val - source.high[period]) > (source:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = nil;
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
        last_peak = nil;
        last_peak_i = nil;
        prev_peak = nil;
        local searchMode = searchBoth;
        start = Depth;

        if (g_last_peak_date ~= nil) then
            for i = period, 0, -1 do
                if source:date(i) == g_last_peak_date then
                    last_peak_i = i;
                    last_peak = g_last_peak;
                    start = i;
                    searchMode = g_searchMode;
                    if (g_prev_peak_date == nil) then
                        break;
                    end
                end
                if (source:date(i) == g_prev_peak_date) then
                    prev_peak = i;
                    break;
                end
                if (g_prev_peak_date ~= nil and source:date(i) < g_prev_peak_date) then
                    break;
                end
            end
        end

        for i = start, period, 1 do


            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = HighMap[i];
                    searchMode = searchLawn;
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = LowMap[i];
                    searchMode = searchPeak;
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        core.drawLine(ZigZag, core.range(prev_peak, i), ZigZag[prev_peak], prev_peak, LowMap[i], i);
                    end
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i);
                    prev_peak = last_peak_i;
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    searchMode = searchLawn;
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        core.drawLine(ZigZag, core.range(prev_peak, i), ZigZag[prev_peak], prev_peak, HighMap[i], i);
                    end
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    core.drawLine(ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i);
                    prev_peak = last_peak_i;
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    searchMode = searchPeak;
                end
            end
        end
        if (last_peak_i ~= nil) then
            g_last_peak_date = source:date(last_peak_i)
        end
        if (prev_peak ~= nil) then
            g_prev_peak_date = source:date(prev_peak)
        end
        g_searchMode = searchMode;
        g_last_peak = last_peak;
    end
end