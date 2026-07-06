-- Id: 17094
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
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
    indicator:name("Disparity Index");
    indicator:description("Disparity Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 13);
	indicator.parameters:addInteger("Variable", "Variable", "Variable", 1,1,100000);
	indicator.parameters:addInteger("N", "N", "N", 13 );
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DI_color", "Color of DI", "Color of DI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local MA;
local first;
local source = nil;
local Variable;
local Raw;
local N;
-- Streams block
local DI = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Variable= instance.parameters.Variable;
	N= instance.parameters.N;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Variable).. ", " .. tostring(N).. ")";
    instance:name(name);
	
	MA = core.indicators:create("EMA", source  , Period);
	first = MA.DATA:first();
	
	Raw = instance:addInternalStream(first, 0);

    if (not (nameOnly)) then
        DI = instance:addStream("DI", core.Line, name, "DI", instance.parameters.DI_color, first+N);
		DI:setWidth(instance.parameters.width);
        DI:setStyle(instance.parameters.style);
		DI:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
	MA:update(mode)
	
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
    Raw[period] = ((source[period] - MA.DATA[period]) / MA.DATA[period] *100)*100;
	
	if period < first + N then
	return;
	end
	
	--X * natural logarithm (Disparity Index1/Disparity IndexN) 
	
	DI[period]= Variable * math.log(Raw[period]-Raw[period-N]);
    
end

