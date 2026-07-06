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
    indicator:name("NONLINEAR EHLERS FILTER");
    indicator:description("NONLINEAR EHLERS FILTER");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length", "Length", 15);
	indicator.parameters:addInteger("Period", "Momentum Period", "Period", 5);
	
	indicator.parameters:addString("Method", "Method", "Method" , "Momentum");
    indicator.parameters:addStringAlternative("Method", "Momentum", "Momentum" , "Momentum");
    indicator.parameters:addStringAlternative("Method", "Distance Coefficient", "Distance Coefficient" , "Distance Coefficient");
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("NEF_color", "Color of NEF", "Color of NEF", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;

local first;
local source = nil;
local Period;
local Method;
-- Streams block
local NEF = nil;
local Coef, RawCoef;
-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
	Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    source = instance.source;
	RawCoef = instance:addInternalStream(0, 0);
	Coef = instance:addInternalStream(0, 0);
    first = source:first()+Period;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Length).. ", " .. tostring(Period).. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        NEF = instance:addStream("NEF", core.Line, name, "NEF", instance.parameters.NEF_color, first+Length);
		NEF:setWidth(instance.parameters.width);
        NEF:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	
	if Method == "Momentum" then
	RawCoef[period] = math.abs(source[period] - source[period - Period]);
	else
	RawCoef[period] = (source[period] - source[period - Period])^2;
	end
    Coef[period] =RawCoef[period] * source[period];
	
	
    if period < first +Length  then
	return;
	end
	
	local Num =mathex.sum(Coef, period-Length+1, period);
	local SumCoef=mathex.sum(RawCoef, period-Length+1, period);



        NEF[period] = Num / SumCoef;
    
end

