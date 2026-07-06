-- Id: 25206
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=68537

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------+
--|                                  Patreon : https://goo.gl/GdXWeN |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Calculates session range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("Start", "Session Start", "", "08:00:00");
    indicator.parameters:addString("End", "Session End", "", "17:00:00");

    indicator.parameters:addColor("line_color", "Line Color", "Line Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("line_width", "Line Width", "Line Width", 1, 1, 5);
    indicator.parameters:addInteger("line_style", "Line Style", "Line Style", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style", core.FLAG_LINE_STYLE);
end

-- Parameters block
local first;
local source = nil;
local host;
local day_offset, week_offset;
local pipsize;
local session;
-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if (nameOnly) then
        return;
    end
	
    source = instance.source;
    pipsize = source:pipSize();
    first = source:first();
    host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    session = CreateSession();
end

local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

    self.items[id] = core.host:execute("getSyncHistory", source:instrument(), tf, source:isBid(), 100, ids.loaded_id, ids.loading_id)
    return self.items[id];
end
function sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
	for index, ids in pairs(self.ids) do
		if ids.loaded_id == cookie then
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
			ids.loaded = false
			self.allLoaded = false
			return false
		end
	end
	return false
end
function sources:IsAllLoaded()
	if self.allLoaded == nil then
		for index, ids in pairs(self.ids) do
			if not ids.loaded then
				self.allLoaded = false
				return false
			end
		end
		self.allLoaded = true
	end
	return self.allLoaded
end

function Update(period)
    if not sources:IsAllLoaded() then
        return;
    end
    Process(session, period);
end

function CalculateSessionDats(session, date)
    -- 1) calculate the session to which the specified date belongs
    local sfrom = math.floor(date * 86400 + 0.5);     -- date/time in seconds
    -- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
    sfrom = sfrom - session.from * 86400;
    -- truncate to the day only.
    sfrom = math.floor(sfrom / 86400 + 0.5) * 86400;
    -- and shift it back to est time zone
    sfrom = (sfrom + session.from * 86400) / 86400;
    if date < sfrom then
        sfrom = sfrom - 1;
    end
    
    local sto = sfrom + session.len;   -- end of the session
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

-- Process the specified session
function Process(session, period)
    if session == nil then
        return ;
    end
    -- find the start of the session
    local date = source:date(period);       -- bar date;
    local sfrom, sto, sto_eod = CalculateSessionDats(session, date);
    -- process only if the date/time is inside the session
    local from_period = core.findDate(session.source, sfrom, false);
    local to_period = core.findDate(session.source, sto, false);
    if to_period == -1 or from_period == -1 then
        return ;
    end
    local lo, hi = mathex.minmax(session.source, from_period, to_period);
    if hi == 0 then
        return;
    end
    session.stream[period] = (hi - lo) / session.source:pipSize();
end

function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

function GetBestTimeframe(date)
    local table = core.dateToTable(date);
    local total_minutes = table.hour * 60 + table.min;

    if TF == "D1" or TF == "W1" or TF == "M1" then
        if TF == "W1" or TF == "M1" then
            day_shift = instance.parameters.day_shift;
        end
        if total_minutes == 0 then
            return TF;
        elseif total_minutes % 60 == 0 then
            return "H1";
        elseif total_minutes % 30 == 0 then
            return "m30";
        elseif total_minutes % 15 == 0 then
            return "m15";
        elseif total_minutes % 5 == 0 then
            return "m5";
        end
    elseif TF == "H1" then
        if total_minutes % 60 == 0 then
            return "H1";
        elseif total_minutes % 30 == 0 then
            return "m30";
        elseif total_minutes % 15 == 0 then
            return "m15";
        elseif total_minutes % 5 == 0 then
            return "m5";
        end
    end
    return "m1";
end

function GetSource(id, tf)
    if source:barSize() == tf then
        return source;
    end
    return sources:Request(id, source, tf);
end

-- Create the session description
function CreateSession()
    from_str = instance.parameters:getString("Start");
    to_str = instance.parameters:getString("End");

    from, valid = ParseTime(from_str);
    assert(valid, "Time " .. from_str .. " is invalid");
    to, valid = ParseTime(to_str);
    assert(valid, "Time " .. to_str .. " is invalid");

    local tf_start = GetBestTimeframe(from);
    local tf_stop = GetBestTimeframe(to);
    local s, e = core.getcandle(tf_start, 0, 0, 0);
    local tf1_length = e - s;
    s, e = core.getcandle(tf_stop, 0, 0, 0);
    local tf2_length = e - s;
    local tf = tf_stop;
    if tf1_length < tf2_length then
        tf = tf_start;
    end

    local session = {};
    session.id = 1;
    session.stream = instance:addStream("Range", core.Line, "Range", "Range", instance.parameters.line_color, 0, 0);
    session.stream:setPrecision(math.max(2, instance.source:getPrecision()));
    session.stream:setWidth(instance.parameters.line_width);
    session.stream:setStyle(instance.parameters.line_style);
    session.source = GetSource("1", tf);
    session.from = from;
    if from < to then
        session.len = to - from;
    else
        session.len = to - from + 1;
    end
    return session;
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) and sources:IsAllLoaded() then
        instance:updateFrom(0);
    end
end
