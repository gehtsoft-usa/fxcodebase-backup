-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70390

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
    indicator.parameters:addStringAlternative(id, "Regression", "", "REGRESSION");
end
function CreateAverages(period, method, source)
    if method == "MVA" or method == "EMA" or method == "ARSI"
       or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA" or method == "REGRESSION"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function Init()
    indicator:name("SC Volatility Band");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("VolatilityBand", "Volatility", "", true)
    indicator.parameters:addInteger("BandsPeriod", "Bands Average Bars", "", 20);
    indicator.parameters:addDouble("BandsDeviation", "Bands Volatility Range", "", 2.4);
    indicator.parameters:addDouble("LowbandAdjust", "Low Band Adjust (Vol. Band Only)", "", 0.9);
    indicator.parameters:addInteger("MiddleLine_period", "Middle Line Period", "", 21);
    AddAverages("MiddleLine_method", "Middle Line Method", "MVA");

    indicator.parameters:addColor("high_color", "Channel High Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("high_width", "Channel High Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("high_style", "Channel High Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("high_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("low_color", "Channel Low Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("low_width", "Channel Low Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("low_style", "Channel Low Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("low_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("median_color", "Channel Median Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("median_width", "Channel Median Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("median_style", "Channel Median Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("median_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MedianAverage_color", "MedianAverage Color", "Color", core.colors().Pink);
    indicator.parameters:addInteger("MedianAverage_width", "MedianAverage Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("MedianAverage_style", "MedianAverage Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("MedianAverage_style", core.FLAG_LINE_STYLE);
end

local source, HighChannel, LowChannel, MedianAverage, TempBuf, VolatilityBand, AtrBuf, BandsDeviation, ma, LowbandAdjust, MiddleLine;
local VolatilityBand, bb;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    LowbandAdjust = instance.parameters.LowbandAdjust;
    BandsDeviation = instance.parameters.BandsDeviation;
    VolatilityBand = instance.parameters.VolatilityBand;
    HighChannel = instance:addStream("High", core.Line, "High", "High", instance.parameters.high_color, 0, 0);
    HighChannel:setWidth(instance.parameters.high_width);
    HighChannel:setStyle(instance.parameters.high_style);
    LowChannel = instance:addStream("Low", core.Line, "Low", "Low", instance.parameters.low_color, 0, 0);
    LowChannel:setWidth(instance.parameters.low_width);
    LowChannel:setStyle(instance.parameters.low_style);
    MedianAverage = instance:addStream("Median", core.Line, "Median", "Median", instance.parameters.median_color, 0, 0);
    MedianAverage:setWidth(instance.parameters.median_width);
    MedianAverage:setStyle(instance.parameters.median_style);
    TempBuf = instance:addInternalStream(0, 0);
    if VolatilityBand then
        AtrBuf = core.indicators:create("MVA", TempBuf, instance.parameters.BandsPeriod * 2 - 1);
        ma = core.indicators:create("LWMA", source.close, instance.parameters.BandsPeriod);
    else
        bb = core.indicators:create("BB", source, instance.parameters.BandsPeriod, instance.parameters.BandsDeviation)
    end
    MiddleLine = CreateAverages(instance.parameters.MiddleLine_period, instance.parameters.MiddleLine_method, source);
end

function Update(period, mode)
    if VolatilityBand then
        if period == 0 then
            TempBuf[period] = source.high[period] - source.low[period];
        else
            TempBuf[period] = math.max(source.high[period], source.close[period - 1]) - math.min(source.low[period], source.close[period - 1]);
        end
        AtrBuf:update(mode);
        ma:update(mode);
        MiddleLine:update(mode);
        MedianAverage[period] = MiddleLine.DATA[period];
        atr = AtrBuf.DATA[period] * BandsDeviation;
        HighChannel[period] = ma.DATA[period] + ma.DATA[period] * atr / source.close[period];
        LowChannel[period] = ma.DATA[period] - ma.DATA[period] * atr * LowbandAdjust / source.close[period];
    else
        bb:update(mode);
        MiddleLine:update(mode);
        MedianAverage[period] = MiddleLine.DATA[period];
        HighChannel[period] = bb.TL[period];
        LowChannel[period] = bb.BL[period];
    end
end