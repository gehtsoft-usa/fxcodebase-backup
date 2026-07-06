-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1961

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
    indicator:name("Accumulation/Distribution");
    indicator:description("Indicator attempts to gauge supply and demand by determining whether investors are generally accumulating (buying) or distributing (selling) a certain stock by identifying divergences between stock price and volume flow.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("Prev", "Incremental", "If the parameter is true, then the previous bar value is added to the current bar value", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrAD", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthAD", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleAD", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleAD", core.FLAG_LINE_STYLE);
end

local source;
local h, l, c, v;
local first;
local AD;
local Prev;

function Prepare(nameOnly)
    source = instance.source;
    h = source.high;
    l = source.low;
    c = source.close;
    v = source.volume;
    first = source:first();
    Prev = instance.parameters.Prev;

    assert(source:supportsVolume(), "The source must have volume");

    local name;
    if Prev then
        name = profile:id() .. "(" .. source:name() .. ", Incremental)";
    else
        name = profile:id() .. "(" .. source:name() .. ", Simple)";
    end
    instance:name(name);
    if nameOnly then
        return;
    end

    AD = instance:addStream("AD", core.Line, name, "AD", instance.parameters.clrAD, first);
    AD:setPrecision(2);
    AD:setWidth(instance.parameters.widthAD);
    AD:setStyle(instance.parameters.styleAD);
    AD:addLevel(0);
end

function Update(period, mode)
    if period >= first then
        if h[period] - l[period] == 0 then
            AD[period] = 0;
        else
            AD[period] = ((c[period] - l[period]) - (h[period] - c[period])) / (h[period] - l[period]) * v[period];
        end
        if period >= first + 1 and Prev then
            AD[period] = AD[period] + AD[period - 1];
        end
    end
end
