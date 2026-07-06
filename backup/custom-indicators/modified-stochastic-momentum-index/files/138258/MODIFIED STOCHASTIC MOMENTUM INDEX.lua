-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70535

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
    indicator:name("MODIFIED STOCHASTIC MOMENTUM INDEX");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "K Period", "", 8, 1, 2000);
    indicator.parameters:addInteger("Period2", "D Period", "", 3, 2, 2000);
	
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 40);
	indicator.parameters:addDouble("Level2", "2. Level","", -40);
 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2; 
local first;
local source = nil;
 
local Oscillator, Signal;  
local rel_diff,diff;
local EMA1, EMA2;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
 
	
	
	local Parameters= Period1..", "..Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period1;
	
	rel_diff= instance:addInternalStream(0, 0);
    diff= instance:addInternalStream(0, 0);
	
	EMA1 = core.indicators:create("EMA", rel_diff, Period2);
	EMA2 = core.indicators:create("EMA", diff, Period2);
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color1,EMA2.DATA:first());
	Oscillator:setWidth(instance.parameters.width1);
    Oscillator:setStyle(instance.parameters.style1);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	Oscillator:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	EMA3 = core.indicators:create("EMA", Oscillator, Period3);
	
	Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.color2,EMA3.DATA:first());
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
    Signal:setPrecision(math.max(2, source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
   local min, max = mathex.minmax(source, period-Period1+1, period);

   rel_diff[period]=  source.close[period] - (max  + min ) / 2;
   diff[period]=   (max  - min ) ;
   
   
   EMA1:update(mode);
   EMA2:update(mode);
   
    if period < EMA2.DATA:first()
	then
	return;
	end
   
     if EMA2.DATA[period]~=0 then
     Oscillator[period]= EMA1.DATA[period] / (EMA2.DATA[period] / 2) * 100;
	else
	Oscillator[period]=0;	
    end	
	
	
	  EMA3:update(mode);
	  
	  
	  if period < EMA3.DATA:first()
	then
	return;
	end
	
	Signal[period]=EMA3.DATA[period];
end 