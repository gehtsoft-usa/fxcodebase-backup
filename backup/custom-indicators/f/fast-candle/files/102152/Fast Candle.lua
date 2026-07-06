-- Id: 14762
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62625

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Fast Candle");
    indicator:description("Fast Candle");
    indicator:requiredSource(core.Bar);
	indicator:setTag("replaceSource", "t");
    indicator:type(core.Indicator);

    indicator.parameters:addDouble("Volume_Factor", "Volume Factor", "Volume Factor", 0.2);
    indicator.parameters:addInteger("Period", "Period", "Period", 3);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Volume_Factor;
local Period;

local first;
local source = nil;

-- Streams block
local open, close, high, low = nil;
local cdFast, cdSlow;
local T3_Fast, T3_Slow; 
-- Routine
function Prepare(nameOnly)
    Volume_Factor = instance.parameters.Volume_Factor;
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Volume_Factor) .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	assert(core.indicators:findIndicator("T3") ~= nil, "Please, download and install T3.LUA indicator");
	assert(core.indicators:findIndicator("GD") ~= nil, "Please, download and install GD.LUA indicator");

    if (not (nameOnly)) then
		cdFast= instance:addInternalStream(first, 0);
		cdSlow= instance:addInternalStream(first, 0); 
		
		T3_Fast = core.indicators:create("T3", cdFast, Volume_Factor, Period);
		T3_Slow = core.indicators:create("T3", cdSlow, Volume_Factor, Period);
		T3_High = core.indicators:create("T3", source.high, Volume_Factor, Period);
		T3_Low = core.indicators:create("T3", source.low, Volume_Factor, Period);
		
		open = instance:addInternalStream(T3_Fast.DATA:first()+1, 0);
		high =instance:addInternalStream(T3_Fast.DATA:first()+1, 0);
		low = instance:addInternalStream(T3_Fast.DATA:first()+1, 0);
		close = instance:addInternalStream(T3_Fast.DATA:first()+1, 0);
		instance:createCandleGroup("ZONE", "", open, high, low, close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    
    if period < first or not source:hasData(period) then
	return;
	end
	
 
	
    if source.close[period] >source.open[period]   then
	cdFast[period]=(source.close[period]+source.high[period])/2
    else
	cdFast[period]=(source.close[period]+source.open[period])/2
	end
	
	
	if source.close[period] >source.open[period]   then
	cdSlow[period]=(source.open[period]+source.low[period])/2
    else
	cdSlow[period]=(source.open[period]+source.high[period])/2
	end
	
	T3_Fast:update(mode);
	T3_Slow:update(mode);
	T3_High:update(mode);
	T3_Low:update(mode);
	
	if period < T3_Fast.DATA:first()+1 then
	return;
	end
	
	period= period-1;
	
	close[period+1]= T3_Fast.DATA[period];
	open[period+1]= T3_Slow.DATA[period-1];
	high[period+1]= T3_High.DATA[period+1];
	low[period+1]= T3_Low.DATA[period+1];
end
 

