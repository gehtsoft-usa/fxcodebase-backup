-- Id: 14366

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62367

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                         http://fxcodebase.com/code/download/file.php?id=8953        Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Volatility Cycle");
    indicator:description("Volatility Cycle");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 18);
    indicator.parameters:addDouble("Multiplicator", "Multiplicator", "No description", 2);
    indicator.parameters:addInteger("Smoothing", "Smoothing", "Smoothing", 2);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VolatilityCycle_color", "Color of VolatilityCycle", "Color of VolatilityCycle", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Multiplicator;
local Smoothing;

local first;
local source = nil;
local Stdev;
-- Streams block
local VolatilityCycle = nil;
local Signal = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Multiplicator = instance.parameters.Multiplicator;
    Smoothing = instance.parameters.Smoothing;
    source = instance.source;
    first = source:first()+Period;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Multiplicator) .. ", " .. tostring(Smoothing) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Stdev= instance:addInternalStream(0, 0);
        VolatilityCycle = instance:addStream("VolatilityCycle", core.Line, name .. ".VolatilityCycle", "VolatilityCycle", instance.parameters.VolatilityCycle_color, first+Period-1);
    VolatilityCycle:setPrecision(math.max(2, instance.source:getPrecision()));
		VolatilityCycle:setWidth(instance.parameters.width1);
        VolatilityCycle:setStyle(instance.parameters.style1);
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, first+Period+Smoothing-1);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	if period < first then
	return;
	end
	
	Stdev[period] =mathex.stdev (source, period-Period+1, period);
	
	if period <= first+Period then
	return;
	end
	
	local min,max=mathex.minmax(Stdev, period-Period+1, period);
	
	VolatilityCycle[period] = (Stdev[period] - min )/ (max-  min);
	
	if period < first +Period +Smoothing then
	return;
	end
	
	Signal[period] = mathex.avg(VolatilityCycle, period-Smoothing+1, period);
	
end

