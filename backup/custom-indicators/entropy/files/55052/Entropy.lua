-- Id: 8551
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32298

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
    indicator:name("Entropy");
    indicator:description("Entropy");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Entropy_color", "Color of Entropy", "Color of Entropy", core.rgb(255, 0, 0));
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

local first;
local source = nil;

-- Streams block
local Entropy = nil;
local x, x2;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        x = instance:addInternalStream(0, 0);
        x2 = instance:addInternalStream(0, 0);
        Entropy = instance:addStream("Entropy", core.Line, name, "Entropy", instance.parameters.Entropy_color, first);
    Entropy:setPrecision(math.max(2, instance.source:getPrecision()));
		Entropy:setWidth(instance.parameters.width);
        Entropy:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
	
	local r=math.log(source[period] / source[period-1]) ;
	x[period] = r;
	x2[period]= r * r;
	
	 if period < first then
	return;
	end
	local avgx = mathex.avg(x, period-Period+1, period );
	local sumx = mathex.avg(x, period-Period+1, period );
	local sumx2 = mathex.avg(x2, period-Period+1, period );
	
	    avgx = sumx / Period;
		rmsx = math.sqrt(sumx2/Period); 
		local P = ((avgx/rmsx)+1)/2.0;
		 	
        Entropy[period]= P * math.log(1+rmsx) + (1-P) * math.log(1-rmsx);
		
		
 end

