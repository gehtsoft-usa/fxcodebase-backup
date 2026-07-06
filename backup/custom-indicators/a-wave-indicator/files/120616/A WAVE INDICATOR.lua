-- Id: 22034
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66534

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("A WAVE INDICATOR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14);
	indicator.parameters:addInteger("Period1", "1. EMA Period", "", 13);
	indicator.parameters:addInteger("Period2", "2. EMA Period", "", 2);
	indicator.parameters:addInteger("Period3", "3. EMA Period", "", 5);
 
 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
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

local Up,Down, Neutral;
local first;
local source = nil;

 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Period;
local Period1;
local Period2;
local Period3;

local Data1, Data2;
local MA1,MA2,MA3;
local VAR1,VAR2,VAR3;
local Signal;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
   
    Period = instance.parameters.Period;
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	 

	source = instance.source;
	first=source:first()+Period;
	VAR1 = instance:addInternalStream(0, 0);
	VAR2 = instance:addInternalStream(0, 0);
	VAR3 = instance:addInternalStream(0, 0);
	Data1 = instance:addInternalStream(0, 0);
	Data2 = instance:addInternalStream(0, 0);
	
	MA1 = core.indicators:create("EMA", Data1, Period1);
	MA2 = core.indicators:create("EMA", Data2, Period2);
	MA3 = core.indicators:create("EMA", MA2.DATA, Period3);
    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
     
    open:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	open:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    	
	
	open:addLevel(50);  
	
	Signal = instance:addStream("Signal", core.Line, "Signal", "Signal",   instance.parameters.color, first +Period1+Period2+Period3 );
	Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
	
	open:setPrecision(math.max(2, instance.source:getPrecision()));
	high:setPrecision(math.max(2, instance.source:getPrecision()));
	low:setPrecision(math.max(2, instance.source:getPrecision()));
	close:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
	
   VAR1[period]=(2*source.close[period]+source.high[period]+source.low[period])/4;
  
  if period < first then
  return;
  end
  
  VAR2[period]=mathex.min(source.low,period-Period+1, period); 	
  VAR3[period]=mathex.max(source.high,period-Period+1, period); 	
  Data1[period]=(VAR1[period]-VAR2[period] )/(VAR3[period]-VAR2[period])*100;
  

   if period < first +Period1 then
  return;
  end
  
  
  MA1:update(mode);
  
  Data2[period]= 0.667*MA1.DATA[period-1]+0.333*MA1.DATA[period];
  if period < first +Period1+Period2 then
  return;
  end
  MA2:update(mode);
  
  
  
 
  
  if MA1.DATA[period]>MA2.DATA[period] then 
  open[period]=MA2.DATA[period]; 
  close[period]=MA1.DATA[period];
  else  
  open[period]=MA2.DATA[period]; 
  close[period]=MA1.DATA[period];
  end
  
   high[period]= math.max(open[period],close[period]);
   low[period]= math.min(open[period],close[period]);
   
    MA3:update(mode);
	
	if period < first +Period1+Period2+Period3 then
  return;
  end
	 
   Signal[period]=MA3.DATA[period];
  
		
 end 