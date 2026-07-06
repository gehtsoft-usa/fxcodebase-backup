-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60385
-- Id: 11264

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
    indicator:name("Reverse Min Max");
    indicator:description("Reverse Min Max");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Min Max Period", "Min Max Period", 20);	
    indicator.parameters:addInteger("Reverse", "Reverse Period", "Reverse Period", 5);
	

	
	indicator.parameters:addGroup("Style");
	
		indicator.parameters:addBoolean("Show", "Show Min/Max", "", false);
    indicator.parameters:addColor("Min_color", "Color of Min", "Color of Min", core.rgb(0, 0, 255));	
    indicator.parameters:addColor("Max_color", "Color of Max", "Color of Max", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("width1", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("ReverseMin_color", "Color of ReverseMin", "Color of ReverseMin", core.rgb(255, 0, 0));
    indicator.parameters:addColor("ReverseMax_color", "Color of ReverseMax", "Color of ReverseMax", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("width2", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Reverse;
local Show;
local first;
local source = nil;

-- Streams block
local Min = nil;
local Max = nil;
local ReverseMin = nil;
local ReverseMax = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Show = instance.parameters.Show;
    Reverse = instance.parameters.Reverse;
    source = instance.source;
    first = source:first() +Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Reverse) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
	
	    if Show then
        Min = instance:addStream("Min", core.Line, name .. ".Min", "Min", instance.parameters.Min_color, first);
		Min:setWidth(instance.parameters.width1);
        Min:setStyle(instance.parameters.style1);
		
        Max = instance:addStream("Max", core.Line, name .. ".Max", "Max", instance.parameters.Max_color, first);
		Max:setWidth(instance.parameters.width1);
        Max:setStyle(instance.parameters.style1);
		
		else
		Max = instance:addInternalStream(0, 0);
		Min = instance:addInternalStream(0, 0);
		end
		
		
        ReverseMin = instance:addStream("ReverseMin", core.Line, name .. ".ReverseMin", "ReverseMin", instance.parameters.ReverseMin_color, first);
		ReverseMin:setWidth(instance.parameters.width2);
        ReverseMin:setStyle(instance.parameters.style2);
		
        ReverseMax = instance:addStream("ReverseMax", core.Line, name .. ".ReverseMax", "ReverseMax", instance.parameters.ReverseMax_color,  source:first() +Reverse);
		ReverseMax:setWidth(instance.parameters.width2);
        ReverseMax:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period < first or not source:hasData(period) then
	return;
	end
	
	    local min,max=  mathex.minmax(source, period-Period+1,  period-1);
        Min[period] =min;
        Max[period] = max;
		
		
		if period < source:first() +Reverse then
		return;
		end
		
        ReverseMin[period] = mathex.max(source.low, period-Reverse+1,  period-1); 		
        ReverseMax[period] =  mathex.min(source.high, period-Reverse+1,  period-1);
     
end

