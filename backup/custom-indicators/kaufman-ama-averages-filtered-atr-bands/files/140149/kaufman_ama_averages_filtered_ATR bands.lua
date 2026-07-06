-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70810

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC |
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
    indicator:name("Kaufman adaptive moving average &  Adaptive Moving Average")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Period", "", 10, 2, 2000)
    indicator.parameters:addInteger("atr_period", "ATR Period", "", 14);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color1", "AMA Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5)

    indicator.parameters:addColor("color2", "KAMA Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5)
end

local Period
local first
local source = nil
local Pds, FastSC, SlowSC
local AAA, KAMA
local ROC
local up, down;

function Prepare(nameOnly)
    Period = instance.parameters.Period

    local name = profile:id() .. "(" .. instance.source:name() .. ", " .. Period .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    Pds = Period + 1
    FastSC = 2 / (2 + 1)
    SlowSC = 2 / (30 + 1)

    source = instance.source
    first = source:first() + Pds

    --Direction = instance:addInternalStream(0, 0);
    --Volatility= instance:addInternalStream(0, 0);
    ROC = instance:addInternalStream(0, 0)

    AAA = instance:addStream("AAA", core.Line, " AAA", " AAA", instance.parameters.color1, first + 1)
    AAA:setWidth(instance.parameters.width1)
    AAA:setStyle(instance.parameters.style1)

    KAMA =
        instance:addStream("KAMA", core.Line, " KAMA", " KAMA", instance.parameters.color2, source:first() + Period * 2)
    KAMA:setWidth(instance.parameters.width2)
    KAMA:setStyle(instance.parameters.style2)
    up = instance:addStream("Up", core.Line, "Up", "Up", instance.parameters.color2, source:first() + Period * 2)
    up:setWidth(instance.parameters.width2)
    up:setStyle(instance.parameters.style2)
    down = instance:addStream("Down", core.Line, "Down", "Down", instance.parameters.color2, source:first() + Period * 2)
    down:setWidth(instance.parameters.width2)
    down:setStyle(instance.parameters.style2)
    atr = core.indicators:create("ATR", source, instance.parameters.atr_period);
end

function Update(period, mode)
    atr:update(mode);
    ROC[period] = math.abs(source.close[period] - source.close[period - 1])

    if period > first then
        --Adaptive Moving Average
        local min, max = mathex.minmax(source, period - Pds + 1, period)
        local Mltp = math.abs((source.close[period] - min) - (max - source.close[period])) / (max - min)
        local SSC = Mltp * (FastSC - SlowSC) + SlowSC
        local Constant = math.pow(SSC, 2)

        if period < first + Pds + 1 then
            AAA[period] = source.close[period - 1] + Constant * (source.close[period] - source.close[period - 1])
        else
            AAA[period] = AAA[period - 1] + Constant * (source.close[period] - AAA[period - 1])
        end
    end

    --Kaufman Adaptive Moving Average

    if period < source:first() + Period * 2 then
        return
    end

    local Direction = math.abs(source.close[period] - source.close[period - Period])
    local Volatility = mathex.sum(ROC, period - Period + 1, period)

    local ER = Direction / Volatility
    local SSC = ER * (FastSC - SlowSC) + SlowSC
    local Constant = math.pow(SSC, 2)

    if period <= source:first() + Period * 2 then
        KAMA[period] = source.close[period - 1] + Constant * (source.close[period] - source.close[period - 1])
    else
        KAMA[period] = KAMA[period - 1] + Constant * (source.close[period] - KAMA[period - 1])
    end
    up[period] = KAMA[period] + atr.DATA[period];
    down[period] = KAMA[period] - atr.DATA[period];
end
