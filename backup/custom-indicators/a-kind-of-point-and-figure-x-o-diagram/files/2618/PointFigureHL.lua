-- Id: 1029
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1361

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
    indicator:name("Point and Figure (on high/low prices)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("BS", "Box Size (in pips)", "", 5, 1, 100);
    indicator.parameters:addInteger("RC", "Reversal Count (in boxes)", "", 3, 1, 100);
    indicator.parameters:addInteger("W", "Width of the column in bars", "Set 0 for auto box size", 1, 0, 100);

    indicator.parameters:addColor("UC", "Up color (X-s)", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("DC", "Down color (O-s)", "", core.COLOR_DOWNCANDLE);
    indicator.parameters:addColor("LC", "Lines color", "", core.rgb(0, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local BS;
local RC;
local FU;
local TU;
local FD;
local TD;
local UL;
local DL;
local LC;
local W;

local first;
local source = nil;
local pip;
local host;

-- Streams block

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    -- size of the box in pips
    BS = instance.parameters.BS * source:pipSize();
    -- reversal sensity in boxes
    RC = instance.parameters.RC;
    -- width of the column in bars
    W = instance.parameters.W;

    LC = instance.parameters.LC;
    first = source:first();
    host = core.host;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.BS .. "(" .. BS .. ")" .. ", " .. RC .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    FU = instance:addStream("FU", core.Dot, name .. ".FU", "FU", core.rgb(192, 192, 192), first);
    FU:setPrecision(math.max(2, instance.source:getPrecision()));
    TU = instance:addStream("TU", core.Dot, name .. ".TU", "TU", core.rgb(192, 192, 192), first);
    TU:setPrecision(math.max(2, instance.source:getPrecision()));
    FD = instance:addStream("FD", core.Dot, name .. ".FD", "FD", core.rgb(192, 192, 192), first);
    FD:setPrecision(math.max(2, instance.source:getPrecision()));
    TD = instance:addStream("TD", core.Dot, name .. ".TD", "TD", core.rgb(192, 192, 192), first);
    TD:setPrecision(math.max(2, instance.source:getPrecision()));
    UL = instance:createTextOutput ("UL", "UL", "Wingdings", 8, core.H_Center, core.V_Top, instance.parameters.DC, 0);
    DL = instance:createTextOutput ("UL", "UL", "Wingdings", 8, core.H_Center, core.V_Bottom, instance.parameters.UC, 0);

    instance:createFromToBarGroup("U", "U", FU, TU, instance.parameters.UC);
    instance:createFromToBarGroup("D", "D", FD, TD, instance.parameters.DC);
end

local lastdate = nil;
local laststart = nil;

-- Indicator calculation routine
function Update(period)
    if period <= first then
        return ;
    end

    if lastdate ~= nil and lastdate > source:date(period) then
        lastdate = nil;
    end

    if period == source:size() - 1 then
        -- recalculate for the latest candle only
        if source:isAlive() then
            if lastdate == nil or lastdate ~= source:date(period) then
                lastdate = source:date(period);
                period = period - 1;
            else
                -- the last candle is still changing
                return ;
            end
        end
    else
        -- do not work until the collection is finished
        return ;
    end

    local columns = {};
    local column;
    local count = 0;
    local i, box, label, date, t, direction;
    local lb, hb, h, l, last;

    last = math.floor(source.open[first] / BS + 0.5);
    direction = 0;

    for i = first, period, 1 do
        l, h, lb, hb = tobox(i);        -- get range of the current bar's high and low expressed in boxes.

        if direction == 0 then
            -- dont' find a direction yet.
            if lb < last then
                direction = -1;
                column = {direction = direction, from = lb, to = last, dfrom = source:date(first), bars = i - first + 1};
                columns[count] = column;
                count = count + 1;
                last = lb;
            elseif hb > last then
                direction = 1;
                column = {direction = direction, from = last, to = lb, dfrom = source:date(first), bars = i - first + 1};
                columns[count] = column;
                count = count + 1;
                last = hb;
            end
        elseif direction > 0 then
            -- up direction
            if hb > column.to then
                -- if new top is higher than the old - extend the border
                column.to = hb;
            end

            if lb <= last - RC then
                -- if lowest price is RC boxes lower than the previous top
                direction = -1;
                t = column.to - 1;
                column = {direction = direction, from = lb, to = t, dfrom = source:date(i), bars = 0};
                columns[count] = column;
                count = count + 1;
            else
                last = column.to;
            end
            column.bars = column.bars + 1;
        elseif direction < 0 then
            -- down direction
            if lb < column.from then
                -- if new low is lower than the old - extend the border
                column.from = lb;
            end

            if hb >= last + RC then
                -- if highest price is RC boxes higher than the previous bottom
                direction = 1;
                t = column.from + 1;
                column = {direction = direction, from = t, to = hb, dfrom = source:date(i), bars = 0};
                columns[count] = column;
                count = count + 1;
            else
                last = column.from;
            end
            column.bars = column.bars + 1;
        end
    end

    local w;
    if W ~= 0 then
        w = W;
    else
        w = math.floor((source:size() - 1) / count);
        if w < 1 then
            w = 1;
        end
    end


    count = count - 1;
    p = period - (count + 1) * w;

    if laststart ~= nil then
        for i = math.max(laststart, 0), source:size() - 1, 1 do
            FD[i] = nil;
            TD[i] = nil;
            FU[i] = nil;
            TU[i] = nil;
            UL:setNoData(i);
            DL:setNoData(i);
        end
    end

    laststart = p;
    local l = 99999999999999;
    local h = 0;
    local f, t;
    for i = 0, count, 1 do
        if p >= 0 then
            column = columns[i];
            f = (column.from) * BS;
            t = (column.to + 1) * BS;
            l = math.min(l, f);
            h = math.max(h, t);
            date = core.dateToTable(host:execute("convertTime", 1, 4, column.dfrom));
            label = string.format("Begins: %02i/%02i/%02i %02i:%02i\nLength: %i bars\nHeight: %i  boxes (%.4f-%.4f)", date.month, date.day, date.year, date.hour, date.min, column.bars, column.to - column.from + 1,  f, t);
            if column.direction == -1 then
                for j = p, p + w - 1, 1 do
                    if j >= source:size() then
                        assert(false);
                    end
                    FD[j] = f;
                    TD[j] = t;
                end
                UL:set(math.floor(p + (w / 2)), TD[p], "\226", label);
            else
                for j = p, p + w - 1, 1 do
                    if j >= source:size() then
                        assert(false);
                    end
                    FU[j] = f;
                    TU[j] = t;
                end
                DL:set(math.floor(p + (w / 2)), FU[p], "\225", label);
            end
        end
        p = p + w;
    end

    host:execute("removeAll");
    if h ~= 0 then
        f = source:date(math.max(laststart, first));
        t = source:date(period + 1);
        j = 1;
        for i = l, h, BS do
            host:execute("drawLine", j, f, i, t, i, LC);
            j = j + 1;
        end
    end
end

function tobox(period)
    -- from and to price expressed in boxes
    return source.low[period], source.high[period],
           math.floor(source.low[period] / BS + 0.5), math.floor(source.high[period] / BS + 0.5);
end

