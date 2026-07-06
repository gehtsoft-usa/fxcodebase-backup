-- Id: 13979
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=62109

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    strategy:name("Price Action Strategy")
    strategy:description("")
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addString("TF", "Timeframe", "", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trading")
    strategy.parameters:addString("Account", "Account", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addBoolean("CanTrade", "Allow Trading", "", false)
    strategy.parameters:setFlag("CanTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addInteger("amount_risk", "Trade size (% of risk)", "", 1, 1, 50)

    strategy.parameters:addGroup("Signal Parameters")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false)

    strategy.parameters:addGroup("Email Parameters")
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false)
    strategy.parameters:addString("Email", "Email address", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- Signal Parameters
local ShowAlert
local SoundFile
local RecurrentSound
local SendEmail, Email

local source = nil
local QTXT_B
local QTXT_S
local CanTrade
--in
function ensure_hedging_account(account_id)
    local account = core.host:findTable("accounts"):find("AccountID", account_id)
    assert(account.Hedging == "Y", "Only hedging accounts are supported")
end

function Prepare(nameOnly)
    local name = profile:id()
    instance:name(name)
    if nameOnly then
        return
    end
    Account = instance.parameters.Account
    ensure_hedging_account(Account)

    CanTrade = instance.parameters.CanTrade
    OfferId = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    base_unit_size = core.host:execute("getTradingProperty", "minQuantity", instance.bid:instrument(), Account)

    ShowAlert = instance.parameters.ShowAlert
    local PlaySound = instance.parameters.PlaySound
    if PlaySound then
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end
    assert(not (PlaySound) or SoundFile ~= "", "Sound file must be chosen")
    RecurrentSound = instance.parameters.Recurrent

    local SendEmail = instance.parameters.SendEmail
    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or Email ~= "", "Email address must be specified")

    source_bid = ExtSubscribe(1, nil, instance.parameters.TF, true, "bar")
    source_ask = ExtSubscribe(2, nil, instance.parameters.TF, false, "bar")
    source = ExtSubscribe(3, nil, "t1", true, "tick")
end

function getAmount(stop)
    local account = core.host:findTable("accounts"):find("AccountID", Account)
    local emr = core.host:execute("getTradingProperty", "EMR", instance.bid:instrument(), Account)
    local lots = math.floor((instance.parameters.amount_risk / 100.0) * account.Equity / emr)
    return math.max(1, lots) * base_unit_size
end

function enter(BuySell, period)
    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.OrderType = "OM"
    valuemap.OfferID = OfferId
    valuemap.AcctID = Account
    valuemap.BuySell = BuySell
    local stop
    local id
    if BuySell == "B" then
        stop = source_bid.low[period]
        valuemap.CustomID = QTXT_B
        id = 1000
    else
        stop = source_ask.high[period]
        valuemap.CustomID = QTXT_S
        id = 1001
    end
    valuemap.RateStop = stop
    valuemap.Quantity = getAmount(stop)
    success, msg = terminal:execute(id, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            source.close[NOW],
            "Open order failed" .. msg,
            source:date(NOW)
        )
    end
end

-- finds a position by custom id
function findPosition(customID)
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while (row ~= nil) do
        if row.QTXT == customID then
            return row
        end
        row = enum:next()
    end
    return nil
end

-- finds a closed position by custom id
function findClosedPosition(customID)
    local enum = core.host:findTable("closed trades"):enumerator()
    local row = enum:next()
    while (row ~= nil) do
        if row.OQTXT == customID then
            return row
        end
        row = enum:next()
    end
    return nil
end

local pos_created = 0
local creating_positions = false
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then
        if not success then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[instance.bid:size() - 1],
                "Position creation failed: " .. message,
                instance.bid:date(instance.bid:size() - 1)
            )
        end
        pos_created = pos_created + 1
    elseif cookie == 1001 then
        if not success then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[instance.bid:size() - 1],
                "Position creation failed: " .. message,
                instance.bid:date(instance.bid:size() - 1)
            )
        end
        pos_created = pos_created + 1
    elseif cookie == 103 then
        if not success then
            buy_breakeven_moved = false
        end
    elseif cookie == 104 then
        if not success then
            sell_breakeven_moved = false
        end
    end
    if pos_created == 2 then
        creating_positions = false
        pos_created = 0
    end
end

-- Edit Order
-- http://www.fxcodebase.com/documents/IndicoreSDK/web-content.html?key=TradingCommandsEditOrder.html
function createEditOrderCommand(orderId, acctID, rate, pegType, pegPriceOffsetPips, trailUpdatePips, quantity, customID)
    local valuemap = core.valuemap()

    valuemap.Command = "EditOrder"
    valuemap.OrderID = orderId
    valuemap.AcctID = acctID
    valuemap.Rate = rate
    valuemap.PegType = pegType
    valuemap.PegPriceOffsetPips = pegPriceOffsetPips
    valuemap.TrailUpdatePips = trailUpdatePips
    valuemap.Quantity = quantity
    valuemap.CustomID = customID

    return valuemap
end

local sell_breakeven_moved = false
local buy_breakeven_moved = false

function ExtUpdate(id, source1, period)
    if not CanTrade then
        return
    end

    if creating_positions then
        return
    end
    local buy_position = findPosition(QTXT_B)
    local sell_position = findPosition(QTXT_S)
    if buy_position == nil and sell_position == nil then
        if id == 1 then
            creating_positions = true
            pos_created = 0
            sell_breakeven_moved = false
            buy_breakeven_moved = false
            QTXT_B = "price_action_B" .. tostring(core.now())
            QTXT_S = "price_action_S" .. tostring(core.now())
            enter("B", period)
            enter("S", period)
        end
    elseif sell_position == nil and not buy_breakeven_moved then
        sell_position = findClosedPosition(QTXT_S)
        if sell_position ~= nil and buy_position ~= nil then
            local lots_ratio = sell_position.Lot / buy_position.Lot
            local new_stop = buy_position.Open + (lots_ratio * math.abs(sell_position.PL)) * source_bid:pipSize()
            if new_stop < source_bid.close[NOW] then
                local command = createEditOrderCommand(buy_position.StopOrderID, buy_position.AccountID, new_stop)
                local success, msg = terminal:execute(103, command)
                if not success then
                    terminal:alertMessage("", 0, "Failed to move stop: " .. msg .. "'", core.now())
                else
                    buy_breakeven_moved = true
                end
            end
        end
    elseif buy_position == nil and not sell_breakeven_moved then
        buy_position = findClosedPosition(QTXT_B)
        if sell_position ~= nil and buy_position ~= nil then
            local lots_ratio = buy_position.Lot / sell_position.Lot
            local new_stop = sell_position.Open - (lots_ratio * math.abs(buy_position.PL)) * source_bid:pipSize()
            if new_stop > source_ask.close[NOW] then
                local command = createEditOrderCommand(sell_position.StopOrderID, sell_position.AccountID, new_stop)
                local success, msg = terminal:execute(104, command)
                if not success then
                    terminal:alertMessage("", 0, "Failed to move stop: " .. msg .. "'", core.now())
                else
                    sell_breakeven_moved = true
                end
            end
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
