-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20
-- Id: 23910
function Init()
    strategy:name("DNC strategy")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert")
    strategy:description("DNC strategy")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")
    strategy.parameters:addGroup("Time Frame")
    HaParameter(1, "m5", 10, 0)
    strategy.parameters:addInteger("N", "Short Term Period", "", 20, 2, 10000)

    strategy.parameters:addInteger("SX", "Short Term Shift", "", 20, 0, 1000)
    strategy.parameters:addInteger("N1", "Long Term Period", "", 40, 2, 10000)

    strategy.parameters:addInteger("SX1", "Long Term Shift", "", 40, 0, 1000)

    CreateTradingParameters()
end

function HaParameter(id, frame, n, level)
    strategy.parameters:addString("TF" .. id, "Strategy Time Frame", "", frame)
    strategy.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
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

    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 2, 1, 100)
    strategy.parameters:addInteger("takeprofit", "Take Profit in Lots", "", 1, 0, 100)
    strategy.parameters:addInteger("profitsize", "Profit after pips", "", 30, 1, 10000)

    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)

    strategy.parameters:addGroup("Alerts")
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)

    strategy.parameters:addGroup("Time Parameters")
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00")
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00")
end

local SoundFile = nil
local RecurrentSound = false
local ALLOWEDSIDE
local AllowTrade
local Offer
local CanClose
local Account
local Amount
local SetLimit
local Limit
local ShowAlert
local Email
local SendEmail
local BaseSize

local Source
local INDICATOR
local sgline
local CustomID
local pipSize
local StartTime
local StopTime
local takeprofit
local profitsize
local strate
local bs = 0
local stcreate = false
local closed = false
local stopenter = false
local fstep = false
local fno = nil
local Source1 = nil
local n
local sx
local stp = 0

local first = 0
local first2
local Source1
local du
local du1
local dn
local dn1
local ClosedHalf

function Prepare(nameOnly)
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "( " .. instance.bid:name() .. ")"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    local valid
    StartTime, valid = ParseTime(instance.parameters.StartTime)
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")
    StopTime, valid = ParseTime(instance.parameters.StopTime)
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid")

    Source = ExtSubscribe(2, nil, instance.parameters.TF1, instance.parameters.Type == "Bid", "bar")

    first = instance.parameters.N + Source:first()
    n = instance.parameters.N
    sx = instance.parameters.SX

    first2 = first + instance.parameters.SX1

    local prof = core.indicators:findIndicator("DNCLINK");
    assert(prof ~= nil, "Please, download and install " .. "DNCLINK" .. ".LUA indicator");
    local aparams = prof:parameters()
    aparams:setString("N", instance.parameters.N)
    aparams:setString("SX", instance.parameters.SX)
    aparams:setString("N1", instance.parameters.N1)
    aparams:setString("SX1", instance.parameters.SX1)
    INDICATOR = prof:createInstance(Source, aparams)
    sgline = INDICATOR.bsline
    du = INDICATOR.DU
    dn = INDICATOR.DN
    du1 = INDICATOR.DU1
    dn1 = INDICATOR.DN1
    pipSize = Source:pipSize()
end

function ParseTime(time)
    local Pos = string.find(time, ":")
    local h = tonumber(string.sub(time, 1, Pos - 1))
    time = string.sub(time, Pos + 1)
    Pos = string.find(time, ":")
    local m = tonumber(string.sub(time, 1, Pos - 1))
    local s = tonumber(string.sub(time, Pos + 1))
    return (h / 24.0 + m / 1440.0 + s / 86400.0), ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or
        (h == 24 and m == 0 and s == 0))
end
function PrepareTrading()
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
    Account = instance.parameters.Account
    Amount = instance.parameters.Amount
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
    SetLimit = instance.parameters.SetLimit
    Limit = instance.parameters.Limit
    takeprofit = instance.parameters.takeprofit
    profitsize = instance.parameters.profitsize
end

function ExtUpdate(id, source, period)
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if period < first2 then
        return
    end

    INDICATOR:update(core.UpdateLast)
    if not du:hasData(du:size() - 1) then
        return
    end

    local now = core.host:execute("getServerTime")
    now = now - math.floor(now)

    local canBuy = false
    local canSell = false

    if
        (StopTime > StartTime and now >= StartTime and now <= StopTime) or
            (StopTime < StartTime and (now >= StartTime or now <= StopTime))
     then
        local p = period

        if sgline[p] == 1 and bs ~= 1 then
            canBuy = true
            bs = 1
        end
        if sgline[p] == 2 and bs ~= 2 then
            canSell = true
            bs = 2
        end
    end

    if (canBuy) then
        BUY()
        ClosedHalf = false
    elseif (canSell) then
        SELL()
        ClosedHalf = false
    elseif not (ClosedHalf) then
        CheckProfit()
    end
end

function CheckProfit()
    local enum, row
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()

    while row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer then
            if row.BS == "B" and row.Close - row.Open >= profitsize * pipSize then
                exit("B", takeprofit, row.TradeID)
                createStop(row)
                ClosedHalf = true
                return
            elseif row.BS == "S" and row.Open - row.Close >= profitsize * pipSize then
                exit("S", takeprofit, row.TradeID)
                createStop(row)
                ClosedHalf = true
                return
            end
        end
        row = enum:next()
    end
end

function createStop(Trade)
    valuemap = core.valuemap()
    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "SE"
    valuemap.OfferID = Trade.OfferID
    valuemap.AcctID = Trade.AccountID
    valuemap.NetQtyFlag = "y"
    valuemap.Rate = Trade.Open
    if Trade.BS == "B" then
        valuemap.BuySell = "S"
    else
        valuemap.BuySell = "B"
    end
    success, msg = terminal:execute(200, valuemap)
    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[NOW],
            "Failed create stop " .. msg,
            instance.bid:date(NOW)
        )
    end
end

function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 200 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    elseif cookie == 202 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Limit Entry order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    elseif cookie == 203 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Limit Entry Remove order failed " .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    elseif cookie == 204 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Stop order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    elseif cookie == 205 and not success then
    elseif cookie == 206 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Modify Stop order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    elseif cookie == 201 and not success then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Close order failed" .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

function BUY()
    if AllowTrade then
        if haveTrades("S") then
            exit("S", 0, 0)
            Signal("Close Short")
        end
        if not haveTrades("B") then
            enter("B")
            Signal("Open Long")
        end
    elseif ShowAlert then
        Signal("Up Trend")
    end
end

function SELL()
    if AllowTrade then
        if haveTrades("B") then
            exit("B", 0, 0)
            Signal("Close Long")
        end
        if not haveTrades("S") then
            enter("S")
            Signal("Open Short")
        end
    elseif ShowAlert then
        Signal("Down Trend")
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
    return core.host:execute("isTableFilled", table)
end

function tradesCount(BuySell)
    local enum, row
    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()

    while row ~= nil do
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

function enter(BuySell)
    if not (AllowTrade) then
        return true
    end

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

    if SetLimit then
        if BuySell == "B" then
            valuemap.RateLimit = instance.bid[NOW] + Limit * pipSize
        else
            valuemap.RateLimit = instance.ask[NOW] - Limit * pipSize
        end
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = "Y"
    end

    success, msg = terminal:execute(200, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    else
    end

    return true
end

function exit(BuySell, Lots, TradeID)
    if not (AllowTrade) then
        return true
    end

    local valuemap, success, msg

    if tradesCount(BuySell) > 0 then
        valuemap = core.valuemap()

        if BuySell == "B" then
            BuySell = "S"
        else
            BuySell = "B"
        end
        valuemap.Command = "CreateOrder"
        valuemap.OrderType = "CM"
        valuemap.OfferID = Offer
        valuemap.AcctID = Account
        if Lots == 0 then
            valuemap.NetQtyFlag = "Y"
        else
            valuemap.Quantity = Lots * BaseSize
            valuemap.TradeID = TradeID
        end
        valuemap.BuySell = BuySell
        success, msg = terminal:execute(201, valuemap)

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
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
