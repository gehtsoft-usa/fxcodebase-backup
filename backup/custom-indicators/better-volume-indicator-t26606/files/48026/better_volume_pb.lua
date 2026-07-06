-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26606
-- Id: 8037

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

-- Better Volume Indicator with "Paint Bars" (modified to reconstruct the volume from lower time-frame bars)
-- Copyright (c) 2012 Steven Dickinson
-- http://robocod.blogspot.co.uk/
--
-- Notes:
-- Version 1 - First version

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
local open;
local high;
local low;
local close;

-- Better Volume variables...
local N;
local Back;
local first;
local ClimaxUp = nil;
local ClimaxDn = nil;
local DensityUp = nil;
local DensityDn = nil;
local VolumeBar = nil;
local SMAline = nil;

-- Create the indicator's profile
function Init()
    indicator:name("Better Volume PB Indicator");
    indicator:description("Better Volume Indicator with 'paint bars'");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Volume Indicators");
    indicator:setTag("replaceSource", "t"); 
    
    local colour = core.colors();
    
    -- License
    --indicator.parameters:addGroup("License");
    --indicator.parameters:addString("license", "License key", "Enter the license key", "");

    -- Calculation parameters
    indicator.parameters:addGroup("Calculation parameters");
    indicator.parameters:addInteger("N", "Average Period", "Length of volume SMA", 20);
    indicator.parameters:addInteger("Back", "Analyse Period Back", "Number of bars used for analysis", 20);
    indicator.parameters:addBoolean("TwoBars", "Use TwoBars", "Use 2 bars for analysis", false);
    
    indicator.parameters:addString("period", "Period", "Period used to reconstruct the volume", "m1");
    indicator.parameters:setFlag("period", core.FLAG_PERIODS);
    indicator.parameters:addInteger("initialBars", "Initial bars", "The number of bars to load initially (0 means load whole chart)", 20);

    -- Display options
    --indicator.parameters:addGroup("Display options");
    
    -- Colours and effects
    indicator.parameters:addGroup("Colours and effects");
    indicator.parameters:addColor("LowVol_color", "Color of LowVol", "Color of LowVol_color", colour.Yellow);
    indicator.parameters:addColor("ClimaxUp_color", "Color of ClimaxUp", "Color of ClimaxUp", colour.Red);
    indicator.parameters:addColor("ClimaxDn_color", "Color of ClimaxDn", "Color of ClimaxDn", colour.White);
    indicator.parameters:addColor("DensityUp_color", "Color of Churn", "Color of DensityUp", colour.Lime);
    indicator.parameters:addColor("DensityDn_color", "Color of ClimaxChurn", "Color of DensityDn", colour.Magenta);
    indicator.parameters:addColor("VolumeBar_color", "Color of VolumeBar", "Color of VolumeBar", colour.Gray);
    indicator.parameters:addColor("SMAline_color", "Color of SMAline", "Color of SMAline", colour.Red);
    indicator.parameters:addBoolean("fade", "Fade", "Fade colour of non-reconstructed bars", false);
    indicator.parameters:addBoolean("shade", "Shade", "Darken the down bars", false);
end

-- Create a new instance of the indicator
function Prepare(nameOnly)
    -- Create locals for these commonly used variables
    source = instance.source;
    host = core.host;
    N = instance.parameters.N;
    Back = instance.parameters.Back;
    first = source:first() + N + Back - 1;
    
    -- Set the indicator name
    local name = string.format("%s(%s, %s, %d, %d)", profile:id(), instance.source:name(),  instance.parameters.period, N, Back);
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
    Value1 = instance:addInternalStream(0,0);
    Value2 = instance:addInternalStream(0,0);
    Value3 = instance:addInternalStream(0,0);
    Value4 = instance:addInternalStream(0,0);
    Value5 = instance:addInternalStream(0,0);
    Value6 = instance:addInternalStream(0,0);
    Value7 = instance:addInternalStream(0,0);
    Value8 = instance:addInternalStream(0,0);
    Value9 = instance:addInternalStream(0,0);
    Value10 = instance:addInternalStream(0,0);
    Value11 = instance:addInternalStream(0,0);
    Value12 = instance:addInternalStream(0,0);
    Value13 = instance:addInternalStream(0,0);
    Value14 = instance:addInternalStream(0,0);
    Value15 = instance:addInternalStream(0,0);
    Value16 = instance:addInternalStream(0,0);
    Value17 = instance:addInternalStream(0,0);
    Value18 = instance:addInternalStream(0,0);
    Value19 = instance:addInternalStream(0,0);
    Value20 = instance:addInternalStream(0,0);
    Value21 = instance:addInternalStream(0,0);
    Value22 = instance:addInternalStream(0,0);
    
    VolumeBar = instance:addInternalStream(0,0);
    SMAline = instance:addInternalStream(0,0);
    
    -- If the primary and secondary streams have the same period, there is no need to use the reconstruct volume
    reconstruct = (instance.parameters.period ~= source:barSize());
    
    -- Candle outputs
    open = instance:addStream("OPEN", core.Line, name .. ".OPEN", "OPEN", core.COLOR_UPCANDLE, 0);
    high = instance:addStream("HIGH", core.Line, name .. ".HIGH", "HIGH", core.rgb(0,0,0), 0);
    low = instance:addStream("LOW", core.Line, name .. ".LOW", "LOW", core.rgb(0,0,0), 0);
    close = instance:addStream("CLOSE", core.Line, name .. ".CLOSE", "CLOSE", core.rgb(0,0,0), 0);
    instance:createCandleGroup(name, name, open, high, low, close);
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
    local VOLUME;
    if reconstruct and source:date(period) >= stream.stream:date(stream.stream:first()) then
        -- Use reconstructed tick volume from secondary stream
        VOLUME = barVolume;
    else
        -- Use regular tick volume from primary stream
        VOLUME = source.volume[period];
        fade = true;
    end
    
    -- Better Volume logic below...
    local p = period;
    local HIGH = source.high[period];
    local LOW = source.low[period];
    local OPEN = source.open[period];
    local CLOSE = source.close[period];
    VolumeBar[period] = VOLUME;
    SMAline[period] = 0;
    
    if period < first then
        Value1[p] = 0;
        Value2[p] = 0;
        Value3[p] = 0;
        Value4[p] = 0;
        Value5[p] = 0;
        Value6[p] = 0;
        Value7[p] = 0;
        Value8[p] = 0;
        Value9[p] = 0;
        Value10[p] = 0;
        Value11[p] = 0;
        Value12[p] = 0;
        Value13[p] = 0;
        Value14[p] = 0;
        Value15[p] = 0;
        Value16[p] = 0;
        Value17[p] = 0;
        Value18[p] = 0;
        Value19[p] = 0;
        Value20[p] = 0;
        Value21[p] = 0;
        Value22[p] = 0;
    else
        SMAline[period] = mathex.avg(VolumeBar,period-N+1,period);
        local Range = HIGH-LOW;

        if  CLOSE > OPEN then
            Value1[p] = VOLUME*(Range/(2*Range + OPEN - CLOSE));
        elseif CLOSE < OPEN then
            Value1[p] = VOLUME*((Range + CLOSE-OPEN)/(2*Range + CLOSE-OPEN));
        end
        if CLOSE == OPEN then
            Value1[p] = 0.5*VOLUME;
        end
        Value2[p] =     VOLUME - Value1[p];
        Value3[p] =     Value1[p] + Value2[p];
        Value4[p] =     Value1[p] * Range;
        Value5[p] = (   Value1[p]-Value2[p])*Range
        Value6[p] =     Value2[p]*Range;
        Value7[p] = (   Value2[p]-Value1[p])*Range;
        if Range ~= 0 then
            Value8[p]  =    Value1[p]/Range;
            Value9[p]  = (  Value1[p]-Value2[p])/Range;
            Value10[p] =    Value2[p]/Range;
            Value11[p] = (  Value2[p]-Value1[p])/Range;
            Value12[p] =    Value3[p]/Range;
        end

        Value13[p] = Value3[p] + Value3[p-1];
        Value14[p] = (Value1[p]+Value1[p-1])*(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value15[p] = (Value1[p]+Value1[p-1] - Value2[p] - Value2[p-1]) * (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value16[p] = (Value2[p]+Value2[p-1])*(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value17[p] = (Value2[p]+Value2[p-1] - Value1[p] - Value1[p-1]) * (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        if mathex.max(source.high,p-2+1,p) ~= mathex.min(source.low,p-2+1,p) then
            Value18[p] = (Value1[p] + Value1[p-1])/(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        end
        Value19[p] = (Value1[p]+Value1[p-1] - Value2[p] - Value2[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value20[p] = (Value2[p]+Value2[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value21[p] = (Value2[p]+Value2[p-1] - Value1[p] - Value1[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value22[p] = Value13[p]/(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        
        local colour = instance.parameters.VolumeBar_color;
        if not instance.parameters.TwoBars then
            --Con 1 or Con 11
            if (Value3[p] == mathex.min(Value3,p-Back+1,p)) then  -- Yellow -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                colour = instance.parameters.LowVol_color;
            end
            --Con 2 or Con 3 or Con 8 or Con 9 or Con 12 or Con 13 or Con 18 or con 19
            if (Value4[p] == mathex.max(Value4,p-Back+1,p) and CLOSE > OPEN) or
               (Value5[p] == mathex.max(Value5,p-Back+1,p) and CLOSE > OPEN) or
               (Value10[p] == mathex.min(Value10,p-Back+1,p) and CLOSE > OPEN) or 
               (Value11[p] == mathex.min(Value11,p-Back+1,p) and CLOSE > OPEN) then  --RED -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                colour = instance.parameters.ClimaxUp_color;
            end
            --Con 4 or Con 5 or Con 6 or Con 7 or Con 14 or Con 15 or Con 16 or con 17
            if (Value6[p] == mathex.max(Value6,p-Back+1,p) and CLOSE < OPEN) or
               (Value7[p] == mathex.max(Value7,p-Back+1,p) and CLOSE < OPEN) or
               (Value8[p] == mathex.min(Value8,p-Back+1,p) and CLOSE < OPEN) or 
               (Value9[p] == mathex.min(Value9,p-Back+1,p) and CLOSE < OPEN) then -- White
                colour = instance.parameters.ClimaxDn_color;
            end
            -- Churn Con 10
            if Value12[p] == mathex.max(Value12,p-Back+1,p) then -- Green
                colour = instance.parameters.DensityUp_color;
            end
            --ClimaxChurn
            if (Value12[p] == mathex.max(Value12,p-Back+1,p) ) and 
               (    (Value4[p] == mathex.max(Value4,p-Back+1,p) and CLOSE > OPEN) or
                    (Value5[p] == mathex.max(Value5,p-Back+1,p) and CLOSE > OPEN) or
                    (Value10[p] == mathex.min(Value10,p-Back+1,p) and CLOSE > OPEN) or 
                    (Value11[p] == mathex.min(Value11,p-Back+1,p) and CLOSE > OPEN) or
                    (Value6[p] == mathex.max(Value6,p-Back+1,p) and CLOSE < OPEN) or
                    (Value7[p] == mathex.max(Value7,p-Back+1,p) and CLOSE < OPEN) or
                    (Value8[p] == mathex.min(Value8,p-Back+1,p) and CLOSE < OPEN) or 
                    (Value9[p] == mathex.min(Value9,p-Back+1,p) and CLOSE < OPEN) ) then
                colour = instance.parameters.DensityDn_color;
            end
        else
            --Con 1 or Con 11
            if (Value13[p] == mathex.min(Value13,p-Back+1,p)) then  -- Yellow -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                colour = instance.parameters.LowVol_color;
            end
            --Con 2 or Con 3 or Con 8 or Con 9 or Con 12 or Con 13 or Con 18 or con 19
            if ((Value14[p] == mathex.max(Value14,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
               ((Value15[p] == mathex.max(Value15,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
               ((Value20[p] == mathex.min(Value20,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or 
               ((Value21[p] == mathex.min(Value21,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) then  --RED -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                colour = instance.parameters.ClimaxUp_color;
            end
            --Con 4 or Con 5 or Con 6 or Con 7 or Con 14 or Con 15 or Con 16 or con 17
            if ((Value16[p] == mathex.max(Value16,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
               ((Value17[p] == mathex.max(Value17,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
               ((Value18[p] == mathex.min(Value18,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or 
               ((Value19[p] == mathex.min(Value19,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) then -- White
                colour = instance.parameters.ClimaxDn_color;
            end
            -- Churn Con 10
            if Value22[p] == mathex.max(Value22,p-Back+1,p) then -- Green
                colour = instance.parameters.DensityUp_color;
            end
            --ClimaxChurn
            if (Value22[p] == mathex.max(Value22,p-Back+1,p) ) and 
               (    ((Value14[p] == mathex.max(Value14,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value15[p] == mathex.max(Value15,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value20[p] == mathex.min(Value20,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or 
                    ((Value21[p] == mathex.min(Value21,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value16[p] == mathex.max(Value16,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
                    ((Value17[p] == mathex.max(Value17,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
                    ((Value18[p] == mathex.min(Value18,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or 
                    ((Value19[p] == mathex.min(Value19,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) ) then
                colour = instance.parameters.DensityDn_color;
            end
        end
        
        -- Set the colour
        if instance.parameters.fade and fade then
            colour = getFadedColour(colour, 0.5);
        end
        
        -- Candle outputs
        open[period] = source.open[period];
        high[period] = source.high[period];
        low[period] = source.low[period];
        close[period] = source.close[period];
        
        if instance.parameters.shade and close[period] < open[period] then
            colour = getShadedColour(colour, 0.7);
        end
        
        -- Paint the candle
        open:setColor(period, colour);
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
-- Generate 'darker' RGB colour from base colour and ratio
--#############################################################################
function getShadedColour(colour, ratio)
    -- Using HSV colour system, where Hue is set from RGB, and Value is set to the ratio
    
    ratio = math.max(0, math.min(1, ratio));
    
    -- Split into RGB components
    -- NOTE: internally the color is stored as BGR for some reason
    local red = colour % 256;
    local green = math.floor(colour / 256) % 256;
    local blue = math.floor(colour / 65536) % 256;

    -- Compute the Hue from the RGB
    local hue, saturation, value = convertRGBtoHSV(red, green, blue);
    
    -- Convert back to RGB, with value component scaled
    return convertHSVtoRGB(hue, saturation, value * ratio);
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