-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71640

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
--|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
--|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
--|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Infinite impulse response filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
 	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Periods", "", 10, 1, 2000);
 
	
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
local Line;
local b0,a0,a1, b1, a2,c1,c2;
local b2=0;
local b3=0;
local b4=0;
local a3=0;
local a4=0;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	
	c1 = 1.41421 * 3.14159 / Period;
	c2 = 2.71828^-c1;
	a1 = 2 * c2 * math.cos( c1 );
	a2 = -c2^2;
	b0 = (1 - a1 - a2)/2;
	b1 = b0;
 
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period;
	
	-- Average= instance:addInternalStream(0, 0);
   
 
	Line = instance:addStream("Line" , core.Line, "Line", "Line",instance.parameters.color, first );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
 
	 
	Line[period]=  b0 * source[ period ] +
           b1 * source[ period - 1 ] +
           b2 * source[ period - 2 ] +
           b3 * source[ period - 3 ] +
           b4 * source[ period - 4 ] +
           a1 * Line[ period - 1 ] +
           a2 * Line[ period - 2 ] +
           a3 * Line[ period - 4 ] +
           a4 * Line[ period - 4 ];
	
 
				  
end


 
 