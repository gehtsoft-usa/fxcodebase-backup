-- Id: 3856
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4156

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
    strategy:name("The 3 Duck's Trading System Strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("Fast Time Frame")
    Parameters(3, "m5")
    strategy.parameters:addGroup("Mid Time Frame")
    Parameters(2, "H1")
    strategy.parameters:addGroup("Slow Time Frame")
    Parameters(1, "H4")

    strategy.parameters:addBoolean("Confirmation", "Use  Confirmation", "", false)

    Trading_Parameters()
end

function Parameters(id, TF)
    strategy.parameters:addString("TF" .. id, "TF", "Time frame ('t1', 'm1', 'm5', etc.)", TF)
    strategy.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)

    strategy.parameters:addInteger("PERIOD" .. id, "Signal Periods", "", 60)

    strategy.parameters:addString(
        "MA" .. id,
        "Smoothing Method",
        "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.",
        "MVA"
    )
    strategy.parameters:addStringAlternative("MA" .. id, "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("MA" .. id, "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("MA" .. id, "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("MA" .. id, "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("MA" .. id, "SMMA*", "", "SMMA")
    strategy.parameters:addStringAlternative("MA" .. id, "Vidya (1995)*", "", "VIDYA")
    strategy.parameters:addStringAlternative("MA" .. id, "Wilders*", "", "WMA")

    strategy.parameters:addString("Price" .. id, "Price", "", "close")
    strategy.parameters:addStringAlternative("Price" .. id, "open", "", "open")
    strategy.parameters:addStringAlternative("Price" .. id, "high", "", "high")
    strategy.parameters:addStringAlternative("Price" .. id, "low", "", "low")
    strategy.parameters:addStringAlternative("Price" .. id, "close", "", "close")
    strategy.parameters:addStringAlternative("Price" .. id, "median", "", "median")
    strategy.parameters:addStringAlternative("Price" .. id, "typical", "", "typical")
    strategy.parameters:addStringAlternative("Price" .. id, "weighted", "", "weighted")
end

-- Parameters block
local gSource = nil -- the source stream

local first = 1
--TODO: Add variable(s) for your strategy if needed
local indicator = {}
local PERIOD = {}
local TF = {}
local Confirmation
local Price = {}
local MA = {}

local SoundFile = nil
local RecurrentSound = false
local ALLOWEDSIDE
local AllowMultiple
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

-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)
    Confirmation = instance.parameters.Confirmation

    local i

    local name
    name = profile:id() .. "(" .. instance.bid:instrument()

    for i = 1, 3, 1 do
        TF[i] = instance.parameters:getString("TF" .. i)
        PERIOD[i] = instance.parameters:getInteger("PERIOD" .. i)
        Price[i] = instance.parameters:getString("Price" .. i)
        MA[i] = instance.parameters:getString("MA" .. i)

        name = name .. ", (" .. ", " .. PERIOD[i] .. "," .. TF[i] .. ")"
        assert(TF[i] ~= "t1", "timeframe must not be tick")
    end

    name = name .. ")"

    assert(core.indicators:findIndicator("MF_MA") ~= nil, "Please, download and install MF_MA.LUA indicator")

    Initialization()

    --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)

    gSource = ExtSubscribe(1, nil, TF[3], instance.parameters.Type == "Bid", "bar")

    for i = 1, 3, 1 do
        indicator[i] = core.indicators:create("MF_MA", gSource, PERIOD[i], MA[i], TF[i], Price[i])
        first = math.max(first, indicator[i].DATA:first())
    end

    if nameOnly then
        return
    end
end

-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
function ExtUpdate(id, source, period)
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if period < first + 1 then
        return
    end

    local FLAG = {nil, nil}
    local BUY = false
    local SELL = false
    local i

    for i = 1, 3, 1 do
        indicator[i]:update(core.UpdateLast)

        if indicator[i].DATA:hasData(period) then
            if gSource.close[period] > indicator[i].DATA[period] then
                FLAG[i] = true

                if AllowTrade then
                    if haveTrades("S") then
                        exit("S")
                        Signal("Close Short")
                    end
                elseif ShowAlert then
                    Signal("Close Short")
                end
            elseif gSource.close[period] < indicator[i].DATA[period] then
                FLAG[i] = false

                if AllowTrade then
                    if haveTrades("B") then
                        exit("B")
                        Signal("Close Long")
                    end
                elseif ShowAlert then
                    Signal("Close Long")
                end
            end
        end
    end

    if FLAG[1] == nil or FLAG[2] == nil then
        return
    else
        FLAG[4] = false
        FLAG[5] = true

        if Confirmation then
            if gSource.close[period] > gSource.high[period - 1] then
                FLAG[4] = true
            elseif gSource.close[period] < gSource.low[period - 1] then
                FLAG[5] = false
            end
        else
            FLAG[4] = true
            FLAG[5] = false
        end

        if indicator[3].DATA:hasData(period) and indicator[3].DATA:hasData(period - 1) then
            if FLAG[1] and FLAG[2] and FLAG[4] then
                if core.crossesOver(gSource.close, indicator[3].DATA, period) then
                    BUY = true
                end
            elseif not FLAG[1] and not FLAG[2] and not FLAG[5] then
                if core.crossesUnder(gSource.close, indicator[3].DATA, period) then
                    SELL = true
                end
            end
        end
    end

    --ENTRY
    if BUY then
        BT()
    elseif SELL then
        ST()
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BT()
    if AllowTrade then
        if haveTrades("B") and not AllowMultiple then
            exit("S")
            Signal("Close Short")

            return
        end

        if ALLOWEDSIDE == "Sell" then
            if haveTrades("S") then
                exit("S")
                Signal("Close Short")
            end

            return
        end

        if haveTrades("S") then
            exit("S")
            Signal("Close Short")
        end
        enter("B")
        Signal("Open Long")
    elseif ShowAlert then
        Signal("Up Trend")
    end
end

function ST()
    if AllowTrade then
        if haveTrades("S") and not AllowMultiple then
            exit("B")
            Signal("Close Long")

            return
        end

        if ALLOWEDSIDE == "Buy" then
            if haveTrades("B") then
                exit("B")
                Signal("Close Long")
            end

            return
        end

        if haveTrades("B") then
            exit("B")
            Signal("Close Long")
        end
        enter("S")
        Signal("Open Short")
    else
        Signal("Down Trend")
    end
end

function Trading_Parameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString(
        "ALLOWEDSIDE",
        "Allowed side",
        "Allowed side for trading or signaling, can be Sell, Buy or Both",
        "Both"
    )
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true)
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

function Initialization()
    AllowMultiple = instance.parameters.AllowMultiple
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
    if AllowTrade then
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
    while count == 0 and row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) then
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
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) then
            found = true
        end
        row = enum:next()
    end

    return found
end

-- enter into the specified direction
function enter(BuySell)
    if not (AllowTrade) then
        return true
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 and not AllowMultiple then
        return true
    end

    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell

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

    success, msg = terminal:execute(100, valuemap)

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

-- exit from the specified direction
function exit(BuySell, use_net)
    if not (AllowTrade) then
        return true
    end

    if use_net == true then
        local valuemap, success, msg
        if tradesCount(BuySell) > 0 then
            valuemap = core.valuemap()

            -- switch the direction since the order must be in oppsite direction
            if BuySell == "B" then
                BuySell = "S"
            else
                BuySell = "B"
            end
            valuemap.OrderType = "CM"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "Y"
            valuemap.BuySell = BuySell
            success, msg = terminal:execute(101, valuemap)

            if not(success) then
               terminal:alertMessage(
                   instance.bid:instrument(),
                   instance.bid[instance.bid:size() - 1],
                   "Open order failed"..msg,
                   instance.bid:date(instance.bid:size() - 1)
               )
                return false
            end
            return true
        end
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if row.BS == BuySell and row.OfferID == Offer then
                local valuemap = core.valuemap();
                valuemap.BuySell = row.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = row.AccountID;
                valuemap.TradeID = row.TradeID;
                valuemap.Quantity = row.Lot;
                local success, msg = terminal:execute(101, valuemap);
            end
        row = enum: next();
        end
    end
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
