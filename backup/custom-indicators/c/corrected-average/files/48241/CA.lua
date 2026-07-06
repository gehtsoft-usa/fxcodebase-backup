-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27589
-- Id: 8061

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
    indicator:name("Corrected Average");
    indicator:description("Corrected Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addInteger("Shift", "Shift", "Shift", 0);
    indicator.parameters:addColor("CA_color", "Color of CA", "Color of CA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Shift;

local first;
local source = nil;
local Method;
-- Streams block
local CA = nil;
local Initial;
local FIRST;
local MA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    Shift = instance.parameters.Shift;
    source = instance.source;
    first = source:first();
	
	
	if  Shift > 0 then
	FIRST= first + Shift;
	else
	FIRST= first;
	end

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Shift) .. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        MA = core.indicators:create(Method, source, Period);
	    Initial = instance:addInternalStream(first, 0); 
		
        CA = instance:addStream("CA", core.Line, name, "CA", instance.parameters.CA_color, FIRST, Shift);
		CA:setWidth(instance.parameters.width);
        CA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
	MA:update(mode);
	
	if period <  math.max( MA.DATA:first() +1 , Period) then
	return;
	end
	
	
	
	local Std = mathex.stdev (source, period-Period+1, period);
	local v1= math.pow  (Std ,2);
    local v2= math.pow ( (Initial[period-1] - MA.DATA[period]),2);
   --local v1= math.sqrt  (Std);
   -- local v2= math.sqrt (Initial[period-1] - MA.DATA[period]);
	
      local  k=0;
	  
	  if  v2<v1  or v2==0  then
      k=0;
	  else
	  k=1-v1/v2;
	  end
	  
    Initial[period]=Initial[period-1]+k*(MA.DATA[period]-Initial[period-1]);   
    ShiftFunction (period);
end

function ShiftFunction (period)

local p= period+Shift;	
	if  Shift < 0 then	
	
	   if  period+Shift < FIRST then
	   return;
	   end
	
	end
	
    CA[p]= Initial[period];

end

