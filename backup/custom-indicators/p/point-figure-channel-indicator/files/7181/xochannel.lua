-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3082

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("XO Square");
    indicator:description("Finds trend direction based based on Point And Figure(XO) diagram approach");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("BS", "Box Size (in pips)", "", 1, 1, 100);
    indicator.parameters:addInteger("RC", "Sensitivity, Reversal Count (in boxes)", "", 40, 1, 100);
    indicator.parameters:addInteger("BoxStyle", "Box Style", "", 1);
    indicator.parameters:addIntegerAlternative("BoxStyle", "Traditional XO", "", 1);
    indicator.parameters:addIntegerAlternative("BoxStyle", "High-Low", "", 2);
    indicator.parameters:addIntegerAlternative("BoxStyle", "Open-Close", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UC", "Up color (X-s)", "",  core.rgb(0, 72, 0));
    indicator.parameters:addColor("DC", "Down color (O-s)", "", core.rgb(72, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency %", "", 70, 1, 100);
    indicator.parameters:addBoolean("ShowLegend", "Show Square Legend", "", true);
    indicator.parameters:addInteger("LineStyle", "Line Style", "", core.LINE_NONE);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LEVEL_STYLE);

end

local STYLE_XO = 1
local STYLE_HL = 2
local STYLE_OC = 3

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
local first;
local source = nil;
local host;

-- Parameters block
local boxStyle;
local embedded;
local activeBar;
local showLegend;
local BS;
local PS;
local RC;
local priceFormat;

-- Streams block
local D;        -- dummy stream

local U1;       -- upper line of up box
local U2;       -- lower line of up box
local D1;       -- upper line of down box
local D2;       -- lower line of down box

local C;        -- stream for the index of the column to which bar belongs

local TextU;    -- upper label
local TextD;    -- lower label

local o, h, l, c;

-- Routine
function Prepare(nameOnly)
    source = instance.source;

    o = source.open;
    h = source.high;
    l = source.low;
    c = source.close;

    PS = source:pipSize();
    priceFormat = "%." .. source:getPrecision() .. "f";

    -- size of the box in pips
    BS = instance.parameters.BS * PS;
    -- reversal sensity in boxes
    RC = instance.parameters.RC;

    boxStyle = instance.parameters.BoxStyle;

    local style;

    if boxStyle == STYLE_XO then
        style = "XO";
    elseif boxStyle == STYLE_HL then
        style = "HL";
    elseif boxStyle == STYLE_OC then
        style = "OC";
    else
        assert(false, "unknown style chosen");
    end

    showLegend = instance.parameters.ShowLegend;

    first = source:first();
    host = core.host;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.BS .. "(" .. BS .. ")" .. ", " .. RC .. "," .. style .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    U1 = instance:addStream("U1", core.Line, name .. ".U1", "U1", instance.parameters.UC, first, 1);
    U2 = instance:addStream("U2", core.Line, name .. ".U2", "U2", instance.parameters.UC, first, 1);
    D1 = instance:addStream("D1", core.Line, name .. ".D1", "D1", instance.parameters.DC, first, 1);
    D2 = instance:addStream("D2", core.Line, name .. ".D2", "D2", instance.parameters.DC, first, 1);
    U1:setStyle(instance.parameters.LineStyle);
    U2:setStyle(instance.parameters.LineStyle);
    D1:setStyle(instance.parameters.LineStyle);
    D2:setStyle(instance.parameters.LineStyle);

    C = instance:addInternalStream(first, 0);

    instance:createChannelGroup("X", "X", U1, U2, instance.parameters.UC, 100 - instance.parameters.Transparency, true);
    instance:createChannelGroup("O", "O", D1, D2, instance.parameters.DC, 100 - instance.parameters.Transparency, true);

    if showLegend then
        TextU = instance:createTextOutput ("TextU", "TextU", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UC, 0);
        TextD = instance:createTextOutput ("TextD", "TextD", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DC, 0);
    end
end

local lastdate = nil;
local xodata = nil;

-- Indicator calculation routine
function Update(period)
    if period <= first then
        return ;
    end

    if lastdate ~= nil and lastdate > source:date(period) then
        -- if scrolled back - just reset xo data
        xodata = nil;
        C:setBookmark(1, -1);
    end

    if period ~= source:size() - 1 then
        -- recalculate for the latest candle of the stream only
        return ;
    end

    -- keep the last date we have calculated for
    lastdate = source:date(period);

    local i, curr, hbox, lbox, from, to;

    -- recall the last bar we calculated the data for
    local startfrom;
    startfrom = C:getBookmark(1);

    -- if there is no such bar yet - just start from the beginning
    if startfrom < first then
        startfrom = first;
    end

    if startfrom == first then
        lbox, hbox = tobox(first);
        if o[first] > c[first] then
            -- descending bar
            curr = {index = 0, direction = -1, hb = hbox, last = lbox, lb = lbox, hp = h[first], lp = l[first]};
        else
            -- ascending bar
            curr = {index = 0, direction = 1, hb = hbox, last = hbox, lb = lbox, hp = h[first], lp = l[first]};
        end
        -- reset all xo data
        xodata = {};
        xodata[0] = curr;
        xodata.barCount = 1;
        C[first] = 0;
        C:setBookmark(1000, first); -- start of bar 0 bookmark
        C:setBookmark(2000, first); -- end of bar 0 bookmark
        startfrom = startfrom + 1;
    end

    -- get the column at the start of the range
    curr = xodata[C[startfrom - 1]];

    assert(curr ~= nil, "error in algo(1)");

    for i = startfrom, period, 1 do
        lbox, hbox = tobox(i);

        -- update highest/lowest price of the bar
        curr.hp = math.max(curr.hp, h[i]);
        curr.lp = math.min(curr.lp, l[i]);

        if curr.direction > 0 then
            curr.last = curr.hb;
            curr.hb = math.max(curr.hb, hbox);
            -- check for reverse
            if lbox <= curr.last - RC then
                -- reverse now!
                C:setBookmark(2000 + curr.index, i - 1);
                draw(curr, true);

                local t = curr.hb;
                curr = {index = xodata.barCount, direction = -1, hb = t - 1, lb = lbox, hp = h[i], lp = l[i]};
                xodata[xodata.barCount] = curr;
                xodata.barCount = xodata.barCount + 1;
                C:setBookmark(1000 + curr.index, i);
                C:setBookmark(2000 + curr.index, i);
            else
                C:setBookmark(2000 + curr.index, i);
            end

        else -- if curr.direction < 0
            curr.last = curr.lb;
            curr.lb = math.min(curr.lb, lbox);
            if hbox >= curr.last + RC then
                -- reverse now!
                C:setBookmark(2000 + curr.index, i - 1);
                draw(curr, true);
                local t = curr.lb;
                curr = {index = xodata.barCount, direction = 1, hb = hbox, lb = t + 1, hp = h[i], lp = l[i]};
                xodata[xodata.barCount] = curr;
                xodata.barCount = xodata.barCount + 1;
                C:setBookmark(1000 + curr.index, i);
                C:setBookmark(2000 + curr.index, i);
            else
                C:setBookmark(2000 + curr.index, i);
            end
        end
        C[i] = curr.index;
    end
    draw(curr, false);
    C:setBookmark(1, period);
end

local labelFormat = nil;

-- draw the box
function draw(curr, updateMinMax)
    local from, to, range, hp, lp, L1, L2, T;

    from = math.max(C:getBookmark(1000 + curr.index), first);
    to = math.max(C:getBookmark(2000 + curr.index), first);
    range = core.range(from, to);

    if updateMinMax and boxStyle == STYLE_HL then
        curr.lp, curr.hp = mathex.minmax(source, from, to);
    end

    if boxStyle == STYLE_XO then
        hp = curr.hb * BS;
        lp = curr.lb * BS;
    elseif boxStyle == STYLE_HL then
        hp = curr.hp;
        lp = curr.lp;
    elseif boxStyle == STYLE_OC then
        hp = math.max(o[from], c[to]);
        lp = math.min(o[from], c[to]);
    end

    if curr.direction > 0 then
        L1 = U1;
        L2 = U2;
        T = TextU;
    else
        L1 = D1;
        L2 = D2;
        T = TextD;
    end

    if from == to then
        L1[from] = hp;
        L2[from] = lp;
    else
        core.drawLine(L1, range, hp, from, hp, to);
        core.drawLine(L2, range, lp, from, lp, to);
    end
    L1:setBreak(from, true);
    L2:setBreak(from, true);

    if showLegend then
        local pnl, height, date, type, label, stream, arrow, price;
        pnl = (c[to] - o[from]) / PS;
        height = (hp - lp) / PS;
        date = host:execute("convertTime", core.TZ_EST, core.TZ_TS, source:date(from));
        if curr.direction > 0 then
            type = "X";
            stream = TextU;
            price = hp;
            if pnl >= 0  then
                arrow = "\121\n";
            else
                arrow = "\120\n";
            end
        else
            type = "O";
            pnl = -pnl;
            stream = TextD;
            price = lp;
            if pnl >= 0  then
                arrow = "\n\121";
            else
                arrow = "\n\120";
            end
        end

        if labelFormat == nil then
            labelFormat = "%s square\nduration: %i bars since %s\n" ..
                          "open:=" .. priceFormat .. ",close:=" .. priceFormat .. "\n" ..
                          "high:=" .. priceFormat .. ",low:=" .. priceFormat .. "\n" ..
                          "height:=%i pips, P/L:=%i pips";
        end


        label = string.format(labelFormat, type, to - from + 1, core.formatDate(date), o[from], c[to], hp, lp, height, pnl);
        stream:set(from, price, arrow, label);
    end
end

-- returns:
--    lowest price in boxes
--    highest price in boxes
-- for the period specified
function tobox(period)
    -- from and to price expressed in boxes
    return math.floor(source.low[period] / BS + 0.5), math.floor(source.high[period] / BS + 0.5);
end

