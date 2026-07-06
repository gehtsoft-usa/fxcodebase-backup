-- Id: 5501
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=10972

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
    strategy:name("BB_EMA_ATR strategy")
    strategy:description("BB_EMA_ATR strategy")
    strategy:setTag("Version", "1.1")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Parameters")
    strategy.parameters:addInteger("BB_Period", "Period of BB", "", 20)
    strategy.parameters:addDouble("BB_Deviation", "Deviation of BB", "", 2)
    strategy.parameters:addInteger("EMA_Period", "Period of EMA", "", 34)
    strategy.parameters:addInteger("ATR_Period", "Period of ATR", "", 14)
    strategy.parameters:addDouble("ATR_Mult", "Multiplier of ATR", "", 2)
    strategy.parameters:addString("Price", "Price", "", "close")
    strategy.parameters:addStringAlternative("Price", "close", "", "close")
    strategy.parameters:addStringAlternative("Price", "open", "", "open")
    strategy.parameters:addStringAlternative("Price", "high", "", "high")
    strategy.parameters:addStringAlternative("Price", "low", "", "low")
    strategy.parameters:addStringAlternative("Price", "median", "", "median")
    strategy.parameters:addStringAlternative("Price", "typical", "", "typical")
    strategy.parameters:addStringAlternative("Price", "weighted", "", "weighted")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

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
local BB = nil
local EMA = nil
local ATR = nil

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
function Prepare(nameOnly)
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
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF .. "," .. ")"
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
    ATR = core.indicators:create("ATR", Source, instance.parameters.ATR_Period)
    Price = instance.parameters.Price
    if Price == "close" then
        BB = core.indicators:create("BB", Source.close, instance.parameters.BB_Period, instance.parameters.BB_Deviation)
        EMA = core.indicators:create("EMA", Source.close, instance.parameters.EMA_Period)
    elseif Price == "open" then
        BB = core.indicators:create("BB", Source.open, instance.parameters.BB_Period, instance.parameters.BB_Deviation)
        EMA = core.indicators:create("EMA", Source.open, instance.parameters.EMA_Period)
    elseif Price == "high" then
        BB = core.indicators:create("BB", Source.high, instance.parameters.BB_Period, instance.parameters.BB_Deviation)
        EMA = core.indicators:create("EMA", Source.high, instance.parameters.EMA_Period)
    elseif Price == "low" then
        BB = core.indicators:create("BB", Source.low, instance.parameters.BB_Period, instance.parameters.BB_Deviation)
        EMA = core.indicators:create("EMA", Source.low, instance.parameters.EMA_Period)
    elseif Price == "typical" then
        BB =
            core.indicators:create(
            "BB",
            Source.typical,
            instance.parameters.BB_Period,
            instance.parameters.BB_Deviation
        )
        EMA = core.indicators:create("EMA", Source.typical, instance.parameters.EMA_Period)
    elseif Price == "median" then
        BB =
            core.indicators:create("BB", Source.median, instance.parameters.BB_Period, instance.parameters.BB_Deviation)
        EMA = core.indicators:create("EMA", Source.median, instance.parameters.EMA_Period)
    else
        BB =
            core.indicators:create(
            "BB",
            Source.weighted,
            instance.parameters.BB_Period,
            instance.parameters.BB_Deviation
        )
        EMA = core.indicators:create("EMA", Source.weighted, instance.parameters.EMA_Period)
    end

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
    BB:update(core.UpdateLast)
    EMA:update(core.UpdateLast)
    ATR:update(core.UpdateLast)

    -- Check that we have enough data
    if (BB.DATA:first() > (period - 1)) then
        return
    end
    if (EMA.DATA:first() > (period - 1)) then
        return
    end
    if (ATR.DATA:first() > (period - 1)) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustOpenB = false
    local MustOpenS = false
    local MustCloseB = false
    local MustCloseS = false

    if
        BB.AL[period] > EMA.DATA[period] and
            (BB.TL[period] - BB.AL[period]) > ATR.DATA[period] * instance.parameters.ATR_Mult and
            Source.high[period - 1] >= BB.AL[period - 1] and
            Source.low[period] <= BB.AL[period]
     then
        if instance.parameters.TypeSignal == "direct" then
            MustOpenB = true
        else
            MustOpenS = true
        end
    end

    if
        BB.AL[period] < EMA.DATA[period] and
            (BB.AL[period] - BB.BL[period]) > ATR.DATA[period] * instance.parameters.ATR_Mult and
            Source.low[period - 1] <= BB.AL[period - 1] and
            Source.high[period] >= BB.AL[period]
     then
        if instance.parameters.TypeSignal == "direct" then
            MustOpenS = true
        else
            MustOpenB = true
        end
    end

    if Source.high[period] > BB.TL[period] or Source.low[period] < EMA.DATA[period] then
        if instance.parameters.TypeSignal == "direct" then
            MustCloseB = true
        else
            MustCloseS = true
        end
    end

    if Source.low[period] < BB.BL[period] or Source.high[period] > EMA.DATA[period] then
        if instance.parameters.TypeSignal == "direct" then
            MustCloseS = true
        else
            MustCloseB = true
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
                    if MustOpenS then
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
                    elseif MustCloseB then
                        if ShowAlert then
                            ExtSignal(source, period, "Close BUY", SoundFile, Email, RecurrentSound)
                        end

                        if AllowTrade then
                            Close(row)
                        end
                    end
                elseif row.BS == "S" then
                    if MustOpenB then
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
                    elseif MustCloseS then
                        if ShowAlert then
                            ExtSignal(source, period, "Close SELL", SoundFile, Email, RecurrentSound)
                        end

                        if AllowTrade then
                            Close(row)
                        end
                    end
                end
            end
        end
    else
        if MustOpenB == true and instance.parameters.AllowDirection ~= "Short" then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                Open("B")
            end
        end

        if MustOpenS == true and instance.parameters.AllowDirection ~= "Long" then
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
