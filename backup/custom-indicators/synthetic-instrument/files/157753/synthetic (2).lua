--
-- Synthetic instrument indicator
-- "synthetic.lua"
--
-- Original code by: SM Webb January 2025 aka Steve_W per fxcodebase
--
-- Calculate the geometric mean of a number of selectable instruments using multiply and/or divide
-- The geometirc mean should be considered as a "strength" - it is not a real price value
-- There is option for "Linear Product" which skips the geometic mean step - this may be useful for conversion of price - eg. XAUGBP = XAUUSD / GBPUSD
--
-- For example:
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


---------------------------------
-- see section near end of file:
-- Code uses a modified version of Managed streams Class from here: https://fxcodebase.com/code/viewtopic.php?f=17&t=4037&p=124465&hilit=better_volume.lua#p124465
-- Better Volume Indicator (modified to reconstruct the volume from lower time-frame bars)
-- Copyright (c) 2012 Steven Dickinson
-- http://robocod.blogspot.co.uk/
---------------------------------


-- History
-- Version 1.0 SM Webb Jan 2025: First release - mostly debugged



-- code version, revision and author
local VERSION = 1;
local REVISION = 0;
local REV_AUTHOR = "Steve_W";


-- global constants
local MAX_INSTRUMENTS = 10;			-- maximum number of instruments that may be used by indicator - edit value to needs...
									-- currency strengths for majors require ~7, but this could be extended for EUR or USD to include exotics or lesser currencies eg. USDNOK, USDSEK
local TF = {"Chart", "m1", "m5", "m15", "m30", "H1", "H2", "H4", "H6", "H8", "D1", "W1", "M1"};


-- global variables
local source = {}; 
local stream = {};
local instrument = {};
local polarity = {};
local o, h, l, c, m, t, w, v = {};	-- internal data streams: OHLC, Median, Typical, Weighted, Volume

local first;
local loading = false;
local num_instruments;
local name;

-- Parameters
function Init()
	local i;

    indicator:name("Synthetic Instrument");
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
	for i = 1, MAX_INSTRUMENTS, 1 do
		indicator.parameters:addString("instrument" .. i, "Instrument " .. i, "", "");
		indicator.parameters:setFlag("instrument" .. i, core.FLAG_INSTRUMENTS);
	end
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("calculation_method", "Calulation Method", "", "Geometric Mean");
	indicator.parameters:addStringAlternative("calculation_method", "Geometric Mean", "", "Geometric Mean");
	indicator.parameters:addStringAlternative("calculation_method", "Linear Product", "", "Linear Product");	
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
	indicator.parameters:addColor("colour", "Line Colour", "", core.rgb(0, 128, 255));
	indicator.parameters:addInteger("width", "Line width in pixels", "", 2, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("About");
	indicator.parameters:addInteger("version", "Version", "", VERSION, VERSION, VERSION);
	indicator.parameters:addInteger("revision", "Revision", "", REVISION, REVISION, REVISION);
	indicator.parameters:addString("rev_author", "Revision Author", "for this code revision", REV_AUTHOR);
end




-- Indicator instance initialization	
function Prepare(nameOnly)   
	local i;
	
	name = profile:id() .. "( ";
	for i = 1, MAX_INSTRUMENTS, 1 do
		instrument[i] = instance.parameters:getString("instrument" .. i);	-- extract instrument
		polarity[i] = instance.parameters:getString("polarity" .. i);		-- extract polarity
		if polarity[i] == "Normal" then
			name = name .. instrument[i] .. " ";
		elseif polarity[i] == "Inverted" then
			name = name .. "1/" .. instrument[i] .. " ";
		end
	end
	name = name .. ")";
	if loading == true then
		name = name .. " loading...";
	end
	instance:name(name); 

    if nameOnly then return end
	

	source = instance.source
	first = source:first();
	 
	
	-- internal streams for calculation
	o = instance:addInternalStream(first, 0);	-- open
    h = instance:addInternalStream(first, 0);	-- high
    l = instance:addInternalStream(first, 0);	-- low
    c = instance:addInternalStream(first, 0);	-- close
    m = instance:addInternalStream(first, 0);	-- median
	t = instance:addInternalStream(first, 0);	-- typical
	w = instance:addInternalStream(first, 0);	-- weighted
    v = instance:addInternalStream(first, 0);	-- volume
	
	if instance.parameters.display_mode == "Volume" then
	    signal = instance:addStream("signal", core.Bar, name, "signal", instance.parameters.colour, first );
		signal:setPrecision(0); 
	elseif instance.parameters.display_mode == "Candles" then
		instance:createCandleGroup("Synthetic", "Synthetic", o, h, l, c, v);
	else
	    signal = instance:addStream("signal", core.Line, name, "signal", instance.parameters.colour, first );
		signal:setWidth(instance.parameters.width);
		signal:setStyle(instance.parameters.style);
		signal:setPrecision(math.max(2, instance.source:getPrecision())); 
	end

	-- setup required managed streams
	local tf = instance.parameters.source_period;
	if tf == "Chart" then tf = source:barSize() end
	for i = 1, MAX_INSTRUMENTS, 1 do
		if polarity[i] ~= "Disabled" then stream[i] = ManagedStream.new(instrument[i], i, tf, instance.parameters.bid_ask_data == "Bid") end
	end
end

 
-- Compute indicator
function Update(period, mode)
	local i;
	
	if period <= first then return end
	
	if loading == true then return end
	
	-- Calculate the 'from' and 'to' for the ManagedStream
    local from;
    local to;
        
    from = source:date(source:first());
    if source:isAlive() then
        -- Subscribe so we always get the latest data
        to = 0;
    else
        -- Use the end of the source
        to = source:date(source:size() - 1);
    end
        
    -- Update the ManagedStream
	for i = 1, MAX_INSTRUMENTS, 1 do
		if polarity[i] ~= "Disabled" then
			if stream[i]:update(from, to) == true then return end
		end
	end
	
	-- perform the geometric mean calculation
	o[period] = 1;	-- start with value of '1' followed by multiplication in formula...
	h[period] = 1;
	l[period] = 1;	
	c[period] = 1;
	m[period] = 1;
	t[period] = 1;
	w[period] = 1;
	v[period] = 0;	-- zero volume
	local count = 0;
	local date_of_period = source:date(period);
	for i = 1, MAX_INSTRUMENTS, 1 do
		if polarity[i] == "Normal" then
			count = count + 1;
			o[period] = o[period] * stream[i]:getPrice(date_of_period, "Open");
			h[period] = h[period] * stream[i]:getPrice(date_of_period, "High");
			l[period] = l[period] * stream[i]:getPrice(date_of_period, "Low");
			c[period] = c[period] * stream[i]:getPrice(date_of_period, "Close");
			m[period] = m[period] * stream[i]:getPrice(date_of_period, "Median");
			t[period] = t[period] * stream[i]:getPrice(date_of_period, "Typical");
			w[period] = w[period] * stream[i]:getPrice(date_of_period, "Weighted");
			v[period] = v[period] + stream[i]:getPrice(date_of_period, "Volume");	-- volume is simply the sum for all selected instruments		
		end
		if polarity[i] == "Inverted" then
			count = count + 1;
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
	
	if count > 0 then
		if instance.parameters.calculation_method == "Geometric Mean" then
			o[period] = math.pow(o[period], 1 / count);		-- geometric mean to linearise the multiplications above[for example trendlines will be more linear]
			h[period] = math.pow(h[period], 1 / count);		-- see wikipedia for basic description of geometric mean method
			l[period] = math.pow(l[period], 1 / count);
			c[period] = math.pow(c[period], 1 / count);
			m[period] = math.pow(m[period], 1 / count);
			t[period] = math.pow(t[period], 1 / count);
			w[period] = math.pow(w[period], 1 / count);
		end
	
		if instance.parameters.display_mode == "Open" then signal[period] = o[period];
			elseif instance.parameters.display_mode == "High" then signal[period] = h[period];
			elseif instance.parameters.display_mode == "Low" then signal[period] = l[period];
			elseif instance.parameters.display_mode == "Close" then signal[period] = c[period];
			elseif instance.parameters.display_mode == "Median" then signal[period] = m[period];
			elseif instance.parameters.display_mode == "Typical" then signal[period] = t[period];
			elseif instance.parameters.display_mode == "Weighted" then signal[period] = w[period];
			elseif instance.parameters.display_mode == "Volume" then signal[period] = v[period];
		end
	end
 end				 
 

-- Handle asynchronous events
function AsyncOperationFinished(cookie, success, message)
	local i;
	
	for i = 1, MAX_INSTRUMENTS, 1 do
		if polarity[i] ~= "Disabled" then
			if stream[i]:async(cookie, success) == true then
				loading = true;
				return 0;
			end 
		end
	end
	instance:updateFrom(source:first());
    return core.ASYNC_REDRAW;
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
