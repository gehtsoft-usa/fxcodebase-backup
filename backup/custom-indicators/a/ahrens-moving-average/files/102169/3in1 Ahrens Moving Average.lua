-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62629

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
    indicator:name("3 in 1 AhrensMovingAverage");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "1. Period", "Period", 5);
	indicator.parameters:addInteger("Period2", "2. Period", "Period", 15);
	indicator.parameters:addInteger("Period3", "3. Period", "Period", 45);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "1. Line Color", "Color of AMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "2. Line Color", "Color of AMA", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color3", "3. Line Color", "Color of AMA", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end
	

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
local Period2;
local Period3;

local first;
local source = nil;

-- Streams block
local AMA1 = nil;
local AMA2 = nil;
local AMA3 = nil;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	
    source = instance.source;
    first = source:first()+math.max(Period1, Period2,Period3);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1).. ", " .. tostring(Period2) .. ", " .. tostring(Period3)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        AMA1 = instance:addStream("AMA1", core.Line, name, "1. AMA", instance.parameters.color1, first);
		AMA1:setWidth(instance.parameters.width1);
        AMA1:setStyle(instance.parameters.style1);
		
		AMA2 = instance:addStream("AMA2", core.Line, name, "2. AMA", instance.parameters.color2, first);
		AMA2:setWidth(instance.parameters.width2);
        AMA2:setStyle(instance.parameters.style2);
		
		AMA3 = instance:addStream("AMA3", core.Line, name, "3. AMA", instance.parameters.color3, first);
		AMA3:setWidth(instance.parameters.width3);
        AMA3:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	   
			local Median1=(AMA1[period-1]+AMA1[period-Period1])/2; 			 	 
			AMA1[period]=  AMA1[period-1]+((source.median[period]-Median1)/Period1);
			
			local Median2=(AMA2[period-1]+AMA2[period-Period2])/2; 			 	 
			AMA2[period]=  AMA2[period-1]+((source.median[period]-Median2)/Period2);
			
			local Median3=(AMA3[period-1]+AMA3[period-Period3])/2; 			 	 
			AMA3[period]=  AMA3[period-1]+((source.median[period]-Median3)/Period3);
			
			
			 
		    
 
    
end

