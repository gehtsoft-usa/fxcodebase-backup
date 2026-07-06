-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69609 

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Alexander Elder System Helper");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("MACD Calculation");
	
	
 
	indicator.parameters:addString("Price1" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price1" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "High", "", "high");
    indicator.parameters:addStringAlternative("Price1" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price1" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price1", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price1" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price1" , "Weighted ", "", "weighted");		
 
	
	 indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
	indicator.parameters:addGroup("MA Calculation");
		
		
 
	indicator.parameters:addString("Price2" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price2" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "High", "", "high");
    indicator.parameters:addStringAlternative("Price2" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price2" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price2", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price2" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price2" , "Weighted ", "", "weighted");		
 
 
	 indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);	
		
 
    indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;

local Price1,Price2,Method;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local SN, LN, IN= nil;
 
local MA;

 


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
   
    Period= instance.parameters.Period;
    IN = instance.parameters.IN;
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
	
	Price1 = instance.parameters.Price1;
	Price2 = instance.parameters.Price2;
	Method= instance.parameters.Method;
	
 
	
	if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
	

	source = instance.source;
	
	
	
		MACD=core.indicators:create("MACD",  source[Price1], SN, LN, IN);
	    MA=core.indicators:create(Method,  source[Price2], Period);
 
	
	first= math.max(MA.DATA:first(), MACD.SIGNAL:first());

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
 
	
			   MACD:update(mode);
			   MA:update(mode);
			   
		 
	local One,Two=nil, nil;

	
		    if MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period-1]
			and  MACD.HISTOGRAM[period-1] > MACD.HISTOGRAM[period-2] 			 
			then
			One = 1;
			elseif MACD.HISTOGRAM[period] < MACD.HISTOGRAM[period-1]
			and  MACD.HISTOGRAM[period-1] < MACD.HISTOGRAM[period-2]  
			then
			One = -1;
			end  
		 
 		
		    if MA.DATA[period] > MA.DATA[period-1]  
			then
			Two = 1;
			elseif MA.DATA[period] < MA.DATA[period-1]  
			then
			Two = -1;
			end  
		 
		
		if One == nil  or Two == nil then
		open:setColor(period,Neutral);	   
		elseif One == 1  and Two == 1    then		
		open:setColor(period,  Up);
        elseif One == -1 and  Two == -1  then
		open:setColor(period,  Down);
		else
		open:setColor(period, Neutral);			
		end
		
		
				

		
 end


