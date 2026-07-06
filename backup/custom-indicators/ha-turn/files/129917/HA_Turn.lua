-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69156

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
    indicator:name("HA Turn");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
end

local source, ha;
local up_color, down_color, out;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;
    if nameOnly then
        return ;
    end

    ha = core.indicators:create("HA", source);
    out = instance:addStream("out", core.Bar, "Out", "Out", instance.parameters.up_color, 0, 0);
end

function Update(period, mode)
    ha:update(mode);
    if period == 0 then
        return;
    end
    if ha.close[period] > ha.open[period] and ha.close[period - 1] < ha.open[period - 1] then
        out[period] = 1;
        out:setColor(period, up_color);
    elseif ha.close[period] < ha.open[period] and ha.close[period - 1] > ha.open[period - 1] then
        out[period] = -1;
        out:setColor(period, down_color);
    end
end