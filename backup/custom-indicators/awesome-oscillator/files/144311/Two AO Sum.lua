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
    indicator:name("Two AO Sum");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. AO Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 5, 1, 2000);
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
	
    indicator.parameters:addInteger("Period2", "2. Period", "", 25, 2, 2000);
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
	
	
    indicator.parameters:addGroup("2. AO Calculation"); 
    indicator.parameters:addInteger("Period3", "1. Period", "", 50, 1, 2000);
    indicator.parameters:addInteger("Shift3", "1. MA Shift Period", "", 0, 0, 2000);	
	
	indicator.parameters:addString("Method3", "2. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Period4", "2. Period", "", 250, 2, 2000);
    indicator.parameters:addInteger("Shift4", "2. MA Shift Period", "", 0, 0, 2000);	
	 
 	indicator.parameters:addString("Method4", "2. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");	
	
	indicator.parameters:addGroup("Bar Style"); 	
    indicator.parameters:addColor("UpUp", "Up Bar in Up Trend Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("UpDown", "Down Bar in Up Trend Color", "", core.rgb(0, 200, 0));  
    indicator.parameters:addColor("DownUp", "Up Bar in Down Trend Color", "", core.rgb(255, 0, 0)); 
    indicator.parameters:addColor("DownDown", "Down Bar in Down Trend Color", "", core.rgb(200, 0, 0));  


	indicator.parameters:addGroup("Zero Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Shift2, Shift1;
local Shift3, Shift4;
local Method2, Method1;
local Period1,Period2; 
local Method3, Method4;
local Period3,Period4; 

local first;
local source = nil;
 
local Oscillator;  
local MA1, MA2;
local MA3, MA4;
-- Routine
 function Prepare(nameOnly)   
 
    Shift2= instance.parameters.Shift2;
	Shift1= instance.parameters.Shift1;
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
    Method1= instance.parameters.Method1;
    Method2= instance.parameters.Method2;
	
    Shift3= instance.parameters.Shift3;
	Shift4= instance.parameters.Shift4;
    Period3= instance.parameters.Period3;
    Period4= instance.parameters.Period4;
    Method3= instance.parameters.Method3;
    Method4= instance.parameters.Method4;	
	
	local Parameters= ""
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	MA1 = core.indicators:create(Method1, source, Period1);
	MA2 = core.indicators:create(Method2, source, Period2);	
	MA3 = core.indicators:create(Method3, source, Period3);
	MA4 = core.indicators:create(Method4, source, Period4);		
    first=math.max(MA1.DATA:first(),MA2.DATA:first(), MA3.DATA:first(),MA4.DATA:first())+math.max(Shift1, Shift2, Shift3, Shift4);
 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.UpUp, first ); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
	
	Zero = instance:addStream("Zero" , core.Line, " Zero"," Zero",instance.parameters.color, first );
	Zero:setWidth(instance.parameters.width);
    Zero:setStyle(instance.parameters.style);
    Zero:setPrecision(math.max(2, source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)

	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	MA4:update(mode);
	
	if period < first
	then
	return;
	end
 
	Zero[period]= (MA3.DATA[period-Shift3]-MA4.DATA[period-Shift4])
    Oscillator[period]= Zero[period]+(MA1.DATA[period-Shift1]-MA2.DATA[period-Shift2]) ;
	
	
	if (MA3.DATA[period-Shift3]-MA4.DATA[period-Shift4])  > 0 then
	
		if Oscillator[period] > Oscillator[period-1] then	
		Oscillator:setColor(period, instance.parameters.UpUp);
		else
		Oscillator:setColor(period, instance.parameters.UpDown);
		end
	else
	
	   	if Oscillator[period] > Oscillator[period-1] then	
		Oscillator:setColor(period, instance.parameters.DownUp);
		else
		Oscillator:setColor(period, instance.parameters.DownDown);
		end

    end
	
	
end


 