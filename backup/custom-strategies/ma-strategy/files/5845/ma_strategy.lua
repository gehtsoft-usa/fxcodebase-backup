-- Id: 2195
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2602

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
    strategy:name("Sample moving average strategy")
    strategy:description("")
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Fast Moving Average")
    strategy.parameters:addString("FMA_M", "Method", "", "MVA")
    strategy.parameters:addStringAlternative("FMA_M", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("FMA_M", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("FMA_M", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("FMA_M", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("FMA_M", "PPMA*", "", "PPMA")
    strategy.parameters:addStringAlternative("FMA_M", "SMMA*", "", "SMMA")
    strategy.parameters:addStringAlternative("FMA_M", "Vidya (1995)*", "", "VIDYA")
    strategy.parameters:addStringAlternative("FMA_M", "Vidya (1992)*", "", "VIDYA92")
    strategy.parameters:addStringAlternative("FMA_M", "Wilders*", "", "WMA")
    strategy.parameters:addStringAlternative("FMA_M", "TEMA*", "", "TEMA1")
    strategy.parameters:addStringAlternative("FMA_M", "HMA", "", "HMA")
    strategy.parameters:addInteger("FMA_N", "Period", "", 5, 1, 300)
    strategy.parameters:addInteger("FMA_S", "Shift", "", 0, 0, 300)
    strategy.parameters:addString("FMA_P", "Price Type", "", "C")
    strategy.parameters:addStringAlternative("FMA_P", "Open", "", "O")
    strategy.parameters:addStringAlternative("FMA_P", "High", "", "H")
    strategy.parameters:addStringAlternative("FMA_P", "Low", "", "L")
    strategy.parameters:addStringAlternative("FMA_P", "Close", "", "C")
    strategy.parameters:addStringAlternative("FMA_P", "Median", "", "M")
    strategy.parameters:addStringAlternative("FMA_P", "Typical", "", "T")
    strategy.parameters:addStringAlternative("FMA_P", "Weighted", "", "W")

    strategy.parameters:addGroup("Slow  Moving Average")
    strategy.parameters:addString("SMA_M", "Method", "", "MVA")
    strategy.parameters:addStringAlternative("SMA_M", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("SMA_M", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("SMA_M", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("SMA_M", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("SMA_M", "PPMA*", "", "PPMA")
    strategy.parameters:addStringAlternative("SMA_M", "SMMA*", "", "SMMA")
    strategy.parameters:addStringAlternative("SMA_M", "Vidya (1995)*", "", "VIDYA")
    strategy.parameters:addStringAlternative("SMA_M", "Vidya (1992)*", "", "VIDYA92")
    strategy.parameters:addStringAlternative("SMA_M", "Wilders*", "", "WMA")
    strategy.parameters:addStringAlternative("SMA_M", "TEMA*", "", "TEMA1")
    strategy.parameters:addStringAlternative("SMA_M", "HMA", "", "HMA")
    strategy.parameters:addInteger("SMA_N", "Period", "", 20, 1, 300)
    strategy.parameters:addInteger("SMA_S", "Shift", "", 0, 0, 300)
    strategy.parameters:addString("SMA_P", "Price Type", "", "C")
    strategy.parameters:addStringAlternative("SMA_P", "Open", "", "O")
    strategy.parameters:addStringAlternative("SMA_P", "High", "", "H")
    strategy.parameters:addStringAlternative("SMA_P", "Low", "", "L")
    strategy.parameters:addStringAlternative("SMA_P", "Close", "", "C")
    strategy.parameters:addStringAlternative("SMA_P", "Median", "", "M")
    strategy.parameters:addStringAlternative("SMA_P", "Typical", "", "T")
    strategy.parameters:addStringAlternative("SMA_P", "Weighted", "", "W")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("TF", "Time Frame", "", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addString("TYPE", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("TYPE", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("TYPE", "Ask", "", "Ask")

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
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

-- check parameters and set advisor name
local name

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

-- global data block start

local priorbar = nil

-- price and MVA data (indicator, data and shift)
local SRC
local SMA, SMADATA, SMASHIFT
local FMA, FMADATA, FMASHIFT

local indicator = {}

function Prepare(onlyName)
    assert(
        not (instance.parameters.FMA_N > instance.parameters.SMA_N),
        "Fast MA Must have a shorter period from the slow MA."
    )

    assert(instance.parameters.TF ~= "t1", "timeframe must not be tick")

    SIDE = instance.parameters.side
    -- set the name
    name =
        profile:id() ..
        "(" ..
            instance.bid:instrument() ..
                "." ..
                    instance.parameters.TF ..
                        "." ..
                            instance.parameters.TYPE ..
                                "," ..
                                    instance.parameters.FMA_M ..
                                        "(" ..
                                            instance.parameters.FMA_P ..
                                                "," ..
                                                    instance.parameters.FMA_N ..
                                                        "," ..
                                                            instance.parameters.FMA_S ..
                                                                ")," ..
                                                                    instance.parameters.SMA_M ..
                                                                        "(" ..
                                                                            instance.parameters.SMA_P ..
                                                                                "," ..
                                                                                    instance.parameters.SMA_N ..
                                                                                        "," ..
                                                                                            instance.parameters.SMA_S ..
                                                                                                "))"
    instance:name(name)
    if onlyName then
        return
    end

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

    -- check methods
    assert(
        core.indicators:findIndicator(instance.parameters.SMA_M) ~= nil,
        "The chosen moving average method is not installed. Please use fxcodebase.com site to download the approriate moving average method."
    )
    assert(
        core.indicators:findIndicator(instance.parameters.FMA_M) ~= nil,
        "The chosen moving average method is not installed. Please use fxcodebase.com site to download the approriate moving average method."
    )

    SRC = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.TYPE == "Bid", "bar")
    FMA, FMADATA = CreateMA(1, instance.parameters.FMA_M, instance.parameters.FMA_N, instance.parameters.FMA_P, SRC)
    SMA, SMADATA = CreateMA(2, instance.parameters.SMA_M, instance.parameters.SMA_N, instance.parameters.SMA_P, SRC)
    FMASHIFT = instance.parameters.FMA_S
    SMASHIFT = instance.parameters.SMA_S
end

-- global data block end
function ExtUpdate(id, source, period)
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if id ~= 1 then
        return
    end

    -- return if the data is not loaded yet
    if SRC:size() < 2 then
        return
    end

    -- the index of the bar to be processed
    local p = SRC:size() - 2

    -- check if the same bar is still updating
    if priorbar ~= nil and SRC:serial(p) == priorbar then
        return
    end

    -- remember the last processed bar
    priorbar = SRC:serial(p)

    -- update moving average
    FMA:update(core.UpdateLast)
    SMA:update(core.UpdateLast)

    -- check whether here is enough data to check the
    -- signal conditions
    if p <= FMADATA:first() + FMASHIFT or p <= SMADATA:first() + SMASHIFT then
        return
    end

    if core.crossesOver(FMADATA, SMADATA, p - FMASHIFT, p - SMASHIFT) then
        if haveTrades("B") and not AllowMultiple then
            if AllowTrade then
                if haveTrades("S") then
                    exit("S")
                    Signal("Close Short")
                end
            elseif ShowAlert then
                Signal("Close Short")
            end

            return
        end

        if SIDE == "SHORT" then
            if AllowTrade then
                if haveTrades("S") then
                    exit("S")
                    Signal("Close Short")
                end
            elseif ShowAlert then
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
            Signal("Close Short")

            Signal("Open Long")
        end
    elseif core.crossesUnder(FMADATA, SMADATA, p - FMASHIFT, p - SMASHIFT) then
        if haveTrades("S") and not AllowMultiple then
            if AllowTrade then
                if haveTrades("B") then
                    exit("B")
                    Signal("Close Long")
                end
            elseif ShowAlert then
                Signal("Close Long")
            end
            return
        end

        if SIDE == "LONG" then
            if AllowTrade then
                if haveTrades("B") then
                    exit("B")
                    Signal("Close Long")
                end
            elseif ShowAlert then
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
            Signal("Close Long")
            Signal("Open Short")
        end
    end
end

-- creates moving average with the specified parameters for the specified price
function CreateMA(id, method, n, price, src)
    local p
    if price == "O" then
        p = src.open
    elseif price == "H" then
        p = src.high
    elseif price == "L" then
        p = src.low
    elseif price == "M" then
        p = src.median
    elseif price == "T" then
        p = src.typical
    elseif price == "W" then
        p = src.weighted
    elseif method == "PPMA" then
        p = src
    else
        p = src.close
    end

    assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
    indicator[id] = core.indicators:create(method, p, n)
    return indicator[id], indicator[id].DATA
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
