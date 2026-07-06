-- Id: 9523
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=51747

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
    indicator:name("Chartmill Value Indicator");
    indicator:description("Chartmill Value Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 5);
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
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up Candle", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Dn", "Color of Down", "Color of Down Candle", core.COLOR_DOWNCANDLE);

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

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local MA, ATR;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MA = core.indicators:create(Method, source.median, Period);
        ATR = core.indicators:create("ATR", source, Period);
        first = math.max(MA.DATA:first(),ATR.DATA:first());
        
        open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
        high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
        low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
        close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
		
		open:setPrecision(math.max(2, instance.source:getPrecision()));
		high:setPrecision(math.max(2, instance.source:getPrecision()));
		low:setPrecision(math.max(2, instance.source:getPrecision()));
		close:setPrecision(math.max(2, instance.source:getPrecision()));
        instance:createCandleGroup("CMVI", "", open, high, low, close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA:update(mode);
	ATR:update(mode);
	
    if period < first and source:hasData(period) then
	return;
	end
	
	close[period] = (source.close[period] - MA.DATA[period]) / ATR.DATA[period];
	high[period] = (source.high[period]  - MA.DATA[period]) / ATR.DATA[period];
	low[period] = (source.low[period] - MA.DATA[period]) / ATR.DATA[period];
	open[period] = (source.open[period]  - MA.DATA[period]) / ATR.DATA[period];
	
	if open[period]>open[period] then
	open:setColor(period, instance.parameters.Up);
	elseif open[period]>open[period] then
    open:setColor(period, instance.parameters.Dn);
	end

	
end

