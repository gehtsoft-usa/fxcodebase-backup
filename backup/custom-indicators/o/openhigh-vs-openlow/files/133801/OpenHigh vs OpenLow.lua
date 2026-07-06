-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63018

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("OpenHigh vs OpenLow  ");
    indicator:description("OpenHigh vs OpenLow  ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
 
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("OH_color", "Color of High Open", "Color of OH", core.rgb(0, 255, 0));
    indicator.parameters:addColor("OL_color", "Color of Open Low", "Color of OL", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local OH = nil;
local OL = nil;
local SumUp;
local SUM;
local Accumulate;
local Direction;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	 
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

  
        OH = instance:addStream("OH", core.Bar, name .. ".OH", "OH", instance.parameters.OH_color, first);		
    OH:setPrecision(math.max(2, instance.source:getPrecision()));
        OL = instance:addStream("OL", core.Bar, name .. ".OL", "OL", instance.parameters.OL_color, first);
    OL:setPrecision(math.max(2, instance.source:getPrecision()));
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <first or not source:hasData(period) then
	return;
	end
        
		OH[period]=0;
		OL[period]=0;
        if source.close[period]> source.open[period] then
        OH[period] = (source.high[period]-source.open[period])/source:pipSize(); 
		elseif source.close[period]< source.open[period] then
        OL[period] = -(source.open[period]-source.low[period])/source:pipSize(); 
		end
 
		
end

