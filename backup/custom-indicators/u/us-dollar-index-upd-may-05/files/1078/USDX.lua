-- Id: 630
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=609

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
    indicator:name("USD Index");
    indicator:description("Calculates the USD index in on the base of EUR/USD, USD/JPY, GBP/USD, USD/CAD, AUD/USD and USD/CHF instruments. You must be subscribed for all these instruments!!!");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clrIndex", "Index Color", "", core.rgb(255, 255, 128));
end

local source;
local barSize;
local usdx;
local loading = false;
local offset;
local weekoffset;

-- indexes for the instruments in the data table
local eurusd = 1;
local usdjpy = 2;
local gbpusd = 3;
local usdcad = 4;
local usdchf = 5;
local usdsek = 6;
local first = nil;
local last = nil;
-- data table
local data = {};

-- add a new item into the data table
-- index        - is the index of the item in the table
-- instrument   - the instrument name
-- weight       - the weigth of the instrument
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

-- initialize the collection of the instruments
function InitCollection()
    -- sum of absolute values of the weights must be 1. negative sign is for the
    -- instrument which has USD as counter currency.
    AddCollectionItem(eurusd, "EUR/USD", -0.576);
    AddCollectionItem(usdjpy, "USD/JPY", 0.136);
    AddCollectionItem(gbpusd, "GBP/USD", -0.119);
    AddCollectionItem(usdcad, "USD/CAD", 0.091);
	 AddCollectionItem(usdsek, "AUD/USD", -0.042);
   -- AddCollectionItem(usdsek, "USD/SEK", 0.042);
    AddCollectionItem(usdchf, "USD/CHF", 0.036);
end

-- prepare the indicator
function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    InitCollection();

    local name = profile:id();
    instance:name(name);
    if nameOnly then
        return;
    end
    usdx = instance:addStream("X", core.Line, name .. ".X", "X", instance.parameters.clrIndex, 0);
    usdx:setPrecision(math.max(2, instance.source:getPrecision()));
end

local p = {};
local w = {};

-- get the price of the specified instrument
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
    p = core.findDate(t.data, date, false);
    if p < 0 then
        return 0, 0;
    end
    return t.data.close[p], t.weight;
end

local lastdate = nil;

-- the function which is called to calculate the period
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

    local i, x, absent, a, b;
    absent = false;
    for i = first, last, 1 do
        a, b = GetPrice(i, lastdate);
        if a == 0 then
            absent = true;
        end
        p[i] = a;
        w[i] = b;
    end

    if loading then
        usdx:setBookmark(1, period);
        return ;
    end

    if absent then
        if usdx:hasData(period - 1) then
            usdx[period] = usdx[period - 1];
        end
    else
        x = 50.14348112;
        for i = first, last, 1 do
            x = x * math.pow(p[i], w[i]);
        end
        usdx[period] = x;
    end

    period = period + 1;

    if period > 0 and period == source:size() - 1 then
        usdx[period] = usdx[period - 1];
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
    period = usdx:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    instance:updateFrom(period);
end
 