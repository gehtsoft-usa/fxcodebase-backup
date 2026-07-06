-- Id: 4744
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7115

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

--100 * LOG10( SUM(ATR(1), x) / ( MaxHi(x) - MinLo(x) ) ) / LOG10(x)
--where x = Choppiness Period
--LOG10(x) is base-10 LOG of x
--ATR(1) is the True Range (Period of 1)
--SUM(ATR(1), x) is the Sum of the True Range over past x bars
--MaxHi(x) is the highest high over past x bars
--
--The Choppiness Index is designed to measure the market's trendiness
--(values below 38.20) versus the market's choppiness (values above
--61.80). When the indicator is reading values near 100, the market is
--considered to be in choppy consolidation. The lower the value of the
--Choppiness Index, the more the market is trending. The period supplied
--by the user dictates how many bars are used to compute the index.
--
--mjdesmond3001

function Init()
    indicator:name("Choppiness Index");
    indicator:description("The indicator measures the market's trendiness (below 38.20) versus the market's choppiness (values above 61.80)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("X", "Choppiness period (in bars)", "", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("C", "Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("W", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("S", "Style", "", 1, 1, core.LINE_SOLID);
    indicator.parameters:setFlag("S", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addGroup("Levels");
    indicator.parameters:addDouble("LOT", "Trend", "", 38.2, 0, 150);
    indicator.parameters:addDouble("LOC", "Choppy", "", 61.8, 0, 150);
    indicator.parameters:addDouble("LOC1", "Consolidation", "", 100, 0, 150);
    indicator.parameters:addBoolean("SLOC1", "Show Consolidation Level", "", false);
    indicator.parameters:addBoolean("SLOC0", "Show Zero Level", "", false);
    indicator.parameters:addColor("LC", "Color", "", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:addInteger("LW", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS", "Style", "", 1, 1, core.LINE_DOT);
    indicator.parameters:setFlag("LS", core.FLAG_LEVEL_STYLE);
end

local source;
local atr;
local first;
local x, l10x;
local out;

function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.X .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    source = instance.source;
    atr = core.indicators:create("ATR", source, 1);
    x = instance.parameters.X;
    l10x = math.log10(x);
    first = math.max(source:first() + x - 1, atr.DATA:first() + x - 1);
    out = instance:addStream("CHOP_IDX", core.Line, name, "CHOP_IDX", instance.parameters.C, first);
    out:setWidth(instance.parameters.W);
    out:setStyle(instance.parameters.S);

    if instance.parameters.SLOC0 then
        out:addLevel(0, core.LINE_NONE, 1, core.rgb(0, 0, 0));
    end
    out:addLevel(instance.parameters.LOT, instance.parameters.LS, instance.parameters.LW, instance.parameters.LC);
    out:addLevel(instance.parameters.LOC, instance.parameters.LS, instance.parameters.LW, instance.parameters.LC);
    if instance.parameters.SLOC1 then
        out:addLevel(instance.parameters.LOC1, instance.parameters.LS, instance.parameters.LW, instance.parameters.LC);
    end
	
	out:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    if period >= first then
        atr:update(mode);
        local ll, hh = core.minmax(source, period - x + 1, period);
        local s = core.sum(atr.DATA, period - x + 1, period);
        out[period] = 100.0 * math.log10(s / (hh - ll)) / l10x;
    end
end

