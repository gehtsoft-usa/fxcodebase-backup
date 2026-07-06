-- Id: 9125
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36543

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
    indicator:name("Point of balance oscillator");
    indicator:description("Point of balance oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14, 2 , 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of BL", "Color of BL", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Dn", "Color of BL", "Color of BL", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local POBC={};
-- Streams block
 
local POB = nil;
 

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	local i;
	
	for i = 1 ,Period, 1 do
	POBC[i]  = instance:addInternalStream(0, 0);
	end

  
      
        POB = instance:addStream("POB", core.Bar, name .. ".POB", "POB", instance.parameters.Up, first);
    POB:setPrecision(math.max(2, instance.source:getPrecision()));
		 
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	
local min, max;
	min, max= mathex.minmax(source.close, period-Period+1, period);
       
   POB[period] = 100*((source.close[period] - AV(period))) / (max-min);
   
      if POB[period] > 0 then
	   POB:setColor(period, instance.parameters.Up);
	   else
	   POB:setColor(period, instance.parameters.Dn);
	   end
end

function AV (period)

local i;
local SUM =0;
local min, max;
	min, max= mathex.minmax(source.close, period-Period+1, period);

POBC[1][period] = (max + min) /2;
SUM=SUM+POBC[1][period];


		for i = 2 , Period, 1 do

		min, max= mathex.minmax(POBC[i-1], period-Period+1, period);

		POBC[i][period] = (max + min) /2;
		SUM=SUM+POBC[i][period]; 
		end

return SUM /Period;
end
