-- Id: 1682
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
-- Intoduce the strategy to the host application (for example, Marketscope).
-- The function is called once when the host application initially loads the strategy.
function Init()
    -- User-friendly name and the description
    strategy:name("ADX DMI SAR Signal Strategy")
    strategy:description("ADX DMI SAR Signal Strategy")
    strategy:setTag(
        "NonOptimizableParameters",
        "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert,Account,CanTrade,Email,SendEmail"
    )
    strategy:setTag("Version", "2")

    -- Fast and slow moving average parameters

    strategy.parameters:addGroup("Reset")
    strategy.parameters:addBoolean("RESET", "Reset if there is no active signal  ", "", true)

    strategy.parameters:addGroup("ADX")
    strategy.parameters:addInteger("ADX", "ADX Period", "ADX Period", 14, 2, 1000)
    strategy.parameters:addInteger("ADXL", "ADX Level", "ADX Level", 20, 0, 100)

    strategy.parameters:addGroup("DMI")
    strategy.parameters:addInteger("DMI", "DMI Period", "DMI Period", 14, 1, 1000)
    strategy.parameters:addInteger("DMIL", "DMI Level", "DMI Level", 17, 0, 100)

    strategy.parameters:addGroup("SAR")
    strategy.parameters:addDouble("Step", "SAR Step", "", 0.02, 0.001, 1)
    strategy.parameters:addDouble("Max", "SAR Max", "", 0.2, 0.001, 10)

    -- Price subscription parameters (bid or ask price, time frame)
    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("PT", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("PT", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("PT", "Ask", "", "Ask")
    strategy.parameters:addString("TF", "Time Frame", "", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    -- Alert parameters
    strategy.parameters:addGroup("Alerts")
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)

    -- Trading parameters
    strategy.parameters:addGroup("Trading")
    strategy.parameters:addBoolean("CanTrade", "Allow Trading", "", false)
    strategy.parameters:setFlag("CanTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("LotSize", "Size of the trade in lots", "", 1, 1, 100)
    strategy.parameters:addInteger(
        "Stop",
        "Distance in pips for the stop order",
        "Use 0 to do not use stops",
        0,
        0,
        1000
    )
    strategy.parameters:addInteger(
        "Limit",
        "Distance in pips for the limit order",
        "Use 0 to do not use limits",
        0,
        0,
        1000
    )

    strategy.parameters:addBoolean("SendEmail", "Send email", "", false)
    strategy.parameters:addString("Email", "Email address", "", "")
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- The global variables
local Email
local BAR = nil -- the price history we subscribed for
local first  -- the index of the oldest period where we can check whether moving averages has been crossed
local CanTrade  -- flag indicating whether we can trade
local Amount  -- the amount for the trade
local Account  -- the account to trade on
local Stop  -- the stop order level expressed in pips or 0 if no stop must be used
local Limit  -- the limit order level expressed in pips or 0 if no stop must be used
local CanClose  -- the flag indicating whether "close market" orders is allowed
local CanStop
local OfferID  -- the internal indentifier of the instrument (required for the orders)
local SoundFile  -- the sound file name or nil if no sound must be played

local ADX, ADXP, ADXL
local DMI, DMIP, DMIL
local SAR, Step, Max
local RESET

local ADXFlag
local DMIFlag
local DIPFlag
local DIMFlag
local SARFlag
local FLAG

-- Prepare all the data.
-- The function is called once when the strategy is about to be started.
function Prepare()
    -- check moving average parameters
    ADXP = instance.parameters.ADX
    ADXL = instance.parameters.ADXL
    DMIP = instance.parameters.DMI
    DMIL = instance.parameters.DMIL
    Step = instance.parameters.Step
    Max = instance.parameters.Max

    RESET = instance.parameters.RESET

    local SendEmail = instance.parameters.SendEmail
    if SendEmail then
        Email = instance.parameters.Email
    else
        Email = nil
    end
    assert(not (SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified")

    -- check alerts settings
    local ShowAlert
    ShowAlert = instance.parameters.ShowAlert
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end
    assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified")

    -- check whether the strategy is allowed to trade
    CanTrade = instance.parameters.CanTrade
    if CanTrade then
        -- Prepare the common information (account, stop, limit and OfferID (internal id of the instrument).
        Account = instance.parameters.Account
        Stop = math.floor(instance.parameters.Stop + 0.5)
        Limit = math.floor(instance.parameters.Limit + 0.5)
        local instrument = instance.bid:instrument()
        OfferID = core.host:findTable("offers"):find("Instrument", instrument).OfferID
        -- check whether stop and limit orders are allowed
        CanStop = core.host:execute("getTradingProperty", "canCreateStopLimit", instrument, Account)
        -- Check whether close market orders are allowed
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instrument, Account)
        -- And finally turn "in lots" amount into the absolule value.
        Amount =
            instance.parameters.LotSize * core.host:execute("getTradingProperty", "baseUnitSize", instrument, Account)
    end
    -- name the indicator
    local name =
        profile:id() ..
        "(" ..
            instance.bid:name() ..
                "," .. ADXP .. ", " .. ADXL .. "," .. DMIP .. ", " .. DMIL .. ", " .. Step .. ", " .. Max .. ")"
    instance:name(name)
    -- setup the signal. pay attention, we pass "ShowAlert" (value initially taken from the instance.parameters.ShowAlert)
    -- here, so, we don't check whether alerts are requested anymore.
    ExtSetupSignal(name, ShowAlert)
    ExtSetupSignalMail(name)

    -- and finally subscribe for the ticks of the instrument the user initially chosen to run the strategy for to
    -- have our strategy activated once.
    ExtSubscribe(1, nil, "t1", true, "tick")
end

-- the function is called every time when any subscribed price is changed. For tick subscribtions the function is called
-- for every tick, for the bar subscribtions the function is called when the candle is closed (in other words, when
-- the first tick of the next candle appears).
function ExtUpdate(id, source, period)
    if id == 1 and BAR == nil then
        -- and get the oldest index of the bar we can work at
        -- first =1+ math.max(ADXPeriod, AroonPeriod);
        -- our tick subscribtion. do it on the first tick if the
        -- user chosen subscribtion has not been not made yet.

        -- subscribe for the user chosen timeframe/to close prices
        BAR = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")
        -- create indicators
        ADX = core.indicators:create("ADX", BAR, ADXP)
        DMI = core.indicators:create("DMI", BAR, DMIP)
        SAR = core.indicators:create("SAR", BAR, Step, Max)
    elseif id == 2 then
        -- on the user chosen subscription (can be either tick or bar subscribtion).

        -- update indicators
        ADX:update(core.UpdateLast)
        DMI:update(core.UpdateLast)
        SAR:update(core.UpdateLast)

        if period > math.max(ADX.DATA:first(), DMI.DATA:first(), SAR.UP:first(), SAR.DN:first()) then
            if core.crossesOver(DMI.DIP, DMI.DIM, period) then
                DMIFlag = "Buy"
            end
            if core.crossesUnder(DMI.DIP, DMI.DIM, period) then
                DMIFlag = "Sell"
            end

            if core.crossesOver(DMI.DIP, DMIL, period) then
                DIPFlag = "Strong"
            end
            if core.crossesUnder(DMI.DIP, DMIL, period) then
                DIPFlag = "Weak"
            end

            if core.crossesOver(DMI.DIM, DMIL, period) then
                DIMFlag = "Strong"
            end
            if core.crossesUnder(DMI.DIM, DMIL, period) then
                DIMFlag = "Weak"
            end

            if core.crossesOver(DMI.DIP, DMI.DIM, period) then
                DMIFlag = "Buy"
            end
            if core.crossesUnder(DMI.DIP, DMI.DIM, period) then
                DMIFlag = "Sell"
            end

            if core.crossesOver(ADX.DATA, ADXL, period) then
                ADXFlag = "Strong"
            end
            if core.crossesUnder(ADX.DATA, ADXL, period) then
                ADXFlag = "Weak"
            end

            if SAR.DN:hasData(period) then
                SARFlag = "DownTrend"
            end
            if SAR.UP:hasData(period) then
                SARFlag = "UpTrend"
            end

            if RESET then
                if ADXFlag == "Weak" then
                    FLAG = nil
                end

                if DIPFlag == "Weak" and DIMFlag == "Weak" then
                    FLAG = nil
                end
            end

            if
                ADXFlag == "Strong" and DMIFlag == "Buy" and FLAG ~= "Buy" and DIPFlag == "Strong" and
                    SARFlag == "UpTrend"
             then
                FLAG = "Buy"

                -- show the signal
                ExtSignal(instance.ask, instance.ask:size() - 1, "BUY", SoundFile, Email)
                -- and if the trading is allowed - either close all sell positions or
                -- open the buy one
                if CanTrade then
                    if not (close(true)) then
                        open(false)
                    end
                end
            end

            if
                ADXFlag == "Strong" and DMIFlag == "Sell" and FLAG ~= "Sell" and DIMFlag == "Strong" and
                    SARFlag == "DownTrend"
             then
                FLAG = "Sell"
                ExtSignal(instance.bid, instance.bid:size() - 1, "SELL", SoundFile, Email)
                -- and if the trading is allowed - either close all buy positions or
                -- open the sell one
                if CanTrade then
                    if not (close(false)) then
                        open(true)
                    end
                end
            end
        end
    end
end

-- The function opens the position in the chosen direction.
-- Account, amount and instrument (aka offer) are predefined in
-- the Prepare() function.
function open(sell)
    -- create and fill value map with the predefined order parameters
    local valuemap
    valuemap = core.valuemap()
    valuemap.Command = "CreateOrder" -- command: create new order
    valuemap.OrderType = "OM" -- order type: open market (execute immediatelly, at any available market price)
    valuemap.OfferID = OfferID -- instrument
    valuemap.AcctID = Account
    valuemap.Quantity = Amount

    -- fill the side and calculate stops and limits.
    -- the Stop and Limit global variables are expressed in pips.
    -- pay attention that we calculate prices against different prices
    -- to avoid setting the stop or limit inside the spread.
    -- Also, the stop and limit offset depends on the trade direction. For example
    -- the stop for a buy position is below the price while the stop for a sell position
    -- is above the price.
    local side, limit, stop
    if sell then
        side = "S"
        stop = instance.ask[instance.ask:size() - 1] + Stop * instance.ask:pipSize()
        limit = instance.bid[instance.ask:size() - 1] - Limit * instance.bid:pipSize()
    else
        side = "B"
        stop = instance.bid[instance.ask:size() - 1] - Stop * instance.ask:pipSize()
        limit = instance.ask[instance.ask:size() - 1] + Limit * instance.bid:pipSize()
    end

    -- fill side and stop/limit orders in the value map
    valuemap.BuySell = side

    if Stop > 0 and CanStop then
        valuemap.RateStop = stop
    end

    if Limit > 0 and CanStop then
        valuemap.RateLimit = limit
    end

    -- and, finally, execute it
    local success, msg
    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)
end

-- close all the positions in the specified direction
function close(sell)
    local enum, row, valuemap, side, closed
    local valuemap

    -- just prepare the name of the direction ("S" for sell and "B" for buy).
    if sell then
        side = "S"
    else
        side = "B"
    end

    -- the flag indicating whether at least one position is closed.
    closed = false

    -- get a enumerator for the "open trades" trading table
    enum = core.host:findTable("trades"):enumerator()

    -- and scan trough all table rows. one row is one trade.
    while true do
        row = enum:next()
        if row == nil then
            break
        end

        -- if trade was placed for chosen account and instrument
        -- and the trade is in the requested side - close it
        if row.AccountID == Account and row.OfferID == OfferID and row.BS == side then
            -- use different close models depending on the account type
            if CanClose then
                -- non-NFA accounts, can use Market Close order
                valuemap = core.valuemap()
                valuemap.Command = "CreateOrder"
                valuemap.OrderType = "CM" -- close market order
                valuemap.OfferID = OfferID
                valuemap.AcctID = Account
                valuemap.Quantity = row.Lot -- the size is required because we can close the position partially
                valuemap.TradeID = row.TradeID -- the trade must be referenced int he close order
                -- the side of the close order must be opposite to the side of the trade.
                if row.BS == "B" then
                    valuemap.BuySell = "S"
                else
                    valuemap.BuySell = "B"
                end
                -- and execute
                local success, msg
                success, msg = terminal:execute(200, valuemap)
                assert(success, msg)
            else
                -- NFA accounts. We cannot call close orders but can
                -- execute an opposite open order. Since NFA accounts can
                -- never be hedging accounts, the opposite open order
                -- closes the existing positions first.
                valuemap = core.valuemap()
                valuemap.OrderType = "OM"
                valuemap.Command = "CreateOrder"
                valuemap.OfferID = OfferID
                valuemap.AcctID = Account
                valuemap.Quantity = row.Lot
                if row.BS == "B" then
                    valuemap.BuySell = "S"
                else
                    valuemap.BuySell = "B"
                end
                local success, msg
                success, msg = terminal:execute(200, valuemap)
                assert(success, msg)
            end
            -- we closed the position, so we should not open anything.
            closed = true
        end
    end
    return closed
end

-- use the helpers
dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
