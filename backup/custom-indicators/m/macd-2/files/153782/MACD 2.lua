-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74471

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
    indicator:name("MACD");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	
    indicator.parameters:addString("Price", "Price Source", "", "median");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");		
 
    indicator.parameters:addInteger("Period1", "Fast MA", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal MA", "", 9, 1, 2000);	
    indicator.parameters:addDouble("Multiplier", "Histogram Multiplier", "", 3, 1, 2000);		
	
	indicator.parameters:addGroup("MACD Style"); 
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));


	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	
	indicator.parameters:addGroup("Histogram Style"); 
	indicator.parameters:addColor("Histogram_Up", "Up Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("Histogram_Down", "Down Color", "", core.rgb(255, 0, 255));
	indicator.parameters:addColor("Histogram_Neutral", "Neutral Color", "", core.rgb(128, 128, 255));	
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
   
   
    Price=instance.parameters.Price;
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Multiplier=instance.parameters.Multiplier;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	
	Histogram_Up=instance.parameters.Histogram_Up;
	Histogram_Down=instance.parameters.Histogram_Down;
	Histogram_Neutral=instance.parameters.Histogram_Neutral;
	
    Transparency= instance.parameters.Transparency;
    Transparency= 100-Transparency;

   
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3  .. "," ..  Multiplier .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	 
	Indicator= core.indicators:create("MACD", source[Price], Period1, Period2, Period3);
	first=Indicator.SIGNAL:first() ; 
	
	
 
	

    MACD = instance:addStream("MACD", core.Line, name, "MACD", Neutral, first );
    MACD:setPrecision(math.max(2, instance.source:getPrecision())); 
    MACD:addLevel(0); 

    SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", Neutral, first );
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision())); 
    SIGNAL:addLevel(0); 
	
    HISTOGRAM = instance:addStream("SIGNAL", core.Bar, name, "HISTOGRAM", Neutral, first );
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
    HISTOGRAM:addLevel(0); 	

	instance:createChannelGroup("Group","Group" , MACD, SIGNAL, Histogram_Neutral, Transparency);	 
end


function Update(period, mode)

	Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
	MACD[period]= Indicator.MACD[period];
	SIGNAL[period]= Indicator.SIGNAL[period];	
	
	if MACD[period] > SIGNAL[period] then
    MACD:setColor(period, Up);	
	else
    MACD:setColor(period, Down);		
	end
	
	HISTOGRAM[period]=Indicator.HISTOGRAM[period]*Multiplier;
	
	if HISTOGRAM[period] > HISTOGRAM[period-1] then
    HISTOGRAM:setColor(period, Histogram_Up);	
	else
    HISTOGRAM:setColor(period, Histogram_Down);		
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