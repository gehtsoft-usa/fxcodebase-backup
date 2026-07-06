-- Development History
--
-- May 05, 2010 Initial version
-- Nov 05, 2010 PeriodBegin > BoxEnd are allowed
--

function Init()
    indicator:name("Breakout Highlight");
    indicator:description("The indicator detects and highlight periods and boxes for the breakout strategy");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("PeriodBegin", "The hour and minute when the period begins", "", "00:00");
    indicator.parameters:addString("PeriodEnd", "The hour and minute when the period ends", "", "05:30");
    indicator.parameters:addString("BoxEnd", "The hour and minute when the box ends", "", "23:00");
    indicator.parameters:addString("Type", "The time type", "", "TD");
    indicator.parameters:addStringAlternative("Type", "Local Time", "", "LT");
    indicator.parameters:addStringAlternative("Type", "EST Time", "", "EST");
    indicator.parameters:addStringAlternative("Type", "GMT Time", "", "GMT");
    indicator.parameters:addStringAlternative("Type", "Trading Day time", "", "TD");
    indicator.parameters:addBoolean("MSMode", "Marketscope mode", "Leave true for this parameter!", true);
    indicator.parameters:addColor("HighLowColor", "The High/Low Lines color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("PeriodColor", "The period highlight color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("PeriodTran", "The period highlight transparency", "", 90, 0, 100);
    indicator.parameters:addColor("BoxColor", "The box highlight color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("BoxTran", "The box transparency", "", 90, 0, 100);
end

local source;
local first;
local MSMode;

local H, L;         -- high/low lines
local PH, PL;       -- period band borders
local BH, BL;       -- box band borders

local PeriodBegin, PeriodEnd, BoxEnd;
local Type = 0;
local T_LT = 1;
local T_EST = 2;
local T_GMT = 3;
local T_TD = 4;
local day_offset;
local host;
local P = nil;

function Prepare()
    source = instance.source;
    first = source:first();

    MSMode = instance.parameters.MSMode;

    host = core.host;
    day_offset = host:execute("getTradingDayOffset");

    local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0);
    assert ((e - s) <= (1.0 / 24), "The time frame must be 1 hour or less");

    PeriodBegin = ParseTime(instance.parameters.PeriodBegin);
    PeriodEnd = ParseTime(instance.parameters.PeriodEnd);
    BoxEnd = ParseTime(instance.parameters.BoxEnd);

    if (PeriodBegin > BoxEnd) then
        PeriodBegin = PeriodBegin - 86400;
    end
    
    if (PeriodEnd > BoxEnd) then
        PeriodEnd = PeriodEnd - 86400;
    end;
    
    assert(PeriodBegin < PeriodEnd, "Period begin must be before the period end");
    assert(PeriodEnd < BoxEnd, "The period end must be before the period end");

    if instance.parameters.Type == "LT" then
        Type = T_LT;
    elseif instance.parameters.Type == "EST" then
        Type = T_EST;
    elseif instance.parameters.Type == "GMT" then
        Type = T_GMT;
    elseif instance.parameters.Type == "TD" then
        Type = T_TD;
    end

    assert(Type ~= 0, "The type is unknown");

    local name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.PeriodBegin .. "," .. instance.parameters.PeriodEnd .. "," .. instance.parameters.BoxEnd .. "," .. instance.parameters.Type .. ")";
    instance:name(name);
    if MSMode then
        PH = instance:addStream("PH", core.Line, name .. "." .. "PH", "PH", instance.parameters.PeriodColor, first);
        PL = instance:addStream("PL", core.Line, name .. "." .. "PL", "PL", instance.parameters.PeriodColor, first);
        instance:createChannelGroup("P", "P", PH, PL, instance.parameters.PeriodColor, 100 - instance.parameters.PeriodTran);
        BH = instance:addStream("BH", core.Line, name .. "." .. "BH", "BH", instance.parameters.BoxColor, first);
        BL = instance:addStream("BL", core.Line, name .. "." .. "BL", "BL", instance.parameters.BoxColor, first);
        instance:createChannelGroup("B", "P", BH, BL, instance.parameters.BoxColor, 100 - instance.parameters.BoxTran);
        P = instance:addInternalStream(0, 0);
    else
        PH = instance:addInternalStream(0, 0);
        PL = instance:addInternalStream(0, 0);
        BH = instance:addInternalStream(0, 0);
        BL = instance:addInternalStream(0, 0);
        P = instance:addStream("P", core.Line, name .. "." .. "P", "P", instance.parameters.HighLowColor, first);
    end
    H = instance:addStream("H", core.Line, name .. "." .. "H", "H", instance.parameters.HighLowColor, first);
    L = instance:addStream("L", core.Line, name .. "." .. "L", "L", instance.parameters.HighLowColor, first);
end

local ptime = "(%d%d?):(%d%d?)";

function ParseTime(time)
    local a, b;
    a, b = string.match(time, ptime);
    a = tonumber(a);
    b = tonumber(b);
    assert(a ~= nil, "Can't recognize the time:" .. time);
    assert (a >= 0 and a <= 23, "Hour must be between 0 and 23");
    assert (b >= 0 and b <= 59, "Minute must be between 0 and 59");
    return b * 60 + a * 60 * 60;    -- return number of second past...
end

local BE_NONE = 0;      -- belongs to period
local BE_PERIOD = 1;    -- belongs to period
local BE_BOX = 2;       -- belongs to box

function BelongsTo(time)
    -- calculate the number of seconds since...
    local t;

    if Type == T_TD then
        -- tranding day
        t = core.getcandle("D1", time, day_offset);
        t = math.floor((time - t) * 86400 + 0.5);
    elseif Type == T_EST then
        t = time - math.floor(time);    -- get only time
        t = math.floor(t * 86400 + 0.5);
    elseif Type == T_GMT then
        t = host:execute("convertTime", 1, 2, time);   -- EST->GMT
        t = t - math.floor(t);    -- get only time
        t = math.floor(t * 86400 + 0.5);
    elseif Type == T_LT then
        t = host:execute("convertTime", 1, 3, time);   -- EST->Local
        t = t - math.floor(t);    -- get only time
        t = math.floor(t * 86400 + 0.5);
    end

    if (PeriodBegin < 0 and t >= BoxEnd) then
        t = t - 86400;
    end
    
    if t >= PeriodBegin and t < PeriodEnd then
        return BE_PERIOD;
    elseif t >= PeriodEnd and t < BoxEnd then
        return BE_BOX;
    else
        return BE_NONE;
    end
end

function Update(period, mode)
    if period >= first then
        local curr, prior, i;
        if P:hasData(period - 1) then
            prior = P[period - 1];
        else
            prior = BE_NONE;
        end

        curr = BelongsTo(source:date(period));
        P[period] = curr;

        if curr == BE_NONE then
            return ;
        elseif curr == BE_BOX then
            if H:hasData(period - 1) then
                H[period] = H[period - 1];
                L[period] = L[period - 1];
                BH[period] = H[period - 1];
                BL[period] = L[period - 1];
            end
        elseif curr == BE_PERIOD then
            if prior ~= BE_PERIOD then
                P:setBookmark(1, period);
            end
            local p, h, l;
            p = P:getBookmark(1)
            l, h = core.minmax(source, core.range(p, period));
            if H:hasData(period - 1) and
               H[period - 1] == h and
               L:hasData(period - 1) and
               L[period - 1] == l then
                H[period] = h;
                L[period] = l;
                PH[period] = h;
                PL[period] = l;
            else
                for i = p, period, 1 do
                    H[i] = h;
                    L[i] = l;
                    PH[i] = h;
                    PL[i] = l;
                end
            end
        end
    end
end
