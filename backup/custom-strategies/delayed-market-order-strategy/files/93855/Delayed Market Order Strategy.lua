-- Id: 11670
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=60651

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
    strategy:name("Delayed Market Order Strategy")
    strategy:description("")
    strategy:setTag("Version", "2")
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addDate("StartTime", "Execution Date and Time", "", 0)
    strategy.parameters:setFlag("StartTime", core.FLAG_DATETIME)
    strategy.parameters:addInteger("TradeInterval", "Trade Executions Interval in second", "Use 0 for unlimited", 0)
    strategy.parameters:addBoolean(
        "AllowMultiple",
        "Allow Multiple",
        "Should we allow multiple trades open at the same time.",
        false
    )

    strategy.parameters:addGroup("Repeat Parameters")
    strategy.parameters:addBoolean(
        "Repeat",
        "Repeat",
        "Should we repeat and enter a new trade after a delay. If false, strategy terminates after placing trade.",
        false
    )
    strategy.parameters:addInteger(
        "RepeatDelay",
        "Repeat Delay (mins)",
        "How many minutes should we wait between repeats",
        60
    )
    strategy.parameters:addBoolean(
        "CloseOnRepeat",
        "Close On Repeat",
        "Should we close any pending orders when we repeat?",
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

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addString("BuySell", "Buy or Sell?", "", "B")
    strategy.parameters:addStringAlternative("BuySell", "Buy", "", "B")
    strategy.parameters:addStringAlternative("BuySell", "Sell", "", "S")
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
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
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

local SoundFile = nil
local RecurrentSound = false
local AllowTrade
local Offer
local CanClose
local Account
local Amount
local SetLimit
local Limit
local SetStop
local Stop
local TrailingStop
local ShowAlert
local Email
local SendEmail
local BaseSize
local BuySell
local TradeInterval
local StartTime
local EndTime

local Repeat
local RepeatDelay
local CloseOnRepeat
local instanceName
local AllowMultiple

function Prepare(nameOnly)
    TradeInterval = instance.parameters.TradeInterval
    Repeat = instance.parameters.Repeat
    RepeatDelay = instance.parameters.RepeatDelay
    CloseOnRepeat = instance.parameters.CloseOnRepeat
    AllowMultiple = instance.parameters.AllowMultiple

    instanceName = profile:id() .. "( " .. instance.bid:name() .. " )"
    instance:name(instanceName)
    instanceName = instanceName .. " " .. instance.parameters.CustomID

    -- NG: parsing of the time is moved to separate function
    local valid
    StartTime = instance.parameters.StartTime
    EndTime = instance.parameters.StartTime + (TradeInterval / 86400.0)

    PrepareTrading()

    if nameOnly then
        return
    end

    core.host:execute("setTimer", 100, 1)
end

function PrepareTrading()
    BuySell = instance.parameters.BuySell

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
    if AllowTrade then
        Account = instance.parameters.Account
        Amount = instance.parameters.Amount
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
        SetLimit = instance.parameters.SetLimit
        Limit = instance.parameters.Limit
        SetStop = instance.parameters.SetStop
        Stop = instance.parameters.Stop
        TrailingStop = instance.parameters.TrailingStop
    end
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
end

local create = true
local nextRepeatTime = nil

function Check()
    -- timer
    if AllowTrade then
        now = core.host:execute("getServerTime")

        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end

        if now >= StartTime and (now < EndTime or EndTime == StartTime) then
            if (create) then
                create = false
                enter(BuySell)

                if BuySell == "B" then
                    Signal("Open Long")
                else
                    Signal("Open Short")
                end

                if Repeat then
                    nextRepeatTime = now + (RepeatDelay / 1440) - (5 / 86400) -- minus one as it takes a second to come back to this method.
                else
                    core.host:execute("stop")
                end
            else
            end
        end

        if not create and Repeat and now >= nextRepeatTime then
            -- reset the create flag to create a new trade!
            create = true
        end
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        Check()
    elseif cookie == 200 and not success then
        create = true
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed: " .. message,
            instance.bid:date(instance.bid:size() - 1)
        )
    elseif cookie == 200 and success and not Repeat then
        core.host:execute("stop")
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

function haveTrades(BuySell)
    local enum, row
    local found = false
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while (not found) and (row ~= nil) do
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == instanceName and
                (row.BS == BuySell or BuySell == nil)
         then
            found = true
        end
        row = enum:next()
    end

    return found
end

-- enter into the specified direction
function enter(BuySell)
    if not (AllowTrade) then
        return true
    end

    -- do not enter if position in the
    -- specified direction already exists
    if haveTrades() and not AllowMultiple then
        return true
    end

    local valuemap, success, msg
    valuemap = core.valuemap()
    valuemap.CustomID = instanceName
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell

    -- add stop/limit
    valuemap.PegTypeStop = "O"
    if SetStop then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop
        else
            valuemap.PegPriceOffsetPipsStop = Stop
        end
    end
    if TrailingStop then
        valuemap.TrailStepStop = 1
    end

    valuemap.PegTypeLimit = "O"
    if SetLimit then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit
        end
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = "Y"
    end

    success, msg = terminal:execute(200, valuemap)

    if not (success) then
        create = true
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed: " .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    return true
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
