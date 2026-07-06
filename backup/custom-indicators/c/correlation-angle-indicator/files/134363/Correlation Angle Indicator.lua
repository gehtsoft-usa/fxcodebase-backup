-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69927
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
    indicator:name("Correlation Angle");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("Period", "Period", "", 20);
   -- indicator.parameters:addInteger("InputPeriod", "InputPeriod", "", 20);

    indicator.parameters:addColor("Angle_color", "Angle Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("Angle_width", "Angle Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("Angle_style", "Angle Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("Angle_style", core.FLAG_LINE_STYLE);
end

local source, Period, InputPeriod, Angle;
function Prepare(nameOnly)
    source = instance.source;
    Period = instance.parameters.Period;
    InputPeriod = instance.parameters.InputPeriod;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Angle = instance:addStream("Angle", core.Line, "Angle", "Angle", instance.parameters.Angle_color, 0, 0);
    Angle:setWidth(instance.parameters.Angle_width);
    Angle:setStyle(instance.parameters.Angle_style);
end

function Price(period)
    if InputPeriod ~= 0 then 
        return math.sin(360 * period / InputPeriod);
    end
   
end

function Update(period, mode)
    if period < Period + 1 then
        return;
    end
    Sx = 0;
    Sy = 0;
    Sxx = 0;
    Sxy = 0;
    Syy = 0;
    for count = 1, Period,1  do
        X = source[period-count+1];
        Y = math.cos(360 * (count - 1 ) / Period);
        Sx = Sx + X;
        Sy = Sy + Y;
        Sxx = Sxx + X * X;
        Sxy = Sxy + X * Y;
        Syy = Syy + Y * Y;
    end
    if (Period * Sxx - Sx * Sx > 0) and (Period * Syy - Sy * Sy > 0) then
        Real = (Period * Sxy - Sx * Sy) / math.sqrt((Period * Sxx - Sx * Sx) * (Period * Syy - Sy * Sy));
    end
    Sx = 0;
    Sy = 0;
    Sxx = 0;
    Sxy = 0;
    Syy = 0;
    for count = 1, Period,1 do
        X = source[period-count+1]
        Y = -math.sin(360 * ( count - 1 ) / Period);
        Sx = Sx + X;
        Sy = Sy + Y;
        Sxx = Sxx + X * X;
        Sxy = Sxy + X * Y;
        Syy = Syy + Y * Y;
    end
    if (Period * Sxx - Sx * Sx > 0) and (Period * Syy - Sy * Sy > 0) then
        Imag = (Period * Sxy - Sx * Sy) / math.sqrt((Period * Sxx - Sx * Sx) * (Period * Syy - Sy * Sy));
    end
    if Imag ~= 0 then 
        Angle[period] = 90 + math.atan(Real / Imag);
    end
    if Imag > 0 then 
        Angle[period] = Angle[period] - 180;
    end
end
