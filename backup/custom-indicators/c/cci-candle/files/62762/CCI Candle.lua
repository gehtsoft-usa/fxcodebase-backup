-- Id: 9173
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=37837

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
    indicator:name("CCI Candle");
    indicator:description("CCI Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period", "CCI period", "CCI Period", 14);

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

local CCIOpen = nil;
local CCIClose = nil;
local CCIHigh = nil;
local CCILow = nil;
  
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator("TBCCI") ~= nil, "Please, download and install TBCCI.LUA indicator");
     
    CCIOpen = core.indicators:create("TBCCI", source.open, Period);
	CCIHigh = core.indicators:create("TBCCI", source.high, Period);
	CCILow = core.indicators:create("TBCCI", source.low, Period);
	CCIClose = core.indicators:create("TBCCI", source.close, Period);	
	
	first = CCIClose.DATA:first() ;
    Open = instance:addStream("Open", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Close = instance:addStream("Close", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    High = instance:addStream("High", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Low = instance:addStream("Low", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
	
	Open:setPrecision(math.max(2, instance.source:getPrecision()));
	Close:setPrecision(math.max(2, instance.source:getPrecision()));
	High:setPrecision(math.max(2, instance.source:getPrecision()));
	Low:setPrecision(math.max(2, instance.source:getPrecision()));
	
	instance:createCandleGroup("CCI", "CCI Candle", Open, High, Low, Close);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first   then
	return;
	end	
	CCIOpen:update(mode);
	CCIClose:update(mode);
	CCIHigh:update(mode);
	CCILow:update(mode);
	
 	
        Open[period] = CCIOpen.DATA[period];
        Close[period] = CCIClose.DATA[period];
        High[period] = CCIHigh.DATA[period];
        Low[period] = CCILow.DATA[period];
   
end

