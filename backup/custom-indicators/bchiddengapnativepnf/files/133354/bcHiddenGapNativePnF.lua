-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69764

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
    indicator:name("BC Hidden Gap Native PnF");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addColor("WRBup", "WRBup", "", core.colors().DeepSkyBlue);
    indicator.parameters:addColor("WRBdown", "WRBdown", "", core.colors().DarkMagenta);
    indicator.parameters:addColor("hiddenGapdown", "hiddenGapdown", "", core.colors().Magenta);
    indicator.parameters:addColor("hiddenGapup", "hiddenGapup", "", core.colors().Cyan);
    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
end

local source, o, h, o, c, v, WRBup, WRBdown, hiddenGapdown, hiddenGapup, flag;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    WRBup = instance.parameters.WRBup;
    WRBdown = instance.parameters.WRBdown;
    hiddenGapdown = instance.parameters.hiddenGapdown;
    hiddenGapup = instance.parameters.hiddenGapup;
    o = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), 0)
    h = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), 0)
    l = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), 0)
    c = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), 0)
    v = instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), 0)
    instance:createCandleGroup(source:name(), source:name(), o, h, l, c, v);
    flag = instance:addInternalStream(0, 0);

    instance:ownerDrawn(true);
end

function Update(period, mode)
    o[period] = source.open[period];
    h[period] = source.high[period];
    l[period] = source.low[period];
    c[period] = source.close[period];
    v[period] = source.volume[period];
    if (source.close[period] > source.open[period] 
        and math.abs(source.close[period] - source.open[period]) > math.abs(source.close[period - 1] - source.open[period - 1])
        and math.abs(source.close[period] - source.open[period]) > math.abs(source.close[period - 2] - source.open[period - 2])
        and math.abs(source.close[period] - source.open[period]) > math.abs(source.close[period - 3] - source.open[period - 3]))
    then
        o:setColor(period, WRBup);
    end
    if (source.low[period] > source.high[period - 2]
        and math.abs(source.close[period - 1] - source.open[period - 1]) > math.abs(source.close[period - 2] - source.open[period - 2])
        and math.abs(source.close[period - 1] - source.open[period - 1]) > math.abs(source.close[period - 3] - source.open[period - 3])
        and math.abs(source.close[period - 1] - source.open[period - 1]) > math.abs(source.close[period - 4] - source.open[period - 4]))
    then
        flag[period] = -1;
    end
    if (source.close[period] < source.open[period]
        and math.abs(source.close[period] - source.open[period]) > math.abs(source.close[period - 1] - source.open[period - 1])
        and math.abs(source.close[period] - source.open[period]) > math.abs(source.close[period - 2] - source.open[period - 2])
        and math.abs(source.close[period] - source.open[period]) > math.abs(source.close[period - 3] - source.open[period - 3]))
    then
        o:setColor(period, WRBdown);
    end
    if (source.high[period] < source.low[period - 2]
        and math.abs(source.close[period - 1] - source.open[period - 1]) > math.abs(source.close[period - 2] - source.open[period - 2])
        and math.abs(source.close[period - 1] - source.open[period - 1]) > math.abs(source.close[period - 3] - source.open[period - 3])
        and math.abs(source.close[period - 1] - source.open[period - 1]) > math.abs(source.close[period - 4] - source.open[period - 4]))	
    then
        flag[period] = 1;
    end
end

local init = false;
local UP_PEN = 1;
local UP_BRUSH = 2;
local DN_PEN = 3;
local DN_BRUSH = 4;
local transparency;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(UP_PEN, context.SOLID, 1, hiddenGapup);
        context:createSolidBrush(UP_BRUSH, hiddenGapup);
        context:createPen(DN_PEN, context.SOLID, 1, hiddenGapdown);
        context:createSolidBrush(DN_BRUSH, hiddenGapdown);
        transparency = context:convertTransparency(instance.parameters.transparency);
        init = true;
    end
    local from_bar = math.max(source:first(), context:firstBar());
    local to_bar = math.min(context:lastBar(), source:size() - 1);
    for i = from_bar, to_bar, 1 do
        if flag[i] == -1 then
            local x1 = context:positionOfBar(i);
            local x2 = context:positionOfBar(i - 2);
            local _, y1 = context:pointOfPrice(source.high[i - 2]);
            local _, y2 = context:pointOfPrice(source.low[i]);
            context:drawRectangle(UP_PEN, UP_BRUSH, x1, y1, x2, y2, transparency);
        elseif flag[i] == 1 then
            local x1 = context:positionOfBar(i);
            local x2 = context:positionOfBar(i - 2);
            local _, y1 = context:pointOfPrice(source.low[i - 2]);
            local _, y2 = context:pointOfPrice(source.high[i]);
            context:drawRectangle(DN_PEN, DN_BRUSH, x1, y1, x2, y2, transparency);
        end
    end
end