-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76410
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


-- Turtle_Soup_Helper_Arrows_OD_Codes.lua
-- TS2 helper indikator – Turtle Soup (+1) s owner-draw strelicama putem font koda (bez alerta)

function Init()
    indicator:name("Turtle Soup Helper (+1) Arrows (Codes)");
    indicator:description("Marks Turtle Soup (+1) reversals with font-code arrows (owner-drawn).");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Lookback (bars)", "", 20, 5, 5000);

    indicator.parameters:addGroup("Filters");
    indicator.parameters:addBoolean("ShowLong",  "Show Long Signals",  "", true);
    indicator.parameters:addBoolean("ShowShort", "Show Short Signals", "", true);

    indicator.parameters:addGroup("Arrows");
    indicator.parameters:addString("ArrowFont", "Font", "", "Wingdings");
    indicator.parameters:addStringAlternative("ArrowFont", "Wingdings", "", "Wingdings");
    indicator.parameters:addStringAlternative("ArrowFont", "Webdings",  "", "Webdings");
    indicator.parameters:addStringAlternative("ArrowFont", "Arial",     "", "Arial");

    indicator.parameters:addInteger("UpCode",   "Up Arrow Code (1–255)",   "Character code for up arrow in chosen font",   233, 1, 255);
    indicator.parameters:addInteger("DownCode", "Down Arrow Code (1–255)", "Character code for down arrow in chosen font", 234, 1, 255);

    indicator.parameters:addColor("ClrLong",  "Long Arrow Color",  "", core.rgb(0,200,0));
    indicator.parameters:addColor("ClrShort", "Short Arrow Color", "", core.rgb(220,0,0));
    indicator.parameters:addInteger("FontPct", "Arrow Size (% of cell)", "60–120 preporuka", 80, 20, 200);
    indicator.parameters:addInteger("OffsetPips", "Offset from High/Low (pips)", "", 5, 0, 200);
end

-- state
local source, N, firstCalc
local showLong, showShort
local clrLong, clrShort, fontPct, offsetPips, arrowFont
local upCode, downCode

-- internal flag/level streamovi za crtanje u Draw()
local LongFlag, LongLevel
local ShortFlag, ShortLevel

local function prior_high(period, lookback)
    return mathex.max(source.high, core.rangeTo(period - 1, lookback))
end
local function prior_low(period, lookback)
    return mathex.min(source.low, core.rangeTo(period - 1, lookback))
end

function Prepare(nameOnly)
    source    = instance.source
    N         = instance.parameters.N
    showLong  = instance.parameters.ShowLong
    showShort = instance.parameters.ShowShort
    clrLong   = instance.parameters.ClrLong
    clrShort  = instance.parameters.ClrShort
    fontPct   = instance.parameters.FontPct
    offsetPips= instance.parameters.OffsetPips
    arrowFont = instance.parameters.ArrowFont
    upCode    = instance.parameters.UpCode
    downCode  = instance.parameters.DownCode

    firstCalc = source:first() + N + 1

    local name = string.format("TurtleSoup(+1)Arrows Codes N=%d", N)
    instance:name(profile:id() .. " - " .. name .. " - " .. source:name())
    if nameOnly then return end

    -- Internal streams za bilježenje signala i Y koordinate (cijene)
    LongFlag   = instance:addInternalStream(0, 0)
    LongLevel  = instance:addInternalStream(0, 0)
    ShortFlag  = instance:addInternalStream(0, 0)
    ShortLevel = instance:addInternalStream(0, 0)

    instance:ownerDrawn(true)
end

function Update(period, mode)
    if period < firstCalc then return end

    local p   = period
    local pm1 = period - 1
    local pm2 = period - 2
    if not (source:hasData(pm2) and source:hasData(pm1) and source:hasData(p)) then return end

    -- reset default
    LongFlag[period]  = 0
    ShortFlag[period] = 0

    -- SHORT: jučer probio stari N-bar High (do pm2), danas close < stari High (do pm1)
    if showShort then
        local prevHighRef = mathex.max(source.high, core.rangeTo(pm2, N))
        local brokeHighPrev = (source.high[pm1] > prevHighRef)
        if brokeHighPrev then
            local nowHighRef = prior_high(p, N)
            if source.close[p] < nowHighRef then
                ShortFlag[period]  = 1
                ShortLevel[period] = source.high[p] + source:pipSize() * offsetPips
            end
        end
    end

    -- LONG: jučer probio stari N-bar Low (do pm2), danas close > stari Low (do pm1)
    if showLong then
        local prevLowRef = mathex.min(source.low, core.rangeTo(pm2, N))
        local brokeLowPrev = (source.low[pm1] < prevLowRef)
        if brokeLowPrev then
            local nowLowRef = prior_low(p, N)
            if source.close[p] > nowLowRef then
                LongFlag[period]  = 1
                LongLevel[period] = source.low[p] - source:pipSize() * offsetPips
            end
        end
    end
end

-- Owner-draw: crtamo znak iz zadanog fonta i koda
function Draw(stage, context)
    if stage ~= 2 then return end

    -- širina ćelije -> veličina fonta u px
    local _, cx1, cx2 = context:positionOfBar(source:size()-1)
    local cellW = math.max(1, (cx2 - cx1))
    local px = math.max(8, math.floor(cellW * (fontPct / 100.0) + 0.5))

    -- kreiraj 2 fonta (isti font/veličina, id 1/2)
    context:createFont(1, arrowFont, px, px, 0)
    context:createFont(2, arrowFont, px, px, 0)

    -- pretvori kod u 1-bajtni znak (za Wingdings/Webdings)
    local upSym   = string.char(math.max(1, math.min(255, upCode)))
    local downSym = string.char(math.max(1, math.min(255, downCode)))

    local firstBar = math.max(source:first(), context:firstBar())
    local lastBar  = math.min(context:lastBar(), source:size()-1)

    for i = firstBar, lastBar do
        if LongFlag:hasData(i) and LongFlag[i] == 1 then
            local x, _, _ = context:positionOfBar(i)
            local _, y = context:pointOfPrice(LongLevel[i])
            local w, h = context:measureText(1, upSym, 0)
            context:drawText(1, upSym, clrLong, -1, x - w/2, y, x + w/2, y + h, 0)
        end
        if ShortFlag:hasData(i) and ShortFlag[i] == 1 then
            local x, _, _ = context:positionOfBar(i)
            local _, y = context:pointOfPrice(ShortLevel[i])
            local w, h = context:measureText(2, downSym, 0)
            context:drawText(2, downSym, clrShort, -1, x - w/2, y - h, x + w/2, y, 0)
        end
    end
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76410
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