-- Id: 51
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27

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
    indicator:name("Gator1");
    indicator:description("Median and SMMA-based version of the gator")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("JawN", "Number of periods for smoothing the alligator jaw", "", 13, 2, 1000);
    indicator.parameters:addInteger("JawS", "Number of periods for shifting the alligator jaw", "", 8, 1, 100);
    indicator.parameters:addInteger("TeethN", "Number of periods for smoothing the alligator teeth", "", 8, 2, 1000);
    indicator.parameters:addInteger("TeethS", "Number of periods for shifting the alligator teeth", "", 5, 1, 100);
    indicator.parameters:addInteger("LipsN", "Number of periods for smoothing the alligator lips", "", 5, 2, 1000);
    indicator.parameters:addInteger("LipsS", "Number of periods for shifting the alligator lips", "", 3, 1, 100);
    indicator.parameters:addString("MTH", "Smoothing method", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", "SMMA", "", "SMMA");
    indicator.parameters:addColor("CL_color", "Color for covering line", "Color for covering line", core.rgb(255, 255, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("GO_color", "Color for higher bars", "Color for higher bars", core.rgb(0, 255, 0));
    indicator.parameters:addColor("RO_color", "Color for lower bars", "Color for lower bars", core.rgb(255, 0, 0));

end

-- lines parameters
local JawN, JawS;
local TeethN, TeethS;
local LipsN, LipsC;

-- indicator source
local source;
local median;

-- alligator lines
local Jaw, Teeth, Lips;
-- alligator lines sources
local JawSrc, TeethSrc, LipsSrc;
-- gator bars
local Up, Down, UpRed, UpGreen, DownRed, DownGreen;
-- bar's parameters
local UpExtent, DownExtent;
local UpFirst, DownFirst;

-- process parameters and prepare for calculations
function Prepare(nameOnly)
    JawN = instance.parameters.JawN;
    JawS = instance.parameters.JawS;
    TeethN = instance.parameters.TeethN;
    TeethS = instance.parameters.TeethS;
    LipsN = instance.parameters.LipsN;
    LipsS = instance.parameters.LipsS;

    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. JawN .. "(" .. JawS .. ")," .. TeethN .. "(" .. TeethS .. ")," .. LipsN .. "(" .. LipsS .. "))";
    instance:name(name);
    if nameOnly then
        return;
    end

    median = instance:addInternalStream(source:first(), 0);

    assert(core.indicators:findIndicator(instance.parameters.MTH) ~= nil, instance.parameters.MTH .. " indicator must be installed");
    JawSrc = core.indicators:create(instance.parameters.MTH, median, JawN, core.rgb(0, 0, 0));
    TeethSrc = core.indicators:create(instance.parameters.MTH, median, TeethN, core.rgb(0, 0, 0));
    LipsSrc = core.indicators:create(instance.parameters.MTH, median, LipsN, core.rgb(0, 0, 0));

    Jaw = instance:addInternalStream(JawSrc.DATA:first() + JawS, JawS);
    Teeth = instance:addInternalStream(TeethSrc.DATA:first() + TeethS, TeethS);
    Lips = instance:addInternalStream(LipsSrc.DATA:first() + LipsS, LipsS);

    UpExtent = math.min(JawS, TeethS);
    UpFirst = math.max(Jaw:first(), Teeth:first());
    Up = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.CL_color, UpFirst, UpExtent);
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Up:addLevel(0);
	Up:setWidth(instance.parameters.width1);
    Up:setStyle(instance.parameters.style1);
    UpRed = instance:addStream("UPR", core.Bar, name .. ".UPR", "UPR", instance.parameters.RO_color, UpFirst, UpExtent);
    UpRed:setPrecision(math.max(2, instance.source:getPrecision()));
    UpGreen = instance:addStream("UPG", core.Bar, name .. ".UPG", "UPG", instance.parameters.GO_color, UpFirst, UpExtent);
    UpGreen:setPrecision(math.max(2, instance.source:getPrecision()));

    DownExtent = math.min(TeethS, LipsS);
    DownFirst = math.max(Teeth:first(), Lips:first());
    Down = instance:addStream("DOWN", core.Line, name .. ".DN", "DN", instance.parameters.CL_color, DownFirst, DownExtent);
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
	Down:setWidth(instance.parameters.width1);
    Down:setStyle(instance.parameters.style1);
    DownRed = instance:addStream("DNR", core.Bar, name .. ".DNR", "DNR", instance.parameters.RO_color, DownFirst, DownExtent);
    DownRed:setPrecision(math.max(2, instance.source:getPrecision()));
    DownGreen = instance:addStream("DNG", core.Bar, name .. ".DNG", "DNG", instance.parameters.GO_color, DownFirst, DownExtent);
    DownGreen:setPrecision(math.max(2, instance.source:getPrecision()));


end

-- Indicator calculation routine
function Update(period, mode)
    -- calculate alligator
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
    -- calculate gator
    if period >= UpFirst then
        Up[period + UpExtent] = math.abs(Jaw[period + UpExtent] - Teeth[period + UpExtent]);
        if period >= UpFirst + 1 then
            if Up[period + UpExtent] >= Up[period + UpExtent - 1] then
                UpGreen[period + UpExtent] = Up[period + UpExtent];
            else
                UpRed[period + UpExtent] = Up[period + UpExtent];
            end
        end
    end
    if period >= DownFirst then
        Down[period + DownExtent] = -math.abs(Teeth[period + DownExtent] - Lips[period + DownExtent]);
        if period >= DownFirst + 1 then
            if Down[period + DownExtent] >= Down[period + DownExtent - 1] then
                DownGreen[period + DownExtent] = Down[period + DownExtent];
            else
                DownRed[period + DownExtent] = Down[period + DownExtent];
            end
        end
    end
end
