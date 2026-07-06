-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69807

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bars on tick chart");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addString("timeframe", "Timeframe", "", "m5");
    indicator.parameters:setFlag("timeframe", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", "Price type", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);

    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
end

local source, bar_source;
local tradingWeekOffset, tradingDayOffset;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    bar_source = core.host:execute("getHistory1", 1, source:instrument(), instance.parameters.timeframe, 300, 0, instance.parameters.type);
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local ASC_PEN = 1;
local DESC_PEN = 3;

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(ASC_PEN, context.SOLID, 1, instance.parameters.up_color);
        context:createPen(DESC_PEN, context.SOLID, 1, instance.parameters.down_color);
    end

    local from_date = source:date(math.max(source:first(), context:firstBar()));
    local to_date = source:date(math.min(context:lastBar(), source:size() - 1));

    local from_bar = math.max(0, core.findDate(bar_source, from_date, false));
    local to_bar = math.min(math.max(0, core.findDate(bar_source, to_date, false)), bar_source:size() - 1);
    for i = from_bar, to_bar, 1 do
        local s, e = core.getcandle(bar_source:barSize(), bar_source:date(i), tradingDayOffset, tradingWeekOffset);
        local start_tick = core.findDate(source, s, false);
        local end_tick = core.findDate(source, e, false);

        local x1 = context:positionOfBar(start_tick);
        local x2 = context:positionOfBar(end_tick);
        local x = (x2 + x1) / 2;

        local _, y_high = context:pointOfPrice(bar_source.high[i]);
        local _, y_low = context:pointOfPrice(bar_source.low[i]);
        local _, y_close = context:pointOfPrice(bar_source.close[i]);
        local _, y_open = context:pointOfPrice(bar_source.open[i]);
        if bar_source.close[i] > bar_source.open[i] then
            context:drawRectangle(ASC_PEN, -1, x1, y_close, x2, y_open);
            context:drawLine(ASC_PEN, x, y_close, x, y_high);
            context:drawLine(ASC_PEN, x, y_open, x, y_low);
        else
            context:drawRectangle(DESC_PEN, -1, x1, y_close, x2, y_open);
            context:drawLine(DESC_PEN, x, y_open, x, y_high);
            context:drawLine(DESC_PEN, x, y_close, x, y_low);
        end
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
end