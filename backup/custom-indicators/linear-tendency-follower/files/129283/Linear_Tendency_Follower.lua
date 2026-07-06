-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69030

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
    indicator:name("Linear Tendency Follower");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("length", "Length", "", 200);
    indicator.parameters:addColor("main_color", "Color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("main_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("main_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("main_style", core.FLAG_LINE_STYLE);
end

local out, slope;
local source, length;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    length = instance.parameters.length;

    slope = instance:addInternalStream(0, 0);
    out = instance:addStream("out", core.Line, "Out", "Out", instance.parameters.main_color, 0, 0);
    out:setWidth(instance.parameters.main_width);
    out:setStyle(instance.parameters.main_style);
end

function Update(period, mode)
    if period < length then
        return;
    end
    slope[period] = slope[period - 1];
    if period % length == 0 then
        slope[period] = (source[period] - source[period - length]) / length;
        out[period] = source[period - length - 1];
    elseif (slope ~= nil) then
        out[period] = out[period - 1] + slope[period];
    end
end