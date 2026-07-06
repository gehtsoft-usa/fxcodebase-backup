-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71658

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
--|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
--|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
--|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine

function Init()
    indicator:name("FX-AO");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 2, 1, 2000);
    indicator.parameters:addInteger("Shift1", "1. MA Shift Period", "", 0, 0, 2000);	
	
	indicator.parameters:addString("Method1", "1. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Period2", "2. Period", "", 13, 2, 2000);
    indicator.parameters:addInteger("Shift2", "2. MA Shift Period", "", 0, 0, 2000);	
	 
 	indicator.parameters:addString("Method2", "2. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0, 0));  
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Shift2, Shift1;
local Method2, Method1;
local Period1,Period2; 
local first;
local source = nil;
 
local Oscillator;  
local MA1, MA2;
-- Routine
 function Prepare(nameOnly)   
 
    Shift2= instance.parameters.Shift2;
	Shift1= instance.parameters.Shift1;
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
    Method1= instance.parameters.Method1;
    Method2= instance.parameters.Method2;
	
	
	local Parameters= Period1..", "..Method1..", "..Shift1..", "..Period2..", "..Method2 ..", "..Shift2
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	MA1 = core.indicators:create(Method1, source, Period1);
	MA2 = core.indicators:create(Method2, source, Period2);	
    first=math.max(MA1.DATA:first(),MA2.DATA:first())+math.max(Shift1, Shift2);
 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first ); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

	MA1:update(mode);
	MA2:update(mode);

	if period < first
	then
	return;
	end
 
		
    Oscillator[period]= MA1.DATA[period-Shift1]-MA2.DATA[period-Shift2];
	
    if Oscillator[period] > Oscillator[period-1] then	
	Oscillator:setColor(period, instance.parameters.Up);
	else
	Oscillator:setColor(period, instance.parameters.Down);
	end
	
end


 