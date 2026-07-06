-- Id: 13703
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61958

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
    indicator:name("Zero Lag MACD Candle");
    indicator:description("Zero Lag MACD Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("SN", "Short EMA", "(SN)No Description", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "(LN)No Description", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "(IN)No Description", 9, 2, 1000);
	
	indicator.parameters:addString("Method", "Candle Method", "Method" , "MACD");
    indicator.parameters:addStringAlternative("Method", "MACD", "MACD" , "MACD");
    indicator.parameters:addStringAlternative("Method", "SIGNAL", "SIGNAL" , "SIGNAL");
    indicator.parameters:addStringAlternative("Method", "HISTOGRAM", "HISTOGRAM" , "HISTOGRAM");

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SN,LN,IN;
local Method;
local first;
local source = nil;

-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;

local MACDOpen = nil;
local MACDClose = nil;
local MACDHigh = nil;
local MACDLow = nil;
local Price;  
-- Routine
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	Price = instance.parameters.Price;
	Method = instance.parameters.Method;
    source = instance.source; 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN.. ", " .. LN.. ", " .. IN .. ", " .. Method.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("ZEROLAGMACD") ~= nil, "Please, download and install ZEROLAGMACD.LUA indicator");
	
    MACDOpen = core.indicators:create("ZEROLAGMACD", source.open, SN, LN,IN);
	MACDHigh = core.indicators:create("ZEROLAGMACD", source.high, SN, LN,IN);
	MACDLow = core.indicators:create("ZEROLAGMACD", source.low, SN, LN,IN);
	MACDClose = core.indicators:create("ZEROLAGMACD", source.close, SN, LN,IN);	
	
	first = MACDClose.DATA:first() ;
    Open = instance:addStream("Open", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Open:setPrecision(math.max(2, instance.source:getPrecision()));
    Close = instance:addStream("Close", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
    High = instance:addStream("High", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    High:setPrecision(math.max(2, instance.source:getPrecision()));
    Low = instance:addStream("Low", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Low:setPrecision(math.max(2, instance.source:getPrecision()));
	instance:createCandleGroup("MACD", "Zero Lag MACD Candle", Open, High, Low, Close);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first   then
	return;
	end	
	MACDOpen:update(mode);
	MACDClose:update(mode);
	MACDHigh:update(mode);
	MACDLow:update(mode);
	
 	
        Open[period] = MACDOpen[Method][period];
        Close[period] = MACDClose[Method][period];
        High[period] = math.max( MACDHigh[Method][period], Open[period] , Close[period] );
        Low[period] =  math.min( MACDLow[Method][period], Open[period] , Close[period] );
   
end

