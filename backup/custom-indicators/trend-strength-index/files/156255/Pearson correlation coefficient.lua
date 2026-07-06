-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75099

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
    indicator:name("Pearson correlation coefficient");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Period", "", 25, 1, 2000);  
	
 
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
local Period ; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    Period=instance.parameters.Period;  
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
  
	first=source:first()+Period  ; 
	 
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first  );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    --Line:addLevel(0);	
 
end




function Update(period, mode)

  
  
  	if period <= first 
	or  not source:hasData(period) 
	then
	return;
	end		
	
    local closePrices, periods = {}, {};
	
	for i= 0, Period-1, 1 do		
		closePrices[i]=source[period-Period+i+1]
		periods[i]=period-Period+i+1; 	
	end
	
  
    Line[period]=pearsonCorrelation(periods, closePrices, Period);
	 
  
 	

 
end

function pearsonCorrelation(x, y, length)
    local sumX, sumY, sumXY, sumX2, sumY2 = 0, 0, 0, 0, 0;
    for i = 0, length - 1 do
        local xVal = x[#x - i];
        local yVal = y[#y - i];
        sumX = sumX + xVal;
        sumY = sumY + yVal;
        sumXY = sumXY + (xVal * yVal);
        sumX2 = sumX2 + (xVal * xVal);
        sumY2 = sumY2 + (yVal * yVal);
    end
    local numerator = (length * sumXY) - (sumX * sumY);
    local denominator = math.sqrt(((length * sumX2) - (sumX * sumX)) * ((length * sumY2) - (sumY * sumY)));
    if denominator == 0 then
        return 0;
    else
        return numerator / denominator;
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