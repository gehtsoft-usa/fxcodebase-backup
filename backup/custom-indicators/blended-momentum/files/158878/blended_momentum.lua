--
-- "blended_momentum.lua"
--
-- original code by: SM Webb April 2025 aka Steve_W per fxcodebase
--
-- Inspired by ideas of Linda Raschke where she sometimes uses multiple timeframe momentum oscillators to gauge a market
-- https://www.youtube.com/watch?v=NDg0VZFvFXU
-- This work develops further into a flexible custom indicator
--
-- The indicator averages a number of different period momentum indicators (selectable from "ROC", "RSI", "CMO", or "User Defined")
-- For "User Defined Momentum Indicator", enter the required indicator name and "User Defined Offset" value to ensure output is symmetrically bipolar
-- "DETERMINISTIC BOLTZMANN APPROXIMATION" is a given recent example - it has first to be installed to use it
-- The number of indicators and their periods is defined with a "," or " " delimited list of periods
-- For example: Blended ROC = [ROC(2)+ROC(3)+ROC(4)+ROC(5)+ROC(6)]/5, is defined by setting "Periods List" to "2,3,4,5,6" 
-- Blended momentum is displayed as either a histogram or line oscillator - colour and shading representing direction and slope
--
-- Optional other modes...
-- "Momentum x Volume": low volume periods are de-emphasized where a momentum indication may have less meaning 
-- "Max-Min": difference between highest momentum reading and the lowest for the list of indicators
-- "Geometric Mean": similar to RMS this averages the momentum - peaks might indicate extreme moves have occurred. Momentum direction is not indicated
-- "Differentiated": the slope of the momentum - similar to acceleration, and momentum being velocity
-- "Integrated": the momentum is re-integrated to give a synthetic price curve - the function includes a decay parameter to keep the signal bipolar 
-- "Separate Indicators": all indicators overlaid - look for convergence (entry area) and spreading (exit area - or possibly reverse) as Raschke explains
--
-- The indicator is designed to supplement trading decisions in conjunction with other metrics
--


-- code version, revision and author - update if you publish changes
local NAME = "Blended Momentum"
local DESCRIPTION = "Blended Momentum Indicator"
local VERSION = 1
local REVISION = 0
local DATE = "05/04/2025"
local REV_AUTHOR = "Steve_W"    -- for this revision
local VERSION_TXT = "v" .. VERSION .. "." .. REVISION .. " " .. DATE

-- revision history - update+add to history if you publish changes, improvements or bug fixes
-- 4/4/2025 v1.0 Steve_W - first release



-- global lists
local INDICATOR_TYPE = {"ROC", "RSI", "CMO", "User Defined"}
local DISPLAY_MODE = {"Momentum", "Momentum x Volume", "Max-Min", "Geometric Mean", "Differentiated", "Integrated", "Separate Indicators"}
local DISPLAY_STYLE = {"Histogram", "Line"}

-- global constants
local LABEL_COLOUR = core.rgb(192, 255, 0)
local GREY_COLOUR = core.rgb(128, 128, 128)


-- parameters
function Init()
    local param = indicator.parameters

    indicator:name(NAME);
    indicator:description(DESCRIPTION)
    indicator:requiredSource(core.Bar)  -- core.Tick could be used, however some other external indicators are found to be coded requiring Bar data
                                        -- "DETERMINISTIC BOLTZMANN APPROXIMATION" is one such example!
    indicator:type(core.Oscillator)
    
    param:addGroup("Calculation")
    Add_list("indicator_type", "Momentum Indicator Type", "", "ROC", INDICATOR_TYPE)
    param:addString("user_defined", "User Defined Momentum Indicator", "for use if indicator type is not defined above list", "DETERMINISTIC BOLTZMANN APPROXIMATION")
    param:addDouble("user_defined_offset", "User Defined Offset", "to make momentum indicator bipolar - for example, RSI has output 0-100, so subtract 50", 0)
    param:addString("period_list", "Periods List", "add required list of periods delimited by spaces or commas", "2,3,4,5,6")
    Add_list("display_mode", "Display Mode", "", "Momentum", DISPLAY_MODE)
    param:addDouble("integration_decay", "Integration Decay Factor", "for use with integration mode", 0.95, 0, 1)
    
    param:addGroup("Style")
    Add_list("display_style", "Display Style", "", "Histogram", DISPLAY_STYLE)
    param:addColor("up_colour", "Up Colour", "", core.rgb(0, 255, 0))
    param:addColor("down_colour", "Down Colour", "", core.rgb(255, 0, 0))
    param:addInteger("darken_reduced_momentum", "Darken % for Reduced Momentum", "", 50, 0, 100)
    param:addInteger("line_width", "Line Width", "", 2, 1, 5)
    
    param:addGroup("About")
    param:addString("version", "Version", "Code for this revision by " .. REV_AUTHOR, VERSION_TXT)
end


-- Indicator instance initialization    
local source = {}                       -- chart source
local momentum_indicator = {}           -- table of indicators
local momentum = {}                     -- result of momentum calculation
local signal = {}                       -- indicator output
local ind = {}                          -- streams to display separate indicators
local first
local period_list
function Prepare(nameOnly)   
    local param = instance.parameters   -- brevity variable for accessing parameters...
    
    source = instance.source
    
    local indicator_type = param.indicator_type
    if param.indicator_type == "User Defined" then indicator_type = param.user_defined end
    local name = profile:id() .. "(" .. instance.source:name().. "."
                                     .. indicator_type .. ","
                                     .. param.display_mode .. ","
                                     .. param.period_list .. ")"
    instance:name(name)
    if nameOnly then return end
    
    -- create the list of indicators
    period_list = Delimit_numbers(param.period_list)
    local i
    local max_period = 0
    local indicator_type = param.indicator_type
    if param.indicator_type == "User Defined" then indicator_type = param.user_defined end
    assert(core.indicators:findIndicator(indicator_type) ~= nil, "The indicator " .. indicator_type .. " must be installed")
    for i = 1, #period_list, 1 do
        momentum_indicator[i] = core.indicators:create(indicator_type, source, period_list[i])
        if period_list[i] > max_period then max_period = period_list[i] end
    end
    
    -- add streams
    first = source:first() + max_period
    momentum = instance:addInternalStream(first, 0)
        
    if param.display_mode == "Separate Indicators" then
        for i = 1, #period_list, 1 do
            ind[i] = instance:addStream("ind" .. i, core.Line, name, "I(" .. period_list[i] .. ")",
                                        Darken_colour(param.up_colour, 100 - ((i - 1) * 80 / #period_list)), first)
            ind[i]:setWidth(param.line_width)
            ind[i]:setPrecision(2)
        end
        ind[1]:addLevel(0, core.LINE_SOLID, param.line_width, GREY_COLOUR)
    elseif param.display_style == "Histogram" then
        signal = instance:addStream("signal", core.Bar, name, "signal", GREY_COLOUR, first)
        signal:setPrecision(2)
        signal:addLevel(0, core.LINE_SOLID, param.line_width, GREY_COLOUR)
    elseif param.display_style == "Line" then
        signal = instance:addStream("signal", core.Line, name, "signal", GREY_COLOUR, first)
        signal:setWidth(param.line_width)
        signal:setPrecision(2)
        signal:addLevel(0, core.LINE_SOLID, param.line_width, GREY_COLOUR)
    end
    
    instance:setLabelColor(LABEL_COLOUR)
end


-- compute indicator
function Update(period, mode)
    local param = instance.parameters
    
    if period < first or not source:hasData(period) then return end
    
    
    local i
    if param.display_mode == "Max-Min" then
        local max_mom = -100
        local min_mom = 100
        for i = 1, #period_list, 1 do
            momentum_indicator[i]:update(mode)
            if momentum_indicator[i].DATA[period] > max_mom then max_mom = momentum_indicator[i].DATA[period] end
            if momentum_indicator[i].DATA[period] < min_mom then min_mom = momentum_indicator[i].DATA[period] end
        end
        momentum[period] = max_mom - min_mom
    elseif param.display_mode == "Geometric Mean" then
        momentum[period] = 1
        for i = 1, #period_list, 1 do
            momentum_indicator[i]:update(mode)
            momentum[period] = momentum[period] * momentum_indicator[i].DATA[period]
        end
        momentum[period] = math.pow(math.abs(momentum[period]), 1 / #period_list)
    else
        momentum[period] = 0
        for i = 1, #period_list, 1 do
            momentum_indicator[i]:update(mode)
            momentum[period] = momentum[period] + momentum_indicator[i].DATA[period]
            if param.display_mode == "Separate Indicators" then
                ind[i][period] = momentum_indicator[i].DATA[period]
            end
        end
        momentum[period] = momentum[period] / #period_list
    end
     
    -- make indicator bipolar, if required
    if param.display_mode ~= "Geometric Mean" then
        if param.indicator_type == "RSI" then momentum[period] = momentum[period] - 50 end
        if param.indicator_type == "User Defined" then momentum[period] = momentum[period] - param.user_defined_offset end
    end
    
    -- scale in volume, if required
    if param.display_mode == "Momentum x Volume" then momentum[period] = momentum[period] * source.volume[period] end
    
    if param.display_mode == "Differentiated" then
        signal[period] = momentum[period] - momentum[period - 1]
    elseif param.display_mode == "Integrated" then
        if signal[period - 1] == nil then
            signal[period - 1] = 0
        else
            signal[period] = param.integration_decay * (signal[period - 1] + momentum[period])  -- decay is required to keep signal bipolar
        end
    elseif param.display_mode == "Separate Indicators" then
        return
    else
        signal[period] = momentum[period]
    end
    
    -- colour the indicator accoring to direction and slope 
    local col = GREY_COLOUR
    if signal[period] > 0 then
        col = param.up_colour
        if signal[period] < signal[period - 1] then col = Darken_colour(col, param.darken_reduced_momentum) end
    end
    if signal[period] < 0 then
        col = param.down_colour
        if signal[period] > signal[period - 1] then col = Darken_colour(col, param.darken_reduced_momentum) end
    end
    signal:setColor(period, col)
end              


-----------------------
-- utility functions separated out from main code


-- add a string list parameter
function Add_list(param, param_txt, param_explain, param_default, param_list)
    indicator.parameters:addString(param, param_txt, param_explain, param_default)
    for i = 1, #param_list, 1 do
        indicator.parameters:addStringAlternative(param, param_list[i], "", param_list[i])
    end
end


 -- darken to a percentage of input colour
function Darken_colour(col, percent)
    percent = math.max(20, math.min(100, percent))  -- clamp value 20-100%
    percent = percent / 100
    local r = col % 256                             -- unpack colour value into RGB values
    local g = math.floor(col / 256) % 256
    local b = math.floor(col / 256 / 256) % 256
    r = math.floor(r * percent)                     -- scale colours
    g = math.floor(g * percent)
    b = math.floor(b * percent)
    return r + (g * 256) + (b * 256 * 256)          -- repack
end
 
 
-- extract a table of numbers from a delimited string
function Delimit_numbers(str)
    local numbers = {}
    for num in str:gmatch("%d+") do
        table.insert(numbers, tonumber(num))
    end
    return numbers
end