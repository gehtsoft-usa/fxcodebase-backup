-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=61032


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
    indicator:name("SuperSmoother");
    indicator:description("SuperSmoother");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("SuperSmoother_color", "Color of SuperSmoother", "Color of SuperSmoother", core.rgb(255, 0, 0));
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
local SuperSmoother = nil;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

 
        SuperSmoother = instance:addStream("SuperSmoother", core.Line, name, "SuperSmoother", instance.parameters.SuperSmoother_color, first);
		SuperSmoother:setWidth(instance.parameters.width);
        SuperSmoother:setStyle(instance.parameters.style);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <first or not  source:hasData(period) then
	return;
	end
	
 
 
local a1 = math.exp(-1.414*3.14159 / 10);
local b1 = 2*a1*math.cos(1.414*180 / 10);
local c2 = b1;
local c3 = -a1*a1;
local c1 = 1 - c2 - c3;




        SuperSmoother[period] =   c1*(source [period] + source [period-1]) / 2 + c2*SuperSmoother[period-1] + c3*SuperSmoother[period-2];  
   
end

