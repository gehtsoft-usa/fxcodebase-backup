
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=940

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("The indicator highlights trade sessions");
    indicator:description("The indicator can be applied on 1-minute to 1-hour charts");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("NY_S", "Show New York session (8:00 am - 5:00 pm EST/EDT)", "", true);
    indicator.parameters:addColor("NY_C", "New York session color", "", core.rgb(255, 0, 0));
    indicator.parameters:addBoolean("LO_S", "Show London session (3:00 am - 12:00 pm EST/EDT)", "", true);
    indicator.parameters:addColor("LO_C", "New York session color", "", core.rgb(0, 255, 0));
    indicator.parameters:addBoolean("TO_S", "Show Tokyo session (7:00 pm - 4:00 am EST/EDT)", "", true);
    indicator.parameters:addColor("TO_C", "Tokyo session color", "", core.rgb(0, 0, 255));
    indicator.parameters:addBoolean("SI_S", "Show Sidney session (5:00 pm - 2:00 am EST/EDT)", "", true);
    indicator.parameters:addColor("SI_C", "Sidney session color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("HL", "Highlight transparency (%)", "", 90, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local host;
local new_york = nil;
local london = nil;
local tokyo = nil;
local sidney = nil;
local dummy = nil;
local day_offset, week_offset;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    host = core.host;
    


    local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
    s = math.floor(s * 86400 + 0.5);  -- >>in seconds
    e = math.floor(e * 86400 + 0.5);  -- >>in seconds
    assert((e - s) < 3600, "The source time frame must not be bigger than 1 hour");

    local name = profile:id() .. "()";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	
    if instance.parameters.NY_S then
        -- 8 am to 5 pm
        new_york = CreateSession(8, 9, instance.parameters.NY_C, "NewYork", name);
    end
    if instance.parameters.LO_S then
        -- 3 am to 12 pm
        london = CreateSession(3, 9, instance.parameters.LO_C, "London", name);
    end
    if instance.parameters.TO_S then
        -- 7 pm of yesterday to 4 am of today
        tokyo = CreateSession(-5, 9, instance.parameters.TO_C, "Tokyo", name);
    end
    if instance.parameters.SI_S then
        -- 5 pm of yesterday to 2 am of today
        sidney = CreateSession(-7, 9, instance.parameters.SI_C, "Sidney", name);
    end

    dummy = instance:addInternalStream(0, 0);   -- the stream for bookmarking
end

local ref = nil;    -- the reference 1-hour source

-- Indicator calculation routine
function Update(period)
    if period >= first then
        if ref == nil then
            ref = registerStream(0, "H1", 24);  -- open 1-hour stream which returns 24 bars BEFORE the start of the source collection.
        end
    end

    Process(new_york, period);
    Process(london, period);
    Process(tokyo, period);
    Process(sidney, period);
end

-- Process the specified session
function Process(session, period)
    if session == nil then
        return ;
    end
    -- find the start of the session
    local date = source:date(period);       -- bar date;
    local sfrom, sto;

    -- 1) calculate the session to which the specified date belongs
    local t;
    t = math.floor(date * 86400 + 0.5);     -- date/time in seconds

    -- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
    t = t - session.from * 3600;
    -- truncate to the day only.
    t = math.floor(t / 86400 + 0.5) * 86400;
    -- and shift it back to est time zone
    t = t + session.from * 3600;

    sfrom = t;                          -- begin of the session
    sto = sfrom + session.len * 3600;   -- end of the session

    sfrom = sfrom / 86400;
    sto = sto / 86400;

    -- process only if the date/time is inside the session
    if date >= sfrom and date < sto then
        -- find the hour bar of the beginning of the day
        local ref_period, loading;
        ref_period, loading = getDate(0, sfrom, false, period);
        if ref_period == -1 then
            -- the first bar is not found at all
            -- or the date is being loaded
            return ;
        end
        local hi = 0;
        local lo = 100000000000000;
        while true do
            local t = ref:date(ref_period);
            if t >= sfrom then
                if t >= sto then
                    break;
                end
                if ref.high[ref_period] > hi then
                    hi = ref.high[ref_period];
                end
                if ref.low[ref_period] < lo then
                    lo = ref.low[ref_period];
                end
            end
            ref_period = ref_period + 1;
            if ref_period >= ref:size() then
                break;
            end
        end
        if hi ~= 0 then
            session.begin[period] = sfrom;
            session.high[period] = hi;
            session.highband[period] = hi;
            session.low[period] = lo;
            session.lowband[period] = lo;
            while period > 1 and session.begin[period] == session.begin[period - 1] do
                if session.high[period] ~= hi or
                   session.low[period] ~= low then
                    session.high[period - 1] = hi;
                    session.highband[period - 1] = hi;
                    session.low[period - 1] = lo;
                    session.lowband[period - 1] = lo;
                    period = period - 1;
                else
                    break;
                end    
            end
        end
    else
        session.begin[period] = 0;
    end
end

-- Create the session description
-- from - the offset in hours again 0:00 of the EST canlendar day
-- len - length of the session in hours
-- color - color for lines and fill area
-- name - of the session
-- iname - the name of the indicator
function CreateSession(from, len, color, name, iname)
    local session = {};
    local n;
    session.name = name;
    session.from = from;
    session.len = len;
    n = name .. "_H";
    session.high = instance:addStream(n, core.Line, iname .. "." .. n, n, color, first);
    n = name .. "_L";
    session.low = instance:addStream(n, core.Line, iname .. "." .. n, n, color, first);
    n = name .. "_HB";
    session.highband = instance:addStream(n, core.Line, iname .. "." .. n, n, color, first);
    n = name .. "_LB";
    session.lowband = instance:addStream(n, core.Line, iname .. "." .. n, n, color, first);
    session.begin = instance:addInternalStream(0, 0);
    instance:createChannelGroup(name, name, session.highband, session.lowband, color, 100 - instance.parameters.HL);
    return session;
end

local streams = {}

-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required extent (number of periods to look the back)
-- @return the stream reference
function registerStream(id, barSize, extent)
    local stream = {};
    local s1, e1, length;
    local from, to;

    s1, e1 = core.getcandle(barSize, 0, 0, 0);
    length = math.floor((e1 - s1) * 86400 + 0.5);

    stream.data = nil;
    stream.barSize = barSize;
    stream.length = length;
    stream.loading = false;
    stream.extent = extent;
    local from, dataFrom
    from, dataFrom = getFrom(barSize, length, extent);
    if (source:isAlive()) then
        to = 0;
    else
        t, to = core.getcandle(barSize, source:date(source:size() - 1), day_offset, week_offset);
    end
    stream.loading = true;
    stream.loadingFrom = from;
    stream.dataFrom = from;
    stream.data = host:execute("getHistory", id, source:instrument(), barSize, from, to, source:isBid());
    setBookmark(0);

    streams[id] = stream;
    return stream.data;
end

function getDate(id, candle, precise, period)
    local stream = streams[id];
    assert(stream ~= nil, "Stream is not registered");
    local from, dataFrom, to;
    if candle < stream.dataFrom then
        setBookmark(period);
        if stream.loading then
            return -1, true;
        end
        from, dataFrom = getFrom(stream.barSize, stream.length, stream.extent);
        stream.loading = true;
        stream.loadingFrom = from;
        stream.dataFrom = from;
        host:execute("extendHistory", id, stream.data, from, stream.data:date(0));
        return -1, true;
    end

    if (not(source:isAlive()) and candle > stream.data:date(stream.data:size() - 1)) then
        setBookmark(period);
        if stream.loading then
            return -1, true;
        end
        stream.loading = true;
        from = bf_data:date(bf_data:size() - 1);
        to = candle;
        host:execute("extendHistory", id, stream.data, from, to);
    end

    local p;
    p = findDateFast(stream.data, candle, precise);
    return p, stream.loading;
end

function setBookmark(period)
    local bm;
    bm = dummy:getBookmark(1);
    if bm < 0 then
        bm = period;
    else
        bm = math.min(period, bm);
    end
    dummy:setBookmark(1, bm);
end

-- get the from date for the stream using bar size and extent and taking the non-trading periods
-- into account
function getFrom(barSize, length, extent)
    local from, loadFrom;
    local nontrading, nontradingend;

    from = core.getcandle(barSize, source:date(source:first()), day_offset, week_offset);
    loadFrom = math.floor(from * 86400 - length * extent + 0.5) / 86400;
    nontrading, nontradingend = core.isnontrading(from, day_offset);
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - length * extent + 0.5) / 86400;
    end
    return loadFrom, from;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;
    local stream = streams[cookie];
    if stream == nil then
        return ;
    end
    stream.loading = false;
    period = dummy:getBookmark(1);
    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end


-- find the date in the stream using binary search algo.
function findDateFast(stream, date, precise)
    local datesec = nil;
    local periodsec = nil;
    local min, max, mid;

    datesec = math.floor(date * 86400 + 0.5)

    min = 0;
    max = stream:size() - 1;

    if max < 1 then
        return -1;
    end

    while true do
        mid = math.floor((min + max) / 2);
        periodsec = math.floor(stream:date(mid) * 86400 + 0.5);
        if datesec == periodsec then
            return mid;
        elseif datesec > periodsec then
            min = mid + 1;
        else
            max = mid - 1;
        end
        if min > max then
            if precise then
                return -1;
            else
                return min - 1;
            end
        end
    end
end


