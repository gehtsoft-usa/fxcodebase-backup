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

--[[
 
WHAT IT DOES
- Tracks the implied (synthetic) NZD/CAD = (AUD/CAD) / (AUD/NZD)
- Compares it to the actual NZD/CAD close
- Computes deviation and Z‑score over a rolling window
- Issues entry/exit signals for mean‑reversion (triangular "arb")

HOW TO USE
- Attach this indicator on the NZD/CAD chart (any timeframe)
- Make sure the symbols in parameters match your broker’s symbols
- Tune Window / EntryZ / ExitZ and the PipsBuffer to your spreads

 
]]

local source;
local TF;

-- External instruments
local INSTR_AUDNZD;
local INSTR_AUDCAD;

-- History handles for the two legs
local H_AUDNZD, H_AUDCAD;
local loading = false;

-- Params
local Window;         -- rolling window for mean/std
local EntryZ;         -- enter when |z| >= EntryZ
local ExitZ;          -- exit when |z| <= ExitZ
local PipsBuffer;     -- require |dev| in pips to exceed this to filter tiny/noisy moves
local UseBid;

-- Outputs
local outDev;         -- raw deviation (synthetic - actual)
local outZ;           -- z‑score of deviation
local sigLong;        -- long NZD/CAD entry marker (expect revert up)
local sigShort;       -- short NZD/CAD entry marker (expect revert down)
local flatSignal;     -- exit marker when z re‑enters band

-- State for regime/positions
local inLong = false;
local inShort = false;

-- Rolling stats buffers
local devBuf = {};
local sumDev, sumDev2 = 0, 0;

local function push_dev(d)
    table.insert(devBuf, d)
    sumDev = sumDev + d
    sumDev2 = sumDev2 + d * d
    if #devBuf > Window then
        local x = table.remove(devBuf, 1)
        sumDev = sumDev - x
        sumDev2 = sumDev2 - x * x
    end
end

local function mean_std()
    local n = #devBuf
    if n < 2 then return 0, 0 end
    local m = sumDev / n
    local v = math.max(0, (sumDev2 / n) - m * m)
    return m, math.sqrt(v)
end

-- Helpers
local function pips(value)
    -- Convert price value (absolute) to pips using the source pip size
    local pip = source:pipSize()
    if pip == nil or pip == 0 then return 0 end
    return math.abs(value) / pip
end

function Init()
    indicator:name("Triangular Mispricing Z-Score ")
    indicator:description("Tracks synthetic NZD/CAD from AUD/CAD & AUD/NZD, computes deviation + Z-score, and signals mean reversion entries/exits.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)  -- z‑score in a separate pane; signals plotted here too

    local p = indicator.parameters

    -- Instruments (default names – adjust to your broker’s symbols)
    p:addString("audnzd", "AUD/NZD symbol", "Symbol for AUD/NZD.", "AUD/NZD")
    p:addString("audcad", "AUD/CAD symbol", "Symbol for AUD/CAD.", "AUD/CAD")

    -- General
    p:addInteger("Window", "Rolling window (bars)", "Bars for mean/std of deviation.", 100, 10, 10000)
    p:addDouble("EntryZ", "Entry threshold |Z|", "Enter when absolute Z-score >= this.", 2.0)
    p:addDouble("ExitZ", "Exit threshold |Z|", "Exit/flatten when absolute Z-score <= this.", 0.5)
    p:addDouble("PipsBuffer", "Deviation buffer (pips)", "Require |deviation| to exceed this, filters micro‑noise.", 1.0)
    p:addBoolean("UseBid", "Use Bid prices", "If false, uses Ask prices when available. Usually true on charts.", true)

    -- Styling
    p:addColor("clrDev", "Deviation color", "Color for deviation line.", core.rgb(128, 128, 128))
    p:addColor("clrZ", "Z-score color", "Color for Z-score line.", core.rgb(0, 128, 255))
    p:addColor("clrLong", "Long signal color", "Color for long markers.", core.rgb(0, 176, 80))
    p:addColor("clrShort", "Short signal color", "Color for short markers.", core.rgb(192, 0, 0))
    p:addColor("clrExit", "Exit signal color", "Color for exit markers.", core.rgb(255, 165, 0))
end

function Prepare(nameOnly)
    source = instance.source
    TF = source:barSize()
    UseBid = instance.parameters.UseBid

    INSTR_AUDNZD = instance.parameters.audnzd
    INSTR_AUDCAD = instance.parameters.audcad

    Window = instance.parameters.Window
    EntryZ = instance.parameters.EntryZ
    ExitZ  = instance.parameters.ExitZ
    PipsBuffer = instance.parameters.PipsBuffer

    local name = profile:id() .. " (" .. source:name() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    -- Outputs (oscillator pane)
    outDev = instance:addStream("dev", core.Line, name .. ": Deviation", "DEV", instance.parameters.clrDev, 0)
    outZ   = instance:addStream("z", core.Line, name .. ": Z-Score", "Z", instance.parameters.clrZ, 0)

    sigLong  = instance:addStream("long", core.Dot, name .. ": Long", "L", instance.parameters.clrLong, 0)
    sigShort = instance:addStream("short", core.Dot, name .. ": Short", "S", instance.parameters.clrShort, 0)
    flatSignal = instance:addStream("flat", core.Dot, name .. ": Exit", "X", instance.parameters.clrExit, 0)

    sigLong:setWidth(2)
    sigShort:setWidth(2)
    flatSignal:setWidth(2)

    -- Initialize history for AUD/NZD and AUD/CAD aligned to source timeframe
    -- Using synchronous history here for robustness; if your build supports async getSyncHistory,
    -- you can swap to that pattern and trigger updateFrom(0) in AsyncOperationFinished.
    local first = source:first()
    local last  = source:size() - 1

    H_AUDNZD = core.host:execute("getSyncHistory", INSTR_AUDNZD, TF, UseBid, first,   100, 101)
    H_AUDCAD = core.host:execute("getSyncHistory", INSTR_AUDCAD, TF, UseBid, first,   200, 201)
 

    -- Reset state
    loading1 = true
    loading2 = true	
	--loading
    inLong, inShort = false, false
    devBuf = {}
    sumDev, sumDev2 = 0, 0
end

-- If you switch to async pattern, uncomment and adapt cookies:
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading1 = false; 
    elseif cookie == 101 then
        loading1 = true;
    end
	
	
    if cookie == 200 then
        loading2 = false; 
    elseif cookie == 201 then
        loading2 = true;
    end	
	
	if not loading2 and not loading1 then
	instance:updateFrom(0);
	end
		return core.ASYNC_REDRAW ;	
end

local function get_close(stream, i)
    -- Access bar close safely; obeys user's guidance to use bracket indexing
    return stream.close[i]
end

local function bar_time(stream, i)
    return stream:date(i)
end

local function seek_at(stream, t)
    -- Find bar index at time t (aligned timeframe)
    return core.findDate(stream, t, true)
end

function Update(period, mode)
    if loading1 or loading2  then
        return
    end

    if period <= source:first() then
        outDev[period] = nil
        outZ[period] = nil
        sigLong[period] = nil
        sigShort[period] = nil
        flatSignal[period] = nil
        return
    end

    -- Align other histories by time
    local t = bar_time(source, period)
    local i_audnzd = seek_at(H_AUDNZD, t)
    local i_audcad = seek_at(H_AUDCAD, t)

    if i_audnzd == -1 or i_audcad == -1 then
        -- Missing bar in one of legs; skip
        outDev[period] = nil
        outZ[period] = nil
        sigLong[period] = nil
        sigShort[period] = nil
        flatSignal[period] = nil
        return
    end

    local nzdCad_actual = get_close(source, period)
    local audnzd = get_close(H_AUDNZD, i_audnzd)
    local audcad = get_close(H_AUDCAD, i_audcad)

    if audnzd == 0 or audnzd == nil or audcad == nil or nzdCad_actual == nil then
        outDev[period] = nil
        outZ[period] = nil
        return
    end

    -- Synthetic NZD/CAD from triangle identity: NZD/CAD = (AUD/CAD) / (AUD/NZD)
    local nzdCad_synth = audcad / audnzd

    -- Deviation (synth - actual)
    local dev = nzdCad_synth - nzdCad_actual
    outDev[period] = dev

    -- Rolling stats
    push_dev(dev)
    local m, s = mean_std()
    local z = 0
    if s ~= 0 then z = (dev - m) / s end
    outZ[period] = z

    -- Signal logic (mean reversion):
    -- Enter when |z| >= EntryZ AND |dev| (pips) >= PipsBuffer
    -- Exit when |z| <= ExitZ or when sign flips against the trade
    sigLong[period] = nil
    sigShort[period] = nil
    flatSignal[period] = nil

    local devPips = pips(dev)
    local absZ = math.abs(z)

    if not inLong and not inShort and absZ >= EntryZ and devPips >= PipsBuffer then
        if z < 0 then
            -- dev < 0 ⇒ synth < actual ⇒ expect up‑revert ⇒ go LONG NZD/CAD
            inLong = true
            sigLong[period] = 0  -- plotted at 0 line in oscillator pane
        else
            -- dev > 0 ⇒ synth > actual ⇒ expect down‑revert ⇒ go SHORT NZD/CAD
            inShort = true
            sigShort[period] = 0
        end
    else
        -- Manage exits
        if inLong then
            if absZ <= ExitZ or z > 0 then
                inLong = false
                flatSignal[period] = 0
            end
        elseif inShort then
            if absZ <= ExitZ or z < 0 then
                inShort = false
                flatSignal[period] = 0
            end
        end
    end
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

 