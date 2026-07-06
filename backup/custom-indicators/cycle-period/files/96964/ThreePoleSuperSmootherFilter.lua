-- Id: 12927
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61420

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
    indicator:name("ThreePoleSuperSmootherFilter");
    indicator:description("ThreePoleSuperSmootherFilter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("CutoffPeriod", "CutoffPeriod", "CutoffPeriod", 15);
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Filter_color", "Color of Filter", "Color of Filter", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CutoffPeriod;

local first;
local source = nil;

-- Streams block
local Filter = nil;
local tempReal, rad2Deg, deg2Rad;
local coef1, coef2, coef3, coef4;
-- Routine
function Prepare(nameOnly)
    CutoffPeriod = instance.parameters.CutoffPeriod;
    source = instance.source;
    first = source:first()+3;
	
	
	tempReal = math.atan(1.0);
    rad2Deg = 45.0 / tempReal;
    deg2Rad = 1.0 / rad2Deg;
    local pi = math.atan(1.0) * 4.0;
    local a1 = math.exp(-pi / CutoffPeriod);
    local b1 = 2 * a1 * math.cos(deg2Rad * math.sqrt(3.0) * 180 / CutoffPeriod);
    local c1 = a1 * a1;
    coef2 = b1 + c1;
    coef3 = -(c1 + b1 * c1);
    coef4 = c1 * c1;
    coef1 = 1.0 - coef2 - coef3 - coef4;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CutoffPeriod) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Filter = instance:addStream("Filter", core.Line, name, "Filter", instance.parameters.Filter_color, first);
		Filter:setWidth(instance.parameters.width);
        Filter:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first +3 or not source:hasData(period) then
	return;
	end
        Filter[period]  = coef1 * source.median[period] +  coef2 * Filter[period- 1] + coef3 * Filter[period - 2] +  coef4 * Filter[period - 3];
    
end

