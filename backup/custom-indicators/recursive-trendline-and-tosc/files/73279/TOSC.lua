-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=46409
-- Id: 9495

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
    indicator:name("TOSC");
    indicator:description("Difference between the recursive trendline value and the exponential moving average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TOSC_color", "Color of TOSC", "Color of TOSC", core.rgb(255, 0, 0));
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
local alpha;
-- Streams block
local TOSC = nil;
local b0,X1;
local EMA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        b0 = instance:addInternalStream(0, 0);
        X1 = instance:addInternalStream(0, 1);
        EMA = core.indicators:create("EMA", source, Period);
        alpha=2/(Period+1)
        TOSC = instance:addStream("TOSC", core.Line, name, "TOSC", instance.parameters.TOSC_color, EMA.DATA:first());
    TOSC:setPrecision(math.max(2, instance.source:getPrecision()));
		TOSC:setWidth(instance.parameters.width);
        TOSC:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first  then
	return;
	end
	
	    b0[period]  =  (1-alpha)* b0[period-1] + source[period];
	    X1[period+1] = (1-alpha)*X1[period] + alpha*(source[period]+b0[period]-b0[period-1]);
		
		EMA:update(mode);
		
		if period < EMA.DATA:first() then
		return;
		end
		
        TOSC[period]=X1[period ]- EMA.DATA[period];
   
end