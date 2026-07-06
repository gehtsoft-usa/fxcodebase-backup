-- Id: 19198
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65148

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
    indicator:name("MA Angle");
    indicator:description(" Determines MA Angle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method", "TEMA", "TEMA" , "TEMA");
    indicator.parameters:addInteger("Period", "Period", "Period", 50, 2, 2000);
    indicator.parameters:addInteger("Start", "Start Shift", "Shift", 2, 0, 2000);
	indicator.parameters:addInteger("End", "End Shift", "Shift", 0, 0, 2000);
	indicator.parameters:addDouble("Treshold", "Treshold", "Treshold", 0.25 , 0, 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top", "Positiv Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Negativ Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Zero", "Neutral Color", "", core.rgb(255, 215, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period=nil;
local Start=nil;
local End=nil;
local Treshold = nil;
local Method;
local first;
local source = nil;

-- Streams block
local ANGLE = nil;

local Bottom=nil;
local Zero=nil;
local Top=nil;

local MA=nil;
  
-- Routine
function Prepare(nameOnly)  

    Bottom=instance.parameters.Bottom;
    Zero=instance.parameters.Zero;
    Top=instance.parameters.Top;
	Method=instance.parameters.Method;

    Period = instance.parameters.Period;
    Start = instance.parameters.Start;
	End = instance.parameters.End;
	Treshold = instance.parameters.Treshold;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Period ..  ", " ..  Start..  ", " ..  End .. ", " .. Treshold .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 assert(Start >= End, "Start Shift must be greater than or equal to End Shift.");
   
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " ..  Method .. ".LUA indicator");
		
	
	MA = core.indicators:create(Method, source.median, Frame);
	first = MA.DATA:first()+ math.max(Start, End);

    
    ANGLE = instance:addStream("ANGLE", core.Bar, name, "ANGLE", Zero, first);
	ANGLE:setPrecision(math.max(2, instance.source:getPrecision())); 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    MA:update(mode);
  
    if period  <  first  or not  source:hasData(period) then
	return;
	end
	
        	      
      ANGLE[period] = ( MA.DATA[period-End] - MA.DATA[period-Start])/ source:pipSize();
	  
	
      
      if ANGLE[period] >= Treshold then
      ANGLE:setColor(period, Top);
      elseif ANGLE[period] <=  -Treshold then
        ANGLE:setColor(period, Bottom); 
      else 
	  ANGLE:setColor(period, Zero);
	  end

 
end