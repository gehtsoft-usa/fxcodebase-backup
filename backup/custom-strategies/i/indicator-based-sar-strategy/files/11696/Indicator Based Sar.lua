-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4725
-- Id: 4120
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Strategy profile initialization routine
-- Defines Strategy profile properties and Strategy parameters
function Init()
    strategy:name("Indicator Based Sar")
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("Indicator Parameters")
    strategy.parameters:addString("Indicator", "Indicator", "", "")
    strategy.parameters:setFlag("Indicator", core.FLAG_INDICATOR)

    strategy.parameters:addInteger("Number", "Stream Number", "", 0, 0, 100)

    strategy.parameters:addDouble("Step", "Step", "The sensitivity of SAR.", 0.02, 0.001, 1)
    strategy.parameters:addDouble("Max", "Max", "The maximum value of Step.", 0.2, 0.001, 10)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple Positions in the same direction", "", true)

    strategy.parameters:addString("SIDE", "Allow Short/Long/Both Positions", "", "BOTH")
    strategy.parameters:addStringAlternative("SIDE", "Both", "", "BOTH")
    strategy.parameters:addStringAlternative("SIDE", "Short", "", "SHORT")
    strategy.parameters:addStringAlternative("SIDE", "Long", "", "LONG")

    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)

    strategy.parameters:addGroup("Notification")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", false)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
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
local SAR
local SubStream
local Parameters = {}

-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)
    SIDE = instance.parameters.SIDE
    AllowMultiple = instance.parameters.AllowMultiple

    local name
    name = profile:id() .. "(" .. instance.bid:instrument()

    local i

    Parameters["Indicator"] = instance.parameters.Indicator
    Parameters["Step"] = instance.parameters.Step
    Parameters["Max"] = instance.parameters.Max
    Parameters["Number"] = instance.parameters.Number

    name = name .. ", " .. instance.parameters.TF .. "(" .. ", " .. Parameters["Indicator"] .. ")"

    assert(instance.parameters.TF ~= "t1", "timeframe must not be tick")

    name = name .. ")"

    ShowAlert = instance.parameters.ShowAlert
    if ShowAlert then
        PlaySound = instance.parameters.PlaySound
        if PlaySound then
            RecurrentSound = instance.parameters.RecurSound
            SoundFile = instance.parameters.SoundFile
        else
            SoundFile = nil
        end
        assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified")

        SendEmail = instance.parameters.SendEmail
        if SendEmail then
            Email = instance.parameters.Email
        else
            Email = nil
        end
        assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")
    end

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

    --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)

    assert(core.indicators:findIndicator("TICK_SAR") ~= nil, "Please, download and install TICK_SAR.LUA indicator")
    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    local iprofile
    local iparams

    iprofile = core.indicators:findIndicator(Parameters["Indicator"])
    iparams = instance.parameters:getCustomParameters("Indicator")
    if iprofile:requiredSource() == core.Tick then
        indicator = iprofile:createInstance(gSource.close, iparams)
    else
        indicator = iprofile:createInstance(gSource, iparams)
    end

    local Count = indicator:getStreamCount()

    if Parameters["Number"] > Count then
        error("Indicator only have " .. Parameters["Number"] .. " Streams, Select Lower Stream Number")
        Parameters["Number"] = 0
    end

    SubStream = indicator:getStream(Parameters["Number"])

    SAR = core.indicators:create("TICK_SAR", SubStream, Parameters["Step"], Parameters["Max"])

    first = SAR.DATA:first()

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

    if id ~= 1 or period < first + 1 then
        return
    end

    indicator:update(core.UpdateLast)
    SAR:update(core.UpdateLast)

    if not (SAR.DN:hasData(period - 1)) and SAR.DN:hasData(period) then
        if haveTrades("B") and not AllowMultiple then
            if haveTrades("S") then
                exit("S")
                Signal("Close Short")
            end
            return
        end

        if SIDE == "SHORT" then
            if haveTrades("S") then
                exit("S")
                Signal("Close Short")
            end
            return
        end

        if AllowTrade then
            if haveTrades("S") then
                exit("S")
                Signal("Close Short")
            end
            enter("B")
            Signal("Open Long")
        elseif ShowAlert then
            Signal("Up Trend")
        end
    elseif not (SAR.UP:hasData(period - 1)) and SAR.UP:hasData(period) then
        if haveTrades("S") and not AllowMultiple then
            if haveTrades("B") then
                exit("B")
                Signal("Close Long")
            end
            return
        end

        if SIDE == "LONG" then
            if haveTrades("B") then
                exit("B")
                Signal("Close Long")
            end
            return
        end

        if AllowTrade then
            if haveTrades("B") then
                exit("B")
                Signal("Close Long")
            end
            enter("S")
            Signal("Open Short")
        elseif ShowAlert then
            Signal("Down Trend")
        end
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

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
