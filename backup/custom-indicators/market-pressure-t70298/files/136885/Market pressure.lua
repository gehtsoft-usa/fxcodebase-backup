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
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
	indicator.parameters:addBoolean("Use_HA", "HA as source", "", false);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Use_HA, HA; 
local Period; 
local first;
local source = nil;
 
local Oscillator;  
local Up, Down;

-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	Use_HA= instance.parameters.Use_HA;
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period;
	
	if Use_HA then
	HA= core.indicators:create("HA", source);
	end
	
	
	Up= instance:addInternalStream(0, 0);
    Down= instance:addInternalStream(0, 0);
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first	);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)


    if Use_HA then
	HA:update(mode);
	
	 
	    if HA.close[period]> HA.close[period] then
		Up[period]=math.abs(HA.close[period]- HA.open[period]);
		Down[period]=0;
		else
		Down[period]=math.abs(HA.close[period]- HA.open[period]);
		Up[period]=0;
		end
	 
	else
	

 

		if source.close[period]> source.close[period] then
		Up[period]=math.abs(source.close[period]- source.open[period]);
		Down[period]=0;
		else
		Down[period]=math.abs(source.close[period]- source.open[period]);
		Up[period]=0;
		end
		
	end
	
	if period <  first 
	then
	return;
	end
	
	
	 
		
     Oscillator[period ]= mathex.avg(Up, period -Period+1, period)-mathex.avg(Down, period -Period+1, period);
				  
end



