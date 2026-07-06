-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69509

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+

 


-- Indicator profile initialization routine

function Init()
    indicator:name("Oscillator Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "CCI Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period2", "RSI Period", "", 14, 1, 2000);
    indicator.parameters:addBoolean("Reverse", "Reverse", "Reverse", false);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("OB", "OB Level","", 0);
	indicator.parameters:addDouble("OS", "OS Level","", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Reverse; 
local Period1,Period2; 
local first;
local source = nil;
 
local Oscillator;  
local RSI, CCI;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
    Reverse= instance.parameters.Reverse;
	
	
	local Parameters= Period1..", "..Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	RSI = core.indicators:create("RSI", source.close, Period2);
	CCI = core.indicators:create("CCI", source, Period1);
    first=math.max(RSI.DATA:first(),CCI.DATA:first());
	
 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.color, first);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	Oscillator:addLevel( instance.parameters.OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel( instance.parameters.OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    
	CCI:update(mode);
	RSI:update(mode);
	if period < first
	then
	return;
	end
	 
	 if  Reverse then
	 Oscillator[period]=CCI.DATA[period]/RSI.DATA[period];
     else	 
     Oscillator[period]=RSI.DATA[period]/CCI.DATA[period];
	 end
				  
end
 
