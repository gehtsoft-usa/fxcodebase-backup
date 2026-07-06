-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71679

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

-- Support that the service we provide to the community be continued onward.
--+------------------------------------------------------------------------------------------------+
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Delta");
    indicator:description("Delta");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("1. Line Calculation");	 
	
	indicator.parameters:addInteger("Period1", "MA Period", "Period" , 13);	
	indicator.parameters:addInteger("Shift1", "MA Shift", "Period" , 0);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");

	indicator.parameters:addGroup("2. Line Calculation");	 
	
	indicator.parameters:addInteger("Period2", "MA Period", "Period" , 60);	
	indicator.parameters:addInteger("Shift2", "MA Period", "Period" , 0);	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("1. Line Style");	
	indicator.parameters:addColor("color1", "Color of Delta", "Color of Delta", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("2. Line Style");	
	indicator.parameters:addColor("color2", "Color of Delta", "Color of Delta", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Shift2, Shift1;
-- Streams block
local Line1, Line2;
local MA1, MA2;
 
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
	
	Shift2=instance.parameters.Shift2;
	Shift1=instance.parameters.Shift1;
	
	
	MA1 = core.indicators:create(instance.parameters.Method1, source,  instance.parameters.Period1);
	MA2 = core.indicators:create( instance.parameters.Method2, source,  instance.parameters.Period2);	
    first = math.max(MA1.DATA:first(),MA2.DATA:first())+math.max(Shift1,Shift2);
 
 
	
    local name = profile:id() .. "(" .. source:name()  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
 
    Line1 = instance:addStream("Line1", core.Line, name .. ".Line1", "Line1", instance.parameters.color1, first);
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
	
	Line2 = instance:addStream("Line2", core.Line, name .. ".Line2", "Line2", instance.parameters.color2, first);
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
	Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
 
end

 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	MA1:update(mode);
	MA2:update(mode);
    
	if period < first or not  source:hasData(period) then
	return;
	end
	
    Line1[period]=(source[period]-MA1.DATA[period-Shift1])/source:pipSize();
    Line2[period]=(source[period]-MA2.DATA[period-Shift2])/source:pipSize();

end