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
    indicator:name("Volume Weighted Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period2", "Volume MA Period", "Period", 50);
    indicator.parameters:addInteger("Period1", "Price MA Period", "Period", 70);	
	indicator.parameters:addBoolean("Show", "Show Price MA", "", true);

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "VWMA Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Price Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1,Period2;

local first;
local source = nil;

-- Streams block
local VWMA = nil;
local Show;
local PVSum,PV;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Show= instance.parameters.Show;
    source = instance.source;
    first = source:first();
	
	 
	PV = instance:addInternalStream(0,  0);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        VWMA = instance:addStream("VWMA", core.Line, name, "VWMA", instance.parameters.color1, first+ Period2);
		VWMA:setWidth(instance.parameters.width1);
        VWMA:setStyle(instance.parameters.style1);
		
		if Show then
		PMA = instance:addStream("PMA", core.Line, name, "PMA", instance.parameters.color2, first+ Period1);
		PMA:setWidth(instance.parameters.width2);
        PMA:setStyle(instance.parameters.style2);
		else
		PMA= instance:addInternalStream(0,  0)
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
     
	PV[period]=source.close[period]*source.volume[period];

    if period > first + Period2 then
	
	VSum = mathex.sum( source.volume, period-Period2+1, period ) ;
	PVSum = mathex.sum( PV, period-Period2+1, period ) ;
	 
	if VSum ~= 0 then
	VWMA[period]= PVSum / VSum ;
    end
	end

	if period > first + Period1 then
	PMA[period]=mathex.avg(source.close,period-Period1+1, period);
	end
end

