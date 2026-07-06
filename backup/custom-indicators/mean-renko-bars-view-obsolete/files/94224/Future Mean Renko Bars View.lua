-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60743

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Future Mean Renko Bars View")
    indicator:description(
        "A chart where a new brick is added only when the price moves up or down by more than a predefined amount"
    )
    indicator:requiredSource(core.Tick)
    indicator:type(core.View)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("instrument", "Instrument", "", "EUR/USD")
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS)
    indicator.parameters:addString("frame", "Time Frame", "", "m15")
    indicator.parameters:setFlag("frame", core.FLAG_PERIODS)
    indicator.parameters:addBoolean("type", "Price Type", "", true)
    indicator.parameters:setFlag("type", core.FLAG_BIDASK)
    indicator.parameters:addInteger("Step", "Step (Pips)", "", 2)
    indicator.parameters:addDouble("OpeningPricePercentage", "Opening Price Percentage (%)", "", 50, 0, 100)
    indicator.parameters:addDouble("ReversalPercentage", "Reversal Percentage (%)", "", 200, 0, 1000)

    indicator.parameters:addBoolean("Smoothed", "Smoothed", "", true)
    indicator.parameters:addBoolean(
        "AlertChangeBarDirection",
        "Change Bar Direction Alert",
        "Direction change, from up to down candle.",
        false
    )

    indicator.parameters:addGroup("Range")
    indicator.parameters:addDate("from", "From", "", -1000)
    indicator.parameters:addDate("to", "To", "", 0)
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL)

    indicator.parameters:addColor("future_down", "Future down color", "", core.COLOR_DOWNCANDLE)
    indicator.parameters:addColor("future_up", "Future up color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addInteger("transp", "Future bars transparency", "", 80, 0, 100)
end

local loading
local instrument
local frame
local StepPips
local history
local open, high, low, close
local iopen, ihigh, ilow, iclose
local offer
local offset
local OneSecond
local LastTime
local OpeningPricePercentage
local Smoothed
local ReversalPercentage
local Flag
local Last
local AlertChangeBarDirection = nil

function Prepare(onlyName)
    instrument = instance.parameters.instrument

    OpeningPricePercentage = instance.parameters.OpeningPricePercentage
    ReversalPercentage = instance.parameters.ReversalPercentage
    Smoothed = instance.parameters.Smoothed
    frame = instance.parameters.frame
    AlertChangeBarDirection = instance.parameters.AlertChangeBarDirection

    if frame == "t1" then
        Flag = true
    else
        Flag = false
    end

    local name = profile:id() .. "(" .. instrument .. "." .. frame .. ")"
    instance:name(name)

    if onlyName then
        return
    end

    -- check whether the instrument is available
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

    assert(row ~= nil, "Instrument not found")

    offer = row.OfferID

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0)

    loading = true
    history =
        core.host:execute(
        "getHistory",
        1000,
        instrument,
        frame,
        instance.parameters.from,
        instance.parameters.to,
        instance.parameters.type
    )
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers")
    end
    if Flag then
        StepPips = instance.parameters.Step * history:pipSize()
    else
        StepPips = instance.parameters.Step * history.close:pipSize()
    end

    core.host:execute("setStatus", "Loading")
    open = instance:addStream("open", core.Line, name .. "." .. "open", "open", 0, 0, 0)
    high = instance:addStream("high", core.Line, name .. "." .. "high", "high", 0, 0, 0)
    low = instance:addStream("low", core.Line, name .. "." .. "low", "low", 0, 0, 0)
    close = instance:addStream("close", core.Line, name .. "." .. "close", "close", 0, 0, 0)
    instance:createCandleGroup("Renko", "Renko", open, high, low, close, nil, frame)

    OneSecond = 1 / 86400
    instance:ownerDrawn(true);
end

function Update(period)
end

local init = false;
local DOWN_BRUSH = 1;
local DOWN_PEN = 2;
local UP_BRUSH = 3;
local UP_PEN = 4;
local transp;

function Draw(stage, context)
    local current = open:size() - 1;
    if stage ~= 0 or history:size() == 0 or current <= 0 then
        return;
    end
    if not init then
        context:createPen(DOWN_PEN, context.SOLID, 1, instance.parameters.future_down);
        context:createSolidBrush(DOWN_BRUSH, instance.parameters.future_down);
        context:createPen(UP_PEN, context.SOLID, 1, instance.parameters.future_up);
        context:createSolidBrush(UP_BRUSH, instance.parameters.future_up);
        transp = context:convertTransparency(instance.parameters.transp);
        init = true;
    end
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
    local history_asc = history.close[NOW] > history.open[NOW];
    local chart_asc = close[NOW] > open[NOW];
    local fromPrice = (close[NOW] + open[NOW]) / 2;

    local diff = history.close[NOW] - fromPrice;
    local min_diff = StepPips * OpeningPricePercentage / 100;
    local reverse_min_diff = StepPips * ReversalPercentage / 100;
    if chart_asc then
        if history_asc then
            if diff < min_diff then
                return;
            end
        else
            if -diff < reverse_min_diff then
                return;
            end
        end
    else
        if history_asc then
            if diff < reverse_min_diff then
                return;
            end
        else
            if -diff < min_diff then
                return;
            end
        end
    end
    local pos = current + 1;
    if diff < 0 then
        while (diff < 0) do
            local toPrice = fromPrice - math.min(math.abs(diff), StepPips);
            local x, x1, x2 = context:positionOfBar(pos);
            local _, y1 = context:pointOfPrice(fromPrice)
            local _, y2 = context:pointOfPrice(toPrice)
            context:drawRectangle(DOWN_PEN, DOWN_BRUSH, x1, y1, x2, y2, transp);
            if math.abs(diff) < StepPips then
                return;
            end
            diff = diff + StepPips * OpeningPricePercentage / 100;
            pos = pos + 1;
            fromPrice = fromPrice - math.min(math.abs(diff), StepPips * OpeningPricePercentage / 100);
        end
    else
        while (diff > 0) do
            local toPrice = fromPrice + math.min(math.abs(diff), StepPips);
            local x, x1, x2 = context:positionOfBar(pos);
            local _, y1 = context:pointOfPrice(fromPrice)
            local _, y2 = context:pointOfPrice(toPrice)
            context:drawRectangle(UP_PEN, UP_BRUSH, x1, y1, x2, y2, transp);

            if math.abs(diff) < StepPips then
                return;
            end
            diff = diff - StepPips * OpeningPricePercentage / 100;
            pos = pos + 1;
            fromPrice = fromPrice + math.min(math.abs(diff), StepPips * OpeningPricePercentage / 100);
        end
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
        handleHistory()
        core.host:execute("setStatus", "")
    elseif cookie == 2000 then
        if message == offer then
            handleUpdate()
        end
    end
end

local lastDirection

function calcFirstValueValue(current, i)
    local source
    if Flag then
        source = history
    else
        source = history.close
    end
    local open_val = math.floor(source[0] / StepPips) * StepPips
    while source[i] > open_val + StepPips do
        current = current + 1
        if current == 0 then
            instance:addViewBar(source:date(0))
        else
            instance:addViewBar(open:date(current - 1) + OneSecond)
        end
        open[current] = open_val
        close[current] = open[current] + StepPips
        low[current] = open[current]
        high[current] = close[current]
        lastDirection = 1
        open_val = open_val + StepPips
    end
    open_val = math.floor(source[0] / StepPips) * StepPips
    while source[i] < open_val - StepPips do
        current = current + 1
        if current == 0 then
            instance:addViewBar(source:date(0))
        else
            instance:addViewBar(open:date(current - 1) + OneSecond)
        end
        open[current] = open_val
        close[current] = open[current] - StepPips
        high[current] = open[current]
        low[current] = close[current]
        lastDirection = -1
        open_val = open_val - StepPips
    end

    return current
end

function calcValue(current, i)
    if current == -1 then
        return calcFirstValueValue(current, i)
    end

    local min, max
    local source
    if Flag then
        source = history
    else
        source = history.close
    end
    -- local diff = history.close[i] - history.open[i];
    --  local diff = close[current] - open[current];
    --  if diff > 0 or (diff == 0 and lastDirection == 1) then
    if lastDirection == 1 then
        --lastDirection = 1;
        while source[i] > close[current] + StepPips do
            current = current + 1
            if open:date(current - 1) < source:date(i) then
                instance:addViewBar(source:date(i))
            else
                instance:addViewBar(open:date(current - 1) + OneSecond)
            end

            if Smoothed then
                if close[current - 1] > open[current - 1] then
                    open[current] = open[current - 1] + (StepPips / 100) * OpeningPricePercentage
                else
                    open[current] = close[current - 1] + (StepPips / 100) * OpeningPricePercentage
                end
            else
                if close[current - 1] > open[current - 1] then
                    open[current] = open[current - 1] + (StepPips / 100) * OpeningPricePercentage
                else
                    open[current] = open[current - 1] - (StepPips / 100) * OpeningPricePercentage
                end
            end

            close[current] = open[current] + StepPips

            low[current] = math.min(open[current], close[current])

            high[current] = math.max(open[current], close[current])
        end
        if source[i] < close[current] - (ReversalPercentage / 100) * StepPips then
            lastDirection = -1

            while source[i] < close[current] - StepPips do
                current = current + 1
                if open:date(current - 1) < source:date(i) then
                    instance:addViewBar(source:date(i))
                    ShowAlertOnChangeDirection(instrument, close[current], source:date(i))
                else
                    instance:addViewBar(open:date(current - 1) + OneSecond)
                end

                if Smoothed then
                    if close[current - 1] > open[current - 1] then
                        open[current] = close[current - 1] - (StepPips / 100) * OpeningPricePercentage
                    else
                        open[current] = open[current - 1] - (StepPips / 100) * OpeningPricePercentage
                    end
                else
                    if close[current - 1] > open[current - 1] then
                        open[current] = open[current - 1] + (StepPips / 100) * OpeningPricePercentage
                    else
                        open[current] = open[current - 1] - (StepPips / 100) * OpeningPricePercentage
                    end
                end
                close[current] = open[current] - StepPips

                low[current] = math.min(open[current], close[current])

                high[current] = math.max(open[current], close[current])
            end
        end
    end

    --if diff < 0 or (diff == 0 and lastDirection == -1) then
    if lastDirection == -1 then
        -- lastDirection = -1;
        while source[i] < close[current] - StepPips do
            current = current + 1
            if open:date(current - 1) < source:date(i) then
                instance:addViewBar(source:date(i))
            else
                instance:addViewBar(open:date(current - 1) + OneSecond)
            end

            if Smoothed then
                if close[current - 1] < open[current - 1] then
                    open[current] = open[current - 1] - (StepPips / 100) * OpeningPricePercentage
                else
                    open[current] = close[current - 1] - (StepPips / 100) * OpeningPricePercentage
                end
            else
                if close[current - 1] < open[current - 1] then
                    open[current] = open[current - 1] - (StepPips / 100) * OpeningPricePercentage
                else
                    open[current] = open[current - 1] + (StepPips / 100) * OpeningPricePercentage
                end
            end

            close[current] = open[current] - StepPips

            low[current] = math.min(open[current], close[current])

            high[current] = math.max(open[current], close[current])
        end

        if source[i] > close[current] + (ReversalPercentage / 100) * StepPips then
            lastDirection = 1
            while source[i] > close[current] + StepPips do
                current = current + 1
                if open:date(current - 1) < source:date(i) then
                    instance:addViewBar(source:date(i))
                else
                    instance:addViewBar(open:date(current - 1) + OneSecond)
                end

                if Smoothed then
                    if close[current - 1] < open[current - 1] then
                        open[current] = close[current - 1] + (StepPips / 100) * OpeningPricePercentage
                    else
                        open[current] = open[current - 1] + (StepPips / 100) * OpeningPricePercentage
                    end
                else
                    if close[current - 1] < open[current - 1] then
                        open[current] = open[current - 1] - (StepPips / 100) * OpeningPricePercentage
                    else
                        open[current] = open[current - 1] + (StepPips / 100) * OpeningPricePercentage
                    end
                end

                close[current] = open[current] + StepPips

                low[current] = math.min(open[current], close[current])

                high[current] = math.max(open[current], close[current])
            end
        end
    end

    if low[current] == 0 then
        low[current] = math.min(open[current], close[current])
    end

    low[current] = math.min(low[current], source[i])

    high[current] = math.max(high[current], source[i])

    return current
end

function ShowAlertOnChangeDirection(instrument, price, time)
    if AlertChangeBarDirection == true then
        terminal:alertMessage(instrument, price, "Candle changed directon, from up to down.", time)
    end
end

function handleHistory()
    local s = history:size() - 1
    local i
    local current = open:size() - 1
    for i = 1, s, 1 do
        current = calcValue(current, i)
    end
    loading = false
    LastTime = history:date(history:size() - 1)
end

function handleUpdate()
    if not loading and history:size() > 0 then
        if history:date(history:size() - 1) ~= LastTime then
            calcValue(open:size() - 1, history:size() - 2)
            LastTime = history:date(history:size() - 1)
        end
    end
end
