-- Id: 22321
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66666

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

function Init()
    indicator:name("12to1 Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
 
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 12, 0, 2000); 
    indicator.parameters:addInteger("Period2", "Period", "", 1, 0, 2000);
  
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local   Period1;
local Period2; 
local first;
local source = nil;
local Up, Down; 
local Oscillator;  
 

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    Period1= instance.parameters.Period1;   
	Period2= instance.parameters.Period2; 
			
    source = instance.source; 
    first=source:first()+math.max(Period1,Period2);
	 
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",Up, first); 
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
	
    if period < first then
	return;
	end
	
		
     Oscillator[period]=(source.close[period] - source.open[period-Period1 + 1]) - (source.close[period] - source.open[period-Period2 + 1]);
	 
	 if Oscillator[period]>0 then
	 Oscillator:setColor(period, Up);
	 else
	 Oscillator:setColor(period, Down);
	 end 
				  
end

