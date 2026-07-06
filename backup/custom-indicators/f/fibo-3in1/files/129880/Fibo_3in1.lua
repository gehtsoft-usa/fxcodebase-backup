-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69127

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function AddLevelStyle(id)
    indicator.parameters:addColor("level" .. id .. "_color", "Level " .. id .. " color", "", core.colors().Red);
end

function Init()
    indicator:name("Fibo 3 in 1");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addDouble("level1", "Level 1", "", 0);
    indicator.parameters:addDouble("level2", "Level 2", "", 0.236);
    indicator.parameters:addDouble("level3", "Level 3", "", 0.382);
    indicator.parameters:addDouble("level4", "Level 4", "", 0.5);
    indicator.parameters:addDouble("level5", "Level 5", "", 0.618);
    indicator.parameters:addDouble("level6", "Level 6", "", 0.764);
    indicator.parameters:addDouble("level7", "Level 7", "", 1);
    indicator.parameters:addDouble("level8", "Level 8", "", 1.272);
    indicator.parameters:addDouble("level9", "Level 9", "", 1.618);
    indicator.parameters:addDouble("level10", "Level 10", "", -0.272);
    indicator.parameters:addDouble("level11", "Level 11", "", -0.382);
    indicator.parameters:addDouble("level12", "Level 12", "", -0.618);
    indicator.parameters:addBoolean("invert", "Invert", "", false);
    indicator.parameters:addBoolean("show_monthly", "Show monthly", "", true);
    indicator.parameters:addInteger("periods_shift_monthly", "Monthly periods shift", "", 0);
    indicator.parameters:addBoolean("show_weekly", "Show weekly", "", true);
    indicator.parameters:addInteger("periods_shift_weekly", "Weekly periods shift", "", 0);
    indicator.parameters:addBoolean("show_daily", "Show daily", "", true)
    indicator.parameters:addInteger("periods_shift_daily", "Daily periods shift", "", 0);
    AddLevelStyle(1);
    AddLevelStyle(2);
    AddLevelStyle(3);
    AddLevelStyle(4);
    AddLevelStyle(5);
    AddLevelStyle(6);
    AddLevelStyle(7);
    AddLevelStyle(8);
    AddLevelStyle(9);
    AddLevelStyle(10);
    AddLevelStyle(11);
    AddLevelStyle(12);
    indicator.parameters:addInteger("monthly_width", "Monthly Width", "", 1, 1, 5);
    indicator.parameters:addInteger("monthly_style", "Monthly Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("monthly_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("weekly_width", "Weekly Width", "", 1, 1, 5);
    indicator.parameters:addInteger("weekly_style", "Weekly Style", "", core.LINE_DASHDOT);
    indicator.parameters:setFlag("weekly_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("daily_width", "Daily Width", "", 1, 1, 5);
    indicator.parameters:addInteger("daily_style", "Daily Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("daily_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addBoolean("extend_to_end", "Extend to end", "", false);
    indicator.parameters:addBoolean("show_price", "Show price", "", false);
    indicator.parameters:addBoolean("show_level", "Show level", "", false);
end
local source;
local levels = {}
local show_monthly, show_weekly, show_daily, tradingWeekOffset, tradingDayOffset, 
    periods_shift_monthly, periods_shift_weekly, periods_shift_daily;
local extend_to_end;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    periods_shift_monthly = instance.parameters.periods_shift_monthly;
    periods_shift_weekly = instance.parameters.periods_shift_weekly;
    periods_shift_daily = instance.parameters.periods_shift_daily;
    extend_to_end = instance.parameters.extend_to_end;
    for i = 1, 12 do
        levels[i] = instance.parameters:getDouble("level" .. i);
    end

    show_monthly = instance.parameters.show_monthly;
    show_weekly = instance.parameters.show_weekly;
    show_daily = instance.parameters.show_daily;
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    instance:ownerDrawn(true)
end

function Update(period, mode)
end

local init = false;
local pens = {};
local invert;
local font_id;
local show_price, show_level;
function DrawFib(context, timeframe, shift, style_shift)
    local s, e = core.getcandle(timeframe, source:date(NOW), tradingDayOffset, tradingWeekOffset);
    local diff = (e - s) * shift;
    s = s - diff;
    e = e - diff;
    local index = core.findDate(source, s, false);
    if index < 0 then
        return;
    end
    local x1 = context:positionOfDate(s);
    local x2 = extend_to_end and context:right() or context:positionOfDate(e);
    local low, high, lowpos, highpos = mathex.minmax(source, index, source:size() - 1);
    for i, level in ipairs(levels) do
        local value;
        if invert then
            value = high - (high - low) * level;
        else
            value = low + (high - low) * level;
        end
        local _, y = context:pointOfPrice(value)
        context:drawLine(#levels * style_shift + i, x1, y, x2, y);

        local text = "";
        if show_price then
            text = win32.formatNumber(value, false, source:getPrecision());
        end
        if show_level then
            if text ~= "" then
                text = text .. "; ";
            end
            text = text .. win32.formatNumber(level, false, 3);
        end
        if text ~= "" then
            local w, h = context:measureText(font_id, text, 0);
            context:drawText(font_id, text, core.COLOR_LABEL, -1, x2 - w, y - h, x2, y, 0);
        end
    end
end

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        invert = instance.parameters.invert;
        show_price = instance.parameters.show_price;
        show_level = instance.parameters.show_level;
        for i, v in ipairs(levels) do
            context:createPen(i, context:convertPenStyle(instance.parameters:getInteger("monthly_style")), 
                instance.parameters:getInteger("monthly_width"), 
                instance.parameters:getColor("level" .. i .. "_color"));
            context:createPen(#levels + i, context:convertPenStyle(instance.parameters:getInteger("weekly_style")), 
                instance.parameters:getInteger("monthly_width"), 
                instance.parameters:getColor("level" .. i .. "_color"));
            context:createPen(#levels * 2 + i, context:convertPenStyle(instance.parameters:getInteger("daily_style")), 
                instance.parameters:getInteger("monthly_width"), 
                instance.parameters:getColor("level" .. i .. "_color"));
        end
        font_id = #levels * 3 + 1;
        context:createFont(font_id, "Arial", 0, context:pointsToPixels(12), 0);
        init = true;
    end
    if show_monthly then
        DrawFib(context, "M1", periods_shift_monthly, 0);
    end
    if show_weekly then
        DrawFib(context, "W1", periods_shift_weekly, 1);
    end
    if show_daily then
        DrawFib(context, "D1", periods_shift_daily, 2);
    end
end