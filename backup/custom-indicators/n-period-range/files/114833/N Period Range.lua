
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65079

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
    indicator:name("N Period Range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    -- indicator parameters
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 34);
     indicator.parameters:addDouble("Value1", "1. Line", "", 100);
	  indicator.parameters:addDouble("Value2", "2. Line", "", 50);
 
     indicator.parameters:addGroup("Upper Band Style");
    indicator.parameters:addColor("H_color_1", "Color of 1. Upper Band Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("H_color_2", "Color of 2. Upper Band Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("H_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("H_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("H_style", core.FLAG_LINE_STYLE);

	 indicator.parameters:addGroup("Lower Band Style");
    indicator.parameters:addColor("L_color_1", "Color of 1. Lower Band Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("L_color_2", "Color of 2. Lower Band Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("L_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("L_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local H1 = nil;
local L1 = nil;
local H2 = nil;
local L2 = nil;
local Value1;
local Value2;
-- Routine
function Prepare(nameOnly)  
    Period = instance.parameters.Period;
	Value1 = instance.parameters.Value1;
	Value2 = instance.parameters.Value2;
    source = instance.source;
	
	first= source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. "." .. Period.. "." .. Value1.. "." .. Value2;  
    name = name .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
 
	
    H1 = instance:addStream("H1", core.Line, name .. ".1. H", "1. H", instance.parameters.H_color_1, first);
	H1:setWidth(instance.parameters.H_width);
    H1:setStyle(instance.parameters.H_style);
    
    L1 = instance:addStream("L1", core.Line, name .. ".1. L", "1. L", instance.parameters.L_color_1, first);
	L1:setWidth(instance.parameters.L_width);
    L1:setStyle(instance.parameters.L_style);
	
	
	
	H2 = instance:addStream("H2", core.Line, name .. ".2. H", "2. H", instance.parameters.H_color_2, first);
	H2:setWidth(instance.parameters.H_width);
    H2:setStyle(instance.parameters.H_style);
    
    L2 = instance:addStream("L2", core.Line, name .. ".2. L", "2. L", instance.parameters.L_color_2, first);
	L2:setWidth(instance.parameters.L_width);
    L2:setStyle(instance.parameters.L_style);
end

-- Indicator calculation routine
function Update(period, mode)

if period < Period then
return;
end


local Range= mathex.max(source.high, period-1-Period+1, period-1)-source.close[period-1];
 

H1[period]= source.open[period]+(Range/100)*Value1;
L1[period]= source.open[period]-(Range/100)*Value1;

H2[period]= source.open[period]+(Range/100)*Value2;
L2[period]= source.open[period]-(Range/100)*Value2;

end