-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69011

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Stochastic MACD Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Period", "Period", "", 45, 1, 2000);
    indicator.parameters:addInteger("Period1", "Fast Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow Period", "", 26, 1, 2000);
	
    indicator.parameters:addInteger("Period3", "Signal Period", "", 9, 1, 2000);
 
	
	indicator.parameters:addGroup("Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Signal Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 10);
    indicator.parameters:addDouble("oversold","Oversold Level","", -10);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Slow, Fast,Signal; 
local Period1,Period2,Period3,Period; 
local first;
local source = nil;
 
local Oscillator,Signal_Line;  
 
-- Routine
 function Prepare(nameOnly)   
 
    Period= instance.parameters.Period;
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	
	
	local Parameters= Period..", "..Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+math.max(Period, Period1, Period2);
	
	-- Average= instance:addInternalStream(0, 0);
   
    Fast = core.indicators:create("EMA", source.high, Period1);
	Slow = core.indicators:create("EMA", source.low, Period2);
	
	
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color1, first);
	Oscillator:setWidth(instance.parameters.width1);
    Oscillator:setStyle(instance.parameters.style1);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	Signal = core.indicators:create("EMA", Oscillator, Period3);
	
	
	Signal_Line = instance:addStream("Signal_Line" , core.Line, " Signal_Line"," Signal_Line",instance.parameters.color2, first+Period3);
	Signal_Line:setWidth(instance.parameters.width2);
    Signal_Line:setStyle(instance.parameters.style2);
    Signal_Line:setPrecision(math.max(2, source:getPrecision()));
	
	
	Signal_Line:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Signal_Line:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    Fast:update(mode);
	Slow:update(mode);
 
	if period < first
	then
	return;
	end
	 
	 
	local min,max=mathex.minmax(source, period-Period+1, period);
	
	
	local Stoch1 = (Fast.DATA[period]-min)/(max-min)
    local Stoch2 = (Slow.DATA[period]-min)/(max-min)
    Oscillator[period] = (Stoch1-Stoch2)*100;
	
	Signal:update(mode);
 
	if period < first+Period3
	then
	return;
	end
	
	Signal_Line[period]=Signal.DATA[period];
end

 
 
