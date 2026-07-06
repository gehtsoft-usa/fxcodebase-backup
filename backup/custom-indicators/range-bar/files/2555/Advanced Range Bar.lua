-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1338

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
    indicator:name("Advanced Range Bar");
    indicator:description("Generates a signal when the bar closes above / below one third of Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("F", "Range Period", "Period", 1);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("UP", "Color of Up Bar", "Color of Up Bar", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Bar", "Color of Down Bar", core.rgb(255, 0, 0));
		
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame=nil;

local first;
local source = nil;

-- Streams block
local up = nil;
local down = nil;
local MAX;
local MIN;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.F;
    source = instance.source;
    first = source:first();
	
	UP=instance.parameters.UP;
	DOWN= instance.parameters.DOWN;
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
	
	 if nameOnly then
        return;
    end
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Bottom, UP, first+Frame);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Top, DOWN, first +Frame);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   
			if period < Frame or not source:hasData(period) then
			return;
			end
			

				MIN, MAX=mathex.minmax(source,period-Frame+1, period);  
			
			 
			 
				 if source.open[period] < (MIN+(MAX-MIN) / 3) and source.close[period] > (MAX-(MAX-MIN)/3)then 	 
				  up:set(period, source.low[period], "\225");
				 end
				 
				 if source.close[period] < (MIN+(MAX-MIN) /3 ) and source.open[period] > (MAX-(MAX-MIN)/3)then
				  down:set(period, source.high[period], "\226");
				 end 
			 
	
end
