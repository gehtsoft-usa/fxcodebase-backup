-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20384
-- Id: 7100

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
    indicator:name("Custom Daily Pivot");
    indicator:description("Daily Pivot with customizable day range. Can be applied at H1 or smaller charts only");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Support/Resistance");

    indicator.parameters:addGroup("Day Parameters");
    indicator.parameters:addInteger("HR", "The hour when the trading day starts", "", 17, 0, 23);
    indicator.parameters:addString("TZ", "Time zone", "The  of the time zone is recognized as a start of the trading day", "TZ_EST");
    indicator.parameters:addStringAlternative("TZ", "NY Time", "", "TZ_EST");
    indicator.parameters:addStringAlternative("TZ", "UTC Time", "", "TZ_UTC");
    indicator.parameters:addStringAlternative("TZ", "Local Time", "", "TZ_LOCAL");
    indicator.parameters:addStringAlternative("TZ", "Trading Day", "", "TZ_FINANCIAL");
    indicator.parameters:addInteger("MC", "Minimum candles in a day", "If the day has less candles than specified, then the previous day is taken as yesterday", 2, 1, 24);

    indicator.parameters:addString("CalcMode", "Pivot calculation mode", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Classic", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci resistance levels", "", "FibonacciR");

    indicator.parameters:addGroup("Pivot display style");
    indicator.parameters:addString("ShowMode", "Show PIVOT line for:", "", "TODAY");
    indicator.parameters:addStringAlternative("ShowMode", "Today", "", "TODAY");
    indicator.parameters:addStringAlternative("ShowMode", "History", "", "HIST");
    indicator.parameters:addString("LabelLoc", "Labels location", "", "E");
    indicator.parameters:addStringAlternative("LabelLoc", "End", "", "E");
    indicator.parameters:addStringAlternative("LabelLoc", "Begin", "", "B");
    indicator.parameters:addStringAlternative("LabelLoc", "Both", "", "A");

    indicator.parameters:addColor("clrP", "Color of P line", "", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("widthP", "Width of P line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleP", "Style of P line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleP", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrS1", "Color of S1 line", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthS1", "Width of S1 line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleS1", "Style of S1 line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS1", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS1", "Show S1 Line", "", true);

    indicator.parameters:addColor("clrS2", "Color of S2 line", "", core.rgb(224, 0, 0));
    indicator.parameters:addInteger("widthS2", "Width of S2 line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleS2", "Style of S2 line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS2", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS2", "Show S2 Line", "", true);

    indicator.parameters:addColor("clrS3", "Color of S3 line", "", core.rgb(192, 0, 0));
    indicator.parameters:addInteger("widthS3", "Width of S3 line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleS3", "Style of S3 line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS3", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS3", "Show S3 Line", "", true);

    indicator.parameters:addColor("clrS4", "Color of S4 line", "", core.rgb(160, 0, 0));
    indicator.parameters:addInteger("widthS4", "Width of S4 line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleS4", "Style of S4 line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS4", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS4", "Show S4 Line", "", true);

    indicator.parameters:addColor("clrR1", "Color of R1 line", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthR1", "Width of R1 line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleR1", "Style of R1 line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleR1", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR1", "Show R1 Line", "", true);

    indicator.parameters:addColor("clrR2", "Color of R2 line", "", core.rgb(0, 224, 0));
    indicator.parameters:addInteger("widthR2", "Width of R2 line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleR2", "Style of R2 line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleR2", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR2", "Show R2 Line", "", true);

    indicator.parameters:addColor("clrR3", "Color of R3 line", "", core.rgb(0, 192, 0));
    indicator.parameters:addInteger("widthR3", "Width of R3 line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleR3", "Style of R3 line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleR3", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR3", "Show R3 Line", "", true);

    indicator.parameters:addColor("clrR4", "Color of R4 line", "", core.rgb(0, 160, 0));
    indicator.parameters:addInteger("widthR4", "Width of R4 line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleR4", "Style of R4 line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleR4", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR4", "Show R4 Line", "", true);

    indicator.parameters:addBoolean("ShowMP", "Show MIDPOINT Line", "", false);
    indicator.parameters:addColor("clrMP", "Color of MIDPOINT line", "", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthMP", "Width of MIDPOINT line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMP", "Style of MIDPOINT line", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleMP", core.FLAG_LEVEL_STYLE);
end

local P;
local H;
local L;
local D;
local source;
local ref;
local instr;
local HR, TZ, MC;
local yesterdayDay;
local host;
local offset;
local weekoffset;

local RP = 0;
local S1 = 1;
local S2 = 2;
local S3 = 3;
local S4 = 4;
local R1 = 5;
local R2 = 6;
local R3 = 7;
local R4 = 8;
local PID = 9;
local name = {};
local show = {};
local clr = {};
local width = {};
local style = {};
local stream = {};
local fibr = {};

local clrP;
local widthP;
local styleP;

local O_PIVOT = 1;
local O_CAM = 2;
local O_WOOD = 3;
local O_FIB = 4;
local O_FLOOR = 5;
local O_FIBR = 6;
local CalcMode;

local O_HIST = 1;
local O_TODAY = 2;
local ShowMode;
local ShowMP;
local clrMP;
local widthMP;
local styleMP;
local O_END = 1;
local O_BEG = 2;
local O_BOTH = 3;
local LabelLoc;
local eps;
local loading = false;

function Prepare(onlyName)
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");


    source = instance.source;
    instr = source:instrument();
    HR = instance.parameters.HR;
    if HR >= 0 and HR < 12 then
        HR = HR;
    elseif HR >= 12 and HR < 24 then
        HR = -(24 - HR);
    else
        assert(false, "The hour specified must be between 0 and 23");
    end
    TZ = core[instance.parameters.TZ];
    MC = instance.parameters.MC;
    clrP = instance.parameters.clrP;
    widthP = instance.parameters.widthP;
    styleP = instance.parameters.styleP;
    ShowMP = instance.parameters.ShowMP;
    clrMP = instance.parameters.clrMP;
    widthMP = instance.parameters.widthMP;
    styleMP = instance.parameters.styleMP;

    local precision = source:getPrecision();
    if precision > 0 then
        eps = math.pow(10, -precision);
    else
        eps = 1;
    end

    name[RP] = "P";
    name[S1] = "S1";
    name[S2] = "S2";
    name[S3] = "S3";
    name[S4] = "S4";
    name[R1] = "R1";
    name[R2] = "R2";
    name[R3] = "R3";
    name[R4] = "R4";
    show[S1] = instance.parameters.showS1;
    show[S2] = instance.parameters.showS2;
    show[S3] = instance.parameters.showS3;
    show[S4] = instance.parameters.showS4;
    show[R1] = instance.parameters.showR1;
    show[R2] = instance.parameters.showR2;
    show[R3] = instance.parameters.showR3;
    show[R4] = instance.parameters.showR4;
    clr[S1] = instance.parameters.clrS1;
    clr[S2] = instance.parameters.clrS2;
    clr[S3] = instance.parameters.clrS3;
    clr[S4] = instance.parameters.clrS4;
    clr[R1] = instance.parameters.clrR1;
    clr[R2] = instance.parameters.clrR2;
    clr[R3] = instance.parameters.clrR3;
    clr[R4] = instance.parameters.clrR4;
    width[S1] = instance.parameters.widthS1;
    width[S2] = instance.parameters.widthS2;
    width[S3] = instance.parameters.widthS3;
    width[S4] = instance.parameters.widthS4;
    width[R1] = instance.parameters.widthR1;
    width[R2] = instance.parameters.widthR2;
    width[R3] = instance.parameters.widthR3;
    width[R4] = instance.parameters.widthR4;
    style[S1] = instance.parameters.styleS1;
    style[S2] = instance.parameters.styleS2;
    style[S3] = instance.parameters.styleS3;
    style[S4] = instance.parameters.styleS4;
    style[R1] = instance.parameters.styleR1;
    style[R2] = instance.parameters.styleR2;
    style[R3] = instance.parameters.styleR3;
    style[R4] = instance.parameters.styleR4;

    fibr[S4] = -0.272;
    fibr[S3] = 0;
    fibr[S2] = 0.236;
    fibr[S1] = 0.382;
    fibr[R1] = 0.618;
    fibr[R2] = 0.764;
    fibr[R3] = 1;
    fibr[R4] = 1.272;

    -- validate
    local l;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l = math.floor((e - s) * 864000 + 0.5) / 10;

    if instance.parameters.ShowMode == "TODAY" then
        ShowMode = O_TODAY;
    elseif instance.parameters.ShowMode == "HIST" then
        ShowMode = O_HIST;
    else
        assert(false, "Wrong display mode" .. ": " .. instance.parameters.CalcMode);
    end

    if instance.parameters.CalcMode == "Pivot" then
        CalcMode = O_PIVOT;
    elseif instance.parameters.CalcMode == "Camarilla" then
        CalcMode = O_CAM;
    elseif instance.parameters.CalcMode == "Woodie" then
        CalcMode = O_WOOD;
    elseif instance.parameters.CalcMode == "Fibonacci" then
        CalcMode = O_FIB;
    elseif instance.parameters.CalcMode == "Floor" then
        CalcMode = O_FLOOR;
    elseif instance.parameters.CalcMode == "FibonacciR" then
        CalcMode = O_FIBR;
        if ShowMode == O_TODAY then
            name[S1] = tostring(fibr[S1]);
            name[S2] = tostring(fibr[S2]);
            name[S3] = tostring(fibr[S3]);
            name[S4] = tostring(fibr[S4]);
            name[R1] = tostring(fibr[R1]);
            name[R2] = tostring(fibr[R2]);
            name[R3] = tostring(fibr[R3]);
            name[R4] = tostring(fibr[R4]);
            name[RP] = "0.5";
        end
    else
        assert(false, "Wrong calculation mode" .. ": " .. instance.parameters.CalcMode);
    end


    if instance.parameters.LabelLoc == "E" then
        LabelLoc = O_END;
    elseif instance.parameters.LabelLoc == "B" then
        LabelLoc = O_BEG;
    elseif instance.parameters.LabelLoc == "A" then
        LabelLoc = O_BOTH;
    else
        assert(false, "Wrong label location" .. ": " .. instance.parameters.LabelLoc);
    end

    -- create streams
    local sname;
    sname = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.CalcMode .. ",@" .. instance.parameters.HR .. ":00(" .. instance.parameters.TZ .. "))";
    instance:name(sname);

    if onlyName then
        assert(l <= 3600, "The indicator can be applied on 1-hour or shorter charts only");
        return;
    end

    -- pivot
    if ShowMode == O_HIST then
        P = instance:addStream("P", core.Line, sname .. "." .. "P", "P", clrP, 0);
        P:setWidth(widthP);
        P:setStyle(styleP);
    else
        D = instance:addInternalStream(0, 0);
        D:setWidth(widthP);
        D:setStyle(styleP);
        P = instance:addInternalStream(0, 0);
    end
    -- range
    H = instance:addInternalStream(0, 0);
    L = instance:addInternalStream(0, 0);
    -- show stream for historical mode
    if ShowMode == O_HIST then
        for i = S1, R4, 1 do
            if show[i] then
                stream[i] = instance:addStream(name[i], core.Line, sname .. "." .. name[i], name[i], clr[i], 0);
                stream[i]:setWidth(width[i]);
                stream[i]:setStyle(style[i]);
            end
        end
    end

    ref = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), 300, 100, 101);
    loading = true;
end

local d = {};

function Update(period, mode)
    -- if data for the specific candle are still loading
    -- then do nothing
    if loading then
        return ;
    end

    if ref:size() == 0 then
        return;
    end


    local o, h, l, c, s;

    o, h, l, c, s = getDay(source:date(period));

    if o == nil then
        return ;
    end

    pday = prev_i;
    if CalcMode == O_PIVOT or CalcMode == O_FIB or CalcMode == O_FLOOR then
        P[period] = (h + c + l) / 3;
    elseif CalcMode == O_CAM then
        P[period] = c;
    elseif CalcMode == O_FIBR then
        P[period] = (h + l) / 2;
    elseif CalcMode == O_WOOD then
        P[period] = (h + l + o * 2 ) / 4;
    end
    H[period] = h;
    L[period] = l;


    CalculateLevels(period);
    if ShowMode == O_HIST then
        local nb;
        nb = false;
        if P:hasData(period - 1) and math.abs(P[period - 1] - P[period]) > eps and not(SameSizeBar) then
            nb = true;
        end

        for i = S1, R4, 1 do
            if show[i] and d[i] ~= 0 then
                stream[i][period] = d[i];
                if nb then
                    stream[i]:setBreak(period, true);
                end
            end
        end
    end
    if (period == source:size() - 1) then
        ShowLevels(d, s, period);
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        getDayReset();
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

function CalculateLevels(period)
    local h, l, p, r;
    p = P[period];
    h = H[period];
    l = L[period];
    r = h - l;

    if CalcMode == O_PIVOT then
        d[R4] = p + r * 3;
        d[R3] = p + r * 2;
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = p - r * 2;
        d[S4] = p - r * 3;
    elseif CalcMode == O_CAM then
        d[R4] = p + r * 1.1 / 2;
        d[R3] = p + r * 1.1 / 4;
        d[R2] = p + r * 1.1 / 6;
        d[R1] = p + r * 1.1 / 12;

        d[S1] = p - r * 1.1 / 12;
        d[S2] = p - r * 1.1 / 6;
        d[S3] = p - r * 1.1 / 4;
        d[S4] = p - r * 1.1 / 2;
    elseif CalcMode == O_WOOD then
        d[R4] = h + (2 * (p - l) + r);
        d[R3] = h + 2 * (p - l);
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = l - 2 * (h - p);
        d[S4] = l - (r + 2 * (h - p));
    elseif CalcMode == O_FIB then
        d[R4] = p + 1.618 * (h - l);
        d[R3] = p + 1 * (h - l);
        d[R2] = p + 0.618 * (h - l);
        d[R1] = p + 0.382 * (h - l);

        d[S1] = p - 0.382 * (h - l);
        d[S2] = p - 0.618 * (h - l);
        d[S3] = p - 1 * (h - l);
        d[S4] = p - 1.618 * (h - l);
    elseif CalcMode == O_FLOOR then
        d[R4] = 0;
        d[R3] = h + (p - l) * 2;
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = l - (h - p) * 2;
        d[S4] = 0;
    elseif CalcMode == O_FIBR then
        d[R4] = l + (h - l) * fibr[R4];
        d[R3] = l + (h - l) * fibr[R3];
        d[R2] = l + (h - l) * fibr[R2];
        d[R1] = l + (h - l) * fibr[R1];

        d[S1] = l + (h - l) * fibr[S1];
        d[S2] = l + (h - l) * fibr[S2];
        d[S3] = l + (h - l) * fibr[S3];
        d[S4] = l + (h - l) * fibr[S4];
    end

    return ;
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function ShowLevels(data, date, period)
    local i, d1, d2;

    d1 = date;
    d2 = d1 + 1;

    host:execute("drawLine", PID, d1, P[period], d2, P[period], clrP, styleP, widthP, "P(" .. round(P[period], source:getPrecision()) .. ")");
    if LabelLoc == O_END or LabelLoc == O_BOTH then
        host:execute("drawLabel", PID, d2, P[period], name[RP]);
    end
    if LabelLoc == O_BEG or LabelLoc == O_BOTH then
        host:execute("drawLabel", PID + 100, d1, P[period], name[RP]);
    end

    for i = S1, R4, 1 do
        if show[i] and data[i] ~= 0 then
            host:execute("drawLine", i, d1, data[i], d2, data[i], clr[i], style[i], width[i], name[i] .. "(" .. round(data[i], source:getPrecision()) .. ")");
            if LabelLoc == O_END or LabelLoc == O_BOTH then
                host:execute("drawLabel", i, d2, data[i], name[i]);
            end
            if LabelLoc == O_BEG or LabelLoc == O_BOTH then
                host:execute("drawLabel", i + 100, d1, data[i], name[i]);
            end
        else
            host:execute("removeLine", i);
            host:execute("removeLabel", i);
            host:execute("removeLabel", i + 100);
        end
    end

    if ShowMP then
        ShowMPP(0, d1, d2, d[S2], d[S3], "M0");
        ShowMPP(1, d1, d2, d[S1], d[S2], "M1");
        ShowMPP(2, d1, d2, P[period], d[S1], "M2");
        ShowMPP(3, d1, d2, P[period], d[R1], "M3");
        ShowMPP(4, d1, d2, d[R1], d[R2], "M4");
        ShowMPP(5, d1, d2, d[R2], d[R3], "M5");
    end
end

function ShowMPP(i, d1, d2, p1, p2, l)
    if p1 ~= 0 and p2 ~= 0 then
        local p = (p1 + p2) / 2;
        host:execute("drawLine", PID + 10 + i, d1, p, d2, p, clrMP, styleMP, widthMP, l .. "(" .. round(p, source:getPrecision()) .. ")");
        if LabelLoc == O_END or LabelLoc == O_BOTH then
            host:execute("drawLabel", PID + 10 + i, d2, p, l);
        end
        if LabelLoc == O_BEG or LabelLoc == O_BOTH then
            host:execute("drawLabel", PID + 110 + i, d1, p, l);
        end
    end
end

local lastDayStart;
local lastOpen, lastHigh, lastLow, lastClose;


function getDay(date)
    if loading then
        return nil;
    end
    -- calculate the trading day
    if lastDayStart ~= nil and date >= lastDayStart and date < lastDayStart + 1 then
        return lastOpen, lastHigh, lastLow, lastClose, lastDayStart;
    end
    -- calculate the date's trading day start
    if TZ ~= core.TZ_EST then
        date = host:execute("convertTime", core.TZ_EST, TZ, date);      -- convert date to requested time zone
    end
    date = core.getcandle("D1", date, HR, 0);
    if TZ ~= core.TZ_EST then
        date = host:execute("convertTime", TZ, core.TZ_EST, date);      -- convert beginning of the day back to EST time zone
    end
    lastDayStart = date;
    -- find the date in the collection
    local idx = core.findDate(ref, lastDayStart, false);
    if idx < 0 then
        lastOpen = nil;
        lastHigh = nil;
        lastLow = nil;
        lastClose = nil;
        return nil, nil, nil, nil, nil;
    end
    -- get current day open
    if ref:date(idx) < lastDayStart then
        if idx == ref:size() - 1 then
            lastOpen = ref.close[idx];
        else
            lastOpen = ref.open[idx + 1];
        end
    else
        lastOpen = ref.open[idx];
        idx = idx - 1;
    end
    local prevDate = date - 1;
    -- find the previous day candle
    local found = false;
    while not found do
        local count = 0;
        lastHigh = -1e100;
        lastLow = 1e100;
        lastClose = nil;
        while ref:date(idx) >= prevDate do
            count = count + 1;
            if lastClose == nil then
                lastClose = ref.close[idx];
            end
            if lastHigh < ref.high[idx] then
                lastHigh = ref.high[idx];
            end
            if lastLow > ref.low[idx] then
                lastLow = ref.low[idx];
            end
            idx = idx - 1;
            if idx < 0 then
                lastOpen = nil;
                lastHigh = nil;
                lastLow = nil;
                lastClose = nil;
                return nil, nil, nil, nil, nil;
            end
        end

        found = count >= MC;
        if not found then
            prevDate = prevDate - 1;
        end
    end
    lastDayStart = date;
    return lastOpen, lastHigh, lastLow, lastClose, lastDayStart;
end

function getDayReset()
    lastDayStart = nil;
end
