-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69493

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("CYBER CYCLE WITH INVERSE FISHER TRANSFORM");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addDouble("Alpha", "Alpha", "", 0.07);

    indicator.parameters:addColor("ICycle_color", "ICycle Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("ICycle_width", "ICycle Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ICycle_style", "ICycle Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ICycle_style", core.FLAG_LINE_STYLE);
end

local source, Alpha, Smooth, Cycle, ICycle;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Alpha = instance.parameters.Alpha;
    Smooth = instance:addInternalStream(0, 0);
    Cycle = instance:addInternalStream(0, 0);

    ICycle = instance:addStream("ICycle", core.Line, "ICycle", "ICycle", instance.parameters.ICycle_color, 0, 0);
    ICycle:setWidth(instance.parameters.ICycle_width);
    ICycle:setStyle(instance.parameters.ICycle_style);
end

function Update(period, mode)
    s1 = 0;
    if period >= 1 and source:hasData(period - 1) then
        s1 = source[period - 1];
    end
    s2 = 0;
    if period >= 2 and source:hasData(period - 2) then
        s2 = source[period - 2];
    end
    s3 = 0;
    if period >= 3 and source:hasData(period - 3) then
        s3 = source[period - 3];
    end
    Smooth[period] = (source[period] + 2 * s1 + 2 * s2 + s3) / 6;

    if period < 3 or not Smooth:hasData(period - 2) then
        return;
    end
    if Cycle:hasData(period - 2) then
        Cycle[period] = (1 - 0.5 * Alpha) * (1 - 0.5 * Alpha) * (Smooth[period] - 2 * Smooth[period - 1] + Smooth[period - 2])
            + 2 * (1 - Alpha) * Cycle[period - 1] - (1 - Alpha) * (1 - Alpha) * Cycle[period - 2];
        ICycle[period] = (math.exp(2 * Cycle[period]) - 1) / (math.exp(2 * Cycle[period]) + 1);
    else
        Cycle[period] = 0;
    end
    
end