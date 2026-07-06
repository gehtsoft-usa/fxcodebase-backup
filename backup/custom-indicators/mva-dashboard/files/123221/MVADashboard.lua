-- Id: 4014
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4504

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

--13 Time Frame
local Period = {
    {code = "m1", default = false},
    {code = "m5", default = false},
    {code = "m15", default = true},
    {code = "m30", default = true},
    {code = "H1", default = true},
    {code = "H2", default = true},
    {code = "H3", default = false},
    {code = "H4", default = true},
    {code = "H6", default = false},
    {code = "H8", default = false},
    {code = "D1", default = true},
    {code = "W1", default = true},
    {code = "M1", default = false}
}

local Time, Offer = {}, {}

function Init()
    indicator:name("MVA Dashboard")
    indicator:description("MVA Dashboard")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    -- ========================= MVA Periods ============================= --
    indicator.parameters:addGroup("MVA Periods")
    indicator.parameters:addInteger("SMA1P", "Short MVA Period", "", 30, 0, 1000)
    indicator.parameters:addInteger("SMA2P", "Medium MVA Period", "", 50, 0, 1000)
    indicator.parameters:addInteger("SMA3P", "Long MVA Period", "", 100, 0, 1000)
    -- ========================= Time Periods ============================= --
    indicator.parameters:addGroup("Time Periods")
    local i
    for i = 1, #Period do
        indicator.parameters:addBoolean("Show" .. Period[i].code, "Show " .. Period[i].code, "", Period[i].default)
    end

    -- =========================    Offers    ============================= --
    indicator.parameters:addGroup("Offers")

    for i = 1, 20 do
        indicator.parameters:addBoolean("Show_instrument" .. i, "Use instrument #" .. i, "", true);
        indicator.parameters:addString("instrument" .. i, "Instrument #" .. i, "", "");
        indicator.parameters:setFlag("instrument" .. i, core.FLAG_INSTRUMENTS);
    end

    indicator.parameters:addGroup("Colors")
    indicator.parameters:addColor("labelColor", "Labels color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("upColor", "Color of UP arrow", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("downColor", "Color of DOWN arrow", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("neutralColor", "Color of NEUTRAL bar", "", core.rgb(128, 128, 128))
end

-- Parameters block
local firstperiod
local source = nil
local day_offset, week_offset

local SELECT
local TAG
local TEMP = {}

-- Streams block
local font
local font2
local dummy
local host = core.host

local init = {
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
}
local streams = {}
local stream = {}

local TMP = 1

local Type
local TF
local jc = 0
local FLAG = true

local Digits
local INDEX = {}
local BUFFER = {}

local SMA1P, SMA2P, SMA3P

-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    source = instance.source
    firstperiod = source:first()
    day_offset = host:execute("getTradingDayOffset")
    week_offset = host:execute("getTradingWeekOffset")

    SMA1P = instance.parameters.SMA1P
    SMA2P = instance.parameters.SMA2P
    SMA3P = instance.parameters.SMA3P

    assert(SMA1P < SMA2P, "Short MVA period should be less then Medium")
    assert(SMA2P < SMA3P, "Medium MVA period should be less then Long")

    normal = core.host:execute("createFont", "Courier", 12, false, false)
    arrows = core.host:execute("createFont", "Wingdings", 12, false, false)

    dummy = instance:addInternalStream(firstperiod, 0)

    for i = 1, #Period do
        if instance.parameters:getBoolean("Show" .. Period[i].code) then
            table.insert(
                Time,
                {
                    code = Period[i].code
                }
            )
        end
    end

    local chartOffer = -1;
    for i = 1, 20 do
        if instance.parameters:getBoolean("Show_instrument" .. i) then
            local row = core.host:findTable("offers"):find("Instrument", instance.parameters:getString("instrument" .. i));
            if row ~= nil then
                if row.Instrument == source:instrument() then
                    chartOffer = #Offer + 1
                end
                table.insert(
                    Offer,
                    {
                        id = row.OfferID,
                        name = row.Instrument,
                        init = false
                    }
                )
            end
        end
    end

    -- Move main chart offer to first place
    if chartOffer ~= 1 and chartOffer ~= -1 then
        Offer[1], Offer[chartOffer] = Offer[chartOffer], Offer[1]
    end

    host:execute("addCommand", 1, "Refresh", "Refresh")
    TMP = 1
end

function id(i, j)
    return Offer[i].startId + j
end

function labelId(i, j)
    return i * (#Time + 4) + j
end

local NEXT_STREAM_ID = 1000

-- Indicator calculation routine
function Update(period)
    if period >= firstperiod and source:hasData(period) then
        if period ~= source:size() - 1 or period == last_updated then
            return
        end

        last_updated = period
        dummy[period] = 0 --???
        local i, j

        --rescanOffers();
        DRAW()
    end
end

function DRAW()
    -- ============ DRAW LABELS ================= --
    local k = 0
    local width = #Time * 35 + 200
    for j = 1, #Time do
        core.host:execute(
            "drawLabel1",
            100 + j,
            80 + j * 35,
            core.CR_LEFT,
            20,
            core.CR_TOP,
            core.H_Center,
            core.V_Center,
            normal,
            instance.parameters.labelColor,
            Time[j].code
        )
        core.host:execute(
            "drawLabel1",
            200 + j,
            width + j * 35,
            core.CR_LEFT,
            20,
            core.CR_TOP,
            core.H_Center,
            core.V_Center,
            normal,
            instance.parameters.labelColor,
            Time[j].code
        )
    end

    local len = math.floor((#Offer + 1) / 2)
    for i = 1, len do
        local i2 = i + len
        core.host:execute(
            "drawLabel1",
            300 + i,
            40,
            core.CR_LEFT,
            40 + i * 17,
            core.CR_TOP,
            core.H_Center,
            core.V_Center,
            normal,
            instance.parameters.labelColor,
            Offer[i].name
        )
        if (i2 <= #Offer) then
            core.host:execute(
                "drawLabel1",
                300 + i2,
                width - 35,
                core.CR_LEFT,
                40 + i * 17,
                core.CR_TOP,
                core.H_Center,
                core.V_Center,
                normal,
                instance.parameters.labelColor,
                Offer[i2].name
            )
        end
        if not Offer[i].init then
            Offer[i].init = true
            Offer[i].startId = getNextId()
            for j = 1, #Time do
                stream[id(i, j)] = registerStream(id(i, j), Time[j].code, 160, Offer[i].name)
            end
        end

        if i2 <= #Offer and not Offer[i2].init then
            Offer[i2].init = true
            Offer[i2].startId = getNextId()
            for j = 1, #Time do
                stream[id(i2, j)] = registerStream(id(i2, j), Time[j].code, 160, Offer[i2].name)
            end
        end

        for j = 1, #Time do
            local s = stream[id(i, j)]

            if s:hasData(s:size() - 1) and s:size() > 100 then --and ss.MVA1 ~= nil
                showLabel(s, i, j, j * 35 + 75, i * 17)
            end

            if (i2 <= #Offer) then
                s = stream[id(i2, j)]
                if s:hasData(s:size() - 1) and s:size() > 100 then --and ss.MVA1 ~= nil
                    showLabel(s, i2, j, j * 35 + width, i * 17)
                end
            end
        end
    end
end

function rescanOffers()
    for i = 1, 50 do
        for j = 1, 15 do
            core.host:execute("removeLabel", 400 + labelId(i, j))
        end
    end

    local enum = core.host:findTable("offers"):enumerator()
    local row = enum:next()
    local chartOffer = -1
    local nOffer = {}
    while row ~= nil do
        if instance.parameters:getBoolean("Show" .. row.OfferID) then
            local o = nil
            --Try to find offer among already registered Offers
            for i = 1, #Offer do
                if Offer[i].id == row.OfferID then
                    o = Offer[i]
                    break
                end
            end
            -- Create new if not found
            if o == nil then
                o = {
                    id = row.OfferID,
                    name = row.Instrument,
                    init = false
                }
            end

            if row.Instrument == source:instrument() then
                chartOffer = #nOffer + 1
            end

            table.insert(nOffer, o)
        end
        row = enum:next()
    end

    if chartOffer ~= 1 and chartOffer ~= -1 then
        nOffer[1], nOffer[chartOffer] = nOffer[chartOffer], nOffer[1]
    end

    Offer = nOffer
    DRAW()
end

function getNextId()
    local nextId = NEXT_STREAM_ID
    NEXT_STREAM_ID = NEXT_STREAM_ID + #Time + 1
    return nextId
end

function showPlainLabel(label, i, j, xoff, yoff)
    core.host:execute(
        "drawLabel1",
        400 + labelId(i, j),
        xoff,
        core.CR_LEFT,
        40 + yoff,
        core.CR_TOP,
        core.H_Right,
        core.V_Center,
        normal,
        instance.parameters.upColor,
        label
    ) --  "\228\37\113"
end

function showLabel(s, i, j, xoff, yoff)
    local sma30 = mathex.avg(s.close, core.rangeTo(s:size() - 1, instance.parameters.SMA1P))
    local sma50 = mathex.avg(s.close, core.rangeTo(s:size() - 1, instance.parameters.SMA2P))
    local sma100 = mathex.avg(s.close, core.rangeTo(s:size() - 1, instance.parameters.SMA3P))
    local price = s.close[s:size() - 1]
    local alert = ""

    if (sma30 > sma50 and sma50 > sma100) then
        if sma30 > price and price > sma50 then
            alert = "\37"
        end
        core.host:execute(
            "drawLabel1",
            400 + labelId(i, j),
            xoff,
            core.CR_LEFT,
            40 + yoff,
            core.CR_TOP,
            core.H_Right,
            core.V_Center,
            arrows,
            instance.parameters.upColor,
            "\228" .. alert
        ) --  "\228\37\113"
    elseif (sma30 < sma50 and sma50 < sma100) then
        if sma30 < price and price < sma50 then
            alert = "\37"
        end
        core.host:execute(
            "drawLabel1",
            400 + labelId(i, j),
            xoff,
            core.CR_LEFT,
            40 + yoff,
            core.CR_TOP,
            core.H_Right,
            core.V_Center,
            arrows,
            instance.parameters.downColor,
            "\230" .. alert
        ) --  "\228\37\113"
    else
        core.host:execute(
            "drawLabel1",
            400 + labelId(i, j),
            xoff,
            core.CR_LEFT,
            40 + yoff,
            core.CR_TOP,
            core.H_Right,
            core.V_Center,
            arrows,
            instance.parameters.neutralColor,
            "\113"
        ) --  "\228\37\113"
    end
end

function ReleaseInstance()
    core.host:execute("deleteFont", normal)
    core.host:execute("deleteFont", arrows)
end

-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required extent (number of periods to look the back)
-- @return the stream reference
function registerStream(id, barSize, extent, instrument)
    local stream = {}
    local s1, e1, length
    local from, to

    s1, e1 = core.getcandle(barSize, 0, 0, 0)
    length = math.floor((e1 - s1) * 86400 + 0.5)

    stream.data = nil
    stream.barSize = barSize
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
    stream.dataFrom = from
    stream.data = host:execute("getHistory", id, instrument, barSize, 0, 0, source:isBid())
    setBookmark(0)

    streams[id] = stream
    return stream.data
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
    from = core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now())
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
    if cookie == 1 then
        rescanOffers()
        return
    end

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
    stream.MVA1 = core.indicators:create("MVA", stream.data.close, 30)
    stream.MVA1:update(core.UpdateAll)
    last_updated = 0
    instance:updateFrom(period)
end
