-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69065

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
    indicator:name("Sixths");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("color_1", "Color 1", "", core.colors().Blue);
    indicator.parameters:addColor("color_2", "Color 2", "", core.colors().Maroon);
    indicator.parameters:addColor("color_3", "Color 3", "", core.colors().Gainsboro);
    indicator.parameters:addColor("color_4", "Color 4", "", core.colors().Maroon);
    indicator.parameters:addColor("color_5", "Color 5", "", core.colors().Blue);
end

local source;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(1, context.SOLID, 1, instance.parameters.color_1);
        context:createPen(2, context.SOLID, 1, instance.parameters.color_2);
        context:createPen(3, context.SOLID, 1, instance.parameters.color_3);
        context:createPen(4, context.SOLID, 1, instance.parameters.color_4);
        context:createPen(5, context.SOLID, 1, instance.parameters.color_5);
        init = true;
    end
    core.host:trace("test");
    local range = context:bottom() - context:top();
    local step = range / 6;
    for i = 1, 5 do
        context:drawLine(i, context:left(), context:top() + i * step, context:right(), context:top() + i * step);
    end
end