-- Id: 23470
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67195

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

function Init()
    indicator:name("Pascal Willain Effective Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup(" MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 10, 1, 2000);

	
	indicator.parameters:addString("Method", "MA Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("AbsoluteValue", "Absolute Value", "", false);
	

	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period;

local first;
local source = nil;
local AbsoluteValue; 
local Oscillator;  
local Indicator;
local Data;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
	AbsoluteValue= instance.parameters.AbsoluteValue;
	
	
	local Parameters= Period ..  ", " .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Data = instance:addInternalStream(0, 0);
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    Indicator = core.indicators:create(Method, Data, Period);
    
    first=source:first()+1 +Period ;
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)



    if period < source:first()+1 then
	return;
	end
 
      local  dividend;
	  
      if AbsoluteValue then
	  dividend = math.abs(source.close[period]-source.close[period-1]);
	  else
      dividend = source.close[period]-source.close[period-1];
	  end
      local  divisor  = math.max(source.high[period],source.close[period-1])-math.min(source.low[period],source.close[period-1]);
         if (divisor~=0) then
		 
               Data[period] = dividend/divisor*source.volume[period];
		 	   
         else 
         		 
		 Data[period] = 0;
		 end
 
 
 
    Indicator:update(mode);

	
	
    if period < first then
	return;
	end
	
		
     Oscillator[period]=Indicator.DATA[period];
				  
end

