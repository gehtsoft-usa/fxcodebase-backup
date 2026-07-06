-- Id: 2217
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=248

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Wilders Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("N", "Number of periods", "", 14, 2, 10000);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("clrWMA", "Color of WMA line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", " WMA Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", " WMA Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first = 0;
local n = 0;
local k = 0;
local source = nil;
local out = nil;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    n = instance.parameters.N;
    n1 = 2 * n - 1;
    k = 2.0 / (n1 + 1.0);
    first = source:first() + n1 - 1;
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    out = instance:addStream("WMA", core.Line, name, "WMA", instance.parameters.clrWMA,  first);
	out:setWidth(instance.parameters.width);
	out:setStyle(instance.parameters.style);
end

-- calculate the value
function Update(period)
    if (period == first) then
        out[period] = core.avg(source, core.rangeTo(period, n));
    elseif (period > first) then
        out[period] = ((source[period] - out[period - 1]) * k) + out[period - 1];
    end
end

