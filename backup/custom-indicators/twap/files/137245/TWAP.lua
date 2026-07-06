-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70366

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
    indicator:name("http://fxcodebase.com/code/viewtopic.php?f=25&t=59371");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("period", "Period", "", 14);
    indicator.parameters:addColor("line_color", "Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("line_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("line_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style", core.FLAG_LINE_STYLE);
end

local source, line, ma, ma_source;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    line = instance:addStream("TWAP", core.Line, "TWAP", "TWAP", instance.parameters.line_color, 0, 0);
    line:setWidth(instance.parameters.line_width);
    line:setStyle(instance.parameters.line_style);
    ma_source = instance:addInternalStream(0, 0);
    ma = core.indicators:create("MVA", ma_source)
end

function Update(period, mode)
    ma_source[period] = (source.close[period] + source.open[period] + source.high[period] + source.low[period]) / 4;
    ma:update(mode);
    line[period] = ma.DATA[period];
end