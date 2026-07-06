-- Id: 23842
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3402&sid=71ddedb091ef86946281ab5ab0a91812

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

function Init()
    strategy:name("Three MA Strategy")
    strategy:description("Three MA Strategy")
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendEmail,Email");

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addBoolean("AllowTicks", "Allow Ticks", "", false)

    strategy.parameters:addGroup("Fast MA Calculation")
    PARAMETARS(1, 10)
    strategy.parameters:addGroup("Mid MA Calculation")
    PARAMETARS(2, 50)
    strategy.parameters:addGroup("Slow MA Calculation")
    PARAMETARS(3, 200)

    strategy.parameters:addGroup("Price Type")
    strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addBoolean("exit_pivot", "Exit on Pivot cross", "", false);
    strategy.parameters:addString("CalcMode", "Pivot Mode", "", "Fibonacci");
    strategy.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    strategy.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    strategy.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    strategy.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci Retracement", "", "FibonacciR");

    Trading_Parameters()
end

function AddAverages(id, name, default)
    strategy.parameters:addString(id, name, "", default);
    strategy.parameters:addStringAlternative(id, "MVA", "", "MVA");
    strategy.parameters:addStringAlternative(id, "EMA", "", "EMA");
    strategy.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative(id, "HMA", "", "HMA");
    strategy.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative(id, "T3", "", "T3");
    strategy.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative(id, "Median", "", "Median");
    strategy.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative(id, "REMA", "", "REMA");
    strategy.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    strategy.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    strategy.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    strategy.parameters:addStringAlternative(id, "HPF", "", "HPF");
    strategy.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
end

function PARAMETARS(id, Period)
    AddAverages("Method" .. id, "Method", "", "MVA")
    strategy.parameters:addInteger("Period" .. id, "Period", "", Period)
end

function CreateAverates(method, source, period)
    if method == "MVA" or method == "EMA" or method == "ARSI" 
        or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

-- Parameters block

local gSource = nil -- the source stream

--TODO: Add variable(s) for your strategy if needed
local Method = {}
local Period = {}
local first = 1
local indicator = {}

local SoundFile = nil
local RecurrentSound = false
local ALLOWEDSIDE
local AllowMultiple
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
local pivot;

-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    local AllowTicks
    AllowTicks = instance.parameters.AllowTicks
    if (not (AllowTicks)) then
        assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks.")
    end

    Initialization()
    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    if instance.parameters.exit_pivot then
        pivot = core.indicators:create("PIVOT", gSource, "D1", instance.parameters.CalcMode, "HIST");
    end

    local i
    for i = 1, 3, 1 do
        Method[i] = instance.parameters:getString("Method" .. i)
        Period[i] = instance.parameters:getInteger("Period" .. i)

        indicator[i] = CreateAverates(Method[i], gSource.close, Period[i]);
        first = math.max(first, indicator[i].DATA:first())
    end

    if (Period[2] <= Period[1]) then
        error("The Fast MA period must be smaller than Mid MA period")
    end

    if (Period[3] <= Period[2]) then
        error("The Mid MA period must be smaller than Slow MA period")
    end
end

function IsPivotBuyExit(period)
    if pivot == nil then
        return false;
    end
    local trigger;
    if pivot.R4[period] < gSource.close[period] then
        trigger = pivot.R4[period];
    elseif pivot.R3[period] < gSource.close[period] then
        trigger = pivot.R3[period];
    elseif pivot.R2[period] < gSource.close[period] then
        trigger = pivot.R2[period];
    elseif pivot.R1[period] < gSource.close[period] then
        trigger = pivot.R1[period];
    else
        return false;
    end
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.AccountID == Account 
            and row.OfferID == Offer 
            and row.BS == "B"
        then
            if row.Open < trigger then
                return true;
            end
        end

        row = enum:next();
    end
    return false;
end

function IsPivotSellExit(period)
    if pivot == nil then
        return false;
    end
    local trigger;
    if pivot.S4[period] > gSource.close[period] then
        trigger = pivot.S4[period];
    elseif pivot.S3[period] > gSource.close[period] then
        trigger = pivot.S3[period];
    elseif pivot.S2[period] > gSource.close[period] then
        trigger = pivot.S2[period];
    elseif pivot.S1[period] > gSource.close[period] then
        trigger = pivot.S1[period];
    else
        return false;
    end
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.AccountID == Account 
            and row.OfferID == Offer 
            and row.BS == "S"
        then
            if row.Open > trigger then
                return true;
            end
        end

        row = enum:next();
    end
    return false;
end

function ExtUpdate(id, source, period)
    if period < first or id ~= 1 then
        return
    end

    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end

    indicator[1]:update(core.UpdateLast)
    indicator[2]:update(core.UpdateLast)
    indicator[3]:update(core.UpdateLast)
    if pivot ~= nil then
        pivot:update(core.UpdateLast);
    end

    if not indicator[1].DATA:hasData(period) or not indicator[1].DATA:hasData(period - 1) then
        return
    end

    if not indicator[2].DATA:hasData(period) or not indicator[2].DATA:hasData(period - 1) then
        return
    end

    if not indicator[3].DATA:hasData(period) or not indicator[3].DATA:hasData(period - 1) then
        return
    end

    if core.crossesOver(indicator[1].DATA, indicator[2].DATA, period) 
        and indicator[2].DATA[period] > indicator[3].DATA[period]
    then
        if haveTrades("B") and not AllowMultiple then
            return
        end

        if SIDE == "SHORT" then
            return
        end

        if ShowAlert then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW))
        end
        if SoundFile ~= nil then
            terminal:alertSound(SoundFile, RecurrentSound)
        end

        if Email ~= nil then
            terminal:alertEmail(Email, "Enter Long", profile:id() .. "(" .. instance.bid:instrument() .. ")" ..
                ", " .. instance.bid:instrument() .. ", " .. instance.bid[NOW] .. ", " .. "Enter Long" .. ", " .. instance.bid:date(NOW))
        end

        if AllowTrade then
            if haveTrades("S") then
                exit("S")
            end
            enter("B")
        end
    elseif core.crossesUnder(indicator[1].DATA, indicator[2].DATA, period) 
        and indicator[2].DATA[period] < indicator[3].DATA[period]
    then
        if haveTrades("S") and not AllowMultiple then
            return
        end

        if SIDE == "LONG" then
            return
        end

        if ShowAlert then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW))
        end
        if SoundFile ~= nil then
            terminal:alertSound(SoundFile, RecurrentSound)
        end

        if Email ~= nil then
            terminal:alertEmail(Email, "Enter Short", profile:id() .. "(" .. instance.bid:instrument() .. ")" ..
                ", " .. instance.bid:instrument() .. ", " .. instance.bid[NOW] .. ", " .. "Enter Short" .. ", " .. instance.bid:date(NOW))
        end

        if AllowTrade then
            if haveTrades("B") then
                exit("B")
            end
            enter("S")
        end
    elseif core.crossesOver(indicator[1].DATA, indicator[2].DATA, period)
        or IsPivotBuyExit(period)
    then
        if ShowAlert then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Close Short", instance.bid:date(NOW))
        end
        if SoundFile ~= nil then
            terminal:alertSound(SoundFile, RecurrentSound)
        end

        if Email ~= nil then
            terminal:alertEmail(Email, "Close Short", profile:id() .. "(" .. instance.bid:instrument() .. ")" .. ", " ..
                instance.bid:instrument() .. ", " .. instance.bid[NOW] .. ", " .. "Close Short" .. ", " .. instance.bid:date(NOW))
        end

        if haveTrades("S") then
            if AllowTrade then
                exit("S")
            end
        end
    elseif core.crossesUnder(indicator[1].DATA, indicator[2].DATA, period)
        or IsPivotSellExit(period)
    then
        if ShowAlert then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Close Long", instance.bid:date(NOW))
        end
        if SoundFile ~= nil then
            terminal:alertSound(SoundFile, RecurrentSound)
        end

        if Email ~= nil then
            terminal:alertEmail(Email, "Close Long", profile:id() .. "(" .. instance.bid:instrument() .. ")" .. ", " ..
                instance.bid:instrument() .. ", " .. instance.bid[NOW] .. ", " .. "Close Long" .. ", " .. instance.bid:date(NOW))
        end

        if haveTrades("B") then
            if AllowTrade then
                exit("B")
            end
        end
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BUY()
    if AllowTrade then
        if haveTrades("B") and not AllowMultiple then
            exit("S")
            Signal("Close Short")

            return
        end

        if ALLOWEDSIDE == "Sell" then
            if haveTrades("S") then
                exit("S")
                Signal("Close Short")
            end

            return
        end

        if haveTrades("S") then
            exit("S")
            Signal("Close Short")
        end
        enter("B")
        Signal("Open Long")
    elseif ShowAlert then
        Signal("Up Trend")
    end
end

function SELL()
    if AllowTrade then
        if haveTrades("S") and not AllowMultiple then
            exit("B")
            Signal("Close Long")

            return
        end

        if ALLOWEDSIDE == "Buy" then
            if haveTrades("B") then
                exit("B")
                Signal("Close Long")
            end

            return
        end

        if haveTrades("B") then
            exit("B")
            Signal("Close Long")
        end
        enter("S")
        Signal("Open Short")
    else
        Signal("Down Trend")
    end
end

function Trading_Parameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
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

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100)
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

function Initialization()
    AllowMultiple = instance.parameters.AllowMultiple
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
    local rc
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true
    else
        rc = core.host:execute("isTableFilled", table)
    end
    return rc
end

function tradesCount(BuySell)
    local enum, row
    local count = 0
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while count == 0 and row ~= nil do
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

-- enter into the specified direction
function enter(BuySell)
    if not (AllowTrade) then
        return true
    end

    -- do not enter if position in the
    -- specified direction already exists
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

    success, msg = terminal:execute(100, valuemap)

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

-- exit from the specified direction
function exit(BuySell, use_net)
    if not (AllowTrade) then
        return true
    end

    if use_net == true then
        local valuemap, success, msg
        if tradesCount(BuySell) > 0 then
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

            if not(success) then
               terminal:alertMessage(
                   instance.bid:instrument(),
                   instance.bid[instance.bid:size() - 1],
                   "Open order failed"..msg,
                   instance.bid:date(instance.bid:size() - 1)
               )
                return false
            end
            return true
        end
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if row.BS == BuySell and row.OfferID == Offer then
                local valuemap = core.valuemap();
                valuemap.BuySell = row.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = row.AccountID;
                valuemap.TradeID = row.TradeID;
                valuemap.Quantity = row.Lot;
                local success, msg = terminal:execute(101, valuemap);
            end
        row = enum: next();
        end
    end
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
