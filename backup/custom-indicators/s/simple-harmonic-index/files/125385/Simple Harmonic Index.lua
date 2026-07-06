-- Id: 24330
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68184

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
    indicator:name("Simple Harmonic Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
 
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period;
local first;
local source = nil;
local Att,Data; 
local Oscillator;  
local MA1, MA2;

-- Routine
 function Prepare(nameOnly)  
 
 
    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
	
	
	local Parameters= Period ..  ", " .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    Att = instance:addInternalStream(0, 0);
	Att:setPrecision(math.max(2, source:getPrecision()));
	
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA1 = core.indicators:create(Method, Att, Period);
    
    first=source:first()+2 +Period ;
	
	Data = instance:addInternalStream(0, 0);
	Data:setPrecision(math.max(2, source:getPrecision()));
	
	MA2 = core.indicators:create(Method, Data, Period); 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first+Period);
 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   if period < source:first()+2 then
   return;
   end
   

   local Cy         = source[period-1];
   local Vt         = source[period]- Cy; 
   
   local Vy         = source[period-1]- source[period-2]
   Att[period]      = (Vt - Vy) 
   
   
   
   
  
 
   
	
	if period < first then
   return;
   end
	
   MA1:update(mode);
	
	
	
	
	local Tt=0;
	if MA1.DATA[period]~= 0 then
	Tt= math.sqrt(math.abs(Vt/MA1.DATA[period]));
	end
	
	
	
	if source[period] > Cy then
	Data[period]=Tt;
	else
	Data[period]=-1*Tt; 
	end
	
	 
	
	 
	if period < first+Period then
   return;
   end
   
   
     MA2:update(mode);
	 Oscillator[period]=MA2.DATA[period]
	 
	 --Oscillator[period]=mathex.avg(Data, period-Period+1, period);
	 
	
    if Oscillator[period]> 0 then
    Oscillator:setColor(period, instance.parameters.Up);	
	else
	Oscillator:setColor(period, instance.parameters.Down);	
	end
	 
	 	  
end

