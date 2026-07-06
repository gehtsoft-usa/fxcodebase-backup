-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74943

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
    indicator:name("ATR bands around the MA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("ATR Calculation");	
 
    indicator.parameters:addInteger("ATR_Period", "ATR PEriod", "", 5, 1, 2000);
    indicator.parameters:addDouble("ATR_Multiplier", "ATR Multiplier", "", 1.5, 0, 2000);	
	
 	indicator.parameters:addGroup("MA Calculation");	
    indicator.parameters:addString("MA_Price", "Price Source", "", "median");
    indicator.parameters:addStringAlternative("MA_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MA_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MA_Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MA_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MA_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MA_Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");	
	
	
    indicator.parameters:addInteger("MA_Period", "MA Period", "", 90, 1, 2000);

	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255)); 	 
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local ATR, MA;
	
-- Routine
 function Prepare(nameOnly)   
 
 
 	ATR_Period=instance.parameters.ATR_Period;
	ATR_Multiplier=instance.parameters.ATR_Multiplier;
	MA_Price=instance.parameters.MA_Price;
	MA_Method=instance.parameters.MA_Method;
	MA_Period=instance.parameters.MA_Period;
    
	 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  ATR_Period.. "," ..  ATR_Multiplier .. "," ..  MA_Price.. "," ..  MA_Method .. "," ..  MA_Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	ATR= core.indicators:create("ATR", source, ATR_Period);
	MA= core.indicators:create(MA_Method, source[MA_Price], MA_Period);	
	first=math.max(ATR.DATA:first(),MA.DATA:first()); 
	 
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style); 
 
 
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);  
	
    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color3, first );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);  	
end


function Update(period, mode)

	ATR:update(mode); 
	MA:update(mode); 
	
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
 ss	
	Top[period]= MA.DATA[period] + ATR_Multiplier*ATR.DATA[period]; 	
	Bottom[period]= MA.DATA[period] - ATR_Multiplier*ATR.DATA[period]; 	
	Central[period]= MA.DATA[period]; 		
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