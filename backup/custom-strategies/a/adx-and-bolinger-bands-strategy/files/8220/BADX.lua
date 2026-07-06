-- Id: 3155
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3438

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    strategy:name("Bollinger Bands and ADX strategy")
    strategy:description("Bollinger Bands and ADX strategy")
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("ADX indicator parameters")
    strategy.parameters:addInteger("ADX_Period", "Period ADX", "No description", 14)
    strategy.parameters:addDouble("ADX_Level", "Level ADX", "No description", 25)

    strategy.parameters:addGroup("Bollinger Bands parameters")
    strategy.parameters:addInteger("Period", "Period", "Period", 20)
    strategy.parameters:addDouble("Deviation", "Deviation", "Deviation", 2)
    strategy.parameters:addString("app_price", "app_price", "", "close")
    strategy.parameters:addStringAlternative("app_price", "close", "", "close")
    strategy.parameters:addStringAlternative("app_price", "open", "", "open")
    strategy.parameters:addStringAlternative("app_price", "high", "", "high")
    strategy.parameters:addStringAlternative("app_price", "low", "", "low")
    strategy.parameters:addStringAlternative("app_price", "median", "", "median")
    strategy.parameters:addStringAlternative("app_price", "typical", "", "typical")
    strategy.parameters:addStringAlternative("app_price", "weighted", "", "weighted")
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse")

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
local ADX = nil
local BB = nil

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
local Source_2
local Direction = nil
local app_price

--
--
--
function Prepare(nameOnly)
    ShowAlert = instance.parameters.ShowAlert
    app_price = instance.parameters.app_price
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
                "." .. instance.parameters.TF .. "," .. "ADX(" .. instance.parameters.ADX_Period .. "), "
    name = name .. "BB (" .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. "))"
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
    ADX = core.indicators:create("ADX", Source, instance.parameters.ADX_Period)
    if instance.parameters.app_price == "close" then
        Source_2 = Source.close
    elseif instance.parameters.app_price == "open" then
        Source_2 = Source.open
    elseif instance.parameters.app_price == "high" then
        Source_2 = Source.high
    elseif instance.parameters.app_price == "low" then
        Source_2 = Source.low
    elseif instance.parameters.app_price == "median" then
        Source_2 = Source.median
    elseif instance.parameters.app_price == "typical" then
        Source_2 = Source.typical
    else
        Source_2 = Source.weighted
    end
    BB = core.indicators:create("BB", Source_2, instance.parameters.Period, instance.parameters.Deviation, true)

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
    ADX:update(core.UpdateLast)
    BB:update(core.UpdateLast)

    -- Check that we have enough data
    if (ADX.DATA:first() > (period - 1)) then
        return
    end
    if (BB.DATA:first() > (period - 1)) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustB = false
    local MustS = false

    if ADX.DATA[period] < instance.parameters.ADX_Level and Source_2[period] < BB.BL[period] then
        if instance.parameters.TypeSignal == "direct" then
            if Direction ~= 1 then
                MustB = true
                Direction = 1
            end
        else
            if Direction ~= -1 then
                MustS = true
                Direction = -1
            end
        end
    end

    if ADX.DATA[period] < instance.parameters.ADX_Level and Source_2[period] > BB.TL[period] then
        if instance.parameters.TypeSignal == "direct" then
            if Direction ~= -1 then
                MustS = true
                Direction = -1
            end
        else
            if Direction ~= 1 then
                MustB = true
                Direction = 1
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
        if MustB == true then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("B")
            end
        end

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
