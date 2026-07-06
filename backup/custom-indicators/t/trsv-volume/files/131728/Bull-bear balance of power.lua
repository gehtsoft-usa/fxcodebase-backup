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
    indicator:name("Bullish/Bearish Balance of Power");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addColor("bop_color", "Balance Of Power Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("bop_width", "Balance Of Power Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("bop_style", "Balance Of Power Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("bop_style", core.FLAG_LINE_STYLE);
end

local source, bop;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    bop = instance:addStream("BOP", core.Line, "BOP", "BOP", instance.parameters.bop_color, 0, 0);
    bop:setWidth(instance.parameters.bop_width);
    bop:setStyle(instance.parameters.bop_style);
end 

function Update(period, mode)
    if period < 1 then
        return;
    end
    local BullPower = 0;
    if source.close[period] < source.open[period] then
        if source.close[period - 1] < source.open[period] then
            BullPower = math.max(source.high[period] - source.close[period - 1], source.close[period] - source.low[period]);
        else
            BullPower = math.max(source.high[period] - source.open[period], source.close[period] - source.low[period]);
        end
    elseif source.close[period] > source.open[period] then
        if source.close[period - 1] > source.open[period] then
            BullPower = source.high[period] - source.low[period];
        else
            BullPower = math.max(source.open[period] - source.close[period - 1], source.high[period] - source.low[period]);
        end
    elseif source.high[period] - source.close[period] > source.close[period] - source.low[period] then
        if source.close[period - 1] < source.open[period] then
            BullPower = math.max(source.high[period] - source.close[period - 1], source.close[period] - source.low[period]);
        else
            BullPower = source.high[period] - source.open[period];
        end
    elseif source.high[period] - source.close[period] < source.close[period] - source.low[period] then
        if source.close[period - 1] > source.open[period] then
            BullPower = source.high[period] - source.low[period];
        else
            BullPower = math.max(source.open[period] - source.close[period - 1], source.high[period] - source.low[period]);
        end
    elseif source.close[period - 1] > source.open[period] then
        BullPower = math.max(source.high[period] - source.open[period], source.close[period] - source.low[period]);
    elseif source.close[period - 1] < source.open[period] then
        BullPower = math.max(source.open[period] - source.close[period - 1], source.high[period] - source.low[period]);
    else
        BullPower = source.high[period] - source.low[period];
    end

    local BearPower = 0;
    if source.close[period] < source.open[period] then
        if source.close[period - 1] > source.open[period] then
            BearPower = math.max(source.close[period - 1] - source.open[period], source.high[period] - source.low[period]);
        else
            BearPower = source.high[period] - source.low[period];
        end
    elseif source.close[period] > source.open[period] then
        if source.close[period - 1] > source.open[period] then
            BearPower = math.max(source.close[period - 1] - source.low[period], source.high[period] - source.close[period])
        else
            BearPower = math.max(source.open[period] - source.low[period], source.high[period] - source.close[period]) 
        end
    elseif source.high[period] - source.close[period] > source.close[period] - source.low[period] then
        if source.close[period - 1] < source.open[period] then
            BearPower = math.max(source.close[period] - source.open[period], source.high[period] - source.low[period])
        else
            BearPower = source.high[period] - source.low[period] 
        end
    elseif source.high[period] - source.close[period] < source.close[period] - source.low[period] then
        if source.close[period - 1] > source.open[period] then
            BearPower = math.max(source.close[period] - source.low[period], source.high[period] - source.close[period])
        else
            BearPower = source.open[period] - source.low[period] 
        end
    elseif source.close[period - 1] > source.open[period] then
        BearPower = math.max(source.close[period] - source.open[period], source.high[period] - source.low[period]) 
    elseif source.close[period - 1] < source.open[period] then
        BearPower = math.max(source.open[period] - source.low[period], source.high[period] - source.close[period])
    else
        BearPower = source.high[period] - source.low[period];
    end
    bop[period] = BullPower / BearPower;
end