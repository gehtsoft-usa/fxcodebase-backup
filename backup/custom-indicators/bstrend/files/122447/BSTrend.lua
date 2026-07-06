-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67034

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
    indicator:name("BSTrend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 12, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255,0,0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period;
local first;
local source = nil;
local ld56, ld80;
local Oscillator;  
local Up,Down,Neutral;

-- Routine
 function Prepare(nameOnly)   
 
    Period= instance.parameters.Period;	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
    
			
    source = instance.source;  
	first=source:first()+Period;
	
	ld56 = instance:addInternalStream(0, 0);
	ld80  = instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",Neutral, first); 
	Oscillator:setPrecision(2);
	Oscillator:addLevel(1);
	Oscillator:addLevel(0);
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
	
    if period < first then
	return;
	end
	
	local min,max=mathex.minmax(source,period-Period+1, period); 
	 
	local ld48 = 0.66 * ((source.median[period] - min) / (max - min) - 0.5) + 0.67 * ld56[period-1];
    local ld48 = math.min(math.max(ld48, -0.999), 0.999);
	local gda80 = math.log((ld48 + 1.0) / (1 - ld48)) / 2.0 + ld80[period-1] / 2.0;
	ld56[period] = ld48;
	ld80[period] = gda80; 
	
	local  ld8 = ld80[period];
    local ld0 = ld80[period-1];
	
	Oscillator[period]=1;
	
	 if ((ld8 < 0.0 and ld0 > 0.0) or ld8 < 0.0) then
	 Oscillator:setColor(period,Down);
	 elseif ((ld8 > 0.0 and ld0 < 0.0) or ld8 > 0.0) then  
	 Oscillator:setColor(period, Up);
	 else
	 Oscillator:setColor(period,Neutral);
	 end
				  
end
 

