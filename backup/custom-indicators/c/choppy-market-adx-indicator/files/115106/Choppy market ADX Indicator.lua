-- Id: 19116
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=64999

function Init()
    indicator:name("Choppy market ADX Indicator")
    indicator:description("Choppy market ADX Indicator")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Period", "", 14)
    indicator.parameters:addDouble("Alpha1", "Alpha1", "", 0.25)
    indicator.parameters:addDouble("Alpha2", "Alpha2", "", 0.33)
    indicator.parameters:addDouble("Level", "Level", "", 25)

    indicator.parameters:addInteger("Type", "Type", "", 1)
    indicator.parameters:addIntegerAlternative("Type", "Box", "", 1)
    indicator.parameters:addIntegerAlternative("Type", "Candle", "", 2)

    indicator.parameters:addGroup("Style")

    indicator.parameters:addColor("Zone", "Choppy Zone Color", "", core.rgb(255, 128, 0))
    indicator.parameters:addInteger("Transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 80, 0, 100)
    indicator.parameters:addInteger("Size", "Font Size", "", 20, 0, 100)

    indicator.parameters:addColor("Up", "Cross Over Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Cross Under Color", "", core.rgb(255, 0, 0))

    indicator.parameters:addColor("Up_Candle", "Up Candle Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addColor("Down_Candle", "Down Candle Color", "", core.COLOR_DOWNCANDLE)
    indicator.parameters:addBoolean("HollowUp", "Hollow Up Candle", "", false)
    indicator.parameters:addBoolean("HollowDown", "Hollow Down Candle", "", false)
    indicator.parameters:addColor("background", "Background Color", "", core.COLOR_BACKGROUND)

    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Label Symbols")

    indicator.parameters:addInteger("U1", "1. Up Symbol", "", 217)
    indicator.parameters:addInteger("U2", "2. Up Symbol", "", 217)
    indicator.parameters:addInteger("D1", "1. Down Symbol", "", 218)
    indicator.parameters:addInteger("D2", "2. Down Symbol", "", 218)

    indicator.parameters:addGroup("Border Symbols")

    indicator.parameters:addBoolean("Show", "Show Border", "", true)
    indicator.parameters:addColor("B_Zone", "Choppy Zone Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("B_width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("B_style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("B_style", core.FLAG_LINE_STYLE)
end

local first
local source = nil
local Period
local Alpha1
local Alpha2
local Zone, B_Zone
local Transparency
local Signal
local Size
local Up, Down
local Cross
local Second
local U1, U2
local D1, D2
local Show
local Type
local open = nil
local close = nil
local high = nil
local low = nil
local Up_Candle, Down_Candle
local HollowUp, HollowDown
local background
function Prepare(nameOnly)
    source = instance.source
    Period = instance.parameters.Period
    Alpha1 = instance.parameters.Alpha1
    Alpha2 = instance.parameters.Alpha2
    Type = instance.parameters.Type

    U1 = string.char(instance.parameters.U1)
    U2 = string.char(instance.parameters.U2)
    D1 = string.char(instance.parameters.D1)
    D2 = string.char(instance.parameters.D2)

    Up_Candle = instance.parameters.Up_Candle
    Down_Candle = instance.parameters.Down_Candle
    HollowUp = instance.parameters.HollowUp
    HollowDown = instance.parameters.HollowDown
    background = instance.parameters.background

    Show = instance.parameters.Show

    Up = instance.parameters.Up
    Down = instance.parameters.Down

    Size = instance.parameters.Size

    Transparency = instance.parameters.Transparency
    Zone = instance.parameters.Zone
    B_Zone = instance.parameters.B_Zone

    Level = instance.parameters.Level

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Alpha1 .. ", " .. Alpha2 .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    Second = instance:addInternalStream(0, 0)
    Signal = instance:addInternalStream(0, 0)
    Cross = instance:addInternalStream(0, 0)

    assert(
        core.indicators:findIndicator("SMOOTHED_ADX") ~= nil,
        "Please, download and install SMOOTHED_ADX.LUA indicator"
    )

    Indicator = core.indicators:create("SMOOTHED_ADX", source, Period, Alpha1, Alpha2)
    first = Indicator.DATA:first()

    instance:ownerDrawn(true)

    if Type == 2 then
        if not HollowUp and not HollowDown then
            open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
            high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
            low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
            close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
            instance:createCandleGroup("ZONE", "", open, high, low, close)
        else
            open = instance:addInternalStream(0, first)
            high = instance:addInternalStream(0, first)
            low = instance:addInternalStream(0, first)
            close = instance:addInternalStream(0, first)
        end
    end
end

function Update(period, mode)
    if (period < first) then
        return
    end

    if Type == 2 then
        high[period] = source.high[period]
        low[period] = source.low[period]
        close[period] = source.close[period]
        open[period] = source.open[period]
    end

    Indicator:update(mode)

    if Indicator.ADX[period] < Level then
        Signal[period] = 1
    else
        Signal[period] = 0
    end

    if Indicator.DIP[period] > Indicator.DIM[period] and Indicator.DIP[period - 1] <= Indicator.DIM[period - 1] then
        Cross[period] = 1
    end

    if Indicator.DIP[period] < Indicator.DIM[period] and Indicator.DIP[period - 1] >= Indicator.DIM[period - 1] then
        Cross[period] = -1
    end

    Second[period] = 0

    local Line, X = Last(period)
    if X == 1 and source.close[period] > Line and source.close[period - 1] <= Line then
        Second[period] = 1
    end

    if X == -1 and source.close[period] < Line and source.close[period - 1] >= Line then
        Second[period] = -1
    end
end

function Last(period)
    local Line = nil
    local X = nil

    for p = period, first, -1 do
        if Signal[p] == 1 or Signal[p] == -1 then
            X = Signal[p]
            if Signal[p] == 1 then
                Line = source.high[p]
            else
                Line = source.low[p]
            end
            break
        end
    end

    return Line, X
end

local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end
    if not init then
        context:createSolidBrush(1, Zone)
        context:createPen(6, context.SOLID, 1, Zone)
        Transparency = context:convertTransparency(instance.parameters.Transparency)
        context:createFont(2, "Wingdings", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
        context:createPen(3, context:convertPenStyle(instance.parameters.style), instance.parameters.width, Up)
        context:createPen(
            4,
            context:convertPenStyle(instance.parameters.style),
            context:pointsToPixels(instance.parameters.width),
            Down
        )
        context:createPen(
            5,
            context:convertPenStyle(instance.parameters.B_style),
            context:pointsToPixels(instance.parameters.B_width),
            B_Zone
        )
        context:createPen(11, context.SOLID, 1, Up_Candle)
        context:createSolidBrush(12, Up_Candle)
        context:createPen(13, context.SOLID, 1, Down_Candle)
        context:createSolidBrush(14, Down_Candle)
        context:createSolidBrush(15, background)
        init = true
    end

    p1 = nil
    p2 = nil
    for p = math.max(context:firstBar(), first + 1), math.min(context:lastBar(), source:size() - 1), 1 do
        visible, y1 = context:pointOfPrice(source.open[p])
        visible, y2 = context:pointOfPrice(source.close[p])
        visible, y3 = context:pointOfPrice(source.low[p])
        visible, y4 = context:pointOfPrice(source.high[p])
        x, x1, x2 = context:positionOfBar(p)
        width = (x2 - x1) * 0.7 / 2
        x3 = x - width
        x4 = x + width
        if Type == 2 then
            if source.close[p] > source.open[p] then
                if HollowUp or HollowDown then
                    context:drawRectangle(11, HollowUp and 15 or 12, x3, y1 + 1, x4, y2 - 1)
                    context:drawLine(11, x, y1, x, y3)
                    context:drawLine(11, x, y4, x, y2)
                else
                    open:setColor(p, Up_Candle)
                end
            else
                if HollowUp or HollowDown then
                    context:drawRectangle(13, HollowUp and 15 or 14, x3, y1 - 1, x4, y2 + 1)
                    context:drawLine(13, x, y4, x, y1)
                    context:drawLine(13, x, y2, x, y3)
                else
                    open:setColor(p, Down_Candle)
                end
            end
        end

        p2 = nil
        if Signal[p] == 1 and Signal[p - 1] ~= 1 then
            p1 = p
            p2 = nil
        end

        if (Signal[p - 1] == 1 and Signal[p] ~= 1) or (Signal[p] == 1 and p == source:size() - 1) then
            p2 = p
        end

        if p1 ~= nil and p2 ~= nil then
            min, max, minpos, maxpos = mathex.minmax(source, p1, p2)

            visible, y1 = context:pointOfPrice(max)
            visible, y2 = context:pointOfPrice(min)

            x1, x = context:positionOfBar(math.min(p1, p2))
            x2, x = context:positionOfBar(math.max(p1, p2))

            if Type == 1 then
                if Show then
                    context:drawRectangle(5, 1, x1, y1, x2, y2, Transparency)
                else
                    context:drawRectangle(-1, 1, x1, y1, x2, y2, Transparency)
                end
            else
                for k = math.min(p1, p2), math.max(p1, p2), 1 do
                    if HollowUp or HollowDown then
                        visible, y1 = context:pointOfPrice(source.open[k])
                        visible, y2 = context:pointOfPrice(source.close[k])
                        visible, y3 = context:pointOfPrice(source.low[k])
                        visible, y4 = context:pointOfPrice(source.high[k])
                        x, x1, x2 = context:positionOfBar(k)
                        width = (x2 - x1) * 0.7 / 2
                        x3 = x - width
                        x4 = x + width
                        if source.close[k] > source.open[k] then
                            context:drawRectangle(6, 1, x3, y1 + 1, x4, y2 - 1)
                            context:drawLine(6, x, y1, x, y3)
                            context:drawLine(6, x, y4, x, y2)
                        else
                            context:drawRectangle(6, 1, x3, y1 - 1, x4, y2 + 1)
                            context:drawLine(6, x, y1, x, y3)
                            context:drawLine(6, x, y4, x, y2)
                        end
                    else
                        open:setColor(p, Up_Candle)
                    end
                    open:setColor(k, Zone)
                end
            end
        end
        if Cross[p] == 1 then
            visible, y = context:pointOfPrice(source.low[p])
            x = context:positionOfBar(p)
            Text = U1
            width, height = context:measureText(2, Text, 0)
            context:drawText(2, Text, Up, -1, x - width / 2, y, x + width / 2, y + height, 0)

            visible, y = context:pointOfPrice(source.high[p])

            x1 = x
            p2 = FindNext(p, source.high[p], 1)
            if p2 ~= nil then
                visible, y2 = context:pointOfPrice(source.low[p2])
                x2, x = context:positionOfBar(p2)
                Text = U2
                width, height = context:measureText(2, Text, 0)
                context:drawText(2, Text, Up, -1, x2 - width / 2, y2, x2 + width / 2, y2 + height, 0)
                context:drawLine(3, x1, y, x2, y)
            end
        end

        if Cross[p] == -1 then
            x = context:positionOfBar(p)
            visible, y = context:pointOfPrice(source.high[p])
            Text = D1
            width, height = context:measureText(2, Text, 0)
            context:drawText(2, Text, Down, -1, x - width / 2, y - height, x + width / 2, y, 0)

            visible, y = context:pointOfPrice(source.low[p])
            x1 = x
            p2 = FindNext(p, source.low[p], -1)
            if p2 ~= nil then
                x2, x = context:positionOfBar(p2)
                visible, y2 = context:pointOfPrice(source.high[p2])
                Text = D2
                width, height = context:measureText(2, Text, 0)
                context:drawText(2, Text, Down, -1, x2 - width / 2, y2 - height, x2 + width / 2, y2, 0)
                context:drawLine(4, x1, y, x2, y)
            end
        end
    end
end

function FindNext(p, cross_level, side)
    local Return = nil

    for i = p, source:size() - 1, 1 do
        if
            (source.close[i] > cross_level and source.close[i - 1] <= cross_level and side == 1) or
                (source.close[i] < cross_level and source.close[i - 1] >= cross_level and side == -1)
         then
            Return = i
            break
        end
    end

    return Return
end
