-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=301&sid=6eb856b7a0e3a5289eb215e2282f8b31

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
    indicator:name("Chande's Variable Index Dynamic Average 1992 version");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("S", "Short range", "", 9);
    indicator.parameters:addInteger("L", "Long range", "", 20);
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("V_color", "Color of the line", "Color of the line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
local S;
local L;
local sc;

local first;
local first_cm;
local source = nil;

-- Streams block
local V = nil;

-- Routine
function Prepare(nameOnly)
    S = instance.parameters.S;
    L = instance.parameters.L;
    source = instance.source;
    first = source:first() + math.max(L, S);
    sc = 2 / (S + 1);
    local name = profile:id() .. "(" .. source:name() .. ", " .. S .. "," .. L .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    V = instance:addStream("V", core.Line, name, "V", instance.parameters.V_color, first);
	V:setWidth(instance.parameters.width);
    V:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period)
    if period == first then
        V[period] = source[period];
    elseif period > first then
        local   cmo, s1, s2;
        s1 = mathex.stdev(source, period-S+1,period);
        s2 = mathex.stdev(source,  period-L+1,period);
        cmo = s1 / s2;
        V[period] = sc * cmo * source[period] + (1 - sc * cmo) * V[period - 1];
    end
end

