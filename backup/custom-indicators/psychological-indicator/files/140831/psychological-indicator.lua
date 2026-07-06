-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70941

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
--+------------------------------------------------------------------+

function Init()
    indicator:name("Psychological indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("PsychPeriod", "PsychPeriod", "", 25)
    
    indicator.parameters:addColor("line_color", "Color", "Color", core.colors().DodgerBlue);
    indicator.parameters:addInteger("line_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("line_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("level_color", "Levels Color", "Color", core.colors().Silver);
    indicator.parameters:addInteger("level_width", "Levels Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("level_style", "Levels Style", "Style", core.LINE_DOT);
    indicator.parameters:setFlag("level_style", core.FLAG_LINE_STYLE);
end

local source, PsychBuffer, PsychPeriod;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    PsychPeriod = instance.parameters.PsychPeriod;
    PsychBuffer = instance:addStream("PsychBuffer", core.Line, "PsychBuffer", "PsychBuffer", instance.parameters.line_color, 0, 0);
    PsychBuffer:setWidth(instance.parameters.line_width);
    PsychBuffer:setStyle(instance.parameters.line_style);
    PsychBuffer:addLevel(50, instance.parameters.level_style, instance.parameters.level_width, instance.parameters.level_color);
    PsychBuffer:addLevel(25, instance.parameters.level_style, instance.parameters.level_width, instance.parameters.level_color);
    PsychBuffer:addLevel(75, instance.parameters.level_style, instance.parameters.level_width, instance.parameters.level_color);
end

function Count(period)
    local count = 0;
    for i = period, period - PsychPeriod, -1 do
        if (source.close[i] > source.close[i - 1]) then
            count = count + 1;
        end
    end
    return count;
end

function Update(period, mode)
    if period < PsychPeriod + 1 then
        return;
    end
    PsychBuffer[period] = (Count(period) / PsychPeriod) * 100.0;
end