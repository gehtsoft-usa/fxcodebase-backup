-- Id: 13293
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61618

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RIBBON RAINBOW");
    indicator:description("RIBBON RAINBOW");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Min", "Min MA Period", "Min MA Period", 20);
    indicator.parameters:addInteger("Max", "Max MA Period", "Max MA Period", 50);
	indicator.parameters:addInteger("Step", "MA Step", "MA Step", 2); 
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Number;
local Period={};
local Method;
local first={};
local source = nil;
local ma={};
-- Streams block
local MA = {};
local Min, Max, Step;
local Count;
-- Routine
function Prepare(nameOnly) 
   
	Method = instance.parameters.Method;     
	Step = instance.parameters.Step;
	Min = instance.parameters.Min;
	Max = instance.parameters.Max;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

	if   (nameOnly) then
        return;
    end
	
	
	local i;
	Count=0;
	for i = Min, Max, Step do
	Count=Count+1;		 
	Period[Count]=i;
	end

	for i= 1, Count, 1 do
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma[i] = core.indicators:create(Method, source, Period[i]);	
    first[i] = ma[i].DATA:first();
	end
	
   
 
	
	    for i= 1, Count, 1 do
        MA[i] = instance:addStream("MA"..i, core.Line, name, Period[Count],  Coloring (( 100/Count)*i, 50), first[i]);
		MA[i]:setWidth(instance.parameters.width);
        MA[i]:setStyle(instance.parameters.style);
		end
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if not source:hasData(period) then
	return;
	end
	
	local i;
	for i= 1, Count, 1 do
	 ma[i]:update(mode); 
	 if period >= first[i]  then
	 MA[i][period] = ma[i].DATA[period];
	 end
	end
       
    
end


function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end

