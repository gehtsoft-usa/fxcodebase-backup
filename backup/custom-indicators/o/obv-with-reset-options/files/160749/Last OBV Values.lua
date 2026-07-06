-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76348
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com
--
-- Last OBV Values (Owner-Draw) — MATCHES "OBV (with Reset Options)"
-- Prints latest OBV values for four reset modes. Computation logic aligned to:
-- OBV (with Reset Options).lua  (baseline=0 at first bar, same reset triggers).
-- Platform: FXCM Trading Station (Indicore)
-- ------------------------------------------------------------------------------

function Init()
    indicator:name("Last OBV Values (Owner-Draw)")
    indicator:description("Owner-drawn block that prints latest OBV values for four reset modes (aligned with OBV (with Reset Options)).")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    -- Session boundaries (used by SessionStart/SessionEnd resets)
    indicator.parameters:addGroup("Session")
    indicator.parameters:addInteger("SessHH", "Session start hour", "0–23", 9, 0, 23)
    indicator.parameters:addInteger("SessMM", "Session start minute", "0–59", 30, 0, 59)
    indicator.parameters:addInteger("SessEndHH", "Session end hour", "0–23", 16, 0, 23)
    indicator.parameters:addInteger("SessEndMM", "Session end minute", "0–59", 0, 0, 59)

    -- Volume handling
    indicator.parameters:addGroup("Volume")
    indicator.parameters:addBoolean("UseTickFallback", "If volume is missing, use 1 tick per bar", "", true)

    -- Display
    indicator.parameters:addGroup("Display")
    indicator.parameters:addString("Corner", "Screen corner", "Where to place the block", "TopRight")
    indicator.parameters:addStringAlternative("Corner", "Top-left",     "TopLeft",    "TopLeft")
    indicator.parameters:addStringAlternative("Corner", "Top-right",    "TopRight",   "TopRight")
    indicator.parameters:addStringAlternative("Corner", "Bottom-left",  "BottomLeft", "BottomLeft")
    indicator.parameters:addStringAlternative("Corner", "Bottom-right", "BottomRight","BottomRight")

    indicator.parameters:addInteger("MarginX", "Horizontal margin (px)", "", 10, 0, 300)
    indicator.parameters:addInteger("MarginY", "Vertical margin (px)",   "", 10, 0, 300)
    indicator.parameters:addInteger("FontPx",  "Font size (px)",         "", 13, 8, 48)
    indicator.parameters:addInteger("LineGap", "Line spacing (px)",      "", 2, 0, 30)

    indicator.parameters:addColor("C_None",      "Color: OBV None",        "", core.rgb(210,210,210))
    indicator.parameters:addColor("C_Day",       "Color: Start of Day",    "", core.rgb( 80,200,255))
    indicator.parameters:addColor("C_SessStart", "Color: Session Start",   "", core.rgb(120,255,120))
    indicator.parameters:addColor("C_SessEnd",   "Color: Session End",     "", core.rgb(255,160, 80))
end

-- ==== locals/state ====
local src, firstBar
local UseTickFallback
local SessHH, SessMM, SessEndHH, SessEndMM
local Corner, MarginX, MarginY, FontPx, LineGap
local C_None, C_Day, C_SessStart, C_SessEnd

-- internal OBV streams (aligned with reference logic)
local obvNone, obvDay, obvSS, obvSE
-- cached last values
local lastNone, lastDay, lastSS, lastSE

-- GDI
local fontReady = false
local FONT_ID = 1

-- ==== helpers ====
local function seconds(hh, mm) return hh*3600 + mm*60 end
local function dayHM(day, hh, mm) return day + seconds(hh, mm) / 86400 end

-- Exactly like reference: trigger when previous < daily mark and current >= daily mark,
-- checking both previous-day mark and current-day mark for safety across midnight.
local function crossesDailyTime(prev_t, t, hh, mm)
    local dPrev = math.floor(prev_t)
    local dCurr = math.floor(t)
    local tp = dayHM(dPrev, hh, mm)
    local tc = dayHM(dCurr, hh, mm)
    if (prev_t < tp and t >= tp) then return true end
    if (prev_t < tc and t >= tc) then return true end
    return false
end

local function getVolume(p)
    if src.volume ~= nil and src.volume:hasData(p) then
        local v = src.volume[p]
        if v ~= nil then return v end
    end
    return UseTickFallback and 1 or 0
end

local function sign(x)
    if x > 0 then return 1 elseif x < 0 then return -1 else return 0 end
end

function Prepare(nameOnly)
    src = instance.source
    -- MATCH the reference baseline: start computing at src:first(),
    -- set OBV=0 at first bar, then start deltas from next bar.
    firstBar = src:first()

    local instName = src:name()
    instance:name(profile:id() .. "(" .. instName .. ") LastOBV")
    instance:ownerDrawn(true)
    if nameOnly then return end

    UseTickFallback = instance.parameters.UseTickFallback
    SessHH, SessMM  = instance.parameters.SessHH,    instance.parameters.SessMM
    SessEndHH       = instance.parameters.SessEndHH
    SessEndMM       = instance.parameters.SessEndMM

    Corner  = instance.parameters.Corner
    MarginX = instance.parameters.MarginX
    MarginY = instance.parameters.MarginY
    FontPx  = instance.parameters.FontPx
    LineGap = instance.parameters.LineGap

    C_None      = instance.parameters.C_None
    C_Day       = instance.parameters.C_Day
    C_SessStart = instance.parameters.C_SessStart
    C_SessEnd   = instance.parameters.C_SessEnd

    -- internal streams (we fill from firstBar onward; period==firstBar is baseline=0)
    obvNone = instance:addInternalStream(firstBar, 0)
    obvDay  = instance:addInternalStream(firstBar, 0)
    obvSS   = instance:addInternalStream(firstBar, 0)
    obvSE   = instance:addInternalStream(firstBar, 0)

    lastNone, lastDay, lastSS, lastSE = 0, 0, 0, 0
    fontReady = false
end

function Update(period, mode)
    if period < firstBar then return end
    -- Baseline at first bar: OBV = 0 for all modes (exactly as in OBV (with Reset Options))
    if period == firstBar then
        obvNone[period] = 0
        obvDay[period]  = 0
        obvSS[period]   = 0
        obvSE[period]   = 0

        lastNone = 0; lastDay = 0; lastSS = 0; lastSE = 0
        return
    end

    if not src:hasData(period) or not src:hasData(period-1) then return end

    local c  = src.close[period]
    local pc = src.close[period-1]
    if c == nil or pc == nil then return end

    local s   = sign(c - pc)
    local vol = getVolume(period)

    local t  = src:date(period)
    local pt = src:date(period-1)

    -- =======================
    -- None (no reset)
    -- =======================
    local prevNone = obvNone[period-1]
    if prevNone == nil then prevNone = 0 end
    obvNone[period] = prevNone + s*vol

    -- =======================
    -- Start of Day (reset on day change)
    -- =======================
    local prevDay = obvDay[period-1]
    if prevDay == nil then prevDay = 0 end
    if math.floor(t) ~= math.floor(pt) then
        prevDay = 0
    end
    obvDay[period] = prevDay + s*vol

    -- =======================
    -- Session Start (reset at SessHH:SessMM)
    -- =======================
    local prevSS = obvSS[period-1]
    if prevSS == nil then prevSS = 0 end
    if crossesDailyTime(pt, t, SessHH, SessMM) then
        prevSS = 0
    end
    obvSS[period] = prevSS + s*vol

    -- =======================
    -- Session End (reset at SessEndHH:SessEndMM)
    -- =======================
    local prevSE = obvSE[period-1]
    if prevSE == nil then prevSE = 0 end
    if crossesDailyTime(pt, t, SessEndHH, SessEndMM) then
        prevSE = 0
    end
    obvSE[period] = prevSE + s*vol

    -- cache last values
    lastNone = obvNone[period]
    lastDay  = obvDay[period]
    lastSS   = obvSS[period]
    lastSE   = obvSE[period]
end

-- Owner-draw
local function ensureFont(context)
    if fontReady then return end
    context:createFont(FONT_ID, "Arial", 0, FontPx, 0)
    fontReady = true
end

function Draw(stage, context)
    if stage ~= 2 then return end
    ensureFont(context)

    local lines = {
        { txt = string.format("OBV None: %d",         math.floor(lastNone or 0)), col = C_None },
        { txt = string.format("OBV StartOfDay: %d",   math.floor(lastDay  or 0)), col = C_Day },
        { txt = string.format("OBV SessionStart: %d", math.floor(lastSS  or 0)), col = C_SessStart },
        { txt = string.format("OBV SessionEnd: %d",   math.floor(lastSE  or 0)), col = C_SessEnd },
    }

    local maxw, lh = 0, 0
    local styleMeasure = context.SINGLELINE + context.LEFT + context.TOP
    for i = 1, #lines do
        local w, h = context:measureText(FONT_ID, lines[i].txt, styleMeasure)
        if w > maxw then maxw = w end
        if h > lh   then lh = h end
    end
    local blockW = maxw
    local blockH = (#lines * lh) + ((#lines - 1) * LineGap)

    local left, top, right, bottom = context:left(), context:top(), context:right(), context:bottom()
    local x1, y1
    if     Corner == "TopLeft" then
        x1, y1 = left + MarginX, top + MarginY
    elseif Corner == "TopRight" then
        x1, y1 = right - MarginX - blockW, top + MarginY
    elseif Corner == "BottomLeft" then
        x1, y1 = left + MarginX, bottom - MarginY - blockH
    else
        x1, y1 = right - MarginX - blockW, bottom - MarginY - blockH
    end

    local drawStyle = context.SINGLELINE + context.LEFT + context.TOP
    local y = y1
    for i = 1, #lines do
        local w, h = context:measureText(FONT_ID, lines[i].txt, drawStyle)
        local x2 = x1 + w
        local y2 = y  + h
        context:drawText(FONT_ID, lines[i].txt, lines[i].col, -1, x1, y, x2, y2, drawStyle, 0)
        y = y + h + LineGap
    end
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76348
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- <https://www.gnu.org/licenses/>.
