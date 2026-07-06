-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14733
-- Id: 6031

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Generic Other Instrument Indicator")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("INDICATOR", "Indicator", "", "")
    indicator.parameters:setFlag("INDICATOR", core.FLAG_ONLYINDICATORS)

    indicator.parameters:addString("INSTRUMENT" .. 1, "Instrumet", "", "")
    indicator.parameters:setFlag("INSTRUMENT" .. 1, core.FLAG_INSTRUMENTS)

    indicator.parameters:addInteger("Number", "Data Stream Number (0 For All)", "", 0, 0, 100)
end

local Number
local INDICATOR
local OUT = {}
local final = {}
local FIRST = 1
local source
local Indicator = nil
local Count
local TEMP
local INDEX = {}
local Up, Down, Neutral
local INSTRUMENT = {}

local day_offset, week_offset
local dummy
local stream = nil
local host
local loading
local FLAG
local streams = {}
local temp
function Prepare(nameOnly)
    INDICATOR = instance.parameters.INDICATOR
    source = instance.source
    Number = instance.parameters.Number
    Number = Number - 1

    host = core.host
    day_offset = host:execute("getTradingDayOffset")
    week_offset = host:execute("getTradingWeekOffset")

    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Neutral = instance.parameters.Neutral

    local name = profile:id()

    local i

    for i = 1, 1, 1 do
        INSTRUMENT[i] = instance.parameters:getString("INSTRUMENT" .. i)
    end

    name = name .. ", (" .. INSTRUMENT[1] .. ", " .. INDICATOR .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end
    dummy = instance:addInternalStream(0, 0)

    local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"))

    local tmpparams = instance.parameters:getCustomParameters("INDICATOR")

    if tmpprofile:requiredSource() == core.Tick then
        temp = tmpprofile:createInstance(source.close, tmpparams)
    else
        temp = tmpprofile:createInstance(source, tmpparams)
    end

    Count = temp:getStreamCount()

    if Number >= Count then
        Number = Count
        assert(false, "Incorrect index of stream. The indicator has only " .. Count .. " stream(s).")
    end

    if Number == -1 then
        for i = 1, Count, 1 do
            OUT[i] = instance:addStream("out" .. i, core.Line, i, i, core.rgb(0, 0, 0), temp.DATA:first())
            OUT[i]:setPrecision(5)

            FIRST = math.max(FIRST, temp:getStream(i - 1):first())
        end
    else
        i = Number
        OUT[i] = instance:addStream("out" .. i, core.Line, i, i, core.rgb(0, 0, 0), temp.DATA:first())
        OUT[i]:setPrecision(5)

        FIRST = math.max(FIRST, temp:getStream(Number):first())
    end

    FLAG = false
    stream = nil
    Indicator = nil
    loading = false
end

function Update(period, mode)
    if loading then
        return
    end

    local curr_date = source:date(period)

    local i

    if stream ~= nil then
        for i = 1, 1, 1 do
            if stream[i]:hasData(stream[i]:first()) then
                if curr_date < stream[i]:date(stream[i]:first()) then
                    local from = source:date(source:first()) -- load from the oldest data we have in source
                    local to = stream[i]:date(stream[i]:first()) -- to the oldest data we have in other instrument

                    loading = true
                    core.host:execute("extendHistory", 1, stream[i], from, to)
                    return
                end
            end
        end
    end

    if Indicator == nil then
        Indicator = {}
        stream = {}

        for i = 1, 1, 1 do
            if source:instrument() == INSTRUMENT[i] then
                stream[i] = source
            else
                stream[i], loading = registerStream(i, source:barSize(), FIRST - source:first() + 1)
            end

            local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"))
            local tmpparams = instance.parameters:getCustomParameters("INDICATOR")

            if tmpprofile:requiredSource() == core.Tick then
                TEMP = tmpprofile:createInstance(stream[i].close, tmpparams)
            else
                TEMP = tmpprofile:createInstance(stream[i], tmpparams)
            end

            if Number == -1 then
                for i = 1, Count, 1 do
                    INDEX[i] = TEMP:getStream(i - 1)
                end
            else
                INDEX[Number] = TEMP:getStream(Number)
            end
        end
    end

    if period < FIRST then
        return
    end

    TEMP:update(mode)

    if Number == -1 then
        for i = 1, Count, 1 do
            if TEMP:getStream(i - 1):hasData(period) then
                OUT[i][period] = INDEX[i][period]
                OUT[i]:setColor(period, TEMP:getStream(i - 1):colorI(period))
            end
        end
    else
        if TEMP:getStream(Number):hasData(period) then
            OUT[Number][period] = INDEX[Number][period]
            OUT[Number]:setColor(period, TEMP:getStream(Number):colorI(period))
        end
    end
end

-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required exten
-- @return the stream reference
function registerStream(id, barSize, extent)
    local stream = {}
    local s1, e1, length
    local from, to

    s1, e1 = core.getcandle(barSize, core.now(), 0, 0)
    length = math.floor((e1 - s1) * 86400 + 0.5)

    -- the size of the source

    stream.data = nil
    stream.barSize = barSize
    stream.external = true
    stream.length = length
    stream.loading = false
    stream.extent = extent
    local from, dataFrom
    from, dataFrom = getFrom(barSize, length, extent)
    if (source:isAlive()) then
        to = 0
    else
        t, to = core.getcandle(barSize, source:date(source:size() - 1), day_offset, week_offset)
    end
    stream.loading = true
    stream.loadingFrom = from
    stream.dataFrom = dataFrom
    stream.data = host:execute("getHistory", id, INSTRUMENT[id], barSize, from, to, source:isBid())
    setBookmark(0)

    streams[id] = stream
    return stream.data
end

function getPeriod(id, period)
    local stream = streams[id]
    assert(stream ~= nil, "Stream is not registered")
    local candle, from, dataFrom, to
    if stream.external then
        candle = core.getcandle(stream.barSize, source:date(period), day_offset, week_offset)
        if candle < stream.dataFrom then
            setBookmark(period)
            if stream.loading then
                return -1, true
            end
            from, dataFrom = getFrom(stream.barSize, stream.length, stream.extent)
            stream.loading = true
            stream.loadingFrom = from
            stream.dataFrom = dataFrom
            host:execute("extendHistory", id, stream.data, from, stream.data:date(0))
            return -1, true
        end

        if (not (source:isAlive()) and candle > stream.data:date(stream.data:size() - 1)) then
            setBookmark(period)
            if stream.loading then
                return -1, true
            end
            stream.loading = true
            from = bf_data:date(bf_data:size() - 1)
            to = candle
            host:execute("extendHistory", id, stream.data, from, to)
        end

        local p
        p = core.findDate(stream.data, candle, true)
        return p, stream.loading
    else
        return period
    end
end

function setBookmark(period)
    local bm
    bm = dummy:getBookmark(1)
    if bm < 0 then
        bm = period
    else
        bm = math.min(period, bm)
    end
    dummy:setBookmark(1, bm)
end

-- get the from date for the stream using bar size and extent and taking the non-trading periods
-- into account
function getFrom(barSize, length, extent)
    local from, loadFrom
    local nontrading, nontradingend

    from = core.getcandle(barSize, source:date(source:first()), day_offset, week_offset)
    loadFrom = math.floor(from * 86400 - 2 * length * extent + 0.5) / 86400
    nontrading, nontradingend = core.isnontrading(from, day_offset)
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - 2 * length * extent + 0.5) / 86400
    end
    return loadFrom, from
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period
    local stream = streams[cookie]
    if stream == nil then
        return
    end
    stream.loading = false
    period = dummy:getBookmark(1)
    if (period < 0) then
        period = 0
    end
    loading = false
    instance:updateFrom(period)
end
