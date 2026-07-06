-- Id: 23068
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67045

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("Bull-Bear")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addInteger("Period", "Period", "", 12);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0))
end

local out;
local temp1;

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    source = instance.source

    out = instance:addStream("Out", core.Bar, "Out", "Out", instance.parameters.Up, 0);
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    temp1 = instance:addInternalStream(0, 0);
end

function Update(period, mode)
    if period < instance.parameters.Period then
        return;
    end
    local lowest, highest = mathex.minmax(source, period - instance.parameters.Period, period);
    local highLowMiddle = (source.high[period] + source.low[period]) / 2.0;
    if (highest - lowest ~= 0) then
        local prevTemp = 0;
        if temp1:hasData(period - 1) then
            prevTemp = temp1[period - 1];
        end
        local val = 0.66 * ((highLowMiddle - lowest) / (highest - lowest) - 0.5) + 0.67 * prevTemp;
        temp1[period] = math.max(-0.999, math.min(0.999, val));

        local prevOut = 0;
        if out:hasData(period - 1) then
            prevOut = out[period - 1];
        end
        out[period] = math.log((temp1[period] + 1.0) / (1 - temp1[period])) / 2.0 + prevOut / 2.0;
    else
        temp1[period] = temp1[period - 1];
        out[period] = out[period - 1];
    end

    if out[period] < 0.0 then
        out:setColor(period, instance.parameters.Down);
    else
        out:setColor(period, instance.parameters.Up);
    end
end

