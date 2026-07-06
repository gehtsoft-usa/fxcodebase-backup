-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3347

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Constant Range indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BarSize", "Size of bar in ticks", "", 10);
    indicator.parameters:addString("TF", "Time frame to calculate", "", "m1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    
end

local first=nil;
local source = nil;
local BarSize;
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
    AddCollectionItem(IndData, source:instrument(), 1);
end



function Prepare(nameOnly)
    source = instance.source;
    BarSize=instance.parameters.BarSize;
    host = core.host;
    
    local name = profile:id() .. "(" .. source:name() .. "," .. BarSize .. ", " .. instance.parameters.TF .. " )";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    first = source:first()+2;
    
    InitCollection();
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("CRB", "CRB", open, high, low, close);
end

local count=nil;

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
     local CurSec;
     if instance.parameters.TF=="t1" then
      CurSec=t:size()-1;
     else 
      CurSec=core.sum(t.volume,core.range(t:first(),t:size()-1));
     end 
     local CurSecC=math.floor(CurSec/BarSize);
     local OnlyLastBar;
     if CurSecC==LastTime and count~=nil then
      OnlyLastBar=true;
     else
      OnlyLastBar=false; 
     end
     if BackDraw==true then
      OnlyLastBar=false;
      BackDraw=false;
     end
     LastPeriod=period;
     LastTime=CurSecC;

     count=period;
     local i;
     local i2;
     o=nil;
     c=t.close[t:size()-1];
     h=t.high[t:size()-1];
     l=t.low[t:size()-1];
     local TickTime;
     if instance.parameters.TF=="t1" then
      TickTime=t:size()-1;
     else 
      TickTime=core.sum(t.volume,core.range(t:first(),t:size()-1));
     end 
     local TickTimeC=math.floor(TickTime/BarSize);
     local LastTimeC=TickTimeC;
     local FirstBar=true;
     for i=t:first(),t:size()-2,1 do
      i2=t:size()-2+t:first()-i;
      if instance.parameters.TF=="t1" then
       TickTime=i2;
      else 
       TickTime=core.sum(t.volume,core.range(i2,t:size()-1));
      end 
      TickTimeC=math.floor(TickTime/BarSize);
      if TickTimeC~=LastTimeC then
       o=t.open[i2+1];
       open[count]=o;
       close[count]=c;
       high[count]=h;
       low[count]=l;
       count=count-1;
       if FirstBar==true then 
        FirstBar=false;
       end
       if OnlyLastBar==true then
        break;
       end
       if count<=source:first()+1 then
        break;
       end
       LastTimeC=TickTimeC;
       c=t.close[i2];
       h=t.high[i2];
       l=t.low[i2];
      end
      h=math.max(h,t.high[i2]);
      l=math.min(l,t.low[i2]);
     
     end
     if OnlyLastBar==false then
      open[count]=nil;
      close[count]=nil;
      high[count]=nil;
      low[count]=nil;
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

