-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41822

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
end
function CreateAverages(period, method, source)
    if method == "MVA" or method == "EMA" or method == "ARSI"
       or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function Init()
    indicator:name("Price MA Ratio")
    indicator:description("Ratio between MA2/PRICE and MA1/MA2 ")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("First MA Calculation")
    indicator.parameters:addInteger("ma1_period", "First MA Period", "", 14);
    AddAverages("ma1_method", "First MA Method", "MVA");
    indicator.parameters:addGroup("Second MA Calculation")
    indicator.parameters:addInteger("ma2_period", "Second MA Period", "", 14);
    AddAverages("ma2_method", "Second MA Method", "EMA");

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first
local source = nil
local One, Two
local Ratio
-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.ma1_method
    Method2 = instance.parameters.ma2_method
    Period1 = instance.parameters.ma1_period
    Period2 = instance.parameters.ma2_period
    source = instance.source

    local name =
        profile:id() ..
        "(" ..
            source:name() ..
                ", " ..
                    tostring(Method1) ..
                        ", " .. tostring(Period1) .. ", " .. tostring(Method2) .. ", " .. tostring(Period2) .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    One = CreateAverages(Period1, Method1, source)
    Two = CreateAverages(Period2, Method2, source)

    first = math.max(One.DATA:first(), Two.DATA:first())

    Ratio = instance:addStream("Ratio", core.Bar, name .. ". Ratio ", " Ratio ", instance.parameters.color, first)
    Ratio:setPrecision(math.max(2, instance.source:getPrecision()))
end

function Update(period, mode)
    One:update(mode)
    Two:update(mode)

    if period < first then
        return
    end

    local DIFF1 = (source[period] - Two.DATA[period])
    local DIFF2 = (One.DATA[period] - Two.DATA[period])

    Ratio[period] = DIFF1 - DIFF2
end
