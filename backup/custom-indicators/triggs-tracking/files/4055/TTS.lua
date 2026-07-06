-- Id: 1434
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1997

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Triggs Tracking");
    indicator:description("Triggs Tracking");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addDouble("A", "A", "A", 0.5, 0.5,1.0);
    indicator.parameters:addColor("Slow_color", "Color of Slow", "Color of Slow", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Fast_color", "Color of Fast", "Color of Fast", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local A;
local B;

local first;
local source = nil;

-- Streams block
local Slow = nil;
local Fast = nil;
local  L1  = nil;
local  L2  = nil;
local  L3  = nil;
local  L4  = nil;
local  L5  = nil;
local  L6  = nil;
local  L7  = nil;
local  L8  = nil;
local  L9  = nil;
local  L10= nil;
local  L11  = nil;


-- Routine
function Prepare(nameOnly)
    A = instance.parameters.A;
    source = instance.source;
    first = source:first();
	
	B=1-A;
    local name = profile:id() .. "(" .. source:name() .. ", " .. A .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	L1  = instance:addInternalStream(first+1, 0);
	L2  = instance:addInternalStream(first+1, 0);
	L3  = instance:addInternalStream(first, 0);
	L4  = instance:addInternalStream(first+1, 0);
	L5  = instance:addInternalStream(first+1, 0);
	L6  = instance:addInternalStream(first+1, 0);
	L7  = instance:addInternalStream(first+2, 0);
    L8  = instance:addInternalStream(first+2, 0);
    L9  = instance:addInternalStream(first+1, 0);
	L10  = instance:addInternalStream(first+2, 0);
    L11  = instance:addInternalStream(first+2, 0);
    Slow = instance:addStream("Slow", core.Line, name .. ".Slow", "Slow", instance.parameters.Slow_color, first+3);
    Slow:setPrecision(math.max(2, instance.source:getPrecision()));
    Fast = instance:addStream("Fast", core.Line, name .. ".Fast", "Fast", instance.parameters.Fast_color, first+3);
    Fast:setPrecision(math.max(2, instance.source:getPrecision()));
	
	Fast:addLevel(-0.25);
	Fast:addLevel(0.25);
	Fast:addLevel(-0.50);
	Fast:addLevel(0.50);
	Fast:addLevel(-0.75);
	Fast:addLevel(0.75);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

     if period ==first then
	 L3[period]=source.close[first];
     end	 
	 
	 if period ==first+1 then
	 L6[period]=source.close[first]/40;
	 L9[period]= source.close[first]/40;
     end	 
	  if period ==first+2 then
	 L7[period]= L6[period]/ L8[period];
	 L8[period]=0.5;
	 L10[period]=L9[period]/L11[period];
	 L11[period]=0.5;
     end	 

    if period >= first+1 and source:hasData(period) then    
	
	L1[period]= source.close[period]*A;
	L2[period]= L3[period-1]*B;
	if period >=2 then
	L3[period]= L1[period]+	L2[period];
	end
	L4[period]= source.close[period]-L3[period];
	L5[period]= math.abs(L4[period]);
	if period >= 3 then
	L6[period]= 0.1*L4[period]+0.9*L6[period-1];
	end
	if period >= 4 then
	L7[period]= 0.1*L5[period]+0.9*L7[period-1];
	L8[period]= L6[period]/L7[period];
	 Slow[period] = L8[period];
	end
	if period >= 3 then
	L9[period]= 0.2*L4[period] + 0.8*L9[period-1];
	end
	
	if period >= 4 then
	L10[period]= 0.2*L5[period] + 0.8*L10[period-1];
	L11[period]=L9[period]/L10[period];
	 Fast[period] = L11[period];
	end
	
       
       
    end
end

