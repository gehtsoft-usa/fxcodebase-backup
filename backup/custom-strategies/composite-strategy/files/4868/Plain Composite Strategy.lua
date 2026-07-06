-- Id: 2468
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64347

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
    strategy:name("Composite Strategy")
    strategy:description("The strategy trades using zzzComposite indicator")

    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Strategy Parametars")
    strategy.parameters:addInteger("COMPOSITLEVEL", "Composite Signal Level", "", 0, 0, 21)

    strategy.parameters:addGroup("Composite Selector")

    local i
    local Label = {
        "RSI",
        "CCI",
        "EMA",
        "AROON",
        "DMI",
        "FRAMA",
        "SAR",
        "SLOPE_DIRECTION_LINE",
        "KRI",
        "TRIX",
        "MOMENTUM",
        "WMA",
        "KAMA",
        "VORTEX",
        "DEM",
        "FORECAST",
        "RLW",
        "TMACD",
        "SUPERTREND",
        "HA",
        "ROC"
    }

    for i = 1, 21, 1 do
        strategy.parameters:addGroup(Label[i] .. " Parameters")
        local Test = nil
        Test = core.indicators:findIndicator(Label[i])
        if Test == nil then
            strategy.parameters:addString(
                "Select" .. i,
                Label[i] .. " (Not Available)",
                "It is Available on FXCODEBASE.COM",
                "No"
            )
            strategy.parameters:addStringAlternative("Select" .. i, "No", "", "No")
        elseif Test ~= nil then
            strategy.parameters:addString("Select" .. i, Label[i], Label[i], "Yes")
            strategy.parameters:addStringAlternative("Select" .. i, "Yes", "", "Yes")
            strategy.parameters:addStringAlternative("Select" .. i, "No", "", "No")
        end
        strategy.parameters:addBoolean("Inverse" .. i, "Inverse Indicator", "", false)

        if i == 1 then
            strategy.parameters:addInteger("RSIFrame", "RSI Period", "RSI Period", 10, 2, 2000)
        elseif i == 2 then
            strategy.parameters:addInteger("CCIFrame", "CCI Period", "CCI Period", 10, 2, 2000)
        elseif i == 3 then
            strategy.parameters:addInteger("EMAFrame", "EMA Period", "EMA Period", 10, 2, 2000)
        elseif i == 4 then
            strategy.parameters:addInteger("AROONFrame", "AROON Period", "AROON Period", 10, 2, 2000)
        elseif i == 5 then
            strategy.parameters:addInteger("DMIFrame", "DMI Period", "DMI Period", 10, 2, 2000)
        elseif i == 6 then
            strategy.parameters:addInteger("FRAMAFrame", "FRAMA Period", "FRAMA Period", 10, 2, 2000)
        elseif i == 7 then
            strategy.parameters:addDouble("Step", "SAR Step", "The sensitivity of SAR.", 0.02, 0.001, 1)
            strategy.parameters:addDouble("Max", "SAR Max", "The maximum value of Step.", 0.2, 0.001, 10)
        elseif i == 8 then
            strategy.parameters:addInteger("SDLFrame", "SDL Period", "SDL Period", 10, 2, 2000)
        elseif i == 9 then
            strategy.parameters:addInteger("KRIFrame", "KRI Period", "KRI Period", 10, 2, 2000)
        elseif i == 10 then
            strategy.parameters:addInteger("TRIXFrame", "TRIX Period", "TRIX Period", 10, 2, 2000)
        elseif i == 11 then
            strategy.parameters:addInteger("MOMENTUMFrame", "MOMENTUM Period", "MOMENTUM Period", 10, 2, 2000)
        elseif i == 12 then
            strategy.parameters:addInteger("WMAFrame", "WMA Period", "WMA Period", 10, 2, 2000)
        elseif i == 13 then
            strategy.parameters:addInteger("KAMAFrame", "KAMA Period", "KAMA Period", 10, 2, 2000)
        elseif i == 14 then
            strategy.parameters:addInteger("VORTEXFrame", "VORTEX Period", "VORTEX Period", 10, 2, 2000)
        elseif i == 15 then
            strategy.parameters:addInteger("DEMARKERFrame", "DEMARKER Period", "DEMARKER Period", 10, 2, 2000)
        elseif i == 16 then
            strategy.parameters:addInteger("FORECASTFrame", "FORECAST Period", "FORECAST Period", 10, 2, 2000)
        elseif i == 17 then
            strategy.parameters:addInteger("RLWFrame", "RLW Period", "RLW Period", 10, 2, 2000)
        elseif i == 18 then
            strategy.parameters:addInteger("TMACDLongFrame", "TMACD Long Period", "TMACD Long Period", 10, 2, 2000)
            strategy.parameters:addInteger("TMACDShortFrame", "TMACD Short Period", "TMACD Short Period", 5, 2, 2000)
        elseif i == 19 then
            strategy.parameters:addInteger("SUPERTRENDFrame", "SUPERTREND Period", "SUPERTREND Period", 10, 2, 2000)
            strategy.parameters:addDouble("Multiplier", "Super Trend Multiplier", "No description", 1.5)
        elseif i == 20 then
        elseif i == 21 then
            strategy.parameters:addInteger("ROCFrame", "ROC Period", "ROC Period", 14, 2, 2000)
        end
    end

    strategy.parameters:addGroup("Parameters")

    strategy.parameters:addBoolean("Live", "Ignore Last period ", "Ignore Last period", true)

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addBoolean("INVERSE", "Inverse Trade", "", false)
    Trading_Parameters()
end

local first = true
local tsource = nil
local indicator = nil

local COMPOSITLEVEL
local INVERSE

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

function Prepare(nameOnly)
    INVERSE = instance.parameters.INVERSE
    COMPOSITLEVEL = instance.parameters.COMPOSITLEVEL

    local name
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end
    
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")
    assert(core.indicators:findIndicator("ZZZCOMPOSITE") ~= nil, "Please download and install ZZZCOMPOSITE!")

    tsource = ExtSubscribe(1, nil, instance.parameters.TF, true, "bar")

    local iprofile = core.indicators:findIndicator("ZZZCOMPOSITE")
    local iparams = iprofile:parameters()
    local i
    for i = 1, 21, 1 do
        iparams:setString("Select" .. i, instance.parameters:getString("Select" .. i))
        iparams:setBoolean("Inverse" .. i, instance.parameters:getBoolean("Inverse" .. i))
    end

    iparams:setInteger("RSIFrame", instance.parameters:getInteger("RSIFrame"))
    iparams:setInteger("CCIFrame", instance.parameters:getInteger("CCIFrame"))
    iparams:setInteger("EMAFrame", instance.parameters:getInteger("EMAFrame"))
    iparams:setInteger("AROONFrame", instance.parameters:getInteger("AROONFrame"))
    iparams:setInteger("DMIFrame", instance.parameters:getInteger("DMIFrame"))
    iparams:setInteger("FRAMAFrame", instance.parameters:getInteger("FRAMAFrame"))
    iparams:setDouble("Step", instance.parameters:getDouble("Step"))
    iparams:setDouble("Max", instance.parameters:getDouble("Max"))
    iparams:setInteger("SDLFrame", instance.parameters:getInteger("SDLFrame"))
    iparams:setInteger("KRIFrame", instance.parameters:getInteger("KRIFrame"))
    iparams:setInteger("TRIXFrame", instance.parameters:getInteger("TRIXFrame"))
    iparams:setInteger("MOMENTUMFrame", instance.parameters:getInteger("MOMENTUMFrame"))
    iparams:setInteger("WMAFrame", instance.parameters:getInteger("WMAFrame"))
    iparams:setInteger("KAMAFrame", instance.parameters:getInteger("KAMAFrame"))
    iparams:setInteger("VORTEXFrame", instance.parameters:getInteger("VORTEXFrame"))
    iparams:setInteger("DEMARKERFrame", instance.parameters:getInteger("DEMARKERFrame"))
    iparams:setInteger("FORECASTFrame", instance.parameters:getInteger("FORECASTFrame"))
    iparams:setInteger("RLWFrame", instance.parameters:getInteger("RLWFrame"))
    iparams:setInteger("TMACDLongFrame", instance.parameters:getInteger("TMACDLongFrame"))
    iparams:setInteger("TMACDShortFrame", instance.parameters:getInteger("TMACDShortFrame"))
    iparams:setInteger("SUPERTRENDFrame", instance.parameters:getInteger("SUPERTRENDFrame"))
    iparams:setDouble("Multiplier", instance.parameters:getDouble("Multiplier"))
    iparams:setInteger("ROCFrame", instance.parameters:getInteger("ROCFrame"))
    iparams:setBoolean("Live", instance.parameters:getBoolean("Live"))
    indicator = iprofile:createInstance(tsource, iparams)

    Initialization()
end

function ExtUpdate(id, source, period)
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if id == 1 and period > 1 then
        indicator:update(core.UpdateLast)

        if indicator.CI:hasData(period) then
            if core.crossesUnder(indicator.CI, 0 - COMPOSITLEVEL, period) then
                Flag = "Sell"

                if INVERSE then
                    BUY()
                else
                    SELL()
                end
            elseif core.crossesOver(indicator.CI, COMPOSITLEVEL, period) then
                Flag = "Buy"

                if INVERSE then
                    SELL()
                else
                    BUY()
                end
            end
        end
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
