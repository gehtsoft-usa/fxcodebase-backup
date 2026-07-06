-- Id: 12115
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60878

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
    indicator:name("Range Histogram");
    indicator:description("Range Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Type", "Range Type", "Range Type", "HL");
	indicator.parameters:addStringAlternative("Type", "High/Low", "High/Low" , "HL");
    indicator.parameters:addStringAlternative("Type", "Open/Close", "Open/Close" , "OC");
	
	
	indicator.parameters:addBoolean("Use"  , "Use Smoothing", "", false);	
    indicator.parameters:addInteger("Period", "Smoothing Period", "Period", 14);
	indicator.parameters:addString("Method", "Smoothing MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA"); 
  
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Range_color", "Color of Range", "Color of Range", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Type;
local Method;
local first;
local source = nil;
local ma;
local Use;
-- Streams block
local Range = nil;
local Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    Type = instance.parameters.Type;
	Use = instance.parameters.Use;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Type) .. ", " .. tostring(Period)  .. ", " .. tostring(Method) .. ", " .. tostring(Type) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Raw = instance:addInternalStream(0, 0);
        
        if Use then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
            ma = core.indicators:create(Method, Raw, Period);
            first = ma.DATA:first();
        else
            first = source:first();
        end
        Range = instance:addStream("Range", core.Bar, name, "Range", instance.parameters.Range_color, first);
    Range:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   
    if Type== "OC" then
    Raw[period] = math.abs(source.open[period]-source.close[period]); 
    else
    Raw[period] = source.high[period]-source.low[period];
	end
    	
    if period < first   then
	return;
	end
	
	if Use then
	ma:update(mode);
    Range[period] = ma.DATA[period];
	else
	Range[period] = Raw[period];
	end
    
end

