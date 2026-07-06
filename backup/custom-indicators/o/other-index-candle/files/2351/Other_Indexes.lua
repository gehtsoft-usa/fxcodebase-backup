-- Id: 819
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1237

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
    indicator:name("Other Index indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addString("Index", "Index", "", "GBP/USD");
	indicator.parameters:setFlag ("Index", core.FLAG_INSTRUMENTS);
end

local first=nil;
local source = nil;
local barSize;
local usdx;
local loading = false;
local offset;
local weekoffset;
local open = nil;
local high = nil;
local low = nil;
local close = nil;
local Index;
local IndData=1;
local last=nil;
local data = {};

function AddCollectionItem(index, instrument, weight)
    local t, coll, from, to, tmp;
    t = {};
    t.instrument = instrument;
    t.data = nil;
    t.loading = false;
    t.weight = weight;
    t.rqfrom = nil;
    t.rqto = nil;
    data[index] = t;

    if first == nil or first > index then
        first = index;
    end
    if last == nil or last < index then
        last = index;
    end
end

function InitCollection()
    -- sum of absolute values of the weights must be 1. negative sign is for the
    -- instrument which has USD as counter currency.
    AddCollectionItem(IndData, Index, 1);
end



function Prepare(nameOnly)
    source = instance.source;
    Index=instance.parameters.Index;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    
    InitCollection();
    local name = profile:id() .. "(" .. source:name() .. "," .. Index .. " )";
    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("HA", "HA", open, high, low, close);

end

local oo = {};
local hh = {};
local ll = {};
local cc = {};

function GetPrice(index, date)
    local t;

    local from, to, tmp;

    t = data[index];

    assert(t ~= nil, "internal error!");

    if t.data == nil then
        -- data is not loaded yet at all
        if source:isAlive() then
            to = 0;
        else
            to = source:date(source:size() - 1);
        end
        from = source:date(source:first());
        t.data = host:execute("getHistory", index, t.instrument, barSize, from, to, source:isBid());
        t.rqfrom = from;
        t.rqto = to;
        t.loading = true;
        loading = true;
        return 0, 0;
    elseif date < t.rqfrom then
        -- requested date is before the first item of the collection
        -- we have ever requested
        from = date;
        to = t.data:date(0);
        host:execute("extendHistory", index, t.data, from, to);
        t.rqfrom = from;
        t.loading = true;
        loading = true;
        return 0, 0;
    elseif not(source:isAlive()) and date > t.rqto then
        -- requested date is after the last item of the collection
        -- we have ever requested
        to = date;
        from = t.data:date(t.data:size() - 1);
        host:execute("extendHistory", index, t.data, from, to);
        t.rqto = to;
        t.loading = true;
        loading = true;
        return 0, 0;
    end

    local p;
    p = core.findDate (t.data, date, false);
    if p < 0 then
        return 0, 0;
    end
    return t.data.open[p], t.data.high[p], t.data.low[p], t.data.close[p];
end

local lastdate = nil;

function Update(period, mode)
    if loading or period <= source:first() then
        return ;
    end

    -- do not calculate for the floating candle
    period = period - 1;

    if lastdate ~= nil and source:date(period) == lastdate then
        return ;
    end

    lastdate = source:date(period);

    local i, x, absent, o,h,l,c;
    absent = false;
    for i = first, last, 1 do
        o,h,l,c = GetPrice(i, lastdate);
        if o == 0 then
            absent = true;
        end
        oo[i] = o;
        hh[i] = h;
        ll[i] = l;
        cc[i] = c;
    end

    if loading then
        open:setBookmark(1, period);
        return ;
    end

    if absent then
        if open:hasData(period - 1) then
            open[period]=open[period-1];
	    high[period]=high[period-1];
	    low[period]=low[period-1];
	    close[period]=close[period-1];
        end
    else
        open[period] = oo[1];
        high[period]=hh[1];
        low[period]=ll[1];
        close[period]=cc[1];
    end

    period = period + 1;

    if period > 0 and period == source:size() - 1 then
        open[period]=open[period-1];
        high[period]=high[period-1];
        low[period]=low[period-1];
        close[period]=close[period-1];
    end
 

end

function AsyncOperationFinished(cookie)

    local t;
    t = data[cookie];
    t.loading = false;
    for i = first, last, 1 do
        if data[i].loading then
            return ;
        end
    end
    loading = false;

    local period;
    period = open:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    instance:updateFrom(period);
end

 