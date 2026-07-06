-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71104

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Kaufman Adaptive Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("length1", "length1", "", 14);
    indicator.parameters:addInteger("fastMA1", "fastMA1", "", 2);
    indicator.parameters:addInteger("slowMA1", "slowMA1", "", 20);
    indicator.parameters:addString("price", "Source", "", "close");
    indicator.parameters:addStringAlternative("price", "Open", "", "open");
    indicator.parameters:addStringAlternative("price", "High", "", "high");
    indicator.parameters:addStringAlternative("price", "Low", "", "low");
    indicator.parameters:addStringAlternative("price", "Close", "", "close");
    indicator.parameters:addStringAlternative("price", "Median", "", "median");
    indicator.parameters:addStringAlternative("price", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("price", "Weighted", "", "weighted");

    indicator.parameters:addColor("kama_color", "KAMA Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("kama_width", "KAMA Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("kama_style", "KAMA Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("kama_style", core.FLAG_LINE_STYLE);
end

local length1, fastMA1, slowMA1;
local source, kama, diff, src;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    slowMA1 = instance.parameters.slowMA1;
    fastMA1 = instance.parameters.fastMA1;
    length1 = instance.parameters.length1;
    kama = instance:addStream("kama", core.Line, "KAMA", "KAMA", instance.parameters.kama_color, 0, 0);
    kama:setWidth(instance.parameters.kama_width);
    kama:setStyle(instance.parameters.kama_style);
    diff = instance:addInternalStream(0, 0);
    src = source[instance.parameters.price];
end

function iff(condition, trueValue, falseValue)
    if condition then
        return trueValue;
    end
    return falseValue;
end

function nz(value)
    if value == nil then
        return 0;
    end
    return value;
end

function Update(period, mode)
    if period < 1 then
        return;
    end
    diff[period] = math.abs(src[period] - src[period - 1]);
    if period < length1 + 1 then
        return;
    end
    volatility1 = mathex.sum(diff, core.rangeTo(period, length1));
    change1 = math.abs(src[period] - src[period - length1 - 1]);
    er1 = iff(volatility1 ~= 0, change1 / volatility1, 0);
    fastSC1 = 2 / (fastMA1 + 1);
    slowSC1 = 2 / (slowMA1 + 1);
    sc1 = math.pow((er1 * (fastSC1 - slowSC1)) + slowSC1, 2);
    kama[period] = nz(kama[period - 1]) + (src[period] * (source.typical[period] - nz(kama[period - 1])))
end