-- Id: 13956
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62092


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
    indicator:name("MA Zone");
    indicator:description("MA Zone");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Level");
	indicator.parameters:addDouble("Level1", "1. Level", "Level", 10);
	indicator.parameters:addDouble("Level2", "2. Level", "Level", 50);
	indicator.parameters:addDouble("Level3", "3. Level", "Level", 100);
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addString("Method", "Method", "Method", "MVA");
	 indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA")
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;

local first;
local source = nil;
local Level={};
-- Streams block
local Central = {};
local Top =  {};
local Bottom = {};
local MA;
-- Routine
function Prepare(nameOnly)  
    Period = instance.parameters.Period;
    Method = instance.parameters.Method;
	Level[1]= instance.parameters.Level1;
	Level[2]= instance.parameters.Level2;
	Level[3]= instance.parameters.Level3;
    source = instance.source;
	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source, Period);
    first = MA.DATA:first();

    local name = profile:id() .. "(" .. source:name().. ", " .. tostring(Level[1]).. ", " .. tostring(Level[2]).. ", " .. tostring(Level[3]).. ", " .. tostring(Period) .. ", " .. tostring(Method) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

     
        Central = instance:addStream("Central1", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
		Central:setWidth(instance.parameters.width1);
        Central:setStyle(instance.parameters.style1);
        Top[1] = instance:addStream("Top1", core.Line, name .. "1. Top", "1. Top", instance.parameters.Top_color, first);
		Top[1]:setWidth(instance.parameters.width2);
        Top[1]:setStyle(instance.parameters.style2);
        Bottom[1] = instance:addStream("Bottom", core.Line, name .. "1. 1. Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom[1]:setWidth(instance.parameters.width3);
        Bottom[1]:setStyle(instance.parameters.style3);
		
		Top[2] = instance:addStream("Top2", core.Line, name .. "2. Top", "2. Top", instance.parameters.Top_color, first);
		Top[2]:setWidth(instance.parameters.width2);
        Top[2]:setStyle(instance.parameters.style2);
        Bottom[2] = instance:addStream("Bottom2", core.Line, name .. "2. Bottom", "2. Bottom", instance.parameters.Bottom_color, first);
		Bottom[2]:setWidth(instance.parameters.width3);
        Bottom[2]:setStyle(instance.parameters.style3);
		
		
		Top[3] = instance:addStream("Top3", core.Line, name .. "3. Top", "3. Top", instance.parameters.Top_color, first);
		Top[3]:setWidth(instance.parameters.width2);
        Top[3]:setStyle(instance.parameters.style2);
        Bottom[3] = instance:addStream("Bottom3", core.Line, name .. "3. Bottom", "3. Bottom", instance.parameters.Bottom_color, first);
		Bottom[3]:setWidth(instance.parameters.width3);
        Bottom[3]:setStyle(instance.parameters.style3);
		
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    MA:update(mode); 
    if period < first or not source:hasData(period) then
	return;
	end
        Central[period] = MA.DATA[period]+Level[1]*source:pipSize();
        Top[1][period] =  MA.DATA[period]+Level[1]*source:pipSize();
        Bottom[1][period] =  MA.DATA[period]-Level[1]*source:pipSize();
		Top[2][period] =  MA.DATA[period]+Level[2]*source:pipSize();
        Bottom[2][period] =  MA.DATA[period]-Level[2]*source:pipSize();
		Top[3][period] =  MA.DATA[period]+Level[3]*source:pipSize();
        Bottom[3][period] =  MA.DATA[period]-Level[3]*source:pipSize();
     
end

