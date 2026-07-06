-- Id: 5402
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=10442

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
    strategy:name("Fractals&ATR strategy")
    strategy:description("Fractals&ATR strategy")
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Parameters")
    strategy.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 3, 99)
    strategy.parameters:addInteger("Period", "ATR Period", "", 25)
    strategy.parameters:addDouble("Mult", "ATR multiplier", "", 2)
    strategy.parameters:addDouble("TP_Mult", "Take profit multiplier", "", 2)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
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
local ATR = nil
local Frame
local Frame2
local SL_open, TP_open

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
local SetStop = nil
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
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF .. "))"
    instance:name(name)
    if nameOnly then
        return;
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
        SetStop = instance.parameters.SetStop
        TrailingStop = instance.parameters.TrailingStop
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")
    ATR = core.indicators:create("ATR", Source, instance.parameters.Period)
    Frame = instance.parameters.Frame
    Frame2 = math.floor((Frame - 1) / 2)

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
    ATR:update(core.UpdateLast)

    -- Check that we have enough data
    if (ATR.DATA:first() > (period - Frame - 1)) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local MustOpenB = false
    local MustOpenS = false

    local UP, DN = IsFractal(period)
    local Dir = 0
    if UP then
        Dir = 1
    elseif DN then
        Dir = -1
    end
    if Dir ~= 0 then
        local PrevFrac, LastFrac = TwoLastFractals(period - 1, -Dir)
        if PrevFrac ~= nil then
            local Range
            if LastFrac > 0 then
                Range = math.abs(source.high[LastFrac] - source.low[-PrevFrac])
            else
                Range = math.abs(source.high[PrevFrac] - source.low[-LastFrac])
            end
            if Range < ATR.DATA[period] * instance.parameters.Mult then
                if LastFrac > 0 then
                    if instance.parameters.TypeSignal == "direct" then
                        MustOpenB = true
                        SL_open = source.low[-PrevFrac] - source.close[period]
                        TP_open = ATR.DATA[period] * instance.parameters.TP_Mult
                    else
                        MustOpenS = true
                        TP_open = source.low[-PrevFrac] - source.close[period]
                        SL_open = ATR.DATA[period] * instance.parameters.TP_Mult
                    end
                else
                    if instance.parameters.TypeSignal == "direct" then
                        MustOpenS = true
                        SL_open = source.high[PrevFrac] - source.close[period]
                        TP_open = -ATR.DATA[period] * instance.parameters.TP_Mult
                    else
                        MustOpenB = true
                        TP_open = source.high[PrevFrac] - source.close[period]
                        SL_open = -ATR.DATA[period] * instance.parameters.TP_Mult
                    end
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
        --        if side == "B" then
        --            valuemap.PegPriceOffsetPipsStop = -Stop;
        --        else
        valuemap.PegPriceOffsetPipsStop = SL_open
        --        end
        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end
    if SetLimit and CanClose then
        valuemap.PegTypeLimit = "O"
        --        if side == "B" then
        valuemap.PegPriceOffsetPipsLimit = TP_open
    --        else
    --            valuemap.PegPriceOffsetPipsLimit = -Limit;
    --        end
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
                rate = instance.ask[NOW] + SL_open
                valuemap.Rate = rate
            elseif side == "S" then
                valuemap.BuySell = "B"
                rate = instance.bid[NOW] + SL_open
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
                rate = instance.ask[NOW] + TP_open
                valuemap.Rate = rate
            elseif side == "S" then
                valuemap.BuySell = "B"
                rate = instance.bid[NOW] + TP_open
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

function TwoLastFractals(period, firstFrac)
    local LastFrac = nil
    local PrevFrac = nil
    local period_ = period
    while period_ > Source:first() + Frame and PrevFrac == nil do
        local UP, DN = IsFractal(period_)
        if UP then
            if LastFrac == nil and firstFrac == 1 then
                LastFrac = period_
            end
            if LastFrac ~= nil and PrevFrac == nil and firstFrac == -1 then
                PrevFrac = period_
            end
        end
        if DN then
            if LastFrac == nil and firstFrac == -1 then
                LastFrac = -period_
            end
            if LastFrac ~= nil and PrevFrac == nil and firstFrac == 1 then
                PrevFrac = -period_
            end
        end
        period_ = period_ - 1
    end
    return PrevFrac, LastFrac
end

function IsFractal(period)
    local i
    local UP = true
    local DN = true
    for i = 1, Frame2, 1 do
        if
            Source.high[period - i - Frame2] >= Source.high[period - Frame2] or
                Source.high[period + i - Frame2] >= Source.high[period - Frame2]
         then
            UP = false
        end
        if
            Source.low[period - i - Frame2] <= Source.low[period - Frame2] or
                Source.low[period + i - Frame2] <= Source.low[period - Frame2]
         then
            DN = false
        end
    end
    return UP, DN
end

function AsyncOperationFinished(cookie, successful, message)
    if not successful then
        core.host:trace("Error: " .. message)
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
