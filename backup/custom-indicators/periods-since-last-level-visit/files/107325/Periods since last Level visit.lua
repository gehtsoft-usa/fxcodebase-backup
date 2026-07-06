-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63707
-- Id: 16420

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
    indicator:name("Periods since last Level visit ");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "MA Period","", 34);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Bar Color", "Bar Color", core.rgb(0, 255, 0));
	
	 indicator.parameters:addColor("color1", "Bar Color", "Bar Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
  
end
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Period, MA;
local first;
local source = nil;
local Value;
 
-- Routine
function Prepare(nameOnly)
   
    source = instance.source; 
	Period= instance.parameters.Period;
	first = source:first() ; 
	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then	  
			Value= instance:addStream("Value", core.Bar, name .. ".Value", "Value",  instance.parameters.color, source:first());	 
    Value:setPrecision(math.max(2, instance.source:getPrecision()));
            MA= instance:addStream("MA", core.Line, name .. ".MA", "MA",  instance.parameters.color1, source:first());	
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
            MA:setWidth(instance.parameters.width1);
            MA:setStyle(instance.parameters.style1);			
    end
end
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period < first  or not source:hasData(period) then
	return;
	end  
	 	
   Value[period]= Calculate(period);  
   
   
    if period < first + Period then
	return;
	end  
	
	MA[period]= mathex.avg( Value, period-Period+1, period);
    
end 

function Calculate(Index)
 
   local Now=-1;

  for period= Index-1, first, -1 do
	  if source.close[Index]<=source.high[period]
	  and source.close[Index]>=source.low[period]
	  then
	  Now=period;
	  break;
	  end  
  end  
  if Now==-1 then
  return 0;
  else
  return Index-Now;
  end
end