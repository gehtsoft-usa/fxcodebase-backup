-- Id:
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66890

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("MyFXBook News")
    indicator:description("The indicator shows chosen MyFXBook calendar events")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addString("File", "File", "The calendar_statement.csv file", "calendar_statement.csv")
    indicator.parameters:addBoolean(
        "ALL",
        "All instruments",
        "Choose true to see all news and false to see the news which are related with the current currency pair only",
        false
    )
    indicator.parameters:addString("IMP", "Importance of the new to show", "", "ALL")
    indicator.parameters:addStringAlternative("IMP", "All news", "", "ALL")
    indicator.parameters:addStringAlternative("IMP", "Medium or above", "", "MED")
    indicator.parameters:addStringAlternative("IMP", "High only", "", "HIGH")
    indicator.parameters:addInteger("ROWS", "Number of lines", "", 5, 1, 20)
    indicator.parameters:addBoolean("Brief", "Description Only", "Show the countdown and event description only", false)
    indicator.parameters:addInteger(
        "Buffer",
        "Removal Delay",
        "Keep expired news around for this many minutes before removing them.",
        5,
        0,
        1440
    )

    indicator.parameters:addGroup("Placement")
    indicator.parameters:addString("Y", "Vertical Placement", "", "Top")
    indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")
    indicator.parameters:addString("X", "Horizontal Placement", "", "Right")
    indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
    indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addInteger("S", "Font size in points", "", 8, 6, 20)
    indicator.parameters:addColor("clrHigh", "High news color", "", core.rgb(217, 0, 0))
    indicator.parameters:addColor("clrMedium", "Medium news color", "", core.rgb(86, 138, 235))
    indicator.parameters:addColor("clrLow", "Low news color", "", core.rgb(46, 186, 46))
    indicator.parameters:addBoolean("Background", "Draw Background", "", false)
    indicator.parameters:addColor("clrBackground", "Background color", "", core.rgb(230, 230, 230))
end

local source
local instr
local ALL
local IMP
local Brief

local clrHigh, clrMedium, clrLow, clrBackground
local Background
local fontSize

local Buffer = 0
local currentEvent = nil
local localTimeDiff

local events = {};
function GetMonth(month)
    if month == "January" then
        return 1;
    end
    if month == "Febuary" then
        return 2;
    end
    if month == "March" then
        return 3;
    end
    if month == "April" then
        return 4;
    end
    if month == "May" then
        return 5;
    end
    if month == "June" then
        return 6;
    end
    if month == "July" then
        return 7;
    end
    if month == "August" then
        return 8;
    end
    if month == "September" then
        return 9;
    end
    if month == "October" then
        return 10;
    end
    if month == "November" then
        return 11;
    end
    if month == "December" then
        return 12;
    end
    return nil;
end

function ParseDatetime(year_str, month_str, day_str, hour_str, minute_str)
    local tdate =
    { 
        year = tonumber(year_str),
        month = GetMonth(month_str),
        day = tonumber(day_str),
        hour = tonumber(hour_str),
        min = tonumber(minute_str),
        sec = 0
    };
    if tdate.year == 0 or tdate.month == nil or tdate.day == 0 then
        return nil;
    end
    return core.tableToDate(tdate);
end

local PRIORITY_HIGH = "High";
local PRIORITY_MEDIUM = "Medium";
local PRIORITY_LOW = "Low";

local pattern = "\"(%d+), (%S+) (%d+), (%d+):(%d+)\","
    .. "\"([^\"]+)\","
    .. "([^,]*),"
    .. "([^,]*),"
    .. "([^,]*),"
    .. "([^,]*),"
    .. "([^,]*)"

function ParseFile(file)
    local header_parsed = false;
    for line in io.lines(file) do
        local values, count = core.parseCsv(line);
        if header_parsed then
            for year_str, month_str, day_str, hour_str, minute_str, title_str,
                impact_str, previous_str, forecast_str, skip, country_str in string.gmatch(line, pattern)
            do
                local event = 
                {
                    date = ParseDatetime(year_str, month_str, day_str, hour_str, minute_str),
                    title = title_str,
                    impact = impact_str,
                    previous = previous_str,
                    forecast = forecast_str,
                    country = country_str
                };
                if event.date ~= nil then
                    events[#events + 1] = event;
                end
            end
        else
            header_parsed = true;
        end
    end
end

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    localTimeDiff = 0;

    source = instance.source
    instr = source:instrument()
    ParseFile(instance.parameters.File);

    ALL = instance.parameters.ALL
    IMP = instance.parameters.IMP
    ROWS = instance.parameters.ROWS
    Brief = instance.parameters.Brief
    Buffer = instance.parameters.Buffer
    Y = instance.parameters.Y
    X = instance.parameters.X
    fontSize = instance.parameters.S
    clrHigh = instance.parameters.clrHigh
    clrMedium = instance.parameters.clrMedium
    clrLow = instance.parameters.clrLow
    clrBackground = instance.parameters.clrBackground
    Background = instance.parameters.Background

    instance:ownerDrawn(true)
end

local init = false

function Draw(stage, context)
    if not init then
        context:createFont(1, "Verdana", 0, context:pointsToPixels(fontSize), 0)
        context:createSolidBrush(2, clrBackground)
        init = true
    end

    local i = 1
    local v
    if Y == "Top" then
        v = 0
    else
        v = ROWS
    end
    local nextEvent = events[i]
    local count = 0
    local XT = 50000
    local XB = 0
    local XR = 0
    local XL = 50000
    local objects = {}

    while (nextEvent ~= nil) do
        local localTime = core.now() - localTimeDiff

        -- calculate the countdown until the time
        -- if it is expired, keep it within the Buffer
        -- if it is outside the buffer, skip it

        if nextEvent.date > (localTime - Buffer * 1 / 1440) then
            -- if we are within our buffer
            local diff
            local post
            if nextEvent.date > localTime then
                diff = nextEvent.date - localTime
                post = "until "
            else
                diff = localTime - nextEvent.date
                post = "ago "
            end

            local h = math.floor(diff * 24)
            local m = math.floor(diff * 1440) - h * 60

            local txtEvent = ""
            if (h > 0) then
                txtEvent = h .. " hrs "
            end
            txtEvent = txtEvent .. m .. " mins " .. post .. nextEvent.country .. ": " .. nextEvent.title
            if not Brief then
                txtEvent = txtEvent .. " (" .. core.formatDate(nextEvent.date) .. ") prev: " .. nextEvent.previous .. " exp: " .. nextEvent.forecast
            end

            local width, height = context:measureText(1, txtEvent, 0)
            local left = iX(context, width, 0, 1)
            local right = iX(context, width, 0, 2)
            local top = iY(context, height, v, 1)
            local bottom = iY(context, height, v, 2)
            local clr

            if (nextEvent.impact == PRIORITY_HIGH) then
                clr = clrHigh
            elseif (nextEvent.impact == PRIORITY_MEDIUM) then
                clr = clrMedium
            else
                clr = clrLow
            end

            if Background then
                local object = {}
                object.txt = txtEvent
                object.clr = clr
                object.left = left
                object.top = top
                object.right = right
                object.bottom = bottom
                objects[count] = object

                -- need to take the max size rectangle depending on content.
                if (left < XL) then
                    XL = left
                end
                if (top < XT) then
                    XT = top
                end
                if (bottom > XB) then
                    XB = bottom
                end
                if (right > XR) then
                    XR = right
                end
            else
                context:drawText(1, txtEvent, clr, -1, left, top, right, bottom, 0)
            end

            count = count + 1
            if Y == "Top" then
                v = v + 1
            else
                v = v - 1
            end
        end

        i = i + 1
        if (count >= ROWS) then
            break
        end

        nextEvent = events[i]
    end

    if (count == 0) then
        -- No News!!
        local txtEvent = "NO NEWS"

        if Y ~= "Top" then
            v = 1
        end
        local width, height = context:measureText(1, txtEvent, 0)
        local left = iX(context, width, 0, 1)
        local right = iX(context, width, 0, 2)
        local top = iY(context, height, v, 1)
        local bottom = iY(context, height, v, 2)

        if Background then
            local object = {}
            object.txt = txtEvent
            object.clr = clrLow
            object.left = left
            object.top = top
            object.right = right
            object.bottom = bottom
            objects[count] = object
            count = count + 1

            -- need to take the max size rectangle depending on content.
            XL = left
            XT = top
            XB = bottom
            XR = right
        else
            context:drawText(1, txtEvent, clrLow, -1, left, top, right, bottom, 0)
        end
    end

    if Background then
        -- draw a background FIRST
        context:drawRectangle(-1, 2, XL - 1, XT - 1, XR + 1, XB + 1)

        -- now draw the objects.
        while (count > 0) do
            count = count - 1
            local object = objects[count]
            context:drawText(1, object.txt, object.clr, -1, object.left, object.top, object.right, object.bottom, 0)
        end
    end
end

function iX(context, width, Shift, x)
    if X == "Left" then
        return context:left() + Shift * width + width * (x - 1)
    end

    return context:right() - width * Shift - width * (1 - (x - 1))
end

function iY(context, height, Shift, x)
    if Y == "Top" then
        return context:top() + Shift * height + height * (x - 1)
    end

    return context:bottom() - Shift * height + height * (x - 1)
end

function Update(period, mode)
end

function AsyncOperationFinished(cookie, success, message)
    return 0
end

function ReleaseInstance()
end
