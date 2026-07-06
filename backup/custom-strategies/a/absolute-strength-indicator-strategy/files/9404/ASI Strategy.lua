-- Id: 3561
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3848

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
    strategy:name("Absolute Strength Indicator Strategy")
    strategy:description("")
    strategy:setTag("Version", "2");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("Strategy Mode")
    strategy.parameters:addString("Mode", "Strategy Mode", "", "SIGNAL")
    strategy.parameters:addStringAlternative("Mode", "Signal", "", "SIGNAL")
    strategy.parameters:addStringAlternative("Mode", "Strategy", "", "STRATEGY")

    strategy.parameters:addGroup("Signal Type")
    strategy.parameters:addString("SignalType", "Signal Type", "", "SIGNAL")
    strategy.parameters:addStringAlternative("SignalType", "Indicator / Signal Line CrossOver", "", "SIGNAL")
    strategy.parameters:addStringAlternative("SignalType", "Indicator / Indicator Line CrossOver", "", "INDICATOR")

    strategy.parameters:addGroup("Absolute Strength Indicator Parameters")

    strategy.parameters:addString("Method", "Method", "", "RSI")
    strategy.parameters:addStringAlternative("Method", "RSI", "", "RSI")
    strategy.parameters:addStringAlternative("Method", "Stoch", "", "Stoch")
    strategy.parameters:addStringAlternative("Method", "ADX", "", "ADX")

    strategy.parameters:addString("Method1", "Method", "Method", "MVA")
    strategy.parameters:addStringAlternative("Method1", "MVA", "MVA", "MVA")
    strategy.parameters:addStringAlternative("Method1", "EMA", "EMA", "EMA")
    strategy.parameters:addStringAlternative("Method1", "LWMA", "LWMA", "LWMA")
    strategy.parameters:addStringAlternative("Method1", "SMMA", "SMMA", "SMMA")

    strategy.parameters:addString("Type1", "CLOSE", "", "C")
    strategy.parameters:addStringAlternative("Type1", "OPEN", "", "O")
    strategy.parameters:addStringAlternative("Type1", "HIGH", "", "H")
    strategy.parameters:addStringAlternative("Type1", "LOW", "", "L")
    strategy.parameters:addStringAlternative("Type1", "CLOSE", "", "C")
    strategy.parameters:addStringAlternative("Type1", "MEDIAN", "", "M")
    strategy.parameters:addStringAlternative("Type1", "TYPICAL", "", "T")
    strategy.parameters:addStringAlternative("Type1", "WEIGHTED", "", "W")

    strategy.parameters:addInteger("Length", "Period for Evaluation", "", 10)
    strategy.parameters:addInteger("SignalPeriod", "Period for Signal", "", 5)
    strategy.parameters:addInteger("Smoothing", "Period for Smoothing", "", 5)

    strategy.parameters:addInteger("OverBought", "OverBought", "", 0)
    strategy.parameters:addInteger("OverSold", "OverSold", "", 0)

    Trading_Parameters()
end

-- Parameters block
local SIDE
local gSource = nil -- the source stream
local PlaySound
local RecurrentSound
local SoundFile
local Email
local SendEmail
local AllowTrade
local Account
local Amount
local BaseSize
local SetLimit
local Limit
local SetStop
local Stop
local TrailingStop
local Offer
local CanClose
local AllowMultiple
local ShowAlert
local first
--TODO: Add variable(s) for your strategy if needed
local indicator
local BullIndicator
local BearIndicator
local BullSignal
local BearSignal

local Type1

local Method
local Method1
local Length
local SignalPeriod
local Smoothing
local OverBought
local OverSold
local SignalType
local Mode
-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)
    Type1 = instance.parameters.Type1
    Mode = instance.parameters.Mode
    SignalType = instance.parameters.SignalType
    Condition = instance.parameters.Condition
    Method = instance.parameters.Method
    Method1 = instance.parameters.Method1
    Length = instance.parameters.Length
    SignalPeriod = instance.parameters.SignalPeriod
    Smoothing = instance.parameters.Smoothing
    OverBought = instance.parameters.OverBought
    OverSold = instance.parameters.OverSold

    Initialization()

    local name
    name = profile:id() .. "(" .. instance.bid:instrument() .. ", " .. instance.parameters.TF

    name = name .. ", " .. "(" .. Mode .. ", " .. SignalType .. ", " .. Method .. ")"

    assert(instance.parameters.TF ~= "t1", "timeframe must not be tick")

    name = name .. ")"

    --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)

    assert(
        core.indicators:findIndicator("ABSOLUTESTRENGTHINDICATOR") ~= nil,
        "Please download and install Absolute Strength Indicator!"
    )

    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    indicator =
        core.indicators:create(
        "ABSOLUTESTRENGTHINDICATOR",
        gSource,
        Method,
        Method1,
        Type1,
        Length,
        SignalPeriod,
        Smoothing,
        OverBought,
        OverSold,
        true,
        true
    )
    BullIndicator = indicator:getStream(0)
    BearIndicator = indicator:getStream(2)
    BullSignal = indicator:getStream(1)
    BearSignal = indicator:getStream(3)

    first = math.max(1, BullSignal:first(), BearSignal:first()) + 1
    first = math.max(first, BullIndicator:first(), BearIndicator:first()) + 1

    if nameOnly then
        return
    end
end

-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
local BearFlag
local BullFlag
function ExtUpdate(id, source, period)
    indicator:update(core.UpdateLast)

    if period < first or id ~= 1 then
        return
    end

    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if not BullIndicator:hasData(period) or not BearIndicator:hasData(period) then
        return
    end

    if not BullSignal:hasData(period) or not BearSignal:hasData(period) then
        return
    end

    if not BullIndicator:hasData(period - 1) or not BearIndicator:hasData(period - 1) then
        return
    end

    if not BullSignal:hasData(period - 1) or not BearSignal:hasData(period - 1) then
        return
    end

    if Mode == "STRATEGY" then
        if SignalType == "SIGNAL" then
            --Flags

            if core.crossesOver(BullIndicator, BullSignal, period) then
                BullFlag = true
            end

            if core.crossesUnder(BullIndicator, BullSignal, period) then
                BullFlag = false
            end

            if core.crossesOver(BearIndicator, BearSignal, period) then
                BearFlag = true
            end

            if core.crossesUnder(BearIndicator, BearSignal, period) then
                BearFlag = false
            end

            -- Trade

            if core.crossesOver(BullIndicator, BullSignal, period) and BullFlag and not BearFlag then
                BUY()
            end

            if core.crossesUnder(BullIndicator, BullSignal, period) and not BullFlag and BearFlag then
                SELL()
            end

            if core.crossesOver(BearIndicator, BearSignal, period) and not BullFlag and BearFlag then
                SELL()
            end

            if core.crossesUnder(BearIndicator, BearSignal, period) and BullFlag and not BearFlag then
                BUY()
            end
        end

        if SignalType == "INDICATOR" then
            if core.crossesOver(BullIndicator, BearIndicator, period) then
                BUY()
            elseif core.crossesUnder(BullIndicator, BearIndicator, period) then
                SELL()
            end
        end
    else
        if core.crossesOver(BullIndicator, BullSignal, period) then
            Alert("Bull / Bull Signal CrossOver")
        end

        if core.crossesUnder(BullIndicator, BullSignal, period) then
            Alert("Bull / Bull Signal CrossUnder")
        end

        if core.crossesOver(BearIndicator, BearSignal, period) then
            Alert("Bear / Bear Signal CrossOver")
        end

        if core.crossesUnder(BearIndicator, BearSignal, period) then
            Alert("Bear / Bear Signal CrossUnder")
        end

        if core.crossesOver(BullIndicator, BearIndicator, period) then
            Alert("Bull / Bear CrossOver")
        elseif core.crossesUnder(BullIndicator, BearIndicator, period) then
            Alert("Bull / Bear CrossOver")
        end
    end
end

function Alert(Label)
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

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BUY()
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

function SELL()
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
