-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1973

--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC |
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

-- The indicator shows the time (in hours:minutes:seconds) to the end of the current candle. The time is shown in the indicator label. The time is updated every second and disappears when candle is closed.
-- Please pay attention that the computer's clock must be synchronized! if the computer's clock has wrong date/time, the value shown by the indicator will be also wrong. To synchronize the clock automatically, go to the Settings->Control Panel->Date and Time, the choose "Internet Time" tab and set "Synchronize time with Internet servers".

function Init()
    indicator:name("TimeThillEnd")
    indicator:description("The indicators show time to the end of the current candle every time when new price appears")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("T", "Display", "", "0")
    indicator.parameters:addStringAlternative("T", "Time", "", "0")
    indicator.parameters:addStringAlternative("T", "Percentage", "", "1")
    indicator.parameters:addStringAlternative("T", "Both", "", "2")
    indicator.parameters:addString("TF", "Time frame", "", "Chart")

    local i
    local iTF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1", "Chart"}
    for i = 1, 14, 1 do
        indicator.parameters:addStringAlternative("TF", iTF[i], "", iTF[i])
    end

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("FC", "Font Color", "", core.COLOR_LABEL)
    indicator.parameters:addString("fontName", "Font", "", "Arial Black")
    indicator.parameters:addInteger("Size", "Font Size", "", 20)

    indicator.parameters:addGroup("Position")
    indicator.parameters:addString("vPos", "Vertical position", "", "Top")
    indicator.parameters:addStringAlternative("vPos", "Top", "", "Top")
    indicator.parameters:addStringAlternative("vPos", "Middle", "", "Middle")
    indicator.parameters:addStringAlternative("vPos", "Bottom", "", "Bottom")
    indicator.parameters:addString("hPos", "Horizontal position", "", "Right")
    indicator.parameters:addStringAlternative("hPos", "Left", "", "Left")
    indicator.parameters:addStringAlternative("hPos", "Centre", "", "Centre")
    indicator.parameters:addStringAlternative("hPos", "Right", "", "Right")

    indicator.parameters:addGroup("Alert")
    indicator.parameters:addBoolean("Use", "Use  Alert", "", true)
    indicator.parameters:addInteger("Advance", "Advance warning", "", 1, 1, 100000000)
    indicator.parameters:addString("Label", "Label", "", "Candle End Alert")
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)

    indicator.parameters:addGroup("Alerts Sound")
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)
    indicator.parameters:addFile("Sound", " Alert Sound", "", "")
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND)

    indicator.parameters:addGroup("Alerts Email")
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
    indicator.parameters:addString("Email", "Email", "", "")
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL)
end

local Label, Sound, Use
local TF
local source
local len
local out
local L
local T
local font1
local fontName
local FC
local vPos, HPos
local loading, SourceData, Advance
local SendEmail, Show, Email, PlaySound, RecurrentSound
function Prepare(nameOnly)
    source = instance.source
    Show = instance.parameters.Show
    SendEmail = instance.parameters.SendEmail
    Label = instance.parameters.Label
    Use = instance.parameters.Use
    Advance = instance.parameters.Advance

    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

    PlaySound = instance.parameters.PlaySound
    if PlaySound then
        Sound = instance.parameters.Sound
    else
        Sound = nil
    end

    assert(not (PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen")

    RecurrentSound = instance.parameters.RecurrentSound

    TF = instance.parameters.TF
    if TF == "Chart" then
        TF = source:barSize()
    end
    Size = instance.parameters.Size
    vPos = instance.parameters.vPos
    hPos = instance.parameters.hPos
    fontName = instance.parameters.fontName
    FC = instance.parameters.FC

    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize() .. ")"

    instance:name(name)

    if (nameOnly) then
        return
    end

    assert(source:isAlive(), "The chart must be the live price, not a history")
    assert(source:barSize() ~= "t1", "The chart must be the bar history, not tick history")

    T = tonumber(instance.parameters.T)
    L = instance.parameters.L

    local s, e
    font1 = core.host:execute("createFont", fontName, Size, false, false)
    -- calculate length of the bar in seconds
    s, e = core.getcandle(TF, 0, 0, 0)
    len = math.floor((e - s) * 86400 + 0.5)
    core.host:execute("setTimer", 1, 1)
end

function Update(period, mode)
    return
end

function AsyncOperationFinished(cookie, success, message)
    Start, End = core.getcandle(TF, source:date(source:size() - 1), 0, 0)
	
	 period=source:size()-1;
	 

    if loading or period <=1  then
        return core.ASYNC_REDRAW
    end

    local now = core.host:execute("getServerTime");
    Start, End = core.getcandle(TF, now, 0.0);
    local past = math.floor((End - now) * 86400 + 0.5)

    local percents = math.floor(past / len * 100)

    local h, m, s, t, p, n
    s = math.floor(past % 60)
    m = math.floor(past / 60) % 60
    h = math.floor(past / 3600)

    if s == Advance and m == 0 and h == 0 then
        SoundAlert(Sound)

        if Advance == 1 then
            EmailAlert(Label, " The period have ended ", period)
            if Show then
                Pop(Label, " The period have ended ")
            end
        else
            EmailAlert(Label, " The period will end soon ", period)
            if Show then
                Pop(Label, " The period will end soon ")
            end
        end
    end

    if T == 0 then
        t = string.format("%i:%02i:%02i", h, m, s)
    elseif T == 1 then
        t = string.format("%i%%", percents)
    elseif T == 2 then
        t = string.format("%i:%02i:%02i %i%%", h, m, s, percents)
    end

    local HShift = 0
    local VShift = 40

    Draw(t)
    return core.ASYNC_REDRAW
end

function Draw(t)
    local HOffset
    local VOffset
    local HPos, HAlign
    local HPos, HAlign

    if vPos == "Top" then
        VPos, VAlign = core.CR_TOP, core.V_Center
        HOffset = 0
        VOffset = Size * 1.5
    elseif vPos == "Bottom" then
        VPos, VAlign = core.CR_BOTTOM, core.V_Center
        HOffset = 0
        VOffset = -Size * 1.5
    else
        VPos, VAlign = core.CR_CENTER, core.V_Center
        HOffset = 0
        VOffset = Size * 1.5
    end

    if hPos == "Left" then
        HPos, HAlign = core.CR_LEFT, core.H_Right
    elseif hPos == "Right" then
        HPos, HAlign = core.CR_RIGHT, core.H_Left
    else
        HPos, HAlign = core.CR_CENTER, core.H_Center
    end

    core.host:execute("drawLabel1", 1, HOffset, HPos, VOffset, VPos, HAlign, VAlign, font1, FC, t)
end

function ReleaseInstance()
    core.host:execute("deleteFont", font1)
    core.host:execute("killTimer", 1)
end

--**************************************************************************************

function Pop(label, note)
    if not Show then
        return
    end
    terminal:alertMessage(
        source:instrument(),
        source[source:size() - 1],
        label .. " ( " .. source:instrument() .. " : " .. TF .. " ) " .. label .. " : " .. note,
        source:date(NOW)
    )
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
    local TF = "Time Frame : " .. TF
    local Time =
        " Date : " ..
        DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time

    terminal:alertEmail(Email, profile:id(), text)
end
