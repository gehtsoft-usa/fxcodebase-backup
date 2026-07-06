
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69806

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
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
--+------------------------------------------------------------------+

function Init()
    indicator:name("Tether Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("Length", "Length", "", 55);
    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

local source, Length, out, up_color, down_color;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Length = instance.parameters.Length;
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;
    out = instance:addStream("out", core.Line, "Out", "Out", up_color, 0, 0);
	
	out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);
    out:setPrecision(math.max(2, source:getPrecision()));
end

function Update(period, mode)
    if period < Length then
        return;
    end
    local ll, hh = mathex.minmax(source, period - Length + 1, period)
    out[period] = (ll + hh) / 2;
    if source.close[period] > out[period] then
        out:setColor(period, up_color);
    else
        out:setColor(period, down_color);
    end
end