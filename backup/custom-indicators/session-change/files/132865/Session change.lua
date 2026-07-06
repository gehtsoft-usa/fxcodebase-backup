-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65141

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
    indicator:name("Session change")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addDouble("From", "Session Start Time", "Session Start Time", 0)

    indicator.parameters:addString("Type", "Type", "", "Percent")
    indicator.parameters:addStringAlternative("Type", "Percent", "", "Percent")
    indicator.parameters:addStringAlternative("Type", "Pip", "", "Pip")
    indicator.parameters:addStringAlternative("Type", "Both", "", "Both")

    indicator.parameters:addGroup("Placement")
    indicator.parameters:addString("Y", " Y Placement", "", "Top")
    indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

    indicator.parameters:addString("X", " X Placement", "", "Right")
    indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
    indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
    indicator.parameters:addInteger("ShiftY", "Shift", "", 0)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Up", "Up Label Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Down Label Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("Size", "Font Size", "", 20)
end

local Change
local first
local source = nil
local X, Y
local font
local Up, Down
local Size
local ShiftY
local From
local Type
function Prepare(nameOnly)
    Y = instance.parameters.Y
    X = instance.parameters.X
    From = instance.parameters.From
    ShiftY = instance.parameters.ShiftY
    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Size = instance.parameters.Size
    Type = instance.parameters.Type
    source = instance.source
    first = source:first()

    if (nameOnly) then
        return
    end

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    instance:ownerDrawn(true)
end

function Update(period)
end

local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        context:createFont(1, "Arial", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
        init = true
    end

    local p = GetDate()

    if p == 0 then
        return
    end

    local Text1

    if Type == "Percent" then
        Change = (source.close[source.close:size() - 1] - source.close[p]) / (source.close[p] / 100)
        Text1 = "Change : " .. win32.formatNumber(Change, false, 2) .. "%"
    elseif Type == "Pip" then
        Change = (source.close[source.close:size() - 1] - source.close[p]) / (source:pipSize())
        Text1 = "Change : " .. win32.formatNumber(Change, false, 2) .. "Pips"
    else
        Change1 = (source.close[source.close:size() - 1] - source.close[p]) / (source.close[p] / 100)
        Change2 = (source.close[source.close:size() - 1] - source.close[p]) / (source:pipSize())

        Text1 = "Change : " .. win32.formatNumber(Change1, false, 2) .. "%"
        Text2 = "Change : " .. win32.formatNumber(Change2, false, 2) .. "Pips"
    end

    local i = 1
    width, height = context:measureText(1, Text1, 0)

    if Type ~= "Both" then
        if Change > 0 then
            context:drawText(
                1,
                Text1,
                Up,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i, 0),
                iX(context, width, 0, 2),
                iY(context, height, i, 1),
                0
            )
        else
            context:drawText(
                1,
                Text1,
                Down,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i, 0),
                iX(context, width, 0, 2),
                iY(context, height, i, 1),
                0
            )
        end
    else
        if Change1 > 0 then
            context:drawText(
                1,
                Text1,
                Up,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i, 0),
                iX(context, width, 0, 2),
                iY(context, height, i, 1),
                0
            )
        else
            context:drawText(
                1,
                Text1,
                Down,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i, 0),
                iX(context, width, 0, 2),
                iY(context, height, i, 1),
                0
            )
        end

        if Change2 > 0 then
            context:drawText(
                1,
                Text2,
                Up,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i + 1, 0),
                iX(context, width, 0, 2),
                iY(context, height, i + 1, 1),
                0
            )
        else
            context:drawText(
                1,
                Text2,
                Down,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i + 1, 0),
                iX(context, width, 0, 2),
                iY(context, height, i + 1, 1),
                0
            )
        end
    end
end

function GetDate()
    local olddate = source:date(source:size() - 1) -- bar date;

    local table = core.dateToTable(olddate)
    local newdate = core.datetime(table.year, table.month, table.day, math.floor(From), math.floor(60 * (From - math.floor(From)) + 0.5), 0)

    if newdate > source:date(source:size() - 1) then
        newdate = newdate - 1
    end

    local p = core.findDate(source, newdate, false)

    if p == -1 then
        return 0
    else
        return p
    end
end

function iX(context, width, Shift, x)
    if X == "Left" then
        return context:left() + Shift * width + width * (x - 1)
    else
        return context:right() - width * Shift - width * (1 - (x - 1))
    end
end

function iY(context, height, Index, Line)
    if Y == "Top" then
        return context:top() + Index * height + ShiftY * height + Line * height
    else
        if Line == 1 then
            return context:bottom() - (Index + 1) * height - ShiftY * height + height
        else
            return context:bottom() - (Index + 1) * height - ShiftY * height
        end
    end
end
