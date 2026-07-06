-- More information about this indicator can be found at:
--http://fxcodebase.com/code/posting.php?mode=post&f=17

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
    indicator:name("Linear Regression Intercept");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    indicator.parameters:addInteger("n", "Period", "", 14);

    indicator.parameters:addColor("out_color", "Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("out_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("out_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("out_style", core.FLAG_LINE_STYLE);
end

local out;
local source, n;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    n = instance.parameters.n;

    out = instance:addStream("LRI", core.Line, "LRI", "LRI", instance.parameters.out_color, 0, 0);
    out:setWidth(instance.parameters.out_width);
    out:setStyle(instance.parameters.out_style);
end

function Update(period, mode)
    if period < n then
        return;
    end
    local x = 0;
    local x2 = 0;
    local y = 0;
    local xy = 0;
    for i = 1, n do
        xy = xy + i * source.close[period - i + 1];
        x = x + i;
        x2 = x2 + i * i;
        y = y + source.close[period - i + 1];
    end
    local slope = (n * xy - x * y) / (n * x2 - x * x);
    out[period] = (y - slope * x) / n;
end