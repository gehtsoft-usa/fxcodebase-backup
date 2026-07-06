-- Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=74729

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
    indicator:name("Mean Reversion");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Period", "", 25, 1, 2000);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 2.25);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	   
	indicator.parameters:addColor("color1", "High Line Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("color2", "Low Line Color", "", core.rgb(255, 0, 0)); 
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255)); 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Multiplier; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Multiplier=instance.parameters.Multiplier;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1 .. "," ..  Multiplier .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	--assert(core.indicators:findIndicator("TSR BIG TREND") ~= nil, "Please, download and install TSR BIG TREND.LUA indicator"); 
	Range = instance:addInternalStream(0, 0);	
	Indicator= core.indicators:create("MVA", Range, Period1 );
	first=Indicator.DATA:first() ; 
	
	
    High = instance:addStream("High", core.Line, name, "High", instance.parameters.color1, first );
    High:setPrecision(math.max(2, instance.source:getPrecision()));
    High:setWidth(instance.parameters.width);
    High:setStyle(instance.parameters.style);
 
    Low = instance:addStream("Low", core.Line, name, "Low", instance.parameters.color2, first );
    Low:setPrecision(math.max(2, instance.source:getPrecision()));
    Low:setWidth(instance.parameters.width);
    Low:setStyle(instance.parameters.style);	
	
    IBS = instance:addStream("IBS", core.Line, name, "IBS", instance.parameters.color3, first );
    IBS:setPrecision(math.max(2, instance.source:getPrecision()));
    IBS:setWidth(instance.parameters.width);
    IBS:setStyle(instance.parameters.style);
    IBS:addLevel(0);	

    core.host:execute ("attachOuputToChart", "High")
    core.host:execute ("attachOuputToChart", "Low")
end


function Update(period, mode)

	Range[period]=source.high[period]-source.low[period];

	
	Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
    local min, max=mathex.minmax(source, period-Period1+1, period);		  	
	IBS[period]=  (source.close[period]-source.low[period])/(source.high[period]-source.low[period]); 
	Low[period]= max-Indicator.DATA[period]*Multiplier;
	High[period]= min+Indicator.DATA[period]*Multiplier;

	
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