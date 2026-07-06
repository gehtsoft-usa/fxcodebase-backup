-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74925

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
    indicator:name("Jurik Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  	indicator.parameters:addGroup("JMA  Calculation");
    indicator.parameters:addInteger("Length", "JMA length", "", 10, 1, 2000);
    indicator.parameters:addInteger("Phase", "JMA Phase", "", 50, 1, 2000);
    indicator.parameters:addInteger("Power", "JMA Power", "", 1, 1, 2000); 
 
	
	
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
local Period1, Period2,Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
 
    Length=instance.parameters.Length;
	Phase=instance.parameters.Phase;
	Power=instance.parameters.Power;

	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. "," .. Length  .. "," ..  Phase  .. "," ..    Power .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
 	
	first=source:first() ; 
	
    if Phase < -100 then 
	phaseRatio= 0.5 
    elseif Phase > 100 then
	phaseRatio= 2.5 
	else
	phaseRatio= Phase / 100 + 1.5
	end
    beta = 0.45 * (Length - 1) / (0.45 * (Length - 1) + 2)
    alpha = math.pow(beta, Power)	
	
	e0 = instance:addInternalStream(0, 0);
    e1 = instance:addInternalStream(0, 0);
    e2 = instance:addInternalStream(0, 0);	
	
    JMA = instance:addStream("JMA", core.Line, name, "JMA", instance.parameters.color, first );
    JMA:setPrecision(math.max(2, instance.source:getPrecision()));
    JMA:setWidth(instance.parameters.width);
    JMA:setStyle(instance.parameters.style);
    JMA:addLevel(0);	
 
end


function Update(period, mode)

	--MA1:update(mode); 
	 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
 
 
    e0[period]=(1 - alpha) * source[period] + alpha *  e0[period-1] 
    e1[period]=(source[period]-e0[period]) * (1 - beta) + beta * e1[period-1] 
    e2[period]=(e0[period] + phaseRatio * e1[period] - JMA[period-1]) * math.pow(1 - alpha, 2) + 
       math.pow(alpha, 2) *  e2[period-1]
    JMA[period]= e2[period] + JMA[period-1]
      	
 
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