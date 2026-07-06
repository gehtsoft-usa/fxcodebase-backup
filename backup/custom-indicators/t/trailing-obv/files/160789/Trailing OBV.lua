-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76355
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

--[[--------------------------------------------------------------------
Trailing OBV Oscillator
Author: Mario / Apprentice helper
Description:
  On-Balance Volume (OBV) + rolling sum of last N OBV values as oscillator,
  with SMA signal line over the summed OBV.

Notes:
  - Works on bar data (OHLC). If volume isn't provided for the instrument,
    falls back to 1 per bar (tick-volume proxy).
  - Outputs: OBV_SUM (oscillator), SIGNAL (SMA of OBV_SUM).
----------------------------------------------------------------------]]

function Init()
    indicator:name("Trailing OBV");
    indicator:description("OBV-based oscillator as sum of last N OBV values, with SMA signal line.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Sum Period (N)", "Number of bars to sum OBV over.", 14, 2, 10000);
    indicator.parameters:addInteger("SMAP", "Signal SMA Period", "SMA period applied to OBV sum.", 9, 1, 10000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrOBV", "OBV Sum Color", "", core.rgb(0, 153, 255));
    indicator.parameters:addInteger("wOBV", "OBV Sum Width", "", 2, 1, 5);
    indicator.parameters:addInteger("styOBV", "OBV Sum Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styOBV", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clrSIG", "Signal SMA Color", "", core.rgb(255, 102, 0));
    indicator.parameters:addInteger("wSIG", "Signal Width", "", 2, 1, 5);
    indicator.parameters:addInteger("stySIG", "Signal Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("stySIG", core.FLAG_LINE_STYLE);
end

-- locals
local source;
local N, SMAP;
local obv;        -- internal OBV stream
local obvSum;     -- internal rolling sum(OBV, N)
local sma;        -- core SMA indicator over obvSum
local OUT_OBV;    -- output: OBV_SUM
local OUT_SIG;    -- output: SIGNAL

local first_src;
local first_obv;
local first_sum;
local first_sig;

function Prepare(nameOnly)
    source = instance.source;
    N     = instance.parameters.N;
    SMAP  = instance.parameters.SMAP;

    -- indices: need previous close, so OBV starts at source:first() + 1
    first_src = source:first();
    first_obv = first_src + 1;
    first_sum = first_obv + (N - 1);
    first_sig = first_sum + (SMAP - 1);

    local name = profile:id() .. "(" .. source:name() .. ", N=" .. N .. ", SMA=" .. SMAP .. ")";
    instance:name(name);
    if nameOnly then return; end

    -- internal streams
    obv    = instance:addInternalStream(first_obv, 0);
    obvSum = instance:addInternalStream(first_sum, 0);

    -- nested SMA on obvSum (use built-in MVA as simple moving average)
    sma = core.indicators:create("MVA", obvSum, SMAP);

    -- outputs
    OUT_OBV = instance:addStream("OBV_SUM", core.Line, name .. ".OBV_SUM", "OBVΣ", instance.parameters.clrOBV, first_sum);
    OUT_OBV:setWidth(instance.parameters.wOBV);
    OUT_OBV:setStyle(instance.parameters.styOBV);

    OUT_SIG = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "Signal", instance.parameters.clrSIG, first_sig);
    OUT_SIG:setWidth(instance.parameters.wSIG);
    OUT_SIG:setStyle(instance.parameters.stySIG);
end

function Update(period, mode)
    -- Need prices first
    if period < first_obv then
        return;
    end

    -- --- OBV core ---
    -- Sign by close-to-close change; volume fallback = 1 if unavailable
    local vol = 1;
    if source.volume ~= nil and source.volume:hasData(period) then
        vol = source.volume[period];
    end

    local delta = source.close[period] - source.close[period - 1];
    local sgn = 0;
    if delta > 0 then
        sgn = 1;
    elseif delta < 0 then
        sgn = -1;
    end

    -- Cumulative OBV
    local prev = (period > first_obv) and obv[period - 1] or 0;
    obv[period] = prev + sgn * vol;

    -- --- Rolling sum of last N OBV values ---
    if period >= first_sum then
        obvSum[period] = core.sum(obv, core.rangeTo(period, N));
        OUT_OBV[period] = obvSum[period];
    else
        return;
    end

    -- --- Signal SMA over OBV sum ---
    sma:update(mode);
    if period >= first_sig and sma.DATA:hasData(period) then
        OUT_SIG[period] = sma.DATA[period];
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76355
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