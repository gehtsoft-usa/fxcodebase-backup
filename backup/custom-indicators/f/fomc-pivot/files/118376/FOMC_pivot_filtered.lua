
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
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
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
local day_offset, week_offset;
local color_highlighted;
local width_highlighted;
local style_highlighted;

local meetings = {};

function AddMeetingDate(year, month_start, day_start, month_end, day_end)
    local meeting = {};
    meeting.Start = core.date(year, month_start, day_start);
    meeting.End = core.date(year, month_end, day_end);
    meetings[#meetings + 1] = meeting;
end

function FillMeetingsList()
    AddMeetingDate(2013, 09, 17, 09, 18);
    AddMeetingDate(2013, 10, 29, 10, 30);
    AddMeetingDate(2013, 12, 17, 12, 18);

    AddMeetingDate(2014, 10, 28, 10, 29);
    AddMeetingDate(2014, 12, 16, 12, 17);

    AddMeetingDate(2015, 04, 28, 04, 29);
    AddMeetingDate(2015, 06, 16, 06, 17);
    AddMeetingDate(2015, 09, 16, 09, 17);
    AddMeetingDate(2015, 12, 15, 12, 16);

    AddMeetingDate(2016, 03, 15, 03, 16);
    AddMeetingDate(2016, 06, 14, 06, 15);
    AddMeetingDate(2016, 09, 20, 09, 21);
    AddMeetingDate(2016, 12, 13, 12, 14);

    AddMeetingDate(2017, 01, 31, 02, 01);
    AddMeetingDate(2017, 05, 02, 05, 03);
    AddMeetingDate(2017, 06, 13, 06, 14);
    AddMeetingDate(2017, 07, 25, 07, 26);
    AddMeetingDate(2017, 09, 19, 09, 20);
    AddMeetingDate(2017, 12, 12, 12, 13);
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

    FillMeetingsList();

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
end