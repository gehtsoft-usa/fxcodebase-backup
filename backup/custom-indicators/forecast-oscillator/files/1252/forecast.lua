-- Id: 432
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=693

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
    indicator:name("Forecast Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "N", "Number of periods", 20, 2, 300);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("FO_color", "Color", "Color of Forecast line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local first;
local source = nil;

-- Streams block
local FO = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    source = instance.source;
    first = source:first() + N + 1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    FO = instance:addStream("F", core.Line, name, "F", instance.parameters.FO_color, first);
    FO:setPrecision(math.max(2, instance.source:getPrecision()));
	FO:setWidth(instance.parameters.width);
    FO:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local sx, sy, sxy, sx2, i, t, a, b, tsf;
        t = N;
        sx = 0;
        sy = 0;
        sxy = 0;
        sx2 = 0;
        for i = period - N, period - 1, 1 do
            sy = sy + source[i];
            sx = sx + t;
            sx2 = sx2 + t * t;
            sxy = sxy + source[i] * t;
            t = t - 1;
        end
        b = (N * sxy - sx * sy) / (N * sx2 - sx * sx);
        a = (sy - b * sx) / N;
        tsf = a + b;
        FO[period] = (source[period] - tsf) / source[period] * 100;

    else
        FO[period] = nil;
    end
end

