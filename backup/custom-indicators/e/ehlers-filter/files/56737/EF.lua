-- Id: 8749
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33433

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
    indicator:name("Ehlers Filter");
    indicator:description("Ehlers Filter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addInteger("Momentum", "Momentum", "Momentum", 5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("EF_color", "Color of EF", "Color of EF", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Momentum;
local first;
local source = nil;
local PriceCoef, Coef;
-- Streams block
local EF = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Momentum = instance.parameters.Momentum;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Momentum) .. ")";
    instance:name(name);
    if (not (nameOnly)) then
        Coef= instance:addInternalStream(0, 0);
        PriceCoef= instance:addInternalStream(0, 0);
        EF = instance:addStream("EF", core.Line, name, "EF", instance.parameters.EF_color, first +  Momentum +Period);
		EF:setWidth(instance.parameters.width);
        EF:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period< first +  Momentum then
	return;
	end
	
	
	Coef[period] = math.abs(source[period] - source[period  - Momentum]);
	PriceCoef[period] = Coef[period]*source[period];
	
	if period< first +  Momentum +Period then
	return;
	end
 
 
        EF[period] = mathex.sum(PriceCoef, period-Period+1, period) / mathex.sum(Coef, period-Period+1, period)
    
end

