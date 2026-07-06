-- Available @ http://fxcodebase.com/ 

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

function Init()
    indicator:name("Advance Advance decline ratio");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 9, 2, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);


    indicator.parameters:addGroup("Levels");	 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local Period; 
local first;
local source = nil;
local AD;  
local Up,Down;

-- Routine
 function Prepare(nameOnly)   
   
    Period= instance.parameters.Period;
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
    source = instance.source;     
    first=source:first()+Period;
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	 
 
	AD = instance:addStream("AD" , core.Line, "AD","AD",instance.parameters.color, first);
    AD:setPrecision(math.max(2, instance.source:getPrecision()));
	AD:setWidth(instance.parameters.width);
    AD:setStyle(instance.parameters.style);
	AD:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    
 
	
end

-- Indicator calculation routine
function Update(period, mode)

    if source.close[period]>source.open[period] then
	Up[period]=1;
	Down[period]=0;
	elseif source.close[period]<source.open[period] then
	Up[period]=0;
	Down[period]=1;
	else
	Up[period]=0;
	Down[period]=0;	
	end
		
    if period <= first then
	return;
	end
	
	
	local upBars=mathex.sum(Up, period-Period+1, period)
	local downBars=mathex.sum(Down, period-Period+1, period)
	
	
     if upBars > downBars then
     AD[period]=upBars/downBars;
	 elseif upBars < downBars then
	 AD[period]=-downBars/upBars;
	 else
	 AD[period]=0;
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
