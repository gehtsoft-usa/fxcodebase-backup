-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22579
-- Id: 7166

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("New High  New Low Index");
    indicator:description("New High  New Low Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("C_color", "Index Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("H_color", "Color of New Low", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("H_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("H_style", "Line style", "", core.LINE_NONE);
    indicator.parameters:setFlag("H_style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("L_color", "Color of New High", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("L_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("L_style", "Line style", "", core.LINE_NONE);
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE);
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
local c, h, l;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        c = instance:addStream("C", core.Line, name, "C", instance.parameters.C_color, first);
    c:setPrecision(math.max(2, instance.source:getPrecision()));
		c:setWidth(instance.parameters.width);
        c:setStyle(instance.parameters.style);
		h = instance:addStream("H", core.Line, name, "H", instance.parameters.H_color, first);
    h:setPrecision(math.max(2, instance.source:getPrecision()));
		h:setWidth(instance.parameters.H_width);
        h:setStyle(instance.parameters.H_style);
		l = instance:addStream("L", core.Line, name, "L", instance.parameters.L_color, first);
    l:setPrecision(math.max(2, instance.source:getPrecision()));
		l:setWidth(instance.parameters.L_width);
        l:setStyle(instance.parameters.L_style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	    h[period]= HIGH(period);
	    l[period]= LOW(period);
        c[period] = h[period]+l[period];    
end

function HIGH(period)


   local i;
   local count=0;
   
   for i = period-Period+1, period, 1 do
   
   if source.high[i] > source.high[i-1] then
   count = count+1;
   end
   
   end
   
  return count;   
end	

function LOW(period)	
	
	local i;
   local count=0;
   
   for i = period-Period+1, period, 1 do
   
   if source.low[i] < source.low[i-1] then
   count = count-1;
   end
   
   end
   
  return count; 
	
end




