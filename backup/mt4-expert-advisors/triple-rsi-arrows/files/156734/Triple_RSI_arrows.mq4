-- Available @ http://fxcodebase.com/ 

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
    indicator:name("Trend Strength Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Fast MA", "", 13, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 25, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
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
local Period1, Period2,Method; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..   Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	Momentum = instance:addInternalStream(0, 0);
	AbsMomentum = instance:addInternalStream(0, 0);
	
	Indicator1= core.indicators:create(Method, Momentum, Period1 );
	Indicator1A= core.indicators:create(Method, AbsMomentum, Period1 );	
	
	Indicator2= core.indicators:create(Method, Indicator1.DATA, Period1 );
	Indicator2A= core.indicators:create(Method, Indicator1A.DATA, Period1 );

	Indicator3= core.indicators:create(Method, Indicator2.DATA, Period2 );
	Indicator3A= core.indicators:create(Method, Indicator2A.DATA, Period2 );	
	
	Indicator4= core.indicators:create(Method, Indicator3.DATA, Period2 );
	Indicator4A= core.indicators:create(Method, Indicator3A.DATA, Period2 );	
	
	
	first=source:first()+Period1 ; 
	
	
	Source1 = instance:addInternalStream(0, 0);
	Source2 = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first+Period2 );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    --Line:addLevel(0);	
 
end


function Update(period, mode)


    Momentum[period] = source[period] - source[period - 1];
    AbsMomentum[period] = math.abs(Momentum[period]);
 
	
	
	Indicator1:update(mode); 
	Indicator1A:update(mode); 	
	
	if period <= first 
	or  not source:hasData(period) 
	then
	return;
	end		

	Indicator2:update(mode); 
	Indicator2A:update(mode); 
	
	if period <= first +Period2
	or  not source:hasData(period) 
	then
	return;
	end	
	
	
	Indicator3:update(mode); 
	Indicator3A:update(mode); 	
	
	if period <= first 
	or  not source:hasData(period) 
	then
	return;
	end		

	Indicator4:update(mode); 
	Indicator4A:update(mode); 
	
	if period <= first +Period2
	or  not source:hasData(period) 
	then
	return;
	end	
 
	  
 	
	Line[period]=  100*(Indicator4.DATA[period]/Indicator4A.DATA[period]);
 	

 
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