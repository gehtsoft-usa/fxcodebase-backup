-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18859
-- Id: 6602

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Custom day candles indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BeginDayHour", "Begin day hour", "Begin day hour", 3, 0, 23);
    
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
local volume = nil;
local Index;
local IndData=1;
local last=nil;
local data = {};
local BeginDayHour;

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
    AddCollectionItem(IndData, source:instrument(), 1);
end



function Prepare(nameOnly)
    source = instance.source;
    Index=instance.parameters.Index;
    host = core.host;
    barSize = "H1";
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    BeginDayHour=instance.parameters.BeginDayHour;
    
    assert(source:barSize()=="D1", "Current time frame must be D1");
    
    InitCollection();
    local name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.BeginDayHour .. " )";
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
    volume = instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), first)
    volume:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("CDC", "CDC", open, high, low, close, volume);

end

function DayBegin(D)
 local T=core.dateToTable(D);
 T.hour=0;
 T.min=0;
 T.sec=0;
 return core.tableToDate(T);
end

function GetPrice(index, date)
    local t;

    local from, to, tmp;
    local dateB=DayBegin(date);
    
    local date1=dateB+BeginDayHour/24;
    local date2=dateB+1+BeginDayHour/24-1/86400;

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
        return 0, 0, 0, 0, 0;
    elseif date1 < t.rqfrom then
        -- requested date is before the first item of the collection
        -- we have ever requested
        from = date1;
        to = t.data:date(0);
        host:execute("extendHistory", index, t.data, from, to);
        t.rqfrom = from;
        t.loading = true;
        loading = true;
        return 0, 0, 0, 0, 0;
    elseif not(source:isAlive()) and date2 > t.rqto then
        -- requested date is after the last item of the collection
        -- we have ever requested
        to = date2;
        from = t.data:date(t.data:size() - 1);
        host:execute("extendHistory", index, t.data, from, to);
        t.rqto = to;
        t.loading = true;
        loading = true;
        return 0, 0, 0, 0, 0;
    end

    local p1, p2;
    p1=core.findDate(t.data, date1, false);
    p2=core.findDate(t.data, date2, false);
    
    if t.data:date(p1)<date1 then p1=p1+1; end
    if t.data:date(p2)>date2 then p2=p2-1; end

    if p1<0 or p2<0 or p1>p2 then
        return 0, 0, 0, 0, 0;
    end
    
    if date1>core.now() then
     return 0, 0, 0, 0, 0;
    end
   
    local h=core.max(t.data.high,core.range(p1,p2));
    local l=core.min(t.data.low,core.range(p1,p2));
    local v=core.sum(t.data.volume,core.range(p1,p2));
    
    return t.data.open[p1], h, l, t.data.close[p2], v;
end

local lastdate = nil;

function Update(period, mode)
    if loading or period <= source:first()+2 then
        return ;
    end

    lastdate = source:date(period);

    local i, x, absent, o,h,l,c,v;
    absent = false;
    o,h,l,c,v = GetPrice(1, lastdate);
    if o == 0 then
     absent = true;
    end

    if loading then
        open:setBookmark(1, period);
        return ;
    end

    if absent then
     open[period]=nil;
     close[period]=nil;
     high[period]=nil;
     low[period]=nil;
     volume[period]=nil;
    else
     open[period] = o;
     high[period]=h;
     low[period]=l;
     close[period]=c;
     volume[period]=v;
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
 