-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=717

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

function Init()
    indicator:name("Dynamic Trend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 50);
    indicator.parameters:addDouble("P", "Percent", "", 15);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("L_color", "Color of the line", "Color of line", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrUP", "Up arrow color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down arrow color", "", core.COLOR_DOWNCANDLE);
	 indicator.parameters:addInteger("Size", "Size", "", 10);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local P;

local first;
local source = nil;
local Size;
-- Streams block
local L = nil;
local up, down;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    P = instance.parameters.P;
	Size= instance.parameters.Size;
    source = instance.source;
    first = source:first() + N + 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. P .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    L = instance:addStream("L", core.Line, name, "L", instance.parameters.L_color, first);
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local range = core.rangeTo(period - 1, N);
        local v, p, v1, p1;
        if period == first then
           v, p = core.min(source.close, range);
           L[period] = source.close[p] + P * source:pipSize();
        else
            if source.close[period] < L[period - 1] then
                v, p = core.max(source.close, range);
                L[period] = source.close[p] - P * source:pipSize();
            else
                v, p = core.min(source.close, range);
                L[period] = source.close[p] + P * source:pipSize();
            end
        end
    end
    if period >= first + 4 then
        if (core.crossesUnder(source.close, L, period - 2)) then
            up:set(period, source.high[period], "\226");
        end
        if (core.crossesOver(source.close, L, period - 2)) then
            down:set(period, source.low[period], "\225");
        end
    end
end

