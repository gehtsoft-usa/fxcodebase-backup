-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69327

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--|                         https://AppliedMachineLearning.systems   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Gopalakrishnan Range Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("Period", "Period", "", 5)

    indicator.parameters:addColor("gapo_color", "Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("gapo_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("gapo_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("gapo_style", core.FLAG_LINE_STYLE);
end

local source, gapo, Period;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    Period = instance.parameters.Period;
    gapo = instance:addStream("GAPO", core.Line, "GAPO", "GAPO", instance.parameters.gapo_color, 0, 0);
    gapo:setWidth(instance.parameters.gapo_width);
    gapo:setStyle(instance.parameters.gapo_style);
end

function Update(period, mode)
    if period < Period then
        return;
    end
    local min, max = mathex.minmax(source, period - Period, period);
    gapo[period] = math.log(max - min) / math.log(Period);
end