-- Id: 23324
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67155

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
    indicator:name("ZigZag with Fibonacci")
    indicator:description("Automatic Fib or Gann levels on the base of H/L values")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator:setTag("Version", "1")
    indicator.parameters:addGroup("Zig Zag Parameters")
    indicator.parameters:addInteger(
        "Depth",
        "Depth",
        "the minimal amount of bars where there will not be the second maximum",
        12
    )
    indicator.parameters:addInteger(
        "Deviation",
        "Deviation",
        "Distance in pips to eliminate the second maximum in the last Depth periods",
        5
    )
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)
    indicator.parameters:addInteger("min_threshold", "Threshold, pips", "", 0);
    indicator.parameters:addColor("ZigZag_color_up", "Color of ZigZag (up)", "Color of ZigZag", core.rgb(0, 255, 0))
    indicator.parameters:addColor("ZigZag_color_down", "Color of ZigZag (down)", "Color of ZigZag", core.rgb(255, 0, 0))

    indicator.parameters:addGroup("Fibonacci/Gann Parameters")
    indicator.parameters:addBoolean("Show", "Show Lines", "", true)
    indicator.parameters:addString("M", "Lines Method", "", "F")
    indicator.parameters:addStringAlternative("M", "Fibonacci", "", "F")
    indicator.parameters:addStringAlternative("M", "Gann", "", "G")
    indicator.parameters:addString("L", "Levels number", "", "3")
    indicator.parameters:addStringAlternative("L", "3 Lines", "", "3")
    indicator.parameters:addStringAlternative("L", "3 Lines (alt)", "", "3a")
    indicator.parameters:addStringAlternative("L", "5 Lines", "", "5")
    indicator.parameters:addStringAlternative("L", "7 Lines", "", "7")
    indicator.parameters:addStringAlternative("L", "9 Lines", "", "9")
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("L_color", "Color of level lines", "", core.rgb(255, 255, 0))
    indicator.parameters:addInteger("L_width", "Width of level lines", "", 1, 1, 5)
    indicator.parameters:addInteger("L_style", "Style level lines", "", core.LINE_SOLID)
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("M_color", "Time marker color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("M_width", "Width of level lines", "", 1, 1, 5)
    indicator.parameters:addInteger("M_style", "Style level lines", "", core.LINE_DOT)
    indicator.parameters:setFlag("M_style", core.FLAG_LINE_STYLE)
    indicator.parameters:addBoolean("ShowLabels", "Show Line Labels", "", true)

    indicator.parameters:addColor("Color", "Font color", "", core.rgb(0, 0, 0))
    indicator.parameters:addInteger("Size", "Font Size", "", 10)

    indicator.parameters:addBoolean("ShowZigZag", "Show ZigZag Line", "", true)
    indicator.parameters:addBoolean("Extend", "Extend Lines", "", true)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth
local Deviation
local Backstep

local Show
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
local Extend, Size, Color, ShowZigZag

local barSize
local format

local first
local source = nil

-- Streams block
local ZigZag = nil
local HighMap = nil
local LowMap = nil
local Zig
-- Routine
function Prepare(nameOnly)
    Extend = instance.parameters.Extend
    Size = instance.parameters.Size
    Color = instance.parameters.Color
    ShowZigZag = instance.parameters.ShowZigZag

    Show = instance.parameters.Show
    M = instance.parameters.M
    L = instance.parameters.L
    -- E = instance.parameters.E;
    L_color = instance.parameters.L_color
    L_width = instance.parameters.L_width
    L_style = instance.parameters.L_style
    M_color = instance.parameters.M_color
    M_width = instance.parameters.M_width
    M_style = instance.parameters.M_style
    ShowLabels = instance.parameters.ShowLabels

    source = instance.source
    local s, e
    s, e = core.getcandle(source:barSize(), core.now(), 0)
    barSize = math.floor(((e - s) * 1440) + 0.5) / 1440

    format = "%.3f=%." .. source:getPrecision() .. "f"

    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep

    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ", " .. M .. ", " .. L .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    assert(core.indicators:findIndicator("ZIGZAG_THRESHOLD_PIPS") ~= nil, "ZIGZAG_THRESHOLD_PIPS" .. " indicator must be installed");
    Zig = core.indicators:create("ZIGZAG_THRESHOLD_PIPS", source, Depth, Deviation, Backstep, instance.parameters.min_threshold);
    first = Zig.DATA:first()

    if ShowZigZag then
        ZigZag = instance:addStream("ZigZag", core.Line, name, "ZigZag", instance.parameters.ZigZag_color_up, first)
    else
        ZigZag = instance:addInternalStream(0, 0)
    end
    HighMap = instance:addInternalStream(0, 0)
    LowMap = instance:addInternalStream(0, 0)

    if Show then
        instance:ownerDrawn(true)
    else
        instance:ownerDrawn(false)
    end
end

local searchBoth = 0
local searchPeak = 1
local searchLawn = -1
local lastlow = nil
local lashhigh = nil

-- optimization hint
local g_last_peak_date = nil
local g_last_peak = nil
local g_prev_peak_date = nil
local g_searchMode = nil
local MIN = nil
local MAX = nil
local P = nil
local levels = nil
local index = nil

function Update(period, mode)
    Zig:update(mode)

    if period < first then
        return
    end

    if Zig.DATA[period] == 0 or Zig.DATA[period] == nil then
        ZigZag[period] = nil
    else
        ZigZag[period] = Zig.DATA[period]
        if (period > 0 and ZigZag[period] > ZigZag[period - 1]) then
            ZigZag:setColor(period, instance.parameters.ZigZag_color_up);
        else
            ZigZag:setColor(period, instance.parameters.ZigZag_color_down);
        end
    end
end

local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end
    --period

    if not init then
        context:createPen(1, context:convertPenStyle(L_width), L_width, L_color)
        context:createPen(2, context:convertPenStyle(M_width), M_width, M_color)
        context:createFont(3, "Arial", Size, Size, context.LEFT)
        init = true
    end

    local min, max, minp, maxp
    local p1 = nil
    local p2 = nil

    for i = source:size() - 2, first, -1 do
        if Zig.DATA[i] == 0 or Zig.DATA[i] == nil then
            ZigZag[i] = nil
        else
            ZigZag[i] = Zig.DATA[i]
        end

        if
            p1 == nil and ZigZag[i + 1] ~= nil and ZigZag[i] ~= nil and ZigZag[i - 1] ~= nil and ZigZag[i + 1] ~= 0 and
                ZigZag[i] ~= 0 and
                ZigZag[i - 1] ~= 0
         then
            if ZigZag[i] > ZigZag[i - 1] and ZigZag[i] > ZigZag[i + 1] then
                p1 = i
            end
        end

        if
            p2 == nil and ZigZag[i + 1] ~= nil and ZigZag[i] ~= nil and ZigZag[i - 1] ~= nil and ZigZag[i + 1] ~= 0 and
                ZigZag[i] ~= 0 and
                ZigZag[i - 1] ~= 0
         then
            if ZigZag[i] < ZigZag[i - 1] and ZigZag[i] < ZigZag[i + 1] then
                p2 = i
            end
        end

        if p1 ~= nil and p2 ~= nil then
            break
        end
    end

    local Direction

    if ZigZag[p1] > ZigZag[p2] then
        min = ZigZag[p2]
        max = ZigZag[p1]
        minp = p2
        maxp = p1
        Direction = 1
    elseif ZigZag[p1] > ZigZag[p2] then
        min = ZigZag[p1]
        max = ZigZag[p2]
        minp = p1
        maxp = p2
        Direction = -1
    else
        return
    end

    CalculateLevels(min, max, minp, maxp, Direction, context)
end

function CalculateLevels(min, max, minp, maxp, Direction, context)
    local N = 10

    local p, k, v, f, t, price, d, label

    p = math.min(minp, maxp)

    MIN = min
    MAX = max
    d = max - min
    P = p

    if levels == nil then
        CalcLevels(Direction)
    end
    local idx
    idx = index[L]

    if Extend then
        t = context:right()
        f, x1, x2 = context:positionOfBar(p)
    else
        t = context:positionOfBar(source:size() - 1)
        f, x1, x2 = context:positionOfBar(p)
    end

    for k, v in pairs(idx) do
        if Direction == -1 then
            price = min + d * levels[v]
        else
            price = max - d * levels[v]
        end
        --i

        label = string.format(format, levels[v], price)

        visible1, y1 = context:pointOfPrice(price)

        context:drawLine(1, f, y1, t, y1)

        if ShowLabels then
            local width, height = context:measureText(3, label, context.LEFT)
            context:drawText(3, label, Color, -1, f, y1 - height, f + width, y1, context.LEFT)
        end
    end

    visible1, y1 = context:pointOfPrice(min)
    visible2, y2 = context:pointOfPrice(max)
    context:drawLine(2, f, y1, f, y2)
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
    else
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
    end
end
