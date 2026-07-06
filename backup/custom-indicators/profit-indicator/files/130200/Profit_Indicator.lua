
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69224

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
    indicator:name("Profit indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addColor("profit_color", "Profit color", "", core.colors().Green);
    indicator.parameters:addColor("loss_color", "Loss color", "", core.colors().Red);
    indicator.parameters:addInteger("x", "X", "", 50);
    indicator.parameters:addInteger("y", "Y", "", 50);
    indicator.parameters:addInteger("w", "Width", "", 100);
    indicator.parameters:addInteger("h", "Height", "", 20);
end

local source;
local profit_color, loss_color;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    profit_color = instance.parameters.profit_color;
    loss_color = instance.parameters.loss_color;
    instance:ownerDrawn(true);
end

local init = false;
local PEN_PROFIT = 1;
local PEN_LOSS = 2;
local BRUSH_PROFIT = 3;
local BRUSH_LOSS = 4;
local x, y, h, w;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(PEN_PROFIT, context.SOLID, 1, instance.parameters.profit_color);
        context:createPen(PEN_LOSS, context.SOLID, 1, instance.parameters.loss_color);
        context:createSolidBrush(BRUSH_PROFIT, instance.parameters.profit_color);
        context:createSolidBrush(BRUSH_LOSS, instance.parameters.loss_color);
        x = instance.parameters.x;
        y = instance.parameters.y;
        h = instance.parameters.h;
        w = instance.parameters.w;
    end
    local summary = core.host:findTable("summary"):find("Instrument", source:instrument());
    local in_profit = true;
    if summary ~= nil then
        in_profit = summary.NetPL >= 0;
    end
    if in_profit then
        context:drawRectangle(PEN_PROFIT, BRUSH_PROFIT, context:right() - w - x, context:top() + y, context:right() - x, context:top() + y + h);
    else
        context:drawRectangle(PEN_LOSS, BRUSH_LOSS, context:right() - w - x, context:top() + y, context:right() - x, context:top() + y + h);
    end
end

function Update(period, mode)
end