-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=604

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
    indicator:name("Time Price Opportunity Profile");
    indicator:description("The indicator calculates how often the price appears in the historical data");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 5);
    indicator.parameters:addInteger("Per", "Number of points", "Number of points (1 pt = 1/72 of inch) to display histogram", 50);
    indicator.parameters:addColor("S1", "Color", "", core.rgb(127, 127, 127));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local BoxSize;
local Per;
local TPO = {};
local source = nil;
local S1;
local first;

-- Routine
 function Prepare(nameOnly) 
    BoxSize = instance.parameters.BoxSize;
    Per = instance.parameters.Per;
    S1 = instance.parameters.S1;
    source = instance.source;
    first = source:first();
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. BoxSize .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    instance:addStream("H", core.Line, name .. ".H", "H", S1, 0, 20);
end

local prevDate = -1;
local max = 0;

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local date = source:date(period)
        if date < prevDate then
            TPO = {};
            max = 0;
        elseif date == prevDate then
            return ;
        end

        prevDate = date;

        local median;
        median = (source.high[period] + source.low[period] + source.close[period]) / 3;
        -- express in pips
        median = median / source:pipSize();
        median = median - median % BoxSize;
        local v = rawget(TPO, median);
        if v == nil then
            v = 0;
        end
        v = v + 1;
        if v > max then
            max = v;
        end
        local v = rawset(TPO, median, v);

        core.host:execute("removeAll");
        for k, v in pairs(TPO) do
            local length = v / max * Per;
            core.host:execute("drawLine", k, -2, k * source:pipSize(), length, k * source:pipSize(), S1);
        end
    end

end

