-- Id: 3188
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3497&sid=6eb856b7a0e3a5289eb215e2282f8b31

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
    indicator:name("Other instrument ZigZag");
    indicator:description("Other instrument ZigZag");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Swing");
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Instrument", "Instrument to calculate ZigZag", "", "");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS );
    indicator.parameters:addInteger("Depth", "Depth", "Depth", 12, 1, 10000);
    indicator.parameters:addInteger("Deviation", "Deviation", "Deviation", 5, 1, 1000);
    indicator.parameters:addInteger("Backstep", "Backstep", "Backstep", 3, 1, 10000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Zig_color", "Up color", "Up color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Zag_color", "Dn color", "Dn color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Text_color", "Text color", "Text color", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("TextSize", "Text size", "Text size", 10);
end

local first=nil;
local source = nil;
local barSize;
local Depth;
local Deviation;
local Backstep;
local loading = false;
local offset;
local weekoffset;
local Index;
local IndData=1;
local last=nil;
local data = {};
local ZigZag=nil;
local HighMap=0;
local LowMap=0;
local SearchMode;
local Peak;
local HighB;
local LowB;
local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;
local ZigC;
local ZagC;
local TextBuff=nil;

-- optimization hint
local peak_count = 0;

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
    AddCollectionItem(IndData, instance.parameters.Instrument, 1);
end



function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
   
    InitCollection();
    local name = profile:id() .. "(" .. instance.parameters.Instrument .. ", " .. instance.parameters.Depth .. ", " .. instance.parameters.Deviation .. ", " .. instance.parameters.Backstep .. " )";
    instance:name(name);
    if nameOnly then
        return;
    end
    ZigZag = instance:addStream("ZigZag", core.Line, name, "ZigZag", instance.parameters.Zig_color, 0);
    ZigZag:setPrecision(math.max(2, instance.source:getPrecision()));
    ZigZag:setWidth(instance.parameters.widthZigZag);
    ZigZag:setStyle(instance.parameters.styleZigZag);
    TextBuff = instance:createTextOutput ("Text", "Text", "Arial", instance.parameters.TextSize, core.H_Center, core.V_Center, instance.parameters.Text_color, first);
    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
    HighB = instance:addInternalStream(0, 0);
    LowB = instance:addInternalStream(0, 0);
    SearchMode = instance:addInternalStream(0, 0);
    Peak = instance:addInternalStream(0, 0);
    ZigC = instance.parameters.Zig_color;
    ZagC = instance.parameters.Zag_color;
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
    return t.data.open[p], t.data.high[p], t.data.low[p], t.data.close[p];
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

    local i, x, absent, o,h,l,c;
    absent = false;
    o,h,l,c = GetPrice(1, lastdate);
    if o == 0 then
      absent = true;
    end
    HighB[period]=h;
    LowB[period]=l;
    
    if loading then
        LowB:setBookmark(1, period);
        return ;
    end

    if period >= Depth then
        -- fill high/low maps
        local range = core.rangeTo(period, Depth);
        local val;
        local i;
        -- get the lowest low for the last depth periods
        val = core.min(LowB, range);
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lastlow = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (LowB[period] - val) > (data[1].data:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = 0;
                    end
                end
            end
        end
        if LowB[period] == val then
            LowMap[period] = val;
        else
            LowMap[period] = 0;
        end
        -- get the lowest low for the last depth periods
        val = core.max(HighB, range);
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lasthigh = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (val - HighB[period]) > (data[1].data:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = 0;
                    end
                end
            end
        end

        if HighB[period] == val then
            HighMap[period] = val;
        else
            HighMap[period] = 0
        end

        local start;
        local last_peak;
        local last_peak_i;
        local prev_peak;
        local searchMode = searchBoth;

        i = GetPeak(-4);
        if i == -1 then
            prev_peak = nil;
        else
            prev_peak = i;
        end

        start = Depth;
        i = GetPeak(-3);
        if i == -1 then
            last_peak_i = nil;
            last_peak = nil;
        else
            last_peak_i = i;
            last_peak = Peak[i];
            searchMode = SearchMode[i];
            start = i;
        end

        peak_count = peak_count - 3;
        
if period > 0 and period == data[1].data:size() - 2 then
        for i = start, period, 1 do
            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = HighMap[i];
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = LowMap[i];
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i];
                    TextBuff:setNoData(last_peak_i);
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        if Peak[prev_peak] > LowMap[i] then
                            core.drawLine(ZigZag, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZagC);
                            ZigZag:setColor(prev_peak, ZigC);
                            TextBuff:set(i,LowMap[i],"" .. math.floor((HighMap[prev_peak]-LowMap[i])/data[1].data:pipSize()) .. " p");
                        else
                            core.drawLine(ZigZag, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC);
                            ZigZag:setColor(prev_peak, ZagC);
                            TextBuff:set(i,LowMap[i],"" .. math.floor((HighMap[prev_peak]-LowMap[i])/data[1].data:pipSize()) .. " p");
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC);
                    ZigZag:setColor(last_peak_i, ZagC);
                    TextBuff:set(i,HighMap[i],"" .. math.floor((HighMap[i]-LowMap[last_peak_i])/data[1].data:pipSize()) .. " p");
                    prev_peak = last_peak_i;
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i];
                    TextBuff:setNoData(last_peak_i);
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        core.drawLine(ZigZag, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i, ZigC);
                        ZigZag:setColor(prev_peak, ZagC);
                        TextBuff:set(i,HighMap[i],"" .. math.floor((HighMap[i]-LowMap[prev_peak])/data[1].data:pipSize()) .. " p");
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    if  last_peak > LowMap[i] then
                        core.drawLine(ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC);
                        ZigZag:setColor(last_peak_i, ZigC);
                        TextBuff:set(i,LowMap[i],"" .. math.floor((HighMap[last_peak_i]-LowMap[i])/data[1].data:pipSize()) .. " p");
                    else
                        core.drawLine(ZigZag, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC);
                        ZigZag:setColor(last_peak_i, ZagC);
                        TextBuff:set(i,LowMap[i],"" .. math.floor((HighMap[last_peak_i]-LowMap[i])/data[1].data:pipSize()) .. " p");
                    end
                    prev_peak = last_peak_i;
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            end
        end
    end
     
    

    end
 

end

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1;
    ZigZag:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function ReplaceLastPeak(period, mode, peak)
    --peak_count = peak_count + 1;
    ZigZag:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function GetPeak(offset)
    local peak;
    peak = peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = ZigZag:getBookmark(peak);
    if peak < 0 then
        return -1;
    end
    return peak;
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
    period = LowB:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    instance:updateFrom(period);
end

