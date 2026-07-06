-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70255

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
    indicator:name("Bollinger Bands Breakout");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2, 0, 2000);
	
	indicator.parameters:addBoolean("Central", "Central Line", "", false);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Central;
local Period,Deviation; 
local first;
local source = nil;
 
local Oscillator;  
local BB;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Deviation= instance.parameters.Deviation;
	Central= instance.parameters.Central;
	
	
	local Parameters= Period..", "..Deviation;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
	BB = core.indicators:create("BB", source, Period, Deviation);
    first=source:first();
 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   
   
    BB:update(mode);
	
	if period < first
	then
	return;
	end
	 
	 if Central then
	 
	         Oscillator[period]= source[period]-BB.AL[period];  
	 
	 else
	 
			 if 	source[period] > BB.TL[period] then
			 Oscillator[period]= source[period]-BB.TL[period];
			 elseif 	source[period] < BB.BL[period] then
			 Oscillator[period]= source[period]-BB.BL[period];
			 else
			 Oscillator[period]=0;
			 end
	 end
	 
				  
end
 