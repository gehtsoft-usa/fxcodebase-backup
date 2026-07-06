-- Id: 18181
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64675

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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

function Init()
    strategy:name("SPIKE Trading Strategy")
    strategy:description("The strategy is to take advantage of the spikes in the market due to any event")
    strategy:setTag("group", "Other")
    strategy:type(core.Signal)

    strategy.parameters:addGroup("Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("account", "Account", "", "")
    strategy.parameters:setFlag("account", core.FLAG_ACCOUNT)

    strategy.parameters:addInteger("ProfitThreshold", "Profit Day threshold(%)", "", 10, 1, 100)
    strategy.parameters:addInteger("OrderDecreaseThreshold", "Order Decrease Threshold(%)", "", 5, 1, 100)
end

local gAccount
local gProfitThreshold
local gOrderDecreaseThreshold
local gProceseedPositions = {}
local gPipCost
local gPointSize
local gDigits

function Prepare(onlyName)
    gAccount = instance.parameters.account
    gOrderDecreaseThreshold = instance.parameters.OrderDecreaseThreshold
    gProfitThreshold = instance.parameters.ProfitThreshold

    local name = profile:id() .. "(" .. gAccount .. ")"
    instance:name(name)
    if onlyName then
        return
    end

    gPipCost = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).PipCost
    gPointSize = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).PointSize
    gDigits = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).Digits
end

function Update()
    local currentBalance = core.host:findTable("accounts"):find("AccountID", gAccount).Balance
    local dayPL = core.host:findTable("accounts"):find("AccountID", gAccount).DayPL
    --core.host:trace("CurBalance: " ..  currentBalance);
    --core.host:trace("DayPL: " ..  dayPL);
    local dayRelativeBalance = dayPL / currentBalance * 100 -- in %
    --core.host:trace("DayPLRelativeBalance: " ..  dayRelativeBalance);

    if gProfitThreshold > dayRelativeBalance then
        local positions = saveAll(gAccount)
        closeAll(gAccount)
        reOpen(gAccount, positions, currentBalance)
    end
end

function saveAll(accountID)
    local list = {}
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while row ~= nil do
        if gProceseedPositions[row.TradeID] == nil and row.AccountID == accountID then
            gProceseedPositions[row.TradeID] = true
            table.insert(
                list,
                {
                    TradeID = row.TradeID,
                    OfferID = row.OfferID,
                    BS = row.BS,
                    Quantity = row.Lot,
                    Open = row.Open,
                    Instrument = row.Instrument
                }
            )
        end
        row = enum:next()
    end

    --core.host:trace("Positions Count " ..  #list);

    return list
end

function isExist(savedTrades, trade)
    local found = false
    for i = 1, #savedTrades do
        if savedTrades[i].TradeID == trade.TradeID then
            found = true
            break
        end
    end

    return found
end

function closeAll(accountID)
    local closeList = getListForClose(accountID)

    for i = 1, #closeList do
        close(closeList[i], accountID)
    end

    --core.host:trace("Close Positions Count " ..  #closeList);
end

function getListForClose(accountID)
    local list = {}

    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while row ~= nil do
        if row.AccountID == accountID then
            table.insert(list, row)
        end
        row = enum:next()
    end

    return list
end

function close(trade, accountID)
    if not instance.parameters.AllowTrade then
        return;
    end
    local enum, row, valuemap, success, msg

    local canClose = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID)

    valuemap = core.valuemap()

    -- switch the direction since the order must be in oppsite direction
    valuemap.OrderType = canClose and "CM" or "OM"
    valuemap.OfferID = trade.OfferID
    valuemap.AcctID = accountID
    if canClose then
        valuemap.TradeID = trade.TradeID
    end
    valuemap.BuySell = (trade.BS == "B") and "S" or "B"
    valuemap.Quantity = trade.Lot

    --core.host:trace('Close position ' .. trade.TradeID .. ", Instrument = " .. trade.Instrument .. ", Amount = " .. tostring(trade.Lot))
    success, msg = terminal:execute(101, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Closing position failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

function reOpen(accountID, positions, curBalance)
    for i = 1, #positions do
        local rateOffset = calculateRateOffset(curBalance, gPipCost)
        --core.host:trace("Rate Offset: " ..  rateOffset);
        createEntry(
            accountID,
            positions[i].OfferID,
            positions[i].BS,
            positions[i].Quantity,
            rateOffset,
            positions[i].Instrument
        )
    end

    --core.host:trace("Open Positions Count " ..  #positions);
end

function calculateRateOffset(balance, pipCost)
    return (balance * gOrderDecreaseThreshold / 100) / pipCost
end

function createEntry(accountID, offerID, bs, quantity, rateOffset, instrument)
    if not instance.parameters.AllowTrade then
        return;
    end
    local valuemap, success, msg
    local source = instance.bid
    local rate = round(source[NOW] + rateOffset * gPointSize, gDigits)

    valuemap = core.valuemap()

    valuemap.Command = "CreateOrder"
    valuemap.OrderType = (rate > source[NOW]) and "LE" or "SE"
    valuemap.Rate = rate
    valuemap.OfferID = offerID
    valuemap.AcctID = accountID
    valuemap.BuySell = bs
    valuemap.Quantity = quantity

    core.host:trace(
        "Create order" ..
            ", Instrument = " .. instrument .. ", Amount = " .. tostring(quantity) .. ", Rate = " .. tostring(rate)
    )
    success, msg = terminal:execute(101, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open position failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

function round(num, digits)
    if digits and digits > 0 then
        local mult = 10 ^ digits
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
