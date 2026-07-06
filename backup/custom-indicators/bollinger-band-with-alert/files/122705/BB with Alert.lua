-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60189

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
    indicator:name("Bollinger Band")
    indicator:description(
        "Provides a relative definition of high and low based on standard deviations and a simple moving average."
    )
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)
    indicator:setTag("group", "Bollinger")
    indicator:setTag("Version", "2")

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("N", "Period", "Period", 20, 1, 10000)
    indicator.parameters:addDouble(
        "Dev",
        "Number of standard deviations",
        "The number of standard deviations.",
        2.0,
        0.0001,
        1000.0
    )
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("clr1", "Top Band lines Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width1", "Top Band lines Width", "", 1, 1, 5)
    indicator.parameters:addInteger("style1", "Top Band lines Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addColor("clr2", "Bottom Band lines Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "Bottom Band lines Width", "", 1, 1, 5)
    indicator.parameters:addInteger("style2", "Bottom Band lines Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addBoolean(
        "HideAve",
        "Hide average line",
        "Defines whether the BB average line is hidden.",
        true
    )
    indicator.parameters:addColor("clrBBA", "Average line Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("widthBBA", "Average line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("styleBBA", "Average line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("styleBBA", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addBoolean("show_historical", "Show Historical", "", true);

    indicator.parameters:addGroup("Mode")
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live")
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

    indicator.parameters:addGroup("Alert Style")
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100)

    indicator.parameters:addGroup("Alerts")
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)

    indicator.parameters:addGroup("Alerts Sound")
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

    indicator.parameters:addGroup("Alerts Email")
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
    indicator.parameters:addString("Email", "Email", "", "")
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

    Parameters(1, "Central Line Cross")
    Parameters(2, "Band Line Cross")
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert")

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true)

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "")
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND)

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "")
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND)

    indicator.parameters:addString("Label" .. id, "Label", "", Label)
end

local Number = 2

local Up = {}
local Down = {}
local Label = {}
local ON = {}
local Size
local Email
local SendEmail
local RecurrentSound, SoundFile
local Show
local PlaySound
local UpTrendColor, DownTrendColor
local Alert = {}
local AlertLevel = {}
local ShowAlert
local U = {}
local D = {}
local Live

local Indicator
local FIRST = true
local Dev
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N

local firstPeriod
local source = nil

-- Streams block
local TL = nil
local BL = nil
local AL = nil
local show_historical;

-- Routine
function Prepare()
    FIRST = true
    Show = instance.parameters.Show
    Live = instance.parameters.Live
    show_historical = instance.parameters.show_historical;

    UpTrendColor = instance.parameters.UpTrendColor
    DownTrendColor = instance.parameters.DownTrendColor

    ShowAlert = instance.parameters.ShowAlert

    N = instance.parameters.N
    Dev = instance.parameters.Dev
    source = instance.source
    firstPeriod = source:first() + N - 1

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. Dev .. ")"
    instance:name(name)
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clr1, firstPeriod)
    TL:setWidth(instance.parameters.width1)
    TL:setStyle(instance.parameters.style1)
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clr2, firstPeriod)
    BL:setWidth(instance.parameters.width2)
    BL:setStyle(instance.parameters.style2)
    if not instance.parameters.HideAve then
        AL = instance:addInternalStream(0, 0)
    else
        AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.clrBBA, firstPeriod)
        AL:setWidth(instance.parameters.widthBBA)
        AL:setStyle(instance.parameters.styleBBA)
    end

    Initialization()
    instance:ownerDrawn(true)

    for i = 1, Number, 1 do
        Alert[i] = instance:addInternalStream(0, 0)
        AlertLevel[i] = instance:addInternalStream(0, 0)
    end
end

function Initialization()
    Size = instance.parameters.Size
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
    assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

    PlaySound = instance.parameters.PlaySound
    if PlaySound then
        for i = 1, Number, 1 do
            Up[i] = instance.parameters:getString("Up" .. i)
            Down[i] = instance.parameters:getString("Down" .. i)
        end
    else
        for i = 1, Number, 1 do
            Up[i] = nil
            Down[i] = nil
        end
    end

    for i = 1, Number, 1 do
        assert(
            not (PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""),
            "Sound file must be chosen"
        )
        assert(
            not (PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""),
            "Sound file must be chosen"
        )
    end

    RecurrentSound = instance.parameters.RecurrentSound

    for i = 1, Number, 1 do
        U[i] = nil
        D[i] = nil
    end
end

function Calculate(period)
    if period >= firstPeriod then
        local ml = mathex.avg(source, period - N + 1, period)
        local d = mathex.stdev(source, period - N + 1, period)
        local Dd = Dev * d
        TL[period] = ml + Dd
        BL[period] = ml - Dd
        AL[period] = ml
    end
end

-- Indicator calculation routine
function Update(period)
    Calculate(period)

    if period < firstPeriod then
        return
    end

    Activate(1, period)
    Activate(2, period)
end

function Activate(id, period)
    local Shift = 0
    if Live ~= "Live" then
        period = period - 1
        Shift = 1
    end

    Alert[id][period] = 0
    if id == 1 and ON[id] then
        if source[period] > AL[period] and source[period - 1] <= AL[period - 1] then
            Alert[id][period] = 1
            AlertLevel[id][period] = AL[period]

            D[id] = nil

            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period)
                SoundAlert(Up[id])
                EmailAlert(Label[id], " B.B. Central Line Cross Over", period)
                SendAlert(Label[id], "  BB.B. Central Line Cross Over ", period)
                if Show then
                    Pop(Label[id], " B.B. Central Line Cross Over ")
                end
            end
        elseif source[period] < AL[period] and source[period - 1] >= AL[period - 1] then
            Alert[id][period] = -1
            AlertLevel[id][period] = AL[period]

            U[id] = nil

            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period)
                SoundAlert(Down[id])
                EmailAlert(Label[id], " B.B. Central Line Cross Under", period)
                SendAlert(Label[id], "   B.B. Central Line Cross Under ", period)
                if Show then
                    Pop(Label[id], " B.B. Central Line Cross Under ")
                end
            end
        end
    elseif id == 2 and ON[id] then
        --Top Line
        if source[period] > TL[period] and source[period - 1] <= TL[period - 1] then
            Alert[id][period] = 1
            AlertLevel[id][period] = TL[period]

            D[id] = nil

            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period)
                SoundAlert(Up[id])
                EmailAlert(Label[id], " B.B. Top Line Cross Over", period)
                SendAlert(Label[id], " B.B. Top Line Cross Over ", period)
                if Show then
                    Pop(Label[id], " B.B. Top Line Cross Over ")
                end
            end
        elseif source[period] < TL[period] and source[period - 1] >= TL[period - 1] then
            Alert[id][period] = -1
            AlertLevel[id][period] = TL[period]

            U[id] = nil

            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period)
                SoundAlert(Down[id])
                EmailAlert(Label[id], " B.B. Central Line Cross Under", period)
                SendAlert(Label[id], "  B.B. Central Line Cross Under ", period)
                if Show then
                    Pop(Label[id], " B.B. Central Line Cross Under ")
                end
            end
        end
        --Bottom Line
        if source[period] > BL[period] and source[period - 1] <= BL[period - 1] then
            Alert[id][period] = 1
            AlertLevel[id][period] = BL[period]

            D[id] = nil

            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period)
                SoundAlert(Up[id])
                EmailAlert(Label[id], " B.B. Bottom Line Cross Over", period)
                SendAlert(Label[id], " B.B. Bottom Line Cross Over ", period)
                if Show then
                    Pop(Label[id], " B.B. Bottom Line Cross Over ")
                end
            end
        elseif source[period] < BL[period] and source[period - 1] >= BL[period - 1] then
            Alert[id][period] = -1
            AlertLevel[id][period] = BL[period]

            U[id] = nil

            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period)
                SoundAlert(Down[id])
                EmailAlert(Label[id], " B.B. Bottom Line Cross Under", period)
                SendAlert(Label[id], "   B.B. Bottom Line Cross Under ", period)
                if Show then
                    Pop(Label[id], " B.B. Bottom Line Cross Under ")
                end
            end
        end
    end

    if FIRST then
        FIRST = false
    end
end

local init = false

function DrawBar(context, period)
    x, x1, x2 = context:positionOfBar(period)
    for Level = 1, Number, 1 do
        if Alert[Level]:hasData(period) then
            if Alert[Level][period] == 1 then
                visible, y = context:pointOfPrice(AlertLevel[Level][period])
                width, height = context:measureText(1, "\225", 0)
                context:drawText(1, "\225", UpTrendColor, -1, x - width / 2, y - height, x + width / 2, y, 0)
            elseif Alert[Level][period] == -1 then
                visible, y = context:pointOfPrice(AlertLevel[Level][period])
                width, height = context:measureText(1, "\226", 0)
                context:drawText(1, "\226", DownTrendColor, -1, x - width / 2, y, x + width / 2, y + height, 0)
            end
        end
    end
end

function Draw(stage, context)
    if stage ~= 2 then
        return
    end
    if not init then
        context:createFont(1, "Wingdings", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
        init = true
    end
    if show_historical then
        for period = math.max(context:firstBar(), source:first()), math.min(context:lastBar(), source:size() - 1), 1 do
            DrawBar(context, period);
        end
    else
        DrawBar(context,  source:size() - 1);
    end
end

function AsyncOperationFinished(cookie, success, message)
end

function Pop(label, note)
    core.host:execute("prompt", 1, label, " ( " .. source:instrument() .. label .. " : " .. note)
end

function SoundAlert(Sound)
    if not PlaySound then
        return
    end
    terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(label, Subject, period)
    if not SendEmail then
        return
    end

    local date = source:date(period)
    local DATA = core.dateToTable(date)
    local delim = "\013\010"
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
    local Symbol = "Instrument : " .. source:instrument()
    local Time =
        " Date : " ..
        DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec
    local text = Note .. delim .. Symbol .. delim .. Time
    terminal:alertEmail(Email, profile:id(), text)
end

function SendAlert(label, Subject, period)
    if not ShowAlert then
        return
    end

    local date = source:date(period)
    local DATA = core.dateToTable(date)
    local delim = "\013\010"
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
    local Symbol = "Instrument : " .. source:instrument()
    local Time =
        " Date : " ..
        DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec
    local TF = "Time Frame : " .. source:barSize()
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW))
end
