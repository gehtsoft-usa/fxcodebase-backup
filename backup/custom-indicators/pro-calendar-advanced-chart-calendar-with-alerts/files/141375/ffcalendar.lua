-- Id: 13045
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61485

--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ForexFactory News")
    indicator:description("The indicator shows chosen ForexFactory calendar events")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addString("Server", "Server", "The ForexFactory Server", "faireconomy.media")
    indicator.parameters:addString("File", "File", "The ForexFactory file", "ff_calendar_thisweek.xml")
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
    indicator.parameters:addBoolean("REFRESH", "Refresh news automatically", "", false)
    indicator.parameters:addInteger("TIMEOUT", "Refresh news in the specified timeout (in minutes)", "", 5, 5, 60)

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
local loading
local instr
local ALL
local IMP
local refresh = false
local Server, File
local Brief

local clrHigh, clrMedium, clrLow, clrBackground
local Background
local fontSize

local Buffer = 0
local gWeekData = nil
local eventIndex = 0
local currentEvent = nil
local firstUpdate = true
local timeNow
local localTimeDiff
local loadingRequest

local ROWS

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    source = instance.source
    instr = source:instrument()

    ALL = instance.parameters.ALL
    IMP = instance.parameters.IMP
    ROWS = instance.parameters.ROWS
    Brief = instance.parameters.Brief
    Buffer = instance.parameters.Buffer
    Y = instance.parameters.Y
    X = instance.parameters.X
    Server = instance.parameters.Server
    File = instance.parameters.File
    fontSize = instance.parameters.S
    clrHigh = instance.parameters.clrHigh
    clrMedium = instance.parameters.clrMedium
    clrLow = instance.parameters.clrLow
    clrBackground = instance.parameters.clrBackground
    Background = instance.parameters.Background

    instance:ownerDrawn(true)

    loading = false
    require("http_lua")
    require("expat_lua")

    core.host:execute("setTimer", 1, 1)
    core.host:execute("addCommand", 2, "Refresh FFNews", "")
    if instance.parameters.REFRESH then
        core.host:execute("setTimer", 3, instance.parameters.TIMEOUT * 60)
    end
end

local init = false

function Draw(stage, context)
    if not init then
        context:createFont(1, "Verdana", 0, context:pointsToPixels(fontSize), 0)
        context:createSolidBrush(2, clrBackground)
        init = true
    end

    if (gWeekData ~= nil) then
        local i = 0
        local v
        if Y == "Top" then
            v = 0
        else
            v = ROWS
        end
        local nextEvent = gWeekData[i]
        local count = 0
        local XT = 50000
        local XB = 0
        local XR = 0
        local XL = 50000
        local objects = {}

        while (nextEvent ~= nil) do
            local localTime = core.now()
            localTime = localTime - localTimeDiff
            -- calculate the countdown until the time
            -- if it is expired, keep it within the Buffer
            -- if it is outside the buffer, skip it

            if nextEvent.oleDate > (localTime - Buffer * 1 / 1440) then
                -- if we are within our buffer
                local diff
                local post
                if nextEvent.oleDate > localTime then
                    diff = nextEvent.oleDate - localTime
                    post = "until "
                else
                    diff = localTime - nextEvent.oleDate
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
                    txtEvent = txtEvent .. " (" .. nextEvent.date .. " " .. nextEvent.time .. ") prev: " .. nextEvent.previous .. " exp: " .. nextEvent.forecast
                end

                local width, height = context:measureText(1, txtEvent, 0)
                local left = iX(context, width, 0, 1)
                local right = iX(context, width, 0, 2)
                local top = iY(context, height, v, 1)
                local bottom = iY(context, height, v, 2)
                local clr

                if (nextEvent.impact == "High") then
                    clr = clrHigh
                elseif (nextEvent.impact == "Medium") then
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
            end

            i = i + 1
            if Y == "Top" then
                v = v + 1
            else
                v = v - 1
            end
            if (count >= ROWS) then
                break
            end

            nextEvent = gWeekData[i]
        end

        if (count == 0) then
            -- No News!!
            local txtEvent
            if (loading) then
                txtEvent = "loading http://" .. Server .. "/" .. File
            else
                txtEvent = "NO NEWS"
            end

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
    if firstUpdate then
        firstUpdate = false
        UpdateNews()
    end
end

local lastText = ""
function sax_characters(this, text)
    -- core.host:trace("text:" .. expat_lua.utf8_to_ansi(text) .. "\n");
    lastText = expat_lua.utf8_to_ansi(text)
end

function sax_startElement(this, name, attributes)
    if (name == "event") then
        -- create a new event.
        currentEvent = {}
    else --
        -- we just ignore the creation of other events.
        --[[
        core.host:trace("start element:" .. name .. "\n");
        local i;
        for i = 0, attributes.count - 1, 1 do
           core.host:trace("   attribute " .. attributes[i].name .. "=" .. attributes[i].value .. "\n");
        end
        ]]
    end
end

function ExtFormatDate(inputDate)
    local theDate = core.dateToTable(inputDate)

    return string.format(
        "%d/%02d/%02d %02d:%02d:%02d %d",
        theDate.year,
        theDate.month,
        theDate.day,
        theDate.hour,
        theDate.min,
        theDate.sec,
        theDate.wday
    )
end

function sax_endElement(this, name)
    if (name == "event") then
        if (currentEvent ~= nil) then
            -- save the last event to the list of events for the week
            gWeekData[eventIndex] = currentEvent
            eventIndex = eventIndex + 1
        end

        -- reset
        currentEvent = nil
    elseif (name == "title") then
        if (currentEvent ~= nil) then
            currentEvent.title = lastText
        end
    elseif (name == "country") then
        if (currentEvent ~= nil) then
            if (string.find(instr, string.upper(lastText), 1, true) ~= nil) or ALL then
                currentEvent.country = lastText
            else
                -- remove it now to optimize drawing later.
                currentEvent = nil
            end
        end
    elseif (name == "date") then
        if (currentEvent ~= nil) then
            currentEvent.date = lastText
        end
    elseif (name == "time") then
        if (currentEvent ~= nil) then
            currentEvent.time = lastText

            -- parse date: example 11-20-2014
            local dd = "(%d%d?)-(%d%d?)-(%d%d%d%d)"
            local month, day, year = string.match(currentEvent.date, dd)

            -- parse time: example 9:30am
            local tt = "(%d%d?):(%d%d)([^,]*)"
            local hour, minute, postfix = string.match(currentEvent.time, tt)

            -- core.host:trace("Converting " .. currentEvent.title .. " " .. currentEvent.date .. " " .. currentEvent.time );
            -- core.host:trace("Converted " .. currentEvent.title .. " " .. hour .. ":" .. minute .. postfix );

            if (postfix == "am" and hour == "12") then
                -- convert 12am to 0am otherwise we will be 12 hour off.
                hour = 0
            end
            local eventDateTime = core.datetime(year, month, day, hour, minute, 0)
            if (postfix == "pm" and hour ~= "12") then
                -- don't add 12 hours to 12:xx pm times otherwise we will be 12 hours off.
                eventDateTime = eventDateTime + 0.5
            end
            -- core.host:trace(ExtFormatDate(eventDateTime));

            if eventDateTime > (timeNow - Buffer * 1 / 1440) then
                -- save OLE format time for comparison.
                currentEvent.oleDate = eventDateTime
            else
                -- core.host:trace(currentEvent.date .. " " .. currentEvent.title .. " " .. currentEvent.time .. " is too old!");
                -- this object has expired, so just remove it now to optimize drawing later.
                currentEvent = nil
            end
        end
    elseif (name == "impact") then
        if (currentEvent ~= nil) then
            if
                IMP == "ALL" or (IMP == "MED" and lastText == "Medium" or lastText == "High") or
                    (IMP == "HIGH" and lastText == "High")
             then
                currentEvent.impact = lastText
            else
                -- filter this news out now to optimize drawing later.
                currentEvent = nil
            end
        end
    elseif (name == "forecast") then
        if (currentEvent ~= nil) then
            currentEvent.forecast = lastText
        end
    elseif (name == "previous") then
        if (currentEvent ~= nil) then
            currentEvent.previous = lastText
        end
    elseif (name == "weeklyevents") then
        -- ignore
    else
        core.host:trace("end element:" .. name .. "\n")
    end
end

function sax_comment(this, text)
    -- core.host:trace("comment:" .. text .. "\n");
end

function sax_startCDATA(this)
    -- core.host:trace("startCDATA\n");
end

function sax_endCDATA(this)
    -- core.host:trace("endCDATA\n");
end

function sax_processingInstruction(this, target, data)
    -- core.host:trace("processing:" .. target .. "," .. data .. "\n");
end

function sax_startNamespace(this, prefix, uri)
    -- if (prefix == nil) then prefix = "nil"; end
    -- core.host:trace("startNamespace:" .. prefix .. "," .. uri .. "\n");
end

function sax_endNamespace(this, prefix)
    -- if (prefix == nil) then prefix = "nil"; end
    -- core.host:trace("endNamespace:" .. prefix .. "\n");
end

function parseXML(response)
    local estDateTimeNow = core.host:execute("getServerTime")
    timeNow = core.host:execute("convertTime", core.TZ_EST, core.TZ_UTC, estDateTimeNow)
    localTimeDiff = core.now() - timeNow

    local handler = {
        characters = sax_characters,
        startElement = sax_startElement,
        endElement = sax_endElement,
        comment = sax_comment,
        startCDATA = sax_startCDATA,
        endCDATA = sax_endCDATA,
        processingInstruction = sax_processingInstruction,
        startNamespace = sax_startNamespace,
        endNamespace = sax_endNamespace
    }

    expat_lua.parseSAX(response, handler)

    return nil
end

function UpdateNews()
    if (loading) then
        return
    end

    gWeekData = {}
    eventIndex = 0
    core.host:trace("loading")
    loading = true

    local url = "http://" .. Server .. "/" .. File
    core.host:execute("setStatus", "loading " .. url)
    core.host:trace(url);
    loadingRequest = http_lua.createRequest()
    loadingRequest:start(url)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading then
            if not (loadingRequest:loading()) then
                loading = false
                if loadingRequest:httpStatus() == 200 then
                    parseXML(loadingRequest:response())
                else
                    gWeekData = nil
                    eventIndex = 0
                end
                core.host:trace("loading complete")
                loading = false
                core.host:execute("setStatus", "")
                return core.ASYNC_REDRAW
            end
        end
        return 0
    elseif cookie == 2 then
        UpdateNews()
        return core.ASYNC_REDRAW
    elseif cookie == 3 then
        if not (refresh) then
            -- skip the first refresh tick
            refresh = true
            return 0
        else
            UpdateNews()
            return core.ASYNC_REDRAW
        end
    end
    return 0
end

function ReleaseInstance()
    if loading then
        while (loadingRequest:loading()) do
        end
    end
    core.host:execute("killTimer", 1)
    core.host:execute("killTimer", 3)
end
