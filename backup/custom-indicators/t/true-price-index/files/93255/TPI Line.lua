-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60466
-- Id: 11386

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

function Init()
    indicator:name("True Price Index ");
    indicator:description("True Price Index ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addBoolean("H", "Show High", "", true);
	indicator.parameters:addBoolean("L", "Show Low", "", true);
	indicator.parameters:addBoolean("C", "Show Close", "", true);
	indicator.parameters:addBoolean("O", "Show Open", "", true);

    indicator.parameters:addColor("color1", "Color of Open", "Color", core.rgb(128, 128, 128) );
	indicator.parameters:addColor("color2", "Color of Close", "Color", core.rgb(0, 0, 255) )
	indicator.parameters:addColor("color3", "Color of High", "Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("color4", "Color of Low", "Color", core.rgb(255, 0, 0))

 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
 
-- Streams block
local Open = nil;
local High = nil;
local Low = nil;
local Close = nil;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
 
    first = source:first()+1;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (nameOnly) then
	return;
	end
	
	if instance.parameters.O then
    Open = instance:addStream("Open", core.Line, name .. ".Open", "Open",instance.parameters.color1, first);
    Open:setPrecision(math.max(2, instance.source:getPrecision()));
	else
    Open = instance:addInternalStream(0, 0);	
    end
	if instance.parameters.H then
    High = instance:addStream("High", core.Line, name .. ".High", "High", instance.parameters.color2, first);
    High:setPrecision(math.max(2, instance.source:getPrecision()));
	else
    High = instance:addInternalStream(0, 0);	
    end
	if instance.parameters.L then
    Low = instance:addStream("Low", core.Line, name .. ".Low", "Low", instance.parameters.color3, first);
    Low:setPrecision(math.max(2, instance.source:getPrecision()));	
	else
    Low = instance:addInternalStream(0, 0);	
    end
	if instance.parameters.C then
    Close = instance:addStream("Close", core.Line, name .. ".Close", "Close", instance.parameters.color4, first);
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
	else
    Close = instance:addInternalStream(0, 0);	
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period <first or not  source:hasData(period) then
	return;
	end
	
	local Length = source.high[period]-source.low[period];
	
	if source.close[period]<  source.open[period] then
	Length=- Length;	
	end
	
        Open[period] = Close[period-1];    
        Close[period] = Open[period]+ Length;  
		
		
		High[period] = math.max(Open[period], Close[period]);
        Low[period] =  math.min(Open[period], Close[period]);
end

