-- Id: 454
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=716

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
    indicator:name("Detrend Price Oscillator");
    indicator:description("Oscillator eliminates the trend effect of price movement.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("N", "Number of periods", "", 12);
    indicator.parameters:addColor("L_color", "Color of oscillator", "Color of oscillator", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;

local first;
local source = nil;

-- Streams block
local L = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    N = N / 2 + 1;
    first = source:first() + N;
    L = instance:addStream("L", core.Line, name, "L", instance.parameters.L_color, first);
    L:setPrecision(math.max(2, instance.source:getPrecision()));
    L:addLevel(0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first then
        local range;
        range = core.rangeTo(period, N);
        L[period] = source[period] - core.avg(source, range);
    end
end

