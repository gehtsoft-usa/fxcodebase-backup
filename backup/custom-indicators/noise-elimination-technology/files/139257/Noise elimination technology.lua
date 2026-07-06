-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70678

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
    indicator:name("Noise elimination technology");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);

 
	
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
 
local Indicator;  
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
   
 
	Indicator = instance:addStream("Indicator" , core.Line, " Indicator"," Indicator",instance.parameters.color, first );
	Indicator:setWidth(instance.parameters.width);
    Indicator:setStyle(instance.parameters.style);
    Indicator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	
 
	local Denom=0.5*Period*(Period-1);


   local X={};
   local Y={};
   

   for count = 1, Period, 1 do
	X[count] = source[period-count + 1];
	Y[count] = -count;
   end


    local Value;
    local Num = 0;
	for count = 2 , Period, 1 do
		for K = 1,  count - 1, 1 do
		Value=X[count] - X[K];
		Num = Num - Sign(Value);
		end
	end

     Indicator[period]= Num/Denom;
				  
end


function Sign(Value)

if Value > 0 then
return 1;
elseif Value < 0 then
return -1;
else
return 0;
end 

end


