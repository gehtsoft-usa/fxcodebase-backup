-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=195

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


-- initializes the indicator
function Init()
    indicator:name("Smoothed Moving Average");
    indicator:description("The Smoothed Moving Average gives the recent prices an equal weighting to the historic ones.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Moving Averages");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 7, 2, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color of the line", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "Width of the line", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style of the line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first = 0;
local n = 0;
local source = nil;
local out = nil;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    n = instance.parameters.N;
    first = n + source:first() - 1;
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    out = instance:addStream("SMMA", core.Line, name, "SMMA", instance.parameters.clr,  first)
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);
end

-- calculate the value
function Update(period)
    if (period == first) then
        out[period] =  mathex.avg(source, period- n+1, period);
    elseif (period > first) then
        local sum;
        sum  = mathex.sum(source,  period-1 -n+1, period-1);
        out[period] = (out[period - 1] * n - out[period - 1] + source[period]) / n;
    end
end

