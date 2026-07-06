-- Id: 931
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1356

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

function Init()
    indicator:name(" Range Action Verification Index ");
    indicator:description("Identify whether a market or security is trending");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Slow", "Slow moving averages Period", "Slow moving averages Period", 65);
    indicator.parameters:addInteger("Fast", "Fast moving averages Period", "Fast moving averages Period", 7);
	
	indicator.parameters:addGroup("Style");  
	indicator.parameters:addColor("RAVI_UP", "Color of Growing RAVI", "Color of Growing RAVI", core.rgb(0, 255, 0));
	indicator.parameters:addColor("RAVI_DOWN", "Color of Falling RAVI", "Color of Falling RAVI", core.rgb(255, 0, 0));
 
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Slow;
local Fast;

local first;
local source = nil;

-- Streams block
local RAVI = nil;
local LONG=nil;
local SHORT = nil;

local UP=nil;
local DOWN = nil;

-- Routine
function Prepare(nameOnly)
    Slow = instance.parameters.Slow;
    Fast = instance.parameters.Fast;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Slow .. ", " .. Fast .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end   
	
	LONG = core.indicators:create("MVA", source, Slow);
	SHORT = core.indicators:create("MVA", source, Fast);
	 first = math.max(LONG.DATA:first(), SHORT.DATA:first());
	 
    RAVI =  instance:addInternalStream(0, 0);	 

    UP = instance:addStream("UP", core.Bar, name, "UP", instance.parameters.RAVI_UP, first);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN = instance:addStream("DOWN", core.Bar, name, "DOWN", instance.parameters.RAVI_DOWN, first);
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	UP:addLevel (0.3);
	DOWN:addLevel (-0.3);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
   
	
	 LONG:update(mode);
	 SHORT:update(mode);
	 
	  if period < first then
	 return;
	 end
	
       RAVI[period] =  100*(SHORT.DATA[period] -LONG.DATA[period]) / LONG.DATA[period];

		    
		   if RAVI[period] > RAVI[period-1] then
		   UP[period]=RAVI[period];
           else		   
		   DOWN[period]=RAVI[period];
		   end
			
 		   
		
     
end

