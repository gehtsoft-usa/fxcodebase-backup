--
-- Synthetic instrument indicator
-- "synthetic.lua"
--
-- for further details see here: https://fxcodebase.com/code/viewtopic.php?f=17&t=75486
--
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
-- The calculation also includes summed volume data for the selected instruments
--
-- Pre-configured instrument basket options are provided - these are down to personal preference and may be adapted by editing code



---------------------------------
-- see section near end of file:
-- Code uses a modified version of Managed streams Class from here: https://fxcodebase.com/code/viewtopic.php?f=17&t=4037&p=124465&hilit=better_volume.lua#p124465
-- Better Volume Indicator (modified to reconstruct the volume from lower time-frame bars)
-- Copyright (c) 2012 Steven Dickinson
-- http://robocod.blogspot.co.uk/
---------------------------------


-- History
-- Version 1.0 SM Webb 1/1/2025:    First release - mostly debugged
-- Version 2.0 SM Webb 24/1/2025:   " added: Sum Pips, Sum P/L, Harmonic Mean, Overlay, % Change, Basket Options, Code Tidy";
-- Version 2.1 SM Webb 25/1/2025:   " improved stability, bug fixes, added: RMS, Heronian, energy complex";



-- code version, revision, author and version details
local VERSION = 2;
local REVISION = 1;
local REV_AUTHOR = "Steve_W";
local VERSION_TXT = "v" .. VERSION .. "." .. REVISION .. " improved stability, bug fixes, added: RMS, Heronian, energy complex";


-- global constants
local MAX_INSTRUMENTS = 15;         -- maximum number of instruments that may be used by indicator - edit value to needs...
                                    -- currency strengths for majors require ~7, but this could be extended for EUR or USD to include exotics or lesser currencies eg. USDNOK, USDSEK
local TF = {"Chart", "m1", "m5", "m15", "m30", "H1", "H2", "H4", "H6", "H8", "D1", "W1", "M1"};
local SELECTION = { "User List",                                                                        -- user defines the basket
                    "USD", "EUR", "GBP", "CAD", "AUD", "NZD", "JPY", "CHF",                             -- majors
                    "NOK", "SEK", "ZAR", "HUF", "TRY",                                                  -- exotics
                    "USD Extended", "EUR Extended",
                    "US Stock Indices", "European Stock Indices", "Asia Stock Indices",                 -- stock indices by region
                    "Risk-On", "Safe Haven",                                                            -- risk on/off feeling
                    "North America", "Europe", "Australasia", "Asia", "Latin America", "Scandinavia",   -- currency baskets by region
                    "Commodity Currencies USD", "Commodity Currencies USD & EUR",                       -- specialty currency baskets
                    "Oil", "Energy Complex",                                                            -- energy
                    "Monetary Metals", "Gold Majors", "Silver Majors",                                  -- money
                    "Metals Complex",                                                                   -- metals commodities
                    "Softs"};                                                                           -- other commodities

-- global variables
local name;
local signal = {};
local source = {}; 
local stream = {};
local pip_cost = {};
local point_size = {};
local overlay = {};
local instrument = {};
local polarity = {};
local o, h, l, c, m, t, w, v = {};  -- internal data streams: OHLC, Median, Typical, Weighted, Volume

local first;
local loading;
local num_instruments;



-- Parameters
function Init()
    local i;

    indicator:name("Synthetic Instrument v" .. VERSION .. "." .. REVISION);
    indicator:description("Instrument constructed from geometric mean of other instruments");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Source Data");
    indicator.parameters:addString("bid_ask_data", "Price Type", "", "Bid");
    indicator.parameters:addStringAlternative("bid_ask_data", "Bid", "", "Bid");
    indicator.parameters:addStringAlternative("bid_ask_data", "Ask", "", "Ask");
    indicator.parameters:addString("source_period", "Source Period", "for each instrument stream", "Chart");
    for i = 1, table.getn(TF), 1 do
        indicator.parameters:addStringAlternative("source_period", TF[i], "", TF[i]);
    end
    indicator.parameters:addString("selection", "Basket Selection", "built in basket of instruments, expand list by editing code, user must be subscribed to required instruments", "User List");
    for i = 1, table.getn(SELECTION), 1 do
        indicator.parameters:addStringAlternative("selection", SELECTION[i], "", SELECTION[i]);
    end
    
    indicator.parameters:addGroup("User List");
    for i = 1, MAX_INSTRUMENTS, 1 do
        indicator.parameters:addString("instrument" .. i, "User Instrument " .. i, "", "");
        indicator.parameters:setFlag("instrument" .. i, core.FLAG_INSTRUMENTS);
    end
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("calculation_method", "Calculation Method", "", "Geometric Mean");
    indicator.parameters:addStringAlternative("calculation_method", "Geometric Mean", "", "Geometric Mean");
    indicator.parameters:addStringAlternative("calculation_method", "Harmonic Mean", "", "Harmonic Mean");  
    indicator.parameters:addStringAlternative("calculation_method", "RMS", "", "RMS");
    indicator.parameters:addStringAlternative("calculation_method", "Cubic Mean", "", "Cubic Mean");    
    indicator.parameters:addStringAlternative("calculation_method", "Linear Product", "", "Linear Product");    
    indicator.parameters:addStringAlternative("calculation_method", "Sum Pips", "", "Sum Pips");    
    indicator.parameters:addStringAlternative("calculation_method", "Sum P/L", "", "Sum P/L");  
    indicator.parameters:addStringAlternative("calculation_method", "Heronian Mean", "", "Heronian Mean");  
    
    for i = 1, MAX_INSTRUMENTS, 1 do
        local default = "Disabled";
        if i == 1 then default = "Normal" end
        indicator.parameters:addString("polarity" .. i, "Polarity " .. i, "polarity used in the product or left out of calculation", default);
        indicator.parameters:addStringAlternative("polarity" .. i, "Normal", "", "Normal");
        indicator.parameters:addStringAlternative("polarity" .. i, "Inverted", "", "Inverted");
        indicator.parameters:addStringAlternative("polarity" .. i, "Disabled", "", "Disabled"); 
    end
    
    indicator.parameters:addGroup("Display");     
    indicator.parameters:addString("display_mode", "Display Mode", "", "Candles");
    indicator.parameters:addStringAlternative("display_mode", "Candles", "", "Candles");
    indicator.parameters:addStringAlternative("display_mode", "Open", "", "Open");
    indicator.parameters:addStringAlternative("display_mode", "High", "", "High");
    indicator.parameters:addStringAlternative("display_mode", "Low", "", "Low");
    indicator.parameters:addStringAlternative("display_mode", "Close", "", "Close");
    indicator.parameters:addStringAlternative("display_mode", "Median", "", "Median");
    indicator.parameters:addStringAlternative("display_mode", "Typical", "", "Typical");
    indicator.parameters:addStringAlternative("display_mode", "Weighted", "", "Weighted");
    indicator.parameters:addStringAlternative("display_mode", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("display_mode", "Percentage Change", "", "Percentage Change");
    
    indicator.parameters:addBoolean("overlay_source", "Overlay Chart Instrument", "", false);
    indicator.parameters:addBoolean("overlay_invert", "Invert Overlay", "", false);
    indicator.parameters:addInteger("lookback", "Lookback Last N Bars", "normalisation period for overlay and percentage change", 200, 0, 1000);
    indicator.parameters:addInteger("levels", "Upper/Lower Levels for Percentage Change", "for use on percentage change display", 5, 0, 200);
    
    indicator.parameters:addColor("synthetic_colour", "Synthetic Line Colour", "", core.rgb(0, 128, 255));  -- blue
    indicator.parameters:addColor("overlay_colour", "Overlay Line Colour", "", core.rgb(255, 255, 0));      -- yellow
    indicator.parameters:addInteger("synthetic_width", "Synthetic Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("overlay_width", "Overlay Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("synthetic_style", "Synthetic Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("synthetic_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("overlay_style", "Overlay Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("overlay_style", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addGroup("About");
    indicator.parameters:addInteger("version", "Version", VERSION_TXT, VERSION, VERSION, VERSION);
    indicator.parameters:addInteger("revision", "Revision", VERSION_TXT, REVISION, REVISION, REVISION);
    indicator.parameters:addString("rev_author", "Revision Author", "for this code revision", REV_AUTHOR);
end


-- Indicator instance initialization    
function Prepare(nameOnly)   
    loading = false;
    
    -- create custom basket? - edit code to expand options, user must be subscribed to required instruments
    local missing_subscriptions = "";
    if instance.parameters.selection ~= "User List" then missing_subscriptions = Configure_inbuilt() end
    
    -- special case for Heronian mean
    if instance.parameters.calculation_method == "Heronian Mean" then
        for i = 3, MAX_INSTRUMENTS, 1 do
            instance.parameters:setString("polarity" .. i, ""); -- blank the polarity to make it more obvious Heronian only applies to first two instruments
        end
    end
    
    
    
    -- fabricate profile name+configuration text
    name = profile:id() .. "(";
    name = name .. instance.parameters.calculation_method .. ", ";
    name = name .. instance.parameters.display_mode .. ", ";
    if instance.parameters.selection ~= "User List" then name = name .. instance.parameters.selection .. " Basket, " end
    local i;
    num_instruments = 0;
    for i = 1, MAX_INSTRUMENTS, 1 do
        instrument[i] = instance.parameters:getString("instrument" .. i);       -- extract instrument
        polarity[i] = instance.parameters:getString("polarity" .. i);           -- extract polarity
        if instrument[i] == "" then                                             -- delete polarity if instrument is missing
            polarity[i] = "";                                                   -- user must define both if switching back from a basket to user instruments
            instance.parameters:setString("polarity" .. i, "");
        end
        --if polarity[i] == "" then                                             -- delete instrument if polarity is missing
        --  instrument[i] = "";                                                 -- user must define both if switching back from a basket to user instruments
        --  instance.parameters:setString("instrument" .. i, "");               -- NOTE: this bit of code causes a crash and indicator is removed from chart
        --end                                                                   -- to do with core.FLAG_INSTRUMENTS in prepare... I don't have a solution
        if polarity[i] == "Normal" then
            name = name .. " " .. instrument[i];
            num_instruments = num_instruments + 1;
        elseif polarity[i] == "Inverted" then
            name = name .. " 1/" .. instrument[i];
            num_instruments = num_instruments + 1;
        end
    end
    name = name .. ")";
    if missing_subscriptions ~= "" then     -- the user need to add these instruments to their subscription list - no errors thrown for not doing so
        name = name .. " Missing Subcriptions for: " .. missing_subscriptions;
    end
    instance:name(name); 

    if nameOnly then return end
    

    source = instance.source
    first = source:first();
     
    
    -- setup required managed streams
    local tf = instance.parameters.source_period;
    local row;
    if tf == "Chart" then tf = source:barSize() end
    local max_dps = 0;
    for i = 1, MAX_INSTRUMENTS, 1 do
        if polarity[i] ~= "Disabled" and polarity[i] ~= "" and instrument[i] ~= "" then
            stream[i] = ManagedStream.new(instrument[i], i, tf, instance.parameters.bid_ask_data == "Bid");
            row = core.host:findTable("Offers"):find("Instrument", instrument[i]);
            point_size[i] = row.PointSize;
            pip_cost[i] = row.PipCost;
            if -math.log10(point_size[i]) > max_dps then max_dps = -math.log10(point_size[i]) + 1 end   -- the +1 sets precision to 0.1 pips rather than 1 pip without
        end
    end
    
    
    -- internal streams for calculation
    o = instance:addInternalStream(first, 0);   -- open
    h = instance:addInternalStream(first, 0);   -- high
    l = instance:addInternalStream(first, 0);   -- low
    c = instance:addInternalStream(first, 0);   -- close
    m = instance:addInternalStream(first, 0);   -- median
    t = instance:addInternalStream(first, 0);   -- typical
    w = instance:addInternalStream(first, 0);   -- weighted
    v = instance:addInternalStream(first, 0);   -- volume
    
    if instance.parameters.display_mode == "Volume" then
        signal = instance:addStream("signal", core.Bar, name, "signal", instance.parameters.synthetic_colour, first);
        signal:setPrecision(0);
    elseif instance.parameters.display_mode == "Candles" then
        instance:createCandleGroup("Synthetic", "Synthetic", o, h, l, c, v);
    else
        signal = instance:addStream("signal", core.Line, name, "signal", instance.parameters.synthetic_colour, first);
        signal:setWidth(instance.parameters.synthetic_width);
        signal:setStyle(instance.parameters.synthetic_style);
        if instance.parameters.calculation_method == "Sum P/L" then
            signal:setPrecision(2);             -- nearest account currency 0.00
        elseif instance.parameters.calculation_method == "Sum Pips" then
            signal:setPrecision(1);             -- nearest 0.1 pips
        else
            signal:setPrecision(max_dps);       -- the instrument with the most decimal points
        end
        if instance.parameters.display_mode == "Percentage Change" then
            signal:addLevel(0);
            signal:addLevel(-instance.parameters.levels);
            signal:addLevel(instance.parameters.levels);
        end
    end
    
    
    if  instance.parameters.overlay_source == true and
        instance.parameters.display_mode ~= "Volume" and
        instance.parameters.display_mode ~= "Percentage Change"
    then
        overlay = instance:addStream("overlay", core.Line, name, "overlay", instance.parameters.overlay_colour, first);
        overlay:setWidth(instance.parameters.overlay_width);
        overlay:setStyle(instance.parameters.overlay_style);
        overlay:setPrecision(instance.source:getPrecision());
    end 
end

 
-- Compute indicator
function Update(period, mode)
    local i;
    
    if loading == true then return end
    if period <= first then return end
    
    
    -- Calculate the 'from' and 'to' for the ManagedStream
    local from;
    local to;
        
    from = source:date(first);
    if source:isAlive() then
        -- Subscribe so we always get the latest data
        to = 0;
    else
        -- Use the end of the source
        to = source:date(source:size() - 1);
    end
        
    -- Update the ManagedStream
    for i = 1, MAX_INSTRUMENTS, 1 do
        if polarity[i] ~= "Disabled" and polarity[i] ~= "" and instrument[i] ~= "" then
            if stream[i]:update(from, to) == true then return end
        end
    end
    
    if instance.parameters.display_mode == "Percentage Change" and period < source:size() - instance.parameters.lookback then return end
    

    
    -- perform desired calculation
    local date_of_period = source:date(period);

    if instance.parameters.calculation_method == "Sum Pips" or instance.parameters.calculation_method == "Sum P/L" then
        -- perform "Sum Pips" or "Sum P/L"
        o[period] = 0;
        h[period] = 0;
        l[period] = 0;  
        c[period] = 0;
        m[period] = 0;
        t[period] = 0;
        w[period] = 0;
        v[period] = 0;
        if num_instruments > 0 then
            local scale;
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] ~= "Disabled" and polarity[i] ~= "" and instrument[i] ~= "" then
                    scale = 1 / point_size[i];
                    if instance.parameters.calculation_method == "Sum P/L" then scale = scale * pip_cost[i] end
                    if polarity[i] == "Normal" then
                        o[period] = o[period] + stream[i]:getPrice(date_of_period, "Open") * scale;
                        h[period] = h[period] + stream[i]:getPrice(date_of_period, "High") * scale;
                        l[period] = l[period] + stream[i]:getPrice(date_of_period, "Low") * scale;
                        c[period] = c[period] + stream[i]:getPrice(date_of_period, "Close") * scale;
                        m[period] = m[period] + stream[i]:getPrice(date_of_period, "Median") * scale;
                        t[period] = t[period] + stream[i]:getPrice(date_of_period, "Typical") * scale;
                        w[period] = w[period] + stream[i]:getPrice(date_of_period, "Weighted") * scale;
                        v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");   -- volume is sum for all selected instruments       
                    end
                    if polarity[i] == "Inverted" then
                        o[period] = o[period] - stream[i]:getPrice(date_of_period, "Open") * scale;
                        h[period] = h[period] - stream[i]:getPrice(date_of_period, "Low") * scale;
                        l[period] = l[period] - stream[i]:getPrice(date_of_period, "High") * scale;
                        c[period] = c[period] - stream[i]:getPrice(date_of_period, "Close") * scale;
                        m[period] = m[period] - stream[i]:getPrice(date_of_period, "Median") * scale;
                        t[period] = t[period] - stream[i]:getPrice(date_of_period, "Typical") * scale;
                        w[period] = w[period] - stream[i]:getPrice(date_of_period, "Weighted") * scale;
                        v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");       
                    end
                end
            end
        end
    
    elseif instance.parameters.calculation_method == "Geometric Mean" or instance.parameters.calculation_method == "Linear Product" then
        -- perform the "Geometric Mean" or "Linear Product" calculation
        o[period] = 1;  -- start with value of '1' followed by multiplication in formula...
        h[period] = 1;
        l[period] = 1;  
        c[period] = 1;
        m[period] = 1;
        t[period] = 1;
        w[period] = 1;
        v[period] = 0;  -- zero volume
        if num_instruments > 0 then
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] == "Normal" then
                    o[period] = o[period] * stream[i]:getPrice(date_of_period, "Open");
                    h[period] = h[period] * stream[i]:getPrice(date_of_period, "High");
                    l[period] = l[period] * stream[i]:getPrice(date_of_period, "Low");
                    c[period] = c[period] * stream[i]:getPrice(date_of_period, "Close");
                    m[period] = m[period] * stream[i]:getPrice(date_of_period, "Median");
                    t[period] = t[period] * stream[i]:getPrice(date_of_period, "Typical");
                    w[period] = w[period] * stream[i]:getPrice(date_of_period, "Weighted");
                    v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");         
                end
                if polarity[i] == "Inverted" then
                    o[period] = o[period] / stream[i]:getPrice(date_of_period, "Open");
                    h[period] = h[period] / stream[i]:getPrice(date_of_period, "Low");
                    l[period] = l[period] / stream[i]:getPrice(date_of_period, "High");
                    c[period] = c[period] / stream[i]:getPrice(date_of_period, "Close");
                    m[period] = m[period] / stream[i]:getPrice(date_of_period, "Median");
                    t[period] = t[period] / stream[i]:getPrice(date_of_period, "Typical");
                    w[period] = w[period] / stream[i]:getPrice(date_of_period, "Weighted");
                    v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");
                end
            end
            if instance.parameters.calculation_method == "Geometric Mean" then
                o[period] = math.pow(o[period], 1 / num_instruments);   -- geometric mean to linearise the multiplications above[for example trendlines will be more linear]
                h[period] = math.pow(h[period], 1 / num_instruments);   -- see https://en.wikipedia.org/wiki/Geometric_mean
                l[period] = math.pow(l[period], 1 / num_instruments);
                c[period] = math.pow(c[period], 1 / num_instruments);
                m[period] = math.pow(m[period], 1 / num_instruments);
                t[period] = math.pow(t[period], 1 / num_instruments);
                w[period] = math.pow(w[period], 1 / num_instruments);
            end
        end

    elseif instance.parameters.calculation_method == "Harmonic Mean" then
        -- perform Harmonic Mean calculation: see https://en.wikipedia.org/wiki/Harmonic_mean
        o[period] = 0;
        h[period] = 0;
        l[period] = 0;  
        c[period] = 0;
        m[period] = 0;
        t[period] = 0;
        w[period] = 0;
        v[period] = 0;
        if num_instruments > 0 then
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] == "Normal" then
                    o[period] = o[period] + 1 / stream[i]:getPrice(date_of_period, "Open");
                    h[period] = h[period] + 1 / stream[i]:getPrice(date_of_period, "Low");
                    l[period] = l[period] + 1 / stream[i]:getPrice(date_of_period, "High");
                    c[period] = c[period] + 1 / stream[i]:getPrice(date_of_period, "Close");
                    m[period] = m[period] + 1 / stream[i]:getPrice(date_of_period, "Median");
                    t[period] = t[period] + 1 / stream[i]:getPrice(date_of_period, "Typical");
                    w[period] = w[period] + 1 / stream[i]:getPrice(date_of_period, "Weighted");
                    v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");
                end
                if polarity[i] == "Inverted" then
                    o[period] = o[period] + stream[i]:getPrice(date_of_period, "Open");
                    h[period] = h[period] + stream[i]:getPrice(date_of_period, "High");
                    l[period] = l[period] + stream[i]:getPrice(date_of_period, "Low");
                    c[period] = c[period] + stream[i]:getPrice(date_of_period, "Close");
                    m[period] = m[period] + stream[i]:getPrice(date_of_period, "Median");
                    t[period] = t[period] + stream[i]:getPrice(date_of_period, "Typical");
                    w[period] = w[period] + stream[i]:getPrice(date_of_period, "Weighted");
                    v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");
                end
            end
            o[period] = num_instruments / o[period];
            h[period] = num_instruments / h[period];
            l[period] = num_instruments / l[period];    
            c[period] = num_instruments / c[period];
            m[period] = num_instruments / m[period];
            t[period] = num_instruments / t[period];
            w[period] = num_instruments / w[period];        
        end
        
    elseif instance.parameters.calculation_method == "RMS" then
        o[period] = 0;
        h[period] = 0;
        l[period] = 0;  
        c[period] = 0;
        m[period] = 0;
        t[period] = 0;
        w[period] = 0;
        v[period] = 0;
        if num_instruments > 0 then
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] == "Normal" then
                    o[period] = o[period] + math.pow(stream[i]:getPrice(date_of_period, "Open"), 2);
                    h[period] = h[period] + math.pow(stream[i]:getPrice(date_of_period, "Low"), 2);
                    l[period] = l[period] + math.pow(stream[i]:getPrice(date_of_period, "High"), 2);
                    c[period] = c[period] + math.pow(stream[i]:getPrice(date_of_period, "Close"), 2);
                    m[period] = m[period] + math.pow(stream[i]:getPrice(date_of_period, "Median"), 2);
                    t[period] = t[period] + math.pow(stream[i]:getPrice(date_of_period, "Typical"), 2);
                    w[period] = w[period] + math.pow(stream[i]:getPrice(date_of_period, "Weighted"), 2);
                    v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");
                end
                if polarity[i] == "Inverted" then
                    o[period] = o[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Open"), 2);
                    h[period] = h[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "High"), 2);
                    l[period] = l[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Low"), 2);
                    c[period] = c[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Close"), 2);
                    m[period] = m[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Median"), 2);
                    t[period] = t[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Typical"), 2);
                    w[period] = w[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Weighted"), 2);
                    v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");
                end
            end
            o[period] = math.sqrt(o[period] / num_instruments);
            h[period] = math.sqrt(h[period] / num_instruments);
            l[period] = math.sqrt(l[period] / num_instruments);
            c[period] = math.sqrt(c[period] / num_instruments);
            m[period] = math.sqrt(m[period] / num_instruments);
            t[period] = math.sqrt(t[period] / num_instruments);
            w[period] = math.sqrt(w[period] / num_instruments);
        end
    
    elseif instance.parameters.calculation_method == "Cubic Mean" then
        o[period] = 0;
        h[period] = 0;
        l[period] = 0;  
        c[period] = 0;
        m[period] = 0;
        t[period] = 0;
        w[period] = 0;
        v[period] = 0;
        if num_instruments > 0 then
            for i = 1, MAX_INSTRUMENTS, 1 do
                if polarity[i] == "Normal" then
                    o[period] = o[period] + math.pow(stream[i]:getPrice(date_of_period, "Open"), 3);
                    h[period] = h[period] + math.pow(stream[i]:getPrice(date_of_period, "Low"), 3);
                    l[period] = l[period] + math.pow(stream[i]:getPrice(date_of_period, "High"), 3);
                    c[period] = c[period] + math.pow(stream[i]:getPrice(date_of_period, "Close"), 3);
                    m[period] = m[period] + math.pow(stream[i]:getPrice(date_of_period, "Median"), 3);
                    t[period] = t[period] + math.pow(stream[i]:getPrice(date_of_period, "Typical"), 3);
                    w[period] = w[period] + math.pow(stream[i]:getPrice(date_of_period, "Weighted"), 3);
                    v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");
                end
                if polarity[i] == "Inverted" then
                    o[period] = o[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Open"), 3);
                    h[period] = h[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "High"), 3);
                    l[period] = l[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Low"), 3);
                    c[period] = c[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Close"), 3);
                    m[period] = m[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Median"), 3);
                    t[period] = t[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Typical"), 3);
                    w[period] = w[period] + math.pow(1 / stream[i]:getPrice(date_of_period, "Weighted"), 3);
                    v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");
                end
            end
            o[period] = math.pow(o[period] / num_instruments, 1 / 3);
            h[period] = math.pow(h[period] / num_instruments, 1 / 3);
            l[period] = math.pow(l[period] / num_instruments, 1 / 3);
            c[period] = math.pow(c[period] / num_instruments, 1 / 3);
            m[period] = math.pow(m[period] / num_instruments, 1 / 3);
            t[period] = math.pow(t[period] / num_instruments, 1 / 3);
            w[period] = math.pow(w[period] / num_instruments, 1 / 3);
        end
    
    elseif instance.parameters.calculation_method == "Heronian Mean" then   -- no idea if this might be useful, but it is coded in
        if num_instruments == 2 and polarity[1] ~= "Disabled" and polarity[2] ~= "Disabled" then    -- special case, only applies to first 2 instruments
            o[period] = Heronian(date_of_period, "Open");
            h[period] = Heronian(date_of_period, "High");
            l[period] = Heronian(date_of_period, "Low");
            c[period] = Heronian(date_of_period, "Close");
            m[period] = Heronian(date_of_period, "Median");
            t[period] = Heronian(date_of_period, "Typical");
            w[period] = Heronian(date_of_period, "Weighted");
            v[period] = stream[1]:getPrice(date_of_period, "Volume") + stream[2]:getPrice(date_of_period, "Volume");
        end
    end
    
    
    
        
    -- number of bars to lookback for % change and overlay normalisation
    local offset = instance.parameters.lookback;
    if source:size() - offset < first then offset = source:size() - first end
        
    if instance.parameters.display_mode == "Open" then signal[period] = o[period];
        elseif instance.parameters.display_mode == "High" then signal[period] = h[period];
        elseif instance.parameters.display_mode == "Low" then signal[period] = l[period];
        elseif instance.parameters.display_mode == "Close" then signal[period] = c[period];
        elseif instance.parameters.display_mode == "Median" then signal[period] = m[period];
        elseif instance.parameters.display_mode == "Typical" then signal[period] = t[period];
        elseif instance.parameters.display_mode == "Weighted" then signal[period] = w[period];
        elseif instance.parameters.display_mode == "Volume" then signal[period] = v[period];
        elseif instance.parameters.display_mode == "Percentage Change" then signal[period] = c[period] / c[source:size() - offset] * 100 - 100;
    end
    
    if  instance.parameters.overlay_source == true and
        period == source:size() - 1 and
        instance.parameters.display_mode ~= "Volume" and
        instance.parameters.display_mode ~= "Percentage Change"
    then
        local i;
        local min1, max1;
        local min2, max2;
        min1, max1 = mathex.minmax(c, c:size() - offset, c:size() - 1);
        min2, max2 = mathex.minmax(source.close, source:size() - offset, source:size() - 1);
        if instance.parameters.overlay_invert == true then
            for i = 0, source:size() - 1, 1 do
                overlay[period - i] = ((-source.close[period - i] + max2) / (max2 - min2)) * (max1 - min1) + (min1 + max1) / 2 - (max1 - min1) / 2;
            end
        else
            for i = 0, source:size() - 1, 1 do
                overlay[period - i] = ((source.close[period - i] - min2) / (max2 - min2)) * (max1 - min1) + (min1 + max1) / 2 - (max1 - min1) / 2;
            end
        end
    end
        
        
    --[[
    if instance.parameters.display_mode == "Volume" then    -- test code
        if v[period] > v[period - 1] then
            if c[period] > c[period - 1] then signal:setColor(period, core.rgb(255, 0, 0)) end
            if c[period] < c[period - 1] then signal:setColor(period, core.rgb(0, 255, 0)) end
        end
    end
    ]]--
 end                 
 
 
-- utility function to calculate Heronian mean - hard coded to first two instruments
function Heronian(date, price_type)
    local a = stream[1]:getPrice(date, price_type);
    local b = stream[2]:getPrice(date, price_type);
    if polarity[1] == "Inverted" then a = 1 / a end
    if polarity[2] == "Inverted" then b = 1 / b end
    return (a + math.sqrt(a * b) + b) / 3;
end


-- Handle asynchronous events
function AsyncOperationFinished(cookie, success, message)
    local i;
    
    if stream[cookie]:async(cookie, success) == true then
        loading = true;                     -- something is still loading...
        return 0;
    end 
    loading = false;                        -- everything must have been loaded at this point
    
    
    
    
    instance:updateFrom(first);             -- update the chart
    return core.ASYNC_REDRAW;
end


-- configure the inbuilt basket selection - update user instruments so they reflect the selection as if this was done manually
-- returns string with list of unsubscribed instruments and disables those streams to prevent an error
function Configure_inbuilt()
    
    -- reset parameters for user instruments to default
    local i;
    for i = 1, MAX_INSTRUMENTS, 1 do
        instance.parameters:setString("instrument" .. i, "EUR/USD");
        instance.parameters:setString("polarity" .. i, "");
    end
    instance.parameters:setString("polarity" .. 1, "Normal");
    
    -- Note: the configured "calculation_method" is left unchanged
    -- ie. since user may wish to alter it and custom defining here would reset the value each time it is changed
    -- For instance, normally currency strengths are defined as a "Geometric Mean" but "Harmonic Mean", or "Sum Pips", etc..., could be desired
    
    -- re-configure parameters for desired selection
    if instance.parameters.selection == "USD" then  -- USD strength
        instance.parameters:setString("instrument" .. 1, "AUD/USD");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "USD/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "USD/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/USD");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "USD/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "GBP/USD");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "NZD/USD");        instance.parameters:setString("polarity" .. 7, "Inverted");
    end
    
    if instance.parameters.selection == "EUR" then  -- EUR strength
        instance.parameters:setString("instrument" .. 1, "EUR/AUD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "EUR/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "EUR/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/USD");        instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "EUR/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "EUR/GBP");        instance.parameters:setString("polarity" .. 6, "Normal");
        instance.parameters:setString("instrument" .. 7, "EUR/NZD");        instance.parameters:setString("polarity" .. 7, "Normal");
    end

    if instance.parameters.selection == "GBP" then  -- GBP strength
        instance.parameters:setString("instrument" .. 1, "GBP/AUD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "GBP/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "GBP/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "GBP/USD");        instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "GBP/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "EUR/GBP");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "GBP/NZD");        instance.parameters:setString("polarity" .. 7, "Normal");
    end
    
    if instance.parameters.selection == "CAD" then  -- CAD strength
        instance.parameters:setString("instrument" .. 1, "AUD/CAD");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "USD/CAD");        instance.parameters:setString("polarity" .. 2, "Inverted");
        instance.parameters:setString("instrument" .. 3, "CAD/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/CAD");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "CAD/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "GBP/CAD");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "NZD/CAD");        instance.parameters:setString("polarity" .. 7, "Inverted");
    end
        
    if instance.parameters.selection == "AUD" then  -- AUD strength
        instance.parameters:setString("instrument" .. 1, "AUD/USD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "AUD/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "AUD/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/AUD");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "AUD/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "GBP/AUD");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "AUD/NZD");        instance.parameters:setString("polarity" .. 7, "Normal");
    end
    
    if instance.parameters.selection == "NZD" then  -- NZD strength
        instance.parameters:setString("instrument" .. 1, "NZD/USD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "NZD/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "NZD/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/NZD");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "NZD/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "GBP/NZD");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "AUD/NZD");        instance.parameters:setString("polarity" .. 7, "Inverted");
    end
    
    if instance.parameters.selection == "JPY" then  -- JPY strength
        instance.parameters:setString("instrument" .. 1, "USD/JPY");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "AUD/JPY");        instance.parameters:setString("polarity" .. 2, "Inverted");
        instance.parameters:setString("instrument" .. 3, "CHF/JPY");        instance.parameters:setString("polarity" .. 3, "Inverted");
        instance.parameters:setString("instrument" .. 4, "EUR/JPY");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "CAD/JPY");        instance.parameters:setString("polarity" .. 5, "Inverted");
        instance.parameters:setString("instrument" .. 6, "GBP/JPY");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "NZD/JPY");        instance.parameters:setString("polarity" .. 7, "Inverted");
    end

    if instance.parameters.selection == "CHF" then  -- CHF strength
        instance.parameters:setString("instrument" .. 1, "USD/CHF");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "AUD/CHF");        instance.parameters:setString("polarity" .. 2, "Inverted");
        instance.parameters:setString("instrument" .. 3, "CHF/JPY");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/CHF");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "CAD/CHF");        instance.parameters:setString("polarity" .. 5, "Inverted");
        instance.parameters:setString("instrument" .. 6, "GBP/CHF");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "NZD/CHF");        instance.parameters:setString("polarity" .. 7, "Inverted");
    end
    
    if instance.parameters.selection == "NOK" then  -- NOK strength
        instance.parameters:setString("instrument" .. 1, "USD/NOK");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "EUR/NOK");        instance.parameters:setString("polarity" .. 2, "Inverted");
    end

    if instance.parameters.selection == "SEK" then  -- SEK strength
        instance.parameters:setString("instrument" .. 1, "USD/SEK");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "EUR/SEK");        instance.parameters:setString("polarity" .. 2, "Inverted");
    end
    
    if instance.parameters.selection == "ZAR" then  -- ZAR strength
        instance.parameters:setString("instrument" .. 1, "USD/ZAR");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "ZAR/JPY");        instance.parameters:setString("polarity" .. 2, "Normal");
    end
    
    if instance.parameters.selection == "HUF" then  -- HUF strength
        instance.parameters:setString("instrument" .. 1, "USD/HUF");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "EUR/HUF");        instance.parameters:setString("polarity" .. 2, "Inverted");
    end
    
    if instance.parameters.selection == "TRY" then  -- TRY strength
        instance.parameters:setString("instrument" .. 1, "USD/TRY");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "EUR/TRY");        instance.parameters:setString("polarity" .. 2, "Inverted");
    end
    
    if instance.parameters.selection == "USD Extended" then -- USD strength, extended instruments
        instance.parameters:setString("instrument" .. 1, "AUD/USD");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "USD/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "USD/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/USD");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "USD/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "GBP/USD");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "NZD/USD");        instance.parameters:setString("polarity" .. 7, "Inverted");
        instance.parameters:setString("instrument" .. 8, "USD/HKD");        instance.parameters:setString("polarity" .. 8, "Normal");
        instance.parameters:setString("instrument" .. 9, "USD/HUF");        instance.parameters:setString("polarity" .. 9, "Normal");
        instance.parameters:setString("instrument" .. 10, "USD/MXN");       instance.parameters:setString("polarity" .. 10, "Normal");
        instance.parameters:setString("instrument" .. 11, "USD/NOK");       instance.parameters:setString("polarity" .. 11, "Normal");
        instance.parameters:setString("instrument" .. 12, "USD/SEK");       instance.parameters:setString("polarity" .. 12, "Normal");
        instance.parameters:setString("instrument" .. 13, "USD/TRY");       instance.parameters:setString("polarity" .. 13, "Normal");
        instance.parameters:setString("instrument" .. 14, "USD/ZAR");       instance.parameters:setString("polarity" .. 14, "Normal");
    end

    if instance.parameters.selection == "EUR Extended" then -- EUR strength, extended instruments
        instance.parameters:setString("instrument" .. 1, "EUR/AUD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "EUR/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "EUR/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/USD");        instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "EUR/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "EUR/GBP");        instance.parameters:setString("polarity" .. 6, "Normal");
        instance.parameters:setString("instrument" .. 7, "EUR/NZD");        instance.parameters:setString("polarity" .. 7, "Normal");
        instance.parameters:setString("instrument" .. 8, "EUR/HUF");        instance.parameters:setString("polarity" .. 8, "Normal");
        instance.parameters:setString("instrument" .. 9, "EUR/NOK");        instance.parameters:setString("polarity" .. 9, "Normal");
        instance.parameters:setString("instrument" .. 10, "EUR/SEK");       instance.parameters:setString("polarity" .. 10, "Normal");
        instance.parameters:setString("instrument" .. 11, "EUR/TRY");       instance.parameters:setString("polarity" .. 11, "Normal");
    end
    
    if instance.parameters.selection == "US Stock Indices" then -- US stocks strength
        instance.parameters:setString("instrument" .. 1, "NAS100");         instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "US30");           instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "SPX500");         instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "US2000");         instance.parameters:setString("polarity" .. 4, "Normal");
    end
    
    if instance.parameters.selection == "European Stock Indices" then -- EU stocks strength
        instance.parameters:setString("instrument" .. 1, "GER30");          instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "FRA40");          instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "UK100");          instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "ESP35");          instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "EUSTX50");        instance.parameters:setString("polarity" .. 5, "Normal");
    end
    
    if instance.parameters.selection == "Asia Stock Indices" then -- Asia stocks strength
        instance.parameters:setString("instrument" .. 1, "AUS200");         instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "HKG33");          instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "JPN225");         instance.parameters:setString("polarity" .. 3, "Normal");
    end
    
    if instance.parameters.selection == "Risk-On" then -- Risk-On strength
        instance.parameters:setString("instrument" .. 1, "USEquities");     instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "EMBasket");       instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "USDOLLAR");       instance.parameters:setString("polarity" .. 3, "Inverted");
        instance.parameters:setString("instrument" .. 4, "JPYBasket");      instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "VOLX");           instance.parameters:setString("polarity" .. 5, "Inverted");
    end
    
    if instance.parameters.selection == "Safe Haven" then   -- Safe Havens USD, JPY & CHF strength
        instance.parameters:setString("instrument" .. 1, "AUD/USD");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "USD/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "EUR/USD");        instance.parameters:setString("polarity" .. 3, "Inverted");
        instance.parameters:setString("instrument" .. 4, "GBP/USD");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "NZD/USD");        instance.parameters:setString("polarity" .. 5, "Inverted");
        instance.parameters:setString("instrument" .. 6, "AUD/JPY");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "EUR/JPY");        instance.parameters:setString("polarity" .. 7, "Inverted");
        instance.parameters:setString("instrument" .. 8, "CAD/JPY");        instance.parameters:setString("polarity" .. 8, "Inverted");
        instance.parameters:setString("instrument" .. 9, "GBP/JPY");        instance.parameters:setString("polarity" .. 9, "Inverted");
        instance.parameters:setString("instrument" .. 10, "NZD/JPY");       instance.parameters:setString("polarity" .. 10, "Inverted");
        instance.parameters:setString("instrument" .. 11, "AUD/CHF");       instance.parameters:setString("polarity" .. 11, "Inverted");
        instance.parameters:setString("instrument" .. 12, "EUR/CHF");       instance.parameters:setString("polarity" .. 12, "Inverted");
        instance.parameters:setString("instrument" .. 13, "CAD/CHF");       instance.parameters:setString("polarity" .. 13, "Inverted");
        instance.parameters:setString("instrument" .. 14, "GBP/CHF");       instance.parameters:setString("polarity" .. 14, "Inverted");
        instance.parameters:setString("instrument" .. 15, "NZD/CHF");       instance.parameters:setString("polarity" .. 15, "Inverted");
    end

    if instance.parameters.selection == "North America" then    -- USD+CAD strength
        instance.parameters:setString("instrument" .. 1, "AUD/USD");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "USD/CHF");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "EUR/USD");        instance.parameters:setString("polarity" .. 3, "Inverted");
        instance.parameters:setString("instrument" .. 4, "USD/JPY");        instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "GBP/USD");        instance.parameters:setString("polarity" .. 5, "Inverted");
        instance.parameters:setString("instrument" .. 6, "NZD/USD");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "AUD/CAD");        instance.parameters:setString("polarity" .. 7, "Inverted");
        instance.parameters:setString("instrument" .. 8, "CAD/CHF");        instance.parameters:setString("polarity" .. 8, "Normal");
        instance.parameters:setString("instrument" .. 9, "EUR/CAD");        instance.parameters:setString("polarity" .. 9, "Inverted");
        instance.parameters:setString("instrument" .. 10, "CAD/JPY");       instance.parameters:setString("polarity" .. 10, "Normal");
        instance.parameters:setString("instrument" .. 11, "GBP/CAD");       instance.parameters:setString("polarity" .. 11, "Inverted");
        instance.parameters:setString("instrument" .. 12, "NZD/CAD");       instance.parameters:setString("polarity" .. 12, "Inverted");
    end
    
    if instance.parameters.selection == "Europe" then   -- EUR+GBP+HUF+NOK+SEK strength
        instance.parameters:setString("instrument" .. 1, "EUR/AUD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "EUR/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "EUR/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/USD");        instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "EUR/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "EUR/NZD");        instance.parameters:setString("polarity" .. 6, "Normal");
        instance.parameters:setString("instrument" .. 7, "GBP/AUD");        instance.parameters:setString("polarity" .. 7, "Normal");
        instance.parameters:setString("instrument" .. 8, "GBP/CAD");        instance.parameters:setString("polarity" .. 8, "Normal");
        instance.parameters:setString("instrument" .. 9, "GBP/CHF");        instance.parameters:setString("polarity" .. 9, "Normal");
        instance.parameters:setString("instrument" .. 10, "GBP/USD");       instance.parameters:setString("polarity" .. 10, "Normal");
        instance.parameters:setString("instrument" .. 11, "GBP/JPY");       instance.parameters:setString("polarity" .. 11, "Normal");
        instance.parameters:setString("instrument" .. 12, "GBP/NZD");       instance.parameters:setString("polarity" .. 12, "Normal");
        instance.parameters:setString("instrument" .. 13, "USD/HUF");       instance.parameters:setString("polarity" .. 13, "Inverted");
        instance.parameters:setString("instrument" .. 14, "USD/NOK");       instance.parameters:setString("polarity" .. 14, "Inverted");
        instance.parameters:setString("instrument" .. 15, "USD/SEK");       instance.parameters:setString("polarity" .. 15, "Inverted");
    end
    
    if instance.parameters.selection == "Australasia" then  -- AUD+NZD strength
        instance.parameters:setString("instrument" .. 1, "AUD/USD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "AUD/CAD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "AUD/CHF");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/AUD");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "AUD/JPY");        instance.parameters:setString("polarity" .. 5, "Normal");
        instance.parameters:setString("instrument" .. 6, "GBP/AUD");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "NZD/USD");        instance.parameters:setString("polarity" .. 7, "Normal");
        instance.parameters:setString("instrument" .. 8, "NZD/CAD");        instance.parameters:setString("polarity" .. 8, "Normal");
        instance.parameters:setString("instrument" .. 9, "NZD/CHF");        instance.parameters:setString("polarity" .. 9, "Normal");
        instance.parameters:setString("instrument" .. 10, "EUR/NZD");       instance.parameters:setString("polarity" .. 10, "Inverted");
        instance.parameters:setString("instrument" .. 11, "NZD/JPY");       instance.parameters:setString("polarity" .. 11, "Normal");
        instance.parameters:setString("instrument" .. 12, "GBP/NZD");       instance.parameters:setString("polarity" .. 12, "Inverted");
    end
    
    if instance.parameters.selection == "Asia" then -- JPY+HKD+KRW+TWD+INR strength
        instance.parameters:setString("instrument" .. 1, "USD/JPY");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "AUD/JPY");        instance.parameters:setString("polarity" .. 2, "Inverted");
        instance.parameters:setString("instrument" .. 3, "CHF/JPY");        instance.parameters:setString("polarity" .. 3, "Inverted");
        instance.parameters:setString("instrument" .. 4, "EUR/JPY");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "CAD/JPY");        instance.parameters:setString("polarity" .. 5, "Inverted");
        instance.parameters:setString("instrument" .. 6, "GBP/JPY");        instance.parameters:setString("polarity" .. 6, "Inverted");
        instance.parameters:setString("instrument" .. 7, "NZD/JPY");        instance.parameters:setString("polarity" .. 7, "Inverted");
        instance.parameters:setString("instrument" .. 8, "USD/HKD");        instance.parameters:setString("polarity" .. 8, "Inverted");
        instance.parameters:setString("instrument" .. 9, "USD/KRW");        instance.parameters:setString("polarity" .. 9, "Inverted");
        instance.parameters:setString("instrument" .. 10, "USD/TWD");       instance.parameters:setString("polarity" .. 10, "Inverted");
        instance.parameters:setString("instrument" .. 11, "USD/INR");       instance.parameters:setString("polarity" .. 11, "Inverted");
    end
    
    if instance.parameters.selection == "Latin America" then -- MXN+CLP+COP
        instance.parameters:setString("instrument" .. 1, "USD/MXN");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "USD/CLP");        instance.parameters:setString("polarity" .. 2, "Inverted");
        instance.parameters:setString("instrument" .. 3, "USD/COP");        instance.parameters:setString("polarity" .. 3, "Inverted");
    end
    
    if instance.parameters.selection == "Scandinavia" then  -- Scandinavia strength
        instance.parameters:setString("instrument" .. 1, "USD/NOK");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "EUR/NOK");        instance.parameters:setString("polarity" .. 2, "Inverted");
        instance.parameters:setString("instrument" .. 3, "USD/SEK");        instance.parameters:setString("polarity" .. 3, "Inverted");
        instance.parameters:setString("instrument" .. 4, "EUR/SEK");        instance.parameters:setString("polarity" .. 4, "Inverted");
    end
    
    if instance.parameters.selection == "Commodity Currencies USD" then -- Commodity currency strength versus USD
        instance.parameters:setString("instrument" .. 1, "USD/CAD");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "AUD/USD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "NZD/USD");        instance.parameters:setString("polarity" .. 3, "Normal");
    end

    if instance.parameters.selection == "Commodity Currencies USD & EUR" then   -- Commodity currency strength versus USD & EUR
        instance.parameters:setString("instrument" .. 1, "USD/CAD");        instance.parameters:setString("polarity" .. 1, "Inverted");
        instance.parameters:setString("instrument" .. 2, "AUD/USD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "NZD/USD");        instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "EUR/CAD");        instance.parameters:setString("polarity" .. 4, "Inverted");
        instance.parameters:setString("instrument" .. 5, "EUR/AUD");        instance.parameters:setString("polarity" .. 5, "Inverted");
        instance.parameters:setString("instrument" .. 6, "EUR/NZD");        instance.parameters:setString("polarity" .. 6, "Inverted");
    end

    if instance.parameters.selection == "Oil" then  -- Oil strength
        instance.parameters:setString("instrument" .. 1, "USOil");          instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "UKOil");          instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "USOilSpot");      instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "UKOilSpot");      instance.parameters:setString("polarity" .. 4, "Normal");
    end
    
    if instance.parameters.selection == "Energy Complex" then  -- Energy complex
        instance.parameters:setString("instrument" .. 1, "USOil");          instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "UKOil");          instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "NGAS");           instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "GasolineF");      instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "HeatingOilF");    instance.parameters:setString("polarity" .. 5, "Normal");
    end
    
    if instance.parameters.selection == "Monetary Metals" then  -- Copper, Silver & Gold strength
        instance.parameters:setString("instrument" .. 1, "XAU/USD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "XAG/USD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "Copper");         instance.parameters:setString("polarity" .. 3, "Normal");
    end

    if instance.parameters.selection == "Gold Majors" then  -- Gold strength averaged across majors ie XAUUSD, XAUGBP, XAUEUR... etc...
        instance.parameters:setString("instrument" .. 1, "XAU/USD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "XAU/USD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "EUR/USD");        instance.parameters:setString("polarity" .. 3, "Inverted");
        instance.parameters:setString("instrument" .. 4, "XAU/USD");        instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "GBP/USD");        instance.parameters:setString("polarity" .. 5, "Inverted");
        instance.parameters:setString("instrument" .. 6, "XAU/USD");        instance.parameters:setString("polarity" .. 6, "Normal");
        instance.parameters:setString("instrument" .. 7, "USD/CAD");        instance.parameters:setString("polarity" .. 7, "Normal");
        instance.parameters:setString("instrument" .. 8, "XAU/USD");        instance.parameters:setString("polarity" .. 8, "Normal");
        instance.parameters:setString("instrument" .. 9, "AUD/USD");        instance.parameters:setString("polarity" .. 9, "Inverted");
        instance.parameters:setString("instrument" .. 10, "XAU/USD");       instance.parameters:setString("polarity" .. 10, "Normal");
        instance.parameters:setString("instrument" .. 11, "NZD/USD");       instance.parameters:setString("polarity" .. 11, "Inverted");
        instance.parameters:setString("instrument" .. 12, "XAU/USD");       instance.parameters:setString("polarity" .. 12, "Normal");
        instance.parameters:setString("instrument" .. 13, "USD/JPY");       instance.parameters:setString("polarity" .. 13, "Normal");
        instance.parameters:setString("instrument" .. 14, "XAU/USD");       instance.parameters:setString("polarity" .. 14, "Normal");
        instance.parameters:setString("instrument" .. 15, "USD/CHF");       instance.parameters:setString("polarity" .. 15, "Normal");
    end

    if instance.parameters.selection == "Silver Majors" then    -- Silver strength averaged across majors ie XAGUSD, XAGGBP, XAGEUR... etc...
        instance.parameters:setString("instrument" .. 1, "XAG/USD");        instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "XAG/USD");        instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "EUR/USD");        instance.parameters:setString("polarity" .. 3, "Inverted");
        instance.parameters:setString("instrument" .. 4, "XAG/USD");        instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "GBP/USD");        instance.parameters:setString("polarity" .. 5, "Inverted");
        instance.parameters:setString("instrument" .. 6, "XAG/USD");        instance.parameters:setString("polarity" .. 6, "Normal");
        instance.parameters:setString("instrument" .. 7, "USD/CAD");        instance.parameters:setString("polarity" .. 7, "Normal");
        instance.parameters:setString("instrument" .. 8, "XAG/USD");        instance.parameters:setString("polarity" .. 8, "Normal");
        instance.parameters:setString("instrument" .. 9, "AUD/USD");        instance.parameters:setString("polarity" .. 9, "Inverted");
        instance.parameters:setString("instrument" .. 10, "XAG/USD");       instance.parameters:setString("polarity" .. 10, "Normal");
        instance.parameters:setString("instrument" .. 11, "NZD/USD");       instance.parameters:setString("polarity" .. 11, "Inverted");
        instance.parameters:setString("instrument" .. 12, "XAG/USD");       instance.parameters:setString("polarity" .. 12, "Normal");
        instance.parameters:setString("instrument" .. 13, "USD/JPY");       instance.parameters:setString("polarity" .. 13, "Normal");
        instance.parameters:setString("instrument" .. 14, "XAG/USD");       instance.parameters:setString("polarity" .. 14, "Normal");
        instance.parameters:setString("instrument" .. 15, "USD/CHF");       instance.parameters:setString("polarity" .. 15, "Normal");
    end
    
    if instance.parameters.selection == "Metals Complex" then -- Metals Complex excluding Gold + Silver
        instance.parameters:setString("instrument" .. 1, "AlumSpot");       instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "LeadSpot");       instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "NickelSpot");     instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "ZincSpot");       instance.parameters:setString("polarity" .. 4, "Normal");
        instance.parameters:setString("instrument" .. 5, "Copper");         instance.parameters:setString("polarity" .. 5, "Normal");
    end
    
    if instance.parameters.selection == "Softs" then    -- Softs
        instance.parameters:setString("instrument" .. 1, "WHEATF");         instance.parameters:setString("polarity" .. 1, "Normal");
        instance.parameters:setString("instrument" .. 2, "CORNF");          instance.parameters:setString("polarity" .. 2, "Normal");
        instance.parameters:setString("instrument" .. 3, "CoffeeNYF");      instance.parameters:setString("polarity" .. 3, "Normal");
        instance.parameters:setString("instrument" .. 4, "SugarNYF");       instance.parameters:setString("polarity" .. 4, "Normal");
    end


    
    -- disable all instruments that have not been subscribed to ... 
    local instrument;
    local missing = "";
    for i = 1, MAX_INSTRUMENTS, 1 do
        instrument = instance.parameters:getString("instrument" .. i);
        if instrument == "" then
            instance.parameters:setString("polarity" .. i, "Disabled");
        elseif core.host:findTable("Offers"):find("Instrument", instrument) == nil then
            instance.parameters:setString("polarity" .. i, "Disabled");
            instance.parameters:setString("instrument" .. i, "EUR/USD");    -- set parameter to default instrument to prevent crash with undefined instrument
            missing = missing .. " " .. instrument;
        end
    end
    
    return missing;
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
ManagedStream = {};

-- Factory method to create a new ManagedStream object
function ManagedStream.new(instrument, cookie, barSize, bidOrAsk, extend)
    -- Create the data object
    local data = {};

    -- Add the __index metamethod to the table, setting it to ManagedStream
    -- this causes all objects constructed by 'new' to inherit the methods
    setmetatable(data, {__index = ManagedStream});

    data.instrument = instrument;
    data.cookie = cookie;
    data.barSize = barSize;
    data.bidOrAsk = bidOrAsk;
    data.loading = false;
    data.stream = nil;
    data.requestedFrom = 0;
    data.requestedTo = 0;
    data.extend = extend;

    return data;
end

-- Use 'update' method to update the ManagedStream object from Update()
function ManagedStream:update(from, to)
    if not self.loading then
        if self.stream == nil then
            -- No data yet, so we load the history
            self.loading = true;
            self.requestedFrom = from;
            self.requestedTo = to;
            if self.extend then
                -- Only load the default duration, it will get extended later
                self.stream = core.host:execute("getHistory", self.cookie, self.instrument, self.barSize, 0, to, self.bidOrAsk);
            else
                -- Attempt to load the whole date range
                self.stream = core.host:execute("getHistory", self.cookie, self.instrument, self.barSize, from, to, self.bidOrAsk);
            end
        else
            if from < self.requestedFrom then
                -- Required 'from' is earlier start date/time, so extend to the left
                self.loading = true;
                self.requestedFrom = from;
                core.host:execute("extendHistory", self.cookie, self.stream, from, self.stream:date(self.stream:first()));
            elseif to ~= 0 and to > self.requestedTo then
                -- Required 'to' is later start date/time, so extend to the right
                self.loading = true;
                self.requestedTo = to;
                core.host:execute("extendHistory", self.cookie, self.stream, self.stream:date(self.stream:size() - 1), to);
            elseif self.extend and self.stream:size() > 0 and from < self.stream:date(self.stream:first()) then
                -- Didn't load all history last time, so extend now
                self.loading = true;
                self.requestedFrom = from;
                self.extend = false;
                core.host:execute("extendHistory", self.cookie, self.stream, from, self.stream:date(self.stream:first()));
            end
        end
    end

    return self.loading;
end

-- Use 'async' method to update the ManagedStream object from AsyncOperationFinished()
function ManagedStream:async(cookie, success)
    if cookie == self.cookie and success then
        self.loading = false;
    end

    return self.loading;
end

-- Index the ManagedStream by date and return the period
function ManagedStream:getPeriod(date)
    -- TODO: this is O(log2(N)) search. Maybe possible to optimize it since we
    -- usually don't do random access of the stream, but use it in a linear fashion
    -- i.e. the requested date is usually very close to the last requested date.
    return core.findDate(self.stream, date, false);
end

-- Index the ManagedStream by date and return the close price (or -1 if not available)
-- NOTE: This can be used with bar_stream and tick_stream
-- modifications by SM Webb for Volume and Weighted
function ManagedStream:getPrice(date, type)
    local period = self:getPeriod(date);

    if period >= 0 then
        if self.stream:isBar() then
            if not type or type == "Close" then
                return self.stream.close[period];
            elseif type == "Open" then
                return self.stream.open[period];
            elseif type == "High" then
                return self.stream.high[period];
            elseif type == "Low" then
                return self.stream.low[period];
            elseif type == "Median" then
                return (self.stream.high[period] + self.stream.low[period]) / 2;
            elseif type == "Typical" then
                return (self.stream.high[period] + self.stream.low[period] + self.stream.close[period]) / 3;
            elseif type == "Weighted" then
                return (self.stream.high[period] + self.stream.low[period] + 2 * self.stream.close[period]) / 4;
            elseif type == "Volume" then
                return (self.stream.volume[period]);
            else
                return self.stream.close[period];
            end
        else
            return self.stream[period];
        end
    else
        return -1;
    end
end

-- Index the ManagedStream by date and return the open, high, low and close (or -1 if not available)
-- NOTE: This can only be used with bar_stream
function ManagedStream:getCandle(date)
    local period = self:getPeriod(date);

    if period >= 0 then
        return self.stream.open[period], self.stream.high[period], self.stream.low[period], self.stream.close[period];
    else
        return -1, -1, -1, -1;
    end
end
