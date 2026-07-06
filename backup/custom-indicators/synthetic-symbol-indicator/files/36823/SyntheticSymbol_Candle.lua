-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 7005

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
    indicator:name("Synthetic Symbol");
    indicator:description("Calculates the Synthetic Symbol in on the base of selected instruments.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    for i=1,10,1 do
     AddSymbol(i);
    end

    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clrIndex", "Index Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local source;
local barSize;
local loading = false;
local offset;
local weekoffset;
local open = nil;
local high = nil;
local low = nil;
local close = nil;

-- indexes for the instruments in the data table
local SymbolCount=0;
local last = nil;
-- data table
local data = {};
local SymbolsName;
local first, last;
function AddSymbol(ParName)
 indicator.parameters:addString("Symbol" .. ParName , "Instrument", "", "EUR/USD");
 indicator.parameters:setFlag("Symbol" .. ParName , core.FLAG_INSTRUMENTS);
 indicator.parameters:addDouble("Weight" .. ParName, "Weight" .. ParName, "", 1);
end

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
    SymbolCount=0;
    SymbolsName="";
    for i=1,10,1 do
     SymbName=instance.parameters:getString("Symbol" .. i);
     SymbWeight=instance.parameters:getDouble("Weight" .. i);
     if SymbName~="- Empty -" and SymbWeight~=0 then
      SymbolCount=SymbolCount+1;
      if SymbolsName~="" then
       SymbolsName=SymbolsName .. "*";
      end
      SymbolsName=SymbolsName .. SymbName .. "^(" .. SymbWeight .. ")";
      AddCollectionItem(SymbolCount, SymbName, SymbWeight);
     end
    end
    
end

-- prepare the indicator
function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
 

    InitCollection();

    local name = profile:id() .. "(" .. SymbolsName .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first())
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), source:first())
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first())
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("USDX", "USDX", open, high, low, close);
end

local p = {};
local p2 = {};
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
    p = core.findDate (t.data, date, false);
    if p < 0 then
        return 0, 0;
    end
    return t.data.close[p], t.data.open[p], t.weight;
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

    local i, x, x2, absent, a, b, c;
    absent = false;
    for i = first, last, 1 do
        a, c, b = GetPrice(i, lastdate);
        if a == 0 then
            absent = true;
        end
        p[i] = a;
        p2[i] = c;
        w[i] = b;
    end

    if loading then
        open:setBookmark(1, period);
        return ;
    end

    if absent then

    else
        x = 1;
        x2 = 1;
        for i = first, last, 1 do
            x = x * math.pow(p[i], w[i]);
            x2 = x2 * math.pow(p2[i], w[i]);
        end
        open[period]=x2;
        close[period]=x;
        high[period]=math.max(x,x2);
        low[period]=math.min(x,x2);
    end

    period = period + 1;

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
 