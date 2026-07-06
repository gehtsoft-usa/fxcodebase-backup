-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70021

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine

function Init()
    indicator:name("moving-average-strength");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Back_Bars", "Back_Bars", "",100, 1, 2000);
	
	indicator.parameters:addString("Type", "Type", "Type" , "MVA");
    indicator.parameters:addStringAlternative("Type", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Type", "MACD", "MACD" , "MACD");
    indicator.parameters:addStringAlternative("Type", "Stochastic", "Stochastic" , "Stochastic");
	
	indicator.parameters:addGroup("MA Calculation"); 
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("Fast_MA_Period", "Fast MA  Period", "", 13, 1, 2000);
    indicator.parameters:addInteger("Slow_MA_Period", "Slow MA Period", "", 21, 1, 2000);

	indicator.parameters:addGroup("MACD Calculation"); 
	
	indicator.parameters:addInteger("MACD_Fast_MA_Period", "Fast MA  Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("MACD_Slow_MA_Period", "Slow MA Period", "", 26, 1, 2000);
 	indicator.parameters:addInteger("Signal_Signal_MA_Period", "Signal MA Period", "", 9, 1, 2000);
	
	indicator.parameters:addGroup("Stochastic Calculation"); 
	indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS", "MT4","", "FS");
    
    indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA"); 	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Slow_MA_Period,  Fast_MA_Period, Method;
local Back_Bars;
local Slow_MA, Fast_MA; 
local first;
local source = nil;
local Type; 
local Oscillator;  
local Indicator={};
local Average;
local Positive, Negative
local MACD;
local Stochastic;
-- Routine
 function Prepare(nameOnly)  


    Type= instance.parameters.Type; 
 
    Method= instance.parameters.Method;
    Fast_MA_Period= instance.parameters.Fast_MA_Period;
	Slow_MA_Period= instance.parameters.Slow_MA_Period;
	Back_Bars= instance.parameters.Back_Bars;
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	if Type == "MVA" then
	Slow_MA = core.indicators:create(Method, source.close, Slow_MA_Period);
	Fast_MA = core.indicators:create(Method, source.close, Fast_MA_Period);
    first=math.max( Slow_MA.DATA:first(), Fast_MA.DATA:first());
	elseif Type == "MACD" then
	MACD = core.indicators:create("MACD", source.close,  MACD_Fast_MA_Period, MACD_Slow_MA_Period, MACD_Signal_MA_Period  ); 
    first=MACD.SIGNAL:first();
	else
	Stochastic = core.indicators:create("STOCHASTIC", source,  instance.parameters.K, instance.parameters.SD, instance.parameters.D, instance.parameters.KS, instance.parameters.DS  ); 
    first=Stochastic.D:first();
	end
	
	Positive= instance:addInternalStream(0, 0);
	Negative= instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first );
 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
 
    if Type == "MVA" then
    Slow_MA:update(mode);
	Fast_MA:update(mode);
	elseif Type == "MACD" then
    MACD:update(mode); 
	else 
    Stochastic:update(mode); 
	end
	
	if period <  first 
	then
	return;
	end
	
     Positive[period]=0;
	 Negative[period]=0;
	 
	 
	   if Type == "MVA" then
     Oscillator[period ]= Fast_MA.DATA[period]- Slow_MA.DATA[period];
	 elseif Type == "MACD" then
	  Oscillator[period ]= MACD.MACD[period]- MACD.SIGNAL[period];
	 else
	 
	  Oscillator[period ]= Stochastic.K[period]- Stochastic.D[period];
	 end
	 
	 if Oscillator[period ]> 0 then
	 Oscillator:setColor(period, instance.parameters.Up);
	 Positive[period]=Oscillator[period ];
	 else
	 Oscillator:setColor(period, instance.parameters.Down);
	 Negative[period]=Oscillator[period ];
	 end
	 
	 if period ==source:size()-1 
	 and period >= source:first()+Back_Bars
	 then
	 
	 local Top= mathex.avg(Positive, period-Back_Bars+1, period);
	 local Bottom= mathex.avg(Negative, period-Back_Bars+1, period);
	 
	 
	 core.host:execute("drawLine", 1, source:date(first), Top, source:date(period), Top, instance.parameters.Down);
     core.host:execute("drawLine", 2, source:date(first), Bottom, source:date(period), Bottom, instance.parameters.Up);

	 end
	 
	 
	 
				  
end

 