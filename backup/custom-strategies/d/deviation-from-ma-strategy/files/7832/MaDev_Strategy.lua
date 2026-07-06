-- Id: 3006
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3297

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    strategy:name("MaDev strategy")
    strategy:description("MaDev strategy")
    strategy:setTag(
        "NonOptimizableParameters",
        "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert,Account,CanTrade,Email,SendEmail"
    )
    strategy:setTag("Version", "2")

    strategy.parameters:addGroup("MaDev indicator parameters")
    strategy.parameters:addString("Method", "Method", "", "MVA")
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("Method", "Wilder", "", "Wilder")
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA")
    strategy.parameters:addStringAlternative("Method", "TriMA", "", "TriMA")
    strategy.parameters:addStringAlternative("Method", "LSMA", "", "LSMA")
    strategy.parameters:addStringAlternative("Method", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("Method", "HMA", "", "HMA")
    strategy.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA")
    strategy.parameters:addStringAlternative("Method", "DEMA", "", "DEMA")
    strategy.parameters:addStringAlternative("Method", "T3", "", "T3")
    strategy.parameters:addStringAlternative("Method", "ITrend", "", "ITrend")
    strategy.parameters:addStringAlternative("Method", "Median", "", "Median")
    strategy.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean")
    strategy.parameters:addStringAlternative("Method", "REMA", "", "REMA")
    strategy.parameters:addStringAlternative("Method", "ILRS", "", "ILRS")
    strategy.parameters:addStringAlternative("Method", "IE/2", "", "IE/2")
    strategy.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen")
    strategy.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth")

    strategy.parameters:addString("Price", "Price", "", "close")
    strategy.parameters:addStringAlternative("Price", "close", "", "close")
    strategy.parameters:addStringAlternative("Price", "open", "", "open")
    strategy.parameters:addStringAlternative("Price", "high", "", "high")
    strategy.parameters:addStringAlternative("Price", "low", "", "low")
    strategy.parameters:addStringAlternative("Price", "median", "", "median")
    strategy.parameters:addStringAlternative("Price", "typical", "", "typical")
    strategy.parameters:addStringAlternative("Price", "weighted", "", "weighted")

    strategy.parameters:addInteger("Period", "Period", "", 20)

    strategy.parameters:addInteger("Frame", "Number points for extremums", "", 3)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse")
    strategy.parameters:addInteger("MinValue", "Min value MaDev in pips", "", 20)

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)

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

-- Internal indicators
local MaDev = nil

-- Strategy parameters
local openLevel = 0
local closeLevel = 0
local confirmTrend

-- Trading parameters
local AllowTrade = nil
local Account = nil
local Amount = nil
local BaseSize = nil
local PipSize
local SetLimit = nil
local Limit = nil
local SetStop = nil
local Stop = nil
local TrailingStop = nil
local CanClose = nil
local Source
local Direction = nil

--
--
--
function Prepare(nameOnly)
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
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name =
        profile:id() ..
        "(" ..
            instance.bid:name() ..
                "." ..
                    instance.parameters.TF ..
                        "," ..
                            "MaDev(" ..
                                instance.parameters.Method ..
                                    ", " ..
                                        instance.parameters.Period ..
                                            ", " ..
                                                instance.parameters.Frame .. ", " .. instance.parameters.Price .. "))"
    instance:name(name)
    if nameOnly then
        return
    end

    AllowTrade = instance.parameters.AllowTrade
    if AllowTrade then
        Account = instance.parameters.Account
        Amount = instance.parameters.Amount
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
        PipSize = instance.bid:pipSize()
        SetLimit = instance.parameters.SetLimit
        Limit = instance.parameters.Limit
        SetStop = instance.parameters.SetStop
        Stop = instance.parameters.Stop
        TrailingStop = instance.parameters.TrailingStop
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")
    assert(core.indicators:findIndicator("MADEVOSC") ~= nil, "MADEVOSC indicator must be installed");
    MaDev =
        core.indicators:create(
        "MADEVOSC",
        Source,
        instance.parameters.Method,
        instance.parameters.Price,
        instance.parameters.Period,
        instance.parameters.Frame
    )
    Direction = nil

    ExtSetupSignal(profile:id() .. ":", ShowAlert)
    ExtSetupSignalMail(name)
end

function haveTrades(BuySell)
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and (row.BS == BuySell or BuySell == nil) then
            return true;
        end
        row = enum:next()
    end
    return false
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    MaDev:update(core.UpdateLast)

    -- Check that we have enough data
    if (MaDev.BuffNe:first() > (period - 1)) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustB = false
    local MustS = false
    local Shift = math.floor((instance.parameters.Frame - 1) / 2)
    if period > math.max(instance.parameters.Period, instance.parameters.Frame) then
        if math.abs(MaDev.BuffNe[period - Shift - 1]) >= instance.parameters.MinValue * source:pipSize() then
            if
                (MaDev.BuffUp[period - Shift - 1] == MaDev.BuffNe[period - Shift - 1] and
                    MaDev.BuffDn[period - Shift - 1] ~= MaDev.BuffNe[period - Shift - 1] and
                    instance.parameters.TypeSignal == "direct") or
                    (MaDev.BuffDn[period - Shift - 1] == MaDev.BuffNe[period - Shift - 1] and
                        MaDev.BuffUp[period - Shift - 1] ~= MaDev.BuffNe[period - Shift - 1] and
                        instance.parameters.TypeSignal == "reverse")
             then
                if Direction ~= -1 then
                    MustS = true
                    Direction = -1
                end
            end
            if
                (MaDev.BuffDn[period - Shift - 1] == MaDev.BuffNe[period - Shift - 1] and
                    MaDev.BuffUp[period - Shift - 1] ~= MaDev.BuffNe[period - Shift - 1] and
                    instance.parameters.TypeSignal == "direct") or
                    (MaDev.BuffUp[period - Shift - 1] == MaDev.BuffNe[period - Shift - 1] and
                        MaDev.BuffDn[period - Shift - 1] ~= MaDev.BuffNe[period - Shift - 1] and
                        instance.parameters.TypeSignal == "reverse")
             then
                if Direction ~= 1 then
                    MustB = true
                    Direction = 1
                end
            end
        end
    end

    if (haveTrades()) then
        local enum = trades:enumerator()
        while true do
            local row = enum:next()
            if row == nil then
                break
            end

            if row.AccountID == Account and row.OfferID == Offer then
                -- Close position if we have corresponding closing conditions.
                if row.BS == "B" then
                    if MustS == true then
                        if ShowAlert then
                            ExtSignal(source, period, "Close BUY and SELL", SoundFile, Email, RecurrentSound)
                        end

                        if AllowTrade then
                            Close(row)
                            Open("S")
                        end
                    end
                elseif row.BS == "S" then
                    if MustB == true then
                        if ShowAlert then
                            ExtSignal(source, period, "Close SELL and BUY", SoundFile, Email, RecurrentSound)
                        end

                        if AllowTrade then
                            Close(row)
                            Open("B")
                        end
                    end
                end
            end
        end
    else
        -- Open BUY (Long) position if MACD line crosses over SIGNAL line
        -- in negative area below openLevel. Also check MA trend if
        -- confirmTrend flag is 'true'
        if MustB == true then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("B")
            end
        end

        -- Open SELL (Short) position if MACD line crosses under SIGNAL line
        -- in positive area above openLevel. Also check MA trend if
        -- confirmTrend flag is 'true'
        if MustS == true then
            if ShowAlert then
                ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("S")
            end
        end
    end
end

-- The strategy instance finalization.
function ReleaseInstance()
end

-- The method enters to the market
function Open(side)
    local valuemap

    valuemap = core.valuemap()
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.CustomID = CID
    valuemap.BuySell = side
    if SetStop and CanClose then
        valuemap.PegTypeStop = "O"
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop
        else
            valuemap.PegPriceOffsetPipsStop = Stop
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end
    if SetLimit and CanClose then
        valuemap.PegTypeLimit = "O"
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit
        end
    end
    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)

    -- FIFO Account, in that case we have to open Net Limit and Stop Orders
    if not (CanClose) then
        if SetStop then
            valuemap = core.valuemap()
            valuemap.OrderType = "SE"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "y"
            if side == "B" then
                valuemap.BuySell = "S"
                rate = instance.ask[NOW] - Stop * PipSize
                valuemap.Rate = rate
            elseif side == "S" then
                valuemap.BuySell = "B"
                rate = instance.bid[NOW] + Stop * PipSize
                valuemap.Rate = rate
            end
            if TrailingStop then
                valuemap.TrailUpdatePips = 1
            end
            success, msg = terminal:execute(200, valuemap)
            --core.host:trace('Set stop @ ' .. rate);
            assert(success, msg)
        end
        if SetLimit then
            valuemap = core.valuemap()
            valuemap.OrderType = "LE"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "y"
            if side == "B" then
                valuemap.BuySell = "S"
                rate = instance.ask[NOW] + Limit * PipSize
                valuemap.Rate = rate
            elseif side == "S" then
                valuemap.BuySell = "B"
                rate = instance.bid[NOW] - Limit * PipSize
                valuemap.Rate = rate
            end
            success, msg = terminal:execute(200, valuemap)
            --core.host:trace('Set limit @ ' .. rate);
            assert(success, msg)
        end
    end
end

-- Closes specific position
function Close(trade)
    local valuemap
    valuemap = core.valuemap()

    if CanClose then
        -- non-FIFO account, create a close market order
        valuemap.OrderType = "CM"
        valuemap.TradeID = trade.TradeID
    else
        -- FIFO account, create an opposite market order
        valuemap.OrderType = "OM"
    end

    valuemap.OfferID = trade.OfferID
    valuemap.AcctID = trade.AccountID
    valuemap.Quantity = trade.Lot
    valuemap.CustomID = trade.QTXT
    if trade.BS == "B" then
        valuemap.BuySell = "S"
    else
        valuemap.BuySell = "B"
    end
    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)
end

function AsyncOperationFinished(cookie, successful, message)
    if not successful then
        core.host:trace("Error: " .. message)
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
