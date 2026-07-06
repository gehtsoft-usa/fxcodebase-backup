--
-- "GBB.lua"
--

-- Geometric Bollinger Bands indicator
-- Calculates Bollinger Bands in log-space: exp(MA(log(price)) ± dev * StdDev(log(price)))
-- Suitable for log-scale charts to handle parabolic trends with multiplicative bands
-- Supports up to 3 deviation levels (set to 0 to disable); StdDev calculated manually
--


-- code version, revision and author
local NAME = "Geometric BB"
local DESCRIPTION = "Geometric Bollinger Bands (exp(MA(log(price)) ± dev * StdDev(log(price)))) with multi-dev support"
local VERSION = 1
local REVISION = 0
local DATE = "07/02/2026"
local REV_AUTHOR = "Steve_W"
local CHANGES = "v1.0 - multi-deviation bands with individual styles, geometric toggle"
local VERSION_TXT = "v" .. VERSION .. "." .. REVISION .. " " .. DATE 

-- revision history
-- 07/02/2026 v1.0 Steve_W - initial release with multi-dev bands and manual std dev


-- global list constants
local PRICE_TYPE = {"Close", "Open", "High", "Low", "Typical", "Weighted", "Median"}
local MA_TYPE    = {"EMA", "MVA"}

-- global constants
local LABEL_COLOUR = core.rgb(192, 255, 0)
local BLUE_COLOUR  = core.rgb(0, 128, 255)
local YELLOW_LIGHT = core.rgb(255, 255, 128)
local YELLOW_BASE  = core.rgb(255, 255, 0)
local YELLOW_DARK  = core.rgb(255, 204, 0)


function Init()
    local param = indicator.parameters
    
    indicator:name(NAME)
    indicator:description(DESCRIPTION)
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    
    param:addGroup("Calculation")
    param:addInteger("period", "MA Period", "", 20, 1, 1000)
    Add_list("ma_type",    "MA Type",    "EMA = Exponential, MVA = Simple Moving Average", "MVA", MA_TYPE)
    Add_list("price_type", "Price Type", "", "Close", PRICE_TYPE)
    param:addBoolean("use_geometric", "Use Geometric (Log-Space)", "Enable for geometric bands, disable for standard bands", true)
    
    param:addGroup("Bands 1")
    param:addDouble("dev1", "Deviation 1 (0=disable)", "", 2.0, 0.0, 5.0)
    param:addColor("bands1_colour", "Bands 1 Colour", "", YELLOW_BASE)
    param:addInteger("bands1_width", "Bands 1 Width", "", 1, 1, 5)
    param:addInteger("bands1_style", "Bands 1 Style", "", core.LINE_DOT)
    param:setFlag("bands1_style", core.FLAG_LINE_STYLE)
    
    param:addGroup("Bands 2")
    param:addDouble("dev2", "Deviation 2 (0=disable)", "", 0.0, 0.0, 5.0)
    param:addColor("bands2_colour", "Bands 2 Colour", "", YELLOW_LIGHT)
    param:addInteger("bands2_width", "Bands 2 Width", "", 1, 1, 5)
    param:addInteger("bands2_style", "Bands 2 Style", "", core.LINE_DOT)
    param:setFlag("bands2_style", core.FLAG_LINE_STYLE)
    
    param:addGroup("Bands 3")
    param:addDouble("dev3", "Deviation 3 (0=disable)", "", 0.0, 0.0, 5.0)
    param:addColor("bands3_colour", "Bands 3 Colour", "", YELLOW_DARK)
    param:addInteger("bands3_width", "Bands 3 Width", "", 1, 1, 5)
    param:addInteger("bands3_style", "Bands 3 Style", "", core.LINE_DOT)
    param:setFlag("bands3_style", core.FLAG_LINE_STYLE)
    
    param:addGroup("Style - Middle")
    param:addColor("middle_colour", "Middle Colour", "", BLUE_COLOUR)
    param:addInteger("middle_width", "Middle Width", "", 2, 1, 5)
    param:addInteger("middle_style", "Middle Style", "", core.LINE_SOLID)
    param:setFlag("middle_style", core.FLAG_LINE_STYLE)
    
    param:addGroup("About")
    param:addString("version", "Version", "Code by " .. REV_AUTHOR .. ": " .. CHANGES, VERSION_TXT)
end


-- global variables
local source = {}
local log_internal = {}
local ma_internal = {}
local middle = {}
local upper1 = {}; local lower1 = {}
local upper2 = {}; local lower2 = {}
local upper3 = {}; local lower3 = {}
local has_band1 = false
local has_band2 = false
local has_band3 = false
local first


-- initialisation
function Prepare(name_only)
    local param = instance.parameters
    
    source = instance.source
    first = source:first() + param.period - 1

    -- Build name with deviation values for enabled bands
    local dev_string = ""
    if param.dev1 > 0 then
        dev_string = dev_string .. param.dev1
    end
    if param.dev2 > 0 then
        if dev_string ~= "" then dev_string = dev_string .. "," end
        dev_string = dev_string .. param.dev2
    end
    if param.dev3 > 0 then
        if dev_string ~= "" then dev_string = dev_string .. "," end
        dev_string = dev_string .. param.dev3
    end
    
    local geo_flag = param.use_geometric and "Geo" or "Std"  -- Geo = Geometric, Std = Standard
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. param.price_type .. ", " 
                               .. param.ma_type .. ", " .. param.period .. ", " 
                               .. geo_flag .. ", " .. dev_string .. ")"
    instance:name(name)
    if name_only then return end
    
    instance:setLabelColor(LABEL_COLOUR)
    
    log_internal = instance:addInternalStream(source:first(), 0)
    
    -- Create the selected moving average on log(price) or price
    ma_internal = core.indicators:create(param.ma_type, log_internal, param.period)
    
    middle = instance:addStream("GBB.M", core.Line, name .. " Middle", "GBB.M", param.middle_colour, first)
    middle:setWidth(param.middle_width)
    middle:setStyle(param.middle_style)
    middle:setPrecision(2)
    
    -- Conditionally add band streams if deviation > 0
    if param.dev1 > 0 then
        has_band1 = true
        upper1 = instance:addStream("GBB.U1", core.Line, name .. " Upper1", "GBB.U1", param.bands1_colour, first)
        upper1:setWidth(param.bands1_width)
        upper1:setStyle(param.bands1_style)
        upper1:setPrecision(2)
        
        lower1 = instance:addStream("GBB.L1", core.Line, name .. " Lower1", "GBB.L1", param.bands1_colour, first)
        lower1:setWidth(param.bands1_width)
        lower1:setStyle(param.bands1_style)
        lower1:setPrecision(2)
    end
    
    if param.dev2 > 0 then
        has_band2 = true
        upper2 = instance:addStream("GBB.U2", core.Line, name .. " Upper2", "GBB.U2", param.bands2_colour, first)
        upper2:setWidth(param.bands2_width)
        upper2:setStyle(param.bands2_style)
        upper2:setPrecision(2)
        
        lower2 = instance:addStream("GBB.L2", core.Line, name .. " Lower2", "GBB.L2", param.bands2_colour, first)
        lower2:setWidth(param.bands2_width)
        lower2:setStyle(param.bands2_style)
        lower2:setPrecision(2)
    end
    
    if param.dev3 > 0 then
        has_band3 = true
        upper3 = instance:addStream("GBB.U3", core.Line, name .. " Upper3", "GBB.U3", param.bands3_colour, first)
        upper3:setWidth(param.bands3_width)
        upper3:setStyle(param.bands3_style)
        upper3:setPrecision(2)
        
        lower3 = instance:addStream("GBB.L3", core.Line, name .. " Lower3", "GBB.L3", param.bands3_colour, first)
        lower3:setWidth(param.bands3_width)
        lower3:setStyle(param.bands3_style)
        lower3:setPrecision(2)
    end
end


-- calculation
function Update(period, mode)
    local param = instance.parameters
    if period < first then return end
    
    -- Get current price based on selected type
    local price
    if param.price_type == "Close" then
        price = source.close[period]
    elseif param.price_type == "Open" then
        price = source.open[period]
    elseif param.price_type == "High" then
        price = source.high[period]
    elseif param.price_type == "Low" then
        price = source.low[period]
    elseif param.price_type == "Typical" then
        price = (source.high[period] + source.low[period] + source.close[period]) / 3
    elseif param.price_type == "Weighted" then
        price = (source.high[period] + source.low[period] + source.close[period] * 2) / 4
    elseif param.price_type == "Median" then
        price = (source.high[period] + source.low[period]) / 2
    else
        price = source.close[period]  -- fallback
    end
    
    -- Apply geometric transformation if enabled
    if param.use_geometric then
        if price > 0 then
            log_internal[period] = math.log(price)
        else
            log_internal[period] = log_internal[period - 1] or 0  -- carry forward or zero
        end
    else
        log_internal[period] = price  -- standard mode, no log transform
    end
    
    -- Update the moving average of log(price) or price
    ma_internal:update(mode)
    local ma_value = ma_internal.DATA[period]
    
    -- Manual standard deviation calculation over the last 'period' bars
    local sum_sq_diff = 0
    local count = 0
    for i = 0, param.period - 1 do
        local idx = period - i
        if idx >= source:first() and log_internal:hasData(idx) then
            local diff = log_internal[idx] - ma_value
            sum_sq_diff = sum_sq_diff + diff * diff
            count = count + 1
        end
    end
    
    local stdev = 0
    if count > 0 then
        stdev = math.sqrt(sum_sq_diff / count)  -- population std dev (divide by N)
    end
    
    -- Set the middle line
    if param.use_geometric then
        middle[period] = math.exp(ma_value)
    else
        middle[period] = ma_value
    end
    
    -- Set bands if enabled
    if has_band1 then
        local dev_adjust = stdev * param.dev1
        if param.use_geometric then
            upper1[period] = math.exp(ma_value + dev_adjust)
            lower1[period] = math.exp(ma_value - dev_adjust)
        else
            upper1[period] = ma_value + dev_adjust
            lower1[period] = ma_value - dev_adjust
        end
    end
    
    if has_band2 then
        local dev_adjust = stdev * param.dev2
        if param.use_geometric then
            upper2[period] = math.exp(ma_value + dev_adjust)
            lower2[period] = math.exp(ma_value - dev_adjust)
        else
            upper2[period] = ma_value + dev_adjust
            lower2[period] = ma_value - dev_adjust
        end
    end
    
    if has_band3 then
        local dev_adjust = stdev * param.dev3
        if param.use_geometric then
            upper3[period] = math.exp(ma_value + dev_adjust)
            lower3[period] = math.exp(ma_value - dev_adjust)
        else
            upper3[period] = ma_value + dev_adjust
            lower3[period] = ma_value - dev_adjust
        end
    end
end


-- add a string list parameter
function Add_list(param, param_txt, param_explain, param_default, param_list)
    indicator.parameters:addString(param, param_txt, param_explain, param_default)
    for i = 1, #param_list, 1 do
        indicator.parameters:addStringAlternative(param, param_list[i], "", param_list[i])
    end
end
