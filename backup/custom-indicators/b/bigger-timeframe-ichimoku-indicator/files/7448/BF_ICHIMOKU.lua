-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Bigger timeframe Ichimoku indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BS", "Time frame to calculate Ichimoku", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Tenkan", "Tenkan", "Tenkan", 9);
    indicator.parameters:addInteger("Kijun", "Kijun", "Kijun", 26);
    indicator.parameters:addInteger("Senkou", "Senkou", "Senkou", 52);
    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clrTS", "", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthSL", "", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSL", "", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSL", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("clrKS", "", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthTL", "", "", 1, 1, 5);
    indicator.parameters:addInteger("styleTL", "", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("clrCS", "", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthCS", "", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCS", "", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCS", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("clrSSA", "", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSSA", "", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSSA", "", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSA", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("clrSSB", "", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSSB", "", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSSB", "", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSB", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clrCloud", "", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("transp", "", "", 80, 0, 100);
end

local source;                   -- the source
local bf_data = nil;          -- the high/low data
local Tenkan;
local Kijun;
local Senkou;
local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local Ich;
local day_offset;
local week_offset;
local extent;
local SL;
local TL;
local CS;
local SA;
local SB;

function Prepare(nameOnly)
    source = instance.source;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS = instance.parameters.BS;
    Tenkan = instance.parameters.Tenkan;
    Kijun = instance.parameters.Kijun;
    Senkou = instance.parameters.Senkou;
    extent = Tenkan*2;

    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);

    local name = profile:id() .. "(" .. source:name() .. "," .. BS .. "," .. Tenkan .. "," .. Kijun .. "," .. Senkou .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SL = instance:addStream("SL", core.Line, name .. ".SL", "SL", instance.parameters.clrTS, 0)
    SL:setWidth(instance.parameters.widthSL);
    SL:setStyle(instance.parameters.styleSL);
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrKS, 0)
    TL:setWidth(instance.parameters.widthTL);
    TL:setStyle(instance.parameters.styleTL);
    CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, 0)
    CS:setWidth(instance.parameters.widthCS);
    CS:setStyle(instance.parameters.styleCS);
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, 0, Kijun)
    SA:setWidth(instance.parameters.widthSSA);
    SA:setStyle(instance.parameters.styleSSA);
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB, 0, Kijun)
    SB:setWidth(instance.parameters.widthSSB);
    SB:setStyle(instance.parameters.styleSSB);
    instance:createChannelGroup("SA-SB", "SA-SB", SA, SB, instance.parameters.clrCloud, 100 - instance.parameters.transp);
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
        SL:setBookmark(1, period);
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
        Ich = core.indicators:create("ICH", bf_data, Tenkan, Kijun, Senkou);
        return ;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        SL:setBookmark(1, period);
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
        SL:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = bf_data:date(bf_data:size() - 1);
        loadingTo = bf_candle;
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    Ich:update(mode);
    local p;
    p = core.findDate(bf_data, bf_candle, true);
    if p == -1 then
        return ;
    end
    if Ich:getStream(0):hasData(p) then
        SL[period] = Ich:getStream(0)[p];
    end
    if Ich:getStream(1):hasData(p) then
        TL[period] = Ich:getStream(1)[p];
    end
    if Ich:getStream(2):hasData(p) then
        CS[period] = Ich:getStream(2)[p];
    end
    if Ich:getStream(3):hasData(p+Kijun) then
        SA[period+Kijun] = Ich:getStream(3)[p+Kijun];
    end
    if Ich:getStream(4):hasData(p+Kijun) then
        SB[period+Kijun] = Ich:getStream(4)[p+Kijun];
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = SL:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end


