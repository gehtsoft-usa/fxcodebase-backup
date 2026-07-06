--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC |
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
    indicator:name("Gap Finder");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addColor("buy_color", "Buy Gap Color", "", core.colors().Green);
    indicator.parameters:addColor("sell_color", "Sell Gap Color", "", core.colors().Red);
end

local source, gaps, gaps_ends;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    instance:ownerDrawn(true);
    gaps = instance:addInternalStream(0, 0);
    gaps_ends = instance:addInternalStream(0, 0);
end

local gaps_count = 0;
function Update(period, mode)
    if period < 1 then
        return;
    end
    if source.open[period] ~= source.close[period - 1] then
        if gaps:getBookmark(gaps_count - 1) == -1 then
            gaps:setBookmark(gaps_count, period);
            gaps_count = gaps_count + 1;
        end
    end
    for i = 0, gaps_count - 1 do
        local index = gaps:getBookmark(i);
        if index > 0 then
            if source.open[index] > source.close[index] then
                if source.close[period] < source.open[index] then
                    gaps_ends:setBookmark(i, period);
                end
            else
                if source.close[period] > source.open[index] then
                    gaps_ends:setBookmark(i, period);
                end
            end
        end
    end
end

local init = false;
local buy_color, sell_color;
local buy_pen = 1;
local buy_brush = 2;
local sell_pen = 3;
local sell_brush = 4;

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(buy_pen, context.SOLID, 1, instance.parameters.buy_color);
        context:createPen(sell_pen, context.SOLID, 1, instance.parameters.sell_color);
        context:createSolidBrush(buy_brush, instance.parameters.buy_color)
        context:createSolidBrush(sell_brush, instance.parameters.sell_color)
    end
    for i = 0, gaps_count - 1 do
        local period = gaps:getBookmark(i);
        local end_period = gaps_ends:getBookmark(i);
        if end_period == -1 then
            end_period = source:size() - 1;
        end
        if period > 0 then
            local x1 = context:positionOfBar(period);
            local x2 = context:positionOfBar(end_period);
            local _, y1 = context:pointOfPrice(source.open[period]);
            local _, y2 = context:pointOfPrice(source.close[period - 1]);
            if source.open[period] > source.close[period] then
                context:drawRectangle(buy_pen, buy_brush, x1, y1, x2, y2)
            else
                context:drawRectangle(sell_pen, sell_brush, x1, y1, x2, y2)
            end
        end
    end
end