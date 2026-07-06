-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4048

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
    indicator:name("Bigger timeframe indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BS", "Time frame to calculate indicator", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
    indicator.parameters:addString("IN", "Indicator", "", "");
    indicator.parameters:setFlag("IN",core.FLAG_ONLYINDICATORS);
    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator:setTag("RequiredSourceParam", "IN");    
end

local source;                   -- the source
local bf_data = nil;          -- the high/low data
local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local OutBuffs={};
local day_offset;
local week_offset;
local extent;
local Ind;

function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    
    BS = instance.parameters.BS;
    local name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.IN .. ", " .. BS .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    local ind_ = core.indicators:findIndicator(instance.parameters:getString("IN"));
    local params = instance.parameters:getCustomParameters("IN");
    Ind = ind_:createInstance(source, params);
    
    local i;
    for i=0,Ind:getStreamCount()-1,1 do
     OutBuffs[i]=instance:addStream("Out" .. i, core.Line, "." .. Ind:getStream(i):name(), Ind:getStream(i):name(), instance.parameters.clr, 0);
    end

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    extent = 32;

    local s, e, s1, e1;

    s=source:date(source:size()-2);
    e=source:date(source:size()-1);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);


end


local loading = false;
local loadingFrom, loadingTo;
local pday = nil;

-- the function which is called to calculate the period
function Update(period, mode)
    -- get date and time of the hi/lo candle in the reference data
    local bf_candle;
    bf_candle = core.getcandle(BS, source:date(period), day_offset, week_offset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading and bf_candle >= loadingFrom and (loadingTo == 0 or bf_candle <= loadingTo) then
        return ;
    end

    -- if the period is before the source start
    -- the do nothing
    if period < source:first() then
        return ;
    end

    -- if data is not loaded yet at all
    -- load the data
    if bf_data == nil then
        -- there is no data at all, load initial data
        local to, t;
        local from;

        if (source:isAlive()) then
            -- if the source is subscribed for updates
            -- then subscribe the current collection as well
            to = 0;
        else
            -- else load up to the last currently available date
            t, to = core.getcandle(BS, source:date(period), day_offset, week_offset);
        end

        from = core.getcandle(BS, source:date(source:first()), day_offset, week_offset);
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(from * 86400 - (bf_length * extent) + 0.5) / 86400;
        local nontrading, nontradingend;
        nontrading, nontradingend = core.isnontrading(from, day_offset);
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * extent) + 0.5) / 86400;
        end
        loading = true;
        loadingFrom = from;
        loadingTo = to;
        bf_data = host:execute("getHistory", 1, source:instrument(), BS, loadingFrom, to, source:isBid());
    local ind_ = core.indicators:findIndicator(instance.parameters:getString("IN"));
    local params = instance.parameters:getCustomParameters("IN");
    if  ind_:requiredSource() == core.Tick then
     if source:name()=="close" then
      Ind = ind_:createInstance(bf_data.close, params);
     elseif source:name()=="open" then
      Ind = ind_:createInstance(bf_data.open, params);
     elseif source:name()=="high" then
      Ind = ind_:createInstance(bf_data.high, params);
     elseif source:name()=="low" then
      Ind = ind_:createInstance(bf_data.low, params);
     elseif source:name()=="median" then
      Ind = ind_:createInstance(bf_data.median, params);
     elseif source:name()=="typical" then
      Ind = ind_:createInstance(bf_data.typical, params);
     else
      Ind = ind_:createInstance(bf_data.weighted, params);
     end
    else
     Ind = ind_:createInstance(bf_data, params);
    end 
    first = Ind.DATA:first();
    
        return ;
    end
    OutBuffs[0]:setBookmark(1, period);

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        OutBuffs[0]:setBookmark(1, period);
        if loading then
            return ;
        end
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(bf_candle * 86400 - (bf_length * extent) + 0.5) / 86400;
        local nontrading, nontradingend;
        nontrading, nontradingend = core.isnontrading(from, day_offset);
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * extent) + 0.5) / 86400;
        end
        loading = true;
        loadingFrom = from;
        loadingTo = bf_data:date(0);
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    -- check whether the requested candle is after
    -- the reference collection end
    if (not(source:isAlive()) and bf_candle > bf_data:date(bf_data:size() - 1)) then
        OutBuffs[0]:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = bf_data:date(bf_data:size() - 1);
        loadingTo = bf_candle;
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    Ind:update(mode);
    local p;
    p = core.findDate(bf_data, bf_candle, true);
    if p == -1 then
        return ;
    end
    
    local i;
    for i=0,Ind:getStreamCount()-1,1 do
     if Ind:getStream(i):hasData(p) then
      OutBuffs[i][period]=Ind:getStream(i)[p];
     else
      OutBuffs[i][period]=nil; 
     end 
    end
    
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = OutBuffs[0]:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end

