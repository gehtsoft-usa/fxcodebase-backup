-- Id: 17826
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60727

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

-- Indicator profile initialization routine
function Init()
    indicator:name("ZigZag Channel")
    indicator:description(" ")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12)
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5)
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)
    indicator.parameters:addInteger("Period", "Period", "Period", 1)
    indicator.parameters:addInteger("zz", "Period", "Period", 1)

    indicator.parameters:addGroup("Zig Zag Line Style")
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addGroup("Line Style")
    indicator.parameters:addColor("UpColor", "Up Line color", "Up Line color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DownColor", "Down Line color", "Down Line color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("Width", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("Style", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("Style", core.FLAG_LEVEL_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth
local Deviation
local Backstep

local first
local source = nil
local Period
-- Streams block
local ZigC
local ZagC
local out
local HighMap = nil
local LowMap = nil
local TextBuff = nil
local AverageBuff = nil
local pipSize
local format
local Top, Bottom
local Width, UpColor, DownColor, Style
-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    Period = instance.parameters.Period
    source = instance.source
    first = source:first()

    Width = instance.parameters.Width
    UpColor = instance.parameters.UpColor
    DownColor = instance.parameters.DownColor
    Style = instance.parameters.Style

    format = "%." .. 1 .. "f"

    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ", " .. Period .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first)
    out:setWidth(instance.parameters.widthZigZag)
    out:setStyle(instance.parameters.styleZigZag)

    Top = instance:addStream("Top", core.Line, name, "Top", UpColor, first)
    Top:setWidth(Width)
    Top:setStyle(Style)

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", DownColor, first)
    Bottom:setWidth(Width)
    Bottom:setStyle(Style)

    ZigC = instance.parameters.Zig_color
    ZagC = instance.parameters.Zag_color

    HighMap = instance:addInternalStream(0, 0)
    LowMap = instance:addInternalStream(0, 0)
    SearchMode = instance:addInternalStream(0, 0)
    Peak = instance:addInternalStream(0, 0)
    pipSize = source:pipSize()
end

local searchBoth = 0
local searchPeak = 1
local searchLawn = -1
local lastlow = nil
local lashhigh = nil

function RegisterPeak(period, mode, peak)
    out:setBookmark(1, out:getBookmark(2))
    out:setBookmark(2, period)
    SearchMode[period] = mode
    Peak[period] = peak
end

function ReplaceLastPeak(period, mode, peak)
    out:setBookmark(2, period)
    SearchMode[period] = mode
    Peak[period] = peak
end

local lastserial = -1

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1
    if period < 0 or source:serial(period) == lastserial then
        return
    end

    if mode == core.UpdateAll then
        lastlow = nil
        lasthigh = nil
    end

    lastserial = source:serial(period);

    if period < Depth then
        return;
    end
    -- fill high/low maps
    local range = period - Depth + 1
    -- get the lowest low for the last depth periods
    local val = mathex.min(source, range, period)
    if val == lastlow then
        -- if lowest low is not changed - ignore it
        val = nil
    else
        -- keep it
        lastlow = val
        -- if current low is higher for more than Deviation pips, ignore
        if (source[period] - val) > (source:pipSize() * Deviation) then
            val = nil
        else
            -- check for the previous backstep lows
            for i = period - 1, period - Backstep + 1, -1 do
                if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                    LowMap[i] = 0
                end
            end
        end
    end
    if source[period] == val then
        LowMap[period] = val
    else
        LowMap[period] = 0
    end
    -- get the lowest low for the last depth periods
    val = mathex.max(source, range, period)
    if val == lasthigh then
        -- if lowest low is not changed - ignore it
        val = nil
    else
        -- keep it
        lasthigh = val
        -- if current low is higher for more than Deviation pips, ignore
        if (val - source[period]) > (source:pipSize() * Deviation) then
            val = nil
        else
            -- check for the previous backstep lows
            for i = period - 1, period - Backstep + 1, -1 do
                if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                    HighMap[i] = 0
                end
            end
        end
    end
    if source[period] == val then
        HighMap[period] = val
    else
        HighMap[period] = 0
    end

    local prev_peak = out:getBookmark(1)
    local start = Depth
    local last_peak_i = out:getBookmark(2)
    if last_peak_i ~= -1 then
        start = last_peak_i
    end

    for i = start, period, 1 do
        if last_peak_i == -1 then
            if (HighMap[i] ~= 0) then
                last_peak_i = i
                RegisterPeak(i, searchLawn, HighMap[i])
            elseif (LowMap[i] ~= 0) then
                last_peak_i = i
                RegisterPeak(i, searchPeak, LowMap[i])
            end
        elseif SearchMode[last_peak_i] == searchPeak then
            if (LowMap[i] ~= 0 and LowMap[i] < Peak[last_peak_i]) then
                last_peak_i = i
                if prev_peak ~= -1 then
                    core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZagC)
                    out:setColor(prev_peak, ZigC)
                end
                ReplaceLastPeak(i, searchPeak, LowMap[i])
            end
            if HighMap[i] ~= 0 and LowMap[i] == 0 then
                core.drawLine(out, core.range(last_peak_i, i), Peak[last_peak_i], last_peak_i, HighMap[i], i, ZigC)
                out:setColor(last_peak_i, ZagC)
                prev_peak = last_peak_i
                last_peak_i = i
                RegisterPeak(i, searchLawn, HighMap[i])
            end
        elseif SearchMode[last_peak_i] == searchLawn then
            if (HighMap[i] ~= 0 and HighMap[i] > Peak[last_peak_i]) then
                last_peak_i = i
                if prev_peak ~= -1 then
                    core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i, ZigC)
                    out:setColor(prev_peak, ZagC)
                end
                ReplaceLastPeak(i, searchLawn, HighMap[i])
            end
            if LowMap[i] ~= 0 and HighMap[i] == 0 then
                if Peak[last_peak_i] > LowMap[i] then
                    core.drawLine(out, core.range(last_peak_i, i), Peak[last_peak_i], last_peak_i, LowMap[i], i, ZagC)
                    out:setColor(last_peak_i, ZigC)
                else
                    core.drawLine(out, core.range(last_peak_i, i), Peak[last_peak_i], last_peak_i, LowMap[i], i, ZigC)
                    out:setColor(last_peak_i, ZagC)
                end
                prev_peak = last_peak_i
                last_peak_i = i
                RegisterPeak(i, searchPeak, LowMap[i])
            end
        end
    end

    if period < source:size() - 2 then
        return
    end

    local Up = {}
    local Down = {}
    local Total = 0
    local searchMode = 0;
    for i = source:size() - 2, first, -1 do
        if (SearchMode[i] ~= searchMode and SearchMode[i] ~= 0) then
            Total = Total + 1
            if searchMode == searchLawn then
                searchMode = searchPeak;
                if Total > Period then
                    Up[#Up + 1] = i
                end
            else
                searchMode = searchLawn;
                if Total > Period then
                    Down[#Down + 1] = i
                end
            end
            if Total == Period + 4 then
                DrawLine(Up[1], Up[2], Top, UpColor)
                DrawLine(Down[1], Down[2], Bottom, DownColor)
                break
            end
        end
    end
end

function DrawLine(x1, x2, target, color)
    local y1 = source[x1]
    local y2 = source[x2]
    local a1, c1 = math2d.lineEquation(x1, y1, x2, y2)
    local Y1 = (source:size() - 1) * a1 + c1
    core.drawLine(target, core.range(x2, source:size() - 1), y2, x2, Y1, source:size() - 1, color)
    for period = x2 - 1, first, -1 do
        if target[period] ~= nil then
            target[period] = nil
        else
            break
        end
    end
end
