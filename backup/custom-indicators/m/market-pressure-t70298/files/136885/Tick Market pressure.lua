-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70298

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
    indicator:name("Market pressure");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
 
local Oscillator;  
local Up, Down;

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
    first=source:first()+Period+1;
	
	Up= instance:addInternalStream(0, 0);
    Down= instance:addInternalStream(0, 0);
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first	);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    if period <=  source:first ()
	then
	return;
	end

		if source [period]> source [period-1] then
		Up[period]=math.abs(source[period]- source[period-1]);
		Down[period]=0;
		else
		Down[period]=math.abs(source[period]- source[period-1]);
		Up[period]=0;
		end
		
		
	if period <  first 
	then
	return;
	end
	
	
	 
		
     Oscillator[period ]= mathex.avg(Up, period -Period+1, period)-mathex.avg(Down, period -Period+1, period);
				  
end



