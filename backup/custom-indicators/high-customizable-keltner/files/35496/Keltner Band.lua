-- Id: 6794
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=280

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
    indicator:name("Keltner Band");
    indicator:description("Keltner");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 35);
    indicator.parameters:addDouble("Percentage", "Percentage", "Percentage", 0.015);
	  indicator.parameters:addString("Type", "The center line smoothing method", "", "MVA");
    indicator.parameters:addStringAlternative("Type", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Type", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Type", "LWMA", "", "LWMA");
	indicator.parameters:addStringAlternative("Type", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Type", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Type", "Wilders", "", "WMA");
	indicator.parameters:addStringAlternative("Type", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("Type", "VIDYA", "", "VIDYA");
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("SC", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SC", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("WC", "Line Width", "", 1, 1, 5);
	
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("ST", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("ST", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("WT", "Line Width", "", 1, 1, 5);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("SB", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SB", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("WB", "Line Width", "", 1, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Percentage;
local Type;

local first;
local source = nil;

-- Streams block
local Central = nil;
local Top = nil;
local Bottom = nil;
local MA;

-- Routine
function Prepare(nameOnly)
     Type = instance.parameters.Type;
    Period = instance.parameters.Period;
    Percentage = instance.parameters.Percentage;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ", " .. tostring(Type) .. ", " .. tostring(Percentage) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    assert(core.indicators:findIndicator(Type) ~= nil, Type .. " indicator must be installed");
	 MA = core.indicators:create(Type, source, Period);
     first = MA.DATA:first();

    if (not (nameOnly)) then
        Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
		Central:setStyle(instance.parameters.SC);
        Central:setWidth(instance.parameters.WC);
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setStyle(instance.parameters.ST);
        Top:setWidth(instance.parameters.WT);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setStyle(instance.parameters.SB);
        Bottom:setWidth(instance.parameters.WB);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first  or not source:hasData(period) then
	return;
	end
	
	 MA:update(mode);
	
	
        Central[period] = MA.DATA[period];
		
        Top[period]  = MA.DATA[period]+  MA.DATA[period]*Percentage;
        Bottom[period] = MA.DATA[period]-  MA.DATA[period]*Percentage;
   
end

