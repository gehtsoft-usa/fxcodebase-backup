-- Id: 13432
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=61720


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volatility Arbitrage");
    indicator:description("Volatility Arbitrage");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("ROCPeriod", "ROC Period", "ROC Period", 1);
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 2);
	
	 indicator.parameters:addColor("Color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Central_color", "Color of ROC", "Color of ROC", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ROCPeriod;
local Period;
local Multiplier;

local first;
local source = nil;

-- Streams block
local Top = nil;
local Bottom = nil;
local Central = nil;

-- Routine
function Prepare(nameOnly)
    ROCPeriod = instance.parameters.ROCPeriod;
    Period = instance.parameters.Period;
    Multiplier = instance.parameters.Multiplier;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(ROCPeriod) .. ", " .. tostring(Period) .. ", " .. tostring(Multiplier) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    
	    Central = instance:addStream("ROC", core.Line, name .. ".ROC", "ROC", instance.parameters.Central_color, source:first()+1);
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
		Central:setWidth(instance.parameters.width1);
        Central:setStyle(instance.parameters.style1);
		Central:addLevel (0, instance.parameters.style4, instance.parameters.width4, instance.parameters.Color)
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, source:first()+1+Period);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setWidth(instance.parameters.width2);
        Top:setStyle(instance.parameters.style2);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, source:first()+1+Period);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);      
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    Central[period] = (source[period] / source[period - ROCPeriod] - 1) * 100; 	
	 
    if period < first+Period or not source:hasData(period) then
	return;
	end 
	
   
	Top[period] =  mathex.stdev (Central,period-Period+1, period)*Multiplier;
    Bottom[period] = -1*Top[period];
end

  