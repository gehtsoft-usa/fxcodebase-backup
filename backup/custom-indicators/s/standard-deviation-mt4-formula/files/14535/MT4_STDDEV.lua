-- Id: 4517
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6299

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
    indicator:name("MT4 version of standard deviation");
    indicator:description("Calculation of standard deviation exactly as in iStdDev formula of MT4");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("Periods", "Periods", "", 20, 1, 1000);
    indicator.parameters:addString("Method", "Moving Average Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "Simple Moving Average", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "Exponential Moving Average", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Linear weighted moving average", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "Smoothed moving average", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "Least Square Moving Average", "", "REGRESSION");
    indicator.parameters:addStringAlternative("Method", "Kaufman Moving Average", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilders Moving Average", "", "WMA");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("C", "Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("W", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("S", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("S", core.FLAG_LEVEL_STYLE);
end

local ma;
local source;
local Periods;
local out;
local first;


function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.parameters.Periods .. "," .. instance.parameters.Method .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    source = instance.source;
    Periods = instance.parameters.Periods;
    assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, instance.parameters.Method .. " indicator must be installed");
    ma = core.indicators:create(instance.parameters.Method, instance.source, instance.parameters.Periods);

    first = math.max(source:first(), ma.DATA:first()) + Periods;
    out = instance:addStream("iStdDev", core.Line, name, "iStdDev", instance.parameters.C, first);
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    out:setWidth(instance.parameters.W);
    out:setStyle(instance.parameters.S);
end

function Update(period, mode)
    ma:update(mode);
    if period >= first then
        local amount = 0;
        local movingAverage = ma.DATA[period];
        local i;
        for i = period - Periods + 1, period, 1 do
            amount = amount + math.pow(source[i] - movingAverage, 2);
        end
        out[period] = math.sqrt(amount / Periods);
    end
end
