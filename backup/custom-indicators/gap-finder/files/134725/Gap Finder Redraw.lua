-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36113

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

function Init()
    indicator:name("Gap finder indicator")
    indicator:description("Gap finder indicator")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("MinGapSize", "Min. gap size (in pips)", "", 2)
    indicator.parameters:addInteger("lookback", "Lookback", "", 3)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UPclr", "UP gap color", "UP gap color", core.rgb(255, 255, 0))
    indicator.parameters:addColor("DNclr", "DN gap color", "DN gap color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 10)
end

local first
local source = nil
local MinGapSize
local UpGap = nil
local DnGap = nil
local lookback;

function Prepare(nameOnly)
    source = instance.source
    MinGapSize = instance.parameters.MinGapSize * source:pipSize()
    first = source:first() + 2
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MinGapSize .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    lookback = instance.parameters.lookback;
    UpGap =
        instance:createTextOutput(
        "UpGap",
        "UpGap",
        "Wingdings",
        instance.parameters.ArrowSize,
        core.H_Center,
        core.V_Bottom,
        instance.parameters.UPclr,
        0
    )
    DnGap =
        instance:createTextOutput(
        "DnGap",
        "DnGap",
        "Wingdings",
        instance.parameters.ArrowSize,
        core.H_Center,
        core.V_Top,
        instance.parameters.DNclr,
        0
    )
end

function ClosedPagUp(period)
    for i = period, period + lookback do
        if source.low[i] - source.high[period - 1] < MinGapSize then
            return true;
        end
    end
    return false;
end

function ClosedPagDn(period)
    for i = period, period + lookback do
        if source.low[period - 1] - source.high[i] < MinGapSize then
            return true;
        end
    end
    return false;
end

function Update(period, mode)
    if period <= first then
        return;
    end
    if source.low[period] - source.high[period - 1] >= MinGapSize then
        UpGap:set(period, source.low[period], "\225")
    else
        UpGap:setNoData(period)
    end
    if source.low[period - 1] - source.high[period] >= MinGapSize then
        DnGap:set(period, source.high[period], "\226")
    else
        DnGap:setNoData(period)
    end
    if period < lookback then
        return;
    end
    if UpGap:hasData(period - lookback) and ClosedPagUp(period - lookback) then
        UpGap:setNoData(period - lookback);
    end
    if DnGap:hasData(period - lookback) and ClosedPagDn(period - lookback) then
        DnGap:setNoData(period - lookback);
    end
end
