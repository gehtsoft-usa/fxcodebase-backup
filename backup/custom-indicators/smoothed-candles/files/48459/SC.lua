-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27689
-- Id: 8102

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Smoothed Candles");
    indicator:description("Smoothed Candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
     indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of Up Candles", "Color of Up Candles", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down Candles", "Color of Down Candles", core.rgb(255, 0, 0));
     
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local first;
local source = nil;

-- Streams block
local open = nil;
local close = nil;
local high = nil;
local low = nil;
local OPEN, CLOSE, HIGH, LOW;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        OPEN = core.indicators:create(Method, source.open, Period);
        CLOSE = core.indicators:create(Method, source.close, Period);
        HIGH = core.indicators:create(Method, source.high, Period);
        LOW = core.indicators:create(Method, source.low, Period);
        
        first =OPEN.DATA:first();
        open = instance:addStream("open", core.Line, name .. ".open", "open",  core.rgb(0, 0, 0), first);
        close = instance:addStream("close", core.Line, name .. ".close", "close",  core.rgb(0, 0, 0), first);
        high = instance:addStream("high", core.Line, name .. ".high", "high",  core.rgb(0, 0, 0), first);
        low = instance:addStream("low", core.Line, name .. ".low", "low",  core.rgb(0, 0, 0), first);
		instance:createCandleGroup("Smoothed", "Smoothed", open, high, low, close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    OPEN:update(mode);
    CLOSE:update(mode);	
	HIGH:update(mode);
    LOW:update(mode);	

    if period  < first  then
	return;
	end
	
	 high[period]= HIGH.DATA[period];
	low[period]= LOW.DATA[period];		   
	close[period] = CLOSE.DATA[period];
	open[period]  = OPEN.DATA[period];
        
    if open[period]< close[period] then
	open:setColor(period, instance.parameters.Up);
	else
	open:setColor(period, instance.parameters.Down);
	end
	
end

