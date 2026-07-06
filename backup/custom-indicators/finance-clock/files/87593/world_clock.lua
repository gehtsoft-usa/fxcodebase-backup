-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58432
-- Id: 9575

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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

function Init()
    indicator:name("");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    local tzs = loadTimeZones();

    indicator.parameters:addGroup("Watch set settings");
    addClockParams(1, tzs, "New York", "Eastern Standard Time");
    addClockParams(2, tzs, "London", "GMT Standard Time");
    addClockParams(3, tzs, "Moscow", "Russian Standard Time");
    addClockParams(4, tzs, "Hong Kong", "China Standard Time");
    addClockParams(5, tzs, "Tokyo", "Tokyo Standard Time");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("clockGap", "A gap (px)", "A gap around the clock in pixels", 20, 0, 200);
    indicator.parameters:addInteger("clockSize", "Clock Size (px)", "The size of one clock in the pixels", 100, 20, 500);
    indicator.parameters:addColor("clockShape", "The clock shape color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("clockBg", "The clock background color", "", core.rgb(255, 255, 255));
    indicator.parameters:addColor("clockHands", "The clock handls color", "", core.rgb(0, 0, 0));
    indicator.parameters:addInteger("clockFontSize", "Labels font size", "", 6, 4, 32);
    indicator.parameters:addColor("clockFontColor", "Labels color", "", core.COLOR_LABEL);
    indicator.parameters:addBoolean("clockDigital", "Show date/time under the clocks", "", true);
end

function loadTimeZones()
    local tzs = win32.getTimeZonesList();
    local out = {};
    local i;
    for i = 1, #tzs, 1 do
        local name = win32.getRegistry("HKLM Software\\Microsoft\\Windows NT\\CurrentVersion\\Time Zones\\" .. tzs[i], "Display");
        out[i] = {};
        out[i].id = tzs[i];
        out[i].name = name;
    end

    table.sort(out, function (a, b) return a.name < b.name end);
    return out;
end

function addClockParams(id, tzs, label, tz)
    indicator.parameters:addString("L" .. id, "Clock " .. id .. " label", "", label);
    indicator.parameters:addString("TZ" .. id, "Clock " .. id .. " timezone", "", tz);
    local i;
    for i = 1, #tzs, 1 do
        indicator.parameters:addStringAlternative("TZ" .. id, tzs[i].name, "", tzs[i].id);
    end
end

local clockSize, clockBg, clockHands, clockDigital, clockFontSize, clockFontColor, clockGap, clockShape;
local clockCount = 0;
local clocks = {};
local timer;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    first = source:first();
    local name = profile:id();
    instance:name(name);
    if onlyName then
        return ;
    end

    clockCount = 5;
    for i = 1, 5, 1 do
        clocks[i] = {};
        clocks[i].label = instance.parameters["L" .. i];
        clocks[i].tz = win32.getTimeZone(instance.parameters["TZ" .. i]);
        clocks[i].hour = -1;
        clocks[i].minute = -1;
    end

    clockGap = instance.parameters.clockGap;
    clockShape = instance.parameters.clockShape;
    clockSize = instance.parameters.clockSize;
    clockBg = instance.parameters.clockBg;
    clockHands = instance.parameters.clockHands;
    clockDigital = instance.parameters.clockDigital;
    clockFontSize = instance.parameters.clockFontSize;
    clockFontColor = instance.parameters.clockFontColor;

    instance:setLabelColor(clockBg);
    timer = core.host:execute("setTimer", 1, 1);

    instance:ownerDrawn(true);
end

function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
    local redraw = false;
    if cookie == 1 then
        local time = now();
        local i;

        for i = 1, clockCount, 1 do
            local clock = clocks[i];
            clock.time = win32.convertUTCToTimeZone(clock.tz, time);
            local t = core.dateToTable(clock.time);
            if clock.hour ~= t.hour or
               clock.minute ~= t.min then
                redraw = true;
            end
            clock.hour = t.hour;
            clock.minute = t.min;
            if clockDigital then
                clock.sdate = win32.formatDate(clock.time, win32.SHORT, win32.NONE);
                clock.stime = win32.formatDate(clock.time, win32.NONE, win32.SHORT);
            end
        end
    end
    if redraw then
        return core.ASYNC_REDRAW;
    else
        return 0;
    end
end

function now()
    if __debug__hook ~= nil then
        return core.host:execute("convertTime", core.TZ_EST, core.TZ_UTC, core.now());
    else
        return win32.currentTimeUTC();
    end
end


local drawInit = false;
local fontHeight, tstyle;

function Draw(stage, context)
    if stage == 2 then
        if not drawInit then
            fontHeight = context:pointsToPixels(clockFontSize);
            context:createFont(1, "Arial", 0, fontHeight, 0);
            context:createPen(2, context.SOLID, 1, clockHands);
            context:createPen(3, context.SOLID, 3, clockHands);
            context:createPen(4, context.SOLID, 1, clockShape);
            context:createSolidBrush(5, clockBg);
            tstyle = context.VCENTER + context.SINGLELINE + context.CENTER;
            drawInit = true;
        end

        local i;
        for i = 1, clockCount, 1 do
            local clock = clocks[i];
            if clock.hour >= 0 then
                local xCell, yCell, xWidth;
                local x1, y1, x2, y2, x, y;
                xWidth = clockGap * 2 + clockSize;
                xCell = xWidth * (i - 1);
                yCell = clockGap;

                -- draw label
                context:drawText(1, clock.label, clockFontColor, -1, xCell, yCell, xCell + xWidth, yCell + fontHeight, tstyle);


                -- draw clocks
                x1 = xCell + clockGap;
                x2 = x1 + clockSize;
                y1 = yCell + fontHeight;
                y2 = y1 + clockSize;
                x = (x1 + x2) / 2;
                y = (y1 + y2) / 2;
                context:drawEllipse(4, 5, x1, y1, x2, y2);

                local r = clockSize / 2;
                local hx, hy, mx, my;
                for i = 0, 11, 1 do
                    hx, hy = math2d.polarToCartesian(r, toAngle(i, 12));
                    mx, my = math2d.polarToCartesian(r * 0.9, toAngle(i, 12));
                    hx = hx + x;
                    hy = hy + y;
                    mx = mx + x;
                    my = my + y;
                    context:drawLine(2, mx, my, hx, hy);
                end

                -- draw hands
                hx, hy = math2d.polarToCartesian(r / 2, toAngle(clock.hour % 12 + clock.minute / 60, 12));
                mx, my = math2d.polarToCartesian(r * 3 / 4, toAngle(clock.minute, 60));
                hx = hx + x;
                hy = hy + y;
                mx = mx + x;
                my = my + y;
                context:drawLine(3, x, y, hx, hy);
                context:drawLine(2, x, y, mx, my);

                if clockDigital then
                    context:drawText(1, clock.sdate, clockFontColor, -1, xCell, y2, xCell + xWidth, y2 + fontHeight, tstyle);
                    context:drawText(1, clock.stime, clockFontColor, -1, xCell, y2 + fontHeight, xCell + xWidth, y2 + fontHeight * 2, tstyle);
                end
            end
        end
        i = 0;
    end
end

function toAngle(value, totalValues)
    return value / totalValues * 2 * math.pi - math.pi / 2;
end

function ReleaseInstance()
    core.host:execute("killTimer", timer);
end