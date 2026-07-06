
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69564

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
    indicator:name("Slow Stochastic With Devergences");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("K", "K Period", "", 5, 2, 1000);
    indicator.parameters:addInteger("D", "D Period", "", 3, 1, 1000);
    indicator.parameters:addInteger("SD", "D slowing periods", "", 3, 1, 1000);

    indicator.parameters:addDouble("os", "Oversold", "", 20)
    indicator.parameters:addDouble("ob", "Overbought", "", 80)
    
    indicator.parameters:addColor("K_color", "K Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("K_width", "K Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("K_style", "K Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("K_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("D_color", "D Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("D_width", "D Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("D_style", "D Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("D_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("divergence_color_up", "Up Divergence Line Color", "", core.colors().Green);
    indicator.parameters:addColor("divergence_color_down", "Down Divergence Line Color", "", core.colors().Red);
    indicator.parameters:addInteger("divergence_width", "Divergence Line Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("divergence_style", "Divergence Line Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("divergence_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("trace_color_up", "Up Divergence Trace Color", "", core.colors().Green);
    indicator.parameters:addColor("trace_color_down", "Down Divergence Trace Color", "", core.colors().Red);
    indicator.parameters:addInteger("trace_width", "Divergence Trace Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("trace_style", "Divergence Trace Style", "Style", core.LINE_DASH);
    indicator.parameters:setFlag("trace_style", core.FLAG_LINE_STYLE);
end

local source, K, D, ssd, os, ob;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    os = instance.parameters.os;
    ob = instance.parameters.ob;
    ssd = core.indicators:create("SSD", source, instance.parameters.K, instance.parameters.D, instance.parameters.SD);

    K = instance:addStream("K", core.Line, "K", "K", instance.parameters.K_color, ssd.K:first(), 0);
    K:setWidth(instance.parameters.K_width);
    K:setStyle(instance.parameters.K_style);

    D = instance:addStream("D", core.Line, "D", "D", instance.parameters.D_color, ssd.D:first(), 0);
    D:setWidth(instance.parameters.D_width);
    D:setStyle(instance.parameters.D_style);
    K:addLevel(os, core.LINE_SOLID, 1, core.colors().Yellow);
    K:addLevel(ob, core.LINE_SOLID, 1, core.colors().Yellow);

    instance:ownerDrawn(true);
end

function MarkPeaks(stream, period)
    if stream:first() > period - 2 then
        return;
    end
    if (stream[period] < stream[period - 1] and stream[period - 1] > stream[period - 2])
        or (stream[period] > stream[period - 1] and stream[period - 1] < stream[period - 2])
    then
        local i = 1;
        local curr = stream:getBookmark(i);
        if curr == period - 1 then
            return;
        end
        while curr ~= -1 do
            local prev = stream:getBookmark(i + 1);
            stream:setBookmark(i + 1, curr);
            curr = prev;
            i = i + 1;
        end
        stream:setBookmark(1, period - 1);
    else
        local i = 1;
        local curr = stream:getBookmark(i);
        if curr == period - 1 then
            while curr ~= -1 do
                curr = stream:getBookmark(i + 1);
                stream:setBookmark(i, curr);
                i = i + 1;
            end
        end
    end
end

function Update(period, mode)
    ssd:update(mode);
    K[period] = ssd.K[period];
    D[period] = ssd.D[period];
    MarkPeaks(D, period);
end

local init = false;
local TREND_LINE_PEN_UP = 1;
local TREND_LINE_PEN_DOWN = 2;
local TRACE_LINE_PEN_UP = 3;
local TRACE_LINE_PEN_DOWN = 4;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(TREND_LINE_PEN_UP, context:convertPenStyle(instance.parameters.divergence_style), instance.parameters.divergence_width, instance.parameters.divergence_color_up);
        context:createPen(TREND_LINE_PEN_DOWN, context:convertPenStyle(instance.parameters.divergence_style), instance.parameters.divergence_width, instance.parameters.divergence_color_down);
        context:createPen(TRACE_LINE_PEN_UP, context:convertPenStyle(instance.parameters.trace_style), instance.parameters.trace_width, instance.parameters.trace_color_up);
        context:createPen(TRACE_LINE_PEN_DOWN, context:convertPenStyle(instance.parameters.trace_style), instance.parameters.trace_width, instance.parameters.trace_color_down);
    end

    local i = 1;
    local curr = D:getBookmark(i);
    local prev1, prev2;
    while curr ~= -1 do
        i = i + 1;
        prev2 = prev1;
        prev1 = curr;
        curr = D:getBookmark(i);
        if prev2 ~= nil and curr ~= -1 then
            if D[curr] > ob and D[curr] > D[prev2] and D[curr - 1] < D[curr] and source.close[curr] < source.close[prev2] then
                local x1 = context:positionOfBar(curr);
                local x2 = context:positionOfBar(prev2);
                local y1 = context:top() + (context:bottom() - context:top()) * (context:maxPrice() - D[curr]) / (context:maxPrice() - context:minPrice());
                local y2 = context:top() + (context:bottom() - context:top()) * (context:maxPrice() - D[prev2]) / (context:maxPrice() - context:minPrice());
                context:drawLine(TREND_LINE_PEN_DOWN, x1, y1, x2, y2);
                local a = ((y2 - y1) / (x2 - x1));
                local c = (y1 - a * x1);
                context:drawLine(TRACE_LINE_PEN_DOWN, x2, y2, context:right(),  a * context:right() + c);
                return;
            elseif D[curr] < os and D[curr] < D[prev2] and D[curr - 1] > D[curr] and source.close[curr] > source.close[prev2] then
                local x1 = context:positionOfBar(curr);
                local x2 = context:positionOfBar(prev2);
                local y1 = context:top() + (context:bottom() - context:top()) * (context:maxPrice() - D[curr]) / (context:maxPrice() - context:minPrice());
                local y2 = context:top() + (context:bottom() - context:top()) * (context:maxPrice() - D[prev2]) / (context:maxPrice() - context:minPrice());
                context:drawLine(TREND_LINE_PEN_UP, x1, y1, x2, y2);
                local a = ((y2 - y1) / (x2 - x1));
                local c = (y1 - a * x1);
                context:drawLine(TRACE_LINE_PEN_UP, x2, y2, context:right(), a * context:right() + c);
                return;
            end
        end
    end
end