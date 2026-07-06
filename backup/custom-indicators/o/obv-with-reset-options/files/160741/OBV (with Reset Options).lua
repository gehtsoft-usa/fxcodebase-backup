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
-- <https://www.gnu.org/licenses/>

function Init()
    indicator:name("OBV (with Reset Options)")
    indicator:description("On-Balance Volume with optional reset at Start of Day / Session Start / Session End.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    -- Reset način
    indicator.parameters:addGroup("Reset Mode")
    indicator.parameters:addString("ResetMode", "Reset Mode", "When OBV should reset to 0.", "None")
    indicator.parameters:addStringAlternative("ResetMode", "None",         "No resets",                      "None")
    indicator.parameters:addStringAlternative("ResetMode", "StartOfDay",   "Reset at the start of each day", "StartOfDay")
    indicator.parameters:addStringAlternative("ResetMode", "SessionStart", "Reset at Session Start (HH:MM)", "SessionStart")
    indicator.parameters:addStringAlternative("ResetMode", "SessionEnd",   "Reset at Session End (HH:MM)",   "SessionEnd")

    -- Granice sesije (koriste se za SessionStart/SessionEnd)
    indicator.parameters:addGroup("Session Boundaries")
    indicator.parameters:addInteger("SessHH",    "Session hour",          "0–23", 9, 0, 23)
    indicator.parameters:addInteger("SessMM",    "Session minute",        "0–59", 30, 0, 59)
    indicator.parameters:addInteger("SessEndHH", "Session end hour",      "0–23", 16, 0, 23)
    indicator.parameters:addInteger("SessEndMM", "Session end minute",    "0–59", 0,  0, 59)

    -- Volumen
    indicator.parameters:addGroup("Volume")
    indicator.parameters:addBoolean("UseTickFallback", "If volume missing, use 1 per bar", "", true)

    -- Stil
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("cOBV", "Line color", "", core.rgb(0, 180, 255))
    indicator.parameters:addInteger("wOBV", "Line width", "", 2, 1, 5)
    indicator.parameters:addInteger("sOBV", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("sOBV", core.FLAG_LINE_STYLE)
end

-- locals
local src, first
local out
local ResetMode
local SessHH, SessMM, SessEndHH, SessEndMM
local UseTickFallback
local curr_obv
local prev_date -- prethodni bar (OLE datum/vrijeme)

-- Pomocna: zbroji HH:MM na dan (OLE dan = floor(datetime))
local function dayHM(day, hh, mm)
    return day + (hh * 3600 + mm * 60) / 86400
end

-- Trebamo li resetirati na trenutnom baru t, s obzirom na prethodni prev_t?
local function needReset(t, prev_t)
    if ResetMode == "None" or prev_t == nil then
        return false
    end

    local d  = math.floor(t)
    local pd = math.floor(prev_t)

    if ResetMode == "StartOfDay" then
        -- reset na promjeni dana
        return d ~= pd

    elseif ResetMode == "SessionStart" then
        local sStart = dayHM(d, SessHH, SessMM)
        return (prev_t < sStart) and (t >= sStart)

    elseif ResetMode == "SessionEnd" then
        local sEnd = dayHM(d, SessEndHH, SessEndMM)
        return (prev_t < sEnd) and (t >= sEnd)
    end

    return false
end

function Prepare(nameOnly)
    src   = instance.source
    first = src:first()

    ResetMode      = instance.parameters.ResetMode
    SessHH         = instance.parameters.SessHH
    SessMM         = instance.parameters.SessMM
    SessEndHH      = instance.parameters.SessEndHH
    SessEndMM      = instance.parameters.SessEndMM
    UseTickFallback= instance.parameters.UseTickFallback

    local instName = src:name()
    local id = profile:id() .. "(" .. instName .. ", Reset=" .. ResetMode .. ")"
    instance:name(id)

    if nameOnly then return end

    out = instance:addStream("OBV", core.Line, id, "OBV", instance.parameters.cOBV, first)
    out:setWidth(instance.parameters.wOBV)
    out:setStyle(instance.parameters.sOBV)

    curr_obv  = 0
    prev_date = nil
end

local function getVolume(period)
    local v = (src.volume and src.volume[period]) or nil
    if v == nil and UseTickFallback then
        return 1
    end
    return v or 0
end

function Update(period, mode)
    if period < first then
        return
    end

    if period == first then
        curr_obv  = 0
        out[period] = curr_obv
        prev_date = src:date(period)
        return
    end

    local t      = src:date(period)
    local prev_t = prev_date

    if needReset(t, prev_t) then
        curr_obv = 0
    else
        -- kontinuitet s prethodnog bara
        local prevVal = out[period - 1]
        curr_obv = (prevVal ~= nil) and prevVal or curr_obv
    end

    -- OBV korak
    local c  = src.close[period]
    local pc = src.close[period - 1]
    local v  = getVolume(period)

    if c ~= nil and pc ~= nil then
        if c > pc then
            curr_obv = curr_obv + v
        elseif c < pc then
            curr_obv = curr_obv - v
        else
            -- bez promjene
        end
    end

    out[period] = curr_obv
    prev_date   = t
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
-- <https://www.gnu.org/licenses/>