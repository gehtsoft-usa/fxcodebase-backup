-- Id: 680
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1024

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- See http://en.wikipedia.org/wiki/Ultimate_Oscillator for details
function Init()
    indicator:name("Ultimate Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("S", "Short Period", "", 7);
    indicator.parameters:addInteger("M", "Medium Period", "", 14);
    indicator.parameters:addInteger("L", "Long Period", "", 28);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("O_color", "Oscillator Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local S;
local M;
local L;

local bp;
local tr;

local first;
local first1;
local source = nil;
local low, close, high;
local ks, km;

-- Streams block
local O = nil;

-- Routine
function Prepare(nameOnly)
    S = instance.parameters.S;
    M = instance.parameters.M;
    L = instance.parameters.L;

    assert(S < M and M < L, "Short must be smaller than medium, medium must be smaller than long");

    source = instance.source;
    low = source.low;
    close = source.close;
    high = source.high;
    first1 = source:first() + 1;
    ks = L / S;
    km = L / M;

    local name = profile:id() .. "(" .. source:name() .. ", " .. S .. ", " .. M .. ", " .. L .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    bp = instance:addInternalStream(0, 0);
    tr = instance:addInternalStream(0, 0);

    first = source:first() + L + 1;

    O = instance:addStream("O", core.Line, name, "O", instance.parameters.O_color, first);
    O:setPrecision(math.max(2, instance.source:getPrecision()));
	O:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	O:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    O:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);     
	
	O:setWidth(instance.parameters.width);
    O:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period)
    if period >= first1 then
        bp[period] = close[period] - math.min(low[period], close[period - 1]);
        tr[period] = math.max(high[period], close[period - 1]) - math.min(low[period], close[period - 1]);

        if period >= first then
            local r, ssb, sst, smb, smt, slb, slt, s, m, l;
            r = core.rangeTo(period, S);
            ssb = core.sum(bp, r);
            sst = core.sum(tr, r);
            s = ssb / sst;
            
            r = core.rangeTo(period, M);
            smb = core.sum(bp, r);
            smt = core.sum(tr, r);
            m = smb / smt;
            
            r = core.rangeTo(period, L);
            slb = core.sum(bp, r);
            slt = core.sum(tr, r);
            l = slb / slt;
            
            O[period] = 100 * (ks * s + km * m + l) / (ks + km + 1);
        end
    end
end

