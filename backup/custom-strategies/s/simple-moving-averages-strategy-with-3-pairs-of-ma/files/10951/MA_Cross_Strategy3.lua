-- Id: 3982
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4434

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
    strategy:name("MA cross strategy")
    strategy:description("Ma cross strategy")
    strategy:setTag(
        "NonOptimizableParameters",
        "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert,Account,CanTrade,Email,SendEmail"
    )
    strategy:setTag("Version", "1.1")

    strategy.parameters:addGroup("MA indicators parameters")
    strategy.parameters:addInteger("N1", "Period1", "Period1", 10, 1, 1000)
    strategy.parameters:addInteger("N2", "Period2", "Period2", 20, 1, 1000)
    strategy.parameters:addInteger("N3", "Period3", "Period3", 30, 1, 1000)
    strategy.parameters:addInteger("N4", "Period4", "Period4", 40, 1, 1000)
    strategy.parameters:addInteger("N5", "Period5", "Period5", 50, 1, 1000)
    strategy.parameters:addInteger("N6", "Period6", "Period6", 60, 1, 1000)

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false)
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false)
    strategy.parameters:addString("Email", "Email address", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- Internal indicators
local MA1 = nil
local MA2 = nil
local MA3 = nil
local MA4 = nil
local MA5 = nil
local MA6 = nil

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

--
--
--
function Prepare(nameOnly)
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name =
        profile:id() ..
        "(" ..
            instance.bid:name() ..
                "." ..
                    instance.parameters.TF ..
                        "," .. "MA(" .. instance.parameters.N1 .. ", " .. instance.parameters.N2 .. "))"
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
    MA1 = core.indicators:create("MVA", Source.close, instance.parameters.N1)
    MA2 = core.indicators:create("MVA", Source.close, instance.parameters.N2)
    MA3 = core.indicators:create("MVA", Source.close, instance.parameters.N3)
    MA4 = core.indicators:create("MVA", Source.close, instance.parameters.N4)
    MA5 = core.indicators:create("MVA", Source.close, instance.parameters.N5)
    MA6 = core.indicators:create("MVA", Source.close, instance.parameters.N6)

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
    MA1:update(core.UpdateLast)
    MA2:update(core.UpdateLast)
    MA3:update(core.UpdateLast)
    MA4:update(core.UpdateLast)
    MA5:update(core.UpdateLast)
    MA6:update(core.UpdateLast)

    -- Check that we have enough data
    if (MA1.DATA:first() > (period - 1)) then
        return
    end
    if (MA2.DATA:first() > (period - 1)) then
        return
    end
    if (MA3.DATA:first() > (period - 1)) then
        return
    end
    if (MA4.DATA:first() > (period - 1)) then
        return
    end
    if (MA5.DATA:first() > (period - 1)) then
        return
    end
    if (MA6.DATA:first() > (period - 1)) then
        return
    end

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades")

    local ResPrev = 0
    local ResCur = 0

    if MA1.DATA[period - 1] < MA2.DATA[period - 1] then
        ResPrev = -1
    elseif MA1.DATA[period - 1] > MA2.DATA[period - 1] then
        ResPrev = 1
    end
    if MA1.DATA[period] < MA2.DATA[period] then
        ResCur = -1
    elseif MA1.DATA[period] > MA2.DATA[period] then
        ResCur = 1
    end

    if MA3.DATA[period - 1] < MA4.DATA[period - 1] then
        ResPrev = ResPrev - 1
    elseif MA3.DATA[period - 1] > MA4.DATA[period - 1] then
        ResPrev = ResPrev + 1
    end
    if MA3.DATA[period] < MA4.DATA[period] then
        ResCur = ResCur - 1
    elseif MA3.DATA[period] > MA4.DATA[period] then
        ResCur = ResCur + 1
    end

    if MA5.DATA[period - 1] < MA6.DATA[period - 1] then
        ResPrev = ResPrev - 1
    elseif MA5.DATA[period - 1] > MA6.DATA[period - 1] then
        ResPrev = ResPrev + 1
    end
    if MA5.DATA[period] < MA6.DATA[period] then
        ResCur = ResCur - 1
    elseif MA5.DATA[period] > MA6.DATA[period] then
        ResCur = ResCur + 1
    end

    local OrdersB, OrdersS = CountOrders()
    local Res = OrdersB - OrdersS
    local Diff = ResCur - Res
    if ResCur ~= ResPrev and Diff ~= 0 and math.abs(Res - ResCur) <= 6 then
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
function Open(side, Comm)
    local valuemap

    valuemap = core.valuemap()
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.CustomID = CID
    valuemap.BuySell = side
    valuemap.QTXT = Comm
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
