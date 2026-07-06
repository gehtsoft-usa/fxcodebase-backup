-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71667

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
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Cumulative Range Weighted Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
	
    indicator.parameters:addString("Type", "Price Type", "", "OpenClose");
    indicator.parameters:addStringAlternative("Type", "Open/Close", "", "OpenClose");
    indicator.parameters:addStringAlternative("Type", "High/Low", "", "HighLow");

 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Type;
local Period; 
local first;
local source = nil;
 
local Line;  
local Change;
local Price;
local Weight, PriceM
-- Routine
 function Prepare(nameOnly)   
 
 
   Period= instance.parameters.Period;
   Type= instance.parameters.Type;
	
	
	local Parameters= Period.. ", ".. Type ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	source = instance.source; 
    first=source:first()+Period ;
	
	
	
    Change= instance:addInternalStream(0, 0);
    Weight= instance:addInternalStream(0, 0);	
	Price= instance:addInternalStream(0, 0);
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first+Period );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

	if Type== "OpenClose" then
	Change[period]= math.abs(source.close[period]-source.open[period] );
	else
	Change[period]= math.abs(source.high[period]-source.low[period] );
	end

 
	if period < first 
	then
	return;
	end	

	local  Sum= mathex.sum(Change, period-Period+1, period); 	 
	
 
	Weight[period]= Change[period] /Sum ;
 
	Price[period]=source[period]*Weight[period];
	
	
	if period < first+Period
	then
	return;
	end

  	Line[period]=mathex.sum(Price, period-Period+1, period)/mathex.sum(Weight, period-Period+1, period); 	  
end 


