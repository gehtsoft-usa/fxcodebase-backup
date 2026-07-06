-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=518

--+------------------------------------------------------------------+
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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Heiken Ashi");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("haHIGH_color", "Color of haHIGH", "Color of haHIGH", core.rgb(128, 128, 128));
    indicator.parameters:addColor("haUPC_color", "Color of haUPC", "Color of haUPC", core.rgb(0, 255, 0));
    indicator.parameters:addColor("haDNC_color", "Color of haDNC", "Color of haDNC", core.rgb(128,128,128));
    indicator.parameters:addColor("haUPO_color", "Color of haUPO", "Color of haUPO", core.rgb(128,128,128));
    indicator.parameters:addColor("haDNO_color", "Color of haDNO", "Color of haDNO", core.rgb(255, 0, 0));
    indicator.parameters:addColor("haLOW_color", "Color of haLOW", "Color of haLOW", core.rgb(0, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local haHIGH = nil;
local haUPC = nil;
local haDNC = nil;
local haUPO = nil;
local haDNO = nil;
local haLOW = nil;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+1;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    haOPEN = instance:addInternalStream(first);
    haCLOSE = instance:addInternalStream(first);
    haHIGH = instance:addStream("haHIGH", core.Bar, name .. ".haHIGH", "haHIGH", instance.parameters.haHIGH_color, first);
    haUPC = instance:addStream("haUPC", core.Bar, name .. ".haUPC", "haUPC", instance.parameters.haUPC_color, first);
    haUPO = instance:addStream("haUPO", core.Bar, name .. ".haUPO", "haUPO", instance.parameters.haUPO_color, first);
    haDNO = instance:addStream("haDNO", core.Bar, name .. ".haDNO", "haDNO", instance.parameters.haDNO_color, first);
    haDNC = instance:addStream("haDNC", core.Bar, name .. ".haDNC", "haDNC", instance.parameters.haDNC_color, first);
    haLOW = instance:addStream("haLOW", core.Bar, name .. ".haLOW", "haLOW", instance.parameters.haLOW_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period == source:first() then
        haOPEN[period] = source.open[period];
        haCLOSE[period] = source.close[period];
    end
    if period >= first and source:hasData(period) then
        haOPEN[period] = (haOPEN[period - 1] + haCLOSE[period - 1]) / 2;
        haCLOSE[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
        haHIGH[period] = math.max(source.high[period],math.max(haOPEN[period],haCLOSE[period]));
        haLOW[period] = math.min(source.low[period],math.min(haOPEN[period],haCLOSE[period]));
        if haOPEN[period] - haCLOSE[period] < 0 then
            haUPC[period] = haCLOSE[period];
            haUPO[period] = haOPEN[period];
        else
            haDNC[period] = haCLOSE[period];
            haDNO[period] = haOPEN[period];
        end

    end
end


