--
-- "RelativeVolumeStDev.lua"
--
--
-- Developed from Pine Script source for Relative Volume Standard Deviation from here: https://www.tradingview.com/v/Eize4T9L/
-- This indicator calculates the standard deviation of volume relative to its moving average
-- The volume deviation is normalized by the standard deviation and plotted as columns
-- Values above a threshold are colored blue; others are grey
-- Negative values can be optionally hidden
-- Displays as an oscillator in a separate panel below the price chart
--


-- code version, revision and author - update if you publish changes
local NAME = "REL_VOL_STDEV"
local DESCRIPTION = "Relative Volume Standard Deviation Oscillator"
local VERSION = 1
local REVISION = 0
local DATE = "15/05/2025"
local REV_AUTHOR = "Steve_W"    -- for this revision
local CHANGES = "first release ported from Pine Script"
local VERSION_TXT = "v" .. VERSION .. "." .. REVISION .. " " .. DATE 

-- revision history - update+add to history if you publish changes, improvements or bug fixes
-- 15/05/2025 v1.0 Steve_W - first release ported from Pine Script


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
    param:addInteger("length", "Length", "Period for moving average and standard deviation", 50, 2, 1000)
    param:addDouble("numdev", "Number of Deviations", "Threshold for coloring", 2.0, 1.0, 20.0)
    param:addBoolean("showneg", "Display negative deviations", "", false)
    param:addGroup("Style")
    param:addColor("above_colour", "Above Threshold Colour", "", BLUE_COLOUR)
    param:addColor("below_colour", "Below Threshold Colour", "", GREY_COLOUR)

    param:addGroup("About")
    param:addString("version", "Version", "Code for this revision by " .. REV_AUTHOR .. ": " .. CHANGES, VERSION_TXT)
end


-- global variables
local source = {}
local rel_vol_stdev = {}    -- indicator output
local ema_volume = {}       -- EMA of volume
local stdev_volume = {}     -- standard deviation of volume
local first
local k_ema


-- initialisation
function Prepare(name_only)
    local param = instance.parameters
    
    source = instance.source
    first = math.max(source:first(), 0) + param.length
    
    local name = profile:id() .. "(" .. source:name() .. "," .. param.length .. "," .. param.numdev
    if param.showneg == true then name = name .. ",true" else name = name .. ",false" end
    name = name .. ")"
    instance:name(name)
    if name_only then return end
    
    instance:setLabelColor(LABEL_COLOUR)
    
    rel_vol_stdev = instance:addStream("rel_vol_stdev", core.Bar, name, "RelVolStDev", GREY_COLOUR, first)
    rel_vol_stdev:setPrecision(2)
    
    ema_volume = instance:addInternalStream(first, 0)
    stdev_volume = instance:addInternalStream(first, 0)
    
    k_ema = 2 / (param.length + 1)    -- EMA smoothing constant
end


-- calculation
function Update(period)
    local param = instance.parameters
    if period < first or source:size() <= first then return end
    
    local volume = source.volume[period]
    
    -- calculate EMA of volume
    if period == first then
        ema_volume[period] = volume
    else
        ema_volume[period] = volume * k_ema + ema_volume[period - 1] * (1 - k_ema)
    end
    
    -- calculate standard deviation of volume
    local sum_squares = 0
    local count = 0
    for i = math.max(1, period - param.length + 1), period do
        if source.volume[i] ~= nil then
            local diff = source.volume[i] - ema_volume[period]
            sum_squares = sum_squares + diff * diff
            count = count + 1
        end
    end
    local variance = count > 0 and sum_squares / count or 0
    stdev_volume[period] = variance > 0 and math.sqrt(variance) or 0
    
    -- calculate relative volume standard deviation
    local diff = volume - ema_volume[period]
    local result = stdev_volume[period] > 1e-10 and diff / stdev_volume[period] or 0
    
    -- apply showneg logic
    if param.showneg or result > 0 then
        rel_vol_stdev:set(period, result)
    else
        rel_vol_stdev:set(period, nil)
    end
    
    -- set color based on numdev threshold
    if result >= param.numdev then
        rel_vol_stdev:setColor(period, param.above_colour)
    else
        rel_vol_stdev:setColor(period, param.below_colour)
    end
end

