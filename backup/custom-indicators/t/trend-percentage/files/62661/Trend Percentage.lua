-- Id: 9166
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=37755

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend Percentage");
    indicator:description("Trend Percentage");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Bull_color", "Color of Bull", "Color of Bull", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bear_color", "Color of Bear", "Color of Bear", core.rgb(255, 0, 0));
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

local first;
local source = nil;

-- Streams block
local Bull = nil;
local Bear = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
        Bull = instance:addStream("Bull", core.Line, name .. ".Bull", "Bull", instance.parameters.Bull_color, first);
    Bull:setPrecision(math.max(2, instance.source:getPrecision()));
		Bull:setWidth(instance.parameters.width1);
        Bull:setStyle(instance.parameters.style1);
        Bear = instance:addStream("Bear", core.Line, name .. ".Bear", "Bear", instance.parameters.Bear_color, first);
    Bear:setPrecision(math.max(2, instance.source:getPrecision()));
		Bear:setWidth(instance.parameters.width2);
        Bear:setStyle(instance.parameters.style2);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
	    local bull = 0;
        local bear = 0;
	
	
	local i;
	for i = period-Period, period-1, 1 do
	
	    if source[i] > source[i-1] then
        bull = bull  + math.abs( source[i] - source[i-1] );
		elseif source[i] < source[i-1] then
        bear  = bear  + math.abs( source[i] - source[i-1] );
		end
		
	end	
	
	Bull[period]=  bull / ((bull+bear)/100);
	Bear[period]=  bear / ((bull+bear)/100);
		
    
end

