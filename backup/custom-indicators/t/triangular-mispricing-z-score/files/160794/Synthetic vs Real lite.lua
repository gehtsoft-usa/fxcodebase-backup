-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76356
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
-- Synthetic vs Real (Line Only, HTF-style fetch & time-align)
-- - SAMO synthetic linija (nema svijeća)
-- - Dohvat nogu i poravnanje po vremenu kao u "Higher Time Frame Indicator Template"
-- - Auto LONG/SHORT/NEUTRAL po Z-score (spread = synth - actual)
-- - 3 uvećana imena instrumenata obojana: Long=zelena, Short=crvena, Neutral=siva
-- © 2025 — MIT

function Init()
    indicator:name("Synthetic vs Real (Line Only, HTF-align)");
    indicator:description("Synthetic line with auto sides; legs fetched & time-aligned via getcandle+getSyncHistory+findDate.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Symbols");
    indicator.parameters:addString("Target", "Target (U/V)", "", "NZD/CAD");      indicator.parameters:setFlag("Target", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("Leg1",   "Leg 1 (denominator for DIV)", "", "AUD/NZD"); indicator.parameters:setFlag("Leg1", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("Leg2",   "Leg 2 (numerator for DIV)",   "", "AUD/CAD"); indicator.parameters:setFlag("Leg2", core.FLAG_INSTRUMENTS);
    indicator.parameters:addBoolean("UseBid","Use Bid prices", "", true);

    indicator.parameters:addGroup("Line");
    indicator.parameters:addInteger("LineWidth",  "Synthetic line width", "", 2, 1, 6);

    indicator.parameters:addGroup("Z-Score Signals");
    indicator.parameters:addInteger("Z_Len",   "Z lookback (bars)", "", 100, 10, 10000);
    indicator.parameters:addDouble("EntryZ",   "Entry |Z|",         "", 2.0, 0.1, 10.0);
    indicator.parameters:addDouble("ExitZ",    "Exit |Z|",          "", 0.5, 0.0, 10.0);
    indicator.parameters:addDouble("PipsBuffer","Min deviation (pips)", "", 2.0, 0.0, 1000.0);

    indicator.parameters:addGroup("Colors");
    indicator.parameters:addColor("ClrLong",    "Long color",    "", core.rgb(0,200,0));
    indicator.parameters:addColor("ClrShort",   "Short color",   "", core.rgb(200,0,0));
    indicator.parameters:addColor("ClrNeutral", "Neutral color", "", core.rgb(150,150,150));

    indicator.parameters:addGroup("Label Position");
    indicator.parameters:addString("Corner", "Corner", "", "TopRight");
    indicator.parameters:addStringAlternative("Corner", "Top-left",     "", "TopLeft");
    indicator.parameters:addStringAlternative("Corner", "Top-right",    "", "TopRight");
    indicator.parameters:addStringAlternative("Corner", "Bottom-left",  "", "BottomLeft");
    indicator.parameters:addStringAlternative("Corner", "Bottom-right", "", "BottomRight");
    indicator.parameters:addInteger("MarginX", "Margin X (px)", "", 10, 0, 300);
    indicator.parameters:addInteger("MarginY", "Margin Y (px)", "", 10, 0, 300);
    indicator.parameters:addInteger("RowGap",  "Row gap (px)",  "", 6,  0, 60);
    indicator.parameters:addInteger("NameFontPx","Name font (px)", "", 24, 10, 96);
end

-- ===== Utils =====
local function splitPair(sym) local a,b = string.match(sym, "^([%u]+)%/(%u+)$"); assert(a and b, "Bad symbol: "..tostring(sym)); return a,b end
local function min4(a,b,c,d) return math.min(math.min(a,b), math.min(c,d)) end
local function max4(a,b,c,d) return math.max(math.max(a,b), math.max(c,d)) end
local function prod_bounds(l1,h1,l2,h2) local p1,p2,p3,p4 = l1*l2, l1*h2, h1*l2, h1*h2; return min4(p1,p2,p3,p4), max4(p1,p2,p3,p4) end
local function div_bounds(l1,h1,l2,h2) local q1,q2,q3,q4 = l1/l2, l1/h2, h1/l2, h1/h2; return min4(q1,q2,q3,q4), max4(q1,q2,q3,q4) end
local function haveBar(s,p) return (s and s:hasData(p)) end

-- ===== Globals =====
local source
local Target, Leg1, Leg2, UseBid
local A_stream, B_stream, loadingA, loadingB, firstCalc, op
local g_close
local LineWidth
local Corner, MarginX, MarginY, RowGap, NameFontPx
local ClrLong, ClrShort, ClrNeutral
local Z_Len, EntryZ, ExitZ, PipsBuffer
local fontMade=false
local dayoffset, weekoffset

-- Z internals + buffers
local spread, spread2
local z_stream, side_stream, dev_stream
local Z_cur = nil
local sideTarget, sideLeg1, sideLeg2 = "NEUTRAL","NEUTRAL","NEUTRAL"

-- ===== Side helpers =====
local function colorBySide(side)
    if side == "LONG"      then return ClrLong
    elseif side == "SHORT" then return ClrShort
    else return ClrNeutral end
end
local function decideTargetSideFromZ(z, devPips)
    if z == nil then return "NEUTRAL" end
    if math.abs(z) <= ExitZ then return "NEUTRAL" end
    if devPips < PipsBuffer then return "NEUTRAL" end
    if z <= -EntryZ then return "LONG" end
    if z >=  EntryZ then return "SHORT" end
    return "NEUTRAL"
end
local function mapLegSides(opKind, targetSide)
    if targetSide == "NEUTRAL" then return "NEUTRAL","NEUTRAL" end
    if opKind == "MUL" then
        if targetSide == "LONG"  then return "LONG","LONG" end
        if targetSide == "SHORT" then return "SHORT","SHORT" end
    else -- DIV : Target = Leg2 / Leg1
        if targetSide == "LONG"  then return "SHORT","LONG" end
        if targetSide == "SHORT" then return "LONG","SHORT" end
    end
    return "NEUTRAL","NEUTRAL"
end

-- ===== Prepare =====
function Prepare(nameOnly)
    source  = instance.source
    Target  = instance.parameters.Target
    Leg1    = instance.parameters.Leg1
    Leg2    = instance.parameters.Leg2
    UseBid  = instance.parameters.UseBid

    LineWidth   = instance.parameters.LineWidth
    Corner      = instance.parameters.Corner
    MarginX     = instance.parameters.MarginX
    MarginY     = instance.parameters.MarginY
    RowGap      = instance.parameters.RowGap
    NameFontPx  = instance.parameters.NameFontPx

    ClrLong     = instance.parameters.ClrLong
    ClrShort    = instance.parameters.ClrShort
    ClrNeutral  = instance.parameters.ClrNeutral

    Z_Len       = instance.parameters.Z_Len
    EntryZ      = instance.parameters.EntryZ
    ExitZ       = instance.parameters.ExitZ
    PipsBuffer  = instance.parameters.PipsBuffer

    -- odredi relaciju Target vs Legs (MUL/DIV) za mapiranje strana
    local U,V = splitPair(Target)
    local X,Y = splitPair(Leg1)
    local M,N = splitPair(Leg2)
    if (Y == N and X == U and M == V) then
        op = "DIV"     -- Target = Leg2 / Leg1
    elseif (X == U and N == V and Y == M) then
        op = "MUL"     -- Target = Leg1 * Leg2
    elseif (X == M and Y == U and N == V) then
        op = "DIV"
    else
        op = "DIV"
    end

    local name = profile:id() .. "(" .. source:name() .. "; " .. Target .. ")"
    instance:name(name)
    if nameOnly then return end

    -- offsets (isti pattern kao HTF predložak)
    dayoffset  = core.host:execute("getTradingDayOffset")
    weekoffset = core.host:execute("getTradingWeekOffset")

    -- provjeri subscribe
    local offers = core.host:findTable("offers")
    assert(offers:find("Instrument", Leg1) ~= nil, "Subscribe to "..Leg1)
    assert(offers:find("Instrument", Leg2) ~= nil, "Subscribe to "..Leg2)

    -- dohvat sync povijesti nogu NA ISTOM TF-u kao chart (HTF pattern)
    local TF = source:barSize()
    A_stream = core.host:execute("getSyncHistory", Leg1, TF, UseBid, 0, 100, 101); loadingA = true
    B_stream = core.host:execute("getSyncHistory", Leg2, TF, UseBid, 0, 200, 201); loadingB = true

    -- synthetic line output
    g_close = instance:addStream("g_close", core.Line, name..".g_close", "Synthetic", ClrNeutral, 0)
    g_close:setWidth(LineWidth)

    -- interne serije za Z
    spread      = instance:addInternalStream(0, 0)
    spread2     = instance:addInternalStream(0, 0)
    z_stream    = instance:addInternalStream(0, 0)
    side_stream = instance:addInternalStream(0, 0)
    dev_stream  = instance:addInternalStream(0, 0)

    -- owner-draw za velika imena
    instance:ownerDrawn(true)
    fontMade=false
    firstCalc = 0
end

-- ===== Async (HTF pattern) =====
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loadingA = false
        instance:updateFrom(0)
    elseif cookie == 101 then
        loadingA = true
    elseif cookie == 200 then
        loadingB = false
        instance:updateFrom(0)
    elseif cookie == 201 then
        loadingB = true
    end
    if (not loadingA) and (not loadingB) then
        firstCalc = math.max(source:first(), A_stream:first(), B_stream:first())
        instance:updateFrom(0)
    end
    return core.ASYNC_REDRAW
end

-- ===== Time-align helper (HTF style) =====
local function timeAlignedIndex(stream, period)
    -- uzmi vremenski raspon svijeće na TF-u charta
    local candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset)
    -- poravnaj po početku svijeće (HTF template koristi findDate(candle, false))
    local p = core.findDate(stream, candle, false)
    if p < 0 or not stream:hasData(p) then return -1 end
    return p
end

-- ===== Update =====
function Update(period, mode)
    if loadingA or loadingB then return end
    if period < firstCalc then return end
    if not haveBar(source, period) then return end

    -- pronađi pripadne barove u nogama po vremenu (isti obrazac kao HTF template)
    local ia = timeAlignedIndex(A_stream, period)
    local ib = timeAlignedIndex(B_stream, period)
    if ia == -1 or ib == -1 then return end

    -- real i legs close
    local realC = source.close[period]
    local aC = A_stream.close[ia]
    local bC = B_stream.close[ib]
    if not aC or not bC or aC <= 0 or bC <= 0 then return end

    -- synthetic close (line only)
    local gC
    if op == "MUL" then gC = bC * aC else gC = bC / aC end
    g_close[period] = gC

    -- spread = synth - actual
    local s = gC - realC
    spread[period]  = s
    spread2[period] = s*s

    -- Z-score
    if period >= firstCalc + (Z_Len - 1) then
        local rng   = core.rangeTo(period, Z_Len)
        local mean  = core.avg(spread,  rng)
        local mean2 = core.avg(spread2, rng)
        local var   = mean2 - (mean * mean); if var < 0 then var = 0 end
        local std   = math.sqrt(var)
        Z_cur = (std>0) and ((s - mean) / std) or 0
    else
        Z_cur = nil
    end

    -- auto sides + internal buffers
    local pip = source:pipSize() or 0
    local devPips = (pip > 0) and math.abs(s) / pip or 0

    sideTarget = decideTargetSideFromZ(Z_cur, devPips)
    sideLeg1, sideLeg2 = mapLegSides(op, sideTarget)

    z_stream[period]    = (Z_cur or 0)
    side_stream[period] = (sideTarget=="LONG" and 1) or (sideTarget=="SHORT" and -1) or 0
    dev_stream[period]  = devPips

    -- boja linije po sideTarget (povijesno)
    g_close:setColor(period, colorBySide(sideTarget))
end

-- ===== Draw: Big colored names =====
function Draw(stage, context)
    if stage ~= 2 then return end
    if not fontMade then
        context:createFont(1, "Arial", NameFontPx, NameFontPx, 0)
        fontMade=true
    end

    local left, top, right, bottom = context:left(), context:top(), context:right(), context:bottom()
    local x, y
    local rowh = NameFontPx + RowGap

    if Corner == "TopLeft" then
        x = left  + MarginX; y = top + MarginY
    elseif Corner == "TopRight" then
        x = right - MarginX; y = top + MarginY
    elseif Corner == "BottomLeft" then
        x = left  + MarginX; y = bottom - MarginY - 3*rowh
    else
        x = right - MarginX; y = bottom - MarginY - 3*rowh
    end

    local style = context.SINGLELINE + context.LEFT + context.TOP
    local function drawName(text, col, yrow)
        local w,h = context:measureText(1, text, 0)
        local bx = x
        if Corner=="TopRight" or Corner=="BottomRight" then bx = x - w end
        context:drawText(1, text, col, -1, bx, yrow, bx+w, yrow+h, style, 0)
    end

    drawName(Target, colorBySide(sideTarget), y + 0*rowh)
    drawName(Leg1,   colorBySide(sideLeg1),   y + 1*rowh)
    drawName(Leg2,   colorBySide(sideLeg2),   y + 2*rowh)
end


-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76356
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