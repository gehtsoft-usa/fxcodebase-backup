-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69993

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
    indicator:name("Solo Super Trend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("atr_period", "ATR period", "", 14);
    indicator.parameters:addDouble("Factor", "Factor", "", 1.0);

    indicator.parameters:addColor("SOLOST_color", "SOLOST Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("SOLOST_width", "SOLOST Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("SOLOST_style", "SOLOST Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("SOLOST_style", core.FLAG_LINE_STYLE);
end

local source, atr, SOLOST, Factor;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Factor = instance.parameters.Factor;
    atr = core.indicators:create("ATR", source, instance.parameters.atr_period);
    SOLOST = instance:addStream("SOLOST", core.Line, "SOLOST", "SOLOST", instance.parameters.SOLOST_color, atr.DATA:first() + 1, 0);
    SOLOST:setWidth(instance.parameters.SOLOST_width);
    SOLOST:setStyle(instance.parameters.SOLOST_style);
end

function Update(period, mode)
    atr:update(mode);
    if period == 0 or not atr.DATA:hasData(period - 1) then
        return;
    end
    Up = source.close[period] - Factor * atr.DATA[period - 1];
    Dn = source.close[period] + Factor * atr.DATA[period - 1];
    if not SOLOST:hasData(period - 1) then
        SOLOST[period] = Up;
    elseif source.close[period - 1] > SOLOST[period - 1] then
        SOLOST[period] = math.max(Up, SOLOST[period - 1])
    else
        SOLOST[period] = math.min(SOLOST[period - 1], Dn);
    end
end