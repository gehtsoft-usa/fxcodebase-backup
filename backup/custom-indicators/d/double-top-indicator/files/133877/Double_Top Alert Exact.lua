-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59574
-- Id: 10061

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Double top indicator")
    indicator:description("Double top indicator")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("MinHeight", "Min. height of peak (in pips)", "", 10)
    indicator.parameters:addInteger("MaxDist", "Max. distance between peaks (in bars)", "", 20)
    indicator.parameters:addInteger("MinDist", "Min. distance between peaks (in bars)", "", 5)
    indicator.parameters:addInteger("MinBars", "Min. number of bars after the peak (in bars)", "", 3)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Tclr1", "Top color", "Top color", core.rgb(0, 128, 0))
    indicator.parameters:addColor("Tclr2", "Double top color", "Double top color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Bclr1", "Bottom color", "Bottom color", core.rgb(128, 0, 0))
    indicator.parameters:addColor("Bclr2", "Double bottom color", "Double bottom color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5)

    indicator.parameters:addGroup("Indicator Style")
    indicator.parameters:addColor("color1", "Fast MA color", "MA color", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width1", "MA Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("style1", "MA Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("color2", "Slow MA color", "MA color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "MA Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("style2", "MA Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Alert Parameters")

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)

    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false)
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false)
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", false)

    indicator.parameters:addGroup("Alerts Sound")
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

    indicator.parameters:addGroup("Alerts Email")
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false)
    indicator.parameters:addString("Email", "Email", "", "")
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

    Parameters(1, "Top")
    Parameters(2, "Double top")
    Parameters(3, "Bottom")
    Parameters(4, "Double bottom")
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert")

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true)

    indicator.parameters:addFile("Up" .. id, Label .. " Sound", "", "")
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND)

    indicator.parameters:addString("Label" .. id, "Label", "", Label)
end

local Number = 4
local Up = {}

local Label = {}
local ON = {}
local Email
local SendEmail
local RecurrentSound, SoundFile
local Show
local Alert
local PlaySound
local Live
local FIRST = true
local OnlyOnce
local U = {}

local OnlyOnceFlag
local ShowAlert
local ToTime
local Shift = 0

local first
local source = nil
local MinHeight
local MaxDist, MinDist
local MinBars
local MinHeightPip
local Top = nil
local DoubleTop = nil
local Bottom = nil
local DoubleBottom = nil
local line, Tclr1, Tclr2, Bclr1, Bclr2

function Prepare(nameOnly)
    source = instance.source
    MinHeight = instance.parameters.MinHeight
    MaxDist = instance.parameters.MaxDist
    MinDist = instance.parameters.MinDist
    MinBars = instance.parameters.MinBars
    MinHeightPip = MinHeight * source:pipSize()
    first = source:first() + MinBars
    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. instance.parameters.MinHeight .. ", " .. instance.parameters.MaxDist .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    Tclr1 = instance.parameters.Tclr1
    Tclr2 = instance.parameters.Tclr2
    Bclr1 = instance.parameters.Bclr1
    Bclr2 = instance.parameters.Bclr2
    Top = instance:addStream("Top", core.Dot, name .. ".Top", "Top", instance.parameters.Tclr1, first)
    DoubleTop =
        instance:addStream("DoubleTop", core.Dot, name .. ".DoubleTop", "DoubleTop", instance.parameters.Tclr2, first)
    Bottom = instance:addStream("Bottom", core.Dot, name .. ".Bottom", "Bottom", instance.parameters.Bclr1, first)
    DoubleBottom =
        instance:addStream(
        "DoubleBottom",
        core.Dot,
        name .. ".DoubleBottom",
        "DoubleBottom",
        instance.parameters.Bclr2,
        first
    )
    line = instance:addStream("line", core.Line, "line", "line", Tclr1, 0, 0)
    Top:setWidth(instance.parameters.DotSize)
    DoubleTop:setWidth(instance.parameters.DotSize)
    Bottom:setWidth(instance.parameters.DotSize)
    DoubleBottom:setWidth(instance.parameters.DotSize)

    ToTime = instance.parameters.ToTime

    if ToTime == 1 then
        ToTime = core.TZ_EST
    elseif ToTime == 2 then
        ToTime = core.TZ_UTC
    elseif ToTime == 3 then
        ToTime = core.TZ_LOCAL
    elseif ToTime == 4 then
        ToTime = core.TZ_SERVER
    elseif ToTime == 5 then
        ToTime = core.TZ_FINANCIAL
    elseif ToTime == 6 then
        ToTime = core.TZ_TS
    end

    OnlyOnceFlag = true
    FIRST = true
    OnlyOnce = instance.parameters.OnlyOnce
    ShowAlert = instance.parameters.ShowAlert
    Show = instance.parameters.Show

    Initialization()
end

function Initialization()
    SendEmail = instance.parameters.SendEmail

    local i
    for i = 1, Number, 1 do
        Label[i] = instance.parameters:getString("Label" .. i)
        ON[i] = instance.parameters:getBoolean("ON" .. i)
    end

    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end

    assert(not (SendEmail and (Email == "" or Email == nil)), "E-mail address must be specified")

    PlaySound = instance.parameters.PlaySound
    if PlaySound then
        for i = 1, Number, 1 do
            Up[i] = instance.parameters:getString("Up" .. i)
        end
    else
        for i = 1, Number, 1 do
            Up[i] = nil
        end
    end

    for i = 1, Number, 1 do
        assert(not (PlaySound and (Up[i] == "" or Up[i] == nil)), "Sound file must be chosen")
    end

    RecurrentSound = instance.parameters.RecurrentSound

    for i = 1, Number, 1 do
        U[i] = nil
    end
end

function GetFrom(period)
    local from = line:getBookmark(1)
    if from == period - MinBars then
        from = line:getBookmark(2)
    end
    return from
end

function Update(period, mode)
    if period <= first then
        return
    end
    if IsTop(period - MinBars) then
        Top[period - MinBars] = source.high[period - MinBars]

        Activate(1, period)

        local from = GetFrom(period)
        if from >= 0 then
            core.drawLine(
                line,
                core.range(from, period),
                line[from],
                from,
                Top[period - MinBars],
                period - MinBars,
                Tclr1
            )
        end
        local old = line:getBookmark(1)
        line:setBookmark(1, period - MinBars)
        if old ~= -1 and old ~= period - MinBars then
            line:setBookmark(2, old)
        end
    else
        Top[period - MinBars] = nil
    end
    if IsBottom(period - MinBars) then
        Bottom[period - MinBars] = source.low[period - MinBars]
        Activate(3, period)
        local from = GetFrom(period)
        if from >= 0 then
            core.drawLine(
                line,
                core.range(from, period),
                line[from],
                from,
                Bottom[period - MinBars],
                period - MinBars,
                Bclr1
            )
        end
        local old = line:getBookmark(1)
        line:setBookmark(1, period - MinBars)
        if old ~= -1 and old ~= period - MinBars then
            line:setBookmark(2, old)
        end
    else
        Bottom[period - MinBars] = nil
    end
    local Res
    if Top[period - MinBars] == source.high[period - MinBars] then
        Res = FindPrevTop(period - MinBars)
        if Res ~= nil and source.high[Res] == source.high[period - MinBars] then
            DoubleTop[period - MinBars] = source.high[period - MinBars]
            Activate(2, period)
            local from = GetFrom(period)
            if from >= 0 then
                core.drawLine(
                    line,
                    core.range(from, period),
                    line[from],
                    from,
                    DoubleTop[period - MinBars],
                    period - MinBars,
                    Tclr2
                )
            end
            local old = line:getBookmark(1)
            line:setBookmark(1, period - MinBars)
            if old ~= -1 and old ~= period - MinBars then
                line:setBookmark(2, old)
            end
        end
    end
    if Bottom[period - MinBars] == source.low[period - MinBars] then
        Res = FindPrevBottom(period - MinBars)
        if Res ~= nil and source.low[Res] == source.low[period - MinBars] then
            DoubleBottom[period - MinBars] = source.low[period - MinBars]
            Activate(4, period)

            local from = GetFrom(period)
            if from >= 0 then
                core.drawLine(
                    line,
                    core.range(from, period),
                    line[from],
                    from,
                    DoubleBottom[period - MinBars],
                    period - MinBars,
                    Bclr2
                )
            end
            local old = line:getBookmark(1)
            line:setBookmark(1, period - MinBars)
            if old ~= -1 and old ~= period - MinBars then
                line:setBookmark(2, old)
            end
        end
    end
end

function FindPrevTop(index)
    local i = index - 1
    while i > first and i >= index - MaxDist do
        if Bottom[i] == source.low[i] then
            return nil;
        end
        if Top[i] == source.high[i] then
            if index - i < MinDist then
                return nil;
            end
            return i
        end
        i = i - 1
    end
    return nil
end

function FindPrevBottom(index)
    local i = index - 1
    while i > first and i >= index - MaxDist do
        if Top[i] == source.high[i] then
            return nil;
        end
        if Bottom[i] == source.low[i] then
            if index - i < MinDist then
                return nil;
            end
            return i
        end
        i = i - 1
    end
    return nil
end

function IsTop(index)
    local i
    local Fl = true
    for i = 1, MinBars, 1 do
        if source.high[index + i] >= source.high[index] then
            Fl = false
        end
    end
    if Fl then
        i = index - 1
        while i > first do
            if source.high[i] >= source.high[index] then
                return false
            end
            if source.high[index] - source.low[i] >= MinHeightPip then
                return true
            end
            i = i - 1
        end
    end
    return false
end

function IsBottom(index)
    local i
    local Fl = true
    for i = 1, MinBars, 1 do
        if source.low[index + i] <= source.low[index] then
            Fl = false
        end
    end
    if Fl then
        i = index - 1
        while i > first do
            if source.low[i] <= source.low[index] then
                return false
            end
            if source.high[i] - source.low[index] >= MinHeightPip then
                return true
            end
            i = i - 1
        end
    end
    return false
end

function Activate(id, period)
    if ON[id] then
        local AlertLabels = {"Top", "Double top", "Bottom", "Double bottom"}

        if
            U[id] ~= source:serial(period) and period == source:size() - 1 and not FIRST and
                (not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
         then
            U[id] = source:serial(period)
            SoundAlert(Up[id])
            EmailAlert(Label[id], AlertLabels[id])
            SendAlert(Label[id], AlertLabels[id])
            Pop(Label[id], AlertLabels[id], period)
            OnlyOnceFlag = false
        end
    end

    if FIRST then
        FIRST = false
    end
end

function AsyncOperationFinished(cookie, success, message)
end

function SoundAlert(Sound)
    if not PlaySound then
        return
    end

    terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(label, Subject)
    if not SendEmail then
        return
    end

    local now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    local DATA = core.dateToTable(now)

    local delim = "\013\010"
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
    local Symbol = "Instrument : " .. source:instrument()
    local Time =
        " Date : " ..
        DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

    local TF = "Time Frame : " .. source:barSize()
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time

    terminal:alertEmail(Email, profile:id(), text)
end

function Pop(AlertLabel, AlertText, period)
    if not Show then
        return
    end

    local now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    local DATA = core.dateToTable(now)

    local delim = "\013\010"

    local Symbol = "Instrument : " .. source:instrument()
    local TF = "Time Frame : " .. source:barSize()
    local Time =
        "Date : " ..
        DATA.month .. " / " .. DATA.day .. delim .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec
    local Text = Symbol .. delim .. TF .. delim .. Time .. delim .. AlertLabel .. ":" .. AlertText
    core.host:execute("prompt", 1, profile:id(), Text)
end

function SoundAlert(Sound)
    if not PlaySound then
        return
    end

    terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(AlertLabel, AlertText, period)
    if not SendEmail then
        return
    end

    local delim = "\013\010"

    local now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    local DATA = core.dateToTable(now)

    local Symbol = "Instrument : " .. source:instrument()
    local TF = "Time Frame : " .. source:barSize()
    local Time =
        "Date : " ..
        DATA.month .. " / " .. DATA.day .. delim .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

    local Text = Symbol .. delim .. TF .. delim .. Time .. delim .. AlertLabel .. ":" .. AlertText

    terminal:alertEmail(Email, profile:id(), Text)
end

function SendAlert(AlertLabel, AlertText, period)
    if not ShowAlert then
        return
    end

    local delim = "\013\010"

    local now = core.host:execute("getServerTime")
    now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
    local DATA = core.dateToTable(now)

    local Symbol = "Instrument : " .. source:instrument()
    local TF = "Time Frame : " .. source:barSize()
    local Time =
        "Date : " ..
        DATA.month .. " / " .. DATA.day .. delim .. "Time :" .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

    local Text = Symbol .. delim .. TF .. delim .. Time .. delim .. AlertLabel .. ":" .. AlertText

    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW))
end
