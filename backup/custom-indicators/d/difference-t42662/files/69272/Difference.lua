-- Id: 9456
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=42662

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
    indicator:name("Difference");
    indicator:description("Difference");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 1, 1, 1000);
	 indicator.parameters:addBoolean("Absolute", "Absolute", "Absolute" ,  true);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local source = nil;
local Period;
-- Streams block
local AV = nil;
local Absolute;

-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
	Period=instance.parameters.Period;
	Absolute=instance.parameters.Absolute;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name()  .. ", " .. Period.. ", ".. (not Absolute and "Relative" or "Absolute")   .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        AV = instance:addStream("AV", core.Line, name, "Difference", instance.parameters.color, first);
    AV:setPrecision(math.max(2, instance.source:getPrecision()));
		AV:setWidth(instance.parameters.width);
        AV:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	    if Absolute then
		 AV[period] = math.abs(source[period]-source[period-Period]);
		else
        AV[period] = source[period]-source[period-Period];
		end
    
end

