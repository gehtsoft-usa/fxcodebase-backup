-- Id: 490
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=848

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Schaff Trend Cycle Oscillator with smoothing method selector");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("C", "Schaff cycle periods", "", 10, 2, 10000);
    indicator.parameters:addInteger("S", "Short periods", "", 23, 2, 10000);
    indicator.parameters:addInteger("L", "Long periods", "", 50, 2, 10000);
    indicator.parameters:addString("M", "Smoothing method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "WMA");
    indicator.parameters:addStringAlternative("M", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("M", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("M", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("M", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("M", "Wilders*", "", "WMA");

    indicator.parameters:addColor("clrSCHTC", "Color of the line", "", core.rgb(0, 255, 0));
end

local firstmcd = 0;
local firstst = 0;
local first = 0;
local M = nil;
local S = 0;
local L = 0;
local C = 0;
local source = nil;
local out = nil;
local mas, mal, mast;
local st, mcd

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    S = instance.parameters.S;
    L = instance.parameters.L;
    C = instance.parameters.C;
    M = instance.parameters.M;

    assert(S < L, "Short Period Length must be less than Long Period Length");
    assert(C < L, "Cycle Periods must be less than Long Period Length");

    local name = profile:id() .. "(" .. source:name() .. "," .. C .. "," .. S .. "," .. L .. "," .. M .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator(M) ~= nil, M .. " indicator must be installed");
    mas = core.indicators:create(M, source, S);
    mal = core.indicators:create(M, source, L);

    firstmcd = mal.DATA:first();
    mcd = instance:addInternalStream(firstmcd, 0);
    firstst = firstmcd + C;
    st = instance:addInternalStream(firstst, 0);

    mast = core.indicators:create(M, st, C / 2);
    first = mast.DATA:first();
    out = instance:addStream("SCHTC", core.Line, name, "SCHTC", instance.parameters.clrSCHTC,  first)
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    out:addLevel(30);
    out:addLevel(70);
end

-- calculate the value
function Update(period, mode)
    if (period >= firstmcd) then
        mas:update(mode);
        mal:update(mode);
        mcd[period] = mas.DATA[period] - mal.DATA[period];
    end
    if (period >= firstst) then
        local lookback = core.rangeTo(period, C);
        local max = core.max(mcd, lookback);
        local min = core.min(mcd, lookback);
        st[period] = (mcd[period] - min) / (max - min) * 100;
    end
    if (period > first) then
        mast:update(mode);
        out[period] = mast.DATA[period];
    end
end

