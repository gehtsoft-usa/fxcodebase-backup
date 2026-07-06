-- Id: 12813

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61379

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
    indicator:name("Power Measure");
    indicator:description("Power Measure");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PowerMeasure_color", "Color of PowerMeasure", "Color of PowerMeasure", core.rgb(255, 0, 0));
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
local PowerMeasure = nil;
local CloseClose, HighLow;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	CloseClose = instance:addInternalStream(0, 0);
	HighLow = instance:addInternalStream(0, 0);

    if (not (nameOnly)) then
        PowerMeasure = instance:addStream("PowerMeasure", core.Line, name, "PowerMeasure", instance.parameters.PowerMeasure_color, first);
    PowerMeasure:setPrecision(math.max(2, instance.source:getPrecision()));
		PowerMeasure:setWidth(instance.parameters.width);
        PowerMeasure:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    CloseClose[period]= (source.close[period]-source.close[period-1]);
	HighLow[period]= (source.high[period]-source.low[period-1])/(source.low[period-1]);
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	
        PowerMeasure[period] =  mathex.correl(CloseClose, HighLow, period-Period+1, period, period-Period+1, period);

   
end

