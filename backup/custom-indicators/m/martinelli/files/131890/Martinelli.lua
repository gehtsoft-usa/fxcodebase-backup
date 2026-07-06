-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69519

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
    indicator:name("Martinelli");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("ForecastLen", "ForecastLen", "", 3);
    indicator.parameters:addInteger("StdDevLen", "StdDevLen", "", 7);

    indicator.parameters:addColor("Alpha_color", "Alpha Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("Alpha_width", "Alpha Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("Alpha_style", "Alpha Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("Alpha_style", core.FLAG_LINE_STYLE);
end

local source, ForecastLen, StdDevLen, Cutoff, PriceForecast, PriceChange, Alpha;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    ForecastLen = instance.parameters.ForecastLen;
    StdDevLen = instance.parameters.StdDevLen;
    PriceForecast = instance:addInternalStream(source:first() + ForecastLen, 0);
    PriceChange = instance:addInternalStream(source:first() + 1, 0);

    Alpha = instance:addStream("Alpha", core.Line, "Alpha", "Alpha", instance.parameters.Alpha_color, source:first() + ForecastLen, 0);
    Alpha:setWidth(instance.parameters.Alpha_width);
    Alpha:setStyle(instance.parameters.Alpha_style);
end

function Update(period, mode)
    if period < source:first() + 1 then
        return;
    end
    PriceChange[period] = source[period] - source[period - 1];
    if period < source:first() + ForecastLen then
        return;
    end
    PriceForecast[period] = mathex.lreg(source, period - ForecastLen + 1, period);
    if period < source:first() + StdDevLen then
        return;
    end
    Omega = mathex.stdev(PriceChange, period - StdDevLen + 1, period);
    Alpha[period] = 0;
    if Omega > 0 then
        Alpha[period] = (PriceForecast[period] - source[period]) / Omega;
    end
end