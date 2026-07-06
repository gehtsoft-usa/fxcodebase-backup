-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74653


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
    indicator:name("MACD Heikin-Ashi Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	
    indicator.parameters:addBoolean("ha", "Use Heikin-Ashi as Source", "", true); 	
	indicator.parameters:addString("Price" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");	


	
	indicator.parameters:addInteger("Fast", "Short Period", "", 12, 1, 1000);
	indicator.parameters:addInteger("Slow", "Long Period", "", 26, 1, 1000);	  
	indicator.parameters:addInteger("Signal", "Signal Period", "", 9, 1, 1000);	 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(128, 128, 128));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local source = nil; 
local Indicator;
local first;

local Price, Fast, Slow, Signal;

 function Prepare(nameOnly)   
 
 
    Price= instance.parameters.Price;
    Fast= instance.parameters.Fast;
	Slow= instance.parameters.Slow;
	Signal= instance.parameters.Signal;
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Price .. ", " ..  Fast  .. ", " .. Slow .. ", " .. Signal .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
    ha= instance.parameters.ha;
    
	

	source = instance.source; 
	
	
    --Source = instance:addInternalStream(0, 0);	
	MACD=core.indicators:create("MACD",  source[Price], Fast, Slow, Signal);
	HA=core.indicators:create("HA",  source );
 
	
	
	first= math.max(MACD.HISTOGRAM:first());

    	
	open = instance:addStream("openup", core.Line, name, "", core.COLOR_LABEL, first);
    high = instance:addStream("highup", core.Line, name, "", core.COLOR_LABEL, first);
    low = instance:addStream("lowup", core.Line, name, "", core.COLOR_LABEL, first);
    close = instance:addStream("closeup", core.Line, name, "", core.COLOR_LABEL, first);
    instance:createCandleGroup("Candle", "Candle", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)


	MACD:update(mode);
	HA:update(mode);
	
	if period <= first 
	or not source:hasData(period)
	then
	return;
	end
     
	if ha then
    open[period] = HA.open[period];
	close[period] = HA.close[period];
	high[period] = HA.high[period];
	low[period] = HA.low[period];	
	else
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	end
	


 	if MACD.HISTOGRAM[period]> 0 and HA.close[period] > HA.open[period] then
	open:setColor(period,  Up); 
 	elseif MACD.HISTOGRAM[period] <  0 and HA.close[period] < HA.open[period] then
	open:setColor(period,  Down); 
	else
	open:setColor(period, Neutral);	
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