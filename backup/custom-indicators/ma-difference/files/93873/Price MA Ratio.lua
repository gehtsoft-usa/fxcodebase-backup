-- Id: 11687
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=41822

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Price MA Ratio");
    indicator:description("Ratio between MA2/PRICE and MA1/MA2 ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

   
	
	
    indicator.parameters:addGroup("First MA Calculation");	
    indicator.parameters:addInteger("Period1", "First MA Period", "", 14);
 
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
    indicator.parameters:addInteger("Period2", "Second MA Period", "", 14);	
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
 
	 indicator.parameters:addColor("color", "Line Color","", core.rgb(255, 0, 0));	
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
local Period1,Period2; 
local Method1, Method2;
local One,Two;
local Ratio;
-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Period1 = instance.parameters.Period1;	 
	Period2 = instance.parameters.Period2;
    source = instance.source;    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method1).. ", " .. tostring(Period1).. ", " .. tostring(Method2).. ", " .. tostring(Period2) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	One= core.indicators:create( Method1, source, Period1);
    Two = core.indicators:create( Method2, source, Period2);
	 
	first = math.max(One.DATA:first(), Two.DATA:first());

    
	Ratio = instance:addStream("Ratio", core.Bar, name .. ". Ratio ", " Ratio ", instance.parameters.color, first);
    Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    One:update(mode);
	Two:update(mode);
	
    if period < first   then
	return;
	end
	
 	local DIFF1 =  (source[period] - Two.DATA[period]);
    local DIFF2 = (One.DATA[period]-Two.DATA[period]);
 


    Ratio[period] = DIFF1-DIFF2;
     
end

