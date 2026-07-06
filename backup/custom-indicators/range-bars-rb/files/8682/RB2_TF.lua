-- Id: 3302
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3614

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
    indicator:name("Range indicator");
    indicator:description("Range indicator other TF (other chart)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RangeSize", "Range of bar in pips", "", 10);
    indicator.parameters:addString("TF", "Time frame to calculate", "", "m1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    
end

local first=nil;
local source = nil;
local RangeSize;
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
local open_t = nil;
local high_t = nil;
local low_t = nil;
local close_t = nil;
local Count_t;

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
    AddCollectionItem(IndData, source:instrument(), 1);
end



function Prepare(nameOnly) 
    source = instance.source;
    RangeSize=instance.parameters.RangeSize;
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    first = source:first()+2;
    
    InitCollection();
    local name = profile:id() .. "(" .. source:name() .. "," .. RangeSize .. ", " .. instance.parameters.TF .. " )";
    instance:name(name);
	
	if onlyName then
        return ;
    end
	
    open_t = instance:addInternalStream(first, 0);
    high_t = instance:addInternalStream(first, 0);
    low_t = instance:addInternalStream(first, 0);
    close_t = instance:addInternalStream(first, 0);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("RB", "RB", open, high, low, close);
end

local count=nil;

function CheckBuff(period)
 local ii;
 if Count_t>period then
  for ii=first+1,period,1 do
   open_t[ii-1]=open_t[ii];
   high_t[ii-1]=high_t[ii];
   low_t[ii-1]=low_t[ii];
   close_t[ii-1]=close_t[ii];
  end
  Count_t=Count_t-1;
 end
end

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
        t.data = host:execute("getHistory", index, t.instrument, instance.parameters.TF, from, to, source:isBid());
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
    return t.data.open[p], t.data.high[p], t.data.low[p], t.data.close[p];
end

local lastdate = nil;
local LastTime=nil;
local LastPeriod=0;
local BackDraw=false;

function Update(period, mode)
    if loading or period <= source:first() then
        return ;
    end

    if period~=LastPeriod then
     BackDraw=true;
    end
    
    if period~=source:size()-1 then
     return ;
    end
    
    
    lastdate=source:date(period);
    local absent,o,h,l,c;
    absent=false;
    o,h,l,c = GetPrice(1, lastdate);
    if o == 0 then
     absent = true;
    end
    if absent==false then
     local t=data[1].data;
     Count_t=first;
     open_t[Count_t]=t.open[t:first()];
     high_t[Count_t]=t.high[t:first()];
     low_t[Count_t]=t.low[t:first()];
     close_t[Count_t]=t.close[t:first()];

     for i=t:first()+1,t:size()-1,1 do
       if high_t[Count_t]-low_t[Count_t]>=RangeSize*t:pipSize() then
        Count_t=Count_t+1;
        CheckBuff(period);
        open_t[Count_t]=t.open[i];
        high_t[Count_t]=t.high[i];
        low_t[Count_t]=t.low[i];
        close_t[Count_t]=t.close[i];
       else
        high_t[Count_t]=math.max(high_t[Count_t],t.high[i]);
        low_t[Count_t]=math.min(low_t[Count_t],t.low[i]);
        close_t[Count_t]=t.close[i];
       end
     end 

     for i=first,period,1 do
      local NewPos=i-period+Count_t;
      if NewPos<=first then
       open[i]=nil;
       high[i]=nil;
       low[i]=nil;
       close[i]=nil;
      else
       open[i]=open_t[NewPos];
       high[i]=high_t[NewPos];
       low[i]=low_t[NewPos];
       close[i]=close_t[NewPos];
      end
     end    


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

