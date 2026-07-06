-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60274
-- Id: 11057

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
    indicator:name("Range / Volume Ratio");
    indicator:description("Range / Volume Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Calculation Method", "Method" , "Open/Close");
    indicator.parameters:addStringAlternative("Method", "High/Low", "High/Low" , "High/Low");
    indicator.parameters:addStringAlternative("Method", "Open/Close", "Open/Close" , "Open/Close");
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Candle Color", "Color of Ratio", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Candle Color", "Color of Ratio", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;

local first;
local source = nil;

-- Streams block
local Ratio = nil;

-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Ratio = instance:addStream("Ratio", core.Bar, name, "Ratio", instance.parameters.Up, first);
		Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    
    if period < first or not source:hasData(period) then
	return;
	end
	
	if Method == "High/Low" then
	 Ratio[period]=(source.high[period]-source.low[period])/source.volume[period];
	else
	Ratio[period]=math.abs(source.open[period]-source.close[period])/source.volume[period];
	end
	
    if source.close[period] > source.open[period] then
	Ratio:setColor(period, instance.parameters.Up);
	else
	Ratio:setColor(period, instance.parameters.Down);
	end
	
    
end

