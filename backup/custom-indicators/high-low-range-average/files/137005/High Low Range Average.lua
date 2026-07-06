-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70233

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
    indicator:name("High Low Range Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
	
	indicator.parameters:addBoolean("Shift", "Shift by one period", "", false);
	indicator.parameters:addBoolean("Combine", "Combine", "", false);
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color_1", "High Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color_2", "Low Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Shift,Combine;
local Period; 
local first;
local source = nil;
 
local High,Low;  
local high,low;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	Shift= instance.parameters.Shift;
	Combine= instance.parameters.Combine;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
     first=source:first()+Period;
	
	 high= instance:addInternalStream(0, 0);
	 low= instance:addInternalStream(0, 0);
   
    
	
	if Combine then
	
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color_1, first );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
	Oscillator:addLevel(0);
	
    else
	
	High = instance:addStream("High" , core.Line, " High"," High",instance.parameters.color_1, first );
	High:setWidth(instance.parameters.width);
    High:setStyle(instance.parameters.style);
    High:setPrecision(math.max(2, source:getPrecision()));
	
	
	Low = instance:addStream("Low" , core.Line, " Low"," Low",instance.parameters.color_2, first );
	Low:setWidth(instance.parameters.width);
    Low:setStyle(instance.parameters.style);
    Low:setPrecision(math.max(2, source:getPrecision()));
	end
	
end

-- Indicator calculation routine
function Update(period, mode)

    
	
	high[period]= source.high[period]-source.open[period];
	low[period]= source.open[period]-source.low[period];
	
	if Shift then
	period = period-1;
	end
	
	
	if period <  first
	then
	return;
	end
		
     
	 
	if Combine then
	
	Oscillator[period] = mathex.avg(high,period-Period+1, period) -  mathex.avg(low,period-Period+1, period);
	 if Oscillator[period] > 0 then
	 Oscillator:setColor(period, instance.parameters.color_2);
	 else
	 Oscillator:setColor(period, instance.parameters.color_1);
	 end
	else
	
		
     High[period]= mathex.avg(high,period-Period+1, period);
	 Low[period]= mathex.avg(low,period-Period+1, period);
	 end
				  
end
