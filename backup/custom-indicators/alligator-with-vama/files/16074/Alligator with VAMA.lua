-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7186
-- Id: 4762

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- initializes the indicator
function Init()
    indicator:name("Alligator with VAMA");
    indicator:description("Bill Williams's moving average-based trading system.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("JawN", "Alligator Jaw smoothing periods", "", 13);
    indicator.parameters:addInteger("JawS", "Alligator Jaw shifting periods", "", 8);

    indicator.parameters:addInteger("TeethN", "Alligator Teeth smoothing periods", "", 8);
    indicator.parameters:addInteger("TeethS", "Alligator Teeth shifting periods","", 5);

    indicator.parameters:addInteger("LipsN", "Alligator Lips smoothing periods", "", 5);
    indicator.parameters:addInteger("LipsS", "Alligator Lips shifting periods", "", 3);

    indicator.parameters:addString("MTH", "Smoothing method", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", "REGRESSION", "", "REGRESSION");
    indicator.parameters:addStringAlternative("MTH", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("MTH", "VIDYA92", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MTH", "WMA", "", "WMA");
	indicator.parameters:addStringAlternative("MTH", "VAMA", "", "VAMA");
	

    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("JawC", "Alligator Jaw line color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("JawW", "Alligator Jaw line width", "", 1, 1, 5);
    indicator.parameters:addInteger("JawSt", "Alligator Jaw line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("JawSt", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("TeethC","Alligator Teeth line color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TeethW", "Alligator Teeth line width", "", 1, 1, 5);
    indicator.parameters:addInteger("TeethSt", "Alligator Teeth line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("TeethSt", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("LipsC", "Alligator Lips line color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("LipsW", "Alligator Lips line width", "", 1, 1, 5);
    indicator.parameters:addInteger("LipsSt", "Alligator Lips line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LipsSt", core.FLAG_LEVEL_STYLE);
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
local MTH;

-- process parameters and prepare for calculations
function Prepare(nameOnly)

    MTH= instance.parameters.MTH;
    assert(core.indicators:findIndicator(MTH) ~= nil, "Please download and install " .. MTH .. ".lua indicator");
    
    JawN = instance.parameters.JawN;
    JawS = instance.parameters.JawS;
    TeethN = instance.parameters.TeethN;
    TeethS = instance.parameters.TeethS;
    LipsN = instance.parameters.LipsN;
    LipsS = instance.parameters.LipsS;

    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. JawN .. "(" .. JawS .. ")," .. TeethN .. "(" .. TeethS .. ")," .. LipsN .. "(" .. LipsS .. "), " .. MTH .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

	if MTH == "VAMA" then
	JawSrc = core.indicators:create(MTH, source, JawN, "TYPICAL", core.rgb(0, 0, 0));
    TeethSrc = core.indicators:create(MTH, source, TeethN,"TYPICAL" , core.rgb(0, 0, 0));
    LipsSrc = core.indicators:create(MTH, source, LipsN, "TYPICAL" ,core.rgb(0, 0, 0));
	else
    JawSrc = core.indicators:create(MTH, source.median, JawN, core.rgb(0, 0, 0));
    TeethSrc = core.indicators:create(MTH, source.median, TeethN, core.rgb(0, 0, 0));
    LipsSrc = core.indicators:create(MTH, source.median, LipsN, core.rgb(0, 0, 0));
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

