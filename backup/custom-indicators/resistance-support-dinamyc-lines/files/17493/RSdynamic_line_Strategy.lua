-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6306
-- Id: 4934
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("RSdynamic line strategy")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert")
    strategy:description("RSdynamic line strategy")

    strategy.parameters:addGroup("Parameters")
    strategy.parameters:addInteger("Period", "Period", "", 14)
    strategy.parameters:addString("Price", "Price", "", "close")
    strategy.parameters:addStringAlternative("Price", "close", "", "close")
    strategy.parameters:addStringAlternative("Price", "open", "", "open")
    strategy.parameters:addStringAlternative("Price", "high", "", "high")
    strategy.parameters:addStringAlternative("Price", "low", "", "low")
    strategy.parameters:addStringAlternative("Price", "median", "", "median")
    strategy.parameters:addStringAlternative("Price", "typical", "", "typical")
    strategy.parameters:addStringAlternative("Price", "weighted", "", "weighted")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("BUYpair", "BUY pair", "", "1")
    strategy.parameters:addStringAlternative("BUYpair", "1", "", "1")
    strategy.parameters:addStringAlternative("BUYpair", "2", "", "2")
    strategy.parameters:addStringAlternative("BUYpair", "3", "", "3")
    strategy.parameters:addStringAlternative("BUYpair", "4", "", "4")
    strategy.parameters:addString("SELLpair", "SELL pair", "", "1")
    strategy.parameters:addStringAlternative("SELLpair", "1", "", "1")
    strategy.parameters:addStringAlternative("SELLpair", "2", "", "2")
    strategy.parameters:addStringAlternative("SELLpair", "3", "", "3")
    strategy.parameters:addStringAlternative("SELLpair", "4", "", "4")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addString("AllowDirection", "Allow direction for positions", "", "Both")
    strategy.parameters:addStringAlternative("AllowDirection", "Both", "", "Both")
    strategy.parameters:addStringAlternative("AllowDirection", "Long", "", "Long")
    strategy.parameters:addStringAlternative("AllowDirection", "Short", "", "Short")

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
local RSDL = nil

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
local AllowDirection

--
--
--
function Prepare()
    ShowAlert = instance.parameters.ShowAlert
    AllowDirection = instance.parameters.AllowDirection
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
            instance.bid:name() .. "." .. instance.parameters.TF .. "," .. "RSDL(" .. instance.parameters.Period .. "))"
    instance:name(name)

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

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, instance.parameters.Price)
    assert(core.indicators:findIndicator("RSDYNAMIC_LINE2") ~= nil, "RSDYNAMIC_LINE2" .. " indicator must be installed")
    RSDL = core.indicators:create("RSDYNAMIC_LINE2", Source, instance.parameters.Period)

    ExtSetupSignal(profile:id() .. ":", ShowAlert)
    ExtSetupSignalMail(name)
end

function haveTrades(BuySell)
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and (row.BS == BuySell or BuySell == nil) then
            return true
        end
        row = enum:next()
    end
    return false
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    RSDL:update(core.UpdateLast)

    -- Check that we have enough data
    if (RSDL.DATA:first() > (period - 1)) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustB = false
    local MustS = false

    if instance.parameters.BUYpair == "1" then
        if RSDL.Stream1[period - 1] < RSDL.Buff1[period - 1] and RSDL.Stream1[period] > RSDL.Buff1[period] then
            MustB = true
        end
    elseif instance.parameters.BUYpair == "2" then
        if RSDL.Stream2[period - 1] < RSDL.Buff2[period - 1] and RSDL.Stream2[period] > RSDL.Buff2[period] then
            MustB = true
        end
    elseif instance.parameters.BUYpair == "3" then
        if RSDL.Stream3[period - 1] < RSDL.Buff3[period - 1] and RSDL.Stream3[period] > RSDL.Buff3[period] then
            MustB = true
        end
    else
        if RSDL.Stream4[period - 1] < RSDL.Buff4[period - 1] and RSDL.Stream4[period] > RSDL.Buff4[period] then
            MustB = true
        end
    end

    if instance.parameters.SELLpair == "1" then
        if RSDL.Stream1[period - 1] > RSDL.Buff1[period - 1] and RSDL.Stream1[period] < RSDL.Buff1[period] then
            MustS = true
        end
    elseif instance.parameters.SELLpair == "2" then
        if RSDL.Stream2[period - 1] > RSDL.Buff2[period - 1] and RSDL.Stream2[period] < RSDL.Buff2[period] then
            MustS = true
        end
    elseif instance.parameters.SELLpair == "3" then
        if RSDL.Stream3[period - 1] > RSDL.Buff3[period - 1] and RSDL.Stream3[period] < RSDL.Buff3[period] then
            MustS = true
        end
    else
        if RSDL.Stream4[period - 1] > RSDL.Buff4[period - 1] and RSDL.Stream4[period] < RSDL.Buff4[period] then
            MustS = true
        end
    end

    if MustB and MustS then
        MustB = false
        MustS = true
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
                    if MustS then
                        if ShowAlert then
                            if instance.parameters.AllowDirection == "Long" then
                                ExtSignal(source, period, "Close BUY", SoundFile, Email, RecurrentSound)
                            else
                                ExtSignal(source, period, "Close BUY and SELL", SoundFile, Email, RecurrentSound)
                            end
                        end

                        if AllowTrade then
                            Close(row)
                            if instance.parameters.AllowDirection ~= "Long" then
                                Open("S")
                            end
                        end
                    end
                elseif row.BS == "S" then
                    if MustB then
                        if ShowAlert then
                            if instance.parameters.AllowDirection == "Short" then
                                ExtSignal(source, period, "Close SELL", SoundFile, Email, RecurrentSound)
                            else
                                ExtSignal(source, period, "Close SELL and BUY", SoundFile, Email, RecurrentSound)
                            end
                        end

                        if AllowTrade then
                            Close(row)
                            if instance.parameters.AllowDirection ~= "Short" then
                                Open("B")
                            end
                        end
                    end
                end
            end
        end
    else
        if MustB == true and instance.parameters.AllowDirection ~= "Short" then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("B")
            end
        end

        if MustS == true and instance.parameters.AllowDirection ~= "Long" then
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
    valuemap.QTXT = "1"
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
