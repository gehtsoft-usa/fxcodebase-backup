-- Id: 4143
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2763

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
    strategy:name("MA Crossover Strytegy")
    strategy:description("Breakout strategy")
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addBoolean("AllowTicks", "Allow Ticks", "", false)

    strategy.parameters:addGroup("Calculation")
    strategy.parameters:addString("FastMA_Method", "FastMA_Method", "", "EMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("FastMA_Method", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "Wilder", "", "Wilder")
    strategy.parameters:addStringAlternative("FastMA_Method", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "SineWMA", "", "SineWMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "TriMA", "", "TriMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "LSMA", "", "LSMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "HMA", "", "HMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "ZeroLagEMA", "", "ZeroLagEMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "DEMA", "", "DEMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "T3", "", "T3")
    strategy.parameters:addStringAlternative("FastMA_Method", "ITrend", "", "ITrend")
    strategy.parameters:addStringAlternative("FastMA_Method", "Median", "", "Median")
    strategy.parameters:addStringAlternative("FastMA_Method", "GeoMean", "", "GeoMean")
    strategy.parameters:addStringAlternative("FastMA_Method", "REMA", "", "REMA")
    strategy.parameters:addStringAlternative("FastMA_Method", "ILRS", "", "ILRS")
    strategy.parameters:addStringAlternative("FastMA_Method", "IE/2", "", "IE/2")
    strategy.parameters:addStringAlternative("FastMA_Method", "TriMAgen", "", "TriMAgen")
    strategy.parameters:addStringAlternative("FastMA_Method", "JSmooth", "", "JSmooth")

    strategy.parameters:addString("Type1", "Price Type", "", "C")
    strategy.parameters:addStringAlternative("Type1", "OPEN", "", "O")
    strategy.parameters:addStringAlternative("Type1", "HIGH", "", "H")
    strategy.parameters:addStringAlternative("Type1", "LOW", "", "L")
    strategy.parameters:addStringAlternative("Type1", "CLOSE", "", "C")
    strategy.parameters:addStringAlternative("Type1", "MEDIAN", "", "M")
    strategy.parameters:addStringAlternative("Type1", "TYPICAL", "", "T")
    strategy.parameters:addStringAlternative("Type1", "WEIGHTED", "", "W")

    strategy.parameters:addInteger("FastMA_Period", "FastMA_Period", "", 5)

    strategy.parameters:addString("SlowMA_Method", "SlowMA_Method", "", "EMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "Wilder", "", "Wilder")
    strategy.parameters:addStringAlternative("SlowMA_Method", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "SineWMA", "", "SineWMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "TriMA", "", "TriMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "LSMA", "", "LSMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "HMA", "", "HMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "ZeroLagEMA", "", "ZeroLagEMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "DEMA", "", "DEMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "T3", "", "T3")
    strategy.parameters:addStringAlternative("SlowMA_Method", "ITrend", "", "ITrend")
    strategy.parameters:addStringAlternative("SlowMA_Method", "Median", "", "Median")
    strategy.parameters:addStringAlternative("SlowMA_Method", "GeoMean", "", "GeoMean")
    strategy.parameters:addStringAlternative("SlowMA_Method", "REMA", "", "REMA")
    strategy.parameters:addStringAlternative("SlowMA_Method", "ILRS", "", "ILRS")
    strategy.parameters:addStringAlternative("SlowMA_Method", "IE/2", "", "IE/2")
    strategy.parameters:addStringAlternative("SlowMA_Method", "TriMAgen", "", "TriMAgen")
    strategy.parameters:addStringAlternative("SlowMA_Method", "JSmooth", "", "JSmooth")

    strategy.parameters:addInteger("SlowMA_Period", "SlowMA_Period", "", 8)

    strategy.parameters:addString("Type2", "Price Type", "", "C")
    strategy.parameters:addStringAlternative("Type2", "OPEN", "", "O")
    strategy.parameters:addStringAlternative("Type2", "HIGH", "", "H")
    strategy.parameters:addStringAlternative("Type2", "LOW", "", "L")
    strategy.parameters:addStringAlternative("Type2", "CLOSE", "", "C")
    strategy.parameters:addStringAlternative("Type2", "MEDIAN", "", "M")
    strategy.parameters:addStringAlternative("Type2", "TYPICAL", "", "T")
    strategy.parameters:addStringAlternative("Type2", "WEIGHTED", "", "W")

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

    strategy.parameters:addGroup("Notification")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", true)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- strategy instance initialization routine
-- Processes strategy parameters and creates output streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
-- Parameters block
local Parameters = {}

-- Notification
local PlaySound
local RecurrentSound
local SoundFile
local Email
local SendEmail

-- Trading parameters
local AllowTrade
local Account
local Amount
local BaseSize
local Limit
local Stop
local TrailingStop
local Offer
local CanClose
local ALLOWEDSIDE
local AllowMultiple
local SetStop
local SetLimit

local gSource  -- streams

local first

local AllowTicks
local Type1
local Type2
local P1, P1
local FastMA_Method
local FastMA_Period
local SlowMA_Method
local SlowMA_Period
local SlowMA
local FastMA

-- Routine
function Prepare(nameOnly)
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please download and install Averages Indicator!")

    FastMA_Method = instance.parameters.FastMA_Method
    FastMA_Period = instance.parameters.FastMA_Period
    SlowMA_Method = instance.parameters.SlowMA_Method
    SlowMA_Period = instance.parameters.SlowMA_Period
    Type1 = instance.parameters.Type1
    Type2 = instance.parameters.Type2

    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    ShowAlert = instance.parameters.ShowAlert

    PlaySound = instance.parameters.PlaySound
    if PlaySound then
        RecurrentSound = instance.parameters.RecurSound
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end
    assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified")

    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE

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
        Limit = instance.parameters.Limit
        Stop = instance.parameters.Stop
        TrailingStop = instance.parameters.TrailingStop
        SetStop = instance.parameters.SetStop
        SetLimit = instance.parameters.SetLimit
    end

    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    if Type1 == "O" then
        P1 = gSource.open
    elseif Type1 == "H" then
        P1 = gSource.high
    elseif Type1 == "L" then
        P1 = gSource.low
    elseif Type1 == "M" then
        P1 = gSource.median
    elseif Type1 == "T" then
        P1 = gSource.typical
    elseif Type1 == "W" then
        P1 = gSource.weighted
    else
        P1 = gSource.close
    end

    if Type2 == "O" then
        P2 = gSource.open
    elseif Type2 == "H" then
        P2 = gSource.high
    elseif Type2 == "L" then
        P2 = gSource.low
    elseif Type2 == "M" then
        P2 = gSource.median
    elseif Type2 == "T" then
        P2 = gSource.typical
    elseif Type2 == "W" then
        P2 = gSource.weighted
    else
        P2 = gSource.close
    end

    FastMA = core.indicators:create("AVERAGES", P1, FastMA_Method, FastMA_Period, false)
    SlowMA = core.indicators:create("AVERAGES", P2, SlowMA_Method, SlowMA_Period, false)

    first = math.max(FastMA.DATA:first(), SlowMA.DATA:first()) + 1
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

-- strategy calculation routine
function ExtUpdate(id, source, period)
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if period < first or id ~= 1 then
        return
    end

    FastMA:update(core.UpdateLast)
    SlowMA:update(core.UpdateLast)

    if core.crossesOver(FastMA.DATA, SlowMA.DATA, period) then
        if AllowTrade then
            if haveTrades("B") and not AllowMultiple then
                exit("S")
                Signal("Close Short")

                return
            end

            if ALLOWEDSIDE == "Sell" and haveTrades("S") then
                exit("S")
                Signal("Close Short")

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
    elseif core.crossesUnder(FastMA.DATA, SlowMA.DATA, period) then
        if AllowTrade then
            if haveTrades("S") and not AllowMultiple then
                exit("B")
                Signal("Close Long")

                return
            end

            if ALLOWEDSIDE == "Buy" and haveTrades("B") then
                exit("B")
                Signal("Close Long")

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
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

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
