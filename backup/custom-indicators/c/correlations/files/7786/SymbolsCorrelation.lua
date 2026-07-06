-- Id: 2979
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3278

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
    indicator:name("Symbols correlation indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("PriceX", "The price X", "", "close");
    indicator.parameters:addStringAlternative("PriceX", "open", "", "open");
    indicator.parameters:addStringAlternative("PriceX", "high", "", "high");
    indicator.parameters:addStringAlternative("PriceX", "low", "", "low");
    indicator.parameters:addStringAlternative("PriceX", "close", "", "close");
    indicator.parameters:addStringAlternative("PriceX", "median", "", "median");
    indicator.parameters:addStringAlternative("PriceX", "typical", "", "typical");
    indicator.parameters:addStringAlternative("PriceX", "weighted", "", "weighted");
    indicator.parameters:addString("SymbolX", "The instrument X", "", "");
    indicator.parameters:setFlag("SymbolX", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("PriceY", "The price Y", "", "close");
    indicator.parameters:addStringAlternative("PriceY", "open", "", "open");
    indicator.parameters:addStringAlternative("PriceY", "high", "", "high");
    indicator.parameters:addStringAlternative("PriceY", "low", "", "low");
    indicator.parameters:addStringAlternative("PriceY", "close", "", "close");
    indicator.parameters:addStringAlternative("PriceY", "median", "", "median");
    indicator.parameters:addStringAlternative("PriceY", "typical", "", "typical");
    indicator.parameters:addStringAlternative("PriceY", "weighted", "", "weighted");
    indicator.parameters:addString("SymbolY", "The instrument Y", "", "");
    indicator.parameters:setFlag("SymbolY", core.FLAG_INSTRUMENTS);
    indicator.parameters:addInteger("LeftBorder", "LeftBorder", "", 0);    
    indicator.parameters:addInteger("RightBorder", "RightBorder", "", 300);    
    indicator.parameters:addInteger("TopBorder", "TopBorder", "", 0);    
    indicator.parameters:addInteger("BottomBorder", "BottomBorder", "", -300);    
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
end

local first=nil;
local source = nil;
local barSize;
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
local GMinX;
local GMaxX;
local GMinY;
local GMaxY;
local font;
local font2;

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
    AddCollectionItem(1, instance.parameters.SymbolX, 1);
    AddCollectionItem(2, instance.parameters.SymbolY, 1);
end

function Prepare(nameOnly)
    source = instance.source;
    GMinX=instance.parameters.LeftBorder;
    GMaxX=instance.parameters.RightBorder;
    GMaxY=-instance.parameters.BottomBorder;
    GMinY=-instance.parameters.TopBorder;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    
    InitCollection();
    local name = profile:id() .. "(" .. instance.parameters.SymbolX .. ", " .. instance.parameters.PriceX .. " vs " .. instance.parameters.SymbolY .. ", " .. instance.parameters.PriceY .. " )";
    open = instance:addStream("open", core.Line, name .. ".SS", "SS", instance.parameters.clr, 0);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:name(name);
    if nameOnly then
        return;
    end
    font = core.host:execute("createFont", "Wingdings", 20, true, false);
    font2 = core.host:execute("createFont", "Arial", 20, true, false);
    local i;
    local ii=0;
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
    p = core.findDate(t.data, date, false);
    if p < 0 then
        return 0, 0;
    end
    if index==1 then
     if instance.parameters.PriceX=="open" then
      return t.data.open[p];
     elseif instance.parameters.PriceX=="close" then
      return t.data.close[p];
     elseif instance.parameters.PriceX=="high" then
      return t.data.high[p];
     elseif instance.parameters.PriceX=="low" then
      return t.data.low[p];
     elseif instance.parameters.PriceX=="median" then
      return t.data.median[p];
     elseif instance.parameters.PriceX=="typical" then
      return t.data.typical[p];
     else
      return t.data.weighted[p];
     end 
    else
     if instance.parameters.PriceY=="open" then
      return t.data.open[p];
     elseif instance.parameters.PriceY=="close" then
      return t.data.close[p];
     elseif instance.parameters.PriceY=="high" then
      return t.data.high[p];
     elseif instance.parameters.PriceY=="low" then
      return t.data.low[p];
     elseif instance.parameters.PriceY=="median" then
      return t.data.median[p];
     elseif instance.parameters.PriceY=="typical" then
      return t.data.typical[p];
     else
      return t.data.weighted[p];
     end 
    end
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
    GetPrice(1, lastdate);
    GetPrice(2, lastdate);

    local i, x, absent, o,h,l,c;
    absent = false;

    if loading then
        open:setBookmark(1, period);
        return ;
    end


    period = period + 1;

    if period > 0 and period == source:size() - 1 then
     local MaxX=core.max(data[1].data.high,core.rangeFrom(data[1].data:first(),data[1].data:size()-1));
     local MinX=core.min(data[1].data.low,core.rangeFrom(data[1].data:first(),data[1].data:size()-1));
     local MaxY=core.max(data[2].data.high,core.rangeFrom(data[2].data:first(),data[2].data:size()-1));
     local MinY=core.min(data[2].data.low,core.rangeFrom(data[2].data:first(),data[2].data:size()-1));
     for i=first,period-1,1 do
      absent=false;
      lastdate=source:date(i);
      a1=GetPrice(1,lastdate);
      if a1==0 then
       absent=true;
      end
      a2=GetPrice(2,lastdate);
      if a2==0 then
       absent=true;
      end
      if absent==false then
       PosX=GMaxX-(a1-MinX)*(GMaxX-GMinX)/(MaxX-MinX);
       PosY=GMinY+(a2-MinY)*(GMaxY-GMinY)/(MaxY-MinY);
       core.host:execute("drawLabel1", i,PosX, core.CR_CENTER,PosY, core.CR_TOP, core.H_Center, core.V_Center,
        font, instance.parameters.clr,  "\158");
       
      end
     end
     
     local MaxFirst=math.max(data[1].data:first(),data[2].data:first());
     local MinSize=math.min(data[1].data:size(),data[2].data:size())-1;
     local Data1;
     local Data2;
     if instance.parameters.PriceX=="open" then
      Data1=data[1].data.open;
     elseif instance.parameters.PriceX=="close" then
      Data1=data[1].data.close;
     elseif instance.parameters.PriceX=="high" then
      Data1=data[1].data.high;
     elseif instance.parameters.PriceX=="low" then
      Data1=data[1].data.low;
     elseif instance.parameters.PriceX=="median" then
      Data1=data[1].data.median;
     elseif instance.parameters.PriceX=="typical" then
      Data1=data[1].data.typical;
     else
      Data1=data[1].data.weighted;
     end 
     if instance.parameters.PriceY=="open" then
      Data2=data[2].data.open;
     elseif instance.parameters.PriceY=="close" then
      Data2=data[2].data.close;
     elseif instance.parameters.PriceY=="high" then
      Data2=data[2].data.high;
     elseif instance.parameters.PriceY=="low" then
      Data2=data[2].data.low;
     elseif instance.parameters.PriceY=="median" then
      Data2=data[2].data.median;
     elseif instance.parameters.PriceY=="typical" then
      Data2=data[2].data.typical;
     else
      Data2=data[2].data.weighted;
     end 
     local CorrCoeff=mathex.correl(Data1,Data2,MaxFirst,MinSize,MaxFirst,MinSize);
     CorrCoeff=math.floor(CorrCoeff*1000)/1000;
     core.host:execute("drawLabel1", period,GMaxX, core.CR_CENTER,GMaxY, core.CR_TOP, core.H_Right, core.V_Bottom,
      font2, instance.parameters.clr,  "" .. CorrCoeff);
     
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
 