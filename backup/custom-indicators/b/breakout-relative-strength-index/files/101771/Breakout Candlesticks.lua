-- Id: 14656
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62528

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
    indicator:name("BREAKOUT CANDLESTICKS");
    indicator:description("BREAKOUT CANDLESTICKS");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("replaceSource", "t");

    indicator.parameters:addInteger("Period", "Period", "Period", 2);
  
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
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local volume=nil;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
        high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
        low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
        close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
        volume = instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), first)
        instance:createCandleGroup("ZONE", "Breakout Candlesticks", open, high, low, close,volume);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
    return;
    end
	local min,max= mathex.minmax(source,period-Period+1, period );
	high[period]= max
	low[period]= min;		   
	close[period] = source.close[period];
	open[period]  = source.open[period-Period+1];
	volume[period]= mathex.sum(source.volume,period-Period+1, period );
end

