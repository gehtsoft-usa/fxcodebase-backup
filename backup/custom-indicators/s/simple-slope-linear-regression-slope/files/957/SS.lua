-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=547
-- Id: 6540

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
    indicator:name("Simple Slope");
    indicator:description("Simple Slope");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("period", "Period", "Period", 14);
    indicator.parameters:addColor("slope_color", "Color of slope", "Color of slope", core.rgb(255, 0, 0));
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

-- Streams block
local slope = nil;
local frame=0;

-- Routine
function Prepare(nameOnly)
    frame = instance.parameters.period;
    source = instance.source;
    first = source:first()+frame;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    slope = instance:addStream("SL", core.Line, name, "slope", instance.parameters.slope_color, first);
    slope:setPrecision(math.max(2, instance.source:getPrecision()));
	slope :setWidth(instance.parameters.width);
    slope :setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
   if period < frame or not  source:hasData(period) then
   return;
   end
   
   
	slope[period]=(source[period]-source[period-frame])/(period-(period-frame));
 
end

