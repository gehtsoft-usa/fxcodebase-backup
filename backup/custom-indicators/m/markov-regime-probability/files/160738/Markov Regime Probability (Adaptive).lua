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
Markov Regime Probability (v2.1 Auto, UI-harmonized with v3)
- Same Markov core, with adaptive thresholds:
  Upper/Lower = mean(PUP_window) ± AdaptK*std, clamped.
- Painting modes:
  * ByProb : fixed threshold ProbThresh (like v3)
  * ByAuto : adaptive thresholds (original v2 behavior)
]]

function Init()
    indicator:name("Markov Regime Probability (Adaptive)");
    indicator:description("2-state Markov with adaptive OR fixed thresholds; UI aligned with HMM v3.");
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
    indicator.parameters:addInteger("Period", "Lookback (bars)", "", 200, 50, 5000);

    -- Output
    indicator.parameters:addGroup("Output");
    indicator.parameters:addInteger("SmoothEMA", "EMA Smoothing (0=off)", "", 5, 0, 500);
    indicator.parameters:addColor("Pcol", "Probability Line Color", "", core.rgb(30, 144, 255));
    indicator.parameters:addInteger("Pwidth", "Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("Pstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Pstyle", core.FLAG_LINE_STYLE);

    -- Adaptive Thresholds (for ByAuto)
    indicator.parameters:addGroup("Adaptive Thresholds");
    indicator.parameters:addDouble("AdaptK", "Std Multiplier (K)", "Upper/Lower = mean ± K·std", 0.70, 0.10, 3.00);
    indicator.parameters:addInteger("ClampMin", "Min Threshold (%)", "Lower bound", 10, 0, 49);
    indicator.parameters:addInteger("ClampMax", "Max Threshold (%)", "Upper bound", 90, 51, 100);

    -- Painting
    indicator.parameters:addGroup("Painting");
    indicator.parameters:addBoolean("Paint", "Paint Candles on Main Chart", "", true);
    indicator.parameters:addString("PaintMode", "Painting Mode", "ByProb (fixed T) or ByAuto (adaptive)", "ByAuto");
    indicator.parameters:addStringAlternative("PaintMode", "ByProb", "", "ByProb");
    indicator.parameters:addStringAlternative("PaintMode", "ByAuto", "", "ByAuto");
    indicator.parameters:addInteger("ProbThresh", "Prob Threshold (0-50)", "Used only in ByProb", 60, 0, 50);
    indicator.parameters:addColor("Bull", "Bullish Color", "", core.rgb(0, 180, 0));
    indicator.parameters:addColor("Bear", "Bearish Color", "", core.rgb(200, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- locals
local src, PriceKey, Period, SmoothEMA, AdaptK, ClampMin, ClampMax;
local Paint, PaintMode, ProbThresh, Bull, Bear, Neutral, firstBar;
local PUP, UB, LB, emaStream, emaAlpha;
local openS, highS, lowS, closeS;

local function clamp(x,lo,hi) if x<lo then return lo elseif x>hi then return hi else return x end end
local function price_at(s, key, i) return s[key][i] end

local function estimate_transition(i)
    local uu, ud, du, dd = 1,1,1,1
    local jStart = math.max(firstBar + 1, i - Period + 1)
    for k=jStart,i do
        local up_k   = price_at(src, PriceKey, k)   > price_at(src, PriceKey, k-1)
        local up_km1 = (k-2) >= firstBar and (price_at(src, PriceKey, k-1) > price_at(src, PriceKey, k-2)) or false
        if up_km1 and up_k then uu=uu+1
        elseif up_km1 and (not up_k) then ud=ud+1
        elseif (not up_km1) and up_k then du=du+1
        else dd=dd+1 end
    end
    local puu = uu/(uu+ud)
    local pdu = du/(du+dd)
    return puu,pdu
end

local function posterior_now(i)
    if i<=firstBar then return 0.5 end
    local up = price_at(src, PriceKey, i) > price_at(src, PriceKey, i-1)
    return up and 0.7 or 0.3
end

local function compute_adaptive_thresholds(i)
    local start_i = math.max(firstBar + Period, i - Period + 1)
    local c,sum,sumsq = 0,0.0,0.0
    for k=start_i,i do
        local v = PUP[k]
        if v~=nil then c=c+1; sum=sum+v; sumsq=sumsq+v*v end
    end
    if c<5 then return 60,40 end
    local mean = sum/c
    local var  = (sumsq/c) - mean*mean; if var<0 then var=0 end
    local std  = math.sqrt(var)
    local upper = clamp(mean + AdaptK*std, 50, ClampMax)
    local lower = clamp(mean - AdaptK*std, ClampMin, 50)
    return upper, lower
end

function Prepare(nameOnly)
    PriceKey   = instance.parameters.Price
    Period     = instance.parameters.Period
    SmoothEMA  = instance.parameters.SmoothEMA
    AdaptK     = instance.parameters.AdaptK
    ClampMin   = instance.parameters.ClampMin
    ClampMax   = instance.parameters.ClampMax
    Paint      = instance.parameters.Paint
    PaintMode  = instance.parameters.PaintMode
    ProbThresh = instance.parameters.ProbThresh
    Bull       = instance.parameters.Bull
    Bear       = instance.parameters.Bear
    Neutral    = instance.parameters.Neutral

    src = instance.source
    firstBar = src:first()

    local name = profile:id() .. "(Auto," .. src:name() .. "," .. Period .. ")"
    instance:name(name)
    if nameOnly then return end

    PUP = instance:addStream("PUP", core.Line, name .. " P(UP)", "PUP", instance.parameters.Pcol, firstBar + Period)
    PUP:setWidth(instance.parameters.Pwidth)
    PUP:setStyle(instance.parameters.Pstyle)

    emaStream=nil; emaAlpha=0
    if SmoothEMA>0 then
        emaStream = instance:addInternalStream(firstBar, 0)
        emaAlpha = 2.0/(SmoothEMA+1.0)
    end

    -- show bands only in ByAuto mode (when meaningful)
    if PaintMode=="ByAuto" then
        UB = instance:addStream("UB", core.Line, name.." Upper", "UB", core.rgb(0,150,0), firstBar + Period)
        LB = instance:addStream("LB", core.Line, name.." Lower", "LB", core.rgb(180,0,0), firstBar + Period)
        UB:setStyle(core.LINE_DOT); LB:setStyle(core.LINE_DOT)
    end

    if Paint then
        PUP:setVisible(false); if UB then UB:setVisible(false) end; if LB then LB:setVisible(false) end
        openS  = instance:addStream("open",  core.Line, name..".open",  "open", Neutral, firstBar)
        highS  = instance:addStream("high",  core.Line, name..".high",  "high", Neutral, firstBar)
        lowS   = instance:addStream("low",   core.Line, name..".low",   "low",  Neutral, firstBar)
        closeS = instance:addStream("close", core.Line, name..".close", "close",Neutral, firstBar)
        instance:createCandleGroup("Candles", "Candles", openS, highS, lowS, closeS)
        core.host:execute("attachOutputToChart", "Candles")
    end
end

function Update(period, mode)
    if not src:hasData(period) then return end
    if Paint then
        openS[period]=src.open[period]; highS[period]=src.high[period]
        lowS[period]=src.low[period];   closeS[period]=src.close[period]
    end
    if period < firstBar + Period then return end

    local puu,pdu = estimate_transition(period)
    local p_now = posterior_now(period)
    local p_up  = p_now*puu + (1.0-p_now)*pdu

    if emaStream then
        if period==firstBar+Period then emaStream[period]=p_up
        else emaStream[period]=emaStream[period-1]+emaAlpha*(p_up-emaStream[period-1]) end
        p_up = emaStream[period]
    end

    local p100 = p_up*100.0
    PUP[period]=p100

    local bull=false; local bear=false
    if PaintMode=="ByProb" then
        local th = ProbThresh
        bull = (p100>=th); bear = (p100<=(100-th))
    else -- ByAuto
        local upper,lower = compute_adaptive_thresholds(period)
        if UB then UB[period]=upper end
        if LB then LB[period]=lower end
        bull = (p100>=upper); bear=(p100<=lower)
    end

    if Paint then
        if bull then openS:setColor(period, Bull)
        elseif bear then openS:setColor(period, Bear)
        else openS:setColor(period, Neutral) end
    else
        if bull then PUP:setColor(period, Bull)
        elseif bear then PUP:setColor(period, Bear)
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