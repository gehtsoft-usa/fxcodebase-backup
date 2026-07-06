-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74814

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volume Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Period", "", 20, 1, 2000); 	
    indicator.parameters:addInteger("Period2", "Signal Line Period", "", 20, 1, 2000); 		
	indicator.parameters:addString("Type", "Histogram Type", "", "Average");
    indicator.parameters:addStringAlternative("Type", "Average", "", "Average");
	indicator.parameters:addStringAlternative("Type", "Sum", "", "Sum");	
	indicator.parameters:addStringAlternative("Type", "Volume", "", "Volume");	
	
	 indicator.parameters:addGroup("Line Style");	 
	
	 indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Neutral Color", "", core.rgb(128, 128, 128)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2, Type; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;	
	Type=instance.parameters.Type;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1 .. "," ..  Period2 .. "," ..  Type .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
	
	Indicator= core.indicators:create("MVA", source.volume, Period1);
	first=Indicator.DATA:first() ; 
	
	
	 
	
    Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color1, first );
    Histogram:setPrecision(math.max(2, instance.source:getPrecision())); 
    Histogram:addLevel(0);	
 
end


function Update(period, mode)



	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	if Type == "Average" then  	
	Indicator:update(mode); 
	Histogram[period]= Indicator.DATA[period]	
	elseif Type == "Sum" then
	Histogram[period]= mathex.sum(source.volume, period-Period1+1, period)	
	elseif Type == "Volume" then 
 	Histogram[period]= source.volume[period]
    end	
	
	
	if period <= first + Period2
	or  not source:hasData(period) 
	then
    Histogram:setColor(period, instance.parameters.color3)		
	return;
	end	
	
	local Average=mathex.avg(Histogram, period- Period2+1, period);
	
	
	if Histogram[period] > Average then
    Histogram:setColor(period, instance.parameters.color1);
	else
    Histogram:setColor(period, instance.parameters.color2)	
	end
end



--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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