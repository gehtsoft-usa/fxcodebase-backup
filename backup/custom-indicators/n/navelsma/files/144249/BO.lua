-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71641

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
    indicator:name("BO");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 34, 1, 2000);
	
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
    indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0, 0)); 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Method; 
local first;
local source = nil;
 
local Oscillator;  
local L1, L2, H1, H2,NavelSMA;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
    Method= instance.parameters.Method;
	
	
	local Parameters= Period1..", "..Period2..", "..Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
 	
    source = instance.source; 
    first=source:first()+math.max(Period1, Period2);
	
    assert(core.indicators:findIndicator("NAVEL SMA") ~= nil, "Please, download and install NAVEL SMA.LUA indicator");	
	
	H1 = core.indicators:create(Method, source.high, Period1);
	H2 = core.indicators:create(Method, source.high, Period2);	
 
	L1 = core.indicators:create(Method, source.low, Period1);
	L2 = core.indicators:create(Method, source.low, Period2);   
	
	NavelSMA = core.indicators:create("NAVEL SMA", source , Period1);   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first ); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

	L1:update(mode);
	L2:update(mode);
	H1:update(mode);
	H2:update(mode);
    NavelSMA:update(mode);	
 
	if period < first
	then
	return;
	end
 
     Oscillator[period]= (NavelSMA.DATA[period]-L2.DATA[period])/(H2.DATA[period]-L2.DATA[period])-(NavelSMA.DATA[period]-L1.DATA[period])/(H1.DATA[period]-L1.DATA[period]);
	

    if Oscillator[period] > Oscillator[period-1] then
	Oscillator:setColor(period, instance.parameters.Up);
    else
	Oscillator:setColor(period, instance.parameters.Down);
    end	
end
 