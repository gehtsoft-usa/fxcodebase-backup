-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=547
-- Id: 288

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
    indicator:name("Linear Regression Slope");
    indicator:description("Linear Regression Slope");
    indicator:requiredSource(core.Bar);
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
local b =0;
local c =0;
local oldx=0
local oldy=0
local frame=0;
local testreset=0;
local petlja =0;
local test=0;
local y=0;
local xy=0;
local x=0;
local x2=0;
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
    slope = instance:addStream("slope", core.Line, name, "Slope", instance.parameters.slope_color, first);
    slope:setPrecision(math.max(2, instance.source:getPrecision()));
	slope :setWidth(instance.parameters.width);
    slope :setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 	   
 if period < first or not source:hasData(period) then
 return;
 end
 
		
			        
										
								for petlja = (period-frame), period, 1 do
								
									if petlja == (period-frame) then
									test=1;
									y = source.close[petlja];
									xy=source.close[petlja]*test;
									x=test;
									x2=test*test;
									else
									test=test+1;													
								    y = y + source.close[petlja];
								    xy=xy+(source.close[petlja]*test);
								    x=x+test;
								    x2=x2+(test*test);
									end
							
					   end
    		                  
            c=x2*(test)-x*x;
		    b=(xy*(test)-x*y)/c;			
	        slope[period]=b;
		 
 end