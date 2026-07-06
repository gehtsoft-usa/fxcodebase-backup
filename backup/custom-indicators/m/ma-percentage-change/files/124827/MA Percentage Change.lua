-- Id: 24243
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67758

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("MA Percentage Change");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 10, 1, 2000);
 
 
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Slope Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 1, 1, 2000);
  
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1, Period1;
local  Period2; 
local first;
local source = nil;
 
local Oscillator;  
local MA;

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
	
	Period2= instance.parameters.Period2;
   
	
	
	local Parameters= Period1 ..  ", " .. Method1 ..  ", " ..Period2 ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA = core.indicators:create(Method1, source , Period1);
    
    first=MA.DATA:first()+Period1;
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first+Period2);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA:update(mode);
	
	
    if period < first +Period2 then
	return;
	end
	
		
    Oscillator[period]=((( MA.DATA[period]-MA.DATA[period-Period2])   /  (MA.DATA[period]/100)));
    
	 
	 if Oscillator[period]> 0 then
	 Oscillator:setColor(period, instance.parameters.Up);
	 else
	 Oscillator:setColor(period, instance.parameters.Down);
	 end
				  
end

