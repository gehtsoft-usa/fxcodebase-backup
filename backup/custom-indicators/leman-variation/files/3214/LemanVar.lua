-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1622
-- Id: 1117

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


-- LeMan's variation
-- Copyright � 2010, LeMan.
-- b-market@mail.ru
--
-- This port of Lua is made by ng

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("LeMan's Variation");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("N", "Number of periods to smooth the data", "", 20, 1, 1000);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("LV_color", "Color of the line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local first, firstV;
local source = nil;

-- Streams block
local V = nil;
local LV = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    firstV = source:first() + N;
    V = instance:addInternalStream(firstV, 0);
    first = V:first() + N;
    LV = instance:addStream("LV", core.Line, name, "LV", instance.parameters.LV_color, first);
    LV:setPrecision(math.max(2, instance.source:getPrecision()));
	LV:setWidth(instance.parameters.width);
    LV:setStyle(instance.parameters.style);

    LV:addLevel(0);
end

-- Indicator calculation routine
function Update(period, mode)
    local p, ma;
    if period >= firstV then
        p = core.rangeTo(period, N);
        ma = core.avg(source, p);
        V[period] = source[period] - ma;
        if period >= first then
            LV[period] = source[period] - (ma + core.avg(V, p));
        end
    end
end

