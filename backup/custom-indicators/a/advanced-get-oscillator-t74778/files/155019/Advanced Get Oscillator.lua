-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74778

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
    indicator:name("Advanced Get Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Strength", "Strength", "", 5, 1, 2000);
    indicator.parameters:addInteger("Fast", "Fast Period", "", 35, 1, 2000);
    indicator.parameters:addInteger("Slow", "Slow Period", "", 100, 1, 2000);	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0)); 
 	 indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(255, 0, 0)); 
 	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil 
local Indicator;
local Coefficient;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Strength=instance.parameters.Strength;
	Fast=instance.parameters.Fast;
	Slow=instance.parameters.Slow;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Strength.. "," ..  Fast .. "," .. Slow .. "," ..   Fast .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Sum=Fast+Slow;
	Coefficient = 2.0/Sum	
	FastMA= core.indicators:create("MVA", source, Fast );
	SlowMA= core.indicators:create("MVA", source, Slow );	
	first=math.max(FastMA.DATA:first(),SlowMA.DATA:first() ) ; 
	
	
	TopLine = instance:addInternalStream(0, 0);
 	BottomLine = instance:addInternalStream(0, 0);
	
	
    Oscillator = instance:addStream("Oscillator", core.Bar, name, "Oscillator", instance.parameters.color1, first );
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));

    Oscillator:addLevel(0);	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));	
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);	

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);		
end


function Update(period, mode)

	FastMA:update(mode); 
	SlowMA:update(mode); 
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	Oscillator[period]=FastMA.DATA[period]-SlowMA.DATA[period];
	
 
    if Oscillator[period]> 0 then
	Oscillator:setColor(period, instance.parameters.color1);	
	TopLine[period]=Oscillator[period]*Coefficient+TopLine[period-1]*(1-Coefficient)
	BottomLine[period]=BottomLine[period-1];
	else
	Oscillator:setColor(period, instance.parameters.color2);	
	TopLine[period]=TopLine[period-1]
	BottomLine[period]=Oscillator[period]*Coefficient+BottomLine[period-1]*(1-Coefficient);	
    end
	  	
 
	Top[period] = TopLine[period]+(Strength/100)*TopLine[period]  
	Bottom[period] =BottomLine[period]-(Strength/100)*BottomLine[period] 
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