-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=76119

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

function Init()
    indicator:name("Result vs Effort");
    indicator:description("Effort vs Result");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period", "Period", 1,1,  2000);
    indicator.parameters:addInteger("Period2", "Period", "Period", 4,1,  2000);	
    indicator.parameters:addDouble("Multiplier", "Absolute Multiplier", "Absolute Multiplier", 2); 	
    indicator.parameters:addBoolean("Reversal", "Reversal", "Reversal", false); 
    indicator.parameters:addBoolean("Confirmation", "Confirmation", "Confirmation", true);
    indicator.parameters:addBoolean("Trend", "Trend", "Trend", true);
    indicator.parameters:addBoolean("Absolute", "Absolute", "Absolute", true);	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("EffortResult_color", "Color of EffortResult", "Color of EffortResult", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Size", "Size", 10);	
    indicator.parameters:addColor("clrUP", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local EffortResult = nil; 
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;	
	Confirmation = instance.parameters.Confirmation;
	Reversal = instance.parameters.Reversal;
	Trend = instance.parameters.Trend;
	Absolute= instance.parameters.Absolute;
	Multiplier= instance.parameters.Multiplier;
	Size = instance.parameters.Size;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2).. ")";
    instance:name(name);

    if nameOnly then
	return;
	end
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
	
	first=source:first()+Period1;
    ResultEffort = instance:addStream("ResultEffort", core.Line, name, "ResultEffort", instance.parameters.EffortResult_color, first);
    ResultEffort:setPrecision(math.max(2, instance.source:getPrecision()));
  
	
    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Signal_color, first+Period2);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	core.host:execute ("attachTextToChart", "Up")
 	core.host:execute ("attachTextToChart", "Dn")
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    if period < first 
	or not  source:hasData(period)
	then
	return;
	end
 
   ResultEffort[period] = (source.close[period]-source.open[period-Period1+1])/mathex.sum(source.volume, period-Period1+1, period) ;
 
   
     if period < first +Period2 
	or not  source:hasData(period)
	then
	return;
	end
   
   Signal[period]=mathex.avg(ResultEffort, period-Period2+1, period);
   
   
    down:setNoData(period);
    up:setNoData(period);
	
 
	
		 
					if ResultEffort[period ] > ResultEffort[period-1]  
					and (math.abs(ResultEffort[period ]) >  math.abs(ResultEffort[period-1]*Multiplier )and Absolute or not Absolute) 
					and (ResultEffort[period-2] < ResultEffort[period-3] and Reversal or not Reversal)
					and (ResultEffort[period-1] > ResultEffort[period-2] and  Confirmation or not Confirmation)
					and (Trend and ResultEffort[period ] > 0  or not Trend)  then 
					up:set(period , source.high[period ], "\217", source.high[period  ]);
					elseif ResultEffort[period ] < ResultEffort[period-1]
					and (math.abs(ResultEffort[period ]) > math.abs(ResultEffort[period-1] *Multiplier)and Absolute or not Absolute) 
					and (ResultEffort[period-2] > ResultEffort[period-3]   and Reversal or not Reversal)
					and (ResultEffort[period-1] < ResultEffort[period-2]and  Confirmation or not Confirmation)
			 
					and (Trend and ResultEffort[period ] < 0  or not Trend)  then
					down:set(period , source.low[period ], "\218", source.low[period  ]);  
					end	
			 
				
	
	 
end

-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=76119

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 