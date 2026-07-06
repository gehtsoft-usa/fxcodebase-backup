-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71662

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
    indicator:name("Nadaraya-Watson estimator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Period", "Period", "", 500);
    indicator.parameters:addDouble("Band_Width", "Band Width", "", 8);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Band_Width; 
local first;
local source = nil;
 
local Line;  
 
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	Band_Width= instance.parameters.Band_Width;
	
	
	local Parameters= Period..", "..Band_Width;
 
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

    if period < first then
	return;
	end


	
 
	   
	                    local sum  = 0;
						local sumw = 0;
						local w;
	
			   for j=0 , Period, 1 do
			   
					   
		  
							 w = math.exp(-(math.pow(j,2)/(Band_Width*Band_Width*2.0)));
							 sum = sum + (source[period-j]*w);
							 sumw = sumw + w;
				end
				
				Line[period] = sum/sumw;
 
 
		

				  
end
 