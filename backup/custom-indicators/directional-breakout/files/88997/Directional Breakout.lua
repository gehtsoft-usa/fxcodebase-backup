-- Id: 9822
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59342

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
    indicator:name("Directional Breakout");
    indicator:description("Directional Breakout");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Positiv", "Color of Positiv", "Color of Positiv", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Negativ", "Color of Negativ", "Color of Negativ", core.rgb(255, 0, 0));
	--indicator.parameters:addInteger("transparency", "Transparency (%)", "", 70, 0, 100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Price;
local first;
local source = nil;
local Method;
-- Streams block
local open, close, high, low;
local MA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Price = instance.parameters.Price;
	Method = instance.parameters.Method;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Price).. ", " .. tostring(Method).. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MA = core.indicators:create("EMA", source[Price], Period);
    
        first = MA.DATA:first();
	
	   open = instance:addInternalStream(first, 0);
	   close = instance:addInternalStream(first, 0);
	   high = instance:addInternalStream(first, 0);
       low = instance:addInternalStream(first, 0);
	   
	   open:setPrecision(math.max(2, instance.source:getPrecision()));
	   close:setPrecision(math.max(2, instance.source:getPrecision()));
	   high:setPrecision(math.max(2, instance.source:getPrecision()));
	   low:setPrecision(math.max(2, instance.source:getPrecision()));

	   instance:createCandleGroup ("DB", "DB", open, high, low, close);
    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first then
	return;
	end
	
	
	
	MA:update(mode);

	if source.low[period]>MA.DATA[period] then	   
	    open:setColor(period, instance.parameters.Positiv);
		open[period] = 2;
        close[period] = 0;
		high[period] = 2;
        low[period] = 0;	
	elseif source.high[period]<MA.DATA[period] then
	    open:setColor(period, instance.parameters.Negativ);
		open[period] = 0;
        close[period] = -2;
		high[period] = 0;
        low[period] = -2;		
	else
	    open:setColor(period, instance.parameters.Neutral);
	     open[period] = 1;
        close[period] = -1;
		high[period] = 1;
        low[period] = -1;	
		
	end	
	
	
end

