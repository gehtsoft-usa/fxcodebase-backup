-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&p=132050

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
    indicator.parameters:addStringAlternative(id, "Regression", "", "REGRESSION");
end
function CreateAverages(period, method, source)
    if method == "MVA" or method == "EMA" or method == "ARSI"
       or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA" or method == "REGRESSION"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function Init()
    indicator:name("MA ZigZag")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("ma_period", "MA Period", "", 20);
    AddAverages("ma_method", "MA Method", "MVA");

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12)
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5)
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("ZigZag_color", "Color of ZigZag", "Color of ZigZag", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("ma_color", "MA Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("ma_width", "MA Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ma_style", "MA Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ma_style", core.FLAG_LINE_STYLE);
end

local Depth
local Deviation
local Backstep

local first
local source = nil

-- Streams block
local ZigZag = nil
local HighMap = nil
local LowMap = nil
local ma, ma_stream;

-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    source = instance.source
    first = source:first()

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    ma = CreateAverages(instance.parameters.ma_period, instance.parameters.ma_method, source);
    ZigZag = instance:addStream("ZigZag", core.Line, name, "ZigZag", instance.parameters.ZigZag_color, first)
    ZigZag:setWidth(instance.parameters.width)
    ZigZag:setStyle(instance.parameters.style)
    HighMap = instance:addInternalStream(0, 0)
    LowMap = instance:addInternalStream(0, 0)
    ma_stream = instance:addStream("MA", core.Line, "MA", "MA", instance.parameters.ma_color, 0, 0);
    ma_stream:setWidth(instance.parameters.ma_width);
    ma_stream:setStyle(instance.parameters.ma_style);
end

local searchBoth = 0
local searchPeak = 1
local searchLawn = -1
local lastlow = nil
local lashhigh = nil

-- optimization hint
local g_last_peak_date = nil
local g_last_peak = nil
local g_prev_peak_date = nil
local g_searchMode = nil

function Update(period, mode)
    ma:update(mode);
    ma_stream[period] = ma.DATA[period];
    if period <= ma.DATA:first() + Depth then
        -- inital calculation or re-calculation appeared
        lastlow = nil
        lasthigh = nil

        g_last_peak_date = nil
        g_last_peak = nil
        g_prev_peak_date = nil
        g_searchMode = nil
    else
        -- fill high/low maps
        local range = core.rangeTo(period, Depth)
        local val
        local i
        -- get the lowest low for the last depth periods
        val = core.min(ma.DATA, range)
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil
        else
            -- keep it
            lastlow = val
            -- if current low is higher for more than Deviation pips, ignore
            if (ma.DATA[period] - val) > (ma.DATA:pipSize() * Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = nil
                    end
                end
            end
        end
        if ma.DATA[period] == val then
            LowMap[period] = val
        else
            LowMap[period] = 0
        end
        -- get the lowest low for the last depth periods
        val = core.max(ma.DATA, range)
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil
        else
            -- keep it
            lasthigh = val
            -- if current low is higher for more than Deviation pips, ignore
            if (val - ma.DATA[period]) > (ma.DATA:pipSize() * Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = nil
                    end
                end
            end
        end
        if ma.DATA[period] == val then
            HighMap[period] = val
        else
            HighMap[period] = 0
        end

        local start
        local last_peak
        local last_peak_i
        local prev_peak
        last_peak = nil
        last_peak_i = nil
        prev_peak = nil
        local searchMode = searchBoth
        start = Depth

        if (g_last_peak_date ~= nil) then
            for i = period, 0, -1 do
                if ma.DATA:date(i) == g_last_peak_date then
                    last_peak_i = i
                    last_peak = g_last_peak
                    start = i
                    searchMode = g_searchMode
                    if (g_prev_peak_date == nil) then
                        break
                    end
                end
                if (ma.DATA:date(i) == g_prev_peak_date) then
                    prev_peak = i
                    break
                end
                if (g_prev_peak_date ~= nil and ma.DATA:date(i) < g_prev_peak_date) then
                    break
                end
            end
        end

        for i = start, period, 1 do
            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i
                    last_peak = HighMap[i]
                    searchMode = searchLawn
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i
                    last_peak = LowMap[i]
                    searchMode = searchPeak
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i]
                    last_peak_i = i
                    if prev_peak ~= nil then
                        core.drawLine(ZigZag, core.range(prev_peak, i), ZigZag[prev_peak], prev_peak, LowMap[i], i)
                    end
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i)
                    prev_peak = last_peak_i
                    last_peak = HighMap[i]
                    last_peak_i = i
                    searchMode = searchLawn
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i]
                    last_peak_i = i
                    if prev_peak ~= nil then
                        core.drawLine(ZigZag, core.range(prev_peak, i), ZigZag[prev_peak], prev_peak, HighMap[i], i)
                    end
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    core.drawLine(ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i)
                    prev_peak = last_peak_i
                    last_peak = LowMap[i]
                    last_peak_i = i
                    searchMode = searchPeak
                end
            end
        end
        if (last_peak_i ~= nil) then
            g_last_peak_date = ma.DATA:date(last_peak_i)
        end
        if (prev_peak ~= nil) then
            g_prev_peak_date = ma.DATA:date(prev_peak)
        end
        g_searchMode = searchMode
        g_last_peak = last_peak
    end
end
