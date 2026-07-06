-- Id: 12049
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60841

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
    indicator:name("True Strength Index Candle");
    indicator:description("True Strength Index Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Long", "Long Period", "Long Period", 7);
    indicator.parameters:addInteger("Short", "Short Period", "Short Period", 14);
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
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;

local TSIOpen = nil;
local TSIClose = nil;
local TSIHigh = nil;
local TSILow = nil;

local Long, Short;
  
-- Routine
function Prepare(nameOnly)
    Long = instance.parameters.Long;
	Short = instance.parameters.Short;
    source = instance.source;
     
	first = TSIClose.DATA:first() ;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Long .. ", " ..Short .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    TSIOpen = core.indicators:create("TSI", source.open, Long,Short);
	TSIHigh = core.indicators:create("TSI", source.high, Long,Short);
	TSILow = core.indicators:create("TSI", source.low, Long,Short);
	TSIClose = core.indicators:create("TSI", source.close, Long,Short);	
    Open = instance:addStream("Open", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Open:setPrecision(math.max(2, instance.source:getPrecision()));
    Close = instance:addStream("Close", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
    High = instance:addStream("High", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    High:setPrecision(math.max(2, instance.source:getPrecision()));
    Low = instance:addStream("Low", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Low:setPrecision(math.max(2, instance.source:getPrecision()));
	instance:createCandleGroup("TSI", "TSI Candle", Open, High, Low, Close);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first   then
	return;
	end	
	TSIOpen:update(mode);
	TSIClose:update(mode);
	TSIHigh:update(mode);
	TSILow:update(mode);
	
 	
        Open[period] = TSIOpen.DATA[period];
        Close[period] = TSIClose.DATA[period];		
        High[period] =math.max(Open[period], Close[period],  TSIHigh.DATA[period], TSILow.DATA[period]);
        Low[period] = math.min(Open[period], Close[period],  TSIHigh.DATA[period], TSILow.DATA[period]);
   
end

