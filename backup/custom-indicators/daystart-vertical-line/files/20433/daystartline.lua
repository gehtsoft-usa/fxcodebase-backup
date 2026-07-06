function Init()
    indicator:name("Day Start Line");
    indicator:description("The indicator draws a vertical line at the specified time");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("hour", "Hour (EST)", "Hour at start of which the line must be drawn", 17, 0, 23);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local source;
local dummy, host;
local hour, clr, width, style;
local canwork, error;

function Prepare(onlyname)
    source = instance.source;
    clr = instance.parameters.clr;
    width = instance.parameters.width;
    style = instance.parameters.style;
    hour = instance.parameters.hour;
    host = core.host;

    local s, e = core.getcandle(source:barSize(), 0, host:execute("getTradingDayOffset"), 0);
    canwork = not(math.floor(e - s) >= 1);

    if not canwork then
        errtext = "The indicator must be applied on intraday charts";
        if onlyname then
            assert(false, errtext);
        else
            core.host:execute("setStatus", "error:" .. errtext);
        end
    end

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. hour .. ")";
    instance:name(name);

    if onlyname then
        return ;
    end


    dummy = instance:addStream("D", core.Line, name .. ".D", "D", clr, 0);
end

local last_s = nil;
local id = 0;

function Update(period, mode)
    if not canwork then
        return ;
    end

    -- calculation restarted
    if period == 0 then
        host:execute("removeAll");
        id = 0;
    end

    local s = source:serial(period);

    if last_s ~= nil and s == last_s then
        return ;
    end

    last_s = s;

    local date = source:date(period);
    local t = core.dateToTable(date);
    if t.min == 0 and t.hour == hour then
        id = id + 1;
        host:execute("drawLine", id, date, 0, date, 100000, clr, style, width, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
    end
end



