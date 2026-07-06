-- HEADER:BEGIN
--[[
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76306
License:     GNU


── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com


── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7


── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
]]
-- HEADER:END


-- RBD / DBR / HRBD / HDBR with zone-guard continuation
-- Keeps the run counter growing only while price stays OUTSIDE the origin zone.
-- If price re-enters the zone, the run stops (no increment).

function Init()
    indicator:name("RBD DBR HRBD HDBR (zone-guard)")
    indicator:description("RBD, DBR, HRBD, HDBR zones with continuation blocked if price re-enters the zone")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Half-pattern lookahead bars", "", 2)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("RBD", "RBD Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DBR", "DBR Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("HRBD", "HRBD Color", "", core.rgb(0, 255, 255))
    indicator.parameters:addColor("HDBR", "HDBR Color", "", core.rgb(255, 0, 255))
    indicator.parameters:addInteger("transparency", "Transparency (0-100)", "", 75, 0, 100)

    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5)
end

local source, first, Period
local RBD, DBR, HRBD, HDBR
local RBD_high, RBD_low, DBR_high, DBR_low
local HRBD_high, HRBD_low, HDBR_high, HDBR_low

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    Period = instance.parameters.Period
    if nameOnly then return end

    source = instance.source
    first = source:first() + 1 + math.max(Period, 3)

    RBD  = instance:addInternalStream(0, 0)
    DBR  = instance:addInternalStream(0, 0)
    HRBD = instance:addInternalStream(0, 0)
    HDBR = instance:addInternalStream(0, 0)

    RBD_high  = instance:addInternalStream(0, 0)
    DBR_high  = instance:addInternalStream(0, 0)
    HRBD_high = instance:addInternalStream(0, 0)
    HDBR_high = instance:addInternalStream(0, 0)

    RBD_low  = instance:addInternalStream(0, 0)
    DBR_low  = instance:addInternalStream(0, 0)
    HRBD_low = instance:addInternalStream(0, 0)
    HDBR_low = instance:addInternalStream(0, 0)

    instance:ownerDrawn(true)
end

local function isBull(bar) return source.close[bar] > source.open[bar] end
local function isBear(bar) return source.close[bar] < source.open[bar] end

-- helper: check if price is inside a zone (inclusive)
local function is_inside_zone(closep, low, high)
    if not low or not high then return false end
    if low > high then low, high = high, low end
    return closep >= low and closep <= high
end

function Update(period, mode)
    if period < first then return end
    period = period - 1

    -- =====================
    -- 3-candle patterns
    -- =====================

    -- RBD: bull, bull, bear, and bar3 close < bar2 close
    if source.open[period-2] < source.close[period-2]
    and source.open[period-1] < source.close[period-1]
    and source.open[period]   > source.close[period]
    and source.close[period]  < source.close[period-1] then
        RBD[period] = 1
        -- zone from candle2 body top to candle3 body bottom (body-style)
        RBD_high[period] = math.max(source.open[period-1], source.close[period-1])
        RBD_low[period]  = math.min(source.open[period],   source.close[period])
    elseif RBD[period-1] and RBD[period-1] >= 1 then
        -- continuation only if price remains OUTSIDE the original zone (below it for RBD)
        local start = period - RBD[period-1]
        local low   = RBD_low[start]
        local high  = RBD_high[start]
        local cp    = source.close[period]
        if not is_inside_zone(cp, low, high) and cp < low then
            RBD[period] = RBD[period-1] + 1
        else
            RBD[period] = 0
        end
    end

    -- DBR: bear, bear, bull, and bar3 close > bar2 close
    if source.open[period-2] > source.close[period-2]
    and source.open[period-1] > source.close[period-1]
    and source.open[period]   < source.close[period]
    and source.close[period]  > source.close[period-1] then
        DBR[period] = 1
        -- zone from candle3 body top to candle2 body bottom (body-style)
        DBR_high[period] = math.max(source.open[period],   source.close[period])
        DBR_low[period]  = math.min(source.open[period-1], source.close[period-1])
    elseif DBR[period-1] and DBR[period-1] >= 1 then
        -- continuation only if price remains OUTSIDE the original zone (above it for DBR)
        local start = period - DBR[period-1]
        local low   = DBR_low[start]
        local high  = DBR_high[start]
        local cp    = source.close[period]
        if not is_inside_zone(cp, low, high) and cp > high then
            DBR[period] = DBR[period-1] + 1
        else
            DBR[period] = 0
        end
    end

    -- =====================
    -- Half patterns (Period bars)
    -- =====================
    local c1_open  = source.open[period-Period]
    local c1_close = source.close[period-Period]

    -- HRBD: candle1 bull; subsequent bears; must close below c1 open (after p bars)
    if (c1_close > c1_open) and Up(period) then
        HRBD[period] = 1
        HRBD_high[period] = source.high[period-Period]
        HRBD_low[period]  = math.min(source.open[period], source.close[period])
    elseif HRBD[period-1] and HRBD[period-1] >= 1 then
        local start = period - HRBD[period-1]
        local low   = HRBD_low[start]
        local high  = HRBD_high[start]
        local cp    = source.close[period]
        -- keep going only if we stay below the zone; stop if we re-enter
        if not is_inside_zone(cp, low, high) and cp < low then
            HRBD[period] = HRBD[period-1] + 1
        else
            HRBD[period] = 0
        end
    end

    -- HDBR: candle1 bear; subsequent bulls; must close above c1 open (after p bars)
    if (c1_close < c1_open) and Down(period) then
        HDBR[period] = 1
        HDBR_high[period] = math.max(source.open[period], source.close[period])
        HDBR_low[period]  = source.low[period-Period]
    elseif HDBR[period-1] and HDBR[period-1] >= 1 then
        local start = period - HDBR[period-1]
        local low   = HDBR_low[start]
        local high  = HDBR_high[start]
        local cp    = source.close[period]
        -- keep going only if we stay above the zone; stop if we re-enter
        if not is_inside_zone(cp, low, high) and cp > high then
            HDBR[period] = HDBR[period-1] + 1
        else
            HDBR[period] = 0
        end
    end
end

function Up(period)
    local ItIs = true
    for i = 0, Period - 1 do
        if source.close[period - i] > source.open[period - i]
        or source.close[period - i] > source.open[period - Period] then
            ItIs = false
            break
        end
    end
    return ItIs
end

function Down(period)
    local ItIs = true
    for i = 0, Period - 1 do
        if source.close[period - i] < source.open[period - i]
        or source.close[period - i] < source.open[period - Period] then
            ItIs = false
            break
        end
    end
    return ItIs
end

-- ===== Drawing =====
local init = false
local transparency

function Draw(stage, context)
    if stage ~= 2 then return end

    if not init then
        init = true
        context:createPen(1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.RBD)
        context:createSolidBrush(11, instance.parameters.RBD)

        context:createPen(2, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.DBR)
        context:createSolidBrush(12, instance.parameters.DBR)

        context:createPen(3, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.HRBD)
        context:createSolidBrush(13, instance.parameters.HRBD)

        context:createPen(4, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.HDBR)
        context:createSolidBrush(14, instance.parameters.HDBR)

        transparency = context:convertTransparency(instance.parameters.transparency)
    end

    local from_bar = math.max(source:first(), context:firstBar())
    local to_bar   = math.min(context:lastBar(), source:size() - 1)

    for i = from_bar, to_bar do
        if RBD[i-1] > RBD[i] then
            local _, x1 = context:positionOfBar(i - RBD[i-1])
            local _, x2 = context:positionOfBar(i - 1)
            local _, y_low  = context:pointOfPrice(RBD_low[i - RBD[i-1]])
            local _, y_high = context:pointOfPrice(RBD_high[i - RBD[i-1]])
            context:drawRectangle(-1, 11, x1, y_high, x2, y_low, transparency)
            context:drawLine(1, x1, y_high, x2, y_high)
            context:drawLine(1, x1, y_low,  x2, y_low)
        end

        if DBR[i-1] > DBR[i] then
            local _, x1 = context:positionOfBar(i - DBR[i-1])
            local _, x2 = context:positionOfBar(i - 1)
            local _, y_low  = context:pointOfPrice(DBR_low[i - DBR[i-1]])
            local _, y_high = context:pointOfPrice(DBR_high[i - DBR[i-1]])
            context:drawRectangle(-1, 12, x1, y_high, x2, y_low, transparency)
            context:drawLine(2, x1, y_high, x2, y_high)
            context:drawLine(2, x1, y_low,  x2, y_low)
        end

        if HRBD[i-1] > HRBD[i] then
            local _, x1 = context:positionOfBar(i - HRBD[i-1])
            local _, x2 = context:positionOfBar(i - 1)
            local _, y_low  = context:pointOfPrice(HRBD_low[i - HRBD[i-1]])
            local _, y_high = context:pointOfPrice(HRBD_high[i - HRBD[i-1]])
            context:drawRectangle(-1, 13, x1, y_high, x2, y_low, transparency)
            context:drawLine(3, x1, y_high, x2, y_high)
            context:drawLine(3, x1, y_low,  x2, y_low)
        end

        if HDBR[i-1] > HDBR[i] then
            local _, x1 = context:positionOfBar(i - HDBR[i-1])
            local _, x2 = context:positionOfBar(i - 1)
            local _, y_low  = context:pointOfPrice(HDBR_low[i - HDBR[i-1]])
            local _, y_high = context:pointOfPrice(HDBR_high[i - HDBR[i-1]])
            context:drawRectangle(-1, 14, x1, y_high, x2, y_low, transparency)
            context:drawLine(4, x1, y_high, x2, y_high)
            context:drawLine(4, x1, y_low,  x2, y_low)
        end
    end
end
-- FOOTER:BEGIN
--[[
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76306
License:     GNU


── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com


── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7


── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
]]
-- FOOTER:END
