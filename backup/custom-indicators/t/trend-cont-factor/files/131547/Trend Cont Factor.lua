-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69467

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
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
    indicator:name("Trend Cont Factor");
    indicator:description("S&C 2002-03");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Length", "Period", "", 35)

    indicator.parameters:addColor("PlusTCF_color", "PlusTCF Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("PlusTCF_width", "PlusTCF Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("PlusTCF_style", "PlusTCF Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("PlusTCF_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("MinusTCF_color", "MinusTCF Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("MinusTCF_width", "MinusTCF Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("MinusTCF_style", "MinusTCF Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("MinusTCF_style", core.FLAG_LINE_STYLE);
end

local source, PlusTCF_source, MinusTCF_source, PlusTCF, MinusTCF, PlusCF, MinusCF, Length;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Length = instance.parameters.Length;
    PlusCF = instance:addInternalStream(0, 0);
    MinusCF = instance:addInternalStream(0, 0);
    PlusTCF_source = instance:addInternalStream(0, 0);
    MinusTCF_source = instance:addInternalStream(0, 0);

    PlusTCF = instance:addStream("PlusTCF", core.Line, "PlusTCF", "PlusTCF", instance.parameters.PlusTCF_color, 0, 0);
    PlusTCF:setWidth(instance.parameters.PlusTCF_width);
    PlusTCF:setStyle(instance.parameters.PlusTCF_style);

    MinusTCF = instance:addStream("MinusTCF", core.Line, "MinusTCF", "MinusTCF", instance.parameters.MinusTCF_color, 0, 0);
    MinusTCF:setWidth(instance.parameters.MinusTCF_width);
    MinusTCF:setStyle(instance.parameters.MinusTCF_style);
end

function Update(period, mode)
    if period == 1 then
        return;
    end
    local Change = source.close[period] - source.close[period - 1];
    local PlusChange = 0;
    local MinusChange = 0;
    PlusCF[period] = 0;
    MinusCF[period] = 0;
    PlusTCF_source[period] = 0;
    MinusTCF_source[period] = 0;
    if Change > 0 then
        PlusChange = Change;
        if PlusCF:hasData(period - 1) then
            PlusCF[period] = PlusChange + PlusCF[period - 1];
        else
            PlusCF[period] = PlusChange;
        end
    else
        MinusChange = -Change;
        if MinusCF:hasData(period - 1) then
            MinusCF[period] = MinusChange + MinusCF[period - 1];
        else
            MinusCF[period] = MinusChange;
        end
    end
    PlusTCF_source[period] = PlusChange - MinusCF[period];
    MinusTCF_source[period] = MinusChange - PlusCF[period];
    if period < Length + 1 then
        return;
    end
    PlusTCF[period] = mathex.sum(PlusTCF_source, period - Length, period);
    MinusTCF[period] = mathex.sum(MinusTCF_source, period - Length, period);
end