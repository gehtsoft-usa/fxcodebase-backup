-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75150

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
    indicator:name("Trend Thrust Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");		
 
    indicator.parameters:addInteger("Period1", "Fast MA Period", "", 13, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal MA Period", "", 9, 1, 2000);
    indicator.parameters:addBoolean("Enchanced", "Enchanced Volume Calculation", "", true);	 


	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Histogram Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Price, Period1, Period2, Period3,Enchanced; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    Price=instance.parameters.Price;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Enchanced=instance.parameters.Enchanced;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Price.. "," ..  Period1.. "," ..  Period2.. "," ..  Period3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  
	first=source:first() + math.max(Period1, Period2);  
	
	
    MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, first );
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.width);
    MACD:setStyle(instance.parameters.style);
    MACD:addLevel(0);	
	
    Signal = instance:addStream("Signal", core.Line, name, "MACD", instance.parameters.color2, first + Period3 );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
 	
    Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, first + Period3 );
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

 
function Update(period, mode)

 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	local VWmaF = VWma(period,Period1); 
	local VWmaS = VWma(period,Period2);
	  
    local vol_multiple=1;
    
	if Enchanced then
	vol_multiple= math.pow((VWmaF/VWmaS),2) 
	end
	
	MACD[period]= VWmaF*vol_multiple - VWmaS/vol_multiple; 
	
	
	if period <= first + Period3
	or  not source:hasData(period) 
	then
	return;
	end	
	
	Signal[period]=mathex.avg(MACD, period-Period3+1, period);
	
	Histogram[period]= MACD[period]-Signal[period];	
 
end 


function VWma( period, Period)

        
		local Return=0;
		
		local Volume=mathex.sum(source.volume, period-Period+1, period);
		
		
		
		for i = 0 , Period-1, 1 do
            Return= Return + source[Price][period-i] * source.volume[period-i]/Volume
        end
		
		
        return Return;
		
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