-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65661
-- Id: 20411

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------+
--|                                 Patreon : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Advance VWAP");
    indicator:description("Advance VWAP");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addBoolean("Show_Daily", "Show Daily", "", true);
    indicator.parameters:addColor("Daily_Color", "Color of Daily Line", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("Daily_width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Daily_style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Daily_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addBoolean("Show_Weekly", "Show Weekly", "", true);
    indicator.parameters:addColor("Weekly_color", "Color of Weekly Line", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Weekly_width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Weekly_style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Weekly_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addBoolean("Show_Monthly", "Show Monthly", "", true);
    indicator.parameters:addColor("Monthly_color", "Color of Monthly Line", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Monthly_width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Monthly_style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Monthly_style", core.FLAG_LINE_STYLE);
end

local Daily;
local Weekly;
local Monthly;
local WP;
local source;

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    WP = instance:addInternalStream(0, 0);
    if instance.parameters.Show_Daily then
        Daily = instance:addStream("Daily", core.Line, name, "Daily", instance.parameters.Daily_Color, 0);
        Daily:setWidth(instance.parameters.Daily_width);
        Daily:setStyle(instance.parameters.Daily_style);
    end
    if instance.parameters.Show_Weekly then
        Weekly = instance:addStream("Weekly", core.Line, name, "Weekly", instance.parameters.Weekly_color, 0);
        Weekly:setWidth(instance.parameters.Weekly_width);
        Weekly:setStyle(instance.parameters.Weekly_style);
    end
    if instance.parameters.Show_Monthly then
        Monthly = instance:addStream("Monthly", core.Line, name, "Monthly", instance.parameters.Monthly_color, 0);
        Monthly:setWidth(instance.parameters.Monthly_width);
        Monthly:setStyle(instance.parameters.Monthly_style);
    end
end

function CalcDaily(pos)
    local index = pos;
    local Sum1 = 0;
    local Sum2 = 0;
    local DT = core.dateToTable(source:date(pos)).day;
    while core.dateToTable(source:date(index)).day == DT and index > 0 do
        Sum1 = Sum1 + WP[index];
        Sum2 = Sum2 + source.volume[index];
        index = index - 1;
    end
    if Sum2 ~= 0 then
        return Sum1 / Sum2;
    else
        return 0;
    end
end

function CalcWeekly(pos)
    local index = pos - 1;
    local Sum1 = WP[pos];
    local Sum2 = source.volume[pos];
    while core.dateToTable(source:date(index - 1)).wday <= core.dateToTable(source:date(index)).wday and index > 1 do
        Sum1 = Sum1 + WP[index];
        Sum2 = Sum2 + source.volume[index];
        index = index - 1;
    end
    if Sum2 ~= 0 then
        return Sum1 / Sum2;
    else
        return 0;
    end
end

function CalcMonthly(pos)
    local index = pos;
    local Sum1 = 0;
    local Sum2 = 0;
    local DT = core.dateToTable(source:date(pos)).month;
    while core.dateToTable(source:date(index)).month == DT and index > 0 do
        Sum1 = Sum1 + WP[index];
        Sum2 = Sum2 + source.volume[index];
        index = index - 1;
    end
    if Sum2 ~= 0 then
        return Sum1 / Sum2;
    else
        return 0;
    end
end

function Update(period)
    WP[period] = source.volume[period] * (source.high[period] + source.low[period] + source.close[period]) / 3;
    if Daily ~= nil then
        Daily[period] = CalcDaily(period);
    end
    if Weekly ~= nil then
        Weekly[period] = CalcWeekly(period);
    end
    if Monthly ~= nil then
        Monthly[period] = CalcMonthly(period);
    end
end 
