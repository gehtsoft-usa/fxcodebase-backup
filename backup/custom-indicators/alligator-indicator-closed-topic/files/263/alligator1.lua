-- Id: 47
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- initializes the indicator
function Init()
    indicator:name("Alligator1");
    indicator:description("Median and SMMA-based version of the alligator")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("JawN", "Number of periods for smoothing the alligator jaw", "", 13);
    indicator.parameters:addInteger("JawS", "Number of periods for shifting the alligator jaw", "", 8);
    indicator.parameters:addColor("JawC", "Color of the the alligator jaw", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("TeethN", "Number of periods for smoothing the alligator teeth", "", 8);
    indicator.parameters:addInteger("TeethS", "Number of periods for shifting the alligator teeth", "", 5);
    indicator.parameters:addColor("TeethC", "Color of the the alligator teeth", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("LipsN", "Number of periods for smoothing the alligator lips", "", 5);
    indicator.parameters:addInteger("LipsS", "Number of periods for shifting the alligator lips", "", 3);
	
    indicator.parameters:addColor("LipsC", "Color of the the alligator lips", "", core.rgb(0, 255, 0));
    indicator.parameters:addString("MTH", "Smoothing method", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", "SMMA", "", "SMMA");
	
	indicator.parameters:addGroup("Style");
	
	indicator.parameters:addInteger("width1", "Jaw Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("width2", "Teeth Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("width3", "Lips Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- lines parameters
local JawN, JawS;
local TeethN, TeethS;
local LipsN, LipsC;

-- indicator source
local source;
local median;

-- lines
local Jaw, Teeth, Lips;
-- lines sources
local JawSrc, TeethSrc, LipsSrc;

-- process parameters and prepare for calculations
function Prepare()
    JawN = instance.parameters.JawN;
    JawS = instance.parameters.JawS;
    TeethN = instance.parameters.TeethN;
    TeethS = instance.parameters.TeethS;
    LipsN = instance.parameters.LipsN;
    LipsS = instance.parameters.LipsS;

    source = instance.source;
    median = instance:addInternalStream(source:first(), 0);

    assert(core.indicators:findIndicator(instance.parameters.MTH) ~= nil, instance.parameters.MTH .. " indicator must be installed");
    JawSrc = core.indicators:create(instance.parameters.MTH, median, JawN, core.rgb(0, 0, 0));
    TeethSrc = core.indicators:create(instance.parameters.MTH, median, TeethN, core.rgb(0, 0, 0));
    LipsSrc = core.indicators:create(instance.parameters.MTH, median, LipsN, core.rgb(0, 0, 0));

    local name = profile:id() .. "(" .. source:name() .. ", " .. JawN .. "(" .. JawS .. ")," .. TeethN .. "(" .. TeethS .. ")," .. LipsN .. "(" .. LipsS .. "))";
    instance:name(name);
    Jaw = instance:addStream("Jaw", core.Line, name .. ".Jaw", "Jaw", instance.parameters.JawC, JawSrc.DATA:first() + JawS, JawS);
    Teeth = instance:addStream("Teeth", core.Line, name .. ".Teeth", "Teeth", instance.parameters.TeethC, TeethSrc.DATA:first() + TeethS, TeethS);
    Lips = instance:addStream("Lips", core.Line, name .. ".Lips", "Lips", instance.parameters.LipsC, LipsSrc.DATA:first() + LipsS, LipsS);
	
	Jaw:setWidth(instance.parameters.width1);
	Jaw:setStyle(instance.parameters.style1);
	Teeth:setWidth(instance.parameters.width2);
	Teeth:setStyle(instance.parameters.style2);
	Lips:setWidth(instance.parameters.width3);
	Lips:setStyle(instance.parameters.style3);

end

-- Indicator calculation routine
function Update(period, mode)
    median[period] = (source.high[period] + source.low[period]) / 2;
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
