-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69469

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

function Init()
    indicator:name("Candle Sentiment");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("BBLength", "BBLength", "", 10);
    indicator.parameters:addDouble("BBNumDevs", "BBNumDevs", "", 0.5);
    indicator.parameters:addInteger("AvgLength1", "AvgLength1", "", 4)
    indicator.parameters:addInteger("AvgLength2", "AvgLength2", "", 4)
    indicator.parameters:addInteger("BBILength", "BBILength", "", 60)
    indicator.parameters:addDouble("NumDevsUp", "NumDevsUp", "", 1.5)
    indicator.parameters:addDouble("NumDevsDn", "NumDevsDn", "", 1.5)

    indicator.parameters:addColor("index_color", "CCode Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("index_width", "CCode Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("index_style", "CCode Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("index_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("UpperBand_color", "UpperBand Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("UpperBand_width", "UpperBand Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("UpperBand_style", "UpperBand Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("UpperBand_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("LowerBand_color", "LowerBand Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("LowerBand_width", "LowerBand Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("LowerBand_style", "LowerBand Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("LowerBand_style", core.FLAG_LINE_STYLE);
end

local source, bb, bb_avg, Index, Avg, BBILength, NumDevsUp, NumDevsDn, index, UpperBand, LowerBand;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    BBILength = instance.parameters.BBILength;
    NumDevsUp = instance.parameters.NumDevsUp;
    NumDevsDn = instance.parameters.NumDevsDn;
    bb = core.indicators:create("BB", source, instance.parameters.BBLength, instance.parameters.BBNumDevs);
    bb_avg = core.indicators:create("MVA", bb.AL, instance.parameters.AvgLength1);
    Index = core.indicators:create("MVA", bb_avg.DATA, instance.parameters.AvgLength2);
    Avg = core.indicators:create("MVA", Index.DATA, instance.parameters.BBILength);

    index = instance:addStream("Index", core.Line, "CCode", "CCode", instance.parameters.index_color, 0, 0);
    index:setWidth(instance.parameters.index_width);
    index:setStyle(instance.parameters.index_style);

    UpperBand = instance:addStream("UpperBand", core.Line, "UpperBand", "UpperBand", instance.parameters.UpperBand_color, 0, 0);
    UpperBand:setWidth(instance.parameters.UpperBand_width);
    UpperBand:setStyle(instance.parameters.UpperBand_style);

    LowerBand = instance:addStream("LowerBand", core.Line, "LowerBand", "LowerBand", instance.parameters.LowerBand_color, 0, 0);
    LowerBand:setWidth(instance.parameters.LowerBand_width);
    LowerBand:setStyle(instance.parameters.LowerBand_style);
end

function Update(period, mode)
    bb:update(mode);
    bb_avg:update(mode);
    Index:update(mode);
    Avg:update(mode);
    index[period] = Index.DATA[period];
    if period < BBILength or not Index.DATA:hasData(period - BBILength) then
        return;
    end
    local SDev = mathex.stdev(Index.DATA, period - BBILength, period);
    UpperBand[period] = Avg.DATA[period] + NumDevsUp * SDev; 
    LowerBand[period] = Avg.DATA[period] - NumDevsDn * SDev;
end