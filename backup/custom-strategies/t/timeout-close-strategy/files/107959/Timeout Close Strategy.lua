-- Id: 16602
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=63836

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
    strategy:name("Timeout Close Strategy")
    strategy:description("Deletes selected positions all N minutes")

    strategy.parameters:addGroup("Settings")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("Account", "Account", "Account to monitor open positions for.", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)

    strategy.parameters:addInteger("Timeout", "Timeout (in minutes)", "", 5)
end

local Offer, Account, Timeout, AllowTrade, CanClose  -- Source;

function Prepare(onlyName)
    local name = profile:id()

    instance:name(name)
    Account = instance.parameters.Account
    Timeout = instance.parameters.Timeout
    AllowTrade = instance.parameters.AllowTrade
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)

    if onlyName then
        return
    end

    -- ExtSetupSignal(name .. ":", true);
    --  Source = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "tick");

    core.host:execute("setTimer", 100, 1)
end

function haveTrades()
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account then
            return true
        end
        row = enum:next()
    end
end

function CloseAll() -- new code from victor
    local enum, row
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()

    --row.Time
    --DateTime
    --The date and time when the position was opened. The date and time are in the EST/EDT time.

    --core.now()
    --The method returns the date and time as a number.
    --That number means the number of days past midnight December 30, 1899 (also known as the OLE date/time format).
    -- The date and time is in the user's local time zone.

    local now = core.host:execute("getServerTime")
    while (row ~= nil) do
        if row.AccountID == Account and (row.Time + (Timeout * 60) * (1 / 86400)) < now then
            exitTrade(row)
        end

        row = enum:next()
    end
end

function ExtUpdate(id, source, period)
end

function ExtAsyncOperationFinished(id, success, message)
    if id ~= 100 then
        return
    end

    if not (checkReady("trades")) then
        return
    end

    if haveTrades() then
        CloseAll()
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table)
end

-- exit from the specified direction
function exitTrade(tradeRow)
    if not (AllowTrade) then
        return true
    end

    local valuemap, success, msg
    valuemap = core.valuemap()

    -- switch the direction since the order must be in oppsite direction
    if tradeRow.BS == "B" then
        BuySell = "S"
    else
        BuySell = "B"
    end
    valuemap.OrderType = "CM"
    valuemap.OfferID = tradeRow.OfferID
    valuemap.AcctID = tradeRow.AccountID
    if (CanClose) then
        -- Non-FIFO can close each trade independantly.
        valuemap.TradeID = tradeRow.TradeID
        valuemap.Quantity = tradeRow.Lot
    else
        -- FIFO.
        valuemap.NetQtyFlag = "Y" -- this forces all trades to close in the opposite direction.
    end
    valuemap.BuySell = BuySell
    success, msg = terminal:execute(201, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Close order failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    return true
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
