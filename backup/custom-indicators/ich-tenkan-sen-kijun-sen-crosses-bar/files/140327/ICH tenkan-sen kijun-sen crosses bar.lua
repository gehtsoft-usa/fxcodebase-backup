-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70849

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC |
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
    indicator:name("Ich Tenkan-sen & Kijun-sen crosses bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("TenkanSenPeriod", "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KijunSenPeriod", "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SenkouSpanPeriod", "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);

    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Blue);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
    indicator.parameters:addColor("neutral_color", "Neutral color", "", core.colors().Yellow);
end

local source, indi, up_color, down_color, neutral_color;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;
    neutral_color = instance.parameters.neutral_color;

    indi = core.indicators:create("ICH", source, instance.parameters.TenkanSenPeriod, 
        instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);

    out = instance:addStream("out", core.Bar, "Signal", "Signal", up_color, 0, 0)
    out:addLevel(0);
end

function Update(period, mode)
    indi:update(mode);
	
	if period < indi.SL:first()
	or period < indi.TL:first()
	then
	return;
	end
	
    out[period] = 1;
    if (indi.SL[period] > indi.TL[period]) then
        out:setColor(period, down_color)
    elseif (indi.SL[period] < indi.TL[period]) then
        out:setColor(period, up_color)
    else
        out:setColor(period, neutral_color)
    end
end