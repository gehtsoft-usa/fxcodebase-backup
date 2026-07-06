-- Available @ http://fxcodebase.com/ 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Bigger timeframe Candle")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("BS", "Time frame", "", "D1")

    indicator.parameters:addInteger("DOJI", "Max. Doji Body Lengt", "In Pips", 10, 1, 10000)
    indicator.parameters:addInteger("Wick", "Wick as percentage of candle body", "As percentage", 10, 1, 10000)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UP_Color", "Color for UP", "Color for UP", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DOWN_Color", "Color for DOWN", "Color for DOWN", core.rgb(255, 0, 0))
    indicator.parameters:addColor("DOJI_Color", "Color for Doji", "Color for DOJI", core.rgb(128, 128, 128))

    indicator.parameters:addInteger("transparency", "Transparency", "", 70, 0, 100)
end

local source  -- the source
local bf_data = nil -- the high/low data
local BS
local bf_length  -- length of the bigger frame in seconds
local dates  -- candle dates
local host
local day_offset
local week_offset
local extent
local dummy
local FIRST = true
local DOJI
local UP_Color, DOJI_Color, DOWN_Color
local transparency
local Wick
function Prepare()
    DOJI = instance.parameters.DOJI
    source = instance.source
    host = core.host

    UP_Color = instance.parameters.UP_Color
    DOJI_Color = instance.parameters.DOJI_Color
    DOWN_Color = instance.parameters.DOWN_Color

    Wick = instance.parameters.Wick

    day_offset = host:execute("getTradingDayOffset")
    week_offset = host:execute("getTradingWeekOffset")

    BS = instance.parameters.BS
    extent = 20

    local s, e, s1, e1

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0)
    s1, e1 = core.getcandle(BS, core.now(), 0, 0)
    assert((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!")
    bf_length = math.floor((e1 - s1) * 86400 + 0.5)

    local name = profile:id() .. "(" .. source:name() .. "," .. BS .. "," .. DOJI .. ")"
    instance:name(name)

    dummy = instance:addInternalStream(0, 0)

    instance:ownerDrawn(true)
end

local FLAG = nil
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
        dummy:setBookmark(1, period)
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
        return
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        dummy:setBookmark(1, period)
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
        dummy:setBookmark(1, period)
        if loading then
            return
        end
        loading = true
        loadingFrom = bf_data:date(bf_data:size() - 1)
        loadingTo = bf_candle
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo)
        return
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    loading = false
    instance:updateFrom(0)
end

function Draw(stage, context)
    if stage ~= 0 then
        return
    end

    if not init then
        context:createSolidBrush(1, UP_Color)
        context:createSolidBrush(2, DOWN_Color)
        context:createSolidBrush(3, DOJI_Color)
        transparency = context:convertTransparency(instance.parameters.transparency)

        init = true
    end
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());

    bf_first, x = core.getcandle(BS, source:date(context:firstBar()), day_offset, week_offset)
    x, bf_last = core.getcandle(BS, source:date(context:lastBar()), day_offset, week_offset)

    bf_first = core.findDate(bf_data, bf_first, false)
    bf_last = core.findDate(bf_data, bf_last, false)

    if bf_first == -1 or bf_last == -1 then
        return
    end
    for period = bf_first, bf_last, 1 do
        Add(context, period)
    end
end

function Add(context, period)
    if not bf_data:hasData(period) then
        return
    end

    start_date, end_date = core.getcandle(BS, bf_data:date(period), day_offset, week_offset)
    p1 = core.findDate(source, start_date, false)
    if p1 == -1 then
        return
    end
    p2 = core.findDate(source, end_date, false)
    if p2 == -1 then
        return
    end
    if p2 == source:size() - 1 then
        p2 = p1 + (p2 - p1) * (end_date - start_date) / (source:date(p2) - source:date(p1));
    elseif end_date == source:date(p2) then
        p2 = p2 - 1;
    end

    Low = bf_data.low[period]
    High = bf_data.high[period]
    Open = bf_data.open[period]
    Close = bf_data.close[period]

    visible, H = context:pointOfPrice(math.max(Open, Close))
    visible, L = context:pointOfPrice(math.min(Open, Close))

    visible, high = context:pointOfPrice(High)
    visible, low = context:pointOfPrice(Low)

    x, x1 = context:positionOfBar(p1)
    x, _, x2 = context:positionOfBar(p2)

    Delta = (x2 - x1)
    x = x1 + Delta / 2
    Percentage = (Delta / 100) * Wick

    if DOJI > math.abs(Close - Open) / source:pipSize() then
        context:drawRectangle(-1, 3, x1, H, x2, L, transparency)
        context:drawRectangle(-1, 3, x - Percentage, high, x + Percentage, H, transparency)
        context:drawRectangle(-1, 3, x - Percentage, L, x + Percentage, low, transparency)
    elseif Close > Open then
        context:drawRectangle(-1, 1, x1, H, x2, L, transparency)
        context:drawRectangle(-1, 1, x - Percentage, high, x + Percentage, H, transparency)
        context:drawRectangle(-1, 1, x - Percentage, L, x + Percentage, low, transparency)
    elseif Close < Open then
        context:drawRectangle(-1, 2, x1, H, x2, L, transparency)
        context:drawRectangle(-1, 2, x - Percentage, high, x + Percentage, H, transparency)
        context:drawRectangle(-1, 2, x - Percentage, L, x + Percentage, low, transparency)
    end
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+