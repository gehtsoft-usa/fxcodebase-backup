-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36070
-- Id: 9063

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Average MACD Swing");
    indicator:description("Average MACD Swing");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("MACD Calculation");
    indicator.parameters:addInteger("ShortPeriod", "Short Period", "Short Period", 12);
    indicator.parameters:addInteger("LongPeriod", "Long Period", "Long Period", 26);
    indicator.parameters:addInteger("SignalPeriod", "Signal Period", "Signal Period", 9);
	
	
	indicator.parameters:addGroup("MACD Calculation");
	indicator.parameters:addString("Method", "MA Method", "Method" , "Zero Line");
    indicator.parameters:addStringAlternative("Method", "Zero Line", "Zero Line" , "Zero Line");
    indicator.parameters:addStringAlternative("Method", "Signal Line", "Signal Line" , "Signal Line"); 
	
	 indicator.parameters:addInteger("Period", "Period", "Period", 3);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("AMS_color", "Color of AMS", "Color of AMS", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortPeriod;
local LongPeriod;
local SignalPeriod;
local Method, Period;
local first;
local source = nil;

-- Streams block
local AMS = nil;
local MACD;
-- Routine
function Prepare(nameOnly)
    ShortPeriod = instance.parameters.ShortPeriod;
    LongPeriod = instance.parameters.LongPeriod;
    SignalPeriod = instance.parameters.SignalPeriod;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;
	Price = instance.parameters.Price;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(ShortPeriod) .. ", " .. tostring(LongPeriod) .. ", " .. tostring(SignalPeriod) .. ", " .. tostring(Method) .. ", " .. tostring(Period).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MACD = core.indicators:create("MACD", source , ShortPeriod, LongPeriod, SignalPeriod);
        first = MACD.SIGNAL:first();
        AMS = instance:addStream("AMS", core.Line, name, "AMS", instance.parameters.AMS_color, first);
		AMS:setWidth(instance.parameters.width);
        AMS:setStyle(instance.parameters.style);
		
		MACD:setPrecision(math.max(2, instance.source:getPrecision()));
		AMS:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    MACD:update(mode);
	
    if period < first   then
	return;
	end
	
	
	   
	    if Method== "Zero Line" then		
        AMS[period] = Calculate(period, MACD.MACD, 0);	
        else
		AMS[period] = Calculate(period, MACD.MACD, MACD.SIGNAL);	
        end   
      		
    
end

function Calculate (period, One, Two)

  local i;
  local Break=1;
  local Sum=0;
  local Array={};
  local FIRST;
  Array[Break]=period;
  
    if Method== "Zero Line" then	
   FIRST=  One:first() ;
   else
   FIRST= math.max(One:first(), Two:first());
   end
  
  for i = period, FIRST+1, -1 do
     
      
	   if core.crosses (One, Two, i) then	   
	   Break=Break+1;
	   Array[Break]=i;
	   end
	  
	   if Break == Period+1 then
	   break;
	   end
   
  end
  
  
 
  
  for i = 2, Period+1 , 1 do
  
		  if  Array[i]~= nil and Array[i-1]~= nil  then
		  
				   if core.crossesOver (One, Two ,  Array[i]) then
				   Sum = Sum + ( mathex.max(source, Array[i], Array[i-1]) - source[Array[i]]) ;
				   elseif core.crossesUnder (One, Two ,  Array[i]) then  
				   Sum = Sum - (    source[Array[i]] - mathex.min(source, Array[i], Array[i-1]))  ;
				   end   
				  
				  end
					  
				  return Sum/ (Break-1);
		  
		  end
  
end
