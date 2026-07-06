-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1962
-- Id: 1371

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("On Balance Volume");
    indicator:description("Displays volume as a histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addColor("clrV", "Indicator Color", "", core.rgb(65, 105, 225));
end

local close;
local volume;
local first;
local V;

function Prepare(nameOnly)

    assert(instance.source:supportsVolume(), "The source must have volume");

    close = instance.source.close;
    volume = instance.source.volume;
    first = instance.source:first();


    local name;
    name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    V = instance:addStream("OBV", core.Line, name, "OBV", instance.parameters.clrV, first);
    V:setPrecision(0);
end

function Update(period, mode)
    if period == first then
        V[period] = volume[period];
    elseif period > first then
        if close[period] > close[period - 1] then
            V[period] = V[period - 1] + volume[period];
        elseif close[period] < close[period - 1] then
            V[period] = V[period - 1] - volume[period];
        else
            V[period] = V[period - 1];
        end
    end
end

