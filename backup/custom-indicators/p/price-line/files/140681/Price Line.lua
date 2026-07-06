-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70914

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC |
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
    indicator:name("Price Line");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("shift", "Shift", "", 1);

    indicator.parameters:addColor("line_color", "Line Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("line_width", "Line Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("line_style", "Line Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style", core.FLAG_LINE_STYLE);
end

local source, shift, tradingWeekOffset, tradingDayOffset;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    shift = instance.parameters.shift;
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");

    instance:ownerDrawn(true)
end

function Update(period, mode)
end

local init = false;
local pen = 1;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(pen, context:convertPenStyle(instance.parameters.line_style), instance.parameters.line_width, instance.parameters.line_color);
    end
    local _, y = context:pointOfPrice(source[NOW - shift]);
    local s, e = core.getcandle(source:barSize(), source:date(NOW), tradingDayOffset, tradingWeekOffset);
    local x1 = context:positionOfDate(s)
    local x2 = context:positionOfDate(e)
    context:drawLine(pen, x1, y, x2, y);
    core.host:trace(y .. " " .. x1 .. " " .. x2);
end