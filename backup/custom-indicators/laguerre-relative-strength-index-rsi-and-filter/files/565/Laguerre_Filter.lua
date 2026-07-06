-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=331

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
function Init()
    indicator:name("John Ehlers Laguerre Filter ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("GAMMA", "Gamma", "", 0.7, -0.5, 1.05);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LF_color", "Color of LF", "Color of LF", core.rgb(255, 0, 128));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local GAMMA;

local first;
local source = nil;

-- Streams block
local LF = nil;
local L0;
local L1;
local L2;
local L3;


-- Routine
function Prepare(nameOnly)
    GAMMA = instance.parameters.GAMMA;
    source = instance.source;
    first = source:first() + 30;
    local name = profile:id() .. "(" .. source:name() .. ", " .. GAMMA .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LF = instance:addStream("LF", core.Line, name, "LF", instance.parameters.LF_color, first);
	LF:setWidth(instance.parameters.width);
    LF:setStyle(instance.parameters.style);
    L0 = instance:addInternalStream(0, 0);
    L1 = instance:addInternalStream(0, 0);
    L2 = instance:addInternalStream(0, 0);
    L3 = instance:addInternalStream(0, 0);
end

function calc(period)
   L0[period] = (1.0 - GAMMA) * (source.high[period] + source.low[period]) / 2 + GAMMA * L0[period - 1];
   L1[period] = -GAMMA * L0[period] + L0[period - 1] + GAMMA * L1[period - 1];
   L2[period] = -GAMMA * L1[period] + L1[period - 1] + GAMMA * L2[period - 1];
   L3[period] = -GAMMA * L2[period] + L2[period - 1] + GAMMA * L3[period - 1];
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        calc(period);
        LF[period] = (L0[period] + 2 * L1[period] + 2 * L2[period] + L3[period]) / 6;
    elseif period >= source:first() + 1 then
        calc(period);
    else
        L0[period] = 0;
        L1[period] = 0;
        L2[period] = 0;
        L3[period] = 0;
    end
end

