-- Id: 24
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=21

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Fractal");
    indicator:description("Bill Williams Fractal oscillator")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("UpC", "Color of the up fractal", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DownC", "Color of the down fractal", "", core.rgb(0, 255, 0));
end

local source;
local up, down;

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id();
    instance:name(name);
    if nameOnly then
        return;
    end
    up = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.UpC, 4, -2);
    up:setPrecision(math.max(2, instance.source:getPrecision()));
    up:addLevel(1);
    up:addLevel(0);
    up:addLevel(-1);
    down = instance:addStream("Down", core.Bar, name .. ".Down", "Down", instance.parameters.DownC, 4, -2);
    down:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    if (period > 6) then
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
            up[period - 2] = 1;
        else
            up[period - 2] = nil;
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then
            down[period - 2] = -1;
        else
            down[period - 2] = nil;
        end
    end
end
