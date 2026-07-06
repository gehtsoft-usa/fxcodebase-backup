-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69563

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ATR Range bars")
    indicator:description("")
    indicator:type(core.View)

    indicator.parameters:addGroup("Price Parameters")
    indicator.parameters:addString("instrument", "Instrument", "", "EUR/USD")
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS)
    indicator.parameters:addString("frame", "Timeframe", "Timeframe", "H1")
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS)
    indicator.parameters:addBoolean("type", "Price type", "Price type", true)
    indicator.parameters:setFlag("type", core.FLAG_BIDASK)

    indicator.parameters:addString("atr_frame", "ATR Timeframe", "", "D1")
    indicator.parameters:setFlag("atr_frame", core.FLAG_BARPERIODS)
    indicator.parameters:addInteger("atr_period", "ATR Period", "", 14)
    
    indicator.parameters:addGroup("Range")
    indicator.parameters:addDate("from", "Date From", "", -1000)
    indicator.parameters:addDate("to", "Date to", "", 0)
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL)
end

local loading
local instrument
local frame
local history
local open, high, low, close, volume
local offer
local offset
local sumvolume, lasthistorytime, atr, atr_source;

function Prepare(onlyName)
    instrument = instance.parameters.instrument

    local name = profile:id() .. "(" .. instrument .. "." .. ")"
    instance:name(name)

    if onlyName then
        return
    end

    local offers = core.host:findTable("offers")
    local enum = offers:enumerator()
    local row

    row = enum:next()
    while row ~= nil do
        if row.Instrument == instrument then
            break
        end
        row = enum:next()
    end

    assert(row ~= nil, "Instrument is not found")

    offer = row.OfferID

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0)

    loading = true
    history =
        core.host:execute(
        "getHistory",
        1000,
        instrument,
        instance.parameters.frame,
        instance.parameters.from,
        instance.parameters.to,
        instance.parameters.type
    )
    atr_source = core.host:execute("getHistory", 1001, instrument, instance.parameters.atr_frame, instance.parameters.from, instance.parameters.to, instance.parameters.type)
    atr = core.indicators:create("ATR", atr_source, instance.parameters.atr_period);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers")
    end

    open = instance:addStream("open", core.Line, name .. ".open", "open", 0, 0, 0)
    high = instance:addStream("high", core.Line, name .. ".high", "high", 0, 0, 0)
    low = instance:addStream("low", core.Line, name .. ".low", "low", 0, 0, 0)
    close = instance:addStream("close", core.Line, name .. ".close", "close", 0, 0, 0)
    volume = instance:addStream("volume", core.Line, name .. ".volume", "volume", 0, 0, 0)
    sumvolume = instance:addInternalStream(0, 0)
    lasthistorytime = instance:addInternalStream(0, 0)

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, "")
end

function Update(period, mode)
end

local update_main = true;
function AsyncOperationFinished(cookie, success, message, message1, message2)
    atr:update(core.UpdateLast);
    if cookie == 1000 then
        if atr.DATA:size() == 0 then
            return;
        end
        handleHistory()
    elseif cookie == 2000 then
        if atr.DATA:size() == 0 then
            return;
        elseif update_main == true then
            handleHistory()
            update_main = false;
        else
            if message == offer then
                handleUpdate()
            end
        end
    end
end

function handleHistory()
    local s = history:size() - 1
    local current = open:size()
    local source = history
    instance:addViewBar(source:date(0))
    open[current] = source.open[0]
    high[current] = source.high[0]
    low[current] = source.low[0]
    close[current] = source.close[0]
    volume[current] = source.volume[0]

    for i = 1, s, 1 do
        local index = core.findDate(atr.DATA, source:date(i), false);
        if index >= 0 then
            if high[current] - low[current] >= atr.DATA[index] then
                current = current + 1
                instance:addViewBar(source:date(i))
                open[current] = close[current - 1]
                high[current] = source.high[i]
                low[current] = source.low[i]
                close[current] = source.close[i]
                sumvolume[current] = 0
                lasthistorytime[current] = source:date(i)
            else
                if source.high[i] > high[current] then
                    high[current] = source.high[i]
                end
                if source.low[i] < low[current] then
                    low[current] = source.low[i]
                end
                close[current] = source.close[i]
                if lasthistorytime[current] ~= source:date(i) then
                    sumvolume[current] = sumvolume[current] + source.volume[i - 1]
                    lasthistorytime[current] = source:date(i)
                end
                volume[current] = sumvolume[current] + source.volume[i]
            end
        end
    end

    loading = false
end

function handleUpdate()
    if not loading and history:size() > 0 then
        local i = history:size() - 1
        local current = open:size() - 1
        local source = history

        local index = core.findDate(atr.DATA, source:date(i), false);
        if index >= 0 then
            if high[current] - low[current] >= atr.DATA[index] then
                current = current + 1
                instance:addViewBar(source:date(i))
                open[current] = close[current - 1]
                high[current] = source.high[i]
                low[current] = source.low[i]
                close[current] = source.close[i]
                sumvolume[current] = 0
                lasthistorytime[current] = source:date(i)
            else
                if source.high[i] > high[current] then
                    high[current] = source.high[i]
                end
                if source.low[i] < low[current] then
                    low[current] = source.low[i]
                end
                close[current] = source.close[i]
                if lasthistorytime[current] ~= source:date(i) then
                    sumvolume[current] = sumvolume[current] + source.volume[i - 1]
                    lasthistorytime[current] = source:date(i)
                end
                volume[current] = sumvolume[current] + source.volume[i]
            end
        end
    end
end
