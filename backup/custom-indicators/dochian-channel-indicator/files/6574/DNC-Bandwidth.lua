-- Id: 2554

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20

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
function Init()
    indicator:name("Donchian Channel - Bandwidth Oscillator");
    indicator:description("Donchian Channel - Bandwidth Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 20);
    indicator.parameters:addColor("clrBBB", "Bandwidth Line color", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local first;
local source = nil;
local BAND;

-- Streams block


-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;
   
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. "," .. N .. ")";
    instance:name(name);  
	
	if   (nameOnly) then
        return;
    end
  
    BAND = instance:addStream("Bandwidth", core.Line, name .. ".BANDWIDTH", "Bandwidth", instance.parameters.clrBBB, first);
    BAND:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period)
    
    if period < N or not source:hasData(period) then
	return;
	end
	
	local min, max;
	min, max= core.minmax( source , core.range(period-N, period));
 
    	BAND[period] = max-min;
     
end





