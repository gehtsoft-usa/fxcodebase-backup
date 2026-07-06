-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74678

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
    indicator:name("Average Minimum and Maximum Up Down");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Period", "", 50, 1, 2000);
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down  Line Color", "", core.rgb(255, 0, 0)); 

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
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first()+Period; 
 
    Up = instance:addStream("Up", core.Bar, name, "Up", instance.parameters.color1, first );
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Down = instance:addStream("Down", core.Bar, name, "Down", instance.parameters.color2, first );
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
	
    UpMax = instance:addStream("UpMax", core.Line, name, "Up Max", instance.parameters.color1, first+Period );
    UpMax:setPrecision(math.max(2, instance.source:getPrecision()));
    UpMax:setWidth(instance.parameters.width);
    UpMax:setStyle(instance.parameters.style); 

    UpMin = instance:addStream("UpMin", core.Line, name, "Up Min", instance.parameters.color1, first+Period );
    UpMin:setPrecision(math.max(2, instance.source:getPrecision()));
    UpMin:setWidth(instance.parameters.width);
    UpMin:setStyle(instance.parameters.style); 
	
    UpAverage = instance:addStream("UpAverage", core.Dot, name, "Up Average", instance.parameters.color1, first+Period );
    UpAverage:setPrecision(math.max(2, instance.source:getPrecision()));
    UpAverage:setWidth(instance.parameters.width);
    UpAverage:setStyle(instance.parameters.style); 	
 
    DownMax = instance:addStream("DownMax", core.Line, name, "Down Max", instance.parameters.color2, first+Period );
    DownMax:setPrecision(math.max(2, instance.source:getPrecision()));
    DownMax:setWidth(instance.parameters.width);
    DownMax:setStyle(instance.parameters.style); 
	
    DownMin = instance:addStream("DownMin", core.Line, name, "Down Min", instance.parameters.color2, first+Period );
    DownMin:setPrecision(math.max(2, instance.source:getPrecision()));
    DownMin:setWidth(instance.parameters.width);
    DownMin:setStyle(instance.parameters.style);	
	
    DownAverage = instance:addStream("DownAverage", core.Dot, name, "Down Average", instance.parameters.color2, first+Period );
    DownAverage:setPrecision(math.max(2, instance.source:getPrecision()));
    DownAverage:setWidth(instance.parameters.width);
    DownAverage:setStyle(instance.parameters.style); 
	
end


function Update(period, mode)

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	local Difference= source[period] - source[period-1];
	
	if Difference > 0 then   
    Up[period]=Difference;
	else
    Up[period]= Up[period-1];	
	end
	
	if Difference < 0 then   
    Down[period]=Difference;
	else
    Down[period]= Down[period-1];	
	end
	
	if period <= first + Period
	or  not source:hasData(period) 
	then
	return;
	end	
	
	local MinUp, MaxUp=mathex.minmax(Up, period-Period+1, period)
	local MinDown, MaxDown=mathex.minmax(Down, period-Period+1, period);
	
	
	local AverageUp=mathex.avg(Up, period-Period+1, period);
	local AverageDown=mathex.avg(Down, period-Period+1, period);
	
	
	UpMax[period]=MaxUp/source:pipSize();
	UpAverage[period]=AverageUp/source:pipSize();
	DownMax[period]=MaxDown/source:pipSize();
	DownAverage[period]=AverageDown/source:pipSize();	
	UpMin[period]=MinUp/source:pipSize(); 	
	DownMin[period]=MinDown/source:pipSize(); 
 		
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