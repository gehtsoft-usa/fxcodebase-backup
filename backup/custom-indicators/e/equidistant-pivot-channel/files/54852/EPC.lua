-- Id: 8516
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32176

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function Init()
    indicator:name("Equidistant Pivot Channel");
    indicator:description("Equidistant Pivot Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 

    indicator.parameters:addGroup("Pivot Calculation");
    indicator.parameters:addString("BS", "Time Frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);

    indicator.parameters:addString("CalcMode", "Pivot","", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR");
	
	 indicator.parameters:addGroup("Levels");
	 indicator.parameters:addDouble("First", "1. Line (in Pips)", "", 20);
	 indicator.parameters:addDouble("Second", "2. Line (in Pips)", "", 40);
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Pivot_color", "Color of Pivot", "Color of Pivot", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Color of 1. Pivot", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "1. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "1. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color2", "Color of 2. Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "2. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "2. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local BS, CalcMode;

local first;
local source = nil;
local Pivot;
local Top={};
local Bottom={};
-- Streams block
local PIVOT;
local First, Second;
-- Routine
function Prepare(nameOnly)
    BS = instance.parameters.BS;
	CalcMode = instance.parameters.CalcMode;
	First = instance.parameters.First;
	Second = instance.parameters.Second;
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(BS).. ", " .. tostring(CalcMode) .. ", " .. tostring(First).. ", " .. tostring(Second).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        PIVOT = core.indicators:create("PIVOT", source, BS,CalcMode, "HIST" );
        first = PIVOT.DATA:first();
        Pivot = instance:addStream("Pivot", core.Line, name, "Pivot", instance.parameters.Pivot_color, first);
		Pivot:setWidth(instance.parameters.width);
        Pivot:setStyle(instance.parameters.style);
		
		Top[1] = instance:addStream("Top1", core.Line, name, "1.Top", instance.parameters.color1, first);
		Top[1]:setWidth(instance.parameters.width1);
        Top[1]:setStyle(instance.parameters.style1);
		
		Top[2] = instance:addStream("Top2", core.Line, name, "2.Top", instance.parameters.color2, first);
		Top[2]:setWidth(instance.parameters.width2);
        Top[2]:setStyle(instance.parameters.style2);
		
		Bottom[1] = instance:addStream("Bottom1", core.Line, name, "1.Bottom", instance.parameters.color1, first);
		Bottom[1]:setWidth(instance.parameters.width1);
        Bottom[1]:setStyle(instance.parameters.style1);
		
		
		Bottom[2] = instance:addStream("Bottom2", core.Line, name, "2.Bottom", instance.parameters.color2, first);
		Bottom[2]:setWidth(instance.parameters.width2);
        Bottom[2]:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    core.host:execute ("removeAll")
    PIVOT:update(mode);
   
    if period< source:size()-1   then
	return;
	end
	
    local i;
	for i= first, source:size()-1 do
	   if PIVOT.DATA:hasData(i) then
	   Pivot[i] = PIVOT.DATA[i];
	   Top[1][i] = PIVOT.DATA[i]+First*source:pipSize();
	   Top[2][i] = PIVOT.DATA[i]+Second*source:pipSize();
	   Bottom[1][i] = PIVOT.DATA[i]-First*source:pipSize();
	   Bottom[2][i] = PIVOT.DATA[i]-Second*source:pipSize();
	   end
   end
    
end
