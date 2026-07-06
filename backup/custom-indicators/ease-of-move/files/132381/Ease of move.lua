-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69595

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                                Patreon :  https://goo.gl/GdXWeN  |   
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Ease of move");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
   
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0));
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
local AverageUp,  AverageDown;
local Oscillator;  
local Up, Down,CountUp,CountDown;
 
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
    first=source:first()+Period;
	
	 Up= instance:addInternalStream(0, 0);
     Down= instance:addInternalStream(0, 0);
	 CountUp= instance:addInternalStream(0, 0);
	 CountDown= instance:addInternalStream(0, 0);
 
	AverageUp = instance:addStream("AverageUp" , core.Line, " AverageUp"," AverageUp",instance.parameters.color1, first );
	AverageUp:setWidth(instance.parameters.width);
    AverageUp:setStyle(instance.parameters.style);
    AverageUp:setPrecision(math.max(2, source:getPrecision()));
	
	AverageDown = instance:addStream("AverageDown" , core.Line, " AverageDown"," AverageDown",instance.parameters.color2, first );
	AverageDown:setWidth(instance.parameters.width);
    AverageDown:setStyle(instance.parameters.style);
    AverageDown:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
  
	
	Up[period]=Up[period-1];
    Down[period]=Down[period-1];
	
	AverageUp[period]=AverageUp[period-1];
	AverageDown[period]=AverageDown[period-1];
	
	CountUp[period]=0;
	CountDown[period]=0;
	
	
	if source[period]>  source[period-1] then
	Up[period]= source[period]-  source[period-1]; 
	CountUp[period]=1;
	else
	Down[period]=  source[period-1]-source[period]; 
	CountDown[period]=1;
	end
	
	if period< first then
	return;
	end
	
	
    
	Div=mathex.sum(CountUp, period-Period+1, period)
		if Div ~=0 then
		AverageUp[period]=mathex.avg(Up, period-Period+1, period)/(mathex.sum(Up, period-Period+1, period)/Div);
		end
	Div=mathex.sum(CountDown, period-Period+1, period)
		if Div ~=0 then
		AverageDown[period]=mathex.avg(Down, period-Period+1, period)/(mathex.sum(Down, period-Period+1, period)/Div);
		end
   
				  
end

 
