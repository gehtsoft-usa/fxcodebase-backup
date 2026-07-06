-- Id: 22146
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66591

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Relative Strength Index LEO");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "RSI Period", "", 14, 2, 1000); 
	  indicator.parameters:addInteger("Period1", "1. MA Period", "", 9, 2, 1000); 
	   indicator.parameters:addInteger("Period2", "2. Period", "", 45, 2, 1000); 
	 
	 
	indicator.parameters:addGroup("Style");
	
	local colour = core.colors();
	indicator.parameters:addColor("color1", "RSI color", "", colour.Lime);
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color2", "1.MA color", "", colour.Blue);
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color3", "2.MA color", "", colour.Yellow);
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color4", "Histogram Line Color", "", colour.Red);

	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 40);
    indicator.parameters:addDouble("Level2","2. Level","", 50);
	indicator.parameters:addDouble("Level3","3. Level","", 60);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

 
local first;
local source = nil;
local diff1, diff2;
local Period; 
local EMA1, EMA2;
local Line1, Line2, Line3,Line4;
local Period1, Period2;

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


   Period= instance.parameters.Period;  
   Period1= instance.parameters.Period1;
   Period2= instance.parameters.Period2;
	source = instance.source;
	first=source:first()+Period;
	
	
		
  
    diff1= instance:addInternalStream(0, 0);
	diff2= instance:addInternalStream(0, 0);
	
	EMA1=core.indicators:create("EMA",  diff1, Period);
	EMA2=core.indicators:create("EMA",  diff2, Period);
	
	Line1 = instance:addStream("RSI", core.Line, "RSI", "RSI",  instance.parameters.color1, first);
    Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
	
	Line1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	Line1:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	
	Line2 = instance:addStream("MA1", core.Line, "MA1", "MA1", instance.parameters.color2, first+Period1);
    Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
	
	
	Line3 = instance:addStream("MA2", core.Line, "MA1", "MA2", instance.parameters.color3, first+Period2);
    Line3:setWidth(instance.parameters.width3);
    Line3:setStyle(instance.parameters.style3);
	
	Line4 = instance:addStream("Histogram", core.Bar, "Histogram", "Histogram", instance.parameters.color4, first+math.max(Period2,Period1));
 
	Line1:setPrecision(math.max(2, instance.source:getPrecision()));
	Line2:setPrecision(math.max(2, instance.source:getPrecision()));
	Line3:setPrecision(math.max(2, instance.source:getPrecision()));
	Line4:setPrecision(math.max(2, instance.source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)
	
   
	 
	 local diff= source[period] - source[period - 1];			
     diff1[period] = math.max(diff, 0);
	 diff2[period] = -math.min(diff, 0);
		

    EMA1:update(mode);	
	EMA2:update(mode);
	
	  if period < first then 
			return;
	end
	
	  
	  if EMA2.DATA[period]== 0 then
	  Line1[period]=0;
	  else
	  Line1[period]=100 - (100 / (1 + EMA1.DATA[period] / EMA2.DATA[period]));
	  end
	  
	  
	 if period >= first +Period1 then 
	 Line2[period]=mathex.avg(Line1,period-Period1+1, period);		 
	 end
	 
	 
	 if period >= first +Period2 then 
	 Line3[period]=mathex.avg(Line1,period-Period2+1, period);		 		 
	 end
	 
	 
	 if period < first+math.max(Period2,Period1) then
	 return;
	 end
	 
	 Line4[period]= Line3[period]-Line2[period];
 end

 