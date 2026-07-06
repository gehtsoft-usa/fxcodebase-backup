-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74476

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
    indicator:name("Nonparametric Quantile Regression");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000); 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Median Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color2", "Top Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color3", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
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


	

	first=source:first()+Period;  
 
	
	
    Median = instance:addStream("Median", core.Line, name, "Median", instance.parameters.color1, first );
    Median:setPrecision(math.max(2, instance.source:getPrecision()));
    Median:setWidth(instance.parameters.width);
    Median:setStyle(instance.parameters.style); 
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color2, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style); 	
	
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color3, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style); 
end


function Update(period, mode) 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	local Elements = getLastXElements(period, source, Period)
  	
	Median[period]= median(Elements); 
	
    Top[period]= quantile(Elements, 0.75);	
    Bottom[period]= quantile(Elements, 0.25);
	
end

function getLastXElements(period, array, x)
 
    local result = {}

    for i = period - x + 1, period do
        table.insert(result, array[i])
    end

    return result
end 

-- Function to calculate the median (quantile at 0.5)
function median(data)
    local n = #data
    local sorted_data =  data
    table.sort(sorted_data)
    if n % 2 == 0 then
        return (sorted_data[n/2] + sorted_data[n/2 + 1]) / 2
    else
        return sorted_data[(n + 1) / 2]
    end
end


-- Function to calculate a specific quantile
function quantile(data, q)
    local n = #data
    local sorted_data = data
    table.sort(sorted_data)
    local index = math.ceil(q * n)
    return sorted_data[index]
end


--[[


-- Example data
local data = {3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5}

-- Calculate and print the median
local median_value = median(data)
print("Median:", median_value)

-- Calculate and print the 0.25 quantile
local quantile_25 = quantile(data, 0.25)
print("Quantile at 0.25:", quantile_25)

-- Calculate and print the 0.75 quantile
local quantile_75 = quantile(data, 0.75)
print("Quantile at 0.75:", quantile_75)
]] 

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