-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68332

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Candle day indicator")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("size", "Marks size", "", 8);
    indicator.parameters:addBoolean("day_mark", "Show day mark", "", true);
    indicator.parameters:addInteger("day_symbol", "Day Symbol", "", 117);
    indicator.parameters:addColor("day_color", "Day Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addBoolean("week_mark", "Show week mark", "", true);
    indicator.parameters:addInteger("week_symbol", "Week Symbol", "", 117);
    indicator.parameters:addColor("week_color", "Week Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addBoolean("month_mark", "Show month mark", "", true);
    indicator.parameters:addInteger("month_symbol", "Month Symbol", "", 117);
    indicator.parameters:addColor("month_color", "Month Color", "", core.rgb(0, 0, 255));
end

local source;
local day, week, month;
local day_symbol, week_symbol, month_symbol;
local day_offset, week_offset;
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end
    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");
    source = instance.source;
    if instance.parameters.day_mark then
        day = instance:createTextOutput("Day", "Day", "Wingdings", instance.parameters.size, core.H_Center, core.V_Bottom, instance.parameters.day_color, 0);
        day_symbol = string.char(instance.parameters:getInteger("day_symbol"));
    end

    if instance.parameters.week_mark then
        week = instance:createTextOutput("Week", "Week", "Wingdings", instance.parameters.size, core.H_Center, core.V_Bottom, instance.parameters.week_color, 0);
        week_symbol = string.char(instance.parameters:getInteger("week_symbol"));
    end

    if instance.parameters.month_mark then
        month = instance:createTextOutput("Month", "Month", "Wingdings", instance.parameters.size, core.H_Center, core.V_Bottom, instance.parameters.month_color, 0);
        month_symbol = string.char(instance.parameters:getInteger("month_symbol"));
    end
end

function Update(period, mode)
    if period == 0 then
        return;
    end
    if day_symbol ~= nil then
        local s1 = core.getcandle("D1", source:date(period), day_offset, week_offset);
        local s2 = core.getcandle("D1", source:date(period - 1), day_offset, week_offset);
        if s1 ~= s2 then
            day:set(period, source.high[period], day_symbol);
        end
    end
    if week_symbol ~= nil then
        local s1 = core.getcandle("W1", source:date(period), day_offset, week_offset);
        local s2 = core.getcandle("W1", source:date(period - 1), day_offset, week_offset);
        if s1 ~= s2 then
            week:set(period, source.high[period], week_symbol);
        end
    end
    if month_symbol ~= nil then
        local s1 = core.getcandle("M1", source:date(period), day_offset, week_offset);
        local s2 = core.getcandle("M1", source:date(period - 1), day_offset, week_offset);
        if s1 ~= s2 then
            month:set(period, source.high[period], month_symbol);
        end
    end
end
