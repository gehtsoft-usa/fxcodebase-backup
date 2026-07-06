-- Id: 12179
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2379

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Instrument Index");
    indicator:description("Calculates the instrument index in on the base of (XXX/USD or USD/XXX) and USDX");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Symbol", "Symbol", "", "EUR");

    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clrIndex", "Index Color", "", core.rgb(255, 255, 128));
end

local source;
local barSize;
--local usdx;
local loading = false;
local offset;
local weekoffset;
local Symbol;
local SymbolWeight;

-- indexes for the instruments in the data table
local eurusd = 1;
local usdjpy = 2;
local gbpusd = 3;
local usdcad = 4;
local usdchf = 5;
local usdsek = 6;
local xxxusd = 7;
local first = nil;
local last = nil;

local open, close, high, low;
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
    AddCollectionItem(usdsek, "USD/SEK", 0.042);
    AddCollectionItem(usdchf, "USD/CHF", 0.036);
    if Symbol~="USD"
	and  Symbol~= instance.parameters.Symbol
	then
     AddCollectionItem(xxxusd, Symbol, SymbolWeight);
    end 
end

function CheckSymbol(Symb)
 local Table=core.host:findTable("offers");
 if Table:find("Instrument",Symb)~=nil then
  return true;
 else
  return false; 
 end
end

-- prepare the indicator
function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    Symbol=instance.parameters.Symbol;
    if CheckSymbol(Symbol .. "/USD")==true then
     Symbol=Symbol .. "/USD";
     SymbolWeight=1.;
    end
    if CheckSymbol("USD/" .. Symbol)==true then
     Symbol="USD/" .. Symbol;
     SymbolWeight=-1.;
    end
    
	  if  not(checkReady("offers")) then
            return ;
     end
    InitCollection();

    local name = profile:id() .. "(" .. instance.parameters.Symbol .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	open = instance:addInternalStream(0, 0);
	close = instance:addInternalStream(0, 0);
	high = instance:addInternalStream(0, 0);
	low = instance:addInternalStream(0, 0);
	instance:createCandleGroup ("OtherX1", "OtherX1", open, high, low, close);
   --usdx = instance:addStream("X", core.Line, name .. ".X", "X", instance.parameters.clrIndex, 0);
end

local o = {};
local c = {};
local h = {};
local l = {};
local w = {};

-- get the price of the specified instrument
function GetPrice(index, date)
    local t;

    local from, to, tmp;

    t = data[index];
	
	if t.instrument == instance.parameters.Symbol
	or t.instrument == nil  
	then 
	return 0,0;
	end

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
    return t.data.open[p],  t.data.close[p], t.data.high[p], t.data.low[p], t.weight;
end

function checkReady(table)
    local rc;
   
        rc = core.host:execute("isTableFilled", table);
	
	
	return rc;
		
end		

local lastdate = nil;

-- the function which is called to calculate the period
function Update(period, mode)

    if  not(checkReady("offers")) then
            return ;
     end

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
        o[i], c[i],h[i],l[i],w[i] = GetPrice(i, lastdate);
        if o[i] == 0 then
            absent = true;
        end
       
    end

    if loading then
        open:setBookmark(1, period);
        return ;
    end

    if absent then
        if open:hasData(period - 1) then
            open[period] = open[period - 1];
			close[period] = close[period - 1];
			high[period] = high[period - 1];
			low[period] = low[period - 1];
        end
    else
        xopen = 50.14348112;
		xclose = 50.14348112;
		xhigh = 50.14348112;
		xlow = 50.14348112;
        for i = first, last, 1 do
            xopen = xopen * math.pow(o[i], w[i]);
			 xclose = xclose * math.pow(c[i], w[i]);
			  xhigh = xhigh * math.pow(h[i], w[i]);
			   xlow = xlow * math.pow(l[i], w[i]);
        end
		
		 open[period] = xopen;
			close[period] = xclose;
			high[period] = xhigh;
			low[period] = xlow;
        
    end

    period = period + 1;

    if period > 0 and period == source:size() - 1 then
            open[period] = open[period - 1];
			close[period] = close[period - 1];
			high[period] = high[period - 1];
			low[period] = low[period - 1];
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
 