-- Id: 11644
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=60628

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

function Init() --The strategy profile initialization
    strategy:name("Zscore Strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("TF", "Time frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addInteger("Period", "Periods", "", 20)
    strategy.parameters:addDouble("OB", "OB Level", "", 2)
    strategy.parameters:addDouble("OS", "OS Level", "", -2)

    strategy.parameters:addGroup("Selector")

    strategy.parameters:addString("Action" .. 1, "OB Line Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 1, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 1, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 1, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 1, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 1, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 2, "OB Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 2, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 2, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 2, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 2, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 2, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 3, "OS Line Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 3, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 3, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 3, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 3, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 3, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 4, "OS Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 4, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 4, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 4, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 4, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 4, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 5, "Central Line  Cross Over", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 5, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 5, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 5, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 5, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 5, "Alert", "", "Alert")

    strategy.parameters:addString("Action" .. 6, "Central Line Cross Under", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 6, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. 6, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. 6, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. 6, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. 6, "Alert", "", "Alert")

    CreateTradingParameters()
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    -- NG: optimizer/backtester hint
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true)
    strategy.parameters:addInteger("Max", "(One Side) Position Number Limit ", "", 1, 1, 10000)
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "123"
    )
    strategy.parameters:addString(
        "ALLOWEDSIDE",
        "Allowed side",
        "Allowed side for trading or signaling, can be Sell, Buy or Both",
        "Both"
    )
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)

    strategy.parameters:addGroup("Alerts")
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

local Source
local Max
local SoundFile = nil
local RecurrentSound = false
local ALLOWEDSIDE
local AllowTrade
local Offer
local CanClose
local Account
local Amount
local SetLimit
local Limit
local SetStop
local Stop
local TrailingStop
local ShowAlert
local Email
local SendEmail
local BaseSize
local zscore
local CloseOnOpposite
local first
local Period, OB, OS
local CustomID
local Action = {}
-- Don't need to store hour + minute + second for each time
local OpenTime, CloseTime, ExitTime
--
function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID
    Max = instance.parameters.Max
    CloseOnOpposite = instance.parameters.CloseOnOpposite
    Period = instance.parameters.Period
    OB = instance.parameters.OB
    OS = instance.parameters.OS

    assert(core.indicators:findIndicator("ZSCORE") ~= nil, "Please, download and install ZSCORE.LUA indicator")

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. Period .. "," .. CustomID .. " )"
    instance:name(name)

    for i = 1, 6, 1 do
        Action[i] = instance.parameters:getString("Action" .. i)
    end

    PrepareTrading()

    if nameOnly then
        return
    end

    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    zscore = core.indicators:create("ZSCORE", Source.close, Period)

    first = zscore.DATA:first() + 1
end

function PrepareTrading()
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE

    local PlaySound = instance.parameters.PlaySound
    if PlaySound then
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end
    assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen")

    ShowAlert = instance.parameters.ShowAlert
    RecurrentSound = instance.parameters.RecurrentSound

    SendEmail = instance.parameters.SendEmail

    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

    AllowTrade = instance.parameters.AllowTrade
    Account = instance.parameters.Account
    Amount = instance.parameters.Amount
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
    SetLimit = instance.parameters.SetLimit
    Limit = instance.parameters.Limit
    SetStop = instance.parameters.SetStop
    Stop = instance.parameters.Stop
    TrailingStop = instance.parameters.TrailingStop
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if id ~= 1 then
        -- if this is the bar source, abort.
        return
    end

    -- update indicators.
    zscore:update(core.UpdateLast)

    if period < first then
        -- not enough data, abort.
        return
    end

    if core.crossesOver(zscore:getStream(0), OB, period) then
        ACTION(1, OB, "Over")
    end
    if core.crossesUnder(zscore:getStream(0), OB, period) then
        ACTION(2, OB, "Under")
    end
    if core.crossesOver(zscore:getStream(0), OS, period) then
        ACTION(3, OS, "Over")
    end
    if core.crossesUnder(zscore:getStream(0), OS, period) then
        ACTION(4, OS, "Under")
    end
    if core.crossesOver(zscore:getStream(0), 0, period) then
        ACTION(5, 0, "Over")
    end

    if core.crossesUnder(zscore:getStream(0), 0, period) then
        ACTION(6, 0, "Under")
    end
end

function ACTION(Flag, Line, Label)
    if Action[Flag] == "NO" then
        return
    elseif Action[Flag] == "BUY" then
        BUY()
    elseif Action[Flag] == "SELL" then
        SELL()
    elseif Action[Flag] == "CLOSE" then
        if AllowTrade then
            if haveTrades("B") then
                exitSpecific("B")
                Signal("Close Long")
            end

            if haveTrades("S") then
                exitSpecific("S")
                Signal("Close Short")
            end
        else
            Signal("Close All")
        end
    elseif Action[Flag] == "Alert" then
        Signal(Line .. " Line Cross" .. Label)
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 200 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    elseif cookie == 201 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Close order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function BUY()
    if AllowTrade then
        if CloseOnOpposite and haveTrades("S") then
            -- close on opposite signal
            exitSpecific("S")
            Signal("Close Short")
        end

        if ALLOWEDSIDE == "Sell" then
            -- we are not allowed buys.
            return
        end

        enter("B")
    else
        Signal("Buy Signal")
    end
end

function SELL()
    if AllowTrade then
        if CloseOnOpposite and haveTrades("B") then
            -- close on opposite signal
            exitSpecific("B")
            Signal("Close Long")
        end

        if ALLOWEDSIDE == "Buy" then
            -- we are not allowed sells.
            return
        end

        enter("S")
    else
        Signal("Sell Signal")
    end
end

function Signal(Label)
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], Label, instance.bid:date(NOW))
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound)
    end

    if Email ~= nil then
        terminal:alertEmail(
            Email,
            Label,
            profile:id() ..
                "(" ..
                    instance.bid:instrument() ..
                        ")" .. instance.bid[NOW] .. ", " .. Label .. ", " .. instance.bid:date(NOW)
        )
    end
end

function checkReady(table)
    local rc
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true
    else
        rc = core.host:execute("isTableFilled", table)
    end

    return rc
end

function tradesCount(BuySell)
    local enum, row
    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while row ~= nil do
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and
                (row.BS == BuySell or BuySell == nil)
         then
            count = count + 1
        end

        row = enum:next()
    end

    return count
end

function haveTrades(BuySell)
    local enum, row
    local found = false
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while (row ~= nil) do
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and
                (row.BS == BuySell or BuySell == nil)
         then
            found = true
            break
        end

        row = enum:next()
    end

    return found
end

-- enter into the specified direction
function enter(BuySell)
    -- do not enter if position in the specified direction already exists
    if tradesCount(BuySell) > Max then
        return true
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal("Sell Signal")
    else
        Signal("Buy Signal")
    end

    return MarketOrder(BuySell)
end

-- enter into the specified direction
function MarketOrder(BuySell)
    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID

    -- add stop/limit
    valuemap.PegTypeStop = "O"
    if SetStop then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop
        else
            valuemap.PegPriceOffsetPipsStop = Stop
        end
    end
    if TrailingStop then
        valuemap.TrailStepStop = 1
    end

    valuemap.PegTypeLimit = "O"
    if SetLimit then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit
        end
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = "Y"
    end

    success, msg = terminal:execute(200, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    return true
end

-- exit from the specified trade using the direction as a key
function exitSpecific(BuySell)
    -- we have to loop through to exit all trades in each direction instead
    -- of using the net qty flag because we may be running multiple strategies on the same account.
    local enum, row
    local found = false
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while (not found) and (row ~= nil) do
        -- for every trade for this instance.
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and
                (row.BS == BuySell or BuySell == nil)
         then
            exitTrade(row)
        end

        row = enum:next()
    end
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
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    if (CanClose) then
        -- Non-FIFO can close each trade independantly.
        valuemap.TradeID = tradeRow.TradeID
        valuemap.Quantity = tradeRow.Lot
    else
        -- FIFO.
        valuemap.NetQtyFlag = "Y" -- this forces all trades to close in the opposite direction.
    end
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID
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
