-- Id: 24020
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2640

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
    indicator:name("Market Profile")
    indicator:description("Market Profile")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("Method1", "Profile Period", "Daily", "D1")
    indicator.parameters:addStringAlternative("Method1", "Daily", "", "D1")
    indicator.parameters:addStringAlternative("Method1", "Weekly", "", "W1")
    indicator.parameters:addStringAlternative("Method1", "Monthly", "", "M1")
    indicator.parameters:addStringAlternative("Method1", "Yearly", "", "Y1")
    indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 2)
    indicator.parameters:addInteger("Val", "Value Area Percentage", "", 70)
    indicator.parameters:addBoolean("Hide", "Hide TPO", "", false)
    indicator.parameters:addBoolean("HideCom", "Hide TPO Comments", "", true)
    indicator.parameters:addBoolean("LAST", "Show Only Last Period", "", false)
    indicator.parameters:addInteger("Multi", "Coeff profile Lenght", "", 10)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("POC_color", "POC Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("Size", "Font Size", "", 3)
    indicator.parameters:addColor("VA_color", "VA Color", "", core.rgb(127, 127, 127))
    indicator.parameters:addInteger("VA_transp", "VA transparency, %", "", 50, 0, 100)
    indicator.parameters:addColor("label_color", "Label Color", "", core.rgb(127, 127, 127))
    indicator.parameters:addColor("profile_color", "Profile Color", "", core.rgb(255, 127, 127))
    indicator.parameters:addBoolean("Rainbow", "Rainbow Effect", "", true)
    indicator.parameters:addColor("Pen_color", "Pen Profile Color", "", core.rgb(0, 0, 0))
    indicator.parameters:addInteger("transp", "Profile Transparency", "", 92, 0, 100)
    indicator.parameters:addString("StartTime", "Start Time for Trading", "", "09:00:00")
end

local Size
local AA
local BoxSize
local Multi
local source
local first
local Hide
local Value
local s
local e
local ValueArea
local BOX
local day_offset, week_offset
local LAST
local PocMark
local POC_color
local BarSize

local vah
local val
local fDebug = nil
local filename = "Debug_MP.txt"
local debug_curv = false
local time_shift;

-- Routine
function Prepare(nameOnly)
    fDebug = assert(io.open(filename, "w"))
    fDebug:write("Prepare: MP V2.1\n")
    fDebug:close()
    Value = instance.parameters.Val
    BoxSize = instance.parameters.BoxSize
    Multi = instance.parameters.Multi
    Hide = instance.parameters.Hide
    HideCom = instance.parameters.HideCom
    Rainbow = instance.parameters.Rainbow
    Size = instance.parameters.Size
    LAST = instance.parameters.LAST
    method1 = instance.parameters.method1

    source = instance.source
    first = source:first()

    BOX = BoxSize * source:pipSize()

    local name = profile:id() .. "(" .. source:name() .. ", " .. BoxSize .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    day_offset = core.host:execute("getTradingDayOffset")
    week_offset = core.host:execute("getTradingWeekOffset")

    local valid
    OpenTime, valid = ParseTime(instance.parameters.StartTime)
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")
    instance:ownerDrawn(true)
    now = core.host:execute("getServerTime")
    now = now - math.floor(now)
    fDebug = io.open(filename, "a+")
    fDebug:write("DRAW_DATA: -------------------------------------\n")
    fDebug:write("DRAW_DATA: t=" .. OpenTime .. " " .. now .. "\n")
    fDebug:close()

    vah = instance:addStream("VAH", core.Line, "VAH", "VAH", instance.parameters.VA_color, 0)
    val = instance:addStream("VAL", core.Line, "VAL", "VAL", instance.parameters.VA_color, 0)

    instance:createChannelGroup("VA", "VA", vah, val, instance.parameters.VA_color, instance.parameters.VA_transp)

    PocMark =
        instance:createTextOutput(
        "POC",
        "POC",
        "Wingdings",
        Size,
        core.H_Center,
        core.V_Center,
        instance.parameters.POC_color,
        0
    )
    local s1, e2
    s1, e2 = core.getcandle(source:barSize(), core.now(), 0, 0)
    BarSize = e2 - s1

    local valid
    OpenTime, valid = ParseTime(instance.parameters.StartTime)
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")
    instance:ownerDrawn(true)
end
function ParseTime(time)
    local Pos = string.find(time, ":")
    local h = tonumber(string.sub(time, 1, Pos - 1))
    time = string.sub(time, Pos + 1)
    Pos = string.find(time, ":")
    local m = tonumber(string.sub(time, 1, Pos - 1))
    local s = tonumber(string.sub(time, Pos + 1))
    return (h / 24.0 + m / 1440.0 + s / 86400.0), ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or -- time in ole format
        (h == 24 and m == 0 and s == 0)) -- validity flag
end
local init = false
local FONT = 1
local label_color
local profile_color
local Pen_color
local PEN = 1
local BRUSH = 3
local transp
local dates = {}

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        label_color = instance.parameters.label_color
        profile_color = instance.parameters.profile_color
        Pen_color = instance.parameters.Pen_color
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(10), 0)
        context:createPen(PEN, context.SOLID, 0.5, Pen_color)
        context:createSolidBrush(BRUSH, profile_color)
        transp = context:convertTransparency(instance.parameters.transp)
        init = true
    end
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

    for _, data in pairs(dates) do
        local start_x = context:positionOfDate(source:date(data.start))
        local finish_x = context:positionOfDate(source:date(data.finish))
        for count, profile in ipairs(data.Profile) do
            local text
            if count == data.POC then
                text = "(" .. profile .. ")"
            else
                text = profile
            end
            local _, y = context:pointOfPrice(data.min + count * BOX)
            local _, y_next = context:pointOfPrice(data.min + (count + 1) * BOX)
            if text ~= nil then
                local x = context:positionOfDate(source:date(data.start) - BarSize)
                local width, height = context:measureText(FONT, tostring(text), 0)
                context:drawText(FONT, tostring(text), label_color, -1, x - width, y - height, x, y, 0)
            end

            if not Hide and profile > 0 then
                local coeff = profile * Multi / data.Total
                context:drawRectangle(PEN, BRUSH, start_x, y, start_x + (finish_x - start_x) * coeff, y_next, transp)
            end
            if Rainbow then
                if not Hide and profile > 5 then
                    profile_color = core.rgb(43, 226, 240)
                    context:createSolidBrush(BRUSH, profile_color)
                    local coeff = profile * Multi / data.Total
                    context:drawRectangle(
                        PEN,
                        BRUSH,
                        start_x,
                        y,
                        start_x + (finish_x - start_x) * coeff,
                        y_next,
                        transp
                    )
                end
                if not Hide and profile > 10 then
                    profile_color = core.rgb(28, 255, 128)
                    context:createSolidBrush(BRUSH, profile_color)
                    local coeff = profile * Multi / data.Total
                    context:drawRectangle(
                        PEN,
                        BRUSH,
                        start_x,
                        y,
                        start_x + (finish_x - start_x) * coeff,
                        y_next,
                        transp
                    )
                end
                if not Hide and profile > 20 then
                    profile_color = core.rgb(28, 255, 255)
                    context:createSolidBrush(BRUSH, profile_color)
                    local coeff = profile * Multi / data.Total
                    context:drawRectangle(
                        PEN,
                        BRUSH,
                        start_x,
                        y,
                        start_x + (finish_x - start_x) * coeff,
                        y_next,
                        transp
                    )
                end
                if not Hide and profile > 30 then
                    profile_color = core.rgb(128, 128, 128)
                    context:createSolidBrush(BRUSH, profile_color)
                    local coeff = profile * Multi / data.Total
                    context:drawRectangle(
                        PEN,
                        BRUSH,
                        start_x,
                        y,
                        start_x + (finish_x - start_x) * coeff,
                        y_next,
                        transp
                    )
                end
                if not Hide and profile > 50 then
                    profile_color = core.rgb(128, 128, 255)
                    context:createSolidBrush(BRUSH, profile_color)
                    local coeff = profile * Multi / data.Total
                    context:drawRectangle(
                        PEN,
                        BRUSH,
                        start_x,
                        y,
                        start_x + (finish_x - start_x) * coeff,
                        y_next,
                        transp
                    )
                end
                if not Hide and profile > 60 then
                    profile_color = core.rgb(255, 0, 0)
                    context:createSolidBrush(BRUSH, profile_color)
                    local coeff = profile * Multi / data.Total
                    context:drawRectangle(
                        PEN,
                        BRUSH,
                        start_x,
                        y,
                        start_x + (finish_x - start_x) * coeff,
                        y_next,
                        transp
                    )
                end
            end
        end
        if not HideCom then
            local text =
                " TSO Count (" ..
                data.Total ..
                    "), Value Area(" ..
                        data.ValueArea .. "), Last TSO " .. "(.)" .. ", POC (" .. data.min + data.POC * BOX .. ")"
            local width, height = context:measureText(FONT, tostring(text), 0)
            local _, y = context:pointOfPrice(data.max + 2 * BOX)
            context:drawText(FONT, tostring(text), label_color, -1, start_x, y - height, start_x + width, y, 0)
        end
    end
end

function GetDate(period)
    local s, e = core.getcandle(instance.parameters.Method1, source:date(period), day_offset, week_offset);
    s = FixStartTime(s);
    e = FixStartTime(e);
    if source:date(period) > e then
        s = s + 1;
    elseif source:date(period) < s then
        s = s - 1;
    end
    return s;
end

function Update(period, mode)
    local s = GetDate(period);
    if LAST then
        if s ~= GetDate(NOW) then
            return;
        end
    end
    local data = dates[s];
    if data == nil then
        data = {};
        data.start = period;
        data.finish = period;
        dates[s] = data;
    else
        data.finish = math.max(data.finish, period);
    end
    local min, max = mathex.minmax(source, data.start, data.finish);
    data.min = min
    data.max = max
    data.Total = 0
    data.Profile = {}
    for j = data.start, data.finish, 1 do
        local Count = 0
        for price = min, max, BOX do
            Count = Count + 1
            if data.Profile[Count] == nil then
                data.Profile[Count] = 0
            end

            if
                price >= source.low[j] and price + BOX <= source.high[j] or
                    price <= source.low[j] and price + BOX >= source.low[j] or
                    price <= source.high[j] and price + BOX >= source.high[j]
             then
                data.Profile[Count] = data.Profile[Count] + 1
                data.Total = data.Total + 1
            end

            if price == min then
                data.POC = Count
            elseif data.Profile[data.POC] < data.Profile[Count] then
                data.POC = Count
            end

            data.ValueArea = Value * (data.Total / 100)
        end
        PocMark:set(j, min + data.POC * BOX, "\108")
        local va_min, va_max = CalcVAMinMax(data.Profile, data.POC, data.ValueArea)
        vah[j] = min + va_max * BOX
        val[j] = min + va_min * BOX
    end
end

function CalcVAMinMax(profile, poc, area)
    local max = poc
    local min = poc
    local summ = profile[poc]
    while (summ < area) do
        local up = profile[max + 1] or 0
        local down = profile[min - 1] or 0
        if up == 0 and down == 0 then
            return min, max
        end
        if up > down then
            summ = summ + up
            max = max + 1
        else
            summ = summ + down
            min = min - 1
        end
    end
    return min, max
end

local printed = false;

function FixStartTime(date)
    local ts_date = core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, date);
    return core.host:execute("convertTime", core.TZ_TS, core.TZ_EST, math.floor(ts_date) + OpenTime);
end