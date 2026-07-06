-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26605
-- Id: 7944

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Volume with average and bands (reconstructed tick volume)
-- Copyright (c) 2012 Steven Dickinson
-- http://robocod.blogspot.co.uk/
--
-- Notes:
-- Version 1 - First version
-- Version 2 - Remove the 2nd upper/lower band; option to use StdDev or AvgVol or no bands
-- Version 3 - ManagedStream is included directly in the indicator code (no need for rbc_utils.lua)
-- Version 4 - Doesn't re-construct if the primary and secondary streams have the same period

-- Local variables
local source; -- The 'primary' stream
local lastSerial;
local host;
local stream; -- The 'managed stream' which can be different timeframe to the primary stream
local lastPeriod;
local loading = false;
local dayOffset;
local weekOffset;
local barVolume;
local reconstruct;

-- Outputs
local volume;
local avg;
local upper;
local lower;

-- Create the indicator's profile
function Init()
    indicator:name("Volume Indicator");
    indicator:description("Volume Indicator, with average and bands");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    local colour = core.colors();
    
    -- License
    --indicator.parameters:addGroup("License");
    --indicator.parameters:addString("license", "License key", "Enter the license key", "");

    -- Calculation parameters
    indicator.parameters:addGroup("Calculation parameters");
    indicator.parameters:addInteger("length", "Average length", "", 20, 1, 9999);
    indicator.parameters:addDouble("upperMultiplier", "Upper band multiplier", "", 2);
    indicator.parameters:addDouble("lowerMultiplier", "Lower band multiplier", "", 2);

    indicator.parameters:addString("mode", "Band mode", "", "StdDev");
    indicator.parameters:addStringAlternative("mode", "Off", "", "Off");
    indicator.parameters:addStringAlternative("mode", "Standard deviation", "", "StdDev");
    indicator.parameters:addStringAlternative("mode", "Average volume", "", "AvgVol");
    
    indicator.parameters:addString("period", "Period", "Period used to reconstruct the volume", "m1");
    indicator.parameters:setFlag("period", core.FLAG_PERIODS);
    indicator.parameters:addInteger("initialBars", "Initial bars", "The number of bars to load initially (0 means load whole chart)", 20);

    -- Display options
    --indicator.parameters:addGroup("Display options");
    
    -- Colours and effects
    indicator.parameters:addGroup("Colours and effects");
    indicator.parameters:addColor("volumeColour", "Volume colour", "", colour.Gray);
    indicator.parameters:addColor("avgColour", "Average colour", "", colour.Blue);
    indicator.parameters:addColor("upperColour", "Upper band colour", "", colour.Red);
    indicator.parameters:addColor("lowerColour", "Upper band colour", "", colour.Green);
    indicator.parameters:addBoolean("fade", "Fade", "Fade colour of non-reconstructed bars", false);
end

-- Create a new instance of the indicator
function Prepare(nameOnly)
    -- Create locals for these commonly used variables
    source = instance.source;
    host = core.host;
    
    -- Set the indicator name
    local name = string.format("%s(%s, %s, %d, %s)", profile:id(), instance.source:name(),  instance.parameters.period,
        instance.parameters.length, instance.parameters.mode);
    instance:name(name);

    if nameOnly then
        return
    end

    -- Load required modules
    --require "rbc_utils";

    -- Initialise some variables
    lastPeriod = 0;
    lastSerial = nil;
    loading = false;
    dayOffset = host:execute("getTradingDayOffset");
    weekOffset = host:execute("getTradingWeekOffset");
    barVolume = 0;

    -- Use ManagedStream
    stream = ManagedStream.new(source:instrument(), 1, instance.parameters.period, source:isBid());
    
    -- Outputs
    first = source:first() + instance.parameters.length - 1;
    volume = instance:addStream("VOLUME", core.Bar, name..".VOLUME", "VOLUME", instance.parameters.volumeColour, source:first());
    volume:setPrecision(0);
    volume:addLevel(0, core.LINE_NONE);
    avg = instance:addStream("AVG", core.Line, name..".AVG", "AVG", instance.parameters.avgColour, first);
    avg:setPrecision(0);
    upper = instance:addStream("UPPER", core.Line, name..".UPPER", "UPPER", instance.parameters.upperColour, first);
    upper:setStyle(core.LINE_DOT);
    upper:setPrecision(0);
    lower = instance:addStream("LOWER", core.Line, name..".LOWER", "LOWER", instance.parameters.lowerColour, first);
    lower:setStyle(core.LINE_DOT);
    lower:setPrecision(0);
    
    -- If the primary and secondary streams have the same period, there is no need to use the reconstruct volume
    reconstruct = (instance.parameters.period ~= source:barSize());
end

-- Update the indicator
function Update(period, mode)
    if period < source:first() then
        return;
    end
    
    if reconstruct then
        if loading then
            return;
        end
        
        -- Calculate the 'from' and 'to' for the ManagedStream
        local from;
        local to;
        
        if instance.parameters.initialBars > 0 then
            from = source:date(math.max(source:first(), source:size() - instance.parameters.initialBars));
        else
            from = source:date(source:first());
        end
        
        if source:isAlive() then
            -- Subscribe so we always get the latest data
            to = 0;
        else
            -- Use the end of the source
            to = source:date(source:size() - 1);
        end
        
        -- Update the ManagedStream
        loading = stream:update(from, to);
        
        if loading then
            return;
        end
        
        if period == source:first() then
            -- Initialise some variables
            lastSerial = nil;
            lastPeriod = stream.stream:first();
            barVolume = 0;
        end
        
        -- Check for a new bar on the 'primary' stream
        if lastSerial ~= source:serial(period) then
            lastSerial = source:serial(period);
            
            -- New bar
            barVolume = 0;
        end
        
        -- Get the start / end times of the current candle
        local candleStart, candleEnd = core.getcandle(source:barSize(), source:date(period), dayOffset, weekOffset);
        
        -- Check for a new completed bar on the ManagedStream
        local i = lastPeriod;
        local calculate = false;
        while i < (stream.stream:size() - 1) and (stream.stream:date(i) < candleEnd) do
            if stream.stream:date(i) >= candleStart then
                -- Add the data to the candle profile
                if stream.stream:isBar() then
                    barVolume = barVolume + stream.stream.volume[i];
                else
                    barVolume = barVolume + 1;
                end
                calculate = true;
            end
            
            i = i + 1;
        end
        lastPeriod = i;
    end
    
    -- Volume
    local fade = false;
    if reconstruct and source:date(period) >= stream.stream:date(stream.stream:first()) then
        -- Use reconstructed tick volume from secondary stream
        volume[period] = barVolume;
    else
        -- Use regular tick volume from primary stream
        volume[period] = source.volume[period];
        fade = true;
    end
    
    if period >= first then
        -- Compute mean and standard deviation
        local r = core.rangeTo(period, instance.parameters.length);
        local mean = mathex.avg(volume, r);
        local stdev = mathex.stdev(volume, r);
        avg[period] = mean;
        
        -- Compute bands
        if instance.parameters.mode == "StdDev" then
            upper[period] = mean + instance.parameters.upperMultiplier * stdev;
            lower[period] = mean - instance.parameters.lowerMultiplier * stdev;
        elseif instance.parameters.mode == "AvgVol" then
            upper[period] = mean * instance.parameters.upperMultiplier;
            lower[period] = mean * instance.parameters.lowerMultiplier;
        end
        
        -- Set the volume bar colour
        local colour = instance.parameters.volumeColour;
        if instance.parameters.mode ~= "Off" then
            if volume[period] >= upper[period] then
                colour = instance.parameters.upperColour;
            elseif volume[period] <= lower[period] then
                colour = instance.parameters.lowerColour;
            end
        end
        
        if instance.parameters.fade and fade then
            colour = getFadedColour(colour, 0.5);
        end
        volume:setColor(period, colour);
    end
end

-- Release the indicator
function ReleaseInstance()
    -- Nothing to do yet
end

-- Handle asynchronous events
function AsyncOperationFinished(cookie, success, message)
    -- Check ManagedStream objects
    loading = stream:async(cookie, success);

    if loading then
        -- No need to re-draw (yet)
        return 0;
    else
        -- Force a re-draw
        instance:updateFrom(source:first());
        return core.ASYNC_REDRAW;
    end
end

--#############################################################################
-- ManagedStream class
--#############################################################################
ManagedStream = {};

-- Factory method to create a new ManagedStream object
function ManagedStream.new(instrument, cookie, barSize, bidOrAsk)
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
    data.cache = nil; -- date & period cache for speed

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
            self.stream = core.host:execute("getHistory", self.cookie, self.instrument, self.barSize, from, to, self.bidOrAsk);
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
    if self.cache and self.cache.date == date then
        -- Use cached value
        return self.cache.period;
    else
        -- TODO: this is O(log2(N)) search. Maybe possible to optimize it since we
        -- usually don't do random access of the stream, but use it in a linear fashion
        -- i.e. the requested date is usually very close to the last requested date.
        local period = core.findDate(self.stream, date, false);

        if period >= 0 then
            -- Store it in the cache
            self.cache = { date = date, period = period };
        end

        return period;
    end
end

-- Index the ManagedStream by date and return the close price (or -1 if not available)
-- NOTE: This can be used with bar_stream and tick_strean
function ManagedStream:getPrice(date)
    local period = self:getPeriod(date);

    if period >= 0 then
        if self.stream:isBar() then
            return self.stream.close[period];
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

--#############################################################################
-- Convert an HSV colour to RGB
--#############################################################################
function convertHSVtoRGB(hue, saturation, value)
    -- http://en.wikipedia.org/wiki/HSL_and_HSV
    -- Hue is an angle (0..360), Saturation and Value are both in the range 0..1
    
    local hi = (math.floor(hue / 60)) % 6;
    local f = hue / 60 - math.floor(hue / 60);

    value = value * 255;
    local v = math.floor(value);
    local p = math.floor(value * (1 - saturation));
    local q = math.floor(value * (1 - f * saturation));
    local t = math.floor(value * (1 - (1 - f) * saturation));

    if hi == 0 then
        return core.rgb(v, t, p);
    elseif hi == 1 then
        return core.rgb(q, v, p);
    elseif hi == 2 then
        return core.rgb(p, v, t);
    elseif hi == 3 then
        return core.rgb(p, q, v);
    elseif hi == 4 then
        return core.rgb(t, p, v);
    else
        return core.rgb(v, p, q);
    end
end

--#############################################################################
-- Convert an RGB colour to HSV
--#############################################################################
function convertRGBtoHSV(red, green, blue)
    -- http://en.wikipedia.org/wiki/HSL_and_HSV
    -- Hue is an angle (0..360), Saturation and Value are both in the range 0..1
    local hue = 0;
    local saturation = 0;
    local value = 0;
    
    -- Find min/max rgb values
    local min = math.min(red, math.min(green, blue));
    local max = math.max(red, math.max(green, blue));
    
    -- Compute value (which is the max(r,g,b))
    value = max;
    if value == 0 then
        -- Black
        return 0, 0, 0;
    end
    
    -- Normalize to value
    red = red / value;
    green = green / value;
    blue = blue / value;
    value = value / 255;
    
    -- Find the new normalized min/max rgb values
    min = math.min(red, math.min(green, blue));
    max = math.max(red, math.max(green, blue));
    
    -- Saturation
    saturation = max - min;
    if saturation == 0 then
        -- Grey
        return 0, 0, value;
    end
    
    -- Normalize to saturation
    red = (red - min) / saturation;
    green = (green - min) / saturation;
    blue = (blue - min) / saturation;
    
    -- Hue
    if red == max then
        hue = 0 + 60 * (green - blue);
        if hue < 0 then
            hue = hue + 360;
        end
    elseif green == max then
        hue = 120 + 60 * (blue - red);
    else
        hue = 240 + 60 * (red - green);
    end
    
    -- Colour
    return hue, saturation, value;
end

--#############################################################################
-- Generate 'lighter' RGB colour from base colour and ratio
--#############################################################################
function getFadedColour(colour, ratio)
    -- Using HSV colour system, where Hue is set from RGB, and Saturation is set to the ratio
    
    ratio = math.max(0, math.min(1, ratio));
    
    -- Split into RGB components
    -- NOTE: internally the color is stored as BGR for some reason
    local red = colour % 256;
    local green = math.floor(colour / 256) % 256;
    local blue = math.floor(colour / 65536) % 256;
    
    -- Compute the Hue from the RGB
    local hue, saturation, value = convertRGBtoHSV(red, green, blue);
    
    if saturation == 0 then
        -- Convert back to RGB, with special handling for neutral colours
        return convertHSVtoRGB(hue, saturation, value + (1 - ratio) * (1 - value));
    else
        -- Convert back to RGB, with saturation component scaled
        return convertHSVtoRGB(hue, saturation * ratio, value);
    end
end