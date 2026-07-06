-- Id: 19844
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65136

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("Previous Week Tails")
    indicator:description("Previous Week Tails")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100)
    indicator.parameters:addColor("D_Color", "Day Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("W_Color", "Week Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addBoolean("hist_mode", "Historical Mode", "", false)
end

local source = nil
local Period
local DaySource
local WeekSource
local loading1
local loading2
local transparency
local hist_mode

function Prepare(nameOnly)
    hist_mode = instance.parameters.hist_mode
    source = instance.source
    Period = instance.parameters.Period
    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    DaySource = core.host:execute("getSyncHistory", source:instrument(), "D1", true, 1, 2, 1)
    loading1 = true
    WeekSource = core.host:execute("getSyncHistory", source:instrument(), "W1", true, 2, 4, 3)
    loading2 = true

    instance:ownerDrawn(true)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local FLAG = false
    if cookie == 1 then
        loading1 = true
    elseif cookie == 2 then
        loading1 = false
    end

    if cookie == 3 then
        loading2 = true
    elseif cookie == 4 then
        loading2 = false
    end

    if loading1 or loading2 then
        FLAG = true
    end

    if not FLAG then
        instance:updateFrom(0)
    end

    return core.ASYNC_REDRAW
end

function Update(period)
end

local init = false

function DrawDayRect(context, period_shift)
    local date = DaySource:date(DaySource:size() - 1 - period_shift)
    local PreviousTradingDayClose = DaySource.close[DaySource.close:size() - 1 - 1 - period_shift]
    local PreviousTradingDayOpen = DaySource.open[DaySource.close:size() - 1 - 1 - period_shift]
    local PreviousTradingDayHigh = DaySource.high[DaySource.close:size() - 1 - 1 - period_shift]
    local visible, y1 = context:pointOfPrice(PreviousTradingDayHigh)
    local visible, y2 = context:pointOfPrice(math.max(PreviousTradingDayClose, PreviousTradingDayOpen))
    local daystart, dayend =
        core.getcandle("D1", date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"))
    local x1, x = context:positionOfDate(daystart)
    local x2, x = context:positionOfDate(dayend)
    context:drawRectangle(1, 2, x1, y1, x2, y2, transparency)
    return x1 > 0
end

function DrawWeekRect(context, period_shift)
    local date = WeekSource:date(WeekSource:size() - 1 - period_shift)
    local PreviousTradingWeekClose = WeekSource.close[WeekSource.close:size() - 1 - 1 - period_shift]
    local PreviousTradingWeekOpen = WeekSource.open[WeekSource.close:size() - 1 - 1 - period_shift]
    local PreviousTradingWeekLow = WeekSource.low[WeekSource.close:size() - 1 - 1 - period_shift]
    local visible, y1 = context:pointOfPrice(PreviousTradingWeekLow)
    local visible, y2 = context:pointOfPrice(math.min(PreviousTradingWeekClose, PreviousTradingWeekOpen))
    local weekstart, weekend =
        core.getcandle("W1", date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"))
    local x1, x = context:positionOfDate(weekstart)
    local x2, x = context:positionOfDate(weekend)
    context:drawRectangle(3, 4, x1, y1, x2, y2, transparency)
    return x1 > 0
end

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if loading1 or loading2 then
        return
    end

    if not init then
        context:createPen(1, context.SOLID, 3, instance.parameters.D_Color)
        context:createSolidBrush(2, instance.parameters.D_Color)
        context:createPen(3, context.SOLID, 3, instance.parameters.W_Color)
        context:createSolidBrush(4, instance.parameters.W_Color)
        transparency = context:convertTransparency(instance.parameters.transparency)
        init = true
    end

    if not hist_mode then
        DrawDayRect(context, 0)
        DrawWeekRect(context, 0)
    else
        local shift = 0
        while (DrawDayRect(context, shift)) do
            shift = shift + 1
        end
        shift = 0
        while (DrawWeekRect(context, shift)) do
            shift = shift + 1
        end
    end
end
