-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74472

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
    indicator:name("Trailing Spit Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Long MA", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period2", "Short MA", "", 14, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Long Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Short Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,TF; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end



	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	
 	
	first=source:first() + math.max(Period1, Period2);  
	
	
    Long = instance:addStream("Long", core.Line, name, "Long", instance.parameters.color1, first );
    Long:setPrecision(math.max(2, instance.source:getPrecision()));
    Long:setWidth(instance.parameters.width);
    Long:setStyle(instance.parameters.style); 


    Short = instance:addStream("Short", core.Line, name, "Short", instance.parameters.color2, first );
    Short:setPrecision(math.max(2, instance.source:getPrecision()));
    Short:setWidth(instance.parameters.width);
    Short:setStyle(instance.parameters.style); 
	
end


function Update(period, mode)

 
    if source[period]> source[period] then
	Up[period]=source[period];
	Down[period]=nil;	
	elseif source[period]< source[period] then
	Up[period]=nil;
	Down[period]=source[period];		
	else
	Up[period]=nil;
	Down[period]=nil;	
	end
	

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	local LongCount=0;
    local LongSum=0;
	local ShortCount=0;
    local ShortSum=0;	
	
	 
	 
	for i= period-Period1+1, period, 1 do
		if source[i]> source[i-1] then
		LongCount=LongCount+1;
		LongSum= LongSum+source[i]
		end
	end
	  	
	for i= period-Period2+1, period, 1 do
		if source[i]< source[i-1] then
		ShortCount=ShortCount+1;
		ShortSum= ShortSum+source[i]
		end	
	end
	
	if LongCount ~= 0 then	
	Long[period]= LongSum/LongCount;
	else
	Long[period]=Long[period-1];
	end
	
	if ShortCount ~= 0 then	
	Short[period]= ShortSum/ShortCount;
	else
	Short[period]=Short[period-1];
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