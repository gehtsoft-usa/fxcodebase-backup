-- Id: 3677
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3964

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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

function Init()
    strategy:name("MarginLiquidator")
    strategy:description("MarginLiquidator")
    strategy:setTag(
        "NonOptimizableParameters",
        "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert,Account,CanTrade,Email,SendEmail"
    )
    strategy:setTag("Version", "2")

    strategy.parameters:addGroup("Common Parameters")
    strategy.parameters:addBoolean(
        "AllAcct",
        "Watch margin on all accounts",
        "If Yes, the margin will be watched on all accounts, otherwise, one of the accounts should be selected.",
        true
    )
    strategy.parameters:addString(
        "Account",
        "Account to watch",
        "The strategy will work for the specified account.",
        ""
    )
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addInteger(
        "UpdateInterval",
        "Check margin interval, sec",
        "How often the margin will be checked, time in seconds.",
        10
    )

    strategy.parameters:addGroup("Margin Parameters")
    strategy.parameters:addDouble("MinUsableMargin", "MinimumUsableMargin", "Limit Of Margin To Use", 60)
    strategy.parameters:addString("LiqType", "LiquidationType", "Type of liquidation.", "SpecAmount")
    strategy.parameters:addStringAlternative("LiqType", "OldPositions", "Liquidate old positions first", "OldPos")
    strategy.parameters:addStringAlternative("LiqType", "NewPositions", "Liquidate new positions first", "NewPos")
    strategy.parameters:addStringAlternative(
        "LiqType",
        "SpecificAmount",
        "Liquidate specific amount from oldest position pair",
        "SpecAmount"
    )
    strategy.parameters:addInteger(
        "SpecAmount",
        "SpecificAmount (K)",
        "Amount to liquidate in Ks. I.e 10 will mean 10,000",
        10,
        1,
        1000
    )

    strategy.parameters:addGroup("Notification")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", false)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
    strategy.parameters:addString("Email", "Email", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- Parameters block
local AllAcct
local Account
local UpdateInterval

local UsableMargin
local LiqType
local SpecAmount

local ShowAlert
local PlaySound
local RecurrentSound
local SoundFile
local Email
local SendEmail

local TIMER_ID = 100
local STOP_COMMAND = 20001
-- Routine
function Prepare(nameOnly)
    MinUsableMargin = instance.parameters.MinUsableMargin
    LiqType = instance.parameters.LiqType

    local name =
        profile:id() ..
        "(" .. instance.bid:instrument() .. ", " .. tostring(MinUsableMargin) .. "%, " .. tostring(LiqType) .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    ShowAlert = instance.parameters.ShowAlert

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

    AllAcct = instance.parameters.AllAcct
    Account = instance.parameters.Account
    UpdateInterval = instance.parameters.UpdateInterval
    SpecAmount = instance.parameters.SpecAmount * 1000
    --BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    --CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);

    timerId = core.host:execute("setTimer", TIMER_ID, UpdateInterval)
    core.host:execute("addCommand", STOP_COMMAND, "Stop Margin Liquidator", "Stop Margin Liquidator")
end

--------------------------------------------
-- Recalculate margin level and recheck all levels on timer
--------------------------------------------
function AsyncOperationFinished(cookie, successful, message)
    if cookie == STOP_COMMAND then
        core.host:execute("stop")
        return
    elseif cookie == TIMER_ID then
        if not (core.host:execute("isTableFilled", "accounts")) then
            return false
        end

        if AllAcct == true then
            local enum = core.host:findTable("accounts"):enumerator()
            local row = enum:next()
            while row ~= nil do
                checkAcct(row)
                row = enum:next()
            end
        else
            local row = core.host:findTable("accounts"):find("AccountID", Account)
            checkAcct(row)
        end
    end
end

function checkAcct(row)
    local percentage = 100 * row.UsableMargin / row.Equity

    if percentage < MinUsableMargin then
        liquidate(row.AccountID)
    end
end

function liquidate(AccountID)
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()

    local minDate, maxDate = math.huge, 0
    local oldTrade, newTrade
    while row ~= nil do
        if row.AccountID == AccountID then
            if row.Time < minDate then
                minDate = row.Time
                oldTrade = row
            end
            if row.Time > maxDate then
                maxDate = row.Time
                newTrade = row
            end
        end
        row = enum:next()
    end

    if LiqType == "OldPos" then
        close(oldTrade)
        if ShowAlert then
            Signal(oldTrade.Instrument, "Old position " .. oldTrade.TradeID .. " closed")
        end
    elseif LiqType == "NewPos" then
        close(newTrade)
        if ShowAlert then
            Signal(oldTrade.Instrument, "Old position " .. newTrade.TradeID .. " closed")
        end
    elseif LiqType == "SpecAmount" then
        local list = getListForClose(AccountID, SpecAmount)

        for i = 1, #list do
            close(list[i].trade, list[i].amount)
        end
    end
end

function getListForClose(AccountID, SpecAmount)
    local list = {}

    while SpecAmount ~= 0 do
        local trade = nil
        local minDate = math.huge
        -- find oldest trade not in list
        local enum = core.host:findTable("trades"):enumerator()
        local row = enum:next()
        while row ~= nil do
            if row.AccountID == AccountID then
                local found = false
                for i = 1, #list do
                    if list[i].trade.TradeID == row.TradeID then
                        found = true
                        break
                    end
                end

                if not found and row.Time < minDate then
                    minDate = row.Time
                    trade = row
                end
            end
            row = enum:next()
        end

        -- No trades found, nothing to close
        if trade == nil then
            break
        end

        local closeAmount = math.min(trade.Lot, SpecAmount)
        SpecAmount = SpecAmount - closeAmount
        table.insert(list, {trade = trade, amount = closeAmount})
    end

    return list
end

function close(trade, amount)
    if not instance.parameters.AllowTrade then
        return;
    end
    local enum, row, valuemap, success, msg

    local canClose = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID)

    valuemap = core.valuemap()

    -- switch the direction since the order must be in oppsite direction
    valuemap.OrderType = canClose and "CM" or "OM"
    valuemap.OfferID = trade.OfferID
    valuemap.AcctID = Account
    if canClose then
        valuemap.TradeID = trade.TradeID
    end
    valuemap.BuySell = (trade.BS == "B") and "S" or "B"
    valuemap.Quantity = amount or trade.Lot

    core.host:trace(
        "Close position " ..
            trade.TradeID .. ", Instrument = " .. trade.Instrument .. ", Amount = " .. tostring(amount or trade.Lot)
    )
    success, msg = terminal:execute(101, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Closing position failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
    end
end

-- strategy calculation routine
function Update(id, source, period)
end

-- ---------------------------------------------------------
-- Signals the message
-- @param message   The rest of the message to be added to the signal
-- @param period    The number of the period
-- @param sound     The sound or nil to silent signal
-- @param email     The email address or nil to no send mail on signal
-- @param recurrentSound    Whether the sound should be played recurrently
-- ---------------------------------------------------------
function Signal(instrument, message)
    if ShowAlert then
        terminal:alertMessage(instrument, nil, "MarginLiquidator: " .. message, core.now())
    end

    if SoundFile ~= nil then
        if RecurrentSound == nil then
            RecurrentSound = false
        end
        terminal:alertSound(SoundFile, RecurrentSound)
    end
    if email ~= nil then
        local subject, text = FormatEmail(instrument, message)
        terminal:alertEmail(Email, subject, text)
    end
end

-- ---------------------------------------------------------
-- Formats the email subject and text
-- @param source   The signal source
-- @param period    The number of the period
-- @param message   The rest of the message to be added to the signal
-- ---------------------------------------------------------
function FormatEmail(instrument, message)
    --format email subject
    local subject = "MarginLiquidator: " .. message .. "(" .. instrument .. ")"
    --format email text
    local delim = "\013\010"
    local ttime = core.now()
    local dateDescr = "Time: " .. string.format("%02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min)
    local text = message .. delim .. dateDescr
    return subject, text
end
