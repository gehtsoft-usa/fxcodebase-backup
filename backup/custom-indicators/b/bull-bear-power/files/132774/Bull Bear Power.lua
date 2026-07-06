-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69482

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
    indicator:name("Bull Bear Power Trend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addBoolean("reg_trend_on", "Activate Reg Trend Line", "", false);
    indicator.parameters:addInteger("length", "?? Length Reg Trend line=", "", 8);

    indicator.parameters:addColor("BullTrend_color", "Bull Trend Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("BullTrend_width", "Bull Trend Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("BullTrend_style", "Bull Trend Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("BullTrend_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("BearTrend2_color", "Bear Trend Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("BearTrend2_width", "Bear Trend Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("BearTrend2_style", "Bear Trend Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("BearTrend2_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("Trend_color", "Trend Color", "Color",  core.rgb(128, 128, 128));
 

    indicator.parameters:addColor("Trend2_color", "Reg Trend Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("Trend2_width", "Reg Trend Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("Trend2_style", "Reg Trend Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("Trend2_style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 2);
    indicator.parameters:addDouble("oversold","Oversold Level","", -2);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


end

local source, atr, reg_trend_on, BullTrend, BearTrend2, Trend, Trend2, length, x;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    atr = core.indicators:create("ATR", source, 5);
    reg_trend_on = instance.parameters.reg_trend_on;
    length = instance.parameters.length;

    BullTrend = instance:addStream("BullTrend", core.Line, "BullTrend", "BullTrend", instance.parameters.BullTrend_color, 0, 0);
    BullTrend:setWidth(instance.parameters.BullTrend_width);
    BullTrend:setStyle(instance.parameters.BullTrend_style);
    BearTrend2 = instance:addStream("BearTrend2", core.Line, "BearTrend2", "BearTrend2", instance.parameters.BearTrend2_color, 0, 0);
    BearTrend2:setWidth(instance.parameters.BearTrend2_width);
    BearTrend2:setStyle(instance.parameters.BearTrend2_style);
    Trend = instance:addStream("Trend", core.Bar, "Trend", "Trend", instance.parameters.Trend_color, 0, 0);
 
    x = instance:addInternalStream(0, 0);
    if reg_trend_on then
        Trend2 = instance:addStream("Trend2", core.Line, "Trend2", "Trend2", instance.parameters.Trend2_color, 0, 0);
        Trend2:setWidth(instance.parameters.Trend2_width);
        Trend2:setStyle(instance.parameters.Trend2_style);
			
    end
	
	BullTrend:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	BullTrend:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
end

function Update(period, mode)
    if period < 50 then
        return;
    end

    atr:update(mode);
    local ll, hh = mathex.minmax(source, period - 50, period);
    BullTrend[period] = (source.close[period] - ll) / atr.DATA[period]
    BearTrend = (hh - source.close[period]) / atr.DATA[period]
    BearTrend2[period] = -1 * BearTrend;
    
    Trend[period] = BullTrend[period] - BearTrend;
    if reg_trend_on then
        x[period] = period;
        local range = core.rangeTo(period, length);
        x_ = mathex.avg(x, range);
        y_ = mathex.avg(Trend, range);
        mx = mathex.stdev(x, range);
        my = mathex.stdev(Trend, range);
        c = mathex.correl(x, Trend, period - length, period, period - length, period);
        slope = c * (my / mx)
        inter = y_ - slope * x_
        Trend2[period] = x[period] * slope + inter;
    end
end
