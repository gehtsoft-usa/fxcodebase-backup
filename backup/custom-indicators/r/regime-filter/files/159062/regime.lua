--
-- "regime.lua"
--
--
-- Developed from original source here:
-- https://www.tradingview.com/script/ia5ozyMF-MLExtensions/
-- by https://www.tradingview.com/u/jdehorty/
--
--
-- This indicator aims to detect trending or ranging markets
-- There is no exact explanation of the mechanics, but comments are added in the code below by interpretation
-- First, an adaptive smoothing constant is generated based on average price slope and volatility
-- The constant looks like a solution of a quadratic equation and scaled to be between 0 and 1 for use in EMA KAMA filter or price
-- The output KAMA slope is compared to averaged KAMA slope to select regime
-- Defaults are based on original authors values and code corrected for a minor error and numerical protections added for edge cases
--


-- code version, revision and author - update if you publish changes
local NAME = "REGIME"
local DESCRIPTION = "Regime Filter - trending or ranging market"
local VERSION = 1
local REVISION = 0
local DATE = "27/04/2025"
local REV_AUTHOR = "Steve_W"    -- for this revision
local CHANGES = "first release ported from @jdehorty pinescript"
local VERSION_TXT = "v" .. VERSION .. "." .. REVISION .. " " .. DATE 

-- revision history - update+add to history if you publish changes, improvements or bug fixes
-- 27/04/2025 v1.0 Steve_W - first release ported from @jdehorty pinescript


-- global constants
local LABEL_COLOUR = core.rgb(192, 255, 0)
local GREY_COLOUR = core.rgb(128, 128, 128)
local BLUE_COLOUR = core.rgb(0, 128, 255)


function Init()
    local param = indicator.parameters
    
    indicator:name(NAME)
    indicator:description(DESCRIPTION)
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
    
    param:addGroup("Calculation")
    param:addInteger("fast_ema_length", "Fast EMA Length", "price slope, and volatility filters", 9, 2, 1000)
    param:addInteger("slow_ema_length", "Slow EMA Length", "KAMA filter of price", 200, 2, 1000)
    param:addDouble("threshold", "Threshold", "trending when above this threshold or ranging when below", -0.1, -10, 10)
    param:addBoolean("display_signal", "Display as Signal", "", false)
    param:addGroup("Style")
    param:addInteger("line_width", "Line width", "", 2, 1, 5)
    param:addInteger("line_style", "Line style", "", core.LINE_SOLID)
    param:setFlag("line_style", core.FLAG_LINE_STYLE)
    param:addColor("indicator_colour", "Indicator Colour", "", BLUE_COLOUR)
    param:addColor("threshold_colour", "Threshold Colour", "", GREY_COLOUR)
    
    param:addGroup("About")
    param:addString("version", "Version", "Code for this revision by " .. REV_AUTHOR .. ": " .. CHANGES, VERSION_TXT)
end


-- global variables
local source = {}
local regime = {}           -- indicator output
local ema_roc1 = {}         -- EMA of price slope
local ema_volatility = {}   -- EMA of price volatility
local kama = {}             -- KAMA filter of price
local ema_kama_slope = {}   -- EMA of KAMA filtered price slope
local first
local k_slow
local k_fast


-- initialisation
function Prepare(name_only)
    local param = instance.parameters
    
    source = instance.source
    first = math.max(source:first(), 0) + math.max(param.slow_ema_length, param.fast_ema_length)
    
    local name = profile:id() .. "(" .. source:name() .. "," .. param.fast_ema_length .. ", " .. param.slow_ema_length
    if param.display_signal == true then name = name .. ", " .. param.threshold end
    name = name .. ")"
    instance:name(name)
    if name_only then return end
    
    instance:setLabelColor(LABEL_COLOUR)
    
    if param.display_signal == false then
        regime = instance:addStream("regime", core.Line, name, "Regime", param.indicator_colour, first)
        regime:setWidth(instance.parameters.line_width)
        regime:setStyle(instance.parameters.line_style)
    else
        regime = instance:addStream("regime", core.Bar, name, "Regime", param.indicator_colour, first)
    end
    if param.display_signal == false then
        regime:setPrecision(2)
        regime:addLevel(param.threshold, core.LINE_SOLID, param.line_width, param.threshold_colour)
    else
        regime:setPrecision(0)  
    end
    
    ema_roc1 = instance:addInternalStream(first, 0)
    ema_volatility = instance:addInternalStream(first, 0)
    kama = instance:addInternalStream(first, 0)
    ema_kama_slope = instance:addInternalStream(first, 0)

    k_slow = 2 / (param.slow_ema_length + 1)    -- price slope and volatility EMA's 
    k_fast = 2 / (param.fast_ema_length + 1)    -- KAMA slope EMA
end


-- calculation
function Update(period)
    local param = instance.parameters
    if period < first or source:size() <= first then return end
    
    local kama_slope
    local roc1 = source.close[period] - source.close[period - 1]                                                -- price slope ie. ROC(1)
    if period == first then
        ema_roc1[period] = roc1
        ema_volatility[period] = source.high[period] - source.low[period]
        kama[period] = source.close[period]
        kama_slope = 0
        ema_kama_slope[period] = math.abs(kama_slope)
    else
        ema_roc1[period] = roc1 * k_fast + ema_roc1[period - 1] * (1 - k_fast)                                  -- EMA of price change
                             
        local volatility = source.high[period] - source.low[period]                                             -- volatility of current bar
        ema_volatility[period] = volatility * k_fast + ema_volatility[period - 1] * (1 - k_fast)                -- EMA of volatility
                             
        local omega = ema_volatility[period] ~= 0 and math.abs(ema_roc1[period] / ema_volatility[period]) or 0  -- ratio of averaged price change & volatility
        local omega2 = omega * omega                                                                            -- cache omega^2
        
        -- adaptive smoothing factor alpha, is derived from the ratio of price slope to volatility,
        -- scaled to [0, 1] using a quadratic formula to balance responsiveness and smoothness
        local alpha = (-omega2 + math.sqrt(omega2 * omega2 + 16 * omega2)) / 8                  
        alpha = math.max(0, math.min(1, alpha))                                                                 -- ensure alpha is between 0 and 1 for edge cases
        
        kama[period] = alpha * source.close[period] + (1 - alpha) * kama[period - 1]                            -- KAMA EMA filter of price
    
        kama_slope = math.abs(kama[period] - kama[period - 1])                                                  -- absolute KAMA filter slope
        ema_kama_slope[period] = kama_slope * k_slow + ema_kama_slope[period - 1] * (1 - k_slow)                -- EMA KAMA filter slope
    end
    
    local regime_value = ema_kama_slope[period] > 1e-10 and (kama_slope - ema_kama_slope[period]) / ema_kama_slope[period] or 0  
    if param.display_signal then
        regime:set(period, regime_value >= param.threshold and 1 or 0)  -- trending or ranging signal
    else
        regime:set(period, regime_value)                                -- current slope compared to smoothed slope, and then also normalised
    end
end

