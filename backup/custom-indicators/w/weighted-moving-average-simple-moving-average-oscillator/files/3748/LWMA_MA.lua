-- Id: 1291
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1866

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
    indicator:name("MA / VMA Oscillator");
    indicator:description("MA / VMA Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Frame", "Period", "Period", 20, 2, 2000);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("OSC_Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("OSC_Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;
local MVA=nil;
local LWMA=nil;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
    source = instance.source;
   
	
	assert(core.indicators:findIndicator("LWMA") ~= nil, "Please, download and install LWMA.LUA indicator");
	assert(core.indicators:findIndicator("MVA") ~= nil, "Please, download and install MVA.LUA indicator");
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
	instance:name(name);
	if nameOnly then
		return nameOnly;
	end
	
	LWMA = core.indicators:create("LWMA",source, Frame);
	MVA = core.indicators:create("MVA", source,  Frame);
	
	 first = MVA.DATA:first();
	
	DATA= instance:addInternalStream(first, 0);

    UP = instance:addStream("UP", core.Bar, name, "UP", instance.parameters.OSC_Up, first);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN = instance:addStream("DOWN", core.Bar, name, "DOWN", instance.parameters.OSC_Down, first);
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)    
	
	LWMA:update(mode);
	MVA:update(mode);
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
	    DATA[period]= (LWMA.DATA[period] / MVA.DATA[period])-1;
	
	    if DATA[period] > DATA[period-1] then
		UP[period] =DATA[period];
		else
		DOWN[period] =DATA[period];
		end
  
end

