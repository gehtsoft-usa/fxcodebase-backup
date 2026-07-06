-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1974

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+


function Init()
    indicator:name("The indicator highlights trade sessions");
    indicator:description("The indicator can be applied on 1-minute to 1-hour charts");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("New York Sessions");
    indicator.parameters:addBoolean("NY_S", "Show New York session", "", true);
    indicator.parameters:addBoolean("NY_L", "Show New York session labels", "", true);	
	indicator.parameters:addInteger("NY_Shift", "New York session Shift", "", 8);
    indicator.parameters:addBoolean("NY_show_median_line", "Show New York median line", "", false);
    indicator.parameters:addBoolean("NY_extend", "Extend New York to EOD", "", false);
    indicator.parameters:addColor("NY_C", "New York session color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("London Sessions");
    indicator.parameters:addBoolean("LO_S", "Show London session (3:00 am - 12:00 pm EST/EDT)", "", true);
    indicator.parameters:addBoolean("LO_L", "Show London session labels", "", true);
	indicator.parameters:addInteger("LO_Shift", "London session Shift", "", 3);
    indicator.parameters:addBoolean("LO_show_median_line", "Show London median line", "", false);
    indicator.parameters:addBoolean("LO_extend", "Extend London to EOD", "", false);
    indicator.parameters:addColor("LO_C", "London session color", "", core.rgb(0, 255, 0));
	
	indicator.parameters:addGroup("Tokyo Sessions");
    indicator.parameters:addBoolean("TO_S", "Show Tokyo session", "", true);
    indicator.parameters:addBoolean("TO_L", "Show Tokyo session labels", "", true);	
	indicator.parameters:addInteger("TO_Shift", "Tokyo session Shift", "", -5);
    indicator.parameters:addBoolean("TO_show_median_line", "Show Tokyo median line", "", false);
    indicator.parameters:addBoolean("TO_extend", "Extend Tokyo to EOD", "", false);
    indicator.parameters:addColor("TO_C", "Tokyo session color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("Sydney Sessions");
    indicator.parameters:addBoolean("SY_S", "Show Sydney session", "", true);
    indicator.parameters:addBoolean("SY_L", "Show Sydney session labels", "", true);
	indicator.parameters:addInteger("SY_Shift", "Sydney session Shift", "", -7);
    indicator.parameters:addBoolean("SY_show_median_line", "Show Sydney median line", "", false);
    indicator.parameters:addBoolean("SY_extend", "Extend Sydney to EOD", "", false);
    indicator.parameters:addColor("SY_C", "Sydney session color", "", core.rgb(0, 255, 255));
    
    indicator.parameters:addGroup("Data To Show");
    indicator.parameters:addBoolean("S_N", "Show session name", "", true);
    indicator.parameters:addBoolean("S_TT", "Show data in tooltip", "", false);
    indicator.parameters:addBoolean("S_H", "Show session high", "", true);
    indicator.parameters:addBoolean("S_L", "Show session low", "", true);
    indicator.parameters:addBoolean("S_OD", "Show distance to open", "", true);
    indicator.parameters:addBoolean("S_OH", "Show distance between high/low", "", true);
    indicator.parameters:addGroup("Grid Lines");
    indicator.parameters:addInteger("SM_STYLE", "Mid line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SM_STYLE", core.FLAG_LINE_STYLE);

    indicator.parameters:addBoolean("S_SE", "Show start/end line", "", false);
    indicator.parameters:addInteger("SE_STYLE", "Start/end line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SE_STYLE", core.FLAG_LINE_STYLE);

    indicator.parameters:addBoolean("S_TR", "Show triangulation", "", false);
    indicator.parameters:addInteger("TR_STYLE", "Triangulation line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("TR_STYLE", core.FLAG_LINE_STYLE);
    indicator.parameters:addGroup("Styles");
    indicator.parameters:addInteger("HL", "Highlight transparency (%)", "", 95, 0, 100);
    indicator.parameters:addInteger("STYLE", "Session Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("STYLE", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("FS", "Font Size", "", 6, 4, 24);

    indicator.parameters:addBoolean("show_at_top", "Show at top of the chart", "", false);
end

-- Parameters block
local NY_Shift,LO_Shift,TO_Shift,SY_Shift;
local first;
local source = nil;
local host;
local new_york = nil;
local london = nil;
local tokyo = nil;
local sydney = nil;
local dummy = nil;
local day_offset, week_offset;
local pipsize;
local S_N, S_H, S_L, S_OD, S_OH, S_TT;
local S_SE, S_TR;
local barsize;
local SM_STYLE, SE_STYLE, TR_STYLE;
local show_at_top;

-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if   (nameOnly) then
        return;
    end
	
    show_at_top = instance.parameters.show_at_top;
    if show_at_top then
        instance:ownerDrawn(true);
    end
    source = instance.source;
	NY_Shift = instance.parameters.NY_Shift;
	LO_Shift = instance.parameters.LO_Shift;
	TO_Shift = instance.parameters.TO_Shift;
	SY_Shift = instance.parameters.SY_Shift;
    pipsize = source:pipSize();
    first = source:first();
    host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    S_N = instance.parameters.S_N;
    S_TT = instance.parameters.S_TT;
    S_H = instance.parameters.S_H;
    S_L = instance.parameters.S_L;
    S_OD = instance.parameters.S_OD;
    S_OH = instance.parameters.S_OH;
    S_SE = instance.parameters.S_SE;
    S_TR = instance.parameters.S_TR;
    SM_STYLE = instance.parameters.SM_STYLE;
    SE_STYLE = instance.parameters.SE_STYLE;
    TR_STYLE = instance.parameters.TR_STYLE;

    local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
    s = math.floor(s * 86400 + 0.5);  -- >>in seconds
    e = math.floor(e * 86400 + 0.5);  -- >>in seconds
    assert((e - s) <= 3600, "The source time frame must not be bigger than 1 hour");
    barsize = (e - s) / 86400;

     if instance.parameters.NY_S then
        -- 8 am to 5 pm
        new_york = CreateSession(NY_Shift
            , 9
            , instance.parameters.NY_C
            , "NY"
            , name
            , instance.parameters.NY_L
            , instance.parameters.NY_show_median_line
            , instance.parameters.NY_extend);
    end
    if instance.parameters.LO_S then
        -- 3 am to 12 pm
        london = CreateSession(LO_Shift
            , 9
            , instance.parameters.LO_C
            , "Lon"
            , name
            , instance.parameters.LO_L
            , instance.parameters.LO_show_median_line
            , instance.parameters.LO_extend);
    end
    if instance.parameters.TO_S then
        -- 7 pm of yesterday to 4 am of today
        tokyo = CreateSession(TO_Shift
            , 9
            , instance.parameters.TO_C
            , "Tok"
            , name
            , instance.parameters.TO_L
            , instance.parameters.TO_show_median_line
            , instance.parameters.TO_extend);
    end
    if instance.parameters.SY_S then
        -- 5 pm of yesterday to 2 am of today
        sydney = CreateSession(SY_Shift
            , 9
            , instance.parameters.SY_C
            , "Syd"
            , name
            , instance.parameters.SY_L
            , instance.parameters.SY_show_median_line
            , instance.parameters.SY_extend);
    end

    dummy = instance:addInternalStream(0, 0);   -- the stream for bookmarking
end

local ref = nil;    -- the reference 1-hour source

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

local init = false;
local transparency;
function CreateObjects(context, session)
    if session == nil then
        return;
    end
    context:createPen(session.pen_id, context.SOLID, 1, session.color);
    context:createSolidBrush(session.brush_id, session.color)
end
function DrawSession(context, session)
    if session == nil then
        return;
    end
    local from_bar = math.max(source:first(), context:firstBar());
    local to_bar = math.min(context:lastBar(), source:size() - 1);
    local start_x = nil;
    local last_x;
    for i = from_bar, to_bar, 1 do
        local x_center, x_left, x_right = context:positionOfBar(i);
        local barDate = source:date(i);
        local from, to, to_eod = CalculateSessionDats(session, barDate);
        if barDate >= from and barDate < to_eod then
            if start_x == nil then
                start_x = x_left;
            end
        else
            if start_x ~= nil then
                context:drawRectangle(session.pen_id, session.brush_id, start_x, context:top(), last_x, context:top() + 10, transparency);
                start_x = nil;
            end
        end
        last_x = x_right;
    end
    if start_x ~= nil then
        context:drawRectangle(session.pen_id, session.brush_id, start_x, context:top(), last_x, context:top() + 10, transparency);
        start_x = nil;
    end
end
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        CreateObjects(context, new_york);
        CreateObjects(context, london);
        CreateObjects(context, tokyo);
        CreateObjects(context, sydney);
        transparency = instance.parameters.HL / 100 * 255;
    end
    DrawSession(context, new_york);
    DrawSession(context, london);
    DrawSession(context, tokyo);
    DrawSession(context, sydney);
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        if ref == nil then
            ref = registerStream(0, "H1", 24);  -- open 1-hour stream which returns 24 bars BEFORE the start of the source collection.
        end
    end
	
	if not ref:hasData(ref:size()-1) then
	return;
	end

    Process(new_york, period);
    Process(london, period);
    Process(tokyo, period);
    Process(sydney, period);
end

function CalculateSessionDats(session, date)
    -- 1) calculate the session to which the specified date belongs
    local sfrom = math.floor(date * 86400 + 0.5);     -- date/time in seconds
    -- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
    sfrom = sfrom - session.from * 3600;
    -- truncate to the day only.
    sfrom = math.floor(sfrom / 86400 + 0.5) * 86400;
    -- and shift it back to est time zone
    sfrom = (sfrom + session.from * 3600) / 86400;
    if date < sfrom then
        sfrom = sfrom - 1;
    end
    
    local sto = sfrom + session.len / 24;   -- end of the session
    local sto_eof = sto;
    if session.extend then
        local ts_time_eof = math.floor(core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, sto_eof) + 1);
        sto_eof = core.host:execute("convertTime", core.TZ_TS, core.TZ_EST, ts_time_eof);
        if sto_eof > sfrom + 1 then
            sto_eof = sfrom + 1;
        end
    end
    return sfrom, sto, sto_eof;
end

function CalculateHighLow(ref, ref_period, sfrom, sto)
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
    return hi, lo;
end

function SetHighLow(session, period, hi, lo, sfrom)
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

-- Process the specified session
function Process(session, period)
    if session == nil then
        return ;
    end
    -- find the start of the session
    local date = source:date(period);       -- bar date;
    local sfrom, sto, sto_eod = CalculateSessionDats(session, date);
    -- process only if the date/time is inside the session
    if date >= sfrom and date < sto_eod then
        -- find the hour bar of the beginning of the day
        local ref_period, loading = getDate(0, sfrom, false, period);
        if ref_period == -1 then
            -- the first bar is not found at all
            -- or the date is being loaded
            return ;
        end
        local hi, lo = CalculateHighLow(ref, ref_period, sfrom, sto);
        if date == sfrom then
            session.high:setBookmark(session.id, period);
        end

        if hi ~= 0 then
            SetHighLow(session, period, hi, lo, sfrom);

            local t = session.high:getBookmark(session.id);
            local namesuffix = "";
            if t >= 0 and t <= period and session.labels then
                local open = source.open[t];
                local hl, ll;
                local cc = 0;
                if S_H or S_OH or S_OD then
                    hl = "";
                    if S_H then
                        hl = hl .. hi;
                        namesuffix = namesuffix .. "\013\010";
                        cc = cc + 1;
                    end
                    if S_OD then
                        if cc > 0 then
                            hl = hl .. "\013\010";
                        end
                        cc = cc + 1;
                        hl = hl .. "(O " .. math.floor((hi - open) / pipsize * 10 + 0.5) / 10 .. ")";
                        namesuffix = namesuffix .. "\013\010";
                    end
                    if S_OH then
                        if cc > 0 then
                            hl = hl .. "\013\010";
                        end
                        cc = cc + 1;
                        hl = hl .. "(L " .. math.floor((hi - lo) / pipsize * 10 + 0.5) / 10 .. ")";
                        namesuffix = namesuffix .. "\013\010";
                    end
                    if not(S_TT) then
                        session.LH:set(t, hi, hl);
                    end
                end
                cc = 0;
                if S_L or S_OD then
                    ll = "";
                    if S_L then
                        ll = ll .. lo;
                        cc = cc + 1;
                    end
                    if S_OD then
                        if cc > 0 then
                            ll = ll .. "\013\010";
                        end
                        cc = cc + 1;
                        ll = ll .. "(O " .. math.floor((lo - open) / pipsize * 10 + 0.5) / 10 .. ")";
                    end
                    if not(S_TT) then
                        session.LL:set(t, lo, ll);
                    end
                end
                if S_N then
                    if S_TT then
                        session.LN:set(t, hi, session.name, hl .. "\013\010" .. ll);
                    else
                        session.LN:set(t, hi, session.name .. namesuffix);
                    end
                end
            end

            if (S_SE or S_TR or session.show_median_line) and t >= 0 and t <= period then
                local baseid = math.floor(session.begin[period] * 24 + 0.5) * 30;
                local open = source.open[t];
                local close = source.close[period];
                local date_from = source:date(t);
                local date_to;

                if period ~= source:size() - 1 then
                    date_to = source:date(period + 1);
                else
                    date_to = source:date(period) + barsize;
                end

                if S_TR then
                    -- find highs and lows
                    -- use previously found high and low to reduce number of searches
                    local prior_hi = session.high:getBookmark(session.id + 1);
                    local prior_lo = session.high:getBookmark(session.id + 2);

                    if prior_hi < t or prior_hi >= period then
                        prior_hi = t;
                    end

                    if prior_lo < t or prior_lo >= period then
                        prior_lo = t;
                    end

                    local range, price, pos;
                    if hi ~= source.high[prior_hi] then
                        range = core.range(prior_hi, period);
                        price, pos = core.max(source.high, range);
                        session.high:setBookmark(session.id + 1, pos);
                    else
                        pos = prior_hi;
                    end

                    if pos ~= source:size() - 1 then
                        prior_hi = source:date(pos + 1);
                    else
                        prior_hi = source:date(pos) + barsize;
                    end

                    if lo ~= source.low[prior_lo] then
                        range = core.range(prior_lo, period);
                        price, pos = core.min(source.low, range);
                        session.high:setBookmark(session.id + 2, pos);
                    else
                        pos = prior_lo;
                    end

                    if pos ~= source:size() - 1 then
                        prior_lo = source:date(pos + 1);
                    else
                        prior_lo = source:date(pos) + barsize;
                    end

                    host:execute("drawLine", baseid + 0, date_from, open, prior_hi, hi, session.color, TR_STYLE);
                    host:execute("drawLine", baseid + 1, date_from, open, prior_lo, lo, session.color, TR_STYLE);
                    host:execute("drawLine", baseid + 2, prior_hi, hi, prior_lo, lo, session.color, TR_STYLE);
                    host:execute("drawLine", baseid + 3, prior_hi, hi, date_to, close, session.color, TR_STYLE);
                    host:execute("drawLine", baseid + 4, prior_lo, lo, date_to, close, session.color, TR_STYLE);
                end

                if S_SE then
                    host:execute("drawLine", baseid + 10, date_from, open, date_to, close, session.color, SE_STYLE);
                end

                if session.show_median_line then
                    host:execute("drawLine", baseid + 11, date_from, (hi + lo) / 2, date_to, (hi + lo) / 2, session.color, SM_STYLE);
                end
            end
        end
    else
        session.begin[period] = 0;
    end
end

local gId = 1;

-- Create the session description
-- from - the offset in hours again 0:00 of the EST canlendar day
-- len - length of the session in hours
-- color - color for lines and fill area
-- name - of the session
-- iname - the name of the indicator
function CreateSession(from, len, color, name, iname, labels, show_median_line, extend)
    local session = {};
    local n;
    session.pen_id = gId + 1;
    session.brush_id = gId + 2;
    session.show_median_line = show_median_line;
    session.extend = extend;
    session.id = gId;
    gId = gId + 10;
    session.labels = labels;
    session.name = name;
    session.from = from;
    session.color = color;
    session.len = len;
    n = name .. "_H";
    session.high = instance:addStream(n, core.Line, iname .. "." .. n, name .. "H", color, first);
    session.high:setStyle(instance.parameters.STYLE);
    session.highband = instance:addInternalStream(first, 0);
    
    n = name .. "_L";
    session.low = instance:addStream(n, core.Line, iname .. "." .. n, name .. "L", color, first);
    session.low:setStyle(instance.parameters.STYLE);
    session.lowband = instance:addInternalStream(first, 0);
    session.begin = instance:addInternalStream(0, 0);
    instance:createChannelGroup(name, name, session.highband, session.lowband, color, 100 - instance.parameters.HL);
    if labels and (S_H or S_OH or S_OD) and not(S_TT) then
        session.LH = instance:createTextOutput("", name .. "_HL", "Arial", instance.parameters.FS, core.H_Right, core.V_Top, color, 0);
    end

    if labels and (S_L or S_OD) and not(S_TT) then
        session.LL = instance:createTextOutput("", name .. "_LL", "Arial", instance.parameters.FS, core.H_Right, core.V_Bottom, color, 0);
    end

    if labels and S_N then
        session.LN = instance:createTextOutput("", name .. "_LN", "Arial", instance.parameters.FS, core.H_Right, core.V_Top, color, 0);
    end
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


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+
