-- Id: 20508
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65706

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
    indicator:name("MA Crossover shown in price Chart");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 10, 2, 2000);
 
 
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("2. MA Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 20, 2, 2000);
 
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1 , Period1;
local Method2 ,  Period2; 
local first;
local source = nil;
 
local Line;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)  

   
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
    
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2;
	
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ",  " ..Period1.. ",  " ..Method1  .. ",  " ..Period2.. ",  " ..Method2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   
   
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    Indicator[1] = core.indicators:create(Method1, source , Period1-1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    Indicator[2] = core.indicators:create(Method2, source , Period2-1);
    
    first=math.max(Indicator[1].DATA:first(), Indicator[2].DATA:first());
	
	 
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first);
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator[1]:update(mode);
    Indicator[2]:update(mode);
	
	
    if period < first then
	return;
	end
	
	
	 --Price = ( S * F * MA(S-1) - S * F * MA(F-1) ) / ( S - F )
		
     Line[period]=(Period1*Period2*Indicator[2].DATA[period] -Period1*Period2*Indicator[1].DATA[period] )/(Period2-Period1);
				  
end

