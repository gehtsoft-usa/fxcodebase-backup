-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59830
-- Id: 10400

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
    indicator:name("Volume Accumulation Percentage Indicator");
    indicator:description("Volume Accumulation Percentage Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", " " , 14); 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VA_color", "Color of VACC", "Color of VACC", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local VA = nil;
local VACC = nil;
local Period;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Period=instance.parameters.Period;
	
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        VA= instance:addInternalStream(0, 0);
        VACC = instance:addStream("VACC", core.Bar, name, "VACC", instance.parameters.VA_color, first);
    VACC:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	
	    if (source.high[period]-source.low[period]) == 0 then
		VA[period]=0;
		else		
        VA[period] = source.volume[period] * ((source.close[period]-source.low[period])-(source.high[period]-source.close[period]))/(source.high[period]-source.low[period]);
        end
		
		
		
	if period < first  then
	return;	
	end
		
		local TVA= mathex.sum(VA, period-Period+1, period);
		local TV= mathex.sum(source.volume, period-Period+1, period);
		
		
		 VACC[period] = (TVA / TV) * 100
end

