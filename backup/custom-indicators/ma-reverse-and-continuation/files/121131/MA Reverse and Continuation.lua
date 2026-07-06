-- Id: 22283
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66645 

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
    indicator:name("MA Reverse and Continuation");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation"); 
	
	 indicator.parameters:addInteger("Period", "Reverse Period", "", 3, 1, 2000);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 7, 1, 2000);
 
	 
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
    indicator.parameters:addInteger("Period2", "Period", "", 20, 1, 2000);
 
 
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("3. MA Calculation"); 
    indicator.parameters:addInteger("Period3", "Period", "", 50, 1, 2000);
 
 
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Signal Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Signal Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Signal Color", "", core.rgb(128, 128, 128));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period;
local Method1 , Period1;
local Method2 , Period2; 
local Method3 , Period3; 
local first;
local source = nil;
 
local Oscillator;  
local MA1, MA2,MA3;
local Up,Down, Neutral;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	Period= instance.parameters.Period;
	
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1; 
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2; 
	
	Period3= instance.parameters.Period3;
    Method3= instance.parameters.Method3; 
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source , Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(Method2, source , Period2);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA3 = core.indicators:create(Method3, source , Period3);
    
    first=math.max(MA1.DATA:first(), MA2.DATA:first(), MA3.DATA:first());
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",Neutral, first); 
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA1:update(mode);
    MA2:update(mode);
	MA3:update(mode);
	
	
    if period < first then
	return;
	end
	
	
	 if source[period]> MA3.DATA[period] 
	 and  MA1.DATA[period]  > MA2.DATA[period]
	 and source[period]> MA1.DATA[period] 
	 and ((period-Reverse(period))<= Period)
	 then	 
	 Oscillator[period]=1;
	 Oscillator:setColor(period, Up);
	 elseif  source[period]< MA3.DATA[period]
	 and  MA1.DATA[period]  < MA2.DATA[period]
	 and source[period]< MA1.DATA[period]
     and ((period-Reverse(period))<= Period)	 
	 then
	 Oscillator[period]=-1;
	 Oscillator:setColor(period, Down);
	 else	
     Oscillator[period]=0;
	  Oscillator:setColor(period, Neutral);
	 end			  
end


function Reverse(period)

local First=0;
local Second=0;

	for i= period, first, -1 do 

		if source[period]> MA1.DATA[period]  
		and source[i]< MA1.DATA[i]
		then
		First=i;
		break;
		end


		if source[period]< MA1.DATA[period]  
		and source[i]> MA1.DATA[i]
		then
		First=i;
		break;
		end

	  
	end
	
	
	if First ==0 then
	return Second;
	end
	
	
	for i= First, first, -1 do 

		if source[First]> MA1.DATA[First]  
		and source[i]< MA1.DATA[i]
		then
		Second=i;
		break;
		end


		if source[First]< MA1.DATA[First]  
		and source[i]> MA1.DATA[i]
		then
		Second=i;
		break;
		end

	  
	end


 


 return Second;

end
