-- Id: 10449
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Adaptive CyberCycle indicator");
    indicator:description("Adaptive CyberCycle indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addDouble("Alpha", "Alpha", "Alpha", 0.07);
	 indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("Cycle_color", "Color of Cycle", "Color of Cycle", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Trigger_color", "Color of Trigger", "Color of Trigger", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Alpha;

local first;
local source = nil;
 
-- Streams block
local Trigger;
local Smooth,Cycle;
local Period;
-- Routine
function Prepare(nameOnly)
    Alpha = instance.parameters.Alpha;
    source = instance.source;
    first = source:first()+3;
	
	Smooth = instance:addInternalStream(0, 0);
 
	
	assert(core.indicators:findIndicator("EHLERS CYBERCYCLE") ~= nil, "Please, download and install EHLERS CYBERCYCLE.LUA indicator");    
	
	Period = core.indicators:create("EHLERS CYBERCYCLE", source, Alpha);	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Alpha) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Cycle = instance:addStream("Cycle", core.Line, name, "Cycle", instance.parameters.Cycle_color, Period.DATA:first());
    Cycle:setPrecision(math.max(2, instance.source:getPrecision()));
		Cycle:setWidth(instance.parameters.width1);
        Cycle:setStyle(instance.parameters.style1);
		Trigger = instance:addStream("Trigger", core.Line, name, "Trigger", instance.parameters.Trigger_color, Period.DATA:first() +2);
    Trigger:setPrecision(math.max(2, instance.source:getPrecision()));
		Trigger:setWidth(instance.parameters.width2);
        Trigger:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first   then
	return;
	end
	
	
	 Smooth[period] = ( source[period] + 2 * source[period-1] +   2 * source[period-2] + source[period-3] ) / 6;
	 
	 Period:update(mode);
	 
	 
	 if period < Period.DATA:first() then
	 return;
	 end
	 
	  
	 local Beta= 2.0/( Period.DATA[period]+1.0);
	 
     Cycle[period] =   ( 1 - 0.5 * Beta ) * ( 1 - 0.5 * Beta ) * ( Smooth[period] - 2 * Smooth[period-1] + Smooth[period-2] ) + 2 * ( 1 - Beta ) * Cycle[period-1] - ( 1 - Beta ) * ( 1 - Beta ) * Cycle[period-2] ;
     Trigger[period]=Cycle[period-1];
    
end
  
 
