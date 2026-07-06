-- Id: 8800
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33851

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+-----------------------------------------------------f-------------+
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
    indicator:name("ADX Difference");
    indicator:description("ADX Difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "ADX Period", "Period", 14);
	indicator.parameters:addInteger("Difference", "Difference Period", "Period", 1);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DIFFERENCE_color", "Color of Difference", "Color of Difference", core.rgb(255, 0, 0));
	 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local ADX;
-- Streams block
local DIFFERENCE = nil;
local Difference;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Difference = instance.parameters.Difference;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    if (not (nameOnly)) then
        ADX = core.indicators:create("ADX", source,period );
        first = ADX.DATA:first()+Difference;
        DIFFERENCE = instance:addStream("Difference", core.Bar, name, "Difference", instance.parameters.DIFFERENCE_color, first);
		
		DIFFERENCE:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ADX:update(mode);
    if period < first   then
	return;
	end
	
        DIFFERENCE[period] = ADX.DATA[period]-ADX.DATA[period-Difference];
    
end

