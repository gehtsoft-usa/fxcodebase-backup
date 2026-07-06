-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71661

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
    indicator:name("Keltner Channels");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Period", "Period", "", 10);
 
 
	
	indicator.parameters:addGroup("Cental Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);


	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
 
local Line, HighLow, Top,Bottom;  
 
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period; 
	
	
	local Parameters= Period ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period;
	
	HighLow= instance:addInternalStream(0, 0);
   
 
	Line = instance:addStream("Line" , core.Line, "Line", "Line",instance.parameters.color1, first );
	Line:setWidth(instance.parameters.width1);
    Line:setStyle(instance.parameters.style1);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	Top = instance:addStream("Top" , core.Line, "Top", "Top",instance.parameters.color2, first );
	Top:setWidth(instance.parameters.width2);
    Top:setStyle(instance.parameters.style2);
    Top:setPrecision(math.max(2, source:getPrecision()));

	Bottom = instance:addStream("Bottom" , core.Line, "Bottom", "Bottom",instance.parameters.color3, first );
	Bottom:setWidth(instance.parameters.width3);
    Bottom:setStyle(instance.parameters.style3);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
	
end

-- Indicator calculation routine
function Update(period, mode)

    HighLow[period]=source.high[period]-source.low[period];

    if period < first then
	return;
	end
 
		
    Line[period] = mathex.avg(source.close, period-Period+1, period);
	local Avearege = mathex.avg(HighLow, period-Period+1, period);
				  
	Top[period]=Line[period]+Avearege;
	Bottom[period]=Line[period]-Avearege;	
end


 
					 

 