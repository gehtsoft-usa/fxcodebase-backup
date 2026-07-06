-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68468

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ADR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("y_shift", "Lavel Y shift", "", 50);
    indicator.parameters:addDouble("HighPercent", "High Percent", "", 91);
    indicator.parameters:addDouble("LowPercent", "Low Percent", "", 75);
    indicator.parameters:addColor("labelColor", "Label Color", "", core.rgb(255, 255, 0))
    indicator.parameters:addColor("MediumColor", "Medium Color", "", core.colors().Yellow)
    indicator.parameters:addColor("HighColor", "High Color", "", core.colors().Red)
    indicator.parameters:addColor("LowColor", "Low Color", "", core.colors().Lime)
end

local source, d1_source;
local HighPercent, LowPercent

function Prepare(nameOnly) 
    source = instance.source;
    HighPercent = instance.parameters.HighPercent / 100;
    LowPercent = instance.parameters.LowPercent / 100;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if (nameOnly) then
        return;
    end

    d1_source = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), 30, 1, 2);
    instance:ownerDrawn(true);
end
local day_value, day5_value, day10_value, day20_value, today
local labelColor, LowColor, HighColor, MediumColor
function GetColor(rate)
    if rate < LowPercent then
        return LowColor;
    end
    if rate > HighPercent then
        return HighColor;
    end
    return MediumColor;
end
local gap = 5;
local FONT_ID = 1;

function DrawValuePr(context, label, val, x, y)
    local rate = val / ((day10_value + day20_value) / 2);
    local w, h = context:measureText(FONT_ID, label, 0);
    context:drawText(FONT_ID, label, labelColor, -1, x, y, x + w, y + h, 0);
    x = x + w;
    local str = win32.formatNumber(100 * rate, false, 1) .. "%%";
    w, h = context:measureText(FONT_ID, str, 0);
    context:drawText(FONT_ID, str, GetColor(rate), -1, x, y, x + w, y + h, 0);
    return x + w + gap;
end

function DrawValue(context, label, val, x, y)
    local rate = val * d1_source:pipSize() / ((day10_value + day20_value) / 2);

    local w, h = context:measureText(FONT_ID, label, 0);
    context:drawText(FONT_ID, label, labelColor, -1, x, y, x + w, y + h, 0);
    x = x + w;
    local str = win32.formatNumber(val, false, 0);
    w, h = context:measureText(FONT_ID, str, 0);
    context:drawText(FONT_ID, str, GetColor(rate), -1, x, y, x + w, y + h, 0);
    return x + w + gap;
end

local init = false;
local y_shift
function Draw(stage, context)
    if stage ~= 2 or day_value == nil then
        return;
    end
    if not init then
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(12), 0);
        labelColor = instance.parameters.labelColor;
        LowColor = instance.parameters.LowColor;
        HighColor = instance.parameters.HighColor;
        MediumColor = instance.parameters.MediumColor;
        y_shift = instance.parameters.y_shift;
        init = true;
    end
    local x = context:left();
    local y = context:top() + y_shift;

    x = DrawValuePr(context, "ADR: ", today, x, y);
    x = DrawValue(context, "Today: ", today, x, y);
    x = DrawValue(context, "1 Day: ", day_value, x, y);
    x = DrawValue(context, "5 Day: ", day5_value, x, y);
    x = DrawValue(context, "10 Day: ", day10_value, x, y);
    x = DrawValue(context, "20 Day: ", day20_value, x, y);
end

function Update(period, mode)
    if d1_source:size() == 0 then
        return;
    end
    day_value = (d1_source.high[NOW - 1] - d1_source.low[NOW - 1]) / d1_source:pipSize();
    day5_value = day_value;
    for i = 2, 5 do
        day5_value = day5_value + (d1_source.high[NOW - i] - d1_source.low[NOW - i]) / d1_source:pipSize();
    end
    day10_value = day5_value;
    for i = 6, 10 do
        day10_value = day10_value + (d1_source.high[NOW - i] - d1_source.low[NOW - i]) / d1_source:pipSize();
    end
    day20_value = day10_value;
    for i = 11, 20 do
        day20_value = day20_value + (d1_source.high[NOW - i] - d1_source.low[NOW - i]) / d1_source:pipSize();
    end
    day5_value = day5_value / 5;
    day10_value = day10_value / 10;
    day20_value = day20_value / 20;
    today = (d1_source.high[NOW] - d1_source.low[NOW]) / d1_source:pipSize();
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
end