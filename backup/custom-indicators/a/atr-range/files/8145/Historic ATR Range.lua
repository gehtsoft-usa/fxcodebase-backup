
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3415

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
    indicator:name("Historic ATR Range ");
    indicator:description("Historic ATR Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addInteger("Multiple", "Multiple", "Multiple", 2);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Multiple;
local ATR;
local first;
local source = nil;

-- Streams block
local Top = nil;
local Bottom = nil;

-- Routine
function Prepare(nameOnly)  
    Period = instance.parameters.Period;
    Multiple = instance.parameters.Multiple;
    source = instance.source;
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Multiple) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
		ATR= core.indicators:create("ATR", source, Period);
    first = ATR.DATA:first();

    
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.width2);
        Bottom:setStyle(instance.parameters.style2);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    ATR:update(mode);
	
	if period < first then
	return;
	end
	
        Top[period] = source.open[period]+Multiple*ATR.DATA[period];
        Bottom[period] = source.open[period]-Multiple*ATR.DATA[period];
    
end

