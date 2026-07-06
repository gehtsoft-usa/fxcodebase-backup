-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74468

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
    indicator:name("Correlation Based Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	  
    indicator.parameters:addInteger("Min_period", "Min_period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Max_period", "Max_period", "", 100, 1, 2000);
    indicator.parameters:addInteger("Increment", "Increment", "", 10, 1, 2000);
    indicator.parameters:addInteger("Smoothing_period", "Smoothing_period", "", 10, 1, 2000);		
	
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


-- Routine
 function Prepare(nameOnly)   
 
 
	Period=instance.parameters.Period;	 
	Min_period=instance.parameters.Min_period
	Max_period=instance.parameters.Max_period
	Increment=instance.parameters.Increment
	Smoothing_period=instance.parameters.Smoothing_period;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. "," ..  Min_period.. "," ..  Max_period.. "," ..  Increment .. "," ..   Smoothing_period.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	
	first=source:first()+Max_period ; 
	 
	Base = instance:addInternalStream(0, 0); 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	--Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
    local best_period =find_best_moving_average_period(source, Min_period, Max_period, Increment, period)
 
    Base[period]=best_period;		
	
	local AveragPeriod=0;
	
	if period >= Smoothing_period then
    AveragPeriod=mathex.avg(Base, period-Smoothing_period+1, period)
	end	
	
	if period >= AveragPeriod and AveragPeriod > 0 then	
    Line[period]=mathex.avg( source, period-AveragPeriod+1, period);		
	end
 
end

-- Function to find the moving average period that best correlates with the last X elements of a data set
function find_best_moving_average_period(data,  min_period, max_period, increment, n)


    local best_period = min_period
    local max_correlation = 0

    -- Iterate over possible moving average periods
    for period = min_period, max_period, increment do
        local sum = 0
        local correlation = 0

        -- Calculate the moving average
        for i = n - period + 1, n do
            sum = sum + data[i]
        end
        local moving_average = sum / period

        -- Calculate the correlation
        for i = n - period + 1, n do
            correlation = correlation + (data[i] - moving_average) * (data[i - period] - moving_average)
        end
        correlation = correlation / period

        if correlation > max_correlation then
            max_correlation = correlation
            best_period = period
        end
    end

    return best_period
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