--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- ---------------------------------------------------------------------------------------------
-- The port of the original indicator 3_Level_ZZ_Semafor.mq4  http://codebase.mql4.com/ru/2069
-- the original indicator copyright (c) "asystem2000" "asystem2000@yandex.ru"
-- The trend, retrace and target lines are modification of the original MT4 indicator
-- made by by Avery t. Horton, jr. aka therumpledone@gmail.com
-- ---------------------------------------------------------------------------------------------
--
-- The standard Marketscope ZigZag algoritm is used in this implementation
-- ---------------------------------------------------------------------------------------------
function Init()
    indicator:name("ZigZag semaphore");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("First ZigZag");
    indicator.parameters:addInteger("Depth", "Depth", "The minimum number of periods used to draw one ZigZag line.", 5);
    indicator.parameters:addInteger("Deviation", "Deviation", "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.", 1);
    indicator.parameters:addInteger("Backstep", "Backstep", "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.", 3);
    indicator.parameters:addColor("Color", "Color of labels", "", core.rgb(128, 64, 0));
end

local source;

local lastperiod = -1;
local peak_count = 0;
local lastlow = nil;
local lasthigh = nil;

local HighMap
local LowMap
local SearchMode
local Peak

function Prepare()
    source = instance.source;

    instance:name(profile:id());

    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
    
    ZigZag = instance:addStream("ZigZag", core.Bar, ".ZigZag", "ZigZag", instance.parameters.Color, 0    );
        
    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
    SearchMode = instance:addInternalStream(0, 0);
    Peak = instance:addInternalStream(0, 0);
end


local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1;
    ZigZag:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function ReplaceLastPeak(period, mode, peak)
    local p = ZigZag:getBookmark(peak_count);
    ZigZag:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end
    
function GetPeak(offset)
    local peak;
    peak = peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = ZigZag:getBookmark(peak);
    if peak < 0 then
        return -1;
    end
    return peak;
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
        local u, d;
        for i = start, period, 1 do
            ZigZag[i] = 0;
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
                    ZigZag[last_peak_i] = 0;
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        ZigZag[prev_peak] = Peak[prev_peak];
                    end
                    ZigZag[i] = -LowMap[i];
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    ZigZag[i] = HighMap[i];
                    ZigZag[last_peak_i] = -last_peak;
                    prev_peak = last_peak_i;
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    ZigZag[last_peak_i] = 0;
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        ZigZag[prev_peak] = -Peak[prev_peak];
                    end
                    ZigZag[i] = HighMap[i];
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    ZigZag[last_peak_i] = last_peak;
                    ZigZag[i] = -LowMap[i];
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
