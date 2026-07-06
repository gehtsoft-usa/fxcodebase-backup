-- Id: 15620
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63226

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
    indicator:name("Dynamic Fibonacci")
    indicator:description("Automatic Fib or Gann levels base on Fractal H/L values")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Parameters")
    indicator.parameters:addInteger("Number", "Number of Fibonacci ", "", 5)
    indicator.parameters:addString("M", "Lines Method", "", "F")
    indicator.parameters:addStringAlternative("M", "Fibonacci", "", "F")
    indicator.parameters:addStringAlternative("M", "Gann", "", "G")
    indicator.parameters:addStringAlternative("M", "Custom", "", "C")

    indicator.parameters:addString("L", "Levels number", "", "3")
    indicator.parameters:addStringAlternative("L", "3 Lines", "", "3")
    indicator.parameters:addStringAlternative("L", "3 Lines (alt)", "", "3a")
    indicator.parameters:addStringAlternative("L", "5 Lines", "", "5")
    indicator.parameters:addStringAlternative("L", "7 Lines", "", "7")
    indicator.parameters:addStringAlternative("L", "9 Lines", "", "9")
    indicator.parameters:addInteger("E", "Number of bars to show lines after the latest bar char", "", 5, 1, 100)

    indicator.parameters:addBoolean("Flip", "Use L-H instead H-L", "", false)

    indicator.parameters:addGroup("Custom Levels")
    indicator.parameters:addDouble("L1", "1. Level", "", -0.236)
    indicator.parameters:addDouble("L2", "2. Level", "", 0)
    indicator.parameters:addDouble("L3", "3. Level", "", 0.236)
    indicator.parameters:addDouble("L4", "4. Level", "", 0.382)
    indicator.parameters:addDouble("L5", "5. Level", "", 0.5)
    indicator.parameters:addDouble("L6", "6. Level", "", 0.618)
    indicator.parameters:addDouble("L7", "7. Level", "", 0.764)
    indicator.parameters:addDouble("L8", "8. Level", "", 1)
    indicator.parameters:addDouble("L9", "9. Level", "", 1.272)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Label_Color", "Color of Label", "", core.rgb(0, 0, 0))
    indicator.parameters:addInteger("Size", "Label Font Size", "", 12)
    indicator.parameters:addColor("L_color", "Color of level lines", "", core.rgb(255, 255, 0))
    indicator.parameters:addInteger("L_width", "Width of level lines", "", 1, 1, 5)
    indicator.parameters:addInteger("L_style", "Style level lines", "", core.LINE_SOLID)
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("M_color", "Time marker color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("M_width", "Width of level lines", "", 1, 1, 5)
    indicator.parameters:addInteger("M_style", "Style level lines", "", core.LINE_DOT)
    indicator.parameters:setFlag("M_style", core.FLAG_LINE_STYLE)
    indicator.parameters:addBoolean("ShowLabels", "Show Line Labels", "", true)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N
local M
local L
local E
local L_color
local L_width
local L_style
local M_color
local M_width
local M_style
local ShowLabels
local Flip
local Number
local Size
local first
local source = nil
local barSize
local format
local Labe_Color
-- Streams block
local D = nil
local Signal
-- Routine
function Prepare(nameOnly)
    Number = instance.parameters.Number
    Label_Color = instance.parameters.Label_Color
    Size = instance.parameters.Size
    M = instance.parameters.M
    L = instance.parameters.L
    E = instance.parameters.E
    L_color = instance.parameters.L_color
    L_width = instance.parameters.L_width
    L_style = instance.parameters.L_style
    M_color = instance.parameters.M_color
    M_width = instance.parameters.M_width
    M_style = instance.parameters.M_style
    ShowLabels = instance.parameters.ShowLabels
    Flip = instance.parameters.Flip

    source = instance.source

    local name = profile:id() .. "(" .. source:name() .. ", " .. M .. ", " .. L .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    Signal = instance:addInternalStream(0, 0)

    first = source:first() + 4
    format = "%.3f=%." .. source:getPrecision() .. "f"

    instance:ownerDrawn(true)
end

local MIN = nil
local MAX = nil
local P = nil
local levels = nil
local index = nil
local Data = {}
-- Indicator calculation routine
function Update(period)
    if period < first then
        return
    end

    Signal[period - 2] = 0

    curr = source.high[period - 2]
    if
        (curr >= source.high[period - 4] and curr >= source.high[period - 3] and curr >= source.high[period - 1] and
            curr >= source.high[period])
     then
        Signal[period - 2] = 1
    end

    curr = source.low[period - 2]
    if
        (curr <= source.low[period - 4] and curr <= source.low[period - 3] and curr <= source.low[period - 1] and
            curr <= source.low[period])
     then
        Signal[period - 2] = -1
    end

    curr1 = source.high[period - 2]
    curr2 = source.low[period - 2]

    if
        (curr1 >= source.high[period - 4] and curr1 >= source.high[period - 3] and curr1 >= source.high[period - 1] and
            curr1 >= source.high[period]) and
            (curr2 <= source.low[period - 4] and curr2 <= source.low[period - 3] and curr2 <= source.low[period - 1] and
                curr2 <= source.low[period])
     then
        Signal[period - 2] = -2
    end
end

local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        context:createPen(1, context:convertPenStyle(L_style), L_width, L_color)
        context:createPen(2, context:convertPenStyle(M_style), M_width, M_color)
        context:createFont(3, "Arial", Size, Size, 0)
        init = true
    end

    Find()

    for i = 1, (#Data - 1), 1 do
        Calculate(i, context)
    end
end

function Find()
    Data = {}

    local Count = 0
    for period = (source:size() - 2), first, -1 do
        if Signal[period] == 1 or Signal[period] == -2 then
            Count = Count + 1
            Data[Count] = period
        end

        if Count > Number then
            break
        end
    end
end

function Calculate(i, context)
    x1, x = context:positionOfBar(source:size() - 1)
    x2, x = context:positionOfBar(source:size() - 2)
    barSize = x1 - x2

    local min, max, Price1, Price2, Period1, Period2, p, k, v, price, d, label

    if Signal[Data[i]] == 1 then
        Price1 = source.high[Data[i]]
        Period1 = Data[i]

        Price2, Period2 = Second(Data[i], false)
    end

    if Signal[Data[i] == -2] then
        Price1 = source.high[Data[i]]
        Period1 = Data[i]

        Price2 = source.low[Data[i]]
        Period2 = Data[i]
    end

    if Price1 == nil or Period2 == nil then
        return
    end

    p1 = math.min(Period1, Period2)
    p2 = math.max(Period1, Period2)

    min = math.min(Price1, Price2)
    max = math.max(Price1, Price2)
    d = max - min
    P = p

    if levels == nil then
        CalcLevels()
    end
    local idx
    idx = index[L]

    x1, x = context:positionOfBar(p1)
    x2, x = context:positionOfBar(p2 + E)

    if p2 + E > source:size() - 1 then
        x2 = context:positionOfBar(source:size() - 1) + (E - 1) * barSize
    end

    for k, v in pairs(idx) do
        if Flip then
            price = max - d * levels[v]
        else
            price = min + d * levels[v]
        end

        label = string.format(format, levels[v], source.close[source.close:size() - 1])

        visible, y = context:pointOfPrice(price)
        context:drawLine(1, x1, y, x2, y + 1)
        if ShowLabels then
            width, height = context:measureText(3, label, context.LEFT)
            context:drawText(3, label, Label_Color, -1, x1, y - height, x1 + width, y, context.LEFT)
        end
    end

    visible, y1 = context:pointOfPrice(min)
    visible, y2 = context:pointOfPrice(max)
    context:drawLine(2, x1, y1, x1 + 1, y2, 0)
end

function Second(Index, flag)
    for period = Index, source:size() - 1, 1 do
        if not Flag and (Signal[period] == -1 or Signal[period] == -2) then
            return source.low[period], period
        end
    end
end

function CalcLevels()
    levels = {}
    index = {}
    if M == "F" then
        levels[1] = -0.236
        levels[2] = 0
        levels[3] = 0.236
        levels[4] = 0.382
        levels[5] = 0.5
        levels[6] = 0.618
        levels[7] = 0.764
        levels[8] = 1
        levels[9] = 1.272
        index["3"] = {4, 5, 6}
        index["3a"] = {2, 5, 8}
        index["5"] = {2, 4, 5, 6, 8}
        index["7"] = {2, 3, 4, 5, 6, 7, 8}
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    elseif M == "G" then
        levels[1] = 0
        levels[2] = 0.125
        levels[3] = 0.25
        levels[4] = 0.375
        levels[5] = 0.5
        levels[6] = 0.625
        levels[7] = 0.75
        levels[8] = 0.875
        levels[9] = 1
        index["3"] = {3, 5, 7}
        index["3a"] = {1, 5, 9}
        index["5"] = {1, 3, 5, 7, 9}
        index["7"] = {1, 3, 4, 5, 6, 7, 9}
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    elseif M == "C" then
        levels[1] = instance.parameters.L1
        levels[2] = instance.parameters.L2
        levels[3] = instance.parameters.L3
        levels[4] = instance.parameters.L4
        levels[5] = instance.parameters.L5
        levels[6] = instance.parameters.L6
        levels[7] = instance.parameters.L7
        levels[8] = instance.parameters.L8
        levels[9] = instance.parameters.L9
        index["3"] = {4, 5, 6}
        index["3a"] = {2, 5, 8}
        index["5"] = {2, 4, 5, 6, 8}
        index["7"] = {2, 3, 4, 5, 6, 7, 8}
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    end
end
