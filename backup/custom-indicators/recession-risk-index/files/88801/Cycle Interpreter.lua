-- Id: 9784
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59259


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Cycle Interpreter");
    indicator:description("Cycle Interpreter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 0);
	indicator.parameters:addBoolean("Inverse", "Inverse", "", false);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Cycle_color", "Color of Cycle", "Color of Cycle", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 75);
    indicator.parameters:addDouble("oversold","Oversold Level","", 25);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Inverse;
local first;
local source = nil;

-- Streams block
local Cycle = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Inverse = instance.parameters.Inverse;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Cycle = instance:addStream("Cycle", core.Line, name, "Cycle", instance.parameters.Cycle_color, first);
    Cycle:setPrecision(math.max(2, instance.source:getPrecision()));
		Cycle:setWidth(instance.parameters.width);
        Cycle:setStyle(instance.parameters.style);
		Cycle:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Cycle:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		Cycle:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    

    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <first  then
	return;
	end
	
	local min,max;
	if Period == 0 then
	
	min, max=mathex.minmax(source, first, source:size()-2)
	else
	min, max=mathex.minmax(source, period-Period+1, period)
	end
	
	
	if Inverse then
	    Cycle[period] = 100-(source[period]-min)/((max-min)/100);
	else
        Cycle[period] = (source[period]-min)/((max-min)/100);
    end
end

