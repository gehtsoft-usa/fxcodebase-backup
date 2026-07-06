-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74859 

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
    indicator:name("Predicted  Two Moving Average Cross");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Fast MA", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 20, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal MA", "", 10, 1, 2000);

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	 indicator.parameters:addGroup("Line Style");	 
	 indicator.parameters:addColor("color1", "Up Trend Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color11", "Down in Up Trend Color", "", core.rgb(0, 200, 0)); 
	 
	 indicator.parameters:addColor("color2", "Up in Down Trend Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color21", "Down Trend Color", "", core.rgb(200, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2 ; 
local Indicator1, Indicator2,Method;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2; 
	Period3=instance.parameters.Period3; 	
	Method=instance.parameters.Method;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..   Method.. "," ..  Period3.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
	
	Indicator1= core.indicators:create(Method, source, Period1 );
	Indicator2= core.indicators:create(Method, source, Period2 );	
	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first()) +Period1; 
	
	 
	Source = instance:addInternalStream(0, 0);	
	
    Line = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.color1, first+Period3 );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	   
	Source[period]= ForecastFunction(period);
	
	if period <= first + Period3
	or  not source:hasData(period) 
	then
	return;
	end	
	
	
	Line[period]= mathex.avg(Source, period-Period3+1, period);
	if Line[period] > 0 then
		if Line[period]> Line[period-1] then
		Line:setColor(period, instance.parameters.color1);
		else
		Line:setColor(period, instance.parameters.color11);		
		end
	else
		if Line[period]> Line[period-1] then
		Line:setColor(period, instance.parameters.color2);
		else
		Line:setColor(period, instance.parameters.color21);		
		end	
	end
	
	
	
end


function ForecastFunction (period)

   local Value1=Indicator1.DATA[period]-Indicator2.DATA[period];
   local Value2=Indicator1.DATA[period-Period1]-Indicator2.DATA[period-Period1];
   
 
        return Value1/ ( math.max(math.abs(Value2),math.abs(Value1))/Period1);
   
   
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