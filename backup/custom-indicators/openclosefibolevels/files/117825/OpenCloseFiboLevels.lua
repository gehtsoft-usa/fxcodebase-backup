-- Id: 20591
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65750

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Show Open/Close Fibonacci Levels");
    indicator:description("Indicator shows fibonacci levels between open and close prices of chosen period");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Lines");
    AddLevel(1, -0.618, false);
    AddLevel(2, -0.382, false);
    AddLevel(3, -0.272, false);
    AddLevel(4,  0.000, false);
    AddLevel(5,  0.236, false);
    AddLevel(6,  0.382, true);
    AddLevel(7,  0.500, true);
    AddLevel(8,  0.618, true);
    AddLevel(9,  0.764, false);
    AddLevel(10,  1.000, false);
    AddLevel(11,  1.272, false);
    AddLevel(12,  1.618, false);
    AddLevel(13,  2.618, false);
    AddLevel(14,  4.236, false);

    indicator.parameters:addGroup("Time Parameters");   
    indicator.parameters:addDate("FromDate", "Date from", "", -2);
    indicator.parameters:addString("FromTime", "Time from", "", "17:00:00");
    indicator.parameters:addDate("ToDate", "Date to", "", 0);
    indicator.parameters:addString("ToTime", "Time to", "", "00:00:00");

    indicator.parameters:addGroup("Levels Style");
    indicator.parameters:addColor("lcolor", "Period Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("lwidth", "Period Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("lstyle", "Period Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("lstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("ecolor", "Extension Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("ewidth", "Extension Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("estyle", "Extension Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("estyle", core.FLAG_LINE_STYLE);
end


-- --------------------------------------------------------------------
-- Indicator profile
-- --------------------------------------------------------------------


local levels = {};
local firstCall = true;
local source = nil;
local format;
local point;
local dummy;
local barSize;
local label;

local dateFrom = 0;
local dateTo = 0;

-- Overridable: prepare an instance
function Prepare(onlyName)
    local i;

    source = instance.source;

    instance:name(profile:id() .. "(" .. source:name() .. ")");

    if onlyName then
        return ;
    end

    local s, e;
    s, e = core.getcandle(source:barSize(), core.now(), 0);
    s = e - s;  -- length of candle in days
    barSize = s;

    for i = 1, 14, 1 do
        local level = {};
        level.price = instance.parameters:getDouble("level" .. i);
        level.show = instance.parameters:getBoolean("show" .. i);
        levels[i] = level;
    end

    format = "(%.3f:=%." .. source:getPrecision() .. "f)";
    point = instance:createTextOutput("Alert", "Alert", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.lcolor, 0);
    core.host:execute("addCommand", 1001, "Search Open/Clsoe From...", "");
    core.host:execute("addCommand", 1002, "Search Open/Close To...", "");
    core.host:execute("addCommand", 1003, "Reset dates", "");

    local timeFrom, valid = ParseTime(instance.parameters.FromTime);
    assert(valid, "Time " .. instance.parameters.FromTime .. " is invalid");

    local timeTo, valid = ParseTime(instance.parameters.ToTime);
    assert(valid, "Time " .. instance.parameters.ToTime .. " is invalid");
    
    dateFrom = instance.parameters.FromDate + timeFrom;
    --dateFrom = core.formatDate(dateFrom)
    
    dateTo = instance.parameters.ToDate + timeTo;
    --dateTo = core.formatDate(dateTo);
end


-- Overridable: update an instance
function Update(period, mode)
    local i;

    if period == source:size() - 1 then
        if firstCall and period > 50 then
            SetData(dateFrom, dateTo);
            firstCall = false;
        end
    end
end

-- Overridable: hook for commands
function AsyncOperationFinished(cookie, success, message)
    if cookie == 1001 then
        local from = dateFrom;
        local to = dateTo;

        from = Parse(message);
        if from ~= nil then
            SetData(from, to);
        end
    elseif cookie == 1002 then
        local from = dateFrom;
        local to = dateTo;

        to = Parse(message);
        if from ~= nil then
            SetData(from, to);
        end
    elseif cookie == 1003 then
        from = math.max(source:first(), source:size() - 51);
        to = source:size() - 1;
        SetData(source:date(from), source:date(to));
    end
end

-- --------------------------------------------------------------------
-- Utility functions
-- --------------------------------------------------------------------

-- add level to profile's parameters
function AddLevel(id, level, show)
    indicator.parameters:addDouble("level" .. id, "Level " .. id, "", level);
    indicator.parameters:addBoolean("show" .. id, "Show Level " .. id, "", show);
end

-- set from and to dates
function SetData(from, to)
    dateFrom = from;
    dateTo = to;
    if dateFrom > dateTo then
        local t;
        t = dateTo;
        dateTo = dateFrom;
        dateFrom = t;
    end

    -- remove all data
    core.host:execute("removeAll");

    local pfrom, pto;
    pfrom = findDateFast(source, dateFrom, false);
    if pfrom < source:first() then
        pfrom = source:first();
    end
    pto = findDateFast(source, dateTo, false);
    if pto < 0 then
        pto = source:size() - 1;
    end

    if pfrom > pto then
        return ;
    end

    local o = source.open[pfrom];
    local c = source.close[pto];    
    local d = c - o;

    for i = 1, 14, 1 do
        if levels[i].show then
            p = o + levels[i].price * d;
            core.host:execute("drawLine", i, dateFrom, p, dateTo, p,
                              instance.parameters.lcolor, instance.parameters.lstyle, instance.parameters.lwidth,
                              string.format(format, levels[i].price, p));
            core.host:execute("drawLine", i + 100, dateTo, p, source:date(source:size() - 1) + barSize * 100, p,
                              instance.parameters.ecolor, instance.parameters.estyle, instance.parameters.ewidth,
                              string.format(format, levels[i].price, p));
        end
    end
end

-- parse command message (date and price level)
local pattern = "([^;]*);([^;]*)";

function Parse(message)
    local level, date, period;
    level, date = string.match(message, pattern, 0);
    if level == nil then
        return nil;
    end
    return tonumber(date);
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
    return (h / 24.0 + m / 1440.0 + s / 86400.0),                          --time in ole format
            ((h >= 0 and h< 24 and m >= 0 and m< 60 and s >= 0 and s< 60) or(h == 24 and m == 0 and s == 0)); --validity flag
end

-- ------------------------------------------------------------------------------
-- Find the specified date in the specified stream
--
-- The function uses the binary search algorithm, so it requires only O(n) = log2(n) operations
-- to find (or to do not find) the value.
--
-- The function compares the date and time rounded to the whole seconds.
--
-- Parameters:
-- stream       The price stream to find the date in
-- date         Date and time value to be found
-- precise      The search mode
--              In case the value of the parameter is true, the function
--              Searches for the the exact date and returns not found in the
--              date is not found.
--              In case the value of the parameter is false, the function
--              returns the period with the biggest time value which is smaller
--              than the value of the date parameter.
-- Returns:
-- < 0          The value is not found
-- >= 0         The index of the the period in the stream
-- ----------------------------------------------------------------------------------

function findDateFast(stream, date, precise)
    local datesec = nil;
    local periodsec = nil;
    local min, max, mid;

    datesec = math.floor(date * 86400 + 0.5)

    min = 0;
    max = stream:size() - 1;

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

