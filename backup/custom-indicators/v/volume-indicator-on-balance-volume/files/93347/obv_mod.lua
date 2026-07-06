-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1962
-- Id: 11424

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
    indicator:name("On Balance Volume modified");
    indicator:description("Displays volume as a histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Gate", "Gate, in pips", "", 2);

    indicator.parameters:addColor("clrV", "Indicator Color", "", core.rgb(65, 105, 225));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local source;
local close;
local volume;
local first;
local V;
local GatePips;

function Prepare(nameOnly)
    source = instance.source;

    assert(instance.source:supportsVolume(), "The source must have volume");

    close = instance.source.close;
    volume = instance.source.volume;
    first = instance.source:first();


    local name;
    name = profile:id() .. "(" .. instance.source:name() .. ", " .. instance.parameters.Gate .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    V = instance:addStream("OBV", core.Line, name, "OBV", instance.parameters.clrV, first);
    V:setWidth(instance.parameters.widthLinReg);
    V:setStyle(instance.parameters.styleLinReg);
    V:setPrecision(0);
    GatePips=instance.parameters.Gate*source:pipSize();
end

function Update(period, mode)
    if period == first then
        V[period] = volume[period];
    elseif period > first then
        if close[period] > close[period - 1]+GatePips then
            V[period] = V[period - 1] + volume[period];
        elseif close[period] < close[period - 1]-GatePips then
            V[period] = V[period - 1] - volume[period];
        else
            V[period] = V[period - 1];
        end
    end
end

