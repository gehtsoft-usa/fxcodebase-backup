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
    indicator:name("TRsV Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addInteger("length", "Length", "", 10);

    indicator.parameters:addColor("trsv_color", "TRsV Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("trsv_width", "TRsV Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("trsv_style", "TRsV Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("trsv_style", core.FLAG_LINE_STYLE);
end

local source, trsv, atr;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    trsv = instance:addStream("TRsV", core.Bar, "TRsV", "TRsV", instance.parameters.trsv_color, 0, 0);
    trsv:setWidth(instance.parameters.trsv_width);
    trsv:setStyle(instance.parameters.trsv_style);

    atr = core.indicators:create("ATR", source, instance.parameters.length);
end

function Update(period, mode)
    atr:update(mode);

    trsv[period] = source.volume[period] / atr.DATA[period];
end