-- Id: 4737
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
    strategy:name("DSS Bressert Strategy")
    strategy:description(
        "Signals BUY / SELL when DSS Bressert Line crosses under/over the overbought/oversold levels, DSS Bressert Lines crosses  Each other."
    )
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Parameters")

    strategy.parameters:addInteger("Frame", "Stochastic Period", "Stochastic Period", 13)
    strategy.parameters:addInteger("EMAFrame", "Smooth Period", "Smooth Period", 8)
    strategy.parameters:addInteger("SignalFrame", "Signal Period", "Signal Period", 8)

    strategy.parameters:addString("L", "Signal Type", "", "K")
    strategy.parameters:addStringAlternative("L", "DSS Overbought/ Oversold", "", "K")
    strategy.parameters:addStringAlternative("L", "Signal Overbought/ Oversold", "", "D")
    strategy.parameters:addStringAlternative("L", "DSS / Signal Cross", "", "C")
    strategy.parameters:addStringAlternative("L", "DSS / Signal Cross in Overbought/ Oversold", "", "B")
    strategy.parameters:addStringAlternative("L", "DSS /  (OB/ OS) Cross after DSS / Signal Cross in OB/OS ", "", "T")

    strategy.parameters:addInteger("OS", "Oversold level", "", 20, 1, 100)
    strategy.parameters:addInteger("OB", "Overbought level", "", 80, 1, 100)

    strategy.parameters:addGroup("Time Frame Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

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
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)

    strategy.parameters:addGroup("Alert Parameters")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

    strategy.parameters:addGroup("Email Parameters")
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false)
    strategy.parameters:addString("Email", "Email address", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

local Email

local ShowAlert
local SoundFile
local RecurrentSound

local AllowMultiple
local SIDE

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
local Type
local name

local Frame
local EMAFrame
local SignalFrame

local indicatorsource = nil
local indicator = nil

local Line1, Line2
local OS, OB
local PARAMETARS

local OSC, OBC

function Prepare(onlyName)
    SIDE = instance.parameters.SIDE
    AllowMultiple = instance.parameters.AllowMultiple

    Frame = instance.parameters.Frame
    EMAFrame = instance.parameters.EMAFrame
    SignalFrame = instance.parameters.SignalFrame
    Type = instance.parameters.Type
    OS = instance.parameters.OS
    OB = instance.parameters.OB

    local SendEmail = instance.parameters.SendEmail
    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified")

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")
    assert(
        not (instance.parameters.PlaySound) or (instance.parameters.PlaySound and instance.parameters.SoundFile ~= ""),
        "Sound file must be chosen"
    )

    ShowAlert = instance.parameters.ShowAlert
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile
        RecurrentSound = instance.parameters.RecurrentSound
    else
        SoundFile = nil
        RecurrentSound = false
    end

    PARAMETARS =
        instance.parameters.Frame ..
        ", " .. instance.parameters.EMAFrame .. ", " .. instance.parameters.SignalFrame .. ", " .. OS .. "," .. OB

    name =
        profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Type .. ") " .. PARAMETARS .. ")"
    instance:name(name)

    AllowTrade = instance.parameters.AllowTrade

    if AllowTrade then
        Account = instance.parameters.Account
        Amount =
            instance.parameters.Amount *
            core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
        SetLimit = instance.parameters.SetLimit
        Limit = instance.parameters.Limit * instance.bid:pipSize()
        SetStop = instance.parameters.SetStop
        Stop = instance.parameters.Stop * instance.bid:pipSize()
        TrailingStop = instance.parameters.TrailingStop
        if (SetLimit or SetStop) and not (CanClose) then
            assert(false, "Stop and limit orders cannot be used by FIFO account")
        end
        name = name .. ",trade)"
    else
        name = name .. ",signal)"
    end

    instance:name(name)

    if onlyName then
        return
    end

    assert(core.indicators:findIndicator("DSS") ~= nil, "Please, download and install DSS.LUA indicator")

    indicatorsource = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    local iprofile = core.indicators:findIndicator("DSS")
    local iparams = iprofile:parameters()
    iparams:setInteger("Frame", instance.parameters:getInteger("Frame"))
    iparams:setInteger("EMAFrame", instance.parameters:getInteger("EMAFrame"))
    iparams:setInteger("SignalFrame", instance.parameters:getInteger("SignalFrame"))

    indicator = iprofile:createInstance(indicatorsource, iparams)

    Line1 = indicator:getStream(0) -- %K
    Line2 = indicator:getStream(1) -- %D

    OSC = false
    OBC = false
end

local loaded = false
function ExtUpdate(id, source, period)
    if id == 2 and period > 1 then
        indicator:update(core.UpdateLast)

        if period >= Line1:first() + 1 and period >= Line2:first() + 1 then
            if instance.parameters.L == "K" then
                if core.crossesOver(Line1, OS, period) then
                    TRADE("B")
                elseif core.crossesUnder(Line1, OB, period) then
                    TRADE("S")
                end
            end

            if instance.parameters.L == "D" then
                if core.crossesOver(Line2, OS, period) then
                    TRADE("B")
                elseif core.crossesUnder(Line2, OB, period) then
                    TRADE("S")
                end
            end

            if (instance.parameters.L == "C") then
                if core.crossesOver(Line1, Line2, period) then
                    TRADE("B")
                elseif core.crossesUnder(Line1, Line2, period) then
                    TRADE("S")
                end
            end

            if (instance.parameters.L == "B") then
                if core.crossesOver(Line1, Line2, period) and Line1[period - 1] < OS and Line2[period] < OS then
                    TRADE("B")
                elseif core.crossesUnder(Line1, Line2, period) and Line1[period - 1] > OB and Line2[period] > OB then
                    TRADE("S")
                end
            end

            if (instance.parameters.L == "T") then
                if core.crossesOver(Line1, OS, period - 1) then
                    OSC = false
                elseif core.crossesUnder(Line1, OB, period - 1) then
                    OBC = false
                end

                if core.crossesOver(Line1, Line2, period) and Line1[period - 1] < OS and Line2[period] < OS then
                    OSC = true
                elseif core.crossesUnder(Line1, Line2, period) and Line1[period - 1] > OB and Line2[period] > OB then
                    OBC = true
                end

                if core.crossesOver(Line1, OS, period) and OSC then
                    TRADE("B")
                elseif core.crossesUnder(Line1, OB, period) and OBC then
                    TRADE("S")
                end
            end
        end
    end
end

local NOTE

function TRADE(FLAG)
    local subject
    local text

    if haveTrades(FLAG) and not AllowMultiple then
        return
    end

    if FLAG == "S" and SIDE == "LONG" then
        return
    end

    if FLAG == "B" and SIDE == "SHORT" then
        return
    end

    if FLAG == "B" then
        NOTE = "Enter Long"
        exit("S")
        enter("B")

        if Email ~= nil then
            subject, text = Format("B")
            terminal:alertEmail(Email, subject, text)
        end
    else
        NOTE = "Enter Short"
        exit("B")
        enter("S")

        if Email ~= nil then
            subject, text = Format("S")
            terminal:alertEmail(Email, subject, text)
        end
    end
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], NOTE, instance.bid:date(NOW))
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound)
    end
end

-- enter into the specified direction
function enter(BuySell)
    if not (AllowTrade) then
        return
    end

    local enum, row, valuemap, success, msg

    -- check whether we have at least one trade on the specified account
    -- in the specified direction for the specified instrument
    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while count == 0 and row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and row.BS == BuySell then
            count = count + 1
        end
        row = enum:next()
    end

    -- do not enter if position in the
    -- specified direction already exists
    if count > 0 then
        return
    end

    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount
    valuemap.BuySell = BuySell
    valuemap.PegTypeStop = "M"

    if SetLimit then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit
        end
    end

    if SetStop then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateStop = instance.ask[NOW] - Stop
        else
            valuemap.RateStop = instance.bid[NOW] + Stop
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end

    success, msg = terminal:execute(100, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

-- exit from the specified direction
function exit(BuySell)
    if not (AllowTrade) then
        return
    end

    local enum, row, valuemap, success, msg

    -- check whether we have at least one trade on the specified account
    -- in the specified direction for the specified instrument
    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while count == 0 and row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and row.BS == BuySell then
            count = count + 1
        end
        row = enum:next()
    end

    if count > 0 then
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

        if not (success) then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[instance.bid:size() - 1],
                "Close order failed" .. msg,
                instance.bid:date(instance.bid:size() - 1)
            )
        end
    end
end

function Format(SIDE)
    local subject
    local text

    local ttime =
        core.dateToTable(
        core.host:execute(
            "convertTime",
            1,
            4,
            math.max(instance.bid:date(instance.bid:size() - 1), instance.ask:date(instance.ask:size() - 1))
        )
    )
    local dateDescr = "Time: " .. string.format("%02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min)

    if SIDE == "B" then
        subject =
            dateDescr ..
            ", Long position Warning " .. profile:id() .. ", " .. instance.bid:instrument() .. ", " .. PARAMETARS
        text =
            dateDescr ..
            ", Long position Warning " .. profile:id() .. ", " .. instance.bid:instrument() .. ", " .. PARAMETARS
    else
        subject =
            dateDescr ..
            " Short position Warning " .. profile:id() .. ", " .. instance.bid:instrument() .. ", " .. PARAMETARS
        text =
            dateDescr ..
            " Short position Warning " .. profile:id() .. ", " .. instance.bid:instrument() .. ", " .. PARAMETARS
    end

    return subject, text
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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
