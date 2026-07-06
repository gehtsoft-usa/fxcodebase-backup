-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=607


--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("High/Low Bands (Advanced)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BS", "Bar Size to display High/Low", "", "D1");
    indicator.parameters:addBoolean("YTD", "Show yesterday band", "Choose yes to show yesterday band and no to show today band", false);
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clrB", "High/Low Band Color", "", core.rgb(192, 192, 192));
    indicator.parameters:addBoolean("ML", "Show middle line", "Show middle line", false);
    indicator.parameters:addBoolean("OL", "Show open line", "Show middle line", true);
    indicator.parameters:addColor("clrO", "Open line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "H/L dot size", "H/L line width", 1, 1, 5);
    indicator.parameters:addInteger("A", "High/Low Band transparency (%)", "", 90, 0, 100);
end

local source;                   -- the source
local hilo_data = nil;          -- the high/low data
local H;                        -- high stream
local L;                        -- low stream
local M = nil;                        -- middle stream
local BS;
local BSLen;
local dates;                    -- candle dates
local host;
local offset;
local weekoffset;
local candles;                  -- stream of the candle's dates
local YTD;
local ML;
local OL;
local O = nil;

function Prepare()
    source = instance.source;
    host = core.host;
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    BS = instance.parameters.BS;
    ML = instance.parameters.ML;
    OL = instance.parameters.OL;
    YTD = instance.parameters.YTD;
    local YTDn;

    if YTD then
        YTDn = "prev";
    else        
        YTDn = "curr";
    end

    local l1, l2;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l1 = e - s;
    s, e = core.getcandle(BS, core.now(), 0);
    l2 = e - s;
    BSLen = l2; -- remember length of the period
    assert(l1 <= l2, "The chosen time frame must be the same of longer than the chart time frame");

    local name = profile:id() .. "(" .. source:name() .. "," .. BS .. "," .. YTDn .. ")";
    instance:name(name);
    H = instance:addStream("H", core.Dot, name .. ".H", "H", instance.parameters.clrB, 0);
    L = instance:addStream("L", core.Dot, name .. ".L", "L", instance.parameters.clrB, 0);
    H:setWidth(instance.parameters.widthLinReg);
    L:setWidth(instance.parameters.widthLinReg);
    if ML then
     M = instance:addStream("M", core.Dot, name .. ".M", "M", instance.parameters.clrB, 0);
     M:setWidth(instance.parameters.widthLinReg);
    end
    if OL then
     O = instance:addStream("O", core.Dot, name .. ".O", "O", instance.parameters.clrO, 0);
     O:setWidth(instance.parameters.widthLinReg);
    end
    instance:createChannelGroup("HL", "HL", H, L, instance.parameters.clrB, 100 - instance.parameters.A);
    candles = instance:addInternalStream(0, 0);
end


local loading = false;
local loadingFrom, loadingTo;
local pday = nil;

-- the function which is called to calculate the period
function Update(period, mode)
    -- get date and time of the hi/lo candle in the reference data
    local hilo_candle;
    hilo_candle = core.getcandle(BS, source:date(period), offset, weekoffset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading and hilo_candle >= loadingFrom and (loadingTo == 0 or hilo_candle <= loadingTo) then
        return ;
    end

    if not(source:isAlive() and period == source:size() - 1) then
        -- replicate the previous date in case it is the same upscale candle
        if (period > source:first() and candles:hasData(period - 1) and candles[period - 1] == hilo_candle) then
            H[period] = H[period - 1];
            L[period] = L[period - 1];
            if ML then
             M[period] = M[period - 1];
            end 
            if OL then
             O[period] = O[period - 1];
            end 
            candles[period] = hilo_candle;
        end
    end

    -- if the period is before the source start
    -- the do nothing
    if period < source:first() then
        return ;
    end

    -- if data is not loaded yet at all
    -- load the data
    if hilo_data == nil then
        -- there is no data at all, load initial data
        local to, t;
        local from;
        if (source:isAlive()) then
            -- if the source is subscribed for updates
            -- then subscribe the current collection as well
            to = 0;
        else
            -- else load up to the last currently available date
            t, to = core.getcandle(BS, source:date(period), offset, weekoffset);
        end

        from = core.getcandle(BS, source:date(source:first()), offset, weekoffset) - BSLen * 5;
        loading = true;
        H:setBookmark(1, period);
        loadingFrom = from;
        loadingTo = to;
        hilo_data = host:execute("getHistory", 1, source:instrument(), BS, from, to, source:isBid());
        return ;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (hilo_candle < hilo_data:date(0)) then
        H:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = hilo_candle - BSLen * 5;
        loadingTo = hilo_data:date(0);
        host:execute("extendHistory", 1, hilo_data, loadingFrom, loadingTo);
        return ;
    end

    -- check whether the requested candle is after
    -- the reference collection end
    if (not(source:isAlive()) and hilo_candle > hilo_data:date(hilo_data:size() - 1)) then
        H:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = hilo_data:date(hilo_data:size() - 1);
        loadingTo = hilo_candle;
        host:execute("extendHistory", 1, hilo_data, loadingFrom, loadingTo);
        return ;
    end

    local hilo_i = core.findDate(hilo_data, hilo_candle, false);

    -- candle is not found
    if (hilo_i == nil) then
        return ;
    end

    if YTD then
        if hilo_i == 0 then
            return;
        end
        hilo_i = hilo_i - 1;
    end

    H[period] = hilo_data.high[hilo_i];
    L[period] = hilo_data.low[hilo_i];
    if ML then
     M[period]=(H[period]+L[period])/2;
    end 
    if OL then
     O[period]=hilo_data.open[hilo_i];
    end 
    candles[period] = hilo_candle;

    if source:isAlive() and period > source:first() and period == source:size() - 1 then
        -- update all today's data in case today's high low is changed
        if candles:hasData(period - 1) and candles[period - 1] == hilo_candle and
           ((H[period - 1] ~= H[period]) or (L[period - 1] ~= L[period]))  then
            local i = period - 1;
            while i > 0 and candles:hasData(i) and candles[i] == hilo_candle do
                H[i] = hilo_data.high[hilo_i];
                L[i] = hilo_data.low[hilo_i];
                if ML then
                 M[i]=(H[i]+L[i])/2;
                end 
                if OL then
                 O[period]=hilo_data.open[hilo_i];
                end 
                i = i - 1
            end
        end
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = H:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end
 