-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70211

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
    indicator:name("Compare price momentum");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 35, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. Period", "", 10, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Signal Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3,Smoothing1, Smoothing2, Smoothing3 ; 
local first;
local source = nil;
 
local ROC,EMAofROC;  
local Indicator={};
local Average;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
 
    Smoothing1= 2/Period1;
	Smoothing2= 2/Period2;
	Smoothing3= 2/Period3;
	
	local Parameters= Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+1;
	
	ROC= instance:addInternalStream(0, 0);
	EMAofROC= instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
	
	
	Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.color1, first );
	Signal:setWidth(instance.parameters.width1);
    Signal:setStyle(instance.parameters.style1);
    Signal:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	ROC[period]=(source[period]-source[period-1])/source[period-1]*100;
 
	EMAofROC[period] = EMAofROC[period-1] * ( 1 - Smoothing1 )+ ROC[period] * Smoothing1 ;
    Oscillator[period] =  Oscillator[period-1] * ( 1 - Smoothing2 )+ EMAofROC[period] * Smoothing2;
	 Signal[period] =  Signal[period-1] * ( 1 - Smoothing2 )+ Oscillator[period] * Smoothing3;
	
 
 
end

 