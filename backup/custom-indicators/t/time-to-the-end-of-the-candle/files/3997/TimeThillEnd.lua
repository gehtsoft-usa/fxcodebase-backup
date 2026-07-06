-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1973

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Time Thill End")
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
end

local Label
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
local Size

function Prepare(nameOnly)
    source = instance.source

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

    if onlyName then
        return
    end

    T = instance.parameters.T
    L = instance.parameters.L

    local s, e
    font1 = core.host:execute("createFont", fontName, Size, false, false)
    s, e = core.getcandle(TF, 0, 0, 0)
    len = math.floor((e - s) * 86400 + 0.5)
    core.host:execute("setTimer", 1, 1)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        Draw()
    end
end

function Draw()
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

    core.host:execute("drawLabel1", 1, HOffset, HPos, VOffset, VPos, HAlign, VAlign, font1, FC, Text())
end

function ReleaseInstance()
    core.host:execute("deleteFont", font1)
    core.host:execute("killTimer", 1)
end

function Update(period, mode)
end

function Text()
    if source:size() - 1 < 1 then
        return "";
    end

    local now = core.host:execute("getServerTime");
    Start, End = core.getcandle(TF, now, 0.0);
    local past = math.floor((End - now) * 86400 + 0.5)
    local h, m, s, p, n
    s = math.floor(past % 60)
    m = math.floor(past / 60) % 60
    h = math.floor(past / 3600)

    if T == "0" then
        return string.format("%i:%02i:%02i", h, m, s)
    elseif T == "1" then
        return string.format("%i%%", math.floor(past / len * 100))
    elseif T == "2" then
        return string.format("%i:%02i:%02i %i%%", h, m, s, math.floor(past / len * 100))
    end

    return "";
end
