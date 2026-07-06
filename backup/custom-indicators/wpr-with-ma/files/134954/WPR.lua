-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70019

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

function Init()
    indicator:name("Williams Percent Range (WPR)");
    indicator:description("Williams Percent Range (WPR)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "N", "Period", 14);
	
	
	 indicator.parameters:addGroup("MA Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
	
     indicator.parameters:addGroup("Line Style")
    indicator.parameters:addColor("clrWPR", "Color of Williams Percent Range", "Color of Williams Percent Range", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	  indicator.parameters:addGroup("MA Line Style")
    indicator.parameters:addColor("color1", "MA Line Color", "MA Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	
	 indicator.parameters:addBoolean("Lines", "Show MA Lines", "" , true); 
	  indicator.parameters:addBoolean("Cloud", "Show Cloud", "" , true); 
	  indicator.parameters:addBoolean("Colored_Line", "Show Colored_Line", "" , true); 
	  
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", -20);
    indicator.parameters:addDouble("oversold","Oversold Level","", -80);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

local first;
local source = nil;
local N;
local WPR;
local Period, Method;
local ma, MA;
local Lines, Transparency, Up, Down, Neutral,Cloud,Colored_Line;
function Prepare(nameOnly)
    source = instance.source;
    N=instance.parameters.N;
    first=source:first()+N;
	
	Period=instance.parameters.Period;
	Method=instance.parameters.Method;
	
	 Up = instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral;
   
   Colored_Line= instance.parameters.Colored_Line;
   
   Cloud= instance.parameters.Cloud;
   Lines= instance.parameters.Lines;
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	
	if  Lines and Colored_Line  then
    WPR = instance:addStream("WPR", core.Line, name .. ".Williams Percent Range", "Williams Percent Range", instance.parameters.clrWPR, first);
    WPR:setPrecision(math.max(2, instance.source:getPrecision()));
	WPR:setWidth(instance.parameters.width);
    WPR:setStyle(instance.parameters.style);
    WPR:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	WPR:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	else
	 WPR = instance:addStream("WPR", core.Line, name .. ".Williams Percent Range", "Williams Percent Range", instance.parameters.clrWPR, first);
    WPR:setPrecision(math.max(2, instance.source:getPrecision()));
	WPR:setWidth(instance.parameters.width);
    WPR:setStyle(core.LINE_NONE);
    WPR:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	WPR:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	end
	
	ma = core.indicators:create(Method, WPR, Period);
	
	if  Lines then
	MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.color1, ma.DATA:first());
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
	MA:setWidth(instance.parameters.width1);
    MA:setStyle(instance.parameters.style1);
	
	else
	MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.color1, ma.DATA:first());
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
	MA:setWidth(instance.parameters.width1);
    MA:setStyle(core.LINE_NONE);
	end
	
	if Cloud then
	instance:createChannelGroup("Group","Group" , WPR, MA, Neutral, Transparency);
	end
end


function Update(period, mode)
    if (period<first) then
	return;
	end
	
	 local min,max=mathex.minmax(source,period-N+1, period);
     WPR[period]=-((max-source.close[period])*100./(max-min));
	 
	 
	 
	ma:update(mode);
	
	if (period<ma.DATA:first()) then
	return;
	end
	
	
	MA[period]=ma.DATA[period];
	
	 
	if Cloud or Colored_Line then
		if WPR[period] > MA[period] then
		WPR:setColor(period, Up);
		elseif WPR[period] < MA[period] then
		WPR:setColor(period, Down);
		else
		WPR:setColor(period, Neutral);
		end
	end
	 
     
end

