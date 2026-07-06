-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69493

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
    indicator:name("Inverse Fisher Transform");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("Length", "Period", "", 14);
    indicator.parameters:addDouble("Alpha", "Alpha", "", 0.1);
    indicator.parameters:addDouble("values_shift", "Shift values", "", 0)

    indicator.parameters:addColor("ift_color", "IFT Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("ift_width", "IFT Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ift_style", "IFT Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ift_style", core.FLAG_LINE_STYLE);
end

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

local source, Length, Alpha, ift, values_shift, value1;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Length = instance.parameters.Length;
    Alpha = instance.parameters.Alpha;
    values_shift = instance.parameters.values_shift;

    value1 = instance:addInternalStream(source:first(), 0);

    ift = instance:addStream("IFT", core.Line, "IFT", "IFT", instance.parameters.ift_color, 0, 0);
    ift:setWidth(instance.parameters.ift_width);
    ift:setStyle(instance.parameters.ift_style);
end

function Update(period, mode)
    if not source:hasData(period) then
        return;
    end
    value1[period] = Alpha * (source[period] - values_shift);
    if period < Length or not value1:hasData(period - Length) then
        return;
    end
    value2 = mathex.lwma(value1, period - Length + 1, period);
    ift[period] = (math.exp(2 * value2) - 1) / (math.exp(2 * value2) + 1);
end