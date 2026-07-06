-- Id: 3985
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4435

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
    indicator:name("Normalised Divergence Indicator");
    indicator:description("Normalised Divergence Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    AddSymbol(1);
    AddSymbol(2);
    
    indicator.parameters:addInteger("AveragePeriod", "AveragePeriod", "AveragePeriod", 10);

    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clrIndex", "Index Color", "", core.rgb(255, 0, 0));
end

local source;
local barSize;
local SS;
local loading = false;
local offset;
local weekoffset;
local AveragePeriod;

-- indexes for the instruments in the data table
local SymbolCount=0;
local last = nil;
-- data table
local data = {};
local PriceDiff;

function AddSymbol(ParName)
 indicator.parameters:addString("Symbol"  .. ParName, "The instrument " .. ParName, "", "");
 indicator.parameters:setFlag("Symbol"  .. ParName, core.FLAG_INSTRUMENTS);
end

-- add a new item into the data table
-- index        - is the index of the item in the table
-- instrument   - the instrument name
function AddCollectionItem(index, instrument)
    local t, coll, from, to, tmp;
    t = {};
    t.instrument = instrument;
    t.data = nil;
    t.loading = false;
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
    SymbolCount=0;
    for i=1,2,1 do
     SymbName=instance.parameters:getString("Symbol" .. i);
     AddCollectionItem(i, SymbName);
    end
    
end

-- prepare the indicator
function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    AveragePeriod=instance.parameters.AveragePeriod;

    InitCollection();

    local name = profile:id();
    instance:name(name);
    if nameOnly then
        return;
    end
    PriceDiff = instance:addInternalStream(source:first(), 0);
    SS = instance:addStream("SS", core.Bar, name .. ".SS", "SS", instance.parameters.clrIndex, 0);
    SS:setPrecision(math.max(2, instance.source:getPrecision()));
    SS:addLevel(2);
    SS:addLevel(3);
    SS:addLevel(4);
    SS:addLevel(-2);
    SS:addLevel(-3);
    SS:addLevel(-4);
end

local p = {};

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
    p = core.findDate (t.data, date, false);
    if p < 0 then
        return 0, 0;
    end
    return t.data.close[p];
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
        a = GetPrice(i, lastdate);
        if a == 0 then
            absent = true;
        end
        p[i] = a;

    end

    if loading then
        SS:setBookmark(1, period);
        return ;
    end

    if absent then
        if SS:hasData(period - 1) then
            SS[period] = SS[period - 1];
        end
    else
        PriceDiff[period]=p[1]-p[2];
        if period>source:first()+AveragePeriod then
         SS[period]=(PriceDiff[period]-mathex.avg(PriceDiff,core.rangeTo(period,AveragePeriod)))/mathex.stdev(PriceDiff,core.rangeTo(period,AveragePeriod));
        end 
    end

    period = period + 1;

    if period > 0 and period == source:size() - 1 then
        SS[period] = SS[period - 1];
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
    period = SS:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    instance:updateFrom(period);
end
 