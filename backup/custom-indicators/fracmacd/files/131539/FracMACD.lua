-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69462

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
    indicator:name("Fractal MACD");
    indicator:description("S&C 2003-12");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("ShortMACDLength", "ShortMACDLength", "", 14)
    indicator.parameters:addInteger("LongMACDLength", "LongMACDLength", "", 26)
    indicator.parameters:addInteger("MACDSmoothing", "MACDSmoothing", "", 9)

    indicator.parameters:addColor("FracMACD_color", "FracMACD Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("FracMACD_width", "FracMACD Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("FracMACD_style", "FracMACD Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("FracMACD_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("smooth_color", "Smoothing Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("smooth_width", "Smoothing Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("smooth_style", "Smoothing Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("smooth_style", core.FLAG_LINE_STYLE);
end

local source, fast, slow, sm, smooth, FracMACD, smooth_data, FracMACD;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    fast = core.indicators:create("MVA", source, instance.parameters.ShortMACDLength);
    slow = core.indicators:create("MVA", source, instance.parameters.LongMACDLength);

    FracMACD = instance:addStream("FracMACD", core.Line, "FracMACD", "FracMACD", instance.parameters.FracMACD_color, 0, 0);
    FracMACD:setWidth(instance.parameters.FracMACD_width);
    FracMACD:setStyle(instance.parameters.FracMACD_style);
    sm = core.indicators:create("MVA", FracMACD, instance.parameters.MACDSmoothing);

    smooth = instance:addStream("Smooth", core.Line, "Smooth", "Smooth", instance.parameters.smooth_color, 0, 0);
    smooth:setWidth(instance.parameters.smooth_width);
    smooth:setStyle(instance.parameters.smooth_style);
end

function Update(period, mode)
    fast:update(mode);
    slow:update(mode);
    FracMACD[period] = fast.DATA[period] / slow.DATA[period];
    sm:update(mode);
    smooth[period] = sm.DATA[period]; 
end