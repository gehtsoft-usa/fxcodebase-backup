-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64888

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
    indicator:name("MA difference")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)
    indicator.parameters:addGroup("Selector")
    indicator.parameters:addBoolean("S1", "Show Difference Line", "", true)
    indicator.parameters:addBoolean("S2", "Show Signal Line", "", true)
    indicator.parameters:addBoolean("S3", "Show Second Line", "", true)

    indicator.parameters:addGroup("1. Difference Calculation")
    indicator.parameters:addInteger("ma11_period", "1. MA Period", "", 10);
    AddAverages("ma11_method", "1. MA Method", "MVA");
    indicator.parameters:addInteger("ma12_period", "2. MA Period", "", 10);
    AddAverages("ma12_method", "2. MA Method", "EMA");
    indicator.parameters:addInteger("ma1_period", "1. Difference Smoothing Period", "", 10);
    AddAverages("ma1_method", "MA Method", "MVA");
    indicator.parameters:addGroup("2. Difference Calculation")
    indicator.parameters:addInteger("ma21_period", "1. MA Period", "", 34);
    AddAverages("ma21_method", "1. MA Method", "MVA");
    indicator.parameters:addInteger("ma22_period", "2. MA Period", "", 34);
    AddAverages("ma22_method", "2. MA Method", "EMA");
    indicator.parameters:addInteger("ma2_period", "1. Difference Smoothing Period", "", 10);
    AddAverages("ma2_method", "MA Method", "MVA");

    indicator.parameters:addGroup("Line Style")
    indicator.parameters:addColor("color1", "1. Line Color", "Line Color", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("color2", "2. Line Color", "Line Color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Signal Line Style")
    indicator.parameters:addColor("color3", "1. Signal Line Color", "Line Color", core.rgb(0, 255, 255))
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("color4", "2. Signal Line Color", "Line Color", core.rgb(255, 0, 255))
    indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MA11
local MA12
local MA21
local MA22
local source = nil
local first

local MA1, MA2

local difference1
local difference2
local signal1
local signal2

local S1, S2, S3
-- Routine
function Prepare(nameOnly)
    length = instance.parameters.length
    S1 = instance.parameters.S1
    S2 = instance.parameters.S2
    S3 = instance.parameters.S3

    source = instance.source

    local name =
        profile:id() ..
        "(" ..
            source:name() ..
                ", " ..
                    tostring(instance.parameters.ma11_period) ..
                        ", " ..
                            tostring(instance.parameters.ma12_period) ..
                                ", " ..
                                    tostring(instance.parameters.ma21_period) ..
                                        ", " .. tostring(instance.parameters.ma22_period) .. ")"
    instance:name(name)

    if (not (nameOnly)) then
        MA11 = CreateAverages(instance.parameters.ma11_period, instance.parameters.ma11_method, source)
        MA12 = CreateAverages(instance.parameters.ma12_period, instance.parameters.ma12_method, source)
        MA21 = CreateAverages(instance.parameters.ma21_period, instance.parameters.ma21_method, source)
        MA22 = CreateAverages(instance.parameters.ma22_period, instance.parameters.ma22_method, source)
        first = math.max(MA11.DATA:first(), MA12.DATA:first(), MA21.DATA:first(), MA22.DATA:first())

        if S1 then
            difference1 =
                instance:addStream(
                "difference1",
                core.Line,
                name .. ".difference1",
                "difference1",
                instance.parameters.color1,
                first
            )
            difference1:setPrecision(math.max(2, instance.source:getPrecision()))
            difference1:setWidth(instance.parameters.width1)
            difference1:setStyle(instance.parameters.style1)

            if S3 then
                difference2 =
                    instance:addStream(
                    "difference2",
                    core.Line,
                    name .. ".difference2",
                    "difference2",
                    instance.parameters.color2,
                    first
                )
                difference2:setPrecision(math.max(2, instance.source:getPrecision()))
                difference2:setWidth(instance.parameters.width2)
                difference2:setStyle(instance.parameters.style2)
            else
                difference2 = instance:addInternalStream(0, 0)
            end
        else
            difference1 = instance:addInternalStream(0, 0)
            difference2 = instance:addInternalStream(0, 0)
        end

        MA1 = CreateAverages(instance.parameters.ma1_period, instance.parameters.ma1_method, difference1)
        MA2 = CreateAverages(instance.parameters.ma2_period, instance.parameters.ma2_method, difference2)

        if S2 then
            signal1 =
                instance:addStream(
                "signal1",
                core.Line,
                name .. ".signa11",
                "signal1",
                instance.parameters.color2,
                MA1.DATA:first()
            )
            signal1:setPrecision(math.max(2, instance.source:getPrecision()))
            signal1:setWidth(instance.parameters.width3)
            signal1:setStyle(instance.parameters.style3)

            if S3 then
                signal2 =
                    instance:addStream(
                    "signal2",
                    core.Line,
                    name .. ".signal2",
                    "signal2",
                    instance.parameters.color4,
                    MA2.DATA:first()
                )
                signal2:setPrecision(math.max(2, instance.source:getPrecision()))
                signal2:setWidth(instance.parameters.width4)
                signal2:setStyle(instance.parameters.style4)
            else
                signal2 = instance:addInternalStream(0, 0)
            end
        else
            signal1 = instance:addInternalStream(0, 0)
            signal2 = instance:addInternalStream(0, 0)
        end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    MA11:update(mode)
    MA12:update(mode)
    MA21:update(mode)
    MA22:update(mode)

    if period < first then
        return
    end

    difference1[period] = MA11.DATA[period] - MA12.DATA[period]
    difference2[period] = MA21.DATA[period] - MA22.DATA[period]

    MA1:update(mode)
    MA2:update(mode)

    if period > MA1.DATA:first() then
        signal1[period] = MA1.DATA[period]
    end

    if period > MA2.DATA:first() then
        signal2[period] = MA2.DATA[period]
    end
end
