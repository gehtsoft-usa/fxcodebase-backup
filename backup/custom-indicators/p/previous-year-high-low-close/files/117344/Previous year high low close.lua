-- Id: 20460
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63105&start=10

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("Previous Days High Low")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addString("ShowMode", "Show Mode", "", "LAST")
    indicator.parameters:addStringAlternative("ShowMode", "Current Year", "", "CURR")
    indicator.parameters:addStringAlternative("ShowMode", "Last Year", "", "LAST")
    indicator.parameters:addStringAlternative("ShowMode", "Historical", "", "HIST")

    indicator.parameters:addInteger("hist_count", "Number of Years to Show", "", 5)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Open", "Open Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("High", "High Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Low", "Low Line Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Close", "Close Line Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL)
    indicator.parameters:addBoolean("show_open", "Show Open", "", true)
    indicator.parameters:addBoolean("show_high", "Show High", "", true)
    indicator.parameters:addBoolean("show_low", "Show Low", "", true)
    indicator.parameters:addBoolean("show_close", "Show Close", "", true)

    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
    indicator.parameters:addInteger("fontsize", "Font Size", "", 10)
    indicator.parameters:addInteger("transparency", "Line Transparency", "", 50)

    indicator.parameters:addGroup("Placement")
    indicator.parameters:addBoolean("Show", "Show Label", "", false)
    indicator.parameters:addString("Y", " Y Placement", "", "Top")
    indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

    indicator.parameters:addString("X", " X Placement", "", "Right")
    indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
    indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
    indicator.parameters:addInteger("ShiftY", "Shift", "", 0)
end

local source = nil
local transparency
local Source, loading
local ShiftY, X, Y
local Show
local Label
local ShowMode
local hist_count

function Prepare(nameOnly)
    source = instance.source
    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    Y = instance.parameters.Y
    X = instance.parameters.X
    ShiftY = instance.parameters.ShiftY
    Show = instance.parameters.Show
    Label = instance.parameters.Label
    ShowMode = instance.parameters.ShowMode
    hist_count = instance.parameters.hist_count

    Source = core.host:execute("getSyncHistory", source:instrument(), "M1", source:isBid(), 300, 100, 101)
    loading = true

    transparency = instance.parameters.transparency

    instance:ownerDrawn(true)
end

function Update(period)
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false
        instance:updateFrom(0)
    elseif cookie == 101 then
        loading = true
    end
    return core.ASYNC_REDRAW
end

local init = false

function DrawLevels(open, High, Low, Close, context, shift, index)
    if Close == -1 then
        return
    end

    local date = core.dateToTable(core.now())
    local year = date.year
    local date1 = core.datetime(year - shift, 1, 1, 0, 0, 0)
    local date2 = core.datetime(year, 12, 31, 0, 0, 0)
    local X1 = core.findDate(source, date1, false)
    local X2 = core.findDate(source, date2, false)

    if X1 == -1 or X2 == -1 then
        return
    end

    x1, x = context:positionOfBar(X1)
    x2, x = context:positionOfBar(X2)

    if instance.parameters.show_high then
        visible, y1 = context:pointOfPrice(High)
        context:drawLine(1, x1, y1, x2, y1, context:convertTransparency(transparency))
    end
    if instance.parameters.show_low then
        visible, y2 = context:pointOfPrice(Low)
        context:drawLine(2, x1, y2, x2, y2, context:convertTransparency(transparency))
    end
    if instance.parameters.show_close then
        visible, y3 = context:pointOfPrice(Close)
        context:drawLine(3, x1, y3, x2, y3, context:convertTransparency(transparency))
    end
    if instance.parameters.show_open then
        visible, y4 = context:pointOfPrice(open)
        context:drawLine(5, x1, y4, x2, y4, context:convertTransparency(transparency))
    end

    if Show then
        local pos = 1
        if instance.parameters.show_open then
            Text = tostring(year - shift) .. " Open : " .. win32.formatNumber(open, false, source:getPrecision())
            i = index * 3 + pos
            pos = pos + 1
            width, height = context:measureText(4, Text, 0)
            context:drawText(
                4,
                Text,
                Label,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i, 0),
                iX(context, width, 0, 2),
                iY(context, height, i, 1),
                0
            )
        end
        if instance.parameters.show_high then
            Text = tostring(year - shift) .. " High : " .. win32.formatNumber(High, false, source:getPrecision())
            i = index * 3 + pos
            pos = pos + 1
            width, height = context:measureText(4, Text, 0)
            context:drawText(
                4,
                Text,
                Label,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i, 0),
                iX(context, width, 0, 2),
                iY(context, height, i, 1),
                0
            )
        end
        if instance.parameters.show_low then
            Text = tostring(year - shift) .. " Low : " .. win32.formatNumber(Low, false, source:getPrecision())
            i = index * 3 + pos
            pos = pos + 1
            width, height = context:measureText(4, Text, 0)
            context:drawText(
                4,
                Text,
                Label,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i, 0),
                iX(context, width, 0, 2),
                iY(context, height, i, 1),
                0
            )
        end
        if instance.parameters.show_close then
            Text = tostring(year - shift) .. " Close : " .. win32.formatNumber(Close, false, source:getPrecision())
            i = index * 3 + pos
            pos = pos + 1
            width, height = context:measureText(4, Text, 0)
            context:drawText(
                4,
                Text,
                Label,
                -1,
                iX(context, width, 0, 1),
                iY(context, height, i, 0),
                iX(context, width, 0, 2),
                iY(context, height, i, 1),
                0
            )
        end
    end
end

function Draw(stage, context)
    if stage ~= 2 or loading then
        return
    end
    if not init then
        context:createPen(
            1,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            instance.parameters.High
        )
        context:createPen(
            2,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            instance.parameters.Low
        )
        context:createPen(
            3,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            instance.parameters.Close
        )
        context:createFont(4, "Arial", 0, instance.parameters.fontsize, 0)
        context:createPen(
            5,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            instance.parameters.Open
        )
        init = true
    end

    if ShowMode == "LAST" then
        local open, High, Low, Close = Find(1)
        DrawLevels(open, High, Low, Close, context, 1, 0)
    elseif ShowMode == "CURR" then
        local open, High, Low, Close = Find(0)
        DrawLevels(open, High, Low, Close, context, 0, 0)
    elseif ShowMode == "HIST" then
        for i = 0, hist_count - 1 do
            local open, High, Low, Close = Find(i)
            DrawLevels(open, High, Low, Close, context, i, i)
        end
    end
end

function Find(shift)
    local High = -1
    local Low = -1
    local Close = -1
    local date = core.dateToTable(core.now())
    local year = date.year
    local date1 = core.datetime(year - shift, 1, 1, 0, 0, 0)
    local date2 = core.datetime(year - shift, 12, 31, 0, 0, 0)
    local X1 = core.findDate(Source, date1, false)
    local X2 = core.findDate(Source, date2, false)

    if X1 == -1 or X2 == -1 then
        return -1, -1, -1
    end

    Low, High = mathex.minmax(Source, X1, X2)
    Close = Source.close[X2]

    return Source.open[X2], High, Low, Close
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
