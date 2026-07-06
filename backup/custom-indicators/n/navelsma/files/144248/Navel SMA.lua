-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71641

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
    indicator:name("NavelSMA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 13, 1, 2000);
 
	
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE); 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
 
local Oscillator;  
local Navel;
-- Routine
 function Prepare(nameOnly)   
 
 

	Period=instance.parameters.Period;
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Navel= instance:addInternalStream(0, 0);    
 	
    source = instance.source; 
    first=source:first() + Period;
 
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first ); 
    Line:setPrecision(math.max(2, source:getPrecision()));
	Line:setWidth(instance.parameters.width);
	Line:setStyle(instance.parameters.style);	
	
end

-- Indicator calculation routine
function Update(period, mode)

    Navel[period]=(source.close[period]*5+source.open[period]*2+source.high[period]+source.low[period])/9
 
	if period < first
	then
	return;
	end
	
	Line[period]=mathex.avg(Navel, period-Period+1, period );
	
 
	
	local pr=2.0/(Period+1); 
    Line[period]=  Navel[period]*pr+Line[period-1]*(1-pr);
	

 
end
 