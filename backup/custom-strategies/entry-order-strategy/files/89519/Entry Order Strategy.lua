-- Id: 10006
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=59515

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Entry Order Strategy")
    strategy:description("")
    -- NG: optimizer/backtester hint
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email")

    strategy.parameters:addGroup("Time Parameters")
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00")
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString(
        "EntryType",
        "Entry Type",
        "When the time to place the order comes, should the order price be determined from the current price or previous close?",
        "CurrentPrice"
    )
    strategy.parameters:addStringAlternative("EntryType", "Current Price", "", "CurrentPrice")
    strategy.parameters:addStringAlternative("EntryType", "Previous Close", "", "PreviousClose")
    strategy.parameters:addString(
        "TF",
        "Bar Time frame",
        "Bar time frame used if Entry Type base is Previous Close.",
        "D1"
    )
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)
    strategy.parameters:addBoolean(
        "UseMandatoryClosing",
        "Scheduled Terminate",
        "Terminates the strategy at this time.",
        false
    )
    strategy.parameters:addString("ExitTime", "Scheduled Termination Time", "", "23:59:00")
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60)

    strategy.parameters:addGroup("Repeat Parameters")
    strategy.parameters:addBoolean(
        "Repeat",
        "Repeat",
        "Should we repeat this operation periodically. If false, strategy terminates after placing trade.",
        false
    )
    strategy.parameters:addInteger(
        "RepeatDelay",
        "Repeat Delay (mins)",
        "How many minutes should we wait between repeats",
        60
    )
    strategy.parameters:addBoolean(
        "CloseOrdersOnRepeat",
        "Close Orders On Repeat",
        "Should we close any pending orders when we repeat?",
        false
    )
    strategy.parameters:addBoolean(
        "ClosePositionsOnRepeat",
        "Close Positions On Repeat",
        "Should we close any open positions when we repeat?",
        false
    )
    strategy.parameters:addString(
        "CustomID",
        "Identifier",
        "This identifier is required to identify previously placed orders by this strategy",
        "EntryOrderStrat"
    )

    CreateTradingParameters()
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Amount in lots to trade", "", 1, 1, 100)
    strategy.parameters:addInteger("Distance", "Distance to market (in pips)", "", 100, -1000, 1000)
    strategy.parameters:addString("BuySell", "Buy or Sell?", "", "B")
    strategy.parameters:addStringAlternative("BuySell", "Buy", "", "B")
    strategy.parameters:addStringAlternative("BuySell", "Sell", "", "S")

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
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

local offer
local account
local amount
local pipsize
local BuySell
local distance
local SoundFile = nil
local RecurrentSound = false
local SetLimit
local Limit
local SetStop
local Stop
local TrailingStop
local ShowAlert
local Email
local SendEmail
local BaseSize
local ValidInterval
local UseMandatoryClosing
local canClose
-- Don't need to store hour + minute + second for each time
local OpenTime, CloseTime, ExitTime

local Source
local EntryType
local Repeat
local RepeatDelay
local CloseOrdersOnRepeat
local ClosePositionsOnRepeat
local instanceName

--
function Prepare(nameOnly)
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing
    ValidInterval = instance.parameters.ValidInterval
    EntryType = instance.parameters.EntryType
    Repeat = instance.parameters.Repeat
    RepeatDelay = instance.parameters.RepeatDelay
    CloseOrdersOnRepeat = instance.parameters.CloseOrdersOnRepeat
    ClosePositionsOnRepeat = instance.parameters.ClosePositionsOnRepeat

    instanceName = profile:id() .. "( " .. instance.bid:name() .. " )"
    instance:name(instanceName)
    instanceName = instanceName .. " " .. instance.parameters.CustomID

    -- NG: parsing of the time is moved to separate function
    local valid
    OpenTime, valid = ParseTime(instance.parameters.StartTime)
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")
    CloseTime, valid = ParseTime(instance.parameters.StopTime)
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid")
    ExitTime, valid = ParseTime(instance.parameters.ExitTime)
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid")

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    PrepareTrading()

    if nameOnly then
        return
    end

    -- this timer will be used to check our conditions every 5 seconds
    core.host:execute("setTimer", 1111, 5)

    if (EntryType == "PreviousClose") then
        -- price bid/ask depends on if we are selling or buying.
        Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.BuySell == "S", "close")
    end

    if UseMandatoryClosing then
        core.host:execute("setTimer", 1001, math.max(ValidInterval / 2, 1))
    end
end

function PrepareTrading()
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
    account = instance.parameters.Account
    BuySell = instance.parameters.BuySell
    distance = instance.parameters.Distance

    local lotSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), account)
    amount = lotSize * instance.parameters.Amount
    offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    pipsize = instance.bid:pipSize()

    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), account)
    SetLimit = instance.parameters.SetLimit
    Limit = instance.parameters.Limit
    SetStop = instance.parameters.SetStop
    Stop = instance.parameters.Stop
    TrailingStop = instance.parameters.TrailingStop
    canClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), account)
end

function ParseTime(time)
    local pos = string.find(time, ":")
    if pos == nil then
        return nil, false
    end
    local h = tonumber(string.sub(time, 1, pos - 1))
    time = string.sub(time, pos + 1)
    pos = string.find(time, ":")
    if pos == nil then
        return nil, false
    end
    local m = tonumber(string.sub(time, 1, pos - 1))
    local s = tonumber(string.sub(time, pos + 1))
    return (h / 24.0 + m / 1440.0 + s / 86400.0), ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or -- time in ole format
        (h == 24 and m == 0 and s == 0)) -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

local create = true
local nextRepeatTime = nil
local requestId

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    -- we don't need to do anything here.
end

function CheckConditions()
    if not (checkReady("trades")) or not (checkReady("orders")) then
        return
    end

    local now = core.host:execute("getServerTime")
    local time = now - math.floor(now)

    if InRange(time) then
        if create then
            if (EntryType == "PreviousClose") then
                -- confirm we have data from our Source;
                if not Source:hasData(Source:size() - 2) then
                    return
                end
            end

            -- we need to create a new trade, do it.
            Entry()
            nextRepeatTime = now + (RepeatDelay / 1440) - (5 / 86400) -- minus one as it takes a second to come back to this method.
        end
    end

    if not create and Repeat and now >= nextRepeatTime then
        -- we need to repeat now

        -- check if we are supposed to close pending orders first
        if CloseOrdersOnRepeat then
            CloseAllOrders()
        end

        -- check if we are supposed to close open positions first.
        if CloseOrdersOnRepeat then
            exitNet("B")
            exitNet("S")
        end

        -- reset the create flag to create a new trade!
        create = true
    end
end

function CloseAllOrders()
    local enum, row
    enum = core.host:findTable("orders"):enumerator()
    row = enum:next()
    while (row ~= nil) do
        if
            row.AccountID == account and row.OfferID == offer and row.QTXT == instanceName and
                (row.Type == "LE" or row.Type == "SE")
         then
            -- we want to close the entry orders, not the stop or limit orders etc otherwise we will get errors as they close each other out.
            local valuemap = core.valuemap()
            valuemap.Command = "DeleteOrder"
            valuemap.OrderID = row.OrderID
            success, msg = terminal:execute(301, valuemap)
            if not (success) then
                terminal:alertMessage(
                    instance.bid:instrument(),
                    instance.bid[NOW],
                    "Failed to delete orders for instance: " .. instanceName .. ": " .. msg,
                    instance.bid:date(NOW)
                )
            end
        end

        row = enum:next()
    end
end

function HaveTrades(BuySell)
    local enum, row
    local found = false
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while (not found) and (row ~= nil) do
        if
            row.AccountID == account and row.OfferID == offer and row.QTXT == instanceName and
                (row.BS == BuySell or BuySell == nil)
         then
            found = true
        end

        row = enum:next()
    end

    return found
end

-- exit from the specified trade using the direction as a key
function exitNet(BS)
    if not HaveTrades(BS) then
        return
    end

    local valuemap, success, msg, BuySell
    valuemap = core.valuemap()

    -- switch the direction since the order must be in oppsite direction
    local BuySell = nil
    if BS == "B" then
        BuySell = "S"
    else
        BuySell = "B"
    end
    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "CM"
    valuemap.OfferID = offer
    valuemap.AcctID = account
    valuemap.NetQtyFlag = "Y" -- this forces all trades to close in the opposite direction.
    valuemap.BuySell = BuySell
    valuemap.CustomID = instanceName

    success, msg = terminal:execute(101, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Failed net closing of " .. BS .. " trades for instance " .. instanceName .. ": " .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

function Entry()
    create = false

    -- create order
    local valuemap = core.valuemap()
    valuemap.Command = "CreateOrder"

    if (EntryType == "CurrentPrice") then
        -- MooMooForex: I don't agree with the logic below but I'll leave it to match the previous version of the strategy.
        -- get the order type
        if BuySell == "B" and distance < 0 then
            valuemap.OrderType = "LE"
        elseif BuySell == "B" and distance > 0 then
            valuemap.OrderType = "SE"
        elseif BuySell == "S" and distance < 0 then
            valuemap.OrderType = "SE"
        elseif BuySell == "S" and distance > 0 then
            valuemap.OrderType = "LE"
        end

        if distance >= 0 then
            valuemap.Rate = instance.ask[NOW] + distance * pipsize
        else
            valuemap.Rate = instance.bid[NOW] + distance * pipsize
        end
    else
        -- get the price of the previous close.
        local prevClose = Source[Source:size() - 2]

        -- adjust the rate from there.
        valuemap.Rate = prevClose + (distance * pipsize)

        core.host:trace("Previous close is " .. prevClose .. " entry price is " .. valuemap.Rate)

        -- set the order type
        if BuySell == "B" then
            if instance.ask[NOW] > valuemap.Rate then
                valuemap.OrderType = "LE"
            else
                valuemap.OrderType = "SE"
            end
        elseif BuySell == "S" then
            if instance.bid[NOW] > valuemap.Rate then
                valuemap.OrderType = "SE"
            else
                valuemap.OrderType = "LE"
            end
        end
    end

    if instance.parameters.SetLimit then
        valuemap.PegTypeLimit = "M"
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = instance.parameters.Limit
        else
            valuemap.PegPriceOffsetPipsLimit = -instance.parameters.Limit
        end
    end

    if instance.parameters.SetStop then
        valuemap.PegTypeStop = "M"
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -instance.parameters.Stop
        else
            valuemap.PegPriceOffsetPipsStop = instance.parameters.Stop
        end

        if instance.parameters.TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end

    if not (canClose) and (instance.parameters.SetStop or instance.parameters.SetLimit) then
        -- if regular s/l orders aren't allowed - create ELS order
        valuemap.EntryLimitStop = "Y"
    end

    valuemap.OfferID = offer
    valuemap.AcctID = account
    valuemap.Quantity = amount
    valuemap.BuySell = BuySell
    valuemap.CustomID = instanceName

    local success, msg = terminal:execute(100, valuemap)
    if not (success) then
        create = true
    else
        requestId = core.parseCsv(msg, ",")[0]
        TerminateAfterTrade()
    end
end

function TerminateAfterTrade()
    if Repeat then
        -- don't abort.
        return
    end

    core.host:execute("stop")
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 1001 then
        -- timer
        if UseMandatoryClosing then
            now = core.host:execute("getServerTime")
            -- get only time
            now = now - math.floor(now)

            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime + (ValidInterval / 86400.0) then
                core.host:execute("stop")
            end
        end
    elseif cookie == 1111 then
        CheckConditions()
    elseif cookie == 100 and instance.parameters.AllowTrade then
        if not (success) then
            Signal("create order failed: " .. message)
        else
            Signal("order sent: " .. message)
            TerminateAfterTrade()
        end
    elseif cookie == 101 then
        if not (success) then
            Signal("close position failed: " .. message)
        end
    elseif cookie == 301 then
        if not (success) then
            Signal("delete order failed: " .. message)
        end
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
