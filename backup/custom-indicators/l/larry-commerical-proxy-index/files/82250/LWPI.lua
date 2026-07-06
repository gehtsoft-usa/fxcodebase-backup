-- Id: 9544
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=54686

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
    indicator:name("Larry Commerical Proxy Index");
    indicator:description("Larry Commerical Proxy Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 8);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LWPI_color", "Color of LWPI", "Color of LWPI", core.rgb(255, 0, 0));
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
local LWPI = nil;
local ATR, MA,Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Raw = instance:addInternalStream(0, 0);
        MA = core.indicators:create("MVA", Raw, Period);
        ATR = core.indicators:create("ATR", source, Period);
        LWPI = instance:addStream("LWPI", core.Line, name, "LWPI", instance.parameters.LWPI_color, first);
		LWPI:setWidth(instance.parameters.width);
        LWPI:setStyle(instance.parameters.style);
		
		LWPI:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Raw[period]= source.open[period]-source.close[period];
	
	ATR:update(mode);
	MA:update(mode);
	
    if period < first   then
	return;
	end
	
	--MovingAvg(Open-Close, bars used in average)/MovingAvg(Range,bars used in average)*50 +50
        LWPI[period] = MA.DATA[period]/ATR.DATA[period]*50+50; 
		
end

