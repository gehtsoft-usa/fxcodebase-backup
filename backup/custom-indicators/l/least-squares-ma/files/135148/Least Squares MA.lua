-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70053

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
    indicator:name("Least Squares MA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 34, 1, 2000);

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Line; 
local Period; 
local first;
local source = nil;
local lengthvar; 
 
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Period2= instance.parameters.Period2;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    lengthvar = (Period + 1)/3;
 
			
    source = instance.source; 
    first=source:first()+Period;
	
 
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.Up, first );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first()+Period 
	then
	return;
	end
 
 
    local sum=0;
 
         for i = Period,1,-1 do    
         sum=sum+ ( i - lengthvar)*source[period-Period+i];
         end
        

		Line[period] = sum*6/(Period*(Period+1));
        
		
		if Line[period] > Line[period-1] then
		Line:setColor(period, instance.parameters.Up);
		elseif Line[period] < Line[period-1] then
		Line:setColor(period, instance.parameters.Down);
		else
		Line:setColor(period, instance.parameters.Neutral);
		end
		

	 
				  
end

 