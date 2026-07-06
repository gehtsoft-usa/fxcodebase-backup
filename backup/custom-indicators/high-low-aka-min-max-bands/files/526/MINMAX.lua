-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=302

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Min/Max bands");
    indicator:description("Shows minimum and maximum for the last N periods");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Min_color", "Color of Min", "Color of Min", core.rgb(128, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("Max_color", "Color of Max", "Color of Max", core.rgb(128, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

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
local Min = nil;
local Max = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    source = instance.source;
    first = source:first() + N;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Min = instance:addStream("Min", core.Line, name .. ".Min", "Min", instance.parameters.Min_color, first);
	Min:setWidth(instance.parameters.width1);
    Min:setStyle(instance.parameters.style1);
    Max = instance:addStream("Max", core.Line, name .. ".Max", "Max", instance.parameters.Max_color, first);
	Max:setWidth(instance.parameters.width2);
    Max:setStyle(instance.parameters.style2);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
        local min, max
        min, max = mathex.minmax(source, period- N+1, period );
        Min[period] = min;
        Max[period] = max;
    end
end

