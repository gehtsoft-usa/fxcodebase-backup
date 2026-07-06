-- Id: 17266
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64244

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MA_Candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	    indicator.parameters:addGroup("Caclulation");

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	 
	indicator.parameters:addInteger("Period", "Period","", 34);
	
	
end

local first;
local source = nil;
local open = nil;
local high = nil;
local low = nil;
local close = nil;


local High, Low, Close,Open;
local Method, Period;


function Prepare(nameOnly)
    source = instance.source;
   
   
   Method=instance.parameters.Method;
   Period=instance.parameters.Period;
 

    local name = profile:id() .. " " .. source:name()  .. " : " .. Method .. " : " .. Period;
	 instance:name(name );
    if nameOnly then
        return;
    end
 
 
 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    High = core.indicators:create(Method, source.high ,  Period);
	Low = core.indicators:create(Method, source.low ,  Period);
	Open = core.indicators:create(Method, source.open ,  Period);
	Close = core.indicators:create(Method, source.close ,  Period);
	first=Close.DATA:first();
	
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("OtherCandles", "OtherCandles", open, high, low, close);
end

function Update(period, mode)
   if (period <first) then
   return;
   end
   
    High:update(mode);
	Low:update(mode);
	Close:update(mode);
	Open:update(mode);
	
	
    open[period]=Open.DATA[period]
    close[period]=Close.DATA[period]
    high[period]=High.DATA[period]
    low[period]=Low.DATA[period]
   
end

