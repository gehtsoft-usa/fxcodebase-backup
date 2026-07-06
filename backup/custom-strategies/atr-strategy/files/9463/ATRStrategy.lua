-- Id: 3557
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3861

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

local version = "1.1"
-- Strategy profile initialization routine
-- Defines Strategy profile properties and Strategy parameters
function Init()
    strategy:name("ATR Strategy")
    strategy:description("ATR Strategy. v." .. version)
    strategy:setTag("Version", version)
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)
    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")
    strategy.parameters:addString("Action", "Act on Close/Break Out", "", "Close")
    strategy.parameters:addStringAlternative("Action", "Close", "", "Close")
    strategy.parameters:addStringAlternative("Action", "Break Out", "", "BreakOut")

    strategy.parameters:addGroup("Parameters")
    strategy.parameters:addInteger("AP", "ATR period ", "ATR Period ", 14)
    strategy.parameters:addDouble("AM", "ATR multiplicator ", "ATR multiplicator ", 3.5)

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

    strategy.parameters:addGroup("Notification")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", false)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", true)
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", true)
    strategy.parameters:addString("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", true)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- Parameters block
local barSource = nil -- the source stream
local tickSource = nil -- the source stream
local PlaySound
local RecurrentSound
local SoundFile
local Email
local SendEmail
local AllowTrade
local Account
local Amount
local BaseSize
local SetLimit
local Limit
local SetStop
local Stop
local TrailingStop
local Offer
local CanClose

local ATRTS = 0
local Multiplicator
local Action
local BAR_SOURCE = 1
local TICK_SOURCE = 2

-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    AllowTicks = instance.parameters.AllowTicks
    if (not (AllowTicks)) then
        assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks.")
    end

    ShowAlert = instance.parameters.ShowAlert
    if ShowAlert then
        PlaySound = instance.parameters.PlaySound
        if PlaySound then
            RecurrentSound = instance.parameters.RecurSound
            SoundFile = instance.parameters.SoundFile
        else
            SoundFile = nil
        end
        assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified")

        SendEmail = instance.parameters.SendEmail
        if SendEmail then
            Email = instance.parameters.Email
        else
            Email = nil
        end
        assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")
    end

    AllowTrade = instance.parameters.AllowTrade
    if AllowTrade then
        Account = instance.parameters.Account
        Amount = instance.parameters.Amount
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
        SetLimit = instance.parameters.SetLimit
        Limit = instance.parameters.Limit * instance.bid:pipSize()
        SetStop = instance.parameters.SetStop
        Stop = instance.parameters.Stop * instance.bid:pipSize()
        TrailingStop = instance.parameters.TrailingStop
    end

    Action = instance.parameters.Action

    barSource = ExtSubscribe(BAR_SOURCE, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    if Action == "BreakOut" then
        tickSource = ExtSubscribe(TICK_SOURCE, nil, "t1", instance.parameters.Type == "Bid", "tick")
    end

    ExtSetupSignal(profile:id() .. ":", ShowAlert)
    ExtSetupSignalMail(name)

    Multiplicator = instance.parameters.AM
    ATR = core.indicators:create("ATR", barSource, instance.parameters.AP)
end

local direction = "Z"

-- strategy calculation routine
function ExtUpdate(id, source, period)
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    if id == BAR_SOURCE then
        --if Action == "Close" then
        --    checkPrice(source.close, period)
        --end

        --== Recalculate ATRTS value
        ATR:update(core.UpdateLast)

        if ATR.DATA:hasData(period) then
            local STOP = ATR.DATA[period] * Multiplicator

            if direction == "Z" then
                direction = (source.open[period] < source.close[period]) and "B" or "S"
                ATRTS = (direction == "B") and (source.close[period] - STOP) or (source.close[period] + STOP)
            else
                if source.low[period] < ATRTS and source.low[period - 1] > ATRTS then
                    if Action == "Close" then
                        sell()
                    end
                    direction = "S"
                    ATRTS = source.close[period] + STOP
                elseif source.high[period] > ATRTS and source.high[period - 1] < ATRTS then
                    if Action == "Close" then
                        buy()
                    end
                    direction = "B"
                    ATRTS = source.close[period] - STOP
                else
                    if direction == "S" then
                        ATRTS = math.min(ATRTS, source.close[period] + STOP)
                    elseif direction == "B" then
                        ATRTS = math.max(ATRTS, source.close[period] - STOP)
                    end
                end
            end
        end
    elseif id == TICK_SOURCE then
        if Action == "BreakOut" then
            if source[period] < ATRTS and source[period - 1] > ATRTS and direction == "B" then
                sell()
            end
            if source[period] > ATRTS and source[period - 1] < ATRTS and direction == "S" then
                buy()
            end
        end
    end
end

function sell()
    exit("B")
    enter("S")
    if ShowAlert then
        ExtSignal(stream, period, "SELL", SoundFile, Email, RecurrentSound)
    end
end

function buy()
    exit("S")
    enter("B")
    if ShowAlert then
        ExtSignal(stream, period, "BUY", SoundFile, Email, RecurrentSound)
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

-- -----------------------------------------------------------------------
-- Function checks that specified table is ready (filled) for processing
-- or that we running under debugger/simulation conditions.
-- -----------------------------------------------------------------------
function checkReady(table)
    local rc
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true
    else
        rc = core.host:execute("isTableFilled", table)
    end
    return rc
end

-- -----------------------------------------------------------------------
-- Return count of opened trades for spicific direction
-- (both directions if BuySell parameters is 'nil')
-- -----------------------------------------------------------------------
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

-- -----------------------------------------------------------------------
-- Enter into the specified direction
--  BuySell : direction to enter, shoulde be 'B' for long position or 'S' for short
-- -----------------------------------------------------------------------
function enter(BuySell)
    if not (AllowTrade) then
        return true
    end

    local valuemap, success, msg

    -- do not enter if position in the specified direction already exists
    if haveTrades(BuySell) then
        return true
    end

    valuemap = core.valuemap()

    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell
    valuemap.PegTypeStop = "M"

    if SetLimit then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit
        end
    end

    if SetStop then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateStop = instance.ask[NOW] - Stop
        else
            valuemap.RateStop = instance.bid[NOW] + Stop
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end

    if (not CanClose) and (SetStop or SetLimit) then
        valuemap.EntryLimitStop = "Y"
    end

    success, msg = terminal:execute(100, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed:" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    return true
end

-- -----------------------------------------------------------------------
--  Exit from the specified direction
-- -----------------------------------------------------------------------
function exit(BuySell)
    if not (AllowTrade) then
        return
    end

    local valuemap, success, msg
    if haveTrades(BuySell) then
        valuemap = core.valuemap()

        -- switch the direction since the order must be in oppsite direction
        if BuySell == "B" then
            BuySell = "S"
        else
            BuySell = "B"
        end
        valuemap.OrderType = "CM"
        valuemap.OfferID = Offer
        valuemap.AcctID = Account
        valuemap.NetQtyFlag = "Y"
        valuemap.BuySell = BuySell
        success, msg = terminal:execute(101, valuemap)

        if not (success) then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[instance.bid:size() - 1],
                "Open order failed" .. msg,
                instance.bid:date(instance.bid:size() - 1)
            )
        end
    end
end

--===========================================================================--
--                      END OF TRADING UTILITY FUNCTIONS                     --
--===========================================================================--

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
