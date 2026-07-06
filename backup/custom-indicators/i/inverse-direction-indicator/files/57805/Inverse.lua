-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34005

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
    indicator:name("Inverse direction indicator");
    indicator:description("Inverse direction indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	 indicator.parameters:addGroup("Calculation");	
	 indicator.parameters:addBoolean("Use" , "Use Normalization", "", true);
     indicator.parameters:addInteger("Period", "Period", "Use Zero for whole period Normalization", 0);
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Inverse_color", "Color of Inverse", "Color of Inverse", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
--local P1;

local first;
local source = nil;
local Use;
-- Streams block
local Inverse = nil;
local RawInverse;
local Inv;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;	
	Use = instance.parameters.Use;
    source = instance.source;
	
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) ..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	RawInverse = instance:addInternalStream(0, 0);
    
	
	
	  assert(Period~=1, "1 is not allowed Period length.");

  
 
	
	    
		first = source:first()+Period;
		 
        Inverse = instance:addStream("Inverse", core.Line, name, "Inverse", instance.parameters.Inverse_color, first);
		Inverse:setWidth(instance.parameters.width);
        Inverse:setStyle(instance.parameters.style);
		
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

if period < first then
return;
end

   
	if Use then
	
	
	RawInverse[period] = 1/source[period];		
	
	local min1, max1,min2, max2;
	
	if Period== 0 then
	
			if period < source:size()-1   then
			return;
			end
			
		
			  min1,max1=mathex.minmax(source,  first, period );
			  min2,max2=mathex.minmax(RawInverse,  first, period );
					
		 for i = first, source:size()-1 do
		 Inverse[i]=min1 +((max1-min1)/100) * ( (RawInverse[i]-min2 )/ ((max2-min2)/100));
		 end
	 else
	 
	    if period < Period  then
		return;
		end
	     
			  min1,max1=mathex.minmax(source,  period-Period+1, period );
			  min2,max2=mathex.minmax(RawInverse,  period-Period+1, period );
					
		 for i = period-Period+1, period do
		 Inverse[i]=min1 +((max1-min1)/100) * ( (RawInverse[i]-min2 )/ ((max2-min2)/100));
		 end
	 end
	 
	 else
	  Inverse[period] = 1/source[period];	
    end
end

