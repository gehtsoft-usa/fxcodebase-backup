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

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.

function Init()
    indicator:name("Last OBV – Session Strength Dashboard (T/E/O)")
    indicator:description("Daily OBV strength split into Trading / Extended / Off-hours (+ optional Standard). Today vs Yesterday AVG; SUM optional.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    -- ===== Buckets enable =====
    indicator.parameters:addGroup("Buckets")
    indicator.parameters:addBoolean("EnableTrading",  "Show Trading (Regular)", "", true)
    indicator.parameters:addBoolean("EnableExtended", "Show Extended", "", true)
    indicator.parameters:addBoolean("EnableOffhours", "Show Off-hours (everything outside T & E)", "", true)
    indicator.parameters:addBoolean("EnableStandard", "Show Standard OBV (full day)", "", true)

    -- ===== Session windows =====
    indicator.parameters:addGroup("Trading (Regular) window")
    indicator.parameters:addString("RegularStart", "Regular Start (HH:MM)", "", "09:30")
    indicator.parameters:addString("RegularEnd",   "Regular End (HH:MM)",   "", "16:00")

    indicator.parameters:addGroup("Extended window")
    indicator.parameters:addString("ExtStart", "Extended Start (HH:MM)", "", "04:00")
    indicator.parameters:addString("ExtEnd",   "Extended End (HH:MM)",   "", "20:00")

    -- ===== Volume & Display =====
    indicator.parameters:addGroup("Volume")
    indicator.parameters:addBoolean("UseTickFallback", "If volume missing, use 1 per bar", "", true)

    indicator.parameters:addGroup("Display")
    indicator.parameters:addString("Corner", "Screen corner", "", "TopRight")
    indicator.parameters:addStringAlternative("Corner", "Top-left",     "", "TopLeft")
    indicator.parameters:addStringAlternative("Corner", "Top-right",    "", "TopRight")
    indicator.parameters:addStringAlternative("Corner", "Bottom-left",  "", "BottomLeft")
    indicator.parameters:addStringAlternative("Corner", "Bottom-right", "", "BottomRight")

    indicator.parameters:addInteger("MarginX", "Horizontal margin (px)", "", 12, 0, 300)
    indicator.parameters:addInteger("MarginY", "Vertical margin (px)",   "", 12, 0, 300)
    indicator.parameters:addInteger("FontPx",  "Font size (px)",         "", 13, 8, 48)
    indicator.parameters:addInteger("LineGap", "Line spacing (px)",      "", 2, 0, 30)

    indicator.parameters:addBoolean("ShowSum", "Also show SUM rows", "", false)

    indicator.parameters:addGroup("Colors")
    indicator.parameters:addColor("C_Title",     "Color: Title",         "", core.rgb(210,210,210))
    indicator.parameters:addColor("C_Trading",   "Color: Trading rows",  "", core.rgb(120,255,120))
    indicator.parameters:addColor("C_Extended",  "Color: Extended rows", "", core.rgb( 80,200,255))
    indicator.parameters:addColor("C_Offhours",  "Color: Off-hours rows","", core.rgb(255,160, 80))
    indicator.parameters:addColor("C_Standard",  "Color: Standard OBV",  "", core.rgb(200,200,200))
end

-- ===== locals / state =====
local src, firstBar
local UseTickFallback
local Corner, MarginX, MarginY, FontPx, LineGap, ShowSum
local EnableTrading, EnableExtended, EnableOffhours, EnableStandard
local C_Title, C_Trading, C_Extended, C_Offhours, C_Standard

-- windows
local rs_h, rs_m, re_h, re_m   -- Regular
local es_h, es_m, ee_h, ee_m   -- Extended

-- dayBuckets[day] = { T_sum, T_cnt, E_sum, E_cnt, O_sum, O_cnt, S_sum, S_cnt }
local dayBuckets

-- GDI
local fontReady = false
local FONT_ID = 1

-- ===== helpers =====
local function parseHHMM(s)
    local h, m = string.match(s or "", "^(%d%d?):(%d%d)$")
    h = tonumber(h or 0) or 0
    m = tonumber(m or 0) or 0
    if h < 0 then h = 0 elseif h > 23 then h = 23 end
    if m < 0 then m = 0 elseif m > 59 then m = 59 end
    return h, m
end

local function minutesOfDay(t)
    local frac = t - math.floor(t)
    return math.floor(frac * 1440 + 0.5)
end

-- inclusive start, exclusive end; supports wrap over midnight
local function inWindow(t, sh, sm, eh, em)
    local cur = minutesOfDay(t)
    local s = sh*60 + sm
    local e = eh*60 + em
    if s == e then return true end
    if s < e then return (cur >= s) and (cur < e)
    else               return (cur >= s) or  (cur < e) end
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

local function ensureBucket(d)
    local b = dayBuckets[d]
    if b == nil then
        b = {0,0, 0,0, 0,0, 0,0}
        dayBuckets[d] = b
    end
    return b
end

local function safeAvg(sum, cnt)
    if cnt == 0 then return 0 end
    return sum / cnt
end

-- bucket routing for a single bar time t
local function whichBucket(t)
    local inT = inWindow(t, rs_h, rs_m, re_h, re_m)
    local inE = inWindow(t, es_h, es_m, ee_h, ee_m)
    -- Priority: Trading, then Extended, else Off-hours
    if inT then return "T" end
    if inE then return "E" end
    return "O"
end

-- ===== lifecycle =====
function Prepare(nameOnly)
    src = instance.source
    firstBar = src:first()

    local instName = src:name()
    instance:name(profile:id() .. "(" .. instName .. ") Session Strength T/E/O")
    instance:ownerDrawn(true)
    if nameOnly then return end

    EnableTrading  = instance.parameters.EnableTrading
    EnableExtended = instance.parameters.EnableExtended
    EnableOffhours = instance.parameters.EnableOffhours
    EnableStandard = instance.parameters.EnableStandard

    rs_h, rs_m = parseHHMM(instance.parameters.RegularStart)
    re_h, re_m = parseHHMM(instance.parameters.RegularEnd)

    es_h, es_m = parseHHMM(instance.parameters.ExtStart)
    ee_h, ee_m = parseHHMM(instance.parameters.ExtEnd)

    UseTickFallback = instance.parameters.UseTickFallback
    Corner  = instance.parameters.Corner
    MarginX = instance.parameters.MarginX
    MarginY = instance.parameters.MarginY
    FontPx  = instance.parameters.FontPx
    LineGap = instance.parameters.LineGap
    ShowSum = instance.parameters.ShowSum

    C_Title    = instance.parameters.C_Title
    C_Trading  = instance.parameters.C_Trading
    C_Extended = instance.parameters.C_Extended
    C_Offhours = instance.parameters.C_Offhours
    C_Standard = instance.parameters.C_Standard

    dayBuckets = {}
    fontReady = false
end

function Update(period, mode)
    if period < firstBar then return end
    if not src:hasData(period) or not src:hasData(period-1) then return end

    local c  = src.close[period]
    local pc = src.close[period-1]
    if c == nil or pc == nil then return end

    local d  = sign(c - pc) * getVolume(period)
    local t  = src:date(period)
    local dKey = math.floor(t)
    local b = ensureBucket(dKey)

    -- Route to Trading / Extended / Off-hours
    local bucket = whichBucket(t)
    if bucket == "T" then
        b[1] = b[1] + d; b[2] = b[2] + 1
    elseif bucket == "E" then
        b[3] = b[3] + d; b[4] = b[4] + 1
    else
        b[5] = b[5] + d; b[6] = b[6] + 1
    end

    -- Standard (full day)
    b[7] = b[7] + d; b[8] = b[8] + 1
end

-- ===== draw =====
local function ensureFont(context)
    if fontReady then return end
    -- per your rule: use 0 (not boolean) for flags
    context:createFont(FONT_ID, "Arial", FontPx, FontPx, 0)
    fontReady = true
end

local function fmt(num)
    if num >= 0 then return string.format("%.2f", num) else return string.format("-%.2f", -num) end
end

local function addRow(lines, enable, color, label, todayVal, ydayVal, showSum, todaySum, ydaySum)
    if not enable then return end
    table.insert(lines, { color=color,
        text=string.format("%-14s Today: %s   Yesterday: %s   Change: %s",
        label, fmt(todayVal), fmt(ydayVal), fmt(todayVal - ydayVal)) })
    if showSum then
        table.insert(lines, { color=color,
            text=string.format("%-14s SUM   Today: %s   Yesterday: %s   Change: %s",
            label, fmt(todaySum), fmt(ydaySum), fmt(todaySum - ydaySum)) })
    end
end

local function buildLines(today, yday, showSum)
    local tb = dayBuckets[today] or {0,0,0,0,0,0,0,0}
    local yb = dayBuckets[yday]  or {0,0,0,0,0,0,0,0}

    local Tsum_t, Tcnt_t = tb[1], tb[2]
    local Esum_t, Ecnt_t = tb[3], tb[4]
    local Osum_t, Ocnt_t = tb[5], tb[6]
    local Ssum_t, Scnt_t = tb[7], tb[8]

    local Tsum_y, Tcnt_y = yb[1], yb[2]
    local Esum_y, Ecnt_y = yb[3], yb[4]
    local Osum_y, Ocnt_y = yb[5], yb[6]
    local Ssum_y, Scnt_y = yb[7], yb[8]

    local Tavg_t = safeAvg(Tsum_t, Tcnt_t)
    local Eavg_t = safeAvg(Esum_t, Ecnt_t)
    local Oavg_t = safeAvg(Osum_t, Ocnt_t)
    local Savg_t = safeAvg(Ssum_t, Scnt_t)

    local Tavg_y = safeAvg(Tsum_y, Tcnt_y)
    local Eavg_y = safeAvg(Esum_y, Ecnt_y)
    local Oavg_y = safeAvg(Osum_y, Ocnt_y)
    local Savg_y = safeAvg(Ssum_y, Scnt_y)

    local lines = {}
    table.insert(lines, { kind="title" })

    addRow(lines, EnableTrading,  C_Trading,  "Trading AVG",  Tavg_t, Tavg_y, showSum, Tsum_t, Tsum_y)
    addRow(lines, EnableExtended, C_Extended, "Extended AVG", Eavg_t, Eavg_y, showSum, Esum_t, Esum_y)
    addRow(lines, EnableOffhours, C_Offhours, "Off-hours AVG",Oavg_t, Oavg_y, showSum, Osum_t, Osum_y)
    addRow(lines, EnableStandard, C_Standard, "Standard OBV", Savg_t, Savg_y, showSum, Ssum_t, Ssum_y)

    return lines
end

function Draw(stage, context)
    if stage ~= 2 then return end
    ensureFont(context)

    local last = src:size() - 1
    if last < firstBar then return end
    local today = math.floor(src:date(last))
    local yday  = today - 1

    local style = context.SINGLELINE + context.LEFT + context.TOP
    local title = string.format("Session Strength (T/E/O) — %s vs %s",
        os.date("%Y-%m-%d", (today - 25569) * 86400),
        os.date("%Y-%m-%d", (yday  - 25569) * 86400))

    local lines = buildLines(today, yday, ShowSum)

    -- measure precisely to avoid clipping
    local maxw, totalh = 0, 0
    local tw, th = context:measureText(FONT_ID, title, style)
    maxw = math.max(maxw, tw)
    totalh = totalh + th + LineGap
    for i = 1, #lines do
        if lines[i].kind ~= "title" then
            local w, h = context:measureText(FONT_ID, lines[i].text, style)
            if w > maxw then maxw = w end
            totalh = totalh + h + LineGap
        end
    end

    local left, top, right, bottom = context:left(), context:top(), context:right(), context:bottom()
    local x, y
    if     Corner == "TopLeft"     then x, y = left  + MarginX, top    + MarginY
    elseif Corner == "TopRight"    then x, y = right - MarginX - maxw, top    + MarginY
    elseif Corner == "BottomLeft"  then x, y = left  + MarginX, bottom - MarginY - totalh
    else                                x, y = right - MarginX - maxw, bottom - MarginY - totalh
    end

    context:drawText(FONT_ID, title, C_Title, -1, x, y, x+tw, y+th, style, 0)
    y = y + th + LineGap

    for i = 1, #lines do
        local row = lines[i]
        if row.kind ~= "title" then
            local w, h = context:measureText(FONT_ID, row.text, style)
            context:drawText(FONT_ID, row.text, row.color, -1, x, y, x+w, y+h, style, 0)
            y = y + h + LineGap
        end
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

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.