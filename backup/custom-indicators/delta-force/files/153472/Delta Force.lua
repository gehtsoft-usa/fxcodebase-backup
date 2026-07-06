-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74382

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
    indicator:name("Oscillator Template");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

 
	
	indicator.parameters:addGroup("Bar Style"); 	
	
    indicator.parameters:addBoolean("Absolute", "Absolute", "", false);	
	indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0)); 
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
 
    
	source = instance.source
	Absolute = instance.parameters.Absolute;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	first=source:first()+1 ; 
	 
 
	
	if not Absolute then
    Up = instance:addStream("Up", core.Bar, name, "Up", instance.parameters.color1, first );
    Up:setPrecision(math.max(2, instance.source:getPrecision())); 
    Up:addLevel(0);	

    Down = instance:addStream("Down", core.Bar, name, "Down", instance.parameters.color2, first );
    Down:setPrecision(math.max(2, instance.source:getPrecision())); 
    Down:addLevel(0);	 
	else
	
    Up = instance:addStream("Up", core.Line, name, "Up", instance.parameters.color1, first );
    Up:setPrecision(math.max(2, instance.source:getPrecision())); 
    Up:addLevel(0);	

    Down = instance:addStream("Down", core.Line, name, "Down", instance.parameters.color2, first );
    Down:setPrecision(math.max(2, instance.source:getPrecision())); 
    Down:addLevel(0);		
	end
	
end


function Update(period, mode) 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
    local  dif = source[period] - source[period-1];	
	  
    Up[period]=0;
	Down[period]=0;
	
    if(dif > 0) then
	Up[period]=Up[period-1]+dif;
	Down[period]=0;
	end
	
	if(dif < 0) then
		if Absolute then
	    Down[period]=Down[period-1]+math.abs(dif);
		else
	    Down[period]=Down[period-1]+dif;		
		end
	Up[period]=0;
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