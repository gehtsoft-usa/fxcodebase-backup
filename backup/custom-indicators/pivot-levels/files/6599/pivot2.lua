-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2894
-- Id: 2576

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
    indicator:name(resources:get("R_NAME"));
    indicator:description(resources:get("R_DESCRIPTION"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Support/Resistance");

    indicator.parameters:addGroup(resources:get("R_PARAMS"));
    indicator.parameters:addString("BS", resources:get("R_PERIOD"), resources:get("R_PERIOD1"), "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);

    indicator.parameters:addString("CalcMode", resources:get("R_MODE"), resources:get("R_MODE1"), "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O1"), "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O2"), "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O3"), "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O4"), "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O5"), "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O6"), "", "FibonacciR");
	indicator.parameters:addStringAlternative("CalcMode", "Demark Pivots", "", "Demark");

    indicator.parameters:addGroup(resources:get("R_STYLE"));
    indicator.parameters:addString("ShowMode", resources:get("R_SMODE"), resources:get("R_SMODE1"), "TODAY");
    indicator.parameters:addStringAlternative("ShowMode", resources:get("R_SMODE_O1"), "", "TODAY");
    indicator.parameters:addStringAlternative("ShowMode", resources:get("R_SMODE_O2"), "", "HIST");
    indicator.parameters:addString("LabelLoc", resources:get("R_LABEL_LOC"), resources:get("R_LABEL_LOC_DESC"), "E");
    indicator.parameters:addStringAlternative("LabelLoc", resources:get("R_LABEL_LOC_1"), "", "E");
    indicator.parameters:addStringAlternative("LabelLoc", resources:get("R_LABEL_LOC_2"), "", "B");
    indicator.parameters:addStringAlternative("LabelLoc", resources:get("R_LABEL_LOC_3"), "", "A");

    indicator.parameters:addColor("clrP", resources:get("R_COLOR_P"), resources:get("R_COLOR_P_1"), core.rgb(192, 192, 192));
    indicator.parameters:addInteger("widthP", resources:get("R_WIDTH_P"), resources:get("R_WIDTH_P_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleP", resources:get("R_STYLE_P"), resources:get("R_STYLE_P_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleP", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clrS1", resources:get("R_COLOR_S1"), resources:get("R_COLOR_S1_1"), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthS1", resources:get("R_WIDTH_S1"), resources:get("R_WIDTH_S1_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleS1", resources:get("R_STYLE_S1"), resources:get("R_STYLE_S1_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS1", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("showS1", resources:get("R_SHOW_S1"), resources:get("R_SHOW_S1_1"), true);

    indicator.parameters:addColor("clrS2", resources:get("R_COLOR_S2"), resources:get("R_COLOR_S2_1"), core.rgb(224, 0, 0));
    indicator.parameters:addInteger("widthS2", resources:get("R_WIDTH_S2"), resources:get("R_WIDTH_S2_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleS2", resources:get("R_STYLE_S2"), resources:get("R_STYLE_S2_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS2", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("showS2", resources:get("R_SHOW_S2"), resources:get("R_SHOW_S2_1"), true);

    indicator.parameters:addColor("clrS3", resources:get("R_COLOR_S3"), resources:get("R_COLOR_S3_1"), core.rgb(192, 0, 0));
    indicator.parameters:addInteger("widthS3", resources:get("R_WIDTH_S3"), resources:get("R_WIDTH_S3_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleS3", resources:get("R_STYLE_S3"), resources:get("R_STYLE_S3_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS3", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("showS3", resources:get("R_SHOW_S3"), resources:get("R_SHOW_S3_1"), true);

    indicator.parameters:addColor("clrS4", resources:get("R_COLOR_S4"), resources:get("R_COLOR_S4_1"), core.rgb(160, 0, 0));
    indicator.parameters:addInteger("widthS4", resources:get("R_WIDTH_S4"), resources:get("R_WIDTH_S4_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleS4", resources:get("R_STYLE_S4"), resources:get("R_STYLE_S4_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS4", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("showS4", resources:get("R_SHOW_S4"), resources:get("R_SHOW_S4_1"), true);

    indicator.parameters:addColor("clrR1", resources:get("R_COLOR_R1"), resources:get("R_COLOR_R1_1"), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthR1", resources:get("R_WIDTH_R1"), resources:get("R_WIDTH_R1_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleR1", resources:get("R_STYLE_R1"), resources:get("R_STYLE_R1_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR1", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("showR1", resources:get("R_SHOW_R1"), resources:get("R_SHOW_R1_1"), true);

    indicator.parameters:addColor("clrR2", resources:get("R_COLOR_R2"), resources:get("R_COLOR_R2_1"), core.rgb(0, 224, 0));
    indicator.parameters:addInteger("widthR2", resources:get("R_WIDTH_R2"), resources:get("R_WIDTH_R2_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleR2", resources:get("R_STYLE_R2"), resources:get("R_STYLE_R2_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR2", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("showR2", resources:get("R_SHOW_R2"), resources:get("R_SHOW_R2_1"), true);

    indicator.parameters:addColor("clrR3", resources:get("R_COLOR_R3"), resources:get("R_COLOR_R3_1"), core.rgb(0, 192, 0));
    indicator.parameters:addInteger("widthR3", resources:get("R_WIDTH_R3"), resources:get("R_WIDTH_R3_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleR3", resources:get("R_STYLE_R3"), resources:get("R_STYLE_R3_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR3", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("showR3", resources:get("R_SHOW_R3"), resources:get("R_SHOW_R3_1"), true);

    indicator.parameters:addColor("clrR4", resources:get("R_COLOR_R4"), resources:get("R_COLOR_R4_1"), core.rgb(0, 160, 0));
    indicator.parameters:addInteger("widthR4", resources:get("R_WIDTH_R4"), resources:get("R_WIDTH_R4_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleR4", resources:get("R_STYLE_R4"), resources:get("R_STYLE_R4_1"), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR4", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("showR4", resources:get("R_SHOW_R4"), resources:get("R_SHOW_R4_1"), true);

    indicator.parameters:addBoolean("ShowMP", resources:get("R_SHOW_MIDPOINT"), resources:get("R_SHOW_MIDPOINT_1"), false);
    indicator.parameters:addColor("clrMP", resources:get("R_MIDPOINT_COLOR"), resources:get("R_MIDPOINT_COLOR_1"), core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthMP", resources:get("R_WIDTH_MIDPOINT"), resources:get("R_WIDTH_MIDPOINT_1"), 1, 1, 5);
    indicator.parameters:addInteger("styleMP", resources:get("R_STYLE_MIDPOINT"), resources:get("R_STYLE_MIDPOINT_1"), core.LINE_DOT);
    indicator.parameters:setFlag("styleMP", core.FLAG_LINE_STYLE);
end

local P;
local H;
local L;
local C;
local O;
local D;
local source;
local ref;
local instr;
local BS;
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
local O_DM = 7;
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

function Prepare(onlyName)
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    source = instance.source;
    instr = source:instrument();
    BS = instance.parameters.BS;
    clrP = instance.parameters.clrP;
    widthP = instance.parameters.widthP;
    styleP = instance.parameters.styleP;
    ShowMP = instance.parameters.ShowMP;
    clrMP = instance.parameters.clrMP;
    widthMP = instance.parameters.widthMP;
    styleMP = instance.parameters.styleMP;

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

    if instance.parameters.ShowMode == "TODAY" then
        ShowMode = O_TODAY;
    elseif instance.parameters.ShowMode == "HIST" then
        ShowMode = O_HIST;
    else
        assert(false, resources:get("R_SMODE_ERR") .. ": " .. instance.parameters.CalcMode);
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
	 elseif instance.parameters.CalcMode == "Demark" then
        CalcMode = O_DM;		
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
        assert(false, resources:get("R_MODE_ERR") .. ": " .. instance.parameters.CalcMode);
    end


    if instance.parameters.LabelLoc == "E" then
        LabelLoc = O_END;
    elseif instance.parameters.LabelLoc == "B" then
        LabelLoc = O_BEG;
    elseif instance.parameters.LabelLoc == "A" then
        LabelLoc = O_BOTH;
    else
        assert(false, resources:get("L_LABEL_LOC_ERR") .. ": " .. instance.parameters.LabelLoc);
    end

    -- create streams
    local sname;
    sname = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.CalcMode .. ")";
    instance:name(sname);

    if onlyName then
        return;
    end

    assert(l1 <= l2, resources:get("R_PERIOD_ERR1"));
    assert(BS ~= "t1", resources:get("R_PERIOD_ERR2"));


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
	O = instance:addInternalStream(0, 0);
    C = instance:addInternalStream(0, 0);
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
end

local loading = false;
local loadingFrom, loadingTo;
local pday = nil;
local d = {};

function Update(period, mode)
    -- get the previous's candle and load the ref data in case ref data does not exist
    local candle;
    candle = core.getcandle(BS, source:date(period), offset, weekoffset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading and candle >= loadingFrom and (loadingTo == 0 or candle <= loadingTo) then
        return ;
    end

    -- if data is not loaded yet at all
    -- load the data
    if ref == nil then
        -- there is no data at all, load initial data
        local to, t;
        local from;
        if (source:isAlive()) then
            -- if the source is subscribed for updates
            -- then subscribe the current collection as well
            to = 0;
        else
            -- else load up to the last currently available date
            t, to = core.getcandle(BS, source:date(period), offset, weekoffset);
        end
        from = core.getcandle(BS, source:date(source:first()), offset, weekoffset);
        loading = true;
        P:setBookmark(1, period);
        from = fixFrom(from);
        loadingFrom = from;
        loadingTo = to;
        ref = host:execute("getHistory", 1, source:instrument(), BS, from, to, source:isBid());
        return ;
    end

    if ref:size() == 0 then
        return;
    end
    -- check whether the requested candle is before
    -- the reference collection start
    if (candle < ref:date(0)) then
        local from;
        P:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        from = fixFrom(candle);
        loadingFrom = from;
        loadingTo = ref:date(0);
        host:execute("extendHistory", 1, ref, loadingFrom, loadingTo);
        return ;
    end

    -- check whether the requested candle is after
    -- the reference collection end
    if (not(source:isAlive()) and candle > ref:date(ref:size() - 1)) then
        if loading then
            return ;
        end
        loading = true;
        P:setBookmark(1, period);
        loadingFrom = ref:date(ref:size() - 1);
        loadingTo = candle;
        host:execute("extendHistory", 1, ref, loadingFrom, loadingTo);
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
            open = ref.close[prev_i];
        else
            open = ref.close[prev_i + 1];
        end
        P[period] = (ref.high[prev_i] + ref.close[prev_i] + open * 2 ) / 4;
    end
     H[period] = ref.high[prev_i];
    L[period] = ref.low[prev_i];
	O[period] = ref.open[prev_i];
    C[period] = ref.close[prev_i];

    if ShowMode == O_HIST then
        CalculateLevels(period);
        for i = S1, R4, 1 do
            if show[i] and d[i] ~= 0 then
                stream[i][period] = d[i];
            end
        end
    else
        if (period == source:size() - 1) then
            CalculateLevels(period);
            ShowLevels(d, period);
        end
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = P:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end

function CalculateLevels(period)
     local h, l, p, r, o,c;
    p = P[period];
    h = H[period];
    l = L[period];
	o = O[period];
    c = C[period];
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
	 elseif CalcMode == O_DM then
	local X;
	     if  c <  o then
		X = (h + (l * 2) + c);	
		end

		if  c > o then
		X = ((h * 2) + l + c);	
        end
		
		if  c ==  o then
		X = (h + l + (c * 2));
        end		
	
		P[period]  = X/4;
		
		d[R4] = 0;
        d[R3] = 0;
        d[R2] = 0;
        d[R1]= (X /2) - l;
		
		d[S1]= (X/2) - h;
		d[S2] = 0;
        d[S3] = 0;
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

function fixFrom(date)
    -- skip to the previous period
    date = date - BSLen * 2;
    -- check whether the Friday 17:00 >= period > Sunday 17:00
    -- if so - unwind to the last period of the previous trading
    local nontrading, nontradingend;
    nontrading, nontradingend = core.isnontrading(date, offset);
    if BSLen <= 1 and (nontrading) then
        date = nontradingend - BSLen * 2;
    end
    return date;
end


