-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=858
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bigger timeframe ATR Channel")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("BS", "Time frame to calculate ATR Channel", "", "D1")
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS)
    indicator.parameters:addInteger("P1", "ATR Period", "ATR Period", 10)
    indicator.parameters:addInteger("P3", "EMA Period", "EMA Period", 20)
    indicator.parameters:addInteger("Multiplier", "ATR Multiplier", "", 1)

    indicator.parameters:addString("Method", "Method", "", "MVA")
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder")
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA")
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA")
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA")
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA")
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA")
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA")
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3")
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend")
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median")
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean")
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA")
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS")
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2")
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen")
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth")

    indicator.parameters:addBoolean("MORE", "Show additional lines", "", true)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Central_color", "Central", "Color of Central", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("Top_color", "Top", "Color of Top", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("Bottom_color", "Bottom", "Color of Bottom", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)
end

local source  -- the source
local bf_data = nil -- the high/low data
local P1
local P3
local MORE
local BS
local bf_length  -- length of the bigger frame in seconds
local dates  -- candle dates
local host
local S1, S2, S3, S4, S5, S6, S7
local ATRch
local day_offset
local week_offset
local extent
local first
local Multiplier
function Prepare()
    source = instance.source
    first = source:first()
    host = core.host

    day_offset = host:execute("getTradingDayOffset")
    week_offset = host:execute("getTradingWeekOffset")

    BS = instance.parameters.BS
    P1 = instance.parameters.P1
    P3 = instance.parameters.P3
    MORE = instance.parameters.MORE
    Method = instance.parameters.Method
    Multiplier = instance.parameters.Multiplier
    extent = math.max(P1, P3) * 2

    local s, e, s1, e1

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator")
    assert(
        core.indicators:findIndicator("ATR CHANNEL") ~= nil,
        "Please, download and install ATR CHANNEL.LUA indicator"
    )

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0)
    s1, e1 = core.getcandle(BS, core.now(), 0, 0)
    assert((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!")
    bf_length = math.floor((e1 - s1) * 86400 + 0.5)

    local name = profile:id() .. "(" .. source:name() .. "," .. BS .. "," .. P1 .. "," .. P3 .. ")"
    instance:name(name)
    S1 = instance:addStream("Central", core.Line, name .. "Central", "Central", instance.parameters.Central_color, first)
    S1:setWidth(instance.parameters.width1)
    S1:setStyle(instance.parameters.style1)

    if MORE then
        S2 = instance:addStream("Top1", core.Line, name .. "Top", "Top", instance.parameters.Top_color, first)
        S2:setWidth(instance.parameters.width2)
        S2:setStyle(instance.parameters.style2)

        S3 = instance:addStream("Bottom1", core.Line, name .. "Bottom", "Bottom", instance.parameters.Bottom_color, first)
        S3:setWidth(instance.parameters.width3)
        S3:setStyle(instance.parameters.style3)

        S4 = instance:addStream("Top2", core.Line, name .. "Top", "", instance.parameters.Top_color, first)
        S4:setWidth(instance.parameters.width2)
        S4:setStyle(instance.parameters.style2)

        S5 = instance:addStream("Bottom2", core.Line, name .. "Bottom", "", instance.parameters.Bottom_color, first)
        S5:setWidth(instance.parameters.width3)
        S5:setStyle(instance.parameters.style3)

        S6 = instance:addStream("Top3", core.Line, name .. "Top", "", instance.parameters.Top_color, first)
        S6:setWidth(instance.parameters.width2)
        S6:setStyle(instance.parameters.style2)

        S7 = instance:addStream("Bottom3", core.Line, name .. "Bottom", "", instance.parameters.Bottom_color, first)
        S7:setWidth(instance.parameters.width3)
        S7:setStyle(instance.parameters.style3)
    end
end

local loading = false
local loadingFrom, loadingTo
local pday = nil

-- the function which is called to calculate the period
function Update(period, mode)
    -- get date and time of the hi/lo candle in the reference data
    local bf_candle
    bf_candle = core.getcandle(BS, source:date(period), day_offset, week_offset)

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading and bf_candle >= loadingFrom and (loadingTo == 0 or bf_candle <= loadingTo) then
        return
    end

    -- if the period is before the source start
    -- the do nothing
    if period < source:first() then
        return
    end

    -- if data is not loaded yet at all
    -- load the data
    if bf_data == nil then
        -- there is no data at all, load initial data
        local to, t
        local from

        if (source:isAlive()) then
            -- if the source is subscribed for updates
            -- then subscribe the current collection as well
            to = 0
        else
            -- else load up to the last currently available date
            t, to = core.getcandle(BS, source:date(period), day_offset, week_offset)
        end

        from = core.getcandle(BS, source:date(source:first()), day_offset, week_offset)
        S1:setBookmark(1, period)
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(from * 86400 - (bf_length * extent) + 0.5) / 86400
        local nontrading, nontradingend
        nontrading, nontradingend = core.isnontrading(from, day_offset)
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * extent) + 0.5) / 86400
        end
        loading = true
        loadingFrom = from
        loadingTo = to
        bf_data = host:execute("getHistory", 1, source:instrument(), BS, loadingFrom, to, source:isBid())
        ATRch = core.indicators:create("ATR CHANNEL", bf_data, P1, P3, Multiplier, Method, "Yes")
        return
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        S1:setBookmark(1, period)
        if loading then
            return
        end
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(bf_candle * 86400 - (bf_length * extent) + 0.5) / 86400
        local nontrading, nontradingend
        nontrading, nontradingend = core.isnontrading(from, day_offset)
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * extent) + 0.5) / 86400
        end
        loading = true
        loadingFrom = from
        loadingTo = bf_data:date(0)
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo)
        return
    end

    -- check whether the requested candle is after
    -- the reference collection end
    if (not (source:isAlive()) and bf_candle > bf_data:date(bf_data:size() - 1)) then
        S1:setBookmark(1, period)
        if loading then
            return
        end
        loading = true
        loadingFrom = bf_data:date(bf_data:size() - 1)
        loadingTo = bf_candle
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo)
        return
    end

    ATRch:update(mode)
    local p
    p = core.findDate(bf_data, bf_candle, true)
    if p == -1 then
        return
    end
    if ATRch:getStream(0):hasData(p) then
        S1[period] = ATRch:getStream(0)[p]
    end
    if MORE then
        if ATRch:getStream(1):hasData(p) then
            S2[period] = ATRch:getStream(1)[p]
        end
        if ATRch:getStream(2):hasData(p) then
            S3[period] = ATRch:getStream(2)[p]
        end
        if ATRch:getStream(3):hasData(p) then
            S4[period] = ATRch:getStream(3)[p]
        end
        if ATRch:getStream(4):hasData(p) then
            S5[period] = ATRch:getStream(4)[p]
        end
        if ATRch:getStream(5):hasData(p) then
            S6[period] = ATRch:getStream(5)[p]
        end
        if ATRch:getStream(6):hasData(p) then
            S7[period] = ATRch:getStream(6)[p]
        end
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period

    pday = nil
    period = S1:getBookmark(1)

    if (period < 0) then
        period = 0
    end
    loading = false
    instance:updateFrom(period)
end
