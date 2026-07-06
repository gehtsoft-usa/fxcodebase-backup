-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60884
-- Id: 16456

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Consecutive candle Count");
    indicator:description("Consecutive candle Count");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
  --  indicator.parameters:addInteger("Period", "Period", "Period", 5);
	
	indicator.parameters:addBoolean("Extend", "Ignore Zero Body Candles", "", false);

	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Top", "Color of Top Line", "Color of Top Line", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Color of Bottom Line", "Color of Bottom Line", core.rgb(255, 0, 0));
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Count;
-- Streams block
local Top, Bottom;

local Lookback;
local Extend;
-- Routine
function Prepare(nameOnly)
  --  Period = instance.parameters.Period;
	Top = instance.parameters.Top;
	Bottom = instance.parameters.Bottom;
    Extend = instance.parameters.Extend;

    source = instance.source;
    first = source:first() ;
    
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	
	Count = instance:addStream("Count", core.Bar, name, "Count", Top, first);
    Count:setPrecision(math.max(2, instance.source:getPrecision()));
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;	
    end
	
	 Count[period]=Count[period-1];
	 
	
	
	if Extend then
	
	      if  source.close[period] >= source.open[period]
		  then
			
				if   source.close[period-1] >= source.open[period-1]
				and source.close[period] >= source.open[period]
				then
				Count[period]=Count[period]+1;
				elseif  source.close[period] > source.open[period]
				then
				Count[period]=1;
				end
				
			end
			
			 if  source.close[period] <= source.open[period] then
			
					if   source.close[period-1] <= source.open[period-1]
					and source.close[period] <= source.open[period]
					then
					Count[period]=Count[period]-1;
					elseif  source.close[period] < source.open[period] 
					then
					Count[period]=-1;
					end
			end
			
	else
	
			
			if  source.close[period] > source.open[period] then
			
				if   source.close[period-1] > source.open[period-1] then
				Count[period]=Count[period]+1;
				else
				Count[period]=1;
				end
				
			
			
			elseif  source.close[period] < source.open[period] then
			
				if   source.close[period-1] < source.open[period-1] then
				Count[period]=Count[period]-1;
				else
				Count[period]=-1;
				end
			end
	
	end
	if Count[period] >0 then
	Count:setColor(period, Top);
	elseif Count[period] <0 then
	Count:setColor(period, Bottom);
	end
end

 