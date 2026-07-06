-- Id: 2613
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2925

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
    indicator:name("MA Difference indicator");
    indicator:description("MA Difference indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("MA1_Instrument", "Instrument for MA1", "", "");
    indicator.parameters:setFlag("MA1_Instrument", core.FLAG_INSTRUMENTS );

    indicator.parameters:addString("MA1_TF", "Time frame for MA1", "", "D1");
    indicator.parameters:setFlag("MA1_TF", core.FLAG_PERIODS);
    
    indicator.parameters:addString("MA1_Method", "Method for MA1", "", "MVA");
    indicator.parameters:addStringAlternative("MA1_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA1_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA1_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA1_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA1_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA1_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA1_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA1_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA1_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA1_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA1_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA1_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA1_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA1_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA1_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA1_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA1_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA1_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA1_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA1_Method", "JSmooth", "", "JSmooth");
    
    indicator.parameters:addInteger("MA1_Period", "Period for MA1", "", 10);

    indicator.parameters:addString("MA2_Instrument", "Instrument for MA2", "", "");
    indicator.parameters:setFlag("MA2_Instrument", core.FLAG_INSTRUMENTS );

    indicator.parameters:addString("MA2_TF", "Time frame for MA2", "", "D1");
    indicator.parameters:setFlag("MA2_TF", core.FLAG_PERIODS);
    
    indicator.parameters:addString("MA2_Method", "Method for MA2", "", "MVA");
    indicator.parameters:addStringAlternative("MA2_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA2_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA2_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA2_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA2_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA2_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA2_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA2_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA2_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA2_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA2_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA2_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA2_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA2_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA2_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA2_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA2_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA2_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA2_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA2_Method", "JSmooth", "", "JSmooth");
    
    indicator.parameters:addInteger("MA2_Period", "Period for MA2", "", 20);
    
    indicator.parameters:addString("Signal_Method", "Method for Signal MA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Signal_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Signal_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Signal_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Signal_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Signal_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Signal_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Signal_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Signal_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Signal_Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("SignalClr", "Signal color", "Signal color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local source;                   -- the source
local bf_data = nil;          -- the high/low data
local Method;
local Period;
local TF;
local bf_length;                 -- length of the bigger frame in seconds
local bf_data2 = nil;          -- the high/low data
local Method2;
local Period2;
local TF2;
local bf_length2;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local MA;
local MA2;
local day_offset;
local week_offset;
local extent;
local MainBuff=nil;
local UPBuff=nil;
local DNBuff=nil;
local Diff;
local SignalMA;

function Prepare(nameOnly)
    source = instance.source;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    TF = instance.parameters.MA1_TF;
    Method = instance.parameters.MA1_Method;
    Period = instance.parameters.MA1_Period;
    TF2 = instance.parameters.MA2_TF;
    Method2 = instance.parameters.MA2_Method;
    Period2 = instance.parameters.MA2_Period;
    extent = math.max(Period,Period2)*2;
    local name = profile:id() .. "(" .. TF .. "," .. instance.parameters.MA1_Instrument .. "," .. Method .. "," .. Period .. ") vs (" .. TF2 .. "," .. instance.parameters.MA2_Instrument .. "," .. Method2 .. "," .. Period2 .. ") (" .. instance.parameters.Signal_Method .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Diff = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
	
    SignalMA = core.indicators:create("AVERAGES", Diff, instance.parameters.Signal_Method, instance.parameters.Signal_Period, false);

    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen TF 1 must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);
    s1, e1 = core.getcandle(TF2, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen TF 2 must be bigger than the chart time frame!");
    bf_length2 = math.floor((e1 - s1) * 86400 + 0.5);

    MainBuff = instance:addStream("MainBuff", core.Line, name .. ".Main", "Main", instance.parameters.MainClr, 0);
    MainBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    SignalBuff = instance:addStream("SignalBuff", core.Line, name .. ".Signal", "Signal", instance.parameters.SignalClr, 0);
    SignalBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    MainBuff:setWidth(instance.parameters.widthLinReg);
    MainBuff:setStyle(instance.parameters.styleLinReg);
    SignalBuff:setWidth(instance.parameters.widthLinReg);
    SignalBuff:setStyle(instance.parameters.styleLinReg);
end


local loading = false;
local loadingFrom, loadingTo;
local pday = nil;

-- the function which is called to calculate the period
function Update(period, mode)
    -- get date and time of the hi/lo candle in the reference data
    local bf_candle;
    bf_candle = core.getcandle(TF, source:date(period), day_offset, week_offset);
    local bf_candle2;
    bf_candle2 = core.getcandle(TF2, source:date(period), day_offset, week_offset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading and bf_candle >= loadingFrom and (loadingTo == 0 or bf_candle <= loadingTo) then
        return ;
    end
    if loading2 and bf_candle2 >= loadingFrom2 and (loadingTo2 == 0 or bf_candle2 <= loadingTo2) then
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
            t, to = core.getcandle(TF, source:date(period), day_offset, week_offset);
        end

        from = core.getcandle(TF, source:date(source:first()), day_offset, week_offset);
        MainBuff:setBookmark(1, period);
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
        bf_data = host:execute("getHistory", 1, instance.parameters.MA1_Instrument, TF, loadingFrom, to, source:isBid());
        MA = core.indicators:create("AVERAGES", bf_data.close, Method, Period, false);
        return ;
    end

    if bf_data2 == nil then
        -- there is no data at all, load initial data
        local to2, t2;
        local from2;

        if (source:isAlive()) then
            -- if the source is subscribed for updates
            -- then subscribe the current collection as well
            to2 = 0;
        else
            -- else load up to the last currently available date
            t2, to2 = core.getcandle(TF2, source:date(period), day_offset, week_offset);
        end

        from2 = core.getcandle(TF2, source:date(source:first()), day_offset, week_offset);
        MainBuff:setBookmark(1, period);
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from2 = math.floor(from2 * 86400 - (bf_length2 * extent) + 0.5) / 86400;
        local nontrading2, nontradingend2;
        nontrading2, nontradingend2 = core.isnontrading(from2, day_offset);
        if nontrading2 then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from2 = math.floor((from2 - 2) * 86400 - (bf_length2 * extent) + 0.5) / 86400;
        end
        loading2 = true;
        loadingFrom2 = from2;
        loadingTo2 = to2;
        bf_data2 = host:execute("getHistory", 2, instance.parameters.MA2_Instrument, TF2, loadingFrom2, to2, source:isBid());
        MA2 = core.indicators:create("AVERAGES", bf_data2.close, Method2, Period2, false);
        return ;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        MainBuff:setBookmark(1, period);
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

    if (bf_candle2 < bf_data2:date(0)) then
        MainBuff:setBookmark(1, period);
        if loading2 then
            return ;
        end
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from2 = math.floor(bf_candle2 * 86400 - (bf_length2 * extent) + 0.5) / 86400;
        local nontrading2, nontradingend2;
        nontrading2, nontradingend2 = core.isnontrading(from2, day_offset);
        if nontrading2 then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from2 = math.floor((from2 - 2) * 86400 - (bf_length2 * extent) + 0.5) / 86400;
        end
        loading2 = true;
        loadingFrom2 = from2;
        loadingTo2 = bf_data2:date(0);
        host:execute("extendHistory", 2, bf_data2, loadingFrom2, loadingTo2);
        return ;
    end

    -- check whether the requested candle is after
    -- the reference collection end
    if (not(source:isAlive()) and bf_candle > bf_data:date(bf_data:size() - 1)) then
        MainBuff:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = bf_data:date(bf_data:size() - 1);
        loadingTo = bf_candle;
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    if (not(source:isAlive()) and bf_candle2 > bf_data2:date(bf_data2:size() - 1)) then
        MainBuff:setBookmark(1, period);
        if loading2 then
            return ;
        end
        loading2 = true;
        loadingFrom2 = bf_data2:date(bf_data2:size() - 1);
        loadingTo2 = bf_candle2;
        host:execute("extendHistory", 2, bf_data2, loadingFrom2, loadingTo2);
        return ;
    end

    MA:update(mode);
    MA2:update(mode);
    local p;
    p = core.findDate(bf_data, bf_candle, true);
    local p2;
    p2 = core.findDate(bf_data2, bf_candle2, true);
    if p == -1 or p2 == -1 then
        return ;
    end
    if MA:getStream(0):hasData(p) and MA2:getStream(0):hasData(p2) then
        Diff[period] = MA:getStream(0)[p]-MA2:getStream(0)[p2];
        MainBuff[period] = Diff[period];
        SignalMA:update(mode);
        SignalBuff[period]=SignalMA.MainBuff[period];
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = MainBuff:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    loading2 = false;
    instance:updateFrom(period);
end
 