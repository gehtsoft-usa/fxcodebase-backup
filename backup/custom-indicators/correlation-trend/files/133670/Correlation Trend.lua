-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69817

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
    indicator:name("Correlation Trend");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Length", "Length", "", 20);
    
    indicator.parameters:addColor("out_color", "Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("out_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("out_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("out_style", core.FLAG_LINE_STYLE);
end

local source, out, Length, TreiggerLevel;
function Prepare(nameOnly)
    source = instance.source;
    Length = instance.parameters.Length;
    TreiggerLevel = instance.parameters.TreiggerLevel;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    out = instance:addStream("Out", core.Line, "Trend Cor", "Trend Cor", instance.parameters.out_color, 0, 0);
    out:setWidth(instance.parameters.out_width);
    out:setStyle(instance.parameters.out_style);
end

function Update(period, mode)
    local Sx = 0;
    local Sy = 0;
    local Sxx = 0;
    local Sxy = 0;
    local Syy = 0;
    for count = 0, Length - 1 do
        X = source[period - count];
        Y = -count;
        Sx = Sx + X;
        Sy = Sy + Y;
        Sxx = Sxx + X * X;
        Sxy = Sxy + X * Y;
        Syy = Syy + Y * Y;
    end
    Num = Length * Sxy - Sx * Sy;
    Denom = math.sqrt(Length * Sxx - Sx * Sx) * (Length * Syy - Sy * Sy);
    if Denom ~= 0 then
        out[period] = Num / Denom;
    else
        out[period] = 0;
    end
end
