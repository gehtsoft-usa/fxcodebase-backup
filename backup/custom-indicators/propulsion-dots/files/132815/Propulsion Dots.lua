-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69664

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Propulsion Dots");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	
	
	indicator.parameters:addDouble("Delta", "Delta (in pips)", "", 100, 1, 2000);

	
    indicator.parameters:addInteger("Period1", "1. MA Period", "", 7, 2, 2000);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	
    indicator.parameters:addInteger("Period2", "2. MA Period", "", 14, 2, 2000);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	
    indicator.parameters:addInteger("Period3", "Central Line MA Period", "", 50, 2, 2000);
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
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Delta;
local Method1, Method2, Method3;
local Period1,Period2,Period3; 
local first;
local source = nil;
local Trend; 
local MA1, MA2, MA3;
-- Routine
 function Prepare(nameOnly)   
 
    Delta= instance.parameters.Delta;
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Method1= instance.parameters.Method1;
	Method2= instance.parameters.Method2;
	Method3= instance.parameters.Method3;
	
	
	local Parameters=  Delta..", ".. Period1..", "..Method1..", "..Period2..", "..Method2..", "..Period3..", "..Method3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    

    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	Trend = instance:addInternalStream(0, 0);
	MA1 = core.indicators:create(Method1, source, Period1);
	MA2 = core.indicators:create(Method2, source, Period2);
	MA3 = core.indicators:create(Method3, source, Period3);
	
    first=math.max(MA1.DATA:first(), MA2.DATA:first(), MA3.DATA:first());
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	
	if period < first
	then
	return;
	end
	
	
	
	Trend[period]=Trend[period-1];
	Oscillator[period]=Oscillator[period-1];
	
	if MA1.DATA[period]> MA2.DATA[period] then
	Trend[period]=1;
	elseif MA1.DATA[period]< MA2.DATA[period] then
	Trend[period]=-1
	end
     
	 if Trend[period]==1 then
     Oscillator[period]= MA3.DATA[period]-Delta*source:pipSize();
	 elseif Trend[period]==-1 then
	 Oscillator[period]= MA3.DATA[period]+Delta*source:pipSize();
	 end
				  
end

 