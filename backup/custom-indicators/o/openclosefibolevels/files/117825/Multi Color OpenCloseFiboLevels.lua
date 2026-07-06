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

   -- indicator.parameters:addGroup("Label Style");
   -- indicator.parameters:addColor("label_color" , "Label Color", "", core.rgb(255, 255, 0));
end


-- --------------------------------------------------------------------
-- Indicator profile
-- --------------------------------------------------------------------


local levels = {};
local firstCall = true;
local source = nil;
local format;
--local point;
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
		level.style = instance.parameters:getInteger("style" .. i);
		level.width = instance.parameters:getInteger("width" .. i);
        level.show = instance.parameters:getBoolean("show" .. i);
		 level.color = instance.parameters:getColor("color" .. i);
        levels[i] = level;
    end

    format = "(%.3f:=%." .. source:getPrecision() .. "f)";
   -- point = instance:createTextOutput("Alert", "Alert", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.label_color, 0);
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
   
   indicator.parameters:addGroup(id.. ". Levels Style");
   indicator.parameters:addBoolean("show" .. id, "Show Level " .. id, "", show);
	
    indicator.parameters:addDouble("level" .. id, "Level " .. id, "", level);

	
	
	indicator.parameters:addColor("color" .. id, "Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width" .. id, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style" .. id, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style" .. id, core.FLAG_LINE_STYLE);
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
    pfrom = core.findDate(source, dateFrom, false);
    if pfrom < source:first() then
        pfrom = source:first();
    end
    pto = core.findDate(source, dateTo, false);
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
                              levels[i].color, levels[i].style, levels[i].width,
                              string.format(format, levels[i].price, p));
            core.host:execute("drawLine", i + 100, dateTo, p, source:date(source:size() - 1) + barSize * 100, p,
                              levels[i].color, levels[i].style, levels[i].width,
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
 
 -- NG: create a function to parse time
function ParseTime(time)
    local Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end
 