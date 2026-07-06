-- Id: 15054

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62871

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
    indicator:name("Accumulation Distribution Momentum Sum");
    indicator:description("Accumulation Distribution Momentum Sum");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "Momentum Period","", 14);
	indicator.parameters:addString("Method", "Accumulation Distribution Method","", "CI");
    indicator.parameters:addStringAlternative("Method", "Classic", "", "CS");
    indicator.parameters:addStringAlternative("Method", "Classic Incremental", "", "CI");
    indicator.parameters:addStringAlternative("Method", "Trade Station", "", "TS");
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Sum_color", "Color of Sum", "Color of Sum", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Method, Period;
-- Streams block
local Sum = nil;
local AD;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Method=instance.parameters.Method;
    Period=instance.parameters.Period;
	
	AD = core.indicators:create("AD", source, Method);
    first = math.max(AD.DATA:first(), Period);

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Method .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Sum = instance:addStream("Sum", core.Line, name, "Sum", instance.parameters.Sum_color, first);
    Sum:setPrecision(math.max(2, instance.source:getPrecision()));
		Sum:setWidth(instance.parameters.width);
        Sum:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    AD:update(mode);
    if period < first or not  source:hasData(period) then
	return;
	end
        Sum[period] = AD.DATA[period]+ (source.close[period]-source.close[period-Period]);
   
end

