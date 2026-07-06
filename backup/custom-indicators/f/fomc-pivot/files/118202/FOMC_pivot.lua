
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65014

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
    indicator:name("FOMC Pivot");
    indicator:description("FOMC Pivot");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("label_color", "Label color", "", core.COLOR_LABEL);
    indicator.parameters:addColor("bg_color", "Label background", "", core.COLOR_BACKGROUND);
    indicator.parameters:addColor("color_highlighted", "Highlighted line color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width_highlighted", "Highlighted line width", "", 3, 1, 5);
    indicator.parameters:addInteger("style_highlighted", "Highlighted line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style_highlighted", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color", "Line color", "Line color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("max_lines", "Max lines", "", 15);
end

local color, width, style;
local label_color;
local bg_color;
local req;
local day_offset, week_offset;
local color_highlighted;
local width_highlighted;
local style_highlighted;

local meetings = {};

function GetYears(body)
    local years_data = {};
    local meeting_year = string.match(body, "(%d%d%d%d) FOMC Meetings");
    while (meeting_year ~= nil) do
        body = string.sub(body, string.find(body, meeting_year .. " FOMC Meetings") + 18);
        local next_meeting_year = string.match(body, "(%d%d%d%d) FOMC Meetings");
        if next_meeting_year == nil then
            years_data[meeting_year] = body;
        else
            years_data[meeting_year] = string.sub(body, 0, string.find(body, meeting_year .. " FOMC Meetings"));
        end
        meeting_year = next_meeting_year;
    end
    return years_data;
end

function GetMonthIndex(month)
    if month:find("Jan") == 1 then
        return 1;
    elseif month:find("Feb") == 1 then
        return 2;
    elseif month:find("Mar") == 1 then
        return 3;
    elseif month:find("Apr") == 1 then
        return 4;
    elseif month:find("May") == 1 then
        return 5;
    elseif month:find("Jun") == 1 then
        return 6;
    elseif month:find("Jul") == 1 then
        return 7;
    elseif month:find("Aug") == 1 then
        return 8;
    elseif month:find("Sep") == 1 then
        return 9;
    elseif month:find("Oct") == 1 then
        return 10;
    elseif month:find("Nov") == 1 then
        return 11;
    elseif month:find("Dec") == 1 then
        return 12;
    end
    return nil;
end

function AddMeetingDate(year, month, day)
    local meeting = {};
    local month_start;
    local month_end;
    local separator_index = month:find("/");
    if separator_index ~= nil then
        month_start = GetMonthIndex(month:sub(0, separator_index));
        month_end = GetMonthIndex(month:sub(separator_index + 1));
    else
        month_start = GetMonthIndex(month);
        month_end = month_start;
    end
    local day_start, day_end;
    if day:find("[-]") ~= nil then
        day_start, day_end = day:match("(%d+)[-](%d+)");
    else
        day_start = day:match("(%d+)");
        day_end = day_start; 
    end
    meeting.Start = core.date(year, month_start, day_start);
    meeting.End = core.date(year, month_end, day_end);
    meetings[#meetings + 1] = meeting;
end

function AddMeetingDates(year, year_data)
    local index = string.find(year_data, "fomc[-]meeting__month");
    if (index == nil) then
        return;
    end
    year_data = string.sub(year_data, index);
    local meeting_month = string.match(year_data, "g>([^<]+)<");
    while (meeting_month ~= nil) do
        index = string.find(year_data, "fomc[-]meeting__date");
        year_data = string.sub(year_data, index);
        local meeting_day = string.match(year_data, ">([^<]+)<");
        AddMeetingDate(year, meeting_month, meeting_day);

        index = string.find(year_data, "fomc[-]meeting__month");
        if (index == nil) then
            return;
        end
        year_data = string.sub(year_data, index);
        meeting_month = string.match(year_data, "g>([^<]+)<");
    end
end

function FillMeetingsList()
    if req:loading() then
        return false;
    end
    
    if not(req:success()) then
        core.host:execute("setStatus", "Load failed");
        return true;
    end    
    
    if req:httpStatus() ~= 200 then
        core.host:execute("setStatus", "Load failed");
        return true;
    end

    core.host:execute("setStatus", "");
    local body = req:response();
    local years_data = GetYears(body);
    for year, data in pairs(years_data) do
        AddMeetingDates(year, data);
    end
    return true;
end

local timer;
local H1_data;
local labels;

function Prepare(onlyName)
    local name = profile:id();
    instance:name(name);
    if onlyName then
        return;
    end

    color = instance.parameters.color;
    width = instance.parameters.width;
    style = instance.parameters.style;
    color_highlighted = instance.parameters.color_highlighted;
    width_highlighted = instance.parameters.width_highlighted;
    style_highlighted = instance.parameters.style_highlighted;
    label_color = instance.parameters.label_color;
    bg_color = instance.parameters.bg_color;
    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");

    H1_data = core.host:execute("getSyncHistory", instance.source:instrument(), "H1", instance.source:isBid(), 300, 100, 101);

    require("http_lua");
    req = http_lua.createRequest();
    req:start("https://www.federalreserve.gov/monetarypolicy/fomccalendars.htm");
    core.host:execute("setStatus", "Loading FOMC calendar");
    timer = core.host:execute("setTimer", 1, 1);

    instance:ownerDrawn(true);
end

local main_pen = 1;
local highlighed_pen = 2;
local main_font = 3;
local init = false;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(main_pen, context:convertPenStyle(style), width, color);
        context:createPen(highlighed_pen, context:convertPenStyle(style_highlighted), width_highlighted, color_highlighted);
        context:createFont(main_font, "Arial", 0, context:pointsToPixels(10), context.NORMAL);
        init = true;
    end
    local count = 0;
    local last_period;
    local last_rate;
    for i = instance.source:size() - 1, 0, -1 do
        local rate, date = GetRate(instance.source:date(i));
        if rate ~= nil then
            if last_period == nil then
                last_period = i;
                last_rate = rate;
            elseif last_rate ~= rate then
                local s, e = core.getcandle("D1", instance.source:date(i + 1), day_offset, week_offset);
                local period = core.findDate(instance.source, e, false);
                local to_day_end_x = context:positionOfBar(period);
                
                local from_x = context:positionOfBar(i + 1);
                local _, y = context:pointOfPrice(last_rate);
                local DATA = core.dateToTable(date);
                local text = string.format("%02d/%02d/%d", DATA.day, DATA.month, DATA.year);
                local width, height = context:measureText(main_font, text, 0);
                context:drawText(main_font, text, label_color, bg_color, from_x, y - height, from_x + width, y, 0);
                context:drawLine(highlighed_pen, from_x, y, to_day_end_x, y);
                context:drawLine(main_pen, to_day_end_x, y, context:right(), y);

                count = count + 1;
                if count == instance.parameters.max_lines then
                    return;
                end

                last_period = i;
                last_rate = rate;
            end
        end
    end
end

function GetNearestDate(date)
    local max_date = nil;
    for _, meeting in ipairs(meetings) do
        local date_start = math.floor(meeting.Start) + 13.0 / 24.0;
        if date_start <= date then
            if max_date == nil or max_date < date_start then
                max_date = date_start;
            end
        end
    end
    return max_date;
end

function GetRate(date)
    local meeting_date = GetNearestDate(date);
    if meeting_date == nil then
        return nil;
    end
    local index = core.findDate(H1_data, meeting_date, false);
    if index < 0 then
        return nil;
    end
    return H1_data.open[index], meeting_date;
end

function Update(period, mode)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if FillMeetingsList() then
            core.host:execute("killTimer", timer);
        end
    end
end