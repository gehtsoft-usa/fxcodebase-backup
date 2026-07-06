-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69460

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
    indicator:name("Support/Resistance Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("pip", "Pips", "", 3);

    indicator.parameters:addColor("line_color", "Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("line_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("line_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style", core.FLAG_LINE_STYLE);
end

local source, pip;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    pip = instance.parameters.pip;
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local LINE = 1;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(LINE, context:convertPenStyle(instance.parameters.line_style), instance.parameters.line_width, instance.parameters.line_color);
        init = true;
    end
    local price = source.open[NOW - 1] - pip * source:pipSize();
    if source.open[NOW - 1] > source.close[NOW - 1] then
        price = source.open[NOW - 1] + pip * source:pipSize();
    end
    local _, y = context:pointOfPrice(price);
    context:drawLine(LINE, context:left(), y, context:right(), y);
end