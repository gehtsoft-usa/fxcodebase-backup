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

function Init()
    indicator:name("Fibo 3 in 1");
    indicator:description("description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addDouble("level1", "Level 1", "", 0);
    indicator.parameters:addDouble("level2", "Level 2", "", 0.236);
    indicator.parameters:addDouble("level3", "Level 3", "", 0.382);
    indicator.parameters:addDouble("level4", "Level 4", "", 0.5);
    indicator.parameters:addDouble("level5", "Level 5", "", 0.618);
    indicator.parameters:addDouble("level6", "Level 6", "", 0.764);
    indicator.parameters:addDouble("level7", "Level 7", "", 1);
    indicator.parameters:addBoolean("invert", "Invert", "", false);
    indicator.parameters:addBoolean("show_monthly", "Show monthly", "", true);
    indicator.parameters:addBoolean("show_weekly", "Show weekly", "", true);
    indicator.parameters:addBoolean("show_daily", "Show daily", "", true)
    indicator.parameters:addColor("level1_color", "Level 1 color", "", core.colors().Red);
    indicator.parameters:addColor("level2_color", "Level 2 color", "", core.colors().Red);
    indicator.parameters:addColor("level3_color", "Level 3 color", "", core.colors().Red);
    indicator.parameters:addColor("level4_color", "Level 4 color", "", core.colors().Red);
    indicator.parameters:addColor("level5_color", "Level 5 color", "", core.colors().Red);
    indicator.parameters:addColor("level6_color", "Level 6 color", "", core.colors().Red);
    indicator.parameters:addColor("level7_color", "Level 7 color", "", core.colors().Red);
end

local source;
local levels = {}
local show_monthly, show_weekly, show_daily, tradingWeekOffset, tradingDayOffset
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    levels[1] = instance.parameters.level1;
    levels[2] = instance.parameters.level2;
    levels[3] = instance.parameters.level3;
    levels[4] = instance.parameters.level4;
    levels[5] = instance.parameters.level5;
    levels[6] = instance.parameters.level6;
    levels[7] = instance.parameters.level7;
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
function DrawFib(context, timeframe)
    local s, e = core.getcandle(timeframe, source:date(NOW), tradingDayOffset, tradingWeekOffset);
    local index = core.findDate(source, s, false);
    if index < 0 then
        return;
    end
    local x1 = context:positionOfDate(s);
    local x2 = context:positionOfDate(e);
    local low, high, lowpos, highpos = mathex.minmax(source, index, source:size() - 1);
    for i, level in ipairs(levels) do
        local value;
        if invert then
            value = high - (high - low) * level;
        else
            value = low + (high - low) * level;
        end
        local _, y = context:pointOfPrice(value)
        context:drawLine(i, x1, y, x2, y);
    end
end

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        invert = instance.parameters.invert;
        context:createPen(1, context.SOLID, 1, instance.parameters.level1_color);
        context:createPen(2, context.SOLID, 1, instance.parameters.level2_color);
        context:createPen(3, context.SOLID, 1, instance.parameters.level3_color);
        context:createPen(4, context.SOLID, 1, instance.parameters.level4_color);
        context:createPen(5, context.SOLID, 1, instance.parameters.level5_color);
        context:createPen(6, context.SOLID, 1, instance.parameters.level6_color);
        context:createPen(7, context.SOLID, 1, instance.parameters.level7_color);
        init = true;
    end
    DrawFib(context, "D1");
    DrawFib(context, "W1");
    DrawFib(context, "M1");
end