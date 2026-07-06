-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65724

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

function Init()
    indicator:name("Median Price");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Median Period", "", 14, 2, 2000);
	
	indicator.parameters:addString("Method", "Method", "Method" , "S");
    indicator.parameters:addStringAlternative("Method", "Sort function", "Calculates the median value using sort function." , "S");
    indicator.parameters:addStringAlternative("Method", "Wirth's Kth-minimum function", "Calculates the median value using Wirth's Kth-minimum function." , "W");
 
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1 ; 
local Method;
local first;
local source = nil;
 
local alpha; 
local MP;

-- Routine
 function Prepare(nameOnly)   
 
     Period1= instance.parameters.Period1;
	 Method= instance.parameters.Method;
	  
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period1  .. ", " ..  Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  
 
    source = instance.source;
	first=source:first()+Period1;
 
	MP = instance:addStream("MP" , core.Line, "MP","MP",instance.parameters.color, first);
	MP:setWidth(instance.parameters.width);
    MP:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    if period < first then
	return;
	end
 
     if Method== "S" then
	 MP[period] = mathex.median_s(source, period - Period1 + 1, period);
	 else
	 MP[period] = mathex.median_w(source, period - Period1 + 1, period);
	 end
	 
end


