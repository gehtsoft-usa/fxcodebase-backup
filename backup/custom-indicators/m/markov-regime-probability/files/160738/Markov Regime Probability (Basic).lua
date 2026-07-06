-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76346&p=160738#p160738
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
Markov Regime Probability (v1.1 UI-harmonized with v3)
- Simple 2-state Markov on UP/DOWN, painting by probability threshold.
- Parameters aligned with v3 naming: groups, ProbThresh, PaintMode (ByProb).
]]

function Init()
    indicator:name("Markov Regime Probability (Basic)");
    indicator:description("Rolling 2-state Markov (UP/DOWN). UI aligned with HMM v3: ProbThresh, PaintMode.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    -- Data & Window
    indicator.parameters:addGroup("Data & Window");
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN",  "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH",  "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW",   "", "low");
    indicator.parameters:addStringAlternative("Price", "TYPICAL","", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED","", "weighted");
    indicator.parameters:addInteger("Period", "Lookback (bars)", "", 200, 20, 5000);

    -- Output
    indicator.parameters:addGroup("Output");
    indicator.parameters:addInteger("SmoothEMA", "EMA Smoothing (0=off)", "", 5, 0, 500);
    indicator.parameters:addColor("Pcol", "Probability Line Color", "", core.rgb(30, 144, 255));
    indicator.parameters:addInteger("Pwidth", "Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("Pstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Pstyle", core.FLAG_LINE_STYLE);

    -- Painting
    indicator.parameters:addGroup("Painting");
    indicator.parameters:addBoolean("Paint", "Paint Candles on Main Chart", "", true);
    indicator.parameters:addString("PaintMode", "Painting Mode", "ByProb only in v1", "ByProb");
    indicator.parameters:addStringAlternative("PaintMode", "ByProb", "", "ByProb");
    indicator.parameters:addInteger("ProbThresh", "Prob Threshold (0-50)", "Bull if P(UP)>=T; Bear if <=100-T", 60, 0, 50);
    indicator.parameters:addColor("Bull", "Bullish Color", "", core.rgb(0, 180, 0));
    indicator.parameters:addColor("Bear", "Bearish Color", "", core.rgb(200, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- locals
local src, PriceKey, Period, SmoothEMA, Paint, PaintMode, ProbThresh, Bull, Bear, Neutral;
local firstBar, PUP, emaStream, emaAlpha;
local openS, highS, lowS, closeS;

local function clamp01(x) if x<0 then return 0 elseif x>1 then return 1 else return x end end
local function price_at(s, key, i) return s[key][i] end

local function estimate_transition(i)
    local uu, ud, du, dd = 1,1,1,1
    local n=0
    local jStart = math.max(firstBar + 1, i - Period + 1)
    for k=jStart,i do
        local up_k   = price_at(src, PriceKey, k)   > price_at(src, PriceKey, k-1)
        local up_km1 = (k-2) >= firstBar and (price_at(src, PriceKey, k-1) > price_at(src, PriceKey, k-2)) or false
        if up_km1 and up_k then uu=uu+1
        elseif up_km1 and (not up_k) then ud=ud+1
        elseif (not up_km1) and up_k then du=du+1
        else dd=dd+1 end
        n=n+1
    end
    local puu = uu/(uu+ud)
    local pdu = du/(du+dd)
    return puu,pdu,n
end

local function posterior_now(i)
    if i<=firstBar then return 0.5 end
    local up = price_at(src, PriceKey, i) > price_at(src, PriceKey, i-1)
    return up and 0.7 or 0.3
end

function Prepare(nameOnly)
    PriceKey   = instance.parameters.Price
    Period     = instance.parameters.Period
    SmoothEMA  = instance.parameters.SmoothEMA
    Paint      = instance.parameters.Paint
    PaintMode  = instance.parameters.PaintMode
    ProbThresh = instance.parameters.ProbThresh
    Bull       = instance.parameters.Bull
    Bear       = instance.parameters.Bear
    Neutral    = instance.parameters.Neutral

    src = instance.source
    firstBar = src:first()

    local name = profile:id() .. "(Markov," .. src:name() .. "," .. Period .. ")"
    instance:name(name)
    if nameOnly then return end

    PUP = instance:addStream("PUP", core.Line, name .. " P(UP)", "PUP", instance.parameters.Pcol, firstBar + Period)
    PUP:setWidth(instance.parameters.Pwidth)
    PUP:setStyle(instance.parameters.Pstyle)

    if SmoothEMA>0 then
        emaStream = instance:addInternalStream(firstBar, 0)
        emaAlpha = 2.0/(SmoothEMA+1.0)
    end

    if Paint then
        -- sakrij liniju ako bojamo svijeće
        PUP:setVisible(false)
        openS  = instance:addStream("open",  core.Line, name..".open",  "open", Neutral, firstBar)
        highS  = instance:addStream("high",  core.Line, name..".high",  "high", Neutral, firstBar)
        lowS   = instance:addStream("low",   core.Line, name..".low",   "low",  Neutral, firstBar)
        closeS = instance:addStream("close", core.Line, name..".close", "close",Neutral, firstBar)
        instance:createCandleGroup("Candles", "Candles", openS, highS, lowS, closeS)
        core.host:execute("attachOutputToChart", "Candles") -- fixed spelling
    end
end

function Update(period, mode)
    if not src:hasData(period) then return end
    if Paint then
        openS[period]=src.open[period]; highS[period]=src.high[period]
        lowS[period]=src.low[period];   closeS[period]=src.close[period]
    end
    if period < firstBar + Period then return end

    local puu,pdu,n = estimate_transition(period)
    if n<=5 then return end
    local p_now = posterior_now(period)
    local p_up  = p_now*puu + (1.0-p_now)*pdu

    if SmoothEMA>0 then
        if period==firstBar+Period then emaStream[period]=p_up
        else emaStream[period]=emaStream[period-1]+emaAlpha*(p_up-emaStream[period-1]) end
        p_up = emaStream[period]
    end

    local p100 = p_up*100.0
    PUP[period]=p100

    -- Painting (ByProb only in v1)
    local th = ProbThresh
    if Paint then
        if p100 >= th then openS:setColor(period, Bull)
        elseif p100 <= (100-th) then openS:setColor(period, Bear)
        else openS:setColor(period, Neutral) end
    else
        if p100 >= th then PUP:setColor(period, Bull)
        elseif p100 <= (100-th) then PUP:setColor(period, Bear)
        else PUP:setColor(period, Neutral) end
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76346&p=160738#p160738
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