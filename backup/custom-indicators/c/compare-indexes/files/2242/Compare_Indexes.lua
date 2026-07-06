-- Id: 789
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1170&p=2242#p2242

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Compare Indexes indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addString("Index1", "Index1", "", "EUR/USD");
    indicator.parameters:addString("Index2", "Index2", "", "GBP/USD");
    indicator.parameters:addDouble("Coeff1", "Cotff1", "", 1);
    indicator.parameters:addDouble("Coeff2", "Cotff2", "", -1);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Line color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first=nil;
local source = nil;
local barSize;
local usdx;
local loading = false;
local offset;
local weekoffset;
local Comp = nil;
local Index1;
local Index2;
local Coeff1;
local Coeff2;
local IndData1=1;
local IndData2=2;
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
    AddCollectionItem(IndData1, Index1, Coeff1);
    AddCollectionItem(IndData2, Index2, Coeff2);
end



function Prepare(nameOnly)
    source = instance.source;
    Index1=instance.parameters.Index1;
    Index2=instance.parameters.Index2;
    Coeff1=instance.parameters.Coeff1;
    Coeff2=instance.parameters.Coeff2;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    
    InitCollection();
    local name = profile:id() .. "(" .. source:name() .. ", (" .. Coeff1 .. ")*" .. Index1 .. "+(" .. Coeff2 .. ")*" .. Index2 .. " )";
    instance:name(name);
    if nameOnly then 
        return;
    end
    Comp = instance:addStream("Compare", core.Line, name, "Compare", instance.parameters.color, first)
    Comp:setPrecision(math.max(2, instance.source:getPrecision()));
	Comp:setWidth(instance.parameters.width);
    Comp:setStyle(instance.parameters.style);
end

local p = {};
local w = {};

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
    p = findDateFast(t.data, date, false);
    if p < 0 then
        return 0, 0;
    end
    return t.data.close[p], t.weight;
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
        Comp:setBookmark(1, period);
        return ;
    end

    if absent then
        if Comp:hasData(period - 1) then
            Comp[period] = Comp[period - 1];
        end
    else
        x = 0;
        for i = first, last, 1 do
            x = x + p[i]*w[i];
        end
        Comp[period] = x;
    end

    period = period + 1;

    if period > 0 and period == source:size() - 1 then
        Comp[period] = Comp[period - 1];
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
    period = Comp:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    instance:updateFrom(period);
end


function findDateFast(stream, date, precise)
    local datesec = nil;
    local periodsec = nil;
    local min, max, mid;

    datesec = math.floor(date * 86400 + 0.5)

    min = 0;
    max = stream:size() - 1;

    while true do
        mid = math.floor((min + max) / 2);
        periodsec = math.floor(stream:date(mid) * 86400 + 0.5);
        if datesec == periodsec then
            return mid;
        elseif datesec > periodsec then
            min = mid + 1;
        else
            max = mid - 1;
        end
        if min > max then
            if precise then
                return -1;
            else
                return min - 1;
            end
        end
    end
end

