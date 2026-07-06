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
HMM Regime Probability (v3)
Author: Mario Jemic + ChatGPT
Platform: FXCM Trading Station 2 / Indicore

What it does:
- 2-state Gaussian HMM on rolling log-returns:
    y_t = ln(Price[t] / Price[t-1])
- Parameters estimated by Baum–Welch (EM) each bar on last `Period` returns:
    pi, A (2x2), {mu1, var1}, {mu2, var2}
- Decoding:
    * Smoothed/filtered probability of the "bull" state (state with larger mu)
    * Viterbi most-likely state path for the window; last state used for coloring
- Painting:
    * PaintMode = "ByProb": bull if P(bull) >= ProbThresh, bear if <= 100-ProbThresh
    * PaintMode = "ByState": bull if Viterbi(last) == bull_state else bear
- Candle color rule: ONLY the first stream in candle group sets the color.

Notes:
- Uses scaling for Forward/Backward to avoid underflow (alpha/beta with c_t).
- Keeps things light: small EM_iters; rolling window; no external modules.
- Indexing: ALWAYS use stream[key][i], not as a function.
]]

function Init()
    indicator:name("HMM Regime (Baum–Welch + Viterbi)");
    indicator:description("2-state Gaussian HMM on log-returns with EM and Viterbi decoding; paints regime.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    -- Data / window
    indicator.parameters:addGroup("Data & Window");
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN",  "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH",  "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW",   "", "low");
    indicator.parameters:addStringAlternative("Price", "TYPICAL","", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED","", "weighted");
    indicator.parameters:addInteger("Period", "Lookback (bars)", "", 200, 50, 5000);

    -- EM / HMM
    indicator.parameters:addGroup("HMM / EM");
    indicator.parameters:addInteger("EMIters", "EM Iterations per bar", "", 8, 1, 50);
    indicator.parameters:addDouble("MinVar", "Minimal variance", "Floor for variance to avoid collapse", 1e-10, 1e-12, 1.0);
    indicator.parameters:addDouble("StayBias", "Initial stay prob (diag of A)", "Initial A = [[s,1-s],[1-s,s]]", 0.95, 0.60, 0.999);

    -- Output / smoothing
    indicator.parameters:addGroup("Output");
    indicator.parameters:addInteger("SmoothEMA", "EMA Smoothing of P(bull) (0=off)", "", 5, 0, 500);
    indicator.parameters:addColor("Pcol", "Probability Line Color", "", core.rgb(30,144,255));
    indicator.parameters:addInteger("Pwidth", "Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("Pstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Pstyle", core.FLAG_LINE_STYLE);

    -- Painting
    indicator.parameters:addGroup("Painting");
    indicator.parameters:addBoolean("Paint", "Paint Candles on Main Chart", "", true);
    indicator.parameters:addString("PaintMode", "Painting Mode", "ByProb: thresholds on P(bull); ByState: Viterbi last state", "ByProb");
    indicator.parameters:addStringAlternative("PaintMode", "ByProb", "", "ByProb");
    indicator.parameters:addStringAlternative("PaintMode", "ByState", "", "ByState");
    indicator.parameters:addInteger("ProbThresh", "Prob Threshold (0-50)", "Bull if P(bull) >= T; Bear if <= 100-T", 60, 0, 50);
    indicator.parameters:addColor("Bull", "Bullish Color", "", core.rgb(0, 180, 0));
    indicator.parameters:addColor("Bear", "Bearish Color", "", core.rgb(200, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- locals
local src, PriceKey, Period, EMIters, MinVar, StayBias;
local SmoothEMA, Paint, PaintMode, ProbThresh, Bull, Bear, Neutral;
local firstBar;

local Pbull;         -- stream 0..100 for P(bull_state)
local emaBuf;        -- internal EMA buffer
local emaAlpha;

-- Candle group (first stream sets color!)
local openS, highS, lowS, closeS;

-- helpers
local function max(a,b) if a>b then return a else return b end end
local function clamp(x,lo,hi) if x<lo then return lo elseif x>hi then return hi else return x end end
local function price_at(s, key, i) return s[key][i] end

-- gaussian pdf (log)
local function logN(y, mu, var)
    -- avoid log(0) via variance floor
    local v = var
    if v < MinVar then v = MinVar end
    local z = (y - mu)
    -- log of N(y|mu,var) = -0.5*log(2πv) - z^2/(2v)
    return -0.5 * (math.log(2*math.pi*v)) - (z*z)/(2*v)
end

-- Forward-Backward with scaling; returns gammas (T x 2), xis (T-1 x 2x2), and log-likelihood
local function fwbw(y, pi, A, mu1, var1, mu2, var2)
    local T = #y
    if T <= 0 then return nil,nil,nil end

    -- alpha, beta, c scaling
    local alpha = {}
    local beta  = {}
    local c     = {}
    alpha[1] = {0,0}
    beta[T]  = {0,0}
    c[1] = 0

    -- init alpha_1(i) = pi_i * b_i(y1); scale
    local b1_1 = math.exp(logN(y[1], mu1, var1))
    local b1_2 = math.exp(logN(y[1], mu2, var2))
    alpha[1][1] = pi[1] * b1_1
    alpha[1][2] = pi[2] * b1_2
    local c1 = alpha[1][1] + alpha[1][2]
    if c1 == 0 then c1 = 1e-300 end
    c[1] = c1
    alpha[1][1] = alpha[1][1] / c1
    alpha[1][2] = alpha[1][2] / c1

    -- forward
    for t=2,T do
        alpha[t] = {0,0}
        local b1 = math.exp(logN(y[t], mu1, var1))
        local b2 = math.exp(logN(y[t], mu2, var2))
        local a11,a12,a21,a22 = A[1][1],A[1][2],A[2][1],A[2][2]
        local a1 = (alpha[t-1][1]*a11 + alpha[t-1][2]*a21) * b1
        local a2 = (alpha[t-1][1]*a12 + alpha[t-1][2]*a22) * b2
        local ct = a1 + a2; if ct == 0 then ct = 1e-300 end
        c[t] = ct
        alpha[t][1] = a1 / ct
        alpha[t][2] = a2 / ct
    end

    -- init beta_T = 1/ c_T
    beta[T] = {1.0 / c[T], 1.0 / c[T]}

    -- backward
    for t=T-1,1,-1 do
        beta[t] = {0,0}
        local b1 = math.exp(logN(y[t+1], mu1, var1))
        local b2 = math.exp(logN(y[t+1], mu2, var2))
        local a11,a12,a21,a22 = A[1][1],A[1][2],A[2][1],A[2][2]
        beta[t][1] = (a11*b1*beta[t+1][1] + a12*b2*beta[t+1][2]) / c[t]
        beta[t][2] = (a21*b1*beta[t+1][1] + a22*b2*beta[t+1][2]) / c[t]
    end

    -- gammas and xis
    local gamma = {}
    local xi = {}
    for t=1,T do
        gamma[t] = {0,0}
        local denom = alpha[t][1]*beta[t][1] + alpha[t][2]*beta[t][2]
        if denom == 0 then denom = 1e-300 end
        gamma[t][1] = (alpha[t][1]*beta[t][1]) / denom
        gamma[t][2] = (alpha[t][2]*beta[t][2]) / denom
    end
    for t=1,T-1 do
        xi[t] = {{0,0},{0,0}}
        local b1 = math.exp(logN(y[t+1], mu1, var1))
        local b2 = math.exp(logN(y[t+1], mu2, var2))
        local a11,a12,a21,a22 = A[1][1],A[1][2],A[2][1],A[2][2]
        local num11 = alpha[t][1]*a11*b1*beta[t+1][1]
        local num12 = alpha[t][1]*a12*b2*beta[t+1][2]
        local num21 = alpha[t][2]*a21*b1*beta[t+1][1]
        local num22 = alpha[t][2]*a22*b2*beta[t+1][2]
        local denom = num11 + num12 + num21 + num22
        if denom == 0 then denom = 1e-300 end
        xi[t][1][1] = num11 / denom
        xi[t][1][2] = num12 / denom
        xi[t][2][1] = num21 / denom
        xi[t][2][2] = num22 / denom
    end

    -- log-likelihood = -sum log(c_t)
    local ll = 0.0
    for t=1,T do ll = ll + math.log(c[t]) end
    ll = -ll

    return gamma, xi, ll
end

-- One EM step
local function em_step(y, pi, A, mu1, var1, mu2, var2)
    local gamma, xi = fwbw(y, pi, A, mu1, var1, mu2, var2)
    if not gamma then return pi, A, mu1, var1, mu2, var2 end
    local T = #y

    -- re-estimate pi
    pi[1] = gamma[1][1]
    pi[2] = gamma[1][2]

    -- re-estimate A
    local sum_g1 = 0; local sum_g2 = 0
    local sum11,sum12,sum21,sum22 = 0,0,0,0
    for t=1,T-1 do
        sum11 = sum11 + xi[t][1][1]; sum12 = sum12 + xi[t][1][2]
        sum21 = sum21 + xi[t][2][1]; sum22 = sum22 + xi[t][2][2]
        sum_g1 = sum_g1 + gamma[t][1]
        sum_g2 = sum_g2 + gamma[t][2]
    end
    if sum_g1 < 1e-300 then sum_g1 = 1e-300 end
    if sum_g2 < 1e-300 then sum_g2 = 1e-300 end
    A[1][1] = sum11 / sum_g1; A[1][2] = sum12 / sum_g1
    A[2][1] = sum21 / sum_g2; A[2][2] = sum22 / sum_g2

    -- re-estimate Gaussians
    local w1,w2 = 0,0
    local m1,m2 = 0.0,0.0
    for t=1,T do
        w1 = w1 + gamma[t][1]; m1 = m1 + gamma[t][1]*y[t]
        w2 = w2 + gamma[t][2]; m2 = m2 + gamma[t][2]*y[t]
    end
    if w1 < 1e-300 then w1 = 1e-300 end
    if w2 < 1e-300 then w2 = 1e-300 end
    mu1 = m1 / w1; mu2 = m2 / w2

    local v1,v2 = 0.0,0.0
    for t=1,T do
        local d1 = y[t]-mu1; v1 = v1 + gamma[t][1]*d1*d1
        local d2 = y[t]-mu2; v2 = v2 + gamma[t][2]*d2*d2
    end
    var1 = v1 / w1; if var1 < MinVar then var1 = MinVar end
    var2 = v2 / w2; if var2 < MinVar then var2 = MinVar end

    return pi, A, mu1, var1, mu2, var2, gamma
end

-- Viterbi (log domain)
local function viterbi(y, pi, A, mu1, var1, mu2, var2)
    local T = #y
    if T <= 0 then return nil end
    local delta = {}; local psi = {}
    delta[1] = { math.log(pi[1]) + logN(y[1], mu1, var1),
                 math.log(pi[2]) + logN(y[1], mu2, var2) }
    psi[1] = {0,0}
    for t=2,T do
        delta[t] = {0,0}; psi[t] = {0,0}
        -- state 1
        local a = delta[t-1][1] + math.log(A[1][1])
        local b = delta[t-1][2] + math.log(A[2][1])
        if a >= b then delta[t][1] = a + logN(y[t], mu1, var1); psi[t][1] = 1
        else delta[t][1] = b + logN(y[t], mu1, var1); psi[t][1] = 2 end
        -- state 2
        a = delta[t-1][1] + math.log(A[1][2])
        b = delta[t-1][2] + math.log(A[2][2])
        if a >= b then delta[t][2] = a + logN(y[t], mu2, var2); psi[t][2] = 1
        else delta[t][2] = b + logN(y[t], mu2, var2); psi[t][2] = 2 end
    end
    -- backtrack last state
    local path = {}
    local last = (delta[T][1] >= delta[T][2]) and 1 or 2
    path[T] = last
    for t=T-1,1,-1 do path[t] = psi[t+1][path[t+1]] end
    return path
end

-- build log-return window [t-Period+1 .. t]
local function build_returns(i)
    local y = {}
    local start_i = math.max(firstBar + 1, i - Period + 1)
    for k=start_i, i do
        local p  = price_at(src, PriceKey, k)
        local pm = price_at(src, PriceKey, k-1)
        local r = 0.0
        if pm ~= 0 and pm ~= nil then r = math.log(p / pm) end
        y[#y+1] = r
    end
    return y
end

function Prepare(nameOnly)
    PriceKey  = instance.parameters.Price
    Period    = instance.parameters.Period
    EMIters   = instance.parameters.EMIters
    MinVar    = instance.parameters.MinVar
    StayBias  = instance.parameters.StayBias

    SmoothEMA = instance.parameters.SmoothEMA
    Paint     = instance.parameters.Paint
    PaintMode = instance.parameters.PaintMode
    ProbThresh= instance.parameters.ProbThresh
    Bull      = instance.parameters.Bull
    Bear      = instance.parameters.Bear
    Neutral   = instance.parameters.Neutral

    src      = instance.source
    firstBar = src:first()

    local name = profile:id() .. "(HMM," .. src:name() .. "," .. Period .. ")"
    instance:name(name)
    if nameOnly then return end

    Pbull = instance:addStream("Pbull", core.Line, name .. " P(bull)", "Pbull", instance.parameters.Pcol, firstBar + Period)
    Pbull:setWidth(instance.parameters.Pwidth)
    Pbull:setStyle(instance.parameters.Pstyle)

    if SmoothEMA > 0 then
        emaBuf = instance:addInternalStream(firstBar, 0)
        emaAlpha = 2.0 / (SmoothEMA + 1.0)
    end

    if Paint then
        -- Ako bojaš svijeće na glavnom chartu, oscilator možeš sakriti:
        Pbull:setVisible(false)

        openS  = instance:addStream("open",  core.Line, name .. ".open",  "open", Neutral, firstBar)
        highS  = instance:addStream("high",  core.Line, name .. ".high",  "high", Neutral, firstBar)
        lowS   = instance:addStream("low",   core.Line, name .. ".low",   "low",  Neutral, firstBar)
        closeS = instance:addStream("close", core.Line, name .. ".close", "close",Neutral, firstBar)
        instance:createCandleGroup("Candles", "Candles", openS, highS, lowS, closeS)
        core.host:execute("attachOutputToChart", "Candles")
    end
end

function Update(period, mode)
    if not src:hasData(period) then return end

    -- mirror candles if painting
    if Paint then
        openS[period]  = src.open[period]
        highS[period]  = src.high[period]
        lowS[period]   = src.low[period]
        closeS[period] = src.close[period]
    end

    if period < firstBar + Period then return end

    -- 1) Windowed log-returns
    local y = build_returns(period)
    local T = #y
    if T < 10 then return end

    -- 2) Init params (moments + stay bias)
    -- pi
    local pi = {0.5, 0.5}
    -- A
    local s = StayBias
    local A = { {s, 1.0 - s},
                {1.0 - s, s} }
    -- moments for init mus/vars
    local sum, sumsq = 0.0, 0.0
    for t=1,T do sum = sum + y[t]; sumsq = sumsq + y[t]*y[t] end
    local mean = sum / T
    local var  = (sumsq / T) - mean*mean; if var < MinVar then var = MinVar end
    local std  = math.sqrt(var)

    local mu1, var1 = mean - 0.5*std, var
    local mu2, var2 = mean + 0.5*std, var

    -- 3) EM iterations
    local gamma_last = nil
    for it=1,EMIters do
        pi, A, mu1, var1, mu2, var2, gamma_last = em_step(y, pi, A, mu1, var1, mu2, var2)
    end

    -- 4) Identify bull state = state with larger mean
    local bull_state = (mu1 >= mu2) and 1 or 2

    -- 5) Probability of bull at last observation (smoothed)
    local p_bull = 0.5
    if gamma_last then
        p_bull = gamma_last[T][bull_state]
    end
    if SmoothEMA > 0 then
        if period == firstBar + Period then
            emaBuf[period] = p_bull
        else
            local prev = emaBuf[period - 1]
            emaBuf[period] = prev + emaAlpha * (p_bull - prev)
        end
        p_bull = emaBuf[period]
    end
    local p100 = clamp(p_bull * 100.0, 0, 100)
    Pbull[period] = p100

    -- 6) Viterbi last state (for PaintMode="ByState")
    local vState = nil
    if Paint and PaintMode == "ByState" then
        local path = viterbi(y, pi, A, mu1, var1, mu2, var2)
        if path then vState = path[T] end
    end

    -- 7) Painting
    if Paint then
        if PaintMode == "ByProb" then
            local th = ProbThresh
            local bull = (p100 >= th)
            local bear = (p100 <= (100 - th))
            if bull then
                openS:setColor(period, Bull)
            elseif bear then
                openS:setColor(period, Bear)
            else
                openS:setColor(period, Neutral)
            end
        else
            -- ByState (Viterbi)
            if vState == bull_state then
                openS:setColor(period, Bull)
            else
                openS:setColor(period, Bear)
            end
        end
    else
        -- If oscillator only, tint line by regime for clarity
        if p100 >= ProbThresh then
            Pbull:setColor(period, Bull)
        elseif p100 <= (100 - ProbThresh) then
            Pbull:setColor(period, Bear)
        else
            Pbull:setColor(period, Neutral)
        end
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