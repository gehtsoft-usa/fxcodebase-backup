-- Id: 3160
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3447

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
    indicator:name("Trend Confirmation Indicator ");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("Short", "Short MA Period", "", 5);
	indicator.parameters:addInteger("Long", "Long MA Period", "", 20);
	
	indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short, Long;

local first;
local source = nil;

-- Streams block
local TCI = nil;

-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
	Long = instance.parameters.Long;
    source = instance.source;
    first = source:first();
	
	if (Long <= Short) then
       error("The short MA period must be smaller than long MA period");
    end

    local name = profile:id() .. "(" .. source:name() .. ", "..  Short.. ", " .. Long .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ShortMA = core.indicators:create("MVA", source,Short);
	LongMA = core.indicators:create("MVA", source,Long);
	
	first= math.max(LongMA.DATA:first(),ShortMA.DATA:first());
	
	TCI = instance:addStream("TCI", core.Line, name, "TCI", instance.parameters.color, first);
    TCI:setPrecision(math.max(2, instance.source:getPrecision()));
	TCI:setWidth(instance.parameters.width);
    TCI:setStyle(instance.parameters.style);
		
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	
	ShortMA:update(mode);
	LongMA:update(mode);
	
        TCI[period] = (ShortMA.DATA[period] / LongMA.DATA[period]-1) *100;
    end
end

