-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70038

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
    indicator:name("RSI change");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Period1", "RSI Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period2", "Change Period", "", 1, 1, 2000);
 
 
    indicator.parameters:addGroup("Smothing Calculation"); 
    indicator.parameters:addInteger("Period3", "Smothing Period", "", 1, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0);
	indicator.parameters:addDouble("Level2", "2. Level","", 0); 
	indicator.parameters:addDouble("Level3", "3. Level","", 0); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2 ; 
local first;
local source = nil;
local RSI, Raw;
local Oscillator;  
local Indicator={};
local Average;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2; 
	Period3= instance.parameters.Period3; 
	
	local Parameters= Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	RSI = core.indicators:create("RSI", source, Period1);
    first=RSI.DATA:first() ;
	
  
    Raw = instance:addInternalStream(0, 0);
   
   
   
    if Period3== 1 then
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.color, first, Period2+Period3-1);    
	else
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first, Period2+Period3-1);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
	end
	
	
	Oscillator:setPrecision(math.max(2, source:getPrecision()));
	Oscillator:addLevel(instance.parameters.Level1 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    RSI:update(mode);
	
	if period < first +Period2
	then
	return;
	end 
	
	if Period3 == 1 then
		
		Oscillator[period]= RSI.DATA[period]-RSI.DATA[period-Period2] ;
	 
		
	else 	    
		
		Raw[period]= RSI.DATA[period]-RSI.DATA[period-Period2] ;
		
		if period < first +Period2+Period3
		then
		return;
		end 
		
		 Oscillator[period]= mathex.avg(Raw, period-Period3+1, period);

    end
	
end 