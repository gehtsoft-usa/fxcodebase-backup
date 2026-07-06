-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69480

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
    indicator:name("Market Pressure");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("candles", "Candles count", "", 50);
    indicator.parameters:addColor("label_color", "Label's color", "", core.colors().Red);
end

local source, candles;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    candles = instance.parameters.candles;
    instance:ownerDrawn(true);
end

function Update(period, mode)

end

local init = false;
local FONT = 1, label_color;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        label_color = instance.parameters.label_color;
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(12), 0);
    end

    local total = 0;
    local ascending = 0;
    for i = 0, candles, 1 do
        if source.close[NOW - i] > source.open[NOW - i] then
            ascending = ascending + 1;
        end
        total = total + 1;
    end
    bull_text = "Bull Presure: " .. math.floor(ascending / total * 100 + 0.5) .. "%";
    bear_text = "Bear Presure: " .. math.floor((total - ascending) / total * 100 + 0.5) .. "%";
    local w1, h1 = context:measureText(FONT, bull_text, 0);
    local w2, h2 = context:measureText(FONT, bear_text, 0);

    context:drawText(FONT, bull_text, label_color, -1, context:left(), context:bottom() - h2 - h1 - 5, context:left() + w1, context:bottom() - h2 - 5, 0);
    context:drawText(FONT, bear_text, label_color, -1, context:left(), context:bottom() - h2, context:left() + w2, context:bottom(), 0);
end