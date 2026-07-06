-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69779

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
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
    indicator:name("Moving Average Envelope (New Version)")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Shift Calculation")
    indicator.parameters:addBoolean("Shift", "Half Period shift", "", true)
    indicator.parameters:addInteger("SX", "Shift in periods", "Postive is future, negative is past", 0)
    indicator.parameters:addInteger("SY", "Shift in points", "", 0)

    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addInteger("N", "Number of periods for Moving Average", "", 14)
    AddAverages("MET", "Moving Average Method", "MVA");

    indicator.parameters:addDouble("B", "Band Width", "", 25)
    indicator.parameters:addString("BWU", "Band Width Units", "", "%%")
    indicator.parameters:addStringAlternative("BWU", "In 1/100 of percent", "", "%%")
    indicator.parameters:addStringAlternative("BWU", "In pips", "", "pip(s)")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addBoolean("SM", "Show MA line", "", true)
    indicator.parameters:addColor("MVA_color", "Color of MA line", "", core.rgb(255, 0, 0))

    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5)

    indicator.parameters:addColor("B_color", "Color of Band", "", core.rgb(0, 0, 255))

    indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N
local B
local BWU
local MET
local SM
local Shift
local first
local source = nil
local IND

-- Streams block
local MVA = nil
local UB = nil
local LB = nil
local SX, SY

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N
    B = instance.parameters.B
    BWU = instance.parameters.BWU
    MET = instance.parameters.MET
    SM = instance.parameters.SM
    Shift = instance.parameters.Shift

    source = instance.source
    SX = instance.parameters.SX
    if Shift then
        if SX >= 0 then
            SX = SX + 1;
        else
            SX = SX - 1;
        end
    end
    SY = instance.parameters.SY

    local name = profile:id() .. "(" .. source:name() .. "," .. MET .. "(" .. N .. ")," .. B .. BWU .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    
    IND = CreateAverages(N, MET, source);
    first = IND.DATA:first() + 1

    if BWU == "%%" then
        BWU = 1
    else
        BWU = 2
        B = B * source:pipSize()
    end

    if SM then
        MVA = instance:addStream("MVA", core.Line, name .. ".MVA", "MVA", instance.parameters.MVA_color, first, SX)
        MVA:setPrecision(math.max(10, source:getPrecision()))
        MVA:setWidth(instance.parameters.width1)
        MVA:setStyle(instance.parameters.style1)
    end
    UB = instance:addStream("UB", core.Line, name .. ".UB", "UB", instance.parameters.B_color, first, SX)
    LB = instance:addStream("LB", core.Line, name .. ".LB", "LB", instance.parameters.B_color, first, SX)

    UB:setPrecision(math.max(10, source:getPrecision()))
    LB:setPrecision(math.max(10, source:getPrecision()))

    UB:setWidth(instance.parameters.width2)
    UB:setStyle(instance.parameters.style2)
    LB:setWidth(instance.parameters.width2)
    LB:setStyle(instance.parameters.style2)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    IND:update(mode)

    if period < first then
        return
    end

    local d

    if Shift then
        d = (IND.DATA[period - 1] + IND.DATA[period]) / 2
    else
        d = IND.DATA[period]
    end

    local s
    if BWU == 1 then
        s = d * B / 10000
    else
        s = B
    end

    if SM then
        MVA[period + SX] = d + SY
    end
    UB[period + SX] = d + s + SY
    LB[period + SX] = d - s + SY
end
