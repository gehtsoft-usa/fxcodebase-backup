-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69960

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
    indicator:name("Bias");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
 
	
	indicator.parameters:addGroup("Up Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Down Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Current Bar Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
  
local Up, Down, Current;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first() +1;
	
	
	Current = instance:addStream("Current" , core.Bar, " Current"," Current",instance.parameters.color3, first  );
    Current:setPrecision(math.max(2, source:getPrecision()));
 
	Up = instance:addStream("Up" , core.Line, " Up"," Up",instance.parameters.color1, first +Period);
	Up:setWidth(instance.parameters.width1);
    Up:setStyle(instance.parameters.style1);
    Up:setPrecision(math.max(2, source:getPrecision()));
	
	Down = instance:addStream("Down" , core.Line, " Down"," Down",instance.parameters.color2, first  +Period);
	Down:setWidth(instance.parameters.width2);
    Down:setStyle(instance.parameters.style2);
    Down:setPrecision(math.max(2, source:getPrecision()));
	
	
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period <= first
	then
	return;
	end
	
	
	if source[period]> source[period-1] then
	Current[period]=1;
	else
	Current[period]=0;
	end
	
	if period <= first+Period
	then
	return;
	end
	
	
	Up[period]=mathex.sum(Current, period-Period+1, period);
	Down[period]= Period-Up[period];
	
		

end

