-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1975

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
    indicator:name("Alligator");
    indicator:description("Bill Williams's moving average-based trading system")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("JawN", "Number of periods for smoothing the alligator jaw", "", 13);
    indicator.parameters:addInteger("JawS", "Number of periods for shifting the alligator jaw", "", 8);

    indicator.parameters:addInteger("TeethN", "Number of periods for smoothing the alligator teeth", "", 8);
    indicator.parameters:addInteger("TeethS", "Number of periods for shifting the alligator teeth", "", 5);

    indicator.parameters:addInteger("LipsN", "Number of periods for smoothing the alligator lips", "", 5);
    indicator.parameters:addInteger("LipsS", "Number of periods for shifting the alligator lips", "", 3);

    indicator.parameters:addString("MTH", "Smoothing method", "The methods marked with (*) must be downloaded and installed", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", "SMMA(*)", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MTH", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MTH", "Wilders*", "", "WMA");

    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("JawC", "Color of the alligator jaw line", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("JawW", "Width of the alligator jaw line", "", 1, 1, 5);
    indicator.parameters:addInteger("JawSt", "Style of the alligator jaw line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("JawSt", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("TeethC", "Color of the alligator teeth line", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TeethW", "Width of the alligator teeth line", "", 1, 1, 5);
    indicator.parameters:addInteger("TeethSt", "Style of the alligator teeth line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("TeethSt", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("LipsC", "Color of the alligator lips line", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("LipsW", "Width of the alligator lips line", "", 1, 1, 5);
    indicator.parameters:addInteger("LipsSt", "Style of the alligator lips line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LipsSt", core.FLAG_LINE_STYLE);
end

-- lines parameters
local JawN, JawS;
local TeethN, TeethS;
local LipsN, LipsC;

-- indicator source
local source;

-- lines
local Jaw, Teeth, Lips;
-- lines sources
local JawSrc, TeethSrc, LipsSrc;

-- process parameters and prepare for calculations
function Prepare(nameOnly)
    assert(core.indicators:findIndicator(instance.parameters.MTH) ~= nil, "Please download and install " .. instance.parameters.MTH .. ".lua indicator");

    JawN = instance.parameters.JawN;
    JawS = instance.parameters.JawS;
    TeethN = instance.parameters.TeethN;
    TeethS = instance.parameters.TeethS;
    LipsN = instance.parameters.LipsN;
    LipsS = instance.parameters.LipsS;

    source = instance.source;
    JawSrc = core.indicators:create(instance.parameters.MTH, source.median, JawN, core.rgb(0, 0, 0));
    TeethSrc = core.indicators:create(instance.parameters.MTH, source.median, TeethN, core.rgb(0, 0, 0));
    LipsSrc = core.indicators:create(instance.parameters.MTH, source.median, LipsN, core.rgb(0, 0, 0));

    local name = profile:id() .. "(" .. source:name() .. ", " .. JawN .. "(" .. JawS .. ")," .. TeethN .. "(" .. TeethS .. ")," .. LipsN .. "(" .. LipsS .. "), " .. instance.parameters.MTH .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    Jaw = instance:addStream("Jaw", core.Line, name .. ".Jaw", "Jaw", instance.parameters.JawC, JawSrc.DATA:first() + JawS, JawS);
    Jaw:setWidth(instance.parameters.JawW);
    Jaw:setStyle(instance.parameters.JawSt);
    Teeth = instance:addStream("Teeth", core.Line, name .. ".Teeth", "Teeth", instance.parameters.TeethC, TeethSrc.DATA:first() + TeethS, TeethS);
    Teeth:setWidth(instance.parameters.TeethW);
    Teeth:setStyle(instance.parameters.TeethSt);
    Lips = instance:addStream("Lips", core.Line, name .. ".Lips", "Lips", instance.parameters.LipsC, LipsSrc.DATA:first() + LipsS, LipsS);
    Lips:setWidth(instance.parameters.LipsW);
    Lips:setStyle(instance.parameters.LipsSt);
end

-- Indicator calculation routine
function Update(period, mode)
    JawSrc:update(mode);
    TeethSrc:update(mode);
    LipsSrc:update(mode);

    if (period + JawS >= 0 and period >= JawSrc.DATA:first()) then
        Jaw[period + JawS] = JawSrc.DATA[period];
    end

    if (period + TeethS >= 0 and period >= TeethSrc.DATA:first()) then
        Teeth[period + TeethS] = TeethSrc.DATA[period];
    end

    if (period + LipsS >= 0 and period >= LipsSrc.DATA:first()) then
        Lips[period + LipsS] = LipsSrc.DATA[period];
    end
end
