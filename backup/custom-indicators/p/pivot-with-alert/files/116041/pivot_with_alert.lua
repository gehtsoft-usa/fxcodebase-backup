-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65365

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Pivot Levels with alerts");
    indicator:description("The indicator shows pivot point and the last period levels");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Support/Resistance");

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addString("BS", "The time frame for pivot", "The time frame must be equal to or greater than the chart time frame. The recommended time frame is 1 day.", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_BARPERIODS);

    indicator.parameters:addString("CalcMode", "Calculation mode", "The mode of pivot calculation.", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Classic Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci Retracement", "", "FibonacciR");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("ShowMode", "Show Mode", "The mode of pivot presentation.", "TODAY");
    indicator.parameters:addStringAlternative("ShowMode", "Today", "", "TODAY");
    indicator.parameters:addStringAlternative("ShowMode", "Historical", "", "HIST");
    indicator.parameters:addString("LabelLoc", "Line labels location", "Defines the location of line labels.", "E");
    indicator.parameters:addStringAlternative("LabelLoc", "At the end", "", "E");
    indicator.parameters:addStringAlternative("LabelLoc", "At the beginning", "", "B");
    indicator.parameters:addStringAlternative("LabelLoc", "At both", "", "A");

    indicator.parameters:addColor("clrP", string.format("%s color", "Pivot"),
        string.format("The color of the %s.", "pivot line"), core.rgb(192, 192, 192));
    indicator.parameters:addInteger("widthP", string.format("%s width", "Pivot"),
        string.format("The width of the %s.", "pivot line"), 1, 1, 5);
    indicator.parameters:addInteger("styleP", string.format("%s style", "Pivot"),
        string.format("The style of the %s.", "pivot line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleP", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrS1", string.format("%s color", "S1"),
        string.format("The color of the %s.", "first support line"), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthS1", string.format("%s width", "S1"),
        string.format("The width of the %s.", "first support line"), 1, 1, 5);
    indicator.parameters:addInteger("styleS1", string.format("%s style", "S1"),
        string.format("The style of the %s.", "first support line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS1", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS1", "Show S1", "Show the first support line.", true);

    indicator.parameters:addColor("clrS2", string.format("%s color", "S2"),
        string.format("The color of the %s.", "second support line"), core.rgb(224, 0, 0));
    indicator.parameters:addInteger("widthS2", string.format("The width of the %s.", "S2"),
        string.format("The width of the %s.", "second support line"), 1, 1, 5);
    indicator.parameters:addInteger("styleS2", string.format("%s style", "S2"),
        string.format("The style of the %s.", "second support line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS2", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS2", "Show S2", "Show the second support line.", true);

    indicator.parameters:addColor("clrS3", string.format("%s color", "S3"),
        string.format("The color of the %s.", "third support line"), core.rgb(192, 0, 0));
    indicator.parameters:addInteger("widthS3", string.format("The width of the %s.", "S3"),
        string.format("The width of the %s.", "third support line"), 1, 1, 5);
    indicator.parameters:addInteger("styleS3", string.format("%s style", "S3"),
        string.format("The style of the %s.", "third support line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS3", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS3", "Show S3", "Show the third support line.", true);

    indicator.parameters:addColor("clrS4", string.format("%s color", "S4"),
        string.format("The color of the %s.", "fourth support line"), core.rgb(160, 0, 0));
    indicator.parameters:addInteger("widthS4", string.format("The width of the %s.", "S4"),
        string.format("The width of the %s.", "fourth support line"), 1, 1, 5);
    indicator.parameters:addInteger("styleS4", string.format("%s style", "S4"),
        string.format("The style of the %s.", "fourth support line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS4", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS4", "Show S4", "Show the fourth support line.", true);

    indicator.parameters:addColor("clrR1", string.format("%s color", "R1"),
        string.format("The color of the %s.", "first resistance line"), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthR1", string.format("The width of the %s.", "R1"),
        string.format("The width of the %s.", "first resistance line"), 1, 1, 5);
    indicator.parameters:addInteger("styleR1", string.format("%s style", "R1"),
        string.format("The style of the %s.", "first resistance line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR1", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR1", "Show R1", "Show the first resistance line.", true);

    indicator.parameters:addColor("clrR2", string.format("%s color", "R2"),
        string.format("The color of the %s.", "second resistance line"), core.rgb(0, 224, 0));
    indicator.parameters:addInteger("widthR2", string.format("The width of the %s.", "R2"),
        string.format("The width of the %s.", "second resistance line"), 1, 1, 5);
    indicator.parameters:addInteger("styleR2", string.format("%s style", "R2"),
        string.format("The style of the %s.", "second resistance line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR2", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR2", "Show R2", "Show the second resistance line.", true);

    indicator.parameters:addColor("clrR3", string.format("%s color", "R3"),
        string.format("The color of the %s.", "third resistance line"), core.rgb(0, 192, 0));
    indicator.parameters:addInteger("widthR3", string.format("The width of the %s.", "R3"),
        string.format("The width of the %s.", "third resistance line"), 1, 1, 5);
    indicator.parameters:addInteger("styleR3", string.format("%s style", "R3"),
        string.format("The style of the %s.", "third resistance line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR3", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR3", "Show R3", "Show the third resistance line.", true);

    indicator.parameters:addColor("clrR4", string.format("%s color", "R4"),
        string.format("The color of the %s.", "fourth resistance line"), core.rgb(0, 160, 0));
    indicator.parameters:addInteger("widthR4", string.format("The width of the %s.", "R4"),
        string.format("The width of the %s.", "fourth resistance line"), 1, 1, 5);
    indicator.parameters:addInteger("styleR4", string.format("%s style", "R4"),
        string.format("The style of the %s.", "fourth resistance line"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR4", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR4", "Show R4", "Show the fourth resistance line.", true);

    indicator.parameters:addBoolean("ShowMP", "Show midpoint lines", "Defines whether the midpoint lines are shown.", false);
    indicator.parameters:addColor("clrMP", string.format("%s color", "Midpoint lines"),
        string.format("The color of the %s.", "midpoint lines"), core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthMP", string.format("The width of the %s.", "Midpoint lines"),
        string.format("The width of the %s.", "midpoint lines"), 1, 1, 5);
    indicator.parameters:addInteger("styleMP", string.format("%s style", "Midpoint lines"),
        string.format("The style of the %s.", "midpoint lines"), core.LINE_DOT);
    indicator.parameters:setFlag("styleMP", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    indicator.parameters:addColor("AlertsColor", "Alerts Stream Color", "", core.rgb(0, 255, 0));
end

local P;
local H;
local L;
local D;
local source;
local ref;
local instr;
local BS;
local CurrLen;
local BSLen;
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
local SameSizeBar = false;
local loading = false;
local ShowAlert = true;
local AlertStream = nil;

function Prepare(nameOnly) 

    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    source = instance.source;
    instr = source:instrument();
	
	
	
    -- create streams
    local sname;
    sname = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.CalcMode .. ")";
    instance:name(sname);
	
	
	if   (nameOnly) then
        return;
    end
	
    BS = instance.parameters.BS;
    clrP = instance.parameters.clrP;
    widthP = instance.parameters.widthP;
    styleP = instance.parameters.styleP;
    ShowMP = instance.parameters.ShowMP;
    clrMP = instance.parameters.clrMP;
    widthMP = instance.parameters.widthMP;
    styleMP = instance.parameters.styleMP;
    
    ShowAlert = instance.parameters.ShowAlert;

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
    local l1, l2;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l1 = e - s;
    s, e = core.getcandle(BS, core.now(), 0);
    l2 = e - s;
    BSLen = l2; -- remember length of the period
    CurrLen = l1;

    if source:barSize() == BS then
        SameSizeBar = true;
    end


    if instance.parameters.ShowMode == "TODAY" then
        ShowMode = O_TODAY;
    elseif instance.parameters.ShowMode == "HIST" then
        ShowMode = O_HIST;
    else
        assert(false, "Unknown show mode" .. ": " .. instance.parameters.CalcMode);
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
        assert(false, "Unknown calculation mode" .. ": " .. instance.parameters.CalcMode);
    end


    if instance.parameters.LabelLoc == "E" then
        LabelLoc = O_END;
    elseif instance.parameters.LabelLoc == "B" then
        LabelLoc = O_BEG;
    elseif instance.parameters.LabelLoc == "A" then
        LabelLoc = O_BOTH;
    else
        assert(false, "Unknown label location" .. ": " .. instance.parameters.LabelLoc);
    end



  
        assert(l1 <= l2, "Chosen base period for the pivot calculation must be equal to or longer than the chart period.");
        assert(BS ~= "t1", "Chosen base period for the pivot calculation must not be a tick period");
 
     

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

    AlertStream = instance:createTextOutput ("AlertStream", "AlertStream", "Wingdings 2", 15, core.H_Center, core.V_Top, instance.parameters.AlertsColor, 0);
    
    ref = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), 10, 100, 101);   
    loading = true;
end

local pday = nil;
local d = {};
local canWork = nil;

function Update(period, mode)
    if canWork == nil then
        if CurrLen > BSLen then
            core.host:execute("setStatus", "Chosen base period for the pivot calculation must be equal to or longer than the chart period.");
            canWork = false;
            return ;
        elseif BS == "t1" then
            core.host:execute("setStatus", "Chosen base period for the pivot calculation must not be a tick period");
            canWork = false;
            return ;
        else
            canWork = true;
        end
    elseif not(canWork) then
        return ;
    end

    -- get the previous's candle and load the ref data in case ref data does not exist
    local candle;
    candle = core.getcandle(BS, source:date(period), offset, weekoffset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading then
        return ;
    end

    if ref:size() == 0 then
        return;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (candle < ref:date(0)) then
        return ;
    end

    -- find the lastest completed period which is not saturday's period (to avoid
    -- collecting the saturday's data
    local prev_i = nil;
    local start;

    if (pday == nil) then
        start = 0;
    elseif ref:date(pday) >= candle then
        start = 0;
    else
        start = pday;
    end

    for i = start, ref:size() - 1, 1 do
        local td;
        -- skip nontrading candles
        if BSLen > 1 or not(core.isnontrading(ref:date(i), offset)) then
            if (ref:date(i) >= candle) then
                break;
            else
                prev_i = i;
            end
        end
    end

    if (prev_i == nil) then
        -- assert(false, "prev_i is nil");
        return ;
    end

    pday = prev_i;
    if CalcMode == O_PIVOT or CalcMode == O_FIB or CalcMode == O_FLOOR then
        P[period] = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3;
    elseif CalcMode == O_CAM then
        -- P[period] = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3;
        P[period] = ref.close[prev_i];
    elseif CalcMode == O_FIBR then
        P[period] = (ref.high[prev_i] + ref.low[prev_i]) / 2;
    elseif CalcMode == O_WOOD then
        local open;
        if (prev_i == ref:size() - 1) then
            -- for a live day take close as open of the next period
            open = ref.open[prev_i];
        else
            open = ref.open[prev_i + 1];
        end
        P[period] = (ref.high[prev_i] + ref.low[prev_i] + open * 2 ) / 4;
    end
    H[period] = ref.high[prev_i];
    L[period] = ref.low[prev_i];


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
        ShowAlerts(d, period);
        ShowLevels(d, period);
    end
end

function initCalculateLevel(period)

    local h, l, p, r;

    p = P[period];
    h = H[period];
    l = L[period];
    r = h - l;
    return h, l, p, r;
end

function ShowLevels(data, period)
    local i, d1, d2;

    --d1 = source:date(0);
    d2 = source:date(period);
    d1, d2 = core.getcandle(BS, d2, offset, weekoffset);

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

function ShowAlerts(data, period)
    local i;
    linesName = {"S1", "S2", "S3", "S4", "R1", "R2", "R3", "R4"}
    
    for i = S1, R4, 1 do
        if show[i] and data[i] ~= 0 and period > 2  then       
            if core.crosses(source["close"], data[i], period) == true then
                SendAlert("The closing price crossed " .. linesName[i]);
                AlertStream:set(period, source.close[period], "\86");           
            end
        end    
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

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        pday = nil;
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


function CalculateLevels(period)
    
    local h, l, p, r = initCalculateLevel(period);

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

function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
