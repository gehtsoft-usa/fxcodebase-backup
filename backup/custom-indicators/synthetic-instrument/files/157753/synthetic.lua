--
-- Synthetic instrument indicator
-- "synthetic.lua"
--
----------------------------------
-- CODE IS PROVIDED FREE AND "AS-IS" WITHOUT ANY WARRANTIES, EITHER EXPRESSED OR IMPLIED
-- PLEASE USE CODE AT YOUR OWN DISCRETION
-- full FXCodeBase License and Risk Notice: https://fxcodebase.com/code/viewtopic.php?f=17&t=299
----------------------------------
--
--
-- for further details on this indicator see here: https://fxcodebase.com/code/viewtopic.php?f=17&t=75486
-- please reports bugs or improvements at the above link
-- code contains comments to help understand function
--
-- Original code by: SM Webb January 2025 aka Steve_W per fxcodebase
--
-- Calculate an average or sum of N selectable instruments
-- "Geometric mean" -> product of N instruments raised to power 1/N instruments
-- "Linear Product" -> product of N instruments
-- "Sum Pips" -> sum of N instruments in Pips (similar to N simultaneous trades)
-- "Sum P/L" -> sum of N instruments in P/L (as above but using PipCost to give sum in currency)
-- "Harmonic Mean" -> N / (sum N inverted instruments)
-- "RMS" -> sqrt(average of sum N squared instruments)
-- "Cubic Mean" -> cube root(average of sum N cubed instruments)
-- "Heronian Mean" -> special mean only applied to instrument 1 & 2
-- each instrument is defined as normal/inverted/disabled in calculation
--
-- The option "Linear Product" is useful for conversion of price - eg. XAUGBP = XAUUSD / GBPUSD
--
-- "Geometric mean" should be considered as a "strength" - it is not a real price value
-- examples:
-- 1) US stocks strength Close= (SPX500.close x NAS100.close x US30.close)^(1/3)
-- 2) USD currency strength Close = (1/EURUSD.close x USDJPY.close x 1/GBPUSD.close x USDCAD.close x 1/AUDUSD.close x 1/NZDUSD.close x USDCHF.close)^(1/7) 
--
-- The calculation is performed using same method on OHLC candle values to give an estimate of high/low swings (this is not exact actual value)
-- For example:
-- 1) US stocks strength High = (SPX500.high x NAS100.high x US30.high)^(1/3)
-- 2) USD currency strength High = (1/EURUSD.low x USDJPY.high x 1/GBPUSD.low x USDCAD.high x 1/AUDUSD.low x 1/NZDUSD.low x USDCHF.high)^(1/7) 
--
-- The calculation includes summed volume data for the selected instruments
-- Additionally there is a weighted directional volume option
--
-- Pre-configured instrument basket options are provided - these are down to personal preference and may easilly be adapted by editing code



---------------------------------
-- see section near end of file:
-- Code uses a modified version of Managed streams Class from here: https://fxcodebase.com/code/viewtopic.php?f=17&t=4037&p=124465&hilit=better_volume.lua#p124465
-- Better Volume Indicator (modified to reconstruct the volume from lower time-frame bars)
-- Copyright (c) 2012 Steven Dickinson
-- http://robocod.blogspot.co.uk/
---------------------------------


-- History
-- if code is edited, bug-fixed, improved, or refactored please update with brief details
-- Version 1.0 SM Webb 01/01/2025:  "First release - mostly debugged"
-- Version 2.0 SM Webb 24/01/2025:  " added: Sum Pips, Sum P/L, Harmonic Mean, Overlay, % Change, Basket Options, Code Tidy"
-- Version 2.1 SM Webb 25/01/2025:  " improved stability, bug fixes, added: RMS, Heronian, energy complex"
-- Version 3.0 SM Webb 13/02/2025:  " bug fixes, New Baskets, Directional volume method, Profile name improve, Code Tidy"



-- code version, revision, date, author and version details - update these lines if changes are made
local VERSION = 3
local REVISION = 0
local DATE = "13/02/2025"
local REV_AUTHOR = "Steve_W"
local VERSION_TXT = "v" .. VERSION .. "." .. REVISION .. " " .. DATE .. " bug fixes, New Baskets, Directional volume method, Profile name improve, Code Tidy"



-- global constant list arrays
local MAX_INSTRUMENTS = 15          -- maximum number of instruments that may be used by indicator - edit value to needs...
                                    -- currency strengths for majors require ~7, but this could be extended for EUR or USD to include exotics or lesser currencies eg. USDNOK, USDSEK
local PRICE_TYPE = {"Bid", "Ask"}
local TF = {"Chart", "m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "H12", "D1", "W1", "M1", "W13", "W51"}
local BASKET = {"User List",                                                                            -- user defines the basket
                "Chart Pair", "Chart Pair Numerator", "Chart Pair Denominator",                         -- chart instrument xxx/yyy either xxx strength, yyy strength, 
                                                                                                        -- or xxx/yyy strength (intended for for directional volume)
                "USD", "EUR", "GBP", "CAD", "AUD", "NZD", "JPY", "CHF",                                 -- majors
                "NOK", "SEK", "ZAR", "HUF", "TRY",                                                      -- exotics
                "USD Extended", "EUR Extended",
                "Chart Currency Pair",                                                                  -- all elements of chart currency pair - only majors+crosses
                "US Stock Indices", "European Stock Indices", "Asia Stock Indices",                     -- stock indices by region
                "Risk-On", "Safe Haven",                                                                -- risk on/off feeling
                "North America", "Europe", "Australasia", "Asia", "Latin America", "Scandinavia",       -- currency baskets by region
                "Commodity Currencies USD", "Commodity Currencies USD & EUR",                           -- specialty currency baskets
                "Oil", "Oil not in USD", "Energy Complex",                                              -- energy
                "Monetary Metals", "Gold not in USD", "Silver not in USD", "Copper not in USD",         -- money
                "Gold Majors", "Silver Majors", "Gold/Silver", "Gold/SPX500", "Dow/Gold",               -- money
                "Metals Complex",                                                                       -- metals commodities
                "Softs"}                                                                                -- other commodities
local FILTER = {"EMA", "MVA"}
local DVOL_PRICE_TYPE = {"Open", "High", "Low", "Close", "Median", "Typical", "Weighted"}               -- source data for directional volume
local CALCULATION_METHOD = {"Geometric Mean", "Harmonic Mean", "RMS", "Cubic Mean", "Linear Product", "Sum Pips", "Sum P/L", "Heronian Mean"}  
local POLARITY = {"Normal", "Inverted", "Disabled"}
local DISPLAY_MODE = {"Candles", "Open", "High", "Low", "Close", "Median", "Typical", "Weighted", "Volume", "Directional Volume", "Percentage Change"}


-- global list arrays
local synthetic, signal, source, stream, pip_cost, point_size = {}, {}, {}, {}, {}, {}
local overlay, instrument, polarity, dvol_filter = {}, {}, {}, {} 
local o, h, l, c, m, t, w, v, dir_v = {}, {}, {}, {}, {}, {}, {}, {}, {} -- internal data streams: OHLC, Median, Typical, Weighted, Volume, Directional Volume
local dvol_trace = {}


-- global variables
local first, loading, num_instruments
local ref_offset                            -- reference value for Sum Pips, Sum P/L and Percentage Change 


-- parameters - note: to simplify code, "addStringAlternative(...)" lists are used from above global constants via Add_list(...) utility function
function Init()
    local param = indicator.parameters      -- abbreviation for parameters to make code more readable
    local i

    indicator:name("Synthetic Instrument v" .. VERSION .. "." .. REVISION)
    indicator:description("Instrument constructed from geometric mean of other instruments")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
    
    param:addGroup("Source Data")
    Add_list("bid_ask_data", "Price Type", "", "Bid", PRICE_TYPE)
    Add_list("source_period", "Source Period", "for each instrument stream", "Chart", TF)
    Add_list("basket", "Basket Selection",
             "built in basket of instruments, expand list by editing code, user must be subscribed to required instruments",
             "User List", BASKET)
     
    param:addGroup("User List")
    for i = 1, MAX_INSTRUMENTS, 1 do
        param:addString("instrument" .. i, "User Instrument " .. i, "", "")
        param:setFlag("instrument" .. i, core.FLAG_INSTRUMENTS)
    end
    
    param:addGroup("Calculation")
    Add_list("calculation_method", "Calculation Method", "", "Geometric Mean", CALCULATION_METHOD)
    for i = 1, MAX_INSTRUMENTS, 1 do
        local default = "Disabled"
        if i == 1 then default = "Normal" end
        Add_list("polarity" .. i, "Polarity" .. i, "polarity used in the product or left out of calculation", default, POLARITY)
    end
    
    param:addGroup("Directional Volume")
    Add_list("dvol_price_type", "Use Price Type", "price data used to calculat directional volume", "Close", DVOL_PRICE_TYPE)
    Add_list("dvol_filter_type", "Filter Type", "filter applied to directional volume output", "EMA", FILTER)
    param:addInteger("dvol_filter_N", "Filter Length", "", 9, 2, 200)
    param:addBoolean("dvol_scale_hl", "Scale with |Delta Price/(H-L)|", "pro-rata volume contribution from each instrument by this factor", true)
    param:addBoolean("dvol_colour", "Show Direction Colour","", true)
    
    param:addGroup("Display")     
    Add_list("display_mode", "Display Mode", "", "Candles", DISPLAY_MODE)
    param:addBoolean("overlay_source", "Overlay Chart Instrument", "", false)
    param:addBoolean("overlay_invert", "Invert Overlay", "", false)
    param:addInteger("lookback", "Lookback Last N Bars", "for Sum Pips, Sum P/L, normalisation period for overlay, and percentage change", 200, 0, 1000)
    param:addInteger("levels", "Upper/Lower Levels for Percentage Change", "for use on percentage change display", 5, 0, 200)
    param:addColor("synthetic_colour", "Synthetic Line Colour", "", core.rgb(0, 128, 255))  -- blue
    param:addColor("overlay_colour", "Overlay Line Colour", "", core.rgb(255, 255, 0))      -- yellow
    param:addInteger("synthetic_width", "Synthetic Line Width", "", 2, 1, 5)
    param:addInteger("overlay_width", "Overlay Line Width", "", 2, 1, 5)
    param:addInteger("synthetic_style", "Synthetic Line Style", "", core.LINE_SOLID)
    param:setFlag("synthetic_style", core.FLAG_LINE_STYLE)
    param:addInteger("overlay_style", "Overlay Line Style", "", core.LINE_SOLID)
    param:setFlag("overlay_style", core.FLAG_LINE_STYLE)
    param:addColor("up_colour", "Up Colour", "", core.COLOR_UPCANDLE)
    param:addColor("down_colour", "Down Colour", "", core.COLOR_DOWNCANDLE)
    param:addBoolean("shorten_name", "Shorten Indicator Name", "", false);
    
    param:addGroup("About")
    param:addInteger("version", "Version", VERSION_TXT, VERSION, VERSION, VERSION)
    param:addInteger("revision", "Revision", VERSION_TXT, REVISION, REVISION, REVISION)
    param:addString("rev_author", "Revision Author", "for this code revision", REV_AUTHOR)
end


-- utility function to add a string list parameter
function Add_list(param, param_txt, param_explain, param_default, param_list)
    indicator.parameters:addString(param, param_txt, param_explain, param_default)
    for i = 1, table.getn(param_list), 1 do
        indicator.parameters:addStringAlternative(param, param_list[i], "", param_list[i])
    end
end
 

-- indicator instance initialization    
function Prepare(nameOnly) 
    local param = instance.parameters   -- abbreviation for parameters to make code more readable
    loading = false
    
    source = instance.source
    first = source:first() + param.dvol_filter_N
    
    -- create custom basket? - edit code to expand options, user must be subscribed to required instruments
    local missing_subscriptions = ""
    if param.basket ~= "User List" then missing_subscriptions = Configure_inbuilt() end
    
    -- special case for Heronian mean
    if param.calculation_method == "Heronian Mean" then
        for i = 3, MAX_INSTRUMENTS, 1 do
            param:setString("polarity" .. i, "") -- blank the polarity to make it more obvious Heronian only applies to first two instruments
        end
    end
 
    -- extract instrument+polarity values, and count number
    num_instruments = 0
    local i
    for i = 1, MAX_INSTRUMENTS, 1 do
        instrument[i] = param:getString("instrument" .. i)       -- extract instrument
        polarity[i] = param:getString("polarity" .. i)           -- extract polarity
        if instrument[i] == "" then                              -- delete polarity if instrument is missing
            polarity[i] = ""                                     -- user must define both if switching back from a basket to user instruments
            param:setString("polarity" .. i, "")
        end
        --if polarity[i] == "" then                              -- delete instrument if polarity is missing
        --  instrument[i] = ""                                   -- user must define both if switching back from a basket to user instruments
        --  param:setString("instrument" .. i, "")               -- NOTE: this bit of code causes a crash and indicator is removed from chart
        --end                                                    -- to do with core.FLAG_INSTRUMENTS in prepare... I don't have a solution
        if polarity[i] == "Normal" or polarity[i] == "Inverted" then
            num_instruments = num_instruments + 1
        end
    end
    
    -- fabricate profile name
    local name
    local basket_name
    if param.basket == "Chart Pair" then
        basket_name = source:instrument()
    elseif param.basket == "Chart Pair Numerator" then
        basket_name = string.sub(source:instrument(), 1, 3)
    elseif param.basket == "Chart Pair Denominator" then
        basket_name = source:instrument():sub(5)
    else
        basket_name = param.basket
    end
    if param.shorten_name == true then--and param.basket ~= "User List" then
        name = basket_name
    elseif param.shorten_name == false then
        name = profile:id() .. "("
        name = name .. param.display_mode .. ", "
        name = name .. basket_name
        name = name .. " Basket, "
        name = name .. param.calculation_method .. "["
    end
    if param.shorten_name == false then --or param.basket == "User List" then
        local first_one = true
        for i = 1, MAX_INSTRUMENTS, 1 do
            if polarity[i] == "Normal" then
                if first_one ~= true then
                    name = name .. ", "
                else
                    first_one = false
                end
                name = name .. instrument[i]
            elseif polarity[i] == "Inverted" then
                if first_one ~= true then
                    name = name .. ", "
                else
                    first_one = false
                end
                if param.calculation_method == "Sum Pips" or param.calculation_method == "Sum P/L" then
                    name = name .. "-" .. instrument[i]
                else
                    name = name .. "1/" .. instrument[i]
                end
            end
        end
    end
    if param.shorten_name == false then 
        name = name .. "])"
    end
    if missing_subscriptions ~= "" then     -- the user need to add these instruments to their subscription list - no errors thrown for not doing so
        name = name .. " Missing Subcriptions for: " .. missing_subscriptions
    end
    instance:name(name) 

    if nameOnly then return end
    
    
    -- setup required managed streams, find max decimal places
    local tf = param.source_period
    local row
    if tf == "Chart" then tf = source:barSize() end
    local max_dps = 0
    for i = 1, MAX_INSTRUMENTS, 1 do
        if polarity[i] ~= "Disabled" and polarity[i] ~= "" and instrument[i] ~= "" then
            stream[i] = ManagedStream.new(instrument[i], i, tf, param.bid_ask_data == "Bid")
            row = core.host:findTable("Offers"):find("Instrument", instrument[i])
            point_size[i] = row.PointSize
            pip_cost[i] = row.PipCost
            if -math.log10(point_size[i]) > max_dps then max_dps = -math.log10(point_size[i]) + 1 end   -- the +1 sets precision to 0.1 pips rather than 1 pip without
        end
    end
    
    
    -- internal streams for calculation
    o = instance:addInternalStream(first, 0)        -- open
    h = instance:addInternalStream(first, 0)        -- high
    l = instance:addInternalStream(first, 0)        -- low
    c = instance:addInternalStream(first, 0)        -- close
    m = instance:addInternalStream(first, 0)        -- median
    t = instance:addInternalStream(first, 0)        -- typical
    w = instance:addInternalStream(first, 0)        -- weighted
    v = instance:addInternalStream(first, 0)        -- volume
    dir_v = instance:addInternalStream(first, 0)    -- directional volume
    
    instance:createCandleGroup("Synthetic", "Synthetic", o, h, l, c, v)
    if param.display_mode == "Volume" or param.display_mode == "Directional Volume" then
        signal = instance:addStream("signal", core.Bar, name, "Signal", param.synthetic_colour, first)
        signal:setPrecision(0)
    else
        signal = instance:addStream("signal", core.Line, name, "Signal", param.synthetic_colour, first)
        signal:setWidth(param.synthetic_width)
        signal:setStyle(param.synthetic_style)
        if param.calculation_method == "Sum P/L" then
            signal:setPrecision(2)                      -- nearest account currency 0.00
        elseif param.calculation_method == "Sum Pips" then
            signal:setPrecision(1)                      -- nearest 0.1 pips
        elseif param.display_mode == "Percentage Change" then
            signal:setPrecision(1)
            signal:addLevel(0)                          -- set 0, & +/- levels for percentage change option
            signal:addLevel(-param.levels)
            signal:addLevel(param.levels)
        else
            signal:setPrecision(max_dps)                -- the instrument with the most decimal points
        end
    end
    
    -- display candles or signal?
    if param.display_mode ~= "Candles" then
        o:setVisible(false)
        h:setVisible(false)
        l:setVisible(false)
        c:setVisible(false)
    else
        signal:setVisible(false)
    end
    
    if  param.overlay_source == true and                -- add overlay stream
        param.display_mode ~= "Volume" and
        param.display_mode ~= "Directional Volume" and
        param.display_mode ~= "Percentage Change"
    then
        overlay = instance:addStream("overlay", core.Line, name, "Overlay", param.overlay_colour, first)
        overlay:setWidth(param.overlay_width)
        overlay:setStyle(param.overlay_style)
        overlay:setPrecision(instance.source:getPrecision())
    end
    
    -- create required directional volume filter
    if param.dvol_filter_type == "MVA" then
        dvol_filter = core.indicators:create("MVA", dir_v, param.dvol_filter_N)
    elseif param.dvol_filter_type == "EMA" then
        dvol_filter = core.indicators:create("EMA", dir_v, param.dvol_filter_N)
    end
    if param.display_mode == "Directional Volume" then
        dvol_trace = instance:addStream("dvol_trace", core.Line, name, "DirVol", param.overlay_colour, first)
        dvol_trace:setWidth(param.overlay_width)
        dvol_trace:setStyle(param.overlay_style)
        dvol_trace:setPrecision(1)
    end
end

 
-- compute indicator
function Update(period, mode)
    local param = instance.parameters   -- abbreviation for parameters to make code more readable
    local i
    
    if loading == true then return end
    if period <= first then return end
    
    -- Calculate the 'from' and 'to' for the ManagedStream
    local from
    local to
        
    from = source:date(first)
    if source:isAlive() then
        -- Subscribe so we always get the latest data
        to = 0
    else
        -- Use the end of the source
        to = source:date(source:size() - 1)
    end
        
    -- Update the ManagedStream
    for i = 1, MAX_INSTRUMENTS, 1 do
        if polarity[i] ~= "Disabled" and polarity[i] ~= "" and instrument[i] ~= "" then
            if stream[i]:update(from, to) == true then return end
        end
    end
    
    -- convert source period into a date to allow lookup inside the different streams 
    local date_of_period = source:date(period)
    local date_of_prev_period = source:date(period - 1)


    -- number of bars to lookback for % change and overlay normalisation
    local offset = param.lookback
    if source:size() - offset < first then offset = source:size() - first end   -- assure within bounds

    if (param.display_mode == "Percentage Change" or
        param.calculation_method == "Sum Pips" or
        param.calculation_method == "Sum P/L")
    then
        if period < source:size() - offset then return end
    end
    
       
    ---------------------------------------------
    -- perform desired calculations
    ---------------------------------------------
    
    -- "Sum Pips" or "Sum P/L"
    if param.calculation_method == "Sum Pips" or param.calculation_method == "Sum P/L" then
        o[period] = 0
        h[period] = 0
        l[period] = 0  
        c[period] = 0
        m[period] = 0
        t[period] = 0
        w[period] = 0
        if num_instruments > 0 then
            local scale
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] ~= "Disabled" and polarity[i] ~= "" and instrument[i] ~= "" then
                    scale = 1 / point_size[i]
                    if param.calculation_method == "Sum P/L" then scale = scale * pip_cost[i] end
                    if polarity[i] == "Normal" then
                        o[period] = o[period] + stream[i]:getPrice(date_of_period, "Open") * scale
                        h[period] = h[period] + stream[i]:getPrice(date_of_period, "High") * scale
                        l[period] = l[period] + stream[i]:getPrice(date_of_period, "Low") * scale
                        c[period] = c[period] + stream[i]:getPrice(date_of_period, "Close") * scale
                        m[period] = m[period] + stream[i]:getPrice(date_of_period, "Median") * scale
                        t[period] = t[period] + stream[i]:getPrice(date_of_period, "Typical") * scale
                        w[period] = w[period] + stream[i]:getPrice(date_of_period, "Weighted") * scale
                    end
                    if polarity[i] == "Inverted" then
                        o[period] = o[period] - stream[i]:getPrice(date_of_period, "Open") * scale
                        h[period] = h[period] - stream[i]:getPrice(date_of_period, "Low") * scale
                        l[period] = l[period] - stream[i]:getPrice(date_of_period, "High") * scale
                        c[period] = c[period] - stream[i]:getPrice(date_of_period, "Close") * scale
                        m[period] = m[period] - stream[i]:getPrice(date_of_period, "Median") * scale
                        t[period] = t[period] - stream[i]:getPrice(date_of_period, "Typical") * scale
                        w[period] = w[period] - stream[i]:getPrice(date_of_period, "Weighted") * scale
                    end
                end
            end
            if period == source:size() - offset then ref_offset = c[period] end
            o[period] = o[period] - ref_offset
            h[period] = h[period] - ref_offset
            l[period] = l[period] - ref_offset
            c[period] = c[period] - ref_offset
            m[period] = m[period] - ref_offset
            t[period] = t[period] - ref_offset
            w[period] = w[period] - ref_offset
        end
    
    -- "Geometric Mean" or "Linear Product" calculation
    elseif param.calculation_method == "Geometric Mean" or param.calculation_method == "Linear Product" then
        o[period] = 1  -- start with value of '1' followed by multiplication in formula...
        h[period] = 1
        l[period] = 1  
        c[period] = 1
        m[period] = 1
        t[period] = 1
        w[period] = 1
        if num_instruments > 0 then
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] == "Normal" then
                    o[period] = o[period] * stream[i]:getPrice(date_of_period, "Open")
                    h[period] = h[period] * stream[i]:getPrice(date_of_period, "High")
                    l[period] = l[period] * stream[i]:getPrice(date_of_period, "Low")
                    c[period] = c[period] * stream[i]:getPrice(date_of_period, "Close")
                    m[period] = m[period] * stream[i]:getPrice(date_of_period, "Median")
                    t[period] = t[period] * stream[i]:getPrice(date_of_period, "Typical")
                    w[period] = w[period] * stream[i]:getPrice(date_of_period, "Weighted")
                end
                if polarity[i] == "Inverted" then
                    o[period] = o[period] / stream[i]:getPrice(date_of_period, "Open")
                    h[period] = h[period] / stream[i]:getPrice(date_of_period, "Low")
                    l[period] = l[period] / stream[i]:getPrice(date_of_period, "High")
                    c[period] = c[period] / stream[i]:getPrice(date_of_period, "Close")
                    m[period] = m[period] / stream[i]:getPrice(date_of_period, "Median")
                    t[period] = t[period] / stream[i]:getPrice(date_of_period, "Typical")
                    w[period] = w[period] / stream[i]:getPrice(date_of_period, "Weighted")
                end
            end
            if param.calculation_method == "Geometric Mean" then
                o[period] = math.pow(o[period], 1 / num_instruments)   -- geometric mean to linearise the multiplications above[for example trendlines will be more linear]
                h[period] = math.pow(h[period], 1 / num_instruments)   -- see https://en.wikipedia.org/wiki/Geometric_mean
                l[period] = math.pow(l[period], 1 / num_instruments)
                c[period] = math.pow(c[period], 1 / num_instruments)
                m[period] = math.pow(m[period], 1 / num_instruments)
                t[period] = math.pow(t[period], 1 / num_instruments)
                w[period] = math.pow(w[period], 1 / num_instruments)
            end
        end

    -- "Harmonic Mean" calculation: see https://en.wikipedia.org/wiki/Harmonic_mean
    elseif param.calculation_method == "Harmonic Mean" then
        o[period] = 0
        h[period] = 0
        l[period] = 0  
        c[period] = 0
        m[period] = 0
        t[period] = 0
        w[period] = 0
        if num_instruments > 0 then
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] == "Normal" then
                    o[period] = o[period] + 1 / stream[i]:getPrice(date_of_period, "Open")
                    h[period] = h[period] + 1 / stream[i]:getPrice(date_of_period, "Low")
                    l[period] = l[period] + 1 / stream[i]:getPrice(date_of_period, "High")
                    c[period] = c[period] + 1 / stream[i]:getPrice(date_of_period, "Close")
                    m[period] = m[period] + 1 / stream[i]:getPrice(date_of_period, "Median")
                    t[period] = t[period] + 1 / stream[i]:getPrice(date_of_period, "Typical")
                    w[period] = w[period] + 1 / stream[i]:getPrice(date_of_period, "Weighted")
                end
                if polarity[i] == "Inverted" then
                    o[period] = o[period] + stream[i]:getPrice(date_of_period, "Open")
                    h[period] = h[period] + stream[i]:getPrice(date_of_period, "High")
                    l[period] = l[period] + stream[i]:getPrice(date_of_period, "Low")
                    c[period] = c[period] + stream[i]:getPrice(date_of_period, "Close")
                    m[period] = m[period] + stream[i]:getPrice(date_of_period, "Median")
                    t[period] = t[period] + stream[i]:getPrice(date_of_period, "Typical")
                    w[period] = w[period] + stream[i]:getPrice(date_of_period, "Weighted")
                end
            end
            o[period] = num_instruments / o[period]
            h[period] = num_instruments / h[period]
            l[period] = num_instruments / l[period]    
            c[period] = num_instruments / c[period]
            m[period] = num_instruments / m[period]
            t[period] = num_instruments / t[period]
            w[period] = num_instruments / w[period]        
        end
    
    -- "RMS" calculation
    elseif param.calculation_method == "RMS" then
        o[period] = 0
        h[period] = 0
        l[period] = 0  
        c[period] = 0
        m[period] = 0
        t[period] = 0
        w[period] = 0
        if num_instruments > 0 then
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] == "Normal" then
                    o[period] = o[period] + math.pow(stream[i]:getPrice(date_of_period, "Open"), 2)
                    h[period] = h[period] + math.pow(stream[i]:getPrice(date_of_period, "Low"), 2)
                    l[period] = l[period] + math.pow(stream[i]:getPrice(date_of_period, "High"), 2)
                    c[period] = c[period] + math.pow(stream[i]:getPrice(date_of_period, "Close"), 2)
                    m[period] = m[period] + math.pow(stream[i]:getPrice(date_of_period, "Median"), 2)
                    t[period] = t[period] + math.pow(stream[i]:getPrice(date_of_period, "Typical"), 2)
                    w[period] = w[period] + math.pow(stream[i]:getPrice(date_of_period, "Weighted"), 2)
                end
                if polarity[i] == "Inverted" then
                    o[period] = o[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Open"), 2)
                    h[period] = h[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "High"), 2)
                    l[period] = l[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Low"), 2)
                    c[period] = c[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Close"), 2)
                    m[period] = m[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Median"), 2)
                    t[period] = t[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Typical"), 2)
                    w[period] = w[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Weighted"), 2)
                end
            end
            o[period] = math.sqrt(o[period] / num_instruments)
            h[period] = math.sqrt(h[period] / num_instruments)
            l[period] = math.sqrt(l[period] / num_instruments)
            c[period] = math.sqrt(c[period] / num_instruments)
            m[period] = math.sqrt(m[period] / num_instruments)
            t[period] = math.sqrt(t[period] / num_instruments)
            w[period] = math.sqrt(w[period] / num_instruments)
        end
    
    -- "Cubic Mean" calculation
    elseif param.calculation_method == "Cubic Mean" then
        o[period] = 0
        h[period] = 0
        l[period] = 0  
        c[period] = 0
        m[period] = 0
        t[period] = 0
        w[period] = 0
        if num_instruments > 0 then
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] == "Normal" then
                    o[period] = o[period] + math.pow(stream[i]:getPrice(date_of_period, "Open"), 3)
                    h[period] = h[period] + math.pow(stream[i]:getPrice(date_of_period, "Low"), 3)
                    l[period] = l[period] + math.pow(stream[i]:getPrice(date_of_period, "High"), 3)
                    c[period] = c[period] + math.pow(stream[i]:getPrice(date_of_period, "Close"), 3)
                    m[period] = m[period] + math.pow(stream[i]:getPrice(date_of_period, "Median"), 3)
                    t[period] = t[period] + math.pow(stream[i]:getPrice(date_of_period, "Typical"), 3)
                    w[period] = w[period] + math.pow(stream[i]:getPrice(date_of_period, "Weighted"), 3)
                end
                if polarity[i] == "Inverted" then
                    o[period] = o[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Open"), 3)
                    h[period] = h[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "High"), 3)
                    l[period] = l[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Low"), 3)
                    c[period] = c[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Close"), 3)
                    m[period] = m[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Median"), 3)
                    t[period] = t[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Typical"), 3)
                    w[period] = w[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Weighted"), 3)
                end
            end
            o[period] = math.pow(o[period] / num_instruments, 1 / 3)
            h[period] = math.pow(h[period] / num_instruments, 1 / 3)
            l[period] = math.pow(l[period] / num_instruments, 1 / 3)
            c[period] = math.pow(c[period] / num_instruments, 1 / 3)
            m[period] = math.pow(m[period] / num_instruments, 1 / 3)
            t[period] = math.pow(t[period] / num_instruments, 1 / 3)
            w[period] = math.pow(w[period] / num_instruments, 1 / 3)
        end
    
    -- "Heronian Mean" calculation
    elseif param.calculation_method == "Heronian Mean" then   -- no idea if this might be useful, but it is coded in
        if num_instruments == 2 and polarity[1] ~= "Disabled" and polarity[2] ~= "Disabled" then    -- special case, only applies to first 2 instruments
            o[period] = Heronian(date_of_period, "Open")
            h[period] = Heronian(date_of_period, "High")
            l[period] = Heronian(date_of_period, "Low")
            c[period] = Heronian(date_of_period, "Close")
            m[period] = Heronian(date_of_period, "Median")
            t[period] = Heronian(date_of_period, "Typical")
            w[period] = Heronian(date_of_period, "Weighted")
        end
    end
    
    -- volume calculation, sum and estimated directional methods
    -- the directional volume is calculated by weighted sum of individual instruments: SUM[delta price /(H-L) x Instrument Volume x Instrument Polarity]
    -- so to get directional volume for GBPUSD: GBP numerator pairs / USD denominator pairs
    -- GBPUSD, 1/EURGBP, GBPCHF, GBPJPY, GBPCAD, GBPAUD, GBPNZD, EURUSD, 1/USDCHF, 1/USDJPY, 1/USDCAD, AUDUSD, NZDUSD
    v[period] = 0
    dir_v[period] = 0
    if num_instruments > 0 then
        for i = 1, MAX_INSTRUMENTS, 1 do
            if polarity[i] == "Normal" or polarity[i] == "Inverted" then
                v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume")                                     -- simple volume sum
                local pol;
                if polarity[i] == "Normal" then pol = 1 else pol = -1 end                                                -- volume is in direction of instrument
                local delta_price = stream[i]:getPrice(date_of_period, param.dvol_price_type)
                delta_price = delta_price - stream[i]:getPrice(date_of_prev_period, param.dvol_price_type)               -- volume in direction of delta price
                if param.dvol_scale_hl == true then
                    local delta_hl = stream[i]:getPrice(date_of_period, "High") - stream[i]:getPrice(date_of_period, "Low")
                    if delta_hl == nil or delta_hl == 0 then delta_hl = 1 end                                            -- catch errors (1/NaN or 1/0) as they mess up the filter
                    delta_price = delta_price / delta_hl                                                                 -- delta price as a fraction of HL
                end
                dir_v[period] = dir_v[period] + (stream[i]:getPrice(date_of_period, "Volume") * pol * delta_price)       -- add weighted volume into the sum
            end
        end
    end
    dvol_filter:update(mode)        -- update directional volume filter now that its source data has been calculated
        
    
    -- transfer desired value to signal stream
    if param.display_mode == "Open" then signal[period] = o[period]
        elseif param.display_mode == "High" then signal[period] = h[period]
        elseif param.display_mode == "Low" then signal[period] = l[period]
        elseif param.display_mode == "Close" then signal[period] = c[period]
        elseif param.display_mode == "Median" then signal[period] = m[period]
        elseif param.display_mode == "Typical" then signal[period] = t[period]
        elseif param.display_mode == "Weighted" then signal[period] = w[period]
        elseif param.display_mode == "Volume" then signal[period] = v[period]
        elseif param.display_mode == "Directional Volume" then
            signal[period] = dir_v[period]
            dvol_trace[period] = dvol_filter.DATA[period]
        elseif param.display_mode == "Percentage Change" then
            if param.calculation_method ~= "Sump Pips" and param.calculation_method ~= "Sum P/L" then   -- not possible.... for these methods
                signal[period] = c[period] / c[source:size() - offset] * 100 - 100                      -- divide zero error
            end
    end
    
    -- overlay method - could be improved...
    if  param.overlay_source == true and
        period == source:size() - 1 and
        param.display_mode ~= "Volume" and
        param.display_mode ~= "Directional Volume" and
        param.display_mode ~= "Percentage Change"
    then
        local i
        local min1, max1
        local min2, max2
        min1, max1 = mathex.minmax(c, c:size() - offset, c:size() - 1)                         -- simplistic overlay method normalising min/max over the period
        min2, max2 = mathex.minmax(source.close, source:size() - offset, source:size() - 1)    -- a better method would be via a cost function with search
        if param.overlay_invert == true then
            for i = 0, source:size() - 1, 1 do
                overlay[period - i] = ((-source.close[period - i] + max2) / (max2 - min2)) * (max1 - min1) + (min1 + max1) / 2 - (max1 - min1) / 2
            end
        else
            for i = 0, source:size() - 1, 1 do
                overlay[period - i] = ((source.close[period - i] - min2) / (max2 - min2)) * (max1 - min1) + (min1 + max1) / 2 - (max1 - min1) / 2
            end
        end
    end
        
    -- colour chart with volume direction or candle price direction
    if param.dvol_colour == true then
        if param.display_mode == "Candles" then
            if dvol_filter.DATA[period] < 0 then
                o:setColor(period, param.down_colour)
                h:setColor(period, param.down_colour)
                l:setColor(period, param.down_colour)
                c:setColor(period, param.down_colour)
            end
            if dvol_filter.DATA[period] > 0 then
                o:setColor(period, param.up_colour)
                h:setColor(period, param.up_colour)
                l:setColor(period, param.up_colour)
                c:setColor(period, param.up_colour)
            end
        else
            if dvol_filter.DATA[period] < 0 then
                if param.display_mode ~= "Directional Volume" then
                    signal:setColor(period, param.down_colour)--core.rgb(255, 0, 0))
                else
                    dvol_trace:setColor(period, param.down_colour)--core.rgb(255, 0, 0))
                end
            end
            if dvol_filter.DATA[period] > 0 then
                if param.display_mode ~= "Directional Volume" then
                    signal:setColor(period, param.up_colour)--core.rgb(0, 255, 0))
                else
                    dvol_trace:setColor(period, param.up_colour)--core.rgb(0, 255, 0))
                end
            end
        end
    elseif param.display_mode == "Candles" then
        if c[period] > o[period] then
            o:setColor(period, param.up_colour)
            h:setColor(period, param.up_colour)
            l:setColor(period, param.up_colour)
            c:setColor(period, param.up_colour)
        else
            o:setColor(period, param.down_colour)
            h:setColor(period, param.down_colour)
            l:setColor(period, param.down_colour)
            c:setColor(period, param.down_colour)
        end
    end
end                 
 
 
-- utility function to calculate Heronian mean - hard coded to first two instruments
function Heronian(date, price_type)
    local a = stream[1]:getPrice(date, price_type)
    local b = stream[2]:getPrice(date, price_type)
    if polarity[1] == "Inverted" then a = 1 / a end
    if polarity[2] == "Inverted" then b = 1 / b end
    return (a + math.sqrt(a * b) + b) / 3
end


-- handle asynchronous events
function AsyncOperationFinished(cookie, success, message)
    local i
    
    if stream[cookie]:async(cookie, success) == true then
        loading = true                     -- something is still loading...
        return 0
    end 
    loading = false                        -- everything must have been loaded at this point
    
    instance:updateFrom(first)             -- update the chart
    return core.ASYNC_REDRAW
end


-- configure the inbuilt basket selection - update user instruments so they reflect the selection as if this was done manually
-- returns string with list of unsubscribed instruments and disables those streams to prevent an error
function Configure_inbuilt()
    local param = instance.parameters       -- abbreviation for parameters to make code more readable
    local basket_list = nil
    local missing = ""
    
    -- reset parameters for user instruments to default
    local i
    for i = 1, MAX_INSTRUMENTS, 1 do
        param:setString("instrument" .. i, source:instrument())
        param:setString("polarity" .. i, "")
    end
    param:setString("polarity" .. 1, "Normal")
    
    -- Note: the configured "calculation_method" is left unchanged
    -- ie. since user may wish to alter it and custom defining here would reset the value each time it is changed
    -- For instance, normally currency strengths are defined as a "Geometric Mean" but "Harmonic Mean", or "Sum Pips", etc..., could be desired
    
    -- create list of instruments for desired selection - use preceeding "-" to denote inverted
    if param.basket == "Chart Pair Numerator" or param.basket == "Chart Pair Denominator" or param.basket == "Chart Pair" then 
        basket_list = Populate_chart_instrument(param.basket)       -- split this out into a function below that takes chart instrument eg. EUR/USD,
                                                                    -- where EUR, USD or EUR/USD are the 3 numerator, denominator or pair options,
                                                                    -- via the returned basket list
        if table.getn(basket_list) == 0 then
            table.insert(basket_list, source:instrument())          -- set to source instrument as we don't know what to do
            missing = "Chart Instrument " .. source:instrument() .. " is Not Supported"
        end
    elseif param.basket == "USD" then                               -- USD strength
        basket_list = {"-AUD/USD", "USD/CAD", "USD/CHF", "-EUR/USD", "USD/JPY", "-GBP/USD", "-NZD/USD"}
    elseif param.basket == "EUR" then                               -- EUR strength
        basket_list = {"EUR/AUD", "EUR/CAD", "EUR/CHF", "EUR/USD", "EUR/JPY", "EUR/GBP", "EUR/NZD"}
    elseif param.basket == "GBP" then                               -- GBP strength
        basket_list = {"GBP/AUD", "GBP/CAD", "GBP/CHF", "GBP/USD", "GBP/JPY", "-EUR/GBP", "GBP/NZD"}
    elseif param.basket == "CAD" then                               -- CAD strength
        basket_list = {"-AUD/CAD", "-USD/CAD", "CAD/CHF", "-EUR/CAD", "CAD/JPY", "-GBP/CAD", "-NZD/CAD"}
    elseif param.basket == "AUD" then                               -- AUD strength
        basket_list = {"AUD/USD", "AUD/CAD", "AUD/CHF", "-EUR/AUD", "AUD/JPY", "-GBP/AUD", "AUD/NZD"}
    elseif param.basket == "NZD" then                               -- NZD strength
        basket_list = {"NZD/USD", "NZD/CAD", "NZD/CHF", "-EUR/NZD", "NZD/JPY", "-GBP/NZD", "-AUD/NZD"}
    elseif param.basket == "JPY" then                               -- JPY strength
        basket_list = {"-USD/JPY", "-AUD/JPY", "-CHF/JPY", "-EUR/JPY", "-CAD/JPY", "-GBP/JPY", "-NZD/JPY"}
    elseif param.basket == "CHF" then                               -- CHF strength
        basket_list = {"-USD/CHF", "-AUD/CHF", "CHF/JPY", "-EUR/CHF", "-CAD/CHF", "-GBP/CHF", "-NZD/CHF"}
    elseif param.basket == "NOK" then                               -- NOK strength
        basket_list = {"-USD/NOK", "-EUR/NOK"}
    elseif param.basket == "SEK" then                               -- SEK strength
        basket_list = {"-USD/SEK", "-EUR/SEK"}
    elseif param.basket == "ZAR" then                               -- ZAR strength
        basket_list = {"-USD/ZAR", "ZAR/JPY"}
    elseif param.basket == "HUF" then                               -- HUF strength
        basket_list = {"-USD/HUF", "-EUR/HUF"}
    elseif param.basket == "TRY" then                               -- TRY strength
        basket_list = {"-USD/TRY", "-EUR/TRY"}
    elseif param.basket == "USD Extended" then                      -- USD strength, extended instruments
        basket_list = {"-AUD/USD", "USD/CAD", "USD/CHF", "-EUR/USD", "USD/JPY", "-GBP/USD", "-NZD/USD", "USD/HKD", "USD/HUF", "USD/MXN", "USD/NOK", "USD/SEK", "USD/TRY", "USD/ZAR"}
    elseif param.basket == "EUR Extended" then                      -- EUR strength, extended instruments
        basket_list = {"EUR/AUD", "EUR/CAD", "EUR/CHF", "EUR/USD", "EUR/JPY", "EUR/GBP", "EUR/NZD", "EUR/HUF", "EUR/NOK", "EUR/SEK", "EUR/TRY"}
    elseif param.basket == "US Stock Indices" then                  -- US stocks strength
        basket_list = {"NAS100", "US30", "SPX500", "US2000"}
    elseif param.basket == "European Stock Indices" then            -- EU stocks strength
        basket_list = {"GER30", "FRA40", "UK100", "ESP35", "EUSTX50"}
    elseif param.basket == "Asia Stock Indices" then                -- Asia stocks strength
        basket_list = {"AUS200", "HKG33", "JPN225"}
    elseif param.basket == "Risk-On" then                           -- Risk-On strength
        basket_list = {"USEquities", "EMBasket", "-USDOLLAR", "-JPYBasket", "-VOLX"}
    elseif param.basket == "Safe Haven" then                        -- Safe Havens USD, JPY & CHF strength
        basket_list = {"-AUD/USD", "USD/CAD", "-EUR/USD", "-GBP/USD", "-NZD/USD",
                       "-AUD/JPY", "-EUR/JPY", "-CAD/JPY", "-GBP/JPY", "-NZD/JPY",
                       "-AUD/CHF", "-EUR/CHF", "-CAD/CHF", "-GBP/CHF", "-NZD/CHF"}
    elseif param.basket == "North America" then                     -- USD+CAD strength
        basket_list = {"-AUD/USD", "USD/CHF", "-EUR/USD", "USD/JPY", "-GBP/USD", "-NZD/USD",
                       "-AUD/CAD", "CAD/CHF", "-EUR/CAD", "CAD/JPY", "-GBP/CAD", "-NZD/CAD"}
    elseif param.basket == "Europe" then                            -- EUR+GBP+CHF+HUF+NOK+SEK+TRY strength
        basket_list = {"EUR/AUD", "EUR/CAD", "EUR/USD", "EUR/JPY", "EUR/NZD",
                       "GBP/AUD", "GBP/CAD", "GBP/USD", "GBP/JPY", "GBP/NZD",
                       "-USD/CHF", "-USD/HUF", "-USD/NOK", "-USD/SEK", "-USD/TRY"}
    elseif param.basket == "Australasia" then                       -- AUD+NZD strength
        basket_list = {"AUD/USD", "AUD/CAD", "AUD/CHF", "-EUR/AUD", "AUD/JPY", "-GBP/AUD", "NZD/USD", "NZD/CAD", "NZD/CHF", "-EUR/NZD", "NZD/JPY", "-GBP/NZD"}
    elseif param.basket == "Asia" then                              -- JPY+HKD+KRW+TWD+INR strength
        basket_list = {"-USD/JPY", "-AUD/JPY", "-CHF/JPY", "-EUR/JPY", "-CAD/JPY", "-GBP/JPY", "-NZD/JPY", "-USD/HKD", "-USD/KRW", "-USD/TWD", "-USD/INR"}
    elseif param.basket == "Latin America" then                     -- MXN+CLP+COP
        basket_list = {"-USD/MXN", "-USD/CLP", "-USD/COP"}
    elseif param.basket == "Scandinavia" then                       -- Scandinavia strength
        basket_list = {"-USD/NOK", "-EUR/NOK", "-USD/SEK", "-EUR/SEK"}
    elseif param.basket == "Commodity Currencies USD" then          -- Commodity currency strength versus USD
        basket_list = {"-USD/CAD", "AUD/USD", "NZD/USD"}
    elseif param.basket == "Commodity Currencies USD & EUR" then    -- Commodity currency strength versus USD & EUR
        basket_list = {"-USD/CAD", "AUD/USD", "NZD/USD", "-EUR/CAD", "-EUR/AUD", "-EUR/NZD"}
    elseif param.basket == "Oil" then                               -- Oil strength
        basket_list = {"USOil", "UKOil", "USOilSpot", "UKOilSpot"}
    elseif param.basket == "Oil not in USD" then                    -- Oil strength divided by USD
        basket_list = {"USOil", "UKOil", "USOilSpot", "UKOilSpot", "AUD/USD", "-USD/CAD", "-USD/CHF", "EUR/USD", "-USD/JPY", "GBP/USD", "NZD/USD"}
    elseif param.basket == "Energy Complex" then                    -- Energy complex
        basket_list = {"USOil", "UKOil", "NGAS", "GasolineF", "HeatingOilF"}
    elseif param.basket == "Monetary Metals" then                   -- Copper, Silver & Gold strength
        basket_list = {"XAU/USD", "XAG/USD", "Copper"}
    elseif param.basket == "Gold not in USD" then                   -- Gold not in USD
        basket_list = {"XAU/USD", "AUD/USD", "-USD/CAD", "-USD/CHF", "EUR/USD", "-USD/JPY", "GBP/USD", "NZD/USD"}
    elseif param.basket == "Silver not in USD" then                 -- Silver not in USD
        basket_list = {"XAG/USD", "AUD/USD", "-USD/CAD", "-USD/CHF", "EUR/USD", "-USD/JPY", "GBP/USD", "NZD/USD"}
    elseif param.basket == "Copper not in USD" then                 -- Copper not in USD
        basket_list = {"Copper", "AUD/USD", "-USD/CAD", "-USD/CHF", "EUR/USD", "-USD/JPY", "GBP/USD", "NZD/USD"}
    elseif param.basket == "Gold Majors" then                       -- Gold strength averaged across majors ie XAUUSD, XAUGBP, XAUEUR... etc...
        basket_list = {"XAU/USD", "XAU/USD", "-EUR/USD",            -- XAUUSD, XAUEUR
                       "XAU/USD", "-GBP/USD", "XAU/USD", "USD/CAD", -- XAUGBP, XAUCAD
                       "XAU/USD", "-AUD/USD", "XAU/USD", "-NZD/USD",-- XAUAUD, XAUNZD
                       "XAU/USD", "USD/JPY", "XAU/USD", "USD/CHF"}  -- XAUJPY, XAUCHF
    elseif param.basket == "Silver Majors" then                     -- Silver strength averaged across majors ie XAGUSD, XAGGBP, XAGEUR... etc...
        basket_list = {"XAG/USD", "XAG/USD", "-EUR/USD",            -- XAGUSD, XAGEUR
                       "XAG/USD", "-GBP/USD", "XAG/USD", "USD/CAD", -- XAGGBP, XAGCAD
                       "XAG/USD", "-AUD/USD", "XAG/USD", "-NZD/USD",-- XAGAUD, XAGNZD
                       "XAG/USD", "USD/JPY", "XAG/USD", "USD/CHF"}  -- XAGJPY, XAGCHF
    elseif param.basket == "Gold/Silver" then                       -- Gold/Silver
        basket_list = {"XAU/USD", "-XAG/USD"}
    elseif param.basket == "Gold/SPX500" then                       -- Gold/SPX500
        basket_list = {"XAU/USD", "-SPX500"}
    elseif param.basket == "Dow/Gold" then                          -- Dow/Gold
        basket_list = {"US30", "-XAU/USD"}      
    elseif param.basket == "Metals Complex" then                    -- Metals Complex excluding Gold + Silver
        basket_list = {"AlumSpot", "LeadSpot", "NickelSpot", "ZincSpot", "Copper"}
    elseif param.basket == "Softs" then    -- Softs
        basket_list = {"WHEATF", "CORNF", "CoffeeNYF", "SugarNYF"}
    else
        return "Basket not defined"                                 -- catch coding errors
    end
    
    -- set parameters for list of provided instruments, also check subscriptions
    -- "-" value at start of each string denotes inverted polarity
    for i = 1, table.getn(basket_list), 1 do
        local polarity
        local instrument
        if string.sub(basket_list[i], 1, 1) == "-" then -- check first character
            polarity = "Inverted"
            instrument = basket_list[i]:sub(2)          -- remove "-"
        else
            polarity = "Normal"
            instrument = basket_list[i]
        end
        if core.host:findTable("Offers"):find("Instrument", instrument) == nil then
            missing = missing .. " " .. instrument
            polarity = "Disabled"
            instrument = "EUR/USD"  -- set instrument to default instrument to prevent crash with undefined instrument via core.FLAG_INSTRUMENTS in parameters section
        end
        instance.parameters:setString("instrument" .. i, instrument)
        instance.parameters:setString("polarity" .. i, polarity)
    end
 
    return missing
end


-- utility function to populate basket_list with required instruments+polarity to reflect the chart instrument (only for currency pairs)
-- options are: 1) pair, 2) numerator of pair, or 3) denominator of pair
local PAIRS = { "EUR/USD", "GBP/USD", "USD/CAD", "AUD/USD", "NZD/USD", "USD/JPY", "USD/CHF",  -- majors & crosses list first
                "EUR/GBP", "EUR/CAD", "EUR/AUD", "EUR/NZD", "EUR/JPY", "EUR/CHF",
                "GBP/CAD", "GBP/AUD", "GBP/NZD", "GBP/JPY", "GBP/CHF",
                "AUD/CAD", "NZD/CAD", "CAD/JPY", "CAD/CHF",
                "AUD/NZD", "AUD/JPY", "AUD/CHF",
                "NZD/JPY", "NZD/CHF",
                "CHF/JPY",
                ------------------------------- everything else below here
                "USD/NOK", "EUR/NOK",
                "USD/SEK", "EUR/SEK",
                "USD/ZAR", "ZAR/JPY",
                "USD/HUF", "EUR/HUF",
                "USD/TRY", "EUR/TRY",
                "USD/MXN", "USD/CLP", "USD/COP", "USD/HKD", "USD/INR", "USD/KRW", "USD/TWD"}
function Populate_chart_instrument(option)
    local source_instrument = source:instrument()
    local list = {}
    local i
    local found = false;
    for i = 1, table.getn(PAIRS), 1 do
        if PAIRS[i] == source_instrument then found = true end
    end
    if found == false then return list end                              -- instrument not supported... return empty list
    
    local numerator_currency = string.sub(source_instrument, 1, 3)
    local denominator_currency = source_instrument:sub(5)
    local numer_cnt = 0
    local denom_cnt = 0
    for i = 1, table.getn(PAIRS), 1 do
        if PAIRS[i] ~= source_instrument then
            local numer = string.sub(PAIRS[i], 1, 3)
            local denom = PAIRS[i]:sub(5)
            if option == "Chart Pair Numerator" and numer_cnt < 7 then  -- limit to 7 majors or crosses (else we get all the exotics added in)
                if numer == numerator_currency then
                    numer_cnt = numer_cnt + 1
                    table.insert(list, PAIRS[i])
                end
                if denom == numerator_currency then
                    numer_cnt = numer_cnt + 1
                    table.insert(list, "-" .. PAIRS[i])
                end
            elseif option == "Chart Pair Denominator" and denom_cnt < 7 then
                if numer == denominator_currency then
                    denom_cnt = denom_cnt + 1
                    table.insert(list, PAIRS[i])
                end
                if denom == denominator_currency then
                    denom_cnt = denom_cnt + 1
                    table.insert(list, "-" .. PAIRS[i])
                end                     
            elseif option == "Chart Pair" then
                if numer_cnt < 7 then
                    if numer == numerator_currency then
                        numer_cnt = numer_cnt + 1
                        table.insert(list, PAIRS[i])
                    end
                    if denom == numerator_currency then
                        numer_cnt = numer_cnt + 1
                        table.insert(list, "-" .. PAIRS[i])
                    end
                end
                if denom_cnt < 7 then
                    if numer == denominator_currency then
                        denom_cnt = denom_cnt + 1
                        table.insert(list, "-" .. PAIRS[i])
                    end
                    if denom == denominator_currency then
                        denom_cnt = denom_cnt + 1
                        table.insert(list, PAIRS[i])
                    end
                end
            end
        else
            if option == "Chart Pair Numerator" and numer_cnt < 7 then
                numer_cnt = numer_cnt + 1
                table.insert(list, source:instrument())
            elseif option == "Chart Pair Denominator" and denom_cnt < 7 then
                denom_cnt = denom_cnt + 1
                table.insert(list, "-" .. source:instrument())
            elseif option == "Chart Pair" then
                numer_cnt = numer_cnt + 1
                denom_cnt = denom_cnt + 1
                table.insert(list, source:instrument())
            end
        end
    end 
    return list
end


--
-- Code uses a modified version of Managed streams Class from here: https://fxcodebase.com/code/viewtopic.php?f=17&t=4037&p=124465&hilit=better_volume.lua#p124465
-- Better Volume Indicator (modified to reconstruct the volume from lower time-frame bars)
-- Copyright (c) 2012 Steven Dickinson
-- http://robocod.blogspot.co.uk/
--
--#############################################################################
-- ManagedStream class
--#############################################################################
ManagedStream = {}

-- Factory method to create a new ManagedStream object
function ManagedStream.new(instrument, cookie, barSize, bidOrAsk, extend)
    -- Create the data object
    local data = {}

    -- Add the __index metamethod to the table, setting it to ManagedStream
    -- this causes all objects constructed by 'new' to inherit the methods
    setmetatable(data, {__index = ManagedStream})

    data.instrument = instrument
    data.cookie = cookie
    data.barSize = barSize
    data.bidOrAsk = bidOrAsk
    data.loading = false
    data.stream = nil
    data.requestedFrom = 0
    data.requestedTo = 0
    data.extend = extend

    return data
end

-- Use 'update' method to update the ManagedStream object from Update()
function ManagedStream:update(from, to)
    if not self.loading then
        if self.stream == nil then
            -- No data yet, so we load the history
            self.loading = true
            self.requestedFrom = from
            self.requestedTo = to
            if self.extend then
                -- Only load the default duration, it will get extended later
                self.stream = core.host:execute("getHistory", self.cookie, self.instrument, self.barSize, 0, to, self.bidOrAsk)
            else
                -- Attempt to load the whole date range
                self.stream = core.host:execute("getHistory", self.cookie, self.instrument, self.barSize, from, to, self.bidOrAsk)
            end
        else
            if from < self.requestedFrom then
                -- Required 'from' is earlier start date/time, so extend to the left
                self.loading = true
                self.requestedFrom = from
                core.host:execute("extendHistory", self.cookie, self.stream, from, self.stream:date(self.stream:first()));
            elseif to ~= 0 and to > self.requestedTo then
                -- Required 'to' is later start date/time, so extend to the right
                self.loading = true
                self.requestedTo = to
                core.host:execute("extendHistory", self.cookie, self.stream, self.stream:date(self.stream:size() - 1), to);
            elseif self.extend and self.stream:size() > 0 and from < self.stream:date(self.stream:first()) then
                -- Didn't load all history last time, so extend now
                self.loading = true
                self.requestedFrom = from
                self.extend = false
                core.host:execute("extendHistory", self.cookie, self.stream, from, self.stream:date(self.stream:first()))
            end
        end
    end

    return self.loading
end

-- Use 'async' method to update the ManagedStream object from AsyncOperationFinished()
function ManagedStream:async(cookie, success)
    if cookie == self.cookie and success then
        self.loading = false
    end

    return self.loading
end

-- Index the ManagedStream by date and return the period
function ManagedStream:getPeriod(date)
    -- TODO: this is O(log2(N)) search. Maybe possible to optimize it since we
    -- usually don't do random access of the stream, but use it in a linear fashion
    -- i.e. the requested date is usually very close to the last requested date.
    return core.findDate(self.stream, date, false)
end

-- Index the ManagedStream by date and return the close price (or -1 if not available)
-- NOTE: This can be used with bar_stream and tick_stream
-- modifications by SM Webb for Volume and Weighted
function ManagedStream:getPrice(date, type)
    local period = self:getPeriod(date)

    if period >= 0 then
        if self.stream:isBar() then
            if not type or type == "Close" then
                return self.stream.close[period]
            elseif type == "Open" then
                return self.stream.open[period]
            elseif type == "High" then
                return self.stream.high[period]
            elseif type == "Low" then
                return self.stream.low[period]
            elseif type == "Median" then
                return (self.stream.high[period] + self.stream.low[period]) / 2
            elseif type == "Typical" then
                return (self.stream.high[period] + self.stream.low[period] + self.stream.close[period]) / 3
            elseif type == "Weighted" then
                return (self.stream.high[period] + self.stream.low[period] + 2 * self.stream.close[period]) / 4
            elseif type == "Volume" then
                local vol = self.stream.volume[period]
                if vol == nil then vol = 0 end          -- capture nil volume at start of new bar
                return (vol)
            else
                return self.stream.close[period]
            end
        else
            return self.stream[period]
        end
    else
        return -1
    end
end

-- Index the ManagedStream by date and return the open, high, low and close (or -1 if not available)
-- NOTE: This can only be used with bar_stream
function ManagedStream:getCandle(date)
    local period = self:getPeriod(date)

    if period >= 0 then
        return self.stream.open[period], self.stream.high[period], self.stream.low[period], self.stream.close[period]
    else
        return -1, -1, -1, -1
    end
end
