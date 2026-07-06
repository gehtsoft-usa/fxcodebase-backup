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
    indicator:name("Volume Price Confirmation Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	
 
 
    indicator.parameters:addInteger("Period1", "Fast MA Period", "", 13, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA Period", "", 26, 1, 2000); 


	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "VWMA Line Color", "", core.rgb(0, 255, 0)); 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2; 

	
-- Routine
 function Prepare(nameOnly)   
  
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 	assert(core.indicators:findIndicator("VOLUME-WEIGHTED MOVING AVERAGE") ~= nil, "Please, download and install VOLUME-WEIGHTED MOVING AVERAGE.LUA indicator"); 

	Long= core.indicators:create("VOLUME-WEIGHTED MOVING AVERAGE", source, Period2); 
 	Short= core.indicators:create("VOLUME-WEIGHTED MOVING AVERAGE", source, Period1); 
	first= math.max(Long.DATA:first(), Short.DATA:first());  
	
	
    VPCI = instance:addStream("VPCI", core.Line, name, "VPCI", instance.parameters.color, first );
    VPCI:setPrecision(math.max(2, instance.source:getPrecision()));
    VPCI:setWidth(instance.parameters.width);
    VPCI:setStyle(instance.parameters.style); 
    VPCI:addLevel(0);		
 
end

 
function Update(period, mode)

 
	Long:update(mode); 
	Short:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	

    local VPC    = Long.DATA[period]  -   mathex.avg(source.close, period-Period2+1, period)
    local VPR    = Short.DATA[period] /  mathex.avg(source.close, period-Period1+1, period)
    local VM     = mathex.avg(source.volume, period-Period1+1, period) / mathex.avg(source.volume, period-Period2+1, period)
 
	VPCI[period]   = VPC * VPR * VM
 
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