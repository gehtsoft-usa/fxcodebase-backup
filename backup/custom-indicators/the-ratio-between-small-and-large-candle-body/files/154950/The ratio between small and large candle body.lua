-- Available @ http://fxcodebase.com/ 

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
    indicator:name("The ratio between small and large candle body");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 20); 
    indicator.parameters:addDouble("small", "Small", "", 33, 0, 100);
    indicator.parameters:addDouble("large", "Large", "", 66, 0, 100);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Small Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color2", "Large Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color3", "Normal Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local small,large; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	small=instance.parameters.small;
	large=instance.parameters.large;
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. "," ..  Period.. "," ..  small.. "," ..  large  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	 
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() ; 
	
	
	Small = instance:addInternalStream(0, 0);
 	Large = instance:addInternalStream(0, 0);

	
	
    SmallLine = instance:addStream("SmallLine", core.Line, name, "SmallLine", instance.parameters.color1, first+Period );
    SmallLine:setPrecision(math.max(2, instance.source:getPrecision()));
    SmallLine:setWidth(instance.parameters.width);
    SmallLine:setStyle(instance.parameters.style);
    SmallLine:addLevel(0);	
	
    LargeLine = instance:addStream("LargeLine", core.Line, name, "LargeLine", instance.parameters.color2, first+Period );
    LargeLine:setPrecision(math.max(2, instance.source:getPrecision()));
    LargeLine:setWidth(instance.parameters.width);
    LargeLine:setStyle(instance.parameters.style);
    LargeLine:addLevel(0);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color3, first+Period );
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
	
	local Wick=(source.high[period]-source.low[period])/100;
	local Body=math.abs(source.close[period]-source.open[period]);
	
    Small[period]=0;	
    Large[period]=0;	
	
    if (Body / Wick)<small then
    Small[period]=1;
    elseif (Body / Wick)>large then	
    Large[period]=1;
    end	
	
	if period <= first+Period
	or  not source:hasData(period) 
	then
	return;
	end
	
	local SmallNumber = mathex.sum(Small, period-Period+1, period);  
    local LargeNumber = mathex.sum(Large, period-Period+1, period);	

	SmallLine[period]= SmallNumber/Period; 
	LargeLine[period]= LargeNumber/Period;   
	Line[period]= 1 - SmallLine[period] - LargeLine[period];
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