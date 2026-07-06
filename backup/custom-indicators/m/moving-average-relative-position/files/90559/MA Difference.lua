-- Id: 10358
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
    indicator:name("MA Difference");
    indicator:description("MA Difference");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Selector");	
 
	
	
    indicator.parameters:addGroup("First MA Calculation");	
    indicator.parameters:addInteger("P1", "First MA Period", "", 14);
 
	indicator.parameters:addString("Method1", "First MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("Second MA Calculation");	
    indicator.parameters:addInteger("P2", "Second MA Period", "", 14);	
	indicator.parameters:addString("Method2", "Second MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
   
    indicator.parameters:addGroup("Style");
	
	indicator.parameters:addString("Type1", "Bar/Line", "Method" , "Line");
    indicator.parameters:addStringAlternative("Type1", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Type1", "Bar", "Bar" , "Bar");
	
    indicator.parameters:addColor("PM1_color", "Color of MA / Price Difference", "Color of MA / Price Difference", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local P1, P2;
-- Streams block
 
local One,Two;
local Out;
local Type1;
local Method1, Method2;
-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1;
	 Method2 = instance.parameters.Method2;
	 P1 = instance.parameters.P1;
	 P2 = instance.parameters.P2;
 
	 Type1 = instance.parameters.Type1;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method1).. ", " .. tostring(P1).. ", " .. tostring(Method2).. ", " .. tostring(P2) .. ")";
    instance:name(name);
	
	One= core.indicators:create( Method1, source, P1);
    Two = core.indicators:create( Method2, source, P2);

	 
	first = math.max(One.DATA:first(), Two.DATA:first());

    if (not (nameOnly)) then
	 
			if Type1 == "Bar" then
			Out = instance:addStream("Difference", core.Bar, name .. ". Price / MA Difference ", " ", instance.parameters.PM1_color, first);
    		else		
			Out = instance:addStream("Difference", core.Line, name .. ". Price / MA Difference ", " ", instance.parameters.PM1_color, first);
			Out:setWidth(instance.parameters.width);
			Out:setStyle(instance.parameters.style);
			end
            Out:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    One:update(mode);
	Two:update(mode);
	
    if period < first   then
	return;
	end
 
        Out[period] = (Two.DATA[period]-One.DATA[period])  / source:pipSize();
     
end

