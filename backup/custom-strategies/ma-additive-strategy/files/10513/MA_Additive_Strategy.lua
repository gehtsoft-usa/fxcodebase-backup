-- Id: 3875
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4190

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

function Init() --The strategy profile initialization
    strategy:name("MA additive strategy")
    strategy:description("MA additive strategy")
    strategy:setTag(
        "NonOptimizableParameters",
        "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert,Account,CanTrade,Email,SendEmail"
    )
    strategy:setTag("Version", "1.1")

    strategy.parameters:addGroup("EMA indicator parameters")
    strategy.parameters:addInteger("Period_1", "First period", "No description", 5)
    strategy.parameters:addString("Method", "Method", "", "Add")
    strategy.parameters:addStringAlternative("Method", "Add", "", "Add")
    strategy.parameters:addStringAlternative("Method", "Mult", "", "Mult")

    strategy.parameters:addInteger("K", "K", "No description", 2)
    strategy.parameters:addInteger("N", "Count of MA", "No description", 5)

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
local Inds = {}

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
local CanClose = nil
local IndSource

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
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF .. "))"
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
    end

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")

    Price = instance.parameters.Price
    if Price == "close" then
        IndSource = Source.close
        RSI = core.indicators:create("RSI", Source.close, instance.parameters.N)
    elseif Price == "open" then
        IndSource = Source.open
    elseif Price == "high" then
        IndSource = Source.high
    elseif Price == "low" then
        IndSource = Source.low
    elseif Price == "typical" then
        IndSource = Source.typical
    elseif Price == "median" then
        IndSource = Source.median
    else
        IndSource = Source.weighted
    end

    Period1 = instance.parameters.Period_1
    K = instance.parameters.K
    N = instance.parameters.N
    Method = instance.parameters.Method
    local Period = Period1
    for i = 1, N, 1 do
        Ind = core.indicators:create("EMA", IndSource, Period)
        Inds[i] = Ind
        if Method == "Mult" then
            Period = Period * K
        else
            Period = Period + K
        end
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

function CountOrders()
    local trades = core.host:findTable("trades")
    local CountB = 0
    local CountS = 0
    if (haveTrades()) then
        local enum = trades:enumerator()
        while true do
            local row = enum:next()
            if row == nil then
                break
            end
            if row.AccountID == Account and row.OfferID == Offer then
                if row.BS == "B" then
                    CountB = CountB + 1
                elseif row.BS == "S" then
                    CountS = CountS + 1
                end
            end
        end
    end

    return CountB, CountS
end

function ChangeOrders(CloseO, OpenO)
    if CloseO ~= 0 then
        local CloseO_ = CloseO
        local trades = core.host:findTable("trades")
        local enum = trades:enumerator()
        while true do
            local row = enum:next()
            if row == nil then
                break
            end
            if row.AccountID == Account and row.OfferID == Offer then
                if row.BS == "B" and CloseO_ > 0 then
                    Close(row)
                    CloseO_ = CloseO_ - 1
                elseif row.BS == "S" and CloseO_ < 0 then
                    Close(row)
                    CloseO_ = CloseO_ + 1
                end
            end
        end
    end

    local i
    if OpenO > 0 then
        for i = 1, OpenO, 1 do
            Open("B")
        end
    end
    if OpenO < 0 then
        for i = 1, -OpenO, 1 do
            Open("S")
        end
    end
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    Inds[1]:update(core.UpdateLast)
    local Res = 0
    local Res2 = 0
    for i = 2, N, 1 do
        Inds[i]:update(core.UpdateLast)
        if Inds[i].DATA[period] < Inds[i - 1].DATA[period] then
            Res = Res + 1
        else
            Res = Res - 1
        end
        if Inds[i].DATA[period - 1] < Inds[i - 1].DATA[period - 1] then
            Res2 = Res2 + 1
        else
            Res2 = Res2 - 1
        end
    end
    Res = Res / 2
    Res2 = Res2 / 2
    if math.fmod(N, 2) == 0 then
        if Res > 0 then
            Res = Res - 0.5
        else
            Res = Res + 0.5
        end
        if Res2 > 0 then
            Res2 = Res2 - 0.5
        else
            Res2 = Res2 + 0.5
        end
    end

    if instance.parameters.TypeSignal == "reverse" then
        Res = -Res
        Res2 = -Res2
    end

    local OrdersB, OrdersS = CountOrders()
    if Res2 == OrdersB - OrdersS and Res ~= Res2 then
        local Diff = Res - Res2
        if Diff > 0 then
            ChangeOrders(-math.min(Diff, OrdersS), math.max(0, Diff - OrdersS))
        else
            ChangeOrders(math.min(-Diff, OrdersB), -math.max(0, -Diff - OrdersB))
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
    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)
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
