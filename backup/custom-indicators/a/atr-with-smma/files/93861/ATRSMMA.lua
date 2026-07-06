-- Id: 11676
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60655

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
 

-- The ATR indicator as described here http://en.wikipedia.org/wiki/Average_true_range.
-- Unlike the standard ATR indicator this one uses SMMA instead of simple MA on true ranges stream.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Average True Range with SMMA");
    indicator:description("Measures market volatility. Uses SMMA of the true ranges.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volatility");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "The number of periods.", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", "Line color", 
        string.format("The color of the %s.", "Average True Range line"), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthATR", "Line width",
        string.format("The width of the %s.", "Average True Range line"), 1, 1, 5);
    indicator.parameters:addInteger("styleATR", "Line style",
        string.format("The style of the %s.", "Average True Range line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleATR", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local tr = nil;
local trFirst = nil;
local tAbs = math.abs;

-- Streams block
local ATR = nil;

-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    tr = instance:addInternalStream(source:first() + 1, 0);
    first = tr:first() + n;
    ATR = instance:addStream("ATR", core.Line, name, "ATR", instance.parameters.clrATR, first)
    ATR:setWidth(instance.parameters.widthATR);
    ATR:setStyle(instance.parameters.styleATR);
    local precision = math.max(2, source:getPrecision());
    ATR:setPrecision(precision);
    trFirst = tr:first();
end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- Indicator calculation routine
function Update(period)
    if period >= trFirst then
        tr[period] = getTrueRange(period);
    end
    if (period == first) then
        ATR[period] = mathex.avg(tr, period - n + 1, period);        
    elseif (period > first) then
        ATR[period] = (ATR[period - 1] * (n - 1) + tr[period]) / n;
    end
end




