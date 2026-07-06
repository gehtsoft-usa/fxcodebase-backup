-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70592

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


-- Indicator profile initialization routine

function Init()
    indicator:name("RAW_STOCHASTIC");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 21, 1, 2000);
	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
 
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("OB", "OB Level","", 80);
	indicator.parameters:addDouble("OS", "OS Level","", 20); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period ; 
local first;
local source = nil;
 
local STOCHASTIC;  
 
local OB,OS;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period; 
	OB= instance.parameters.OB;
	OS= instance.parameters.OS;
	
	local Parameters= Period ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  
			
    source = instance.source; 
    first=source:first()+Period;
	 
 
	STOCHASTIC = instance:addStream("STOCHASTIC" , core.Line, " STOCHASTIC"," STOCHASTIC",instance.parameters.color1, first) ;
	STOCHASTIC:setWidth(instance.parameters.width1);
    STOCHASTIC:setStyle(instance.parameters.style1);
    STOCHASTIC:setPrecision(math.max(2, source:getPrecision()));
	
	STOCHASTIC:addLevel(instance.parameters.OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	STOCHASTIC:addLevel(instance.parameters.OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	 
end
 


-- Indicator calculation routine
function Update(period, mode)
 
	
	if period < first  
	then
	return;
	end
 
 
	local min,max=mathex.minmax(source,period-Period+1, period); 
   
	if min~=max then	
     STOCHASTIC[period]= (source.close[period]-min)/(max-min)*100;			
    else
	 STOCHASTIC[period]= 0;
    end	
end

 

 