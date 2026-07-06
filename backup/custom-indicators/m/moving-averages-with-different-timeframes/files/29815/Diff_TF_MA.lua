-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15881
-- Id: 6333

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Different TF Averages indicator");
    indicator:description("Different TF Averages indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BS", "Time frame to calculate MA", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Curr_Clr", "Current MA color", "Current MA color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("Curr_Width", "Current MA width", "Current MA width", 1, 1, 5);
    indicator.parameters:addInteger("Curr_Style", "Current MA style", "Current MA style", core.LINE_DASH);
    indicator.parameters:setFlag("Curr_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("TF_Dot_Clr", "TF Dot color", "TF Dot color", core.rgb(0, 128, 0));
    indicator.parameters:addInteger("TF_DotSize", "TF Dot Size", "TF Dot Size", 3, 1, 5);
end

local source;                   -- the source
local first;
local bf_data = nil;          -- the high/low data
local Method;
local Period;
local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local MA;
local CurrMA;
local day_offset;
local week_offset;
local extent;
local CurrBuff=nil;
local TF_Dot=nil;
local TF_Coeff;
local Period2;

function Prepare(nameOnly)
    source = instance.source;
    first=source:first();
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS = instance.parameters.BS;
    Method = instance.parameters.Method;
    Period = instance.parameters.Period;
    extent = Period*2;

    local s, e, s1, e1;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    TF_Coeff=(e1-s1)/(e-s);
    Period2=math.floor(Period*TF_Coeff+0.5);
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);

    local name = profile:id() .. "(" .. source:name() .. "," .. BS .. "," .. Method .. "," .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LastDot=instance:addInternalStream(first, 0);
    CurrBuff = instance:addStream("CurrBuff", core.Line, name .. ".MA", "MA", instance.parameters.Curr_Clr, 0);
    CurrBuff:setWidth(instance.parameters.Curr_Width);
    CurrBuff:setStyle(instance.parameters.Curr_Style);
    TF_Dot = instance:addStream("TF_Dot", core.Dot, name .. ".TF_Dot", "TF_Dot", instance.parameters.TF_Dot_Clr, 0);
    TF_Dot:setWidth(instance.parameters.TF_DotSize);
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
        CurrBuff:setBookmark(1, period);
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
        local PriceType=instance.parameters.Price;
        if PriceType=="close" then
         MA = core.indicators:create("AVERAGES", bf_data.close, Method, Period, false);
         CurrMA = core.indicators:create("AVERAGES", source.close, Method, Period2, false);
        elseif PriceType=="open" then
         MA = core.indicators:create("AVERAGES", bf_data.open, Method, Period, false);
         CurrMA = core.indicators:create("AVERAGES", source.open, Method, Period2, false);
        elseif PriceType=="high" then
         MA = core.indicators:create("AVERAGES", bf_data.high, Method, Period, false);
         CurrMA = core.indicators:create("AVERAGES", source.high, Method, Period2, false);
        elseif PriceType=="low" then
         MA = core.indicators:create("AVERAGES", bf_data.low, Method, Period, false);
         CurrMA = core.indicators:create("AVERAGES", source.low, Method, Period2, false);
        elseif PriceType=="median" then
         MA = core.indicators:create("AVERAGES", bf_data.median, Method, Period, false);
         CurrMA = core.indicators:create("AVERAGES", source.median, Method, Period2, false);
        elseif PriceType=="typical" then
         MA = core.indicators:create("AVERAGES", bf_data.typical, Method, Period, false);
         CurrMA = core.indicators:create("AVERAGES", source.typical, Method, Period2, false);
        else
         MA = core.indicators:create("AVERAGES", bf_data.weighted, Method, Period, false);
         CurrMA = core.indicators:create("AVERAGES", source.weighted, Method, Period2, false);
        end 
        return ;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        CurrBuff:setBookmark(1, period);
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
        CurrBuff:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = bf_data:date(bf_data:size() - 1);
        loadingTo = bf_candle;
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    MA:update(mode);
    CurrMA:update(mode);
    CurrBuff[period]=CurrMA.DATA[period];
    local p; 
	 p =core.findDate (bf_data, bf_candle, true);
    if p == -1 then
        return ;
    end
    TF_Dot[period]=nil;
    if source:date(period)==bf_data:date(p) then
     if MA:getStream(0):hasData(p) then
         TF_Dot[period] = MA:getStream(0)[p];
     end
    end 
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = CurrBuff:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end
 