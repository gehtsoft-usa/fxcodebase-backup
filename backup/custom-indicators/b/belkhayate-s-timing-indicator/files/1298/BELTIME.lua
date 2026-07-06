-- Id: 452
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=715

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
    indicator:name("Belkayate timing indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("N", "Number of bars", "No description", 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;

local first;
local source = nil;

-- Streams block
local O = nil;
local H = nil;
local L = nil;
local C = nil;

-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;
    source = instance.source;
    first = source:first() + N;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
    O = instance:addStream("O", core.Line, name .. ".O", "O", 0, first);
    O:setPrecision(math.max(2, instance.source:getPrecision()));
    H = instance:addStream("H", core.Line, name .. ".H", "H", 0, first);
    H:setPrecision(math.max(2, instance.source:getPrecision()));
    L = instance:addStream("L", core.Line, name .. ".L", "L", 0, first);
    L:setPrecision(math.max(2, instance.source:getPrecision()));
    C = instance:addStream("C", core.Line, name .. ".C", "C", 0, first);
    C:setPrecision(math.max(2, instance.source:getPrecision()));
    O:addLevel(8);
    O:addLevel(6);
    O:addLevel(0);
    O:addLevel(-6);
    O:addLevel(-8);
    instance:createCandleGroup("BT", "BT", O, H, L, C);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first then
        local range, sumhigh, sumlow, avg1, avg2;
        range = core.rangeTo(period, N);
        sumhigh = core.sum(source.high, range);
        sumlow = core.sum(source.low, range);
        avg1 = (sumhigh + sumlow) / (2 * N);
        avg2 = (sumhigh - sumlow) / (5 * N);

        O[period] = (source.open[period] - avg1) / avg2;
        H[period] = (source.high[period] - avg1) / avg2;
        L[period] = (source.low[period] - avg1) / avg2;
        C[period] = (source.close[period] - avg1) / avg2;
    end
end

