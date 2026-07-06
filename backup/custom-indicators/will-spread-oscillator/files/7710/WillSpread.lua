-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3253
-- Id: 9914

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
    indicator:name("Will spread indicator");
    indicator:description("Will spread indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Symbol", "The other symbol", "", "");
    indicator.parameters:setFlag("Symbol", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
    indicator.parameters:addInteger("FastPeriod", "Fast period", "", 3);
    indicator.parameters:addInteger("SlowPeriod", "Slow period", "", 15);
    indicator.parameters:addString("Correlation", "Correlation", "", "direct");
    indicator.parameters:addStringAlternative("Correlation", "direct", "", "direct");
    indicator.parameters:addStringAlternative("Correlation", "inverse", "", "inverse");
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("level_overboughtsold_color", "Zero Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

local first=nil;
local source = nil;
local barSize;
local usdx;
local loading = false;
local offset;
local weekoffset;
local Price;
local IndData=1;
local last=nil;
local data = {};
local buff=nil;
local Spr;
local FastMA;
local SlowMA;

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
    AddCollectionItem(IndData, instance.parameters.Symbol, 1);
end



function Prepare(nameOnly)
    source = instance.source;
    Price=instance.parameters.Price;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    
    InitCollection();
    local name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.Symbol .. "," .. instance.parameters.FastPeriod .. "," .. instance.parameters.SlowPeriod .. " )";
    instance:name(name);
    if nameOnly then
        return;
    end
    Spr = instance:addInternalStream(source:first(), 0);
    FastMA = core.indicators:create("EMA", Spr, instance.parameters.FastPeriod);
    SlowMA = core.indicators:create("EMA", Spr, instance.parameters.SlowPeriod);
    buff = instance:addStream("buff", core.Line, name, "WS", instance.parameters.clr, first);
    buff:setPrecision(math.max(2, instance.source:getPrecision()));
	buff:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	buff:setWidth(instance.parameters.width);
    buff:setStyle(instance.parameters.style);
   

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
    if Price=="close" then
     return t.data.close[p];
    elseif Price=="open" then
     return t.data.open[p];
    elseif Price=="high" then
     return t.data.high[p];
    elseif Price=="low" then
     return t.data.low[p];
    elseif Price=="median" then
     return t.data.median[p];
    elseif Price=="typical" then
     return t.data.typical[p];
    else
     return t.data.weighted[p];
    end 
end

local lastdate = nil;

function Update(period, mode)
    if loading or period <= source:first() then
        return ;
    end

    if lastdate ~= nil and source:date(period) == lastdate then
        return ;
    end

    lastdate = source:date(period);

    local i, x, absent, Pr;
    absent = false;
    for i = first, last, 1 do
        Pr = GetPrice(i, lastdate);
        if Pr == 0 then
            absent = true;
        end
    end

    if loading then
        buff:setBookmark(1, period);
        return ;
    end

    local CurrPrice;
    if Price=="close" then
     CurrPrice=source.close[period];
    elseif Price=="open" then
     CurrPrice=source.open[period];
    elseif Price=="high" then
     CurrPrice=source.high[period];
    elseif Price=="low" then
     CurrPrice=source.low[period];
    elseif Price=="median" then
     CurrPrice=source.median[period];
    elseif Price=="typical" then
     CurrPrice=source.typical[period];
    else
     CurrPrice=source.weighted[period];
    end 
   

    if absent then
        if open:hasData(period - 1) then
            buff[period]=buff[period-1];
        end
    else
        if instance.parameters.Correlation=="direct" then
         Spr[period] = Pr/CurrPrice*100;
        else
	 Spr[period] = CurrPrice/Pr*100;
	end 
    end

    FastMA:update(mode);
    SlowMA:update(mode);
    buff[period]=FastMA.DATA[period]-SlowMA.DATA[period];   


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
    period = buff:getBookmark(1);

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

