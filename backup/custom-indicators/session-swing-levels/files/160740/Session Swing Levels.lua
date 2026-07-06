-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76347
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
    indicator:name("Session & Swing Levels (M1 ATH/ATL Async)")
    indicator:description("Session HL, PDH/PDL history, swings, ATH/ATL via monthly M1 (async). Owner-drawn with robust reset.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)         -- owner-drawn u istom panelu

    -- Session
    indicator.parameters:addGroup("Session")
    indicator.parameters:addInteger("SessHH", "Session start hour",   "0–23", 9, 0, 23)
    indicator.parameters:addInteger("SessMM", "Session start minute", "0–59", 30, 0, 59)
    indicator.parameters:addBoolean("Show_SessionStart", "Show session START vertical", "", true)
    indicator.parameters:addInteger("SessEndHH", "Session end hour",   "0–23", 16, 0, 23)
    indicator.parameters:addInteger("SessEndMM", "Session end minute", "0–59", 0, 0, 59)
    indicator.parameters:addBoolean("Show_SessionEnd", "Show session END vertical", "", true)

    -- Povijest
    indicator.parameters:addGroup("History")
    indicator.parameters:addInteger("HistoryDays", "How many past finished days to render", "0 = none", 5, 0, 250)

    -- Swings
    indicator.parameters:addGroup("Swings")
    indicator.parameters:addInteger("Left",  "Swing Left (L)",  "Bars to the left", 2, 1, 50)
    indicator.parameters:addInteger("Right", "Swing Right (R)", "Bars to the right", 2, 1, 50)

    -- Vidljivost
    indicator.parameters:addGroup("Visibility")
    indicator.parameters:addBoolean("Show_HDH", "Show Today High (HDH)", "", true)
    indicator.parameters:addBoolean("Show_PDH", "Show Previous Days' Highs (PDH)", "", true)
    indicator.parameters:addBoolean("Show_PDL", "Show Previous Days' Lows (PDL)", "", true)
    indicator.parameters:addBoolean("Show_SwingHigh", "Show Swing High (SH)", "", true)
    indicator.parameters:addBoolean("Show_SwingLow",  "Show Swing Low (SL)",  "", true)
    indicator.parameters:addBoolean("Show_ATH", "Show All-Time High (ATH)", "", true)
    indicator.parameters:addBoolean("Show_ATL", "Show All-Time Low (ATL)", "", true)
    indicator.parameters:addBoolean("Show_PrevSessHigh", "Show Previous Session High (per day)", "", true)
    indicator.parameters:addBoolean("Show_PrevSessLow",  "Show Previous Session Low (per day)",  "", true)
    indicator.parameters:addBoolean("Show_PostSessHigh", "Show Post Session High (per day)", "", true)
    indicator.parameters:addBoolean("Show_PostSessLow",  "Show Post Session Low (per day)",  "", true)
    indicator.parameters:addBoolean("Show_Labels", "Show labels (TAG: VALUE)", "", true)

    -- Right-extensions
    indicator.parameters:addGroup("Right Extensions")
    indicator.parameters:addBoolean("ExtendRight", "Extend historical levels to the right", "", true)
    indicator.parameters:addInteger("ExtendDays",  "Extension span (days)", "", 1, 1, 20)

    -- Stilovi: horizontale
    indicator.parameters:addGroup("Style: Horizontal Lines")
    indicator.parameters:addColor("cHDH", "HDH color", "", core.rgb(0,170,255))
    indicator.parameters:addInteger("wHDH", "HDH width", "", 2, 1, 5)
    indicator.parameters:addInteger("sHDH", "HDH style", "", core.LINE_SOLID); indicator.parameters:setFlag("sHDH", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("cPDH", "PDH color", "", core.rgb(255,215,0))
    indicator.parameters:addInteger("wPDH", "PDH width", "", 2, 1, 5)
    indicator.parameters:addInteger("sPDH", "PDH style", "", core.LINE_DOT); indicator.parameters:setFlag("sPDH", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("cPDL", "PDL color", "", core.rgb(255,140,0))
    indicator.parameters:addInteger("wPDL", "PDL width", "", 2, 1, 5)
    indicator.parameters:addInteger("sPDL", "PDL style", "", core.LINE_DOT); indicator.parameters:setFlag("sPDL", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("cSH", "SH color", "", core.rgb(0,200,0))
    indicator.parameters:addInteger("wSH", "SH width", "", 2, 1, 5)
    indicator.parameters:addInteger("sSH", "SH style", "", core.LINE_DASH); indicator.parameters:setFlag("sSH", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("cSL", "SL color", "", core.rgb(200,0,0))
    indicator.parameters:addInteger("wSL", "SL width", "", 2, 1, 5)
    indicator.parameters:addInteger("sSL", "SL style", "", core.LINE_DASH); indicator.parameters:setFlag("sSL", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("cATH", "ATH color", "", core.rgb(128,0,255))
    indicator.parameters:addInteger("wATH", "ATH width", "", 2, 1, 5)
    indicator.parameters:addInteger("sATH", "ATH style", "", core.LINE_SOLID); indicator.parameters:setFlag("sATH", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("cATL", "ATL color", "", core.rgb(255,0,128))
    indicator.parameters:addInteger("wATL", "ATL width", "", 2, 1, 5)
    indicator.parameters:addInteger("sATL", "ATL style", "", core.LINE_SOLID); indicator.parameters:setFlag("sATL", core.FLAG_LINE_STYLE)

    -- Stilovi: vertikale & labele
    indicator.parameters:addGroup("Style: Verticals & Labels")
    indicator.parameters:addColor("cSESS", "Session START color", "", core.rgb(120,120,120))
    indicator.parameters:addInteger("wSESS", "Session START width", "", 2, 1, 6)
    indicator.parameters:addInteger("sSESS", "Session START style", "", core.LINE_DASH); indicator.parameters:setFlag("sSESS", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("cSESSEND", "Session END color", "", core.rgb(120,120,120))
    indicator.parameters:addInteger("wSESSEND", "Session END width", "", 2, 1, 6)
    indicator.parameters:addInteger("sSESSEND", "Session END style", "", core.LINE_DASH); indicator.parameters:setFlag("sSESSEND", core.FLAG_LINE_STYLE)

    indicator.parameters:addColor("cLabel", "Label color", "", core.rgb(220,220,220))
    indicator.parameters:addInteger("LabelPx", "Label font px", "", 12, 8, 24)
end

-- ====== STATE ======
local src, firstBar
local L, R
local SessHH, SessMM, SessEndHH, SessEndMM
local HistoryDays
local showLabels, ExtendRight, ExtendDays

local curDay, dayHigh, dayLow
local lastSwingHigh, lastSwingLow
local aHigh, aLow
local days_list = {}
local day_info  = {}   -- day_info[d] = { PDH, PDL, start, end_, sessH, sessL, postH, postL }

local SourceData = nil
local loading = false
local monthly_scanned = false

local currentInstrument, currentBarSize

-- owner-draw resursi
local readyGDI = false
local PEN_HDH, PEN_PDH, PEN_PDL, PEN_SH, PEN_SL, PEN_ATH, PEN_ATL, PEN_SESS, PEN_SESSEND = 0,1,2,3,4,5,6,7,8
local FONT_LABEL = 20

-- ====== HELPERS ======
local function dayHM(day, hh, mm) return day + (hh*3600 + mm*60)/86400 end

local function ensureDayRecord(d)
    if not day_info[d] then
        day_info[d] = {
            PDH=nil, PDL=nil,
            start=dayHM(d, SessHH, SessMM),
            end_=dayHM(d, SessEndHH, SessEndMM),
            sessH=nil, sessL=nil,
            postH=nil, postL=nil
        }
        days_list[#days_list+1] = d
    end
end

local function reset_state()
    curDay, dayHigh, dayLow = nil, nil, nil
    lastSwingHigh, lastSwingLow = nil, nil
    aHigh, aLow = nil, nil
    days_list, day_info = {}, {}
    monthly_scanned = false
end

local function full_recalc_from_zero()
    reset_state()
    instance:updateFrom(0)   -- puni recompute
end

-- SIGURNO FORMATIRANJE CIJENE (radi na svim buildovima)
local function price_precision_from_pips(pip)
    if not pip or pip <= 0 then return 5 end
    local prec, v = 0, pip
    while v < 1 do
        v = v * 10
        prec = prec + 1
        if prec > 10 then break end
    end
    return prec
end

local function fmtPrice(p)
    local pip = src:pipSize()
    local prec = price_precision_from_pips(pip)
    return string.format("%." .. prec .. "f", p or 0)
end

local function mapStyle(ls, context)
    if ls == core.LINE_DOT then return context.DOT end
    if ls == core.LINE_DASH then return context.DASH end
    if ls == core.LINE_DASHDOT then return context.DASHDOT end
    if ls == core.LINE_DASHDOTDOT then return context.DASHDOTDOT end
    return context.SOLID
end

local function ensureResources(context)
    if readyGDI then return end
    context:createPen(PEN_HDH,      mapStyle(instance.parameters.sHDH,     context), instance.parameters.wHDH,     instance.parameters.cHDH)
    context:createPen(PEN_PDH,      mapStyle(instance.parameters.sPDH,     context), instance.parameters.wPDH,     instance.parameters.cPDH)
    context:createPen(PEN_PDL,      mapStyle(instance.parameters.sPDL,     context), instance.parameters.wPDL,     instance.parameters.cPDL)
    context:createPen(PEN_SH,       mapStyle(instance.parameters.sSH,      context), instance.parameters.wSH,      instance.parameters.cSH)
    context:createPen(PEN_SL,       mapStyle(instance.parameters.sSL,      context), instance.parameters.wSL,      instance.parameters.cSL)
    context:createPen(PEN_ATH,      mapStyle(instance.parameters.sATH,     context), instance.parameters.wATH,     instance.parameters.cATH)
    context:createPen(PEN_ATL,      mapStyle(instance.parameters.sATL,     context), instance.parameters.wATL,     instance.parameters.cATL)
    context:createPen(PEN_SESS,     mapStyle(instance.parameters.sSESS,    context), instance.parameters.wSESS,    instance.parameters.cSESS)
    context:createPen(PEN_SESSEND,  mapStyle(instance.parameters.sSESSEND, context), instance.parameters.wSESSEND, instance.parameters.cSESSEND)
    context:createFont(FONT_LABEL, "Arial", instance.parameters.LabelPx, instance.parameters.LabelPx, 0)
    readyGDI = true
end

local function measure(context, text)
    local w, h = context:measureText(FONT_LABEL, text,0) -- konzervativno (bez flags)
    return w, h
end

local function drawTextBox(context, text, cx, cy, color, hAlign, vAlign)
    local flags = (hAlign or context.RIGHT) + (vAlign or context.BOTTOM)
    local w, h = measure(context, text)
    local x1, y1 = cx - w/2, cy - h/2
    local x2, y2 = cx + w/2, cy + h/2
    context:drawText(FONT_LABEL, text, color, -1, x1, y1, x2, y2, flags, 0)
end

local function yOfPrice(context, price)
    local vis, y = context:pointOfPrice(price)
    if not vis then return nil end
    return y
end

local function xOfDate(context, dateSerial)
    return context:positionOfDate(dateSerial)
end

local function xBoundsOfDay(context, daySerial)
    local x1 = xOfDate(context, daySerial)
    local x2 = xOfDate(context, daySerial + 1)
    local left, right = context:left(), context:right()
    return (x1 or left), (x2 or right)
end

local function xBoundsOfRange(context, tStart, tEnd)
    local x1 = xOfDate(context, tStart)
    local x2 = xOfDate(context, tEnd)
    local left, right = context:left(), context:right()
    return (x1 or left), (x2 or right)
end

local function xFutureLimit(context, baseDay, daysSpan)
    local target = baseDay + (daysSpan or 1) + 1
    local x = xOfDate(context, target)
    return x or context:right()
end

local function drawHLineFull(context, price, penId, tag)
    if not price then return end
    local y = yOfPrice(context, price); if not y then return end
    context:drawLine(penId, context:left(), y, context:right(), y)
    if instance.parameters.Show_Labels and tag then
        local text = tag .. ": " .. fmtPrice(price)
        drawTextBox(context, text, context:right() - 24, y - 12, instance.parameters.cLabel, context.RIGHT, context.BOTTOM)
    end
end

local function drawHSegmentExt(context, price, penId, x1, x2, tag, labelSide, baseDay)
    local y = yOfPrice(context, price)
    if not y or not x1 or not x2 then return end
    local left, right = context:left(), context:right()
    if x2 < left or x1 > right then return end
    if x1 < left then x1 = left end
    if x2 > right then x2 = right end
    context:drawLine(penId, x1, y, x2, y)
    if ExtendRight and baseDay then
        local xR = xFutureLimit(context, baseDay, ExtendDays)
        if xR > x2 then
            context:drawLine(penId, x2, y, xR, y)
        end
    end
    if instance.parameters.Show_Labels and tag then
        local text = tag .. ": " .. fmtPrice(price)
        local lx = (labelSide == "left") and (x1 + 8) or (x2 - 8)
        local hA = (labelSide == "left") and context.LEFT or context.RIGHT
        drawTextBox(context, text, lx, y - 12, instance.parameters.cLabel, hA, context.BOTTOM)
    end
end

local function drawVLine(context, dateSerial, penId, label, side)
    local x = xOfDate(context, dateSerial); if not x then return end
    context:drawLine(penId, x, context:top(), x, context:bottom())
    if instance.parameters.Show_Labels and label then
        local lx = (side == "left") and (x + 6) or (x - 6)
        local hA = (side == "left") and context.LEFT or context.RIGHT
        drawTextBox(context, label, lx, context:top() + 14, instance.parameters.cLabel, hA, context.VCENTER)
    end
end

-- pivots
local function isPivotHigh(p)
    if p - L < firstBar or p + R >= src:size() then return false end
    local h = src.high[p]; if not h then return false end
    for i = 1, L do if src.high[p - i] >  h then return false end end
    for i = 1, R do if src.high[p + i] >= h then return false end end
    return true
end
local function isPivotLow(p)
    if p - L < firstBar or p + R >= src:size() then return false end
    local l = src.low[p]; if not l then return false end
    for i = 1, L do if src.low[p - i] <  l then return false end end
    for i = 1, R do if src.low[p + i] <= l then return false end end
    return true
end

-- ====== PREPARE ======
function Prepare(nameOnly)
    src      = instance.source
    firstBar = src:first()

    L, R                 = instance.parameters.Left, instance.parameters.Right
    SessHH, SessMM       = instance.parameters.SessHH, instance.parameters.SessMM
    SessEndHH, SessEndMM = instance.parameters.SessEndHH, instance.parameters.SessEndMM
    HistoryDays          = instance.parameters.HistoryDays or 0
    showLabels           = instance.parameters.Show_Labels
    ExtendRight          = instance.parameters.ExtendRight
    ExtendDays           = instance.parameters.ExtendDays

    instance:name(profile:id() .. " (" .. src:name() .. "), Session&Swing")
    instance:ownerDrawn(true)
    if nameOnly then return end

    reset_state()
    currentInstrument = src:instrument()
    currentBarSize    = src:barSize()

    -- async M1 dohvat
    local inst = src:instrument()
    SourceData = core.host:execute("getSyncHistory", inst, "M1", src:isBid(), firstBar, 100, 101)
    loading = true
    monthly_scanned = false
end

-- ====== ASYNC ======
local function computeMonthlyATHATL()
    if loading or monthly_scanned or SourceData == nil then return end
    local f = SourceData:first()
    local sz = SourceData:size()
    if not f or not sz or sz <= f then return end
    local hi, lo
    for i = f, sz - 1 do
        local h = SourceData.high[i]
        local l = SourceData.low[i]
        if h then hi = (not hi or h > hi) and h or hi end
        if l then lo = (not lo or l < lo) and l or lo end
    end
    aHigh, aLow = hi, lo
    monthly_scanned = true
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false
        full_recalc_from_zero()
    elseif cookie == 101 then
        loading = true
    end
    return core.ASYNC_REDRAW
end

-- ====== UPDATE ======
function Update(period, mode)
    if period < firstBar or not src:hasData(period) then return end

    if currentInstrument ~= src:instrument() or currentBarSize ~= src:barSize() then
        currentInstrument = src:instrument()
        currentBarSize    = src:barSize()
        full_recalc_from_zero()
        return
    end

    if not monthly_scanned then
        computeMonthlyATHATL()
    end

    local hi, lo = src.high[period], src.low[period]
    local t      = src:date(period)
    local d      = math.floor(t)

    if not curDay then
        curDay, dayHigh, dayLow = d, hi, lo
        ensureDayRecord(d)
    elseif d ~= curDay then
        local rec = day_info[curDay]; if rec then rec.PDH, rec.PDL = dayHigh, dayLow end
        curDay, dayHigh, dayLow = d, hi, lo
        ensureDayRecord(d)
    else
        if hi and (not dayHigh or hi > dayHigh) then dayHigh = hi end
        if lo and (not dayLow  or lo < dayLow ) then dayLow  = lo end
    end

    ensureDayRecord(d)
    local recToday = day_info[d]
    local sStart   = dayHM(d, SessHH, SessMM)
    local sEnd     = dayHM(d, SessEndHH, SessEndMM)

    if t >= sStart and t < sEnd then
        if hi and (not recToday.sessH or hi > recToday.sessH) then recToday.sessH = hi end
        if lo and (not recToday.sessL or lo < recToday.sessL) then recToday.sessL = lo end
    else
        local anchor
        if t < sStart then anchor = d - 1
        elseif t >= sEnd then anchor = d end
        if anchor then
            ensureDayRecord(anchor)
            local rec = day_info[anchor]
            if hi and (not rec.postH or hi > rec.postH) then rec.postH = hi end
            if lo and (not rec.postL or lo < rec.postL) then rec.postL = lo end
        end
    end

    -- swinzi (na baru p=period-R)
    if R > 0 then
        local p = period - R
        if p >= firstBar then
            if isPivotHigh(p) then lastSwingHigh = src.high[p] end
            if isPivotLow(p)  then lastSwingLow  = src.low[p]  end
        end
    end
end

-- ====== DRAW (owner-drawn) ======
function Draw(stage, context)
    ensureResources(context)

    -- Današnji HDH (full width)
    if instance.parameters.Show_HDH and dayHigh then
        drawHLineFull(context, dayHigh, PEN_HDH, "HDH")
    end

    -- Povijest (zadnjih N završenih dana)
    local total = #days_list
    local N = HistoryDays or 0
    if total > 1 and N > 0 then
        local cnt = 0
        for i = total - 1, 1, -1 do
            if cnt >= N then break end
            local d = days_list[i]
            local rec = day_info[d]
            if rec then
                local xLday, xRday = xBoundsOfDay(context, d)

                if instance.parameters.Show_PDH and rec.PDH then
                    drawHSegmentExt(context, rec.PDH, PEN_PDH, xLday, xRday, "PDH", "right", d)
                end
                if instance.parameters.Show_PDL and rec.PDL then
                    drawHSegmentExt(context, rec.PDL, PEN_PDL, xLday, xRday, "PDL", "right", d)
                end

                if instance.parameters.Show_SessionStart then
                    drawVLine(context, rec.start, PEN_SESS, string.format("%02d:%02d", SessHH, SessMM), "left")
                end
                if instance.parameters.Show_SessionEnd then
                    drawVLine(context, rec.end_,  PEN_SESSEND, string.format("%02d:%02d", SessEndHH, SessEndMM), "right")
                end

                if instance.parameters.Show_PrevSessHigh or instance.parameters.Show_PrevSessLow then
                    local xLs, xRs = xBoundsOfRange(context, rec.start, rec.end_)
                    if instance.parameters.Show_PrevSessHigh and rec.sessH then
                        -- koristimo PDH pen za prev session high
                        drawHSegmentExt(context, rec.sessH, PEN_PDH, xLs, xRs, "Prev Session High", "right", d)
                    end
                    if instance.parameters.Show_PrevSessLow and rec.sessL then
                        -- koristimo PDL pen za prev session low
                        drawHSegmentExt(context, rec.sessL, PEN_PDL, xLs, xRs, "Prev Session Low", "right", d)
                    end
                end

                if instance.parameters.Show_PostSessHigh or instance.parameters.Show_PostSessLow then
                    local nextStart = dayHM(d + 1, SessHH, SessMM)
                    local xLp, xRp  = xBoundsOfRange(context, rec.end_, nextStart)
                    if instance.parameters.Show_PostSessHigh and rec.postH then
                        drawHSegmentExt(context, rec.postH, PEN_PDH, xLp, xRp, "Post Session High", "right", d)
                    end
                    if instance.parameters.Show_PostSessLow and rec.postL then
                        drawHSegmentExt(context, rec.postL, PEN_PDL, xLp, xRp, "Post Session Low", "right", d)
                    end
                end

                cnt = cnt + 1
            end
        end
    end

    -- Današnji session (vertikale + segment SH/SL do “sada”)
    if curDay and day_info[curDay] then
        local recT = day_info[curDay]
        if instance.parameters.Show_SessionStart then
            drawVLine(context, recT.start, PEN_SESS, string.format("%02d:%02d", SessHH, SessMM), "left")
        end
        if instance.parameters.Show_SessionEnd then
            drawVLine(context, recT.end_,  PEN_SESSEND, string.format("%02d:%02d", SessEndHH, SessEndMM), "right")
        end
        local nowT   = core.now()
        local segEnd = (nowT < recT.end_) and nowT or recT.end_
        local xLs, xRs = xBoundsOfRange(context, recT.start, segEnd)
        if recT.sessH then
            drawHSegmentExt(context, recT.sessH, PEN_SH, xLs, xRs, "Session High", "right", curDay)
        end
        if recT.sessL then
            drawHSegmentExt(context, recT.sessL, PEN_SL, xLs, xRs, "Session Low",  "right", curDay)
        end
    end

    -- Swings + ATH/ATL (full width)
    if instance.parameters.Show_SwingHigh and lastSwingHigh then
        drawHLineFull(context, lastSwingHigh, PEN_SH, "SH")
    end
    if instance.parameters.Show_SwingLow and lastSwingLow then
        drawHLineFull(context, lastSwingLow, PEN_SL, "SL")
    end
    if instance.parameters.Show_ATH and aHigh then
        drawHLineFull(context, aHigh, PEN_ATH, "ATH")
    end
    if instance.parameters.Show_ATL and aLow then
        drawHLineFull(context, aLow, PEN_ATL, "ATL")
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76347
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