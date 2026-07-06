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
    indicator:name("Trend Breakout");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addColor("BreakoutL_color", "BreakoutL Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("BreakoutL_width", "BreakoutL Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("BreakoutL_style", "BreakoutL Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("BreakoutL_style", core.FLAG_LINE_STYLE);
end

local source, fractal, atr, BreakoutL, MaxAngle, TrendBreak;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    fractal = core.indicators:create("FRACTAL", source);
    atr = core.indicators:create("ATR", source, 7);

    MaxAngle = instance:addInternalStream(2, 0);
    TrendBreak = instance:addInternalStream(2, 0);
    BreakoutL = instance:addStream("BreakoutL", core.Line, "BreakoutL", "BreakoutL", instance.parameters.BreakoutL_color, 2, 0);
    BreakoutL:setWidth(instance.parameters.BreakoutL_width);
    BreakoutL:setStyle(instance.parameters.BreakoutL_style);
end

function FindFractal(period)
    for i = period - 2, 0, -1 do
        if fractal:getTextOutput(0):hasData(i) then
            return 1, i, source.high[i];
        elseif fractal:getTextOutput(1):hasData(i) then
            return -1, i, source.low[i];
        end
    end
    return 0;
end

function Update(period, mode)
    fractal:update(mode);
    atr:update(mode);
    if (period < 2) then
        return;
    end
    local trend, index, price = FindFractal(period);
    local Height, HeightB;
    if trend == 0 then
        return;
    elseif trend == 1 then
        Height = source.low[period] - price;
        HeightB = source.close[period] - price;
    else
        Height = price - source.high[period];
        HeightB = price - source.close[period];
    end
    TrendBreak[period] = TrendBreak[period - 1];
    if index == period - 2 then
        MaxAngle[period] = math.tan(2 / Height);
    else
        MaxAngle[period] = MaxAngle[period - 1];
        if trend == -1 then
            if (math.tan((period - index) / Height) > MaxAngle[period]) and (((source.close[period] < source.open[period]) or (source.close[period] < source.close[period - 1]))) then
                MaxAngle[period] = math.tan((period - index) / Height);
                TrendBreak[period] = 0
            end
            if TrendBreak[period] == 0 and (math.tan((period - index) / HeightB) > MaxAngle[period]) and source.close[period] > source.open[period] then
                TrendBreak[period] = 1
            elseif TrendBreak[period] == 1 and (math.tan((period - 1 - index) / HeightB) > MaxAngle[period]) and source.close[period] > source.close[period - 1] then
                TrendBreak[period] = 2;
            end
        else
            if (math.tan((period - index) / Height) > MaxAngle[period]) and (((source.close[period] > source.open[period]) or (source.close[period] > source.close[period - 1]))) then
                MaxAngle[period] = math.tan((period - index) / Height);
                TrendBreak[period] = 0;
            end
            if TrendBreak[period] == 0 and (math.tan((period - index) / HeightB) > MaxAngle[period]) and source.close[period] > source.open[period] then
                TrendBreak[period] = 1;
            elseif TrendBreak[period] == 1 and (math.tan(((period - 1) - index) / HeightB) > MaxAngle[period]) and source.close[period] < source.close[period - 1] then
                TrendBreak[period] = 2;
            end
        end
    end
        
    BreakoutL[period] = BreakoutL[period - 1];
    if TrendBreak[period] == 2 then
        if trend == -1 then
            local level = mathex.max(source, period - 2, period);
            BreakoutL[period] = level + atr.DATA[period] * 0.3;
        else
            local level = mathex.min(source, period - 2, period);
            BreakoutL[period] = level - atr.DATA[period] * 0.3;
        end
    end
end