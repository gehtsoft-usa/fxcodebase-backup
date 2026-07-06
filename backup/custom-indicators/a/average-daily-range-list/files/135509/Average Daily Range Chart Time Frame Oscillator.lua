 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

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
    indicator:name("Average Daily Range");
    indicator:description("Average Daily Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   
	
	indicator.parameters:addGroup("ADR Calculation"); 
    indicator.parameters:addInteger("N", "ADR Periods", "", 14);	
	indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.5);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local ADR=nil;
local Source, loading;
local N;
local TF;
local first;
 
local size;
local Multiplier;
function Prepare(nameOnly)  
    N=instance.parameters.N;	
	Multiplier=instance.parameters.Multiplier;
	TF=instance.parameters.TF;
    local name =  profile:id() .. ","  .. instance.source:name() ;
    instance:name(name);
    if nameOnly then
        return;
    end
	
    source = instance.source;
	first = source:first() + N;
   
	 
    ADR = instance:addStream("ADR", core.Line, name .. ".ADR", "ADR", instance.parameters.color, first);
    ADR:setWidth(instance.parameters.width);
    ADR:setStyle(instance.parameters.style);
 
end

 

function Update(period, mode)
    if period < first or  source:size() < N then
    	return;
    end	
	
	local adr = Calculate(period);
    ADR[period] = adr / source:pipSize() * Multiplier;
end

function Calculate(period)
	local Sum = 0;
 	for i = 0, N - 1, 1 do
 		Sum = Sum + (source.high[period - i] - source.low[period - i]) 
 	end  
 	return (Sum /N)
end