-- Id: 7046
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=21108

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
    strategy:name("Candle pattern strategy")
    strategy:description("Candle pattern strategy")
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Parameters")
    strategy.parameters:addString("Candle1", "Candle 1", "", "U")
    strategy.parameters:addStringAlternative("Candle1", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle1", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle1", "N", "", "N")
    strategy.parameters:addString("Candle2", "Candle 2", "", "U")
    strategy.parameters:addStringAlternative("Candle2", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle2", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle2", "N", "", "N")
    strategy.parameters:addString("Candle3", "Candle 3", "", "U")
    strategy.parameters:addStringAlternative("Candle3", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle3", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle3", "N", "", "N")
    strategy.parameters:addString("Candle4", "Candle 4", "", "U")
    strategy.parameters:addStringAlternative("Candle4", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle4", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle4", "N", "", "N")
    strategy.parameters:addString("Candle5", "Candle 5", "", "U")
    strategy.parameters:addStringAlternative("Candle5", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle5", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle5", "N", "", "N")
    strategy.parameters:addString("Candle6", "Candle 6", "", "U")
    strategy.parameters:addStringAlternative("Candle6", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle6", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle6", "N", "", "N")
    strategy.parameters:addString("Candle7", "Candle 7", "", "U")
    strategy.parameters:addStringAlternative("Candle7", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle7", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle7", "N", "", "N")
    strategy.parameters:addString("Candle8", "Candle 8", "", "U")
    strategy.parameters:addStringAlternative("Candle8", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle8", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle8", "N", "", "N")
    strategy.parameters:addString("Candle9", "Candle 9", "", "U")
    strategy.parameters:addStringAlternative("Candle9", "U", "", "U")
    strategy.parameters:addStringAlternative("Candle9", "D", "", "D")
    strategy.parameters:addStringAlternative("Candle9", "N", "", "N")
    strategy.parameters:addString("Direction", "Direction for positions", "", "BUY")
    strategy.parameters:addStringAlternative("Direction", "BUY", "", "BUY")
    strategy.parameters:addStringAlternative("Direction", "SELL", "", "SELL")
    strategy.parameters:addBoolean("UseReversePattern", "Use reverse pattern", "", false)
    strategy.parameters:addBoolean("OnlyOneOrder", "Only one order", "", false)
    strategy.parameters:addBoolean("CloseOppositeOrders", "Close opposite orders", "", true)

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

local LengthPattern
local Pattern

--
--
--

function DirectPattern(source, period)
    local i
    local Fl = true
    local s
    for i = 1, LengthPattern, 1 do
        s = string.sub(Pattern, LengthPattern - i + 1, LengthPattern - i + 1)
        if string.upper(s) == "U" and source.close[period - i + 1] <= source.open[period - i + 1] then
            Fl = false
        end
        if string.upper(s) == "D" and source.close[period - i + 1] >= source.open[period - i + 1] then
            Fl = false
        end
    end
    return Fl
end

function ReversePattern(source, period)
    local i
    local Fl = true
    local s
    for i = 1, LengthPattern, 1 do
        s = string.sub(Pattern, LengthPattern - i + 1, LengthPattern - i + 1)
        if string.upper(s) == "U" and source.close[period - i + 1] >= source.open[period - i + 1] then
            Fl = false
        end
        if string.upper(s) == "D" and source.close[period - i + 1] <= source.open[period - i + 1] then
            Fl = false
        end
    end
    return Fl
end

function Prepare(nameOnly)
    ShowAlert = instance.parameters.ShowAlert
    Pattern =
        instance.parameters.Candle1 ..
        instance.parameters.Candle2 ..
            instance.parameters.Candle3 ..
                instance.parameters.Candle4 ..
                    instance.parameters.Candle5 ..
                        instance.parameters.Candle6 ..
                            instance.parameters.Candle7 .. instance.parameters.Candle8 .. instance.parameters.Candle9
    LengthPattern = string.len(Pattern)
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
        Limit = instance.parameters.Limit
        SetStop = instance.parameters.SetStop
        Stop = instance.parameters.Stop
        TrailingStop = instance.parameters.TrailingStop
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")

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

function OpenOrder(source, period, Dir)
    local D
    if (instance.parameters.Direction == "BUY") then
        D = 0
    else
        D = 1
    end
    if Dir == 1 then
        D = 1 - D
    end
    local MustCloseB = false
    local MustCloseS = false
    if instance.parameters.CloseOppositeOrders then
        if D == 0 then
            MustCloseS = true
        elseif D == 1 then
            MustCloseB = true
        end
    end

    local MustOpenB = false
    local MustOpenS = false
    if D == 0 then
        MustOpenB = true
    elseif D == 1 then
        MustOpenS = true
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    if (haveTrades()) then
        local enum = trades:enumerator()
        while true do
            local row = enum:next()
            if row == nil then
                break
            end

            if row.AccountID == Account and row.OfferID == Offer then
                if row.BS == "B" then
                    if instance.parameters.OnlyOneOrder then
                        MustOpenB = false
                    end
                    if MustCloseB then
                        if ShowAlert then
                            ExtSignal(source, period, "Close BUY", SoundFile, Email, RecurrentSound)
                        end

                        if AllowTrade then
                            Close(row)
                        end
                    end
                elseif row.BS == "S" then
                    if instance.parameters.OnlyOneOrder then
                        MustOpenS = false
                    end
                    if MustCloseS then
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
    end

    if MustOpenB then
        if ShowAlert then
            ExtSignal(source, period, "Open BUY", SoundFile, Email, RecurrentSound)
        end
        if AllowTrade then
            Open("B")
        end
    end

    if MustOpenS then
        if ShowAlert then
            ExtSignal(source, period, "Open SELL", SoundFile, Email, RecurrentSound)
        end
        if AllowTrade then
            Open("S")
        end
    end
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    -- Check that we have enough data
    if (source:first() > (period - LengthPattern)) then
        return
    end

    if DirectPattern(source, period) then
        OpenOrder(source, period, 0)
    end
    if instance.parameters.UseReversePattern then
        if ReversePattern(source, period) then
            OpenOrder(source, period, 1)
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
