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
    indicator:name("Absolute Chande Momentum Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P", "Periods", "", 9);
    indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("CMO_color", "Color of the line", "Color of the line", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
local P;
local sc;

local first;
local first_cm;
local source = nil;

-- Streams block
local cmo1 = nil;
local cmo2 = nil;
local CMO = nil;

-- Routine
function Prepare(nameOnly)
    P = instance.parameters.P;
    source = instance.source;
    first_cm = source:first() + 1;
    first = first_cm + P;
    sc = 2 / (P + 1);
    local name = profile:id() .. "(" .. source:name() .. ", " .. P .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    cmo1 = instance:addInternalStream(first_cm, 0);
    cmo2 = instance:addInternalStream(first_cm, 0);
    CMO = instance:addStream("CMO", core.Line, name, "CMO", instance.parameters.CMO_color, first);
    CMO:addLevel(0);
    CMO:addLevel(1);
    CMO:setWidth(instance.parameters.width);
    CMO:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period)
    cmo1[period] = 0;
    cmo2[period] = 0;

    if period >= first_cm then
        -- calculate CMO
        local diff;
        diff = source[period] - source[period - 1];
        if diff > 0 then
            cmo1[period] = diff;
        elseif diff < 0 then
            cmo2[period] = -diff;
        end
    end

    if period >= first then
        local p, cmo, s1, s2;

            s1 = mathex.sum(cmo1, period-P+1, period);
            s2 = mathex.sum(cmo2, period-P+1, period);
        
        CMO[period] = math.abs((s1 - s2) / (s1 + s2) * 100) / 100;
    end
end
