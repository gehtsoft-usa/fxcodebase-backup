-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14724
-- Id: 6029

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
    indicator:name("Second  Instrument CCI")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("PERIOD", "Period", "", 14, 2, 1000)

    Parameters(1)

    indicator.parameters:addGroup(" Line Style")
    indicator.parameters:addColor("first", "First Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("firstwidth", "Line Width (in pixels)", "", 1, 1, 5)
    indicator.parameters:addInteger("firststyle", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("firststyle", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addGroup("Levels Style")
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 100)
    indicator.parameters:addInteger("oversold", "Oversold Level", "", -100)

    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5)
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(0, 0, 255))
end

function Parameters(id)
    indicator.parameters:addGroup("Instrument")
    indicator.parameters:addString("INSTRUMENT" .. id, "Instrumet", "", "")
    indicator.parameters:setFlag("INSTRUMENT" .. id, core.FLAG_INSTRUMENTS)
end

local PERIOD
local out = {}
local source
local Indicator = nil
local day_offset, week_offset
local dummy
local stream = nil
local host
--local alive;
local first
local loading

local FLAG = false

local INSTRUMENT = {}
--local FRAME={};

function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD

    source = instance.source
    first = source:first()
    host = core.host

    local name = profile:id()

    local i

    for i = 1, 1, 1 do
        INSTRUMENT[i] = instance.parameters:getString("INSTRUMENT" .. i)

        name = name .. ", (" .. INSTRUMENT[i] .. ", " .. PERIOD .. ")"
    end

    instance:name(name)
    if nameOnly then
        return;
    end

    day_offset = host:execute("getTradingDayOffset")
    week_offset = host:execute("getTradingWeekOffset")

    dummy = instance:addInternalStream(0, 0)

    out[1] = instance:addStream("CCI", core.Line, "", INSTRUMENT[1], instance.parameters.first, first)

    out[1]:setWidth(instance.parameters.firstwidth)
    out[1]:setStyle(instance.parameters.firststyle)
    out[1]:setPrecision(2)

    FLAG = false
    stream = nil
    Indicator = nil

    out[1]:addLevel(0)
    out[1]:addLevel(
        instance.parameters.oversold,
        instance.parameters.level_overboughtsold_style,
        instance.parameters.level_overboughtsold_width,
        instance.parameters.level_overboughtsold_color
    )
    out[1]:addLevel(
        instance.parameters.overbought,
        instance.parameters.level_overboughtsold_style,
        instance.parameters.level_overboughtsold_width,
        instance.parameters.level_overboughtsold_color
    )
    out[1]:addLevel(100)
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

    if source:hasData(period) and period >= first then
        if Indicator == nil then
            Indicator = {}
            stream = {}

            for i = 1, 1, 1 do
                if source:instrument() == INSTRUMENT[i] then
                    stream[i] = source
                else
                    stream[i] = registerStream(i, source:barSize(), PERIOD)
                end

                Indicator[i] = core.indicators:create("CCI", stream[i], PERIOD)
            end
        end

        for i = 1, 1, 1 do
            Indicator[i]:update(mode)

            local PERIOD

            local p = core.findDate(stream[i], curr_date, true)

            if source:instrument() == INSTRUMENT[i] then
                if Indicator[i].DATA:hasData(period) then
                    out[i][period] = Indicator[i].DATA[period]
                end
            else
                if Indicator[i].DATA:hasData(p) then
                    out[i][period] = Indicator[i].DATA[p]
                end
            end
        end
    end
end

local streams = {}

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
