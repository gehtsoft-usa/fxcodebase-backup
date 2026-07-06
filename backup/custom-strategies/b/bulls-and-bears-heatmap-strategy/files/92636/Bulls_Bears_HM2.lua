-- Id: 11124
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=60298

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Adds indicators parameter
function AddMvaParam(id, frame, n, level)
    indicator.parameters:addString("B" .. id, "Time frame for avegage " .. id, "", frame)
    indicator.parameters:setFlag("B" .. id, core.FLAG_PERIODS)
    indicator.parameters:addInteger("N" .. id, "Length " .. id .. " parameter", "", n)
end

function Init()
    indicator:name("Bulls&Bears heat map")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    AddMvaParam(1, "H1", 10, 0.)
    AddMvaParam(2, "H2", 10, 0.)
    AddMvaParam(3, "H4", 10, 0.)
    AddMvaParam(4, "H6", 10, 0.)
    indicator.parameters:addGroup("Display")
    indicator.parameters:addColor("clrUP", "Up color 1", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("clrDN", "Down color 1", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("clrLBL", "Label color", "", core.COLOR_LABEL)
end

-- list of streams
local streams = {}
-- the indicator source
local source
local day_offset, week_offset
local dummy
local host
local U1 = {}
local D1 = {}
local L = {}
local Bulls = nil
local Bears = nil
local Data = {}
function Prepare(nameOnly)
    source = instance.source
    host = core.host

    day_offset = host:execute("getTradingDayOffset")
    week_offset = host:execute("getTradingWeekOffset")

    CheckBarSize(1)
    CheckBarSize(2)
    CheckBarSize(3)
    CheckBarSize(4)

    local i
    local name = profile:id() .. "(" .. source:name() .. ","
    for i = 1, 4, 1 do
        name = name .. "(" .. instance.parameters:getInteger("N" .. i) .. ")"
        L[i] = instance.parameters:getString("B" .. i) .. " " .. instance.parameters:getString("N" .. i) .. ")"
    end
    name = name .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end
    dummy = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrLBL, 20)
    dummy:setPrecision(math.max(2, instance.source:getPrecision()));
    dummy:addLevel(-1)
    dummy:addLevel(0)
    dummy:addLevel(1)
    for i = 1, 4, 1 do
        U1[i] =
            instance:addStream("DATASTREAM" .. i, core.Bar, "DATASTREAM" .. i, "DATASTREAM" .. i, core.COLOR_LABEL, 2)
    U1[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

function CheckBarSize(id)
    local s, e, s1, e1
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0)
    s1, e1 = core.getcandle(instance.parameters:getString("B" .. id), core.now(), 0, 0)
    assert((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!")
end

function Update(period, mode)
    local i, p, loading
    -- request for data and create MVA's if they do not exist yet.
    if Bulls == nil then
        Bulls = {}
        Bears = {}
        for i = 1, 4, 1 do
            Data[i] =
                registerStream(i, instance.parameters:getString("B" .. i), instance.parameters:getInteger("N" .. i))
    assert(core.indicators:findIndicator("BULLS") ~= nil, "BULLS" .. " indicator must be installed");
            Bulls[i] = core.indicators:create("BULLS", Data[i], instance.parameters:getInteger("N" .. i))
    assert(core.indicators:findIndicator("BEARS") ~= nil, "BEARS" .. " indicator must be installed");
            Bears[i] = core.indicators:create("BEARS", Data[i], instance.parameters:getInteger("N" .. i))
        end
    end

    for i = 1, 4, 1 do
        p, loading = getPeriod(i, period)
        if p ~= -1 then
            Bulls[i]:update(mode)
            Bears[i]:update(mode)
            if Bulls[i].DATA:hasData(p) and Bears[i].DATA:hasData(p) then
                if math.abs(Bulls[i].DATA[p]) > math.abs(Bears[i].DATA[p]) then
                    U1[i]:set(period, 1)
                elseif math.abs(Bulls[i].DATA[p]) < math.abs(Bears[i].DATA[p]) then
                    U1[i]:set(period, -1)
                else
                    U1[i]:set(period, 0)
                end
            end
        end
    end
end

function getPriceStream(stream)
    local s = instance.parameters.S
    return stream
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
    if barSize == source:barSize() then
        stream.data = source
        stream.barSize = barSize
        stream.external = false
        stream.length = length
        stream.loading = false
        stream.extent = extent
        stream.loading = false
    else
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
        stream.data = host:execute("getHistory", id, source:instrument(), barSize, from, to, source:isBid())
        setBookmark(0)
    end
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
        p = findDateFast(stream.data, candle, true)
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
    loadFrom = math.floor(from * 86400 - length * extent + 0.5) / 86400
    nontrading, nontradingend = core.isnontrading(from, day_offset)
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - length * extent + 0.5) / 86400
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

-- find the date in the stream using binary search algo.
function findDateFast(stream, date, precise)
    local datesec = nil
    local periodsec = nil
    local min, max, mid

    datesec = math.floor(date * 86400 + 0.5)

    min = 0
    max = stream:size() - 1

    if max < 1 then
        return -1
    end

    while true do
        mid = math.floor((min + max) / 2)
        periodsec = math.floor(stream:date(mid) * 86400 + 0.5)
        if datesec == periodsec then
            return mid
        elseif datesec > periodsec then
            min = mid + 1
        else
            max = mid - 1
        end
        if min > max then
            if precise then
                return -1
            else
                return min - 1
            end
        end
    end
end
