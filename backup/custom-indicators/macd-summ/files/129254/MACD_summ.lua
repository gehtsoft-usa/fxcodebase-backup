-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69024

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MACD summ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("MACD");
    indicator.parameters:addInteger("macd_SN", "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("macd_LN", "Long EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("macd_IN", "Signal Line", "", 9, 2, 1000);
    indicator.parameters:addGroup("Zero Lag MACD");
    indicator.parameters:addInteger("zlmacd_FMA", "Fast EMA periods", "", 12, 1, 5000);
    indicator.parameters:addInteger("zlmacd_SMA", "Slow EMA Periods", "", 24, 1, 5000);
    indicator.parameters:addInteger("zlmacd_SigMA", "Signal EMA periods", "", 9, 1, 5000);

    indicator.parameters:addGroup("Styling");
    indicator.parameters:addColor("color", "Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("font_size", "Font size", "", 12);
    indicator.parameters:addInteger("x", "X", "", 50);
    indicator.parameters:addInteger("y", "Y", "", 50);
end

local source;
local macd, zl;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    local profile = core.indicators:findIndicator("ZEROLAGMACD");
    assert(profile ~= nil, "Please, download and install " .. "ZEROLAGMACD" .. ".LUA indicator");
    zl = core.indicators:create("ZEROLAGMACD", source, instance.parameters.zlmacd_FMA, instance.parameters.zlmacd_SMA, instance.parameters.zlmacd_SigMA);
    macd = core.indicators:create("MACD", source, instance.parameters.macd_SN, instance.parameters.macd_LN, instance.parameters.macd_IN);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    zl:update(mode);
    macd:update(mode);
end

local init = false;
local FONT = 1;
local color, x, y;
function Draw(stage, context)
    if stage ~= 2 and zl.DATA:size() == 0 then
        return;
    end
    if not init then
        color = instance.parameters.color;
        x = instance.parameters.x;
        y = instance.parameters.y;
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(instance.parameters.font_size), 0);
        init = true;
    end
    local value = zl.DATA[NOW] + macd.DATA[NOW];
    local text = win32.formatNumber(value, false, source:getPrecision());
    local w, h = context:measureText(FONT, text, 0);
    context:drawText(FONT, text, color, -1, x + context:left(), y + context:top(), x + w + context:left(), y + h + context:top(), 0);
end