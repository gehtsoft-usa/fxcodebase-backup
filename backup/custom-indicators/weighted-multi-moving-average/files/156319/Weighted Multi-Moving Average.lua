-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75114

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Weighted Multi-Moving Average");
    indicator:description("An indicator that computes a weighted combination of three moving averages with selectable methods.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 

  
 	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");		

    indicator.parameters:addInteger("Period1", "1. MA Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. MA Period", "", 20, 1, 2000);
	indicator.parameters:addInteger("Period3", "3. MA Period", "", 60, 1, 2000);
	
    indicator.parameters:addDouble("Percentage1", "1. MA Percentage", "", 100/3);
    indicator.parameters:addDouble("Percentage2", "2. MA Percentage", "", 100/3);
	indicator.parameters:addDouble("Percentage3", "3. MA Percentage", "", 100/3);

 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1 =instance.parameters.Period1;
	Period2 =instance.parameters.Period2;
	Period3 =instance.parameters.Period3;
	Percentage1 =instance.parameters.Percentage1;
	Percentage2 =instance.parameters.Percentage2;
	Percentage3 =instance.parameters.Percentage3;	
	Total=(Percentage1+Percentage2+Percentage3);
	
	Method =instance.parameters.Method;
	source = instance.source



	
    Percentage1=Percentage1/Total;
    Percentage2=Percentage2/Total;
	Percentage3=Percentage3/Total;
	
 
    local name = profile:id() .. "(" ..  instance.source:name().. ")";
    instance:name(name); 
	
		
    if   (nameOnly) then
        return;
    end
 
	MA1= core.indicators:create(Method, source, Period1);
	MA2= core.indicators:create(Method, source, Period2);
	MA3= core.indicators:create(Method, source, Period3);	
	first=source:first()+math.max(Period1, Period2, Period3); 
	 
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
 
	Line[period]= (MA1.DATA[period]*Percentage1+MA2.DATA[period]*Percentage2+MA3.DATA[period]*Percentage3);
    
end

 
  
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+