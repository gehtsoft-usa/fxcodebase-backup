-- Id: 8734
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23559

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
    indicator:name("Normalization");
    indicator:description("Normalization");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	 indicator.parameters:addGroup("Calcultion")    
    indicator.parameters:addInteger("Period", "Normalization Period", "Period", 50);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Normalization_color", "Color of Normalization", "Color of Normalization", core.rgb(255, 0, 0));
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
local first;
local source = nil;

-- Streams block
local Normalization = nil;
 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	 
	Mode = instance.parameters.Mode;
    source = instance.source;
    first = source:first()+Period;
    

    local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
        Normalization = instance:addStream("Normalization", core.Line, name, "Normalization", instance.parameters.Normalization_color, first);
    Normalization:setPrecision(math.max(2, instance.source:getPrecision()));
		Normalization:setWidth(instance.parameters.width);
        Normalization:setStyle(instance.parameters.style);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period  )
    if period < first  then
	return;
	end	   
	 
		local min, max;
		min,max=mathex.minmax(source, period-Period+1, period);
		Normalization[period] = ((source[period] - min)/ (max-min))*100; 		
		 
end

