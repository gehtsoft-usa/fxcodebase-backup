-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75066

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
    indicator:name("LBR-310");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Fast Period", "", 3, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period3", "Diff Moving Average Window", "", 16, 1, 2000);	
	
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Diff Line Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Diff Line Down Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Diff Line Neutral Color", "", core.rgb(0, 0, 255)); 
	 
	 indicator.parameters:addColor("color4", "Trend Line Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color5", "Trend Line Down Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color6", "Trend Line Neutral Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	
	Indicator1= core.indicators:create("MVA", source, Period1 );
	Indicator2= core.indicators:create("MVA", source, Period2 );	
	first=math.max(Indicator1.DATA:first(),Indicator1.DATA:first()) ; 
	
	
    Diff = instance:addStream("Diff", core.Line, name, "Diff", instance.parameters.color3, first  );
    Diff:setPrecision(math.max(2, instance.source:getPrecision()));
    Diff:setWidth(instance.parameters.width);
    Diff:setStyle(instance.parameters.style);
    Diff:addLevel(0);	
	
 	Indicator3= core.indicators:create("MVA", Diff, Period3 );
	
	
	
    Trend = instance:addStream("Trend", core.Line, name, "Trend", instance.parameters.color6, first +Period3 );
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    Trend:setWidth(instance.parameters.width);
    Trend:setStyle(instance.parameters.style);
    Trend:addLevel(0);		
	
 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode);
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	Diff[period]=Indicator1.DATA[period]-Indicator2.DATA[period];
	  
	if period <= first + Period3
	or  not source:hasData(period) 
	then
	return;
	end
	
	Indicator3:update(mode);	
    Trend[period]=Indicator3.DATA[period];
	
	
	if Diff[period]> Diff[period-1] then
    Diff:setColor(period, instance.parameters.color1);
	elseif Diff[period]< Diff[period-1] then	
    Diff:setColor(period, instance.parameters.color2);
	else
    Diff:setColor(period, instance.parameters.color3); 
	end
	
	if Trend[period]> Trend[period-1] then
    Trend:setColor(period, instance.parameters.color4);
	elseif Trend[period]< Trend[period-1] then	
    Trend:setColor(period, instance.parameters.color5);
	else
    Trend:setColor(period, instance.parameters.color6); 
	end
 
	
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