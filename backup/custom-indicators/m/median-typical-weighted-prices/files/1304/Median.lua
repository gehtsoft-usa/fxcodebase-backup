-- Id: 457
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=718

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Shows median, typical or weighted price");
    indicator:description("No description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("T", "Price To Show", "", "0");
    indicator.parameters:addStringAlternative("T", "Median (H+L)/2", "", "0");
    indicator.parameters:addStringAlternative("T", "Typical (H+L+C)/3", "", "1");
    indicator.parameters:addStringAlternative("T", "Weighted (H+L+2C)/4", "", "2");
    indicator.parameters:addColor("L_color", "Color of L", "Color of L", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local T;

local first;
local source = nil;

-- Streams block
local L = nil;

-- Routine
function Prepare(nameOnly)
    T = tonumber(instance.parameters.T);
    local TN;
    if T == 0 then
        TN = "Median";
        source = instance.source.median;
    elseif T == 1 then
        TN = "Typical";
        source = instance.source.typical;
    elseif T == 2 then
        TN = "Weighted";
        source = instance.source.weighted;
    end
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. TN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    L = instance:addStream("L", core.Line, name, "L", instance.parameters.L_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first then
        L[period] = source[period];
    end
end

