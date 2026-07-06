-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=69982

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Highly Adaptable Pivot Strategy")
    strategy:description("")

    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("TF", "Strategy Time frame", "", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "123"
    )

    strategy.parameters:addGroup("Pivot")
    strategy.parameters:addString("PivotTF", "Pivot Time frame", "", "D1")
    strategy.parameters:setFlag("PivotTF", core.FLAG_PERIODS)
    strategy.parameters:addString("CalcMode", "Calculation mode", "The mode of pivot calculation.", "Pivot")
    strategy.parameters:addStringAlternative("CalcMode", "Classic Pivot", "", "Pivot")
    strategy.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla")
    strategy.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie")
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci")
    strategy.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor")
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci Retracement", "", "FibonacciR")

    strategy.parameters:addGroup("Actions")
    AddLevel(1, "R4")
    AddLevel(2, "R4 #2")
    AddLevel(3, "MR34")
    AddLevel(4, "MR34 #2")
    AddLevel(5, "R3")
    AddLevel(6, "R3 #2")
    AddLevel(7, "MR23")
    AddLevel(8, "MR23 #2")
    AddLevel(9, "R2")
    AddLevel(10, "R2 #2")
    AddLevel(11, "MR12")
    AddLevel(12, "MR12 #2")
    AddLevel(13, "R1")
    AddLevel(14, "R1 #2")
    AddLevel(15, "MR01")
    AddLevel(16, "MR01 #2")
    AddLevel(17, "P")
    AddLevel(18, "P #2")
    AddLevel(19, "MS01")
    AddLevel(20, "MS01 #2")
    AddLevel(21, "S1")
    AddLevel(22, "S1 #2")
    AddLevel(23, "MS12")
    AddLevel(24, "MS12 #2")
    AddLevel(25, "S2")
    AddLevel(26, "S2 #2")
    AddLevel(27, "MS23")
    AddLevel(28, "MS23 #2")
    AddLevel(29, "S3")
    AddLevel(30, "S3 #2")
    AddLevel(31, "MS34")
    AddLevel(32, "MS34 #2")
    AddLevel(33, "S4")
    AddLevel(34, "S4 #2")
    strategy.parameters:addBoolean("check_margin", "Perform margin care", "", true);
    strategy.parameters:addDouble("min_magrin", "Min margin, %", "", 0)

    CreateTradingParameters()
    strategy.parameters:addBoolean("add_log", "Add log info to signals", "", false)
    strategy.parameters:addFile(
        "log_file",
        "Log file (csv)",
        "You can open it in Excel",
        core.app_path() .. "\\log\\Highly Adaptable Pivot Strategy.csv"
    )
end

function AddOption(name)
    strategy.parameters:addStringAlternative(name, "R4", "", "R4");
    strategy.parameters:addStringAlternative(name, "MR34", "", "MR34");
    strategy.parameters:addStringAlternative(name, "R3", "", "R3");
    strategy.parameters:addStringAlternative(name, "MR23", "", "MR23");
    strategy.parameters:addStringAlternative(name, "R2", "", "R2");
    strategy.parameters:addStringAlternative(name, "MR12", "", "MR12");
    strategy.parameters:addStringAlternative(name, "R1", "", "R1");
    strategy.parameters:addStringAlternative(name, "MR01", "", "MR01");
    strategy.parameters:addStringAlternative(name, "P", "", "P");
    strategy.parameters:addStringAlternative(name, "MS01", "", "MS01");
    strategy.parameters:addStringAlternative(name, "S1", "", "S1");
    strategy.parameters:addStringAlternative(name, "MS12", "", "MS12");
    strategy.parameters:addStringAlternative(name, "S2", "", "S2");
    strategy.parameters:addStringAlternative(name, "MS23", "", "MS23");
    strategy.parameters:addStringAlternative(name, "S3", "", "S3");
    strategy.parameters:addStringAlternative(name, "MS34", "", "MS34");
    strategy.parameters:addStringAlternative(name, "S4", "", "S4");
end

function AddLevel(Number, Desc)
    strategy.parameters:addString("Action" .. Number, Desc .. " Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. Number, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. Number, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. Number, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. Number, "Close Position", "", "CLOSE")
    strategy.parameters:addStringAlternative("Action" .. Number, "Alert", "", "Alert")
    strategy.parameters:addDouble("Pips" .. Number, Desc .. " Pips", "", 0, -1000.0, 1000.0)
    strategy.parameters:addString("stop" .. Number, Desc .. " Stop", "", "no");
    strategy.parameters:addStringAlternative("stop" .. Number, "No Stop", "", "no");
    AddOption("stop" .. Number)
    strategy.parameters:addString("limit" .. Number, Desc .. " Limit", "", "no");
    strategy.parameters:addStringAlternative("limit" .. Number, "No Limit", "", "no");
    AddOption("limit" .. Number)
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "Should we allow multiple positions in the same direction.", true)
    strategy.parameters:addInteger("MultipleLimit", "Open Position Limit", "The number of open positions in the same direction allowed for each instance of this strategy. Zero for unlimited.", 0, 0, 1000)
    strategy.parameters:addInteger(
        "Throttle",
        "Position Throttle",
        "The max number of positions that can be opened within each day. Zero for unlimited.",
        0,
        0,
        1000
    )
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100)

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

local TriggerSource, PivotSource

local SoundFile = nil
local RecurrentSound = false
local ALLOWEDSIDE
local AllowMultiple
local MultipleLimit
local AllowTrade
local Offer
local CanClose
local Account
local Amount
local ShowAlert
local Email
local SendEmail
local BaseSize
local PipSize
local Throttle

local Pips = {}
local CustomID
local CalcMode
local O_PIVOT = 1
local O_CAM = 2
local O_WOOD = 3
local O_FIB = 4
local O_FLOOR = 5
local O_FIBR = 6

local PeriodDate
local P
local S1
local S2
local S3
local S4
local R1
local R2
local R3
local R4
local MS01, MS12, MS23, MS34, MR01, MR12, MR23, MR34
local add_log, log_file;
local headers = {};
local levels = {};
local labels = { "R4", "R4", "MR34", "MR34", "R3", "R3", "MR23", "MR23", "R2", "R2", "MR12", "MR12", "R1", "R1", "MR01", "MR01", "P", "P", "MS01", "MS01", "S1", "S1", "MS12", "MS12", "S2", "S2", "MS23", "MS23", "S3", "S3", "MS34", "MS34", "S4", "S4" };
local check_margin;
function MargingPass()
    if not check_margin then
        return true;
    end
    
    local Amount = instance.parameters:getInteger("Amount");
    local account = core.host:findTable("accounts"):find("AccountID", instance.parameters.Account)
    local MMR = core.host:execute("getTradingProperty", "MMR", instance.bid:instrument(), instance.parameters.Account)
    local full_margin = account.UsableMargin + account.UsedMargin;
    return (account.UsableMargin - MMR * Amount) / full_margin >= (instance.parameters.min_magrin / 100.0);
end

function Prepare(nameOnly)
    check_margin = instance.parameters.check_margin;
    CustomID = instance.parameters.CustomID
    add_log = instance.parameters.add_log;

    if instance.parameters.CalcMode == "Pivot" then
        CalcMode = O_PIVOT
    elseif instance.parameters.CalcMode == "Camarilla" then
        CalcMode = O_CAM
    elseif instance.parameters.CalcMode == "Woodie" then
        CalcMode = O_WOOD
    elseif instance.parameters.CalcMode == "Fibonacci" then
        CalcMode = O_FIB
    elseif instance.parameters.CalcMode == "Floor" then
        CalcMode = O_FLOOR
    elseif instance.parameters.CalcMode == "FibonacciR" then
        CalcMode = O_FIBR
    else
        assert(false, "Unknown calculation mode: " .. instance.parameters.CalcMode)
    end

    assert(instance.parameters.PivotTF ~= "t1", "The pivot time frame must not be tick")

    local name =
        profile:id() .. "( " .. instance.bid:name() .. "," .. instance.parameters.CalcMode .. "," .. CustomID .. " )"
    instance:name(name)

    PrepareTrading()

    if nameOnly then
        return
    end

    if add_log then
        log_file = io.open(instance.parameters.log_file, "w");
        headers[#headers + 1] = "date";
        headers[#headers + 1] = "price";
        headers[#headers + 1] = "R4";
        headers[#headers + 1] = "MR34";
        headers[#headers + 1] = "R3";
        headers[#headers + 1] = "MR23";
        headers[#headers + 1] = "R2";
        headers[#headers + 1] = "MR12";
        headers[#headers + 1] = "R1";
        headers[#headers + 1] = "MR01";
        headers[#headers + 1] = "P";
        headers[#headers + 1] = "MS01";
        headers[#headers + 1] = "S1";
        headers[#headers + 1] = "MS12";
        headers[#headers + 1] = "S2";
        headers[#headers + 1] = "MS23";
        headers[#headers + 1] = "S3";
        headers[#headers + 1] = "MS34";
        headers[#headers + 1] = "S4";
        headers[#headers + 1] = "Buy";
        headers[#headers + 1] = "Sell";
        headers[#headers + 1] = "Close";
        for i, header in ipairs(headers) do
            log_file:write(header .. ";")
        end
        log_file:write("\n");
    end

    PivotSource = ExtSubscribe(1, nil, instance.parameters.PivotTF, instance.parameters.Type == "Bid", "bar")
    PipSize = PivotSource.close:pipSize()
    if (instance.parameters.TF == "t1") then
        TriggerSource = ExtSubscribe(2, nil, "t1", instance.parameters.Type == "Bid", "close")
    else
        TriggerSource = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")
    end

    for i = 1, 34 do
        local level = {};
        level.pips = instance.parameters:getDouble("Pips" .. i) * PipSize;
        level.action = instance.parameters:getString("Action" .. i);
        level.stop = instance.parameters:getString("stop" .. i);
        level.limit = instance.parameters:getString("limit" .. i);
        level.label = labels[i];
        levels[#levels + 1] = level;
    end
end

function UpdateStream(period)
    CalcLevels(PivotSource, period)
end

function PrepareTrading()
    AllowMultiple = instance.parameters.AllowMultiple
    MultipleLimit = instance.parameters.MultipleLimit
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE
    Throttle = instance.parameters.Throttle

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
end
local log_values = {};
function DumpLog()
    if log_file ~= nil then
        for i, header in ipairs(headers) do
            log_file:write(tostring(log_values[header]) .. ";");
        end
        log_file:write("\n");
        log_file:flush();
    end
end
function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not (checkReady("trades")) or not (checkReady("orders")) then
            return
        end
    end
    if log_file ~= nil then
        log_values = {};
        log_values["date"] = core.formatDate(core.host:execute("getServerTime"));
    end
    if (id == 1) then
        -- pivot source so calculate pivot levels.
        CalcLevels(PivotSource, period)
    elseif (id == 2) then
        -- trigger source so check the actions
        if (INDEX == nil) then
            -- we don't have the pivots calculated yet
            -- find the latest period of the pivot source that is closed.
            local pp = PivotSource:size() - 2
            if (pp - 1 < PivotSource:first()) then
                -- not enough data to calculate pivot.
                DumpLog();
                return
            else
                -- got enough data, calculate!
                CalcLevels(PivotSource, pp)
                if (INDEX == nil) then
                    -- if this happens, chances are the period chosen was non-trading so go back one more.
                    CalcLevels(PivotSource, pp - 1)
                end
            end
        end

        if (INDEX == nil) then
            -- if we still don't have pivot data then I don't know.
            DumpLog();
            return
        end

        if (TriggerSource:isBar()) then
            stream = TriggerSource.close
        else
            stream = TriggerSource
        end
        for i, level in ipairs(levels) do
            if core.crosses(stream, level.value, period) then
                ACTION(i, level.action, level.label, period)
            end
        end
    end
    DumpLog();
end

function CalcLevels(ref, period)
    if (period - 1 < ref:first()) then
        -- not enough data
        return
    end

    if (ref:serial(period) == INDEX) then
        -- already calculated;
        return
    end

    -- if we are daily or less, ignore saturdays.
    if (ref:barSize() ~= "M1" and ref:barSize() ~= "W1") then
        offset = core.host:execute("getTradingDayOffset")
        if (core.isnontrading(ref:date(period), offset)) then
            return
        end
    end

    local prev_i = period
    INDEX = ref:serial(period)

    -- calculate the pivot level
    if CalcMode == O_PIVOT or CalcMode == O_FIB or CalcMode == O_FLOOR then
        P = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3
    elseif CalcMode == O_CAM then
        P = ref.close[prev_i]
    elseif CalcMode == O_FIBR then
        P = (ref.high[prev_i] + ref.low[prev_i]) / 2
    elseif CalcMode == O_WOOD then
        local open
        if (prev_i == ref:size() - 1) then
            -- for a live day take close as open of the next period
            open = ref.open[prev_i]
        else
            open = ref.open[prev_i + 1]
        end
        P = (ref.high[prev_i] + ref.low[prev_i] + open * 2) / 4
    end

    local h, l, r, p
    h = ref.high[prev_i]
    l = ref.low[prev_i]
    r = h - l
    p = P
    local values = {};
    values["P"] = P;
    -- calculate the other levels
    if CalcMode == O_PIVOT then
        values["R4"] = p + r * 3
        values["R3"] = p + r * 2
        values["R2"] = p + r
        values["R1"] = p * 2 - l

        values["S1"] = p * 2 - h
        values["S2"] = p - r
        values["S3"] = p - r * 2
        values["S4"] = p - r * 3
    elseif CalcMode == O_CAM then
        values["R4"] = p + r * 1.1 / 2
        values["R3"] = p + r * 1.1 / 4
        values["R2"] = p + r * 1.1 / 6
        values["R1"] = p + r * 1.1 / 12

        values["S1"] = p - r * 1.1 / 12
        values["S2"] = p - r * 1.1 / 6
        values["S3"] = p - r * 1.1 / 4
        values["S4"] = p - r * 1.1 / 2
    elseif CalcMode == O_WOOD then
        values["R4"] = h + (2 * (p - l) + r)
        values["R3"] = h + 2 * (p - l)
        values["R2"] = p + r
        values["R1"] = p * 2 - l

        values["S1"] = p * 2 - h
        values["S2"] = p - r
        values["S3"] = l - 2 * (h - p)
        values["S4"] = l - (r + 2 * (h - p))
    elseif CalcMode == O_FIB then
        values["R4"] = p + 1.618 * (h - l)
        values["R3"] = p + 1 * (h - l)
        values["R2"] = p + 0.618 * (h - l)
        values["R1"] = p + 0.382 * (h - l)

        values["S1"] = p - 0.382 * (h - l)
        values["S2"] = p - 0.618 * (h - l)
        values["S3"] = p - 1 * (h - l)
        values["S4"] = p - 1.618 * (h - l)
    elseif CalcMode == O_FLOOR then
        values["R4"] = 0
        values["R3"] = h + (p - l) * 2
        values["R2"] = p + r
        values["R1"] = p * 2 - l

        values["S1"] = p * 2 - h
        values["S2"] = p - r
        values["S3"] = l - (h - p) * 2
        values["S4"] = 0
    elseif CalcMode == O_FIBR then
        values["R4"] = l + (h - l) * 1.272
        values["R3"] = l + (h - l) * 1.0
        values["R2"] = l + (h - l) * 0.764
        values["R1"] = l + (h - l) * 0.618

        values["S1"] = l + (h - l) * 0.382
        values["S2"] = l + (h - l) * 0.236
        values["S3"] = l + (h - l) * 0.0
        values["S4"] = l + (h - l) * -0.272
    end

    -- calculate mid points
    values["MR01"] = 0.5 * (values["P"] + values["R1"])
    values["MR12"] = 0.5 * (values["R1"] + values["R2"])
    values["MR23"] = 0.5 * (values["R2"] + values["R3"])
    values["MR34"] = 0.5 * (values["R3"] + values["R4"])
    values["MS01"] = 0.5 * (values["P"] + values["S1"])
    values["MS12"] = 0.5 * (values["S1"] + values["S2"])
    values["MS23"] = 0.5 * (values["S2"] + values["S3"])
    values["MS34"] = 0.5 * (values["S3"] + values["S4"])

    for i, level in ipairs(levels) do
        level.value = values[level.label] + level.pips * PivotSource:pipSize();
        level.stop_value = values[level.stop];
        level.limit_value = values[level.limit];
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1))
    elseif cookie == 201 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. message, instance.bid:date(instance.bid:size() - 1))
    end
end

function ACTION(Flag, action, Line, period)
    if action == "NO" then
        return
    elseif action == "BUY" and MargingPass() then
        log_values["Buy"] = "true";
        BUY(levels[Flag].stop_value, levels[Flag].limit_value);
        Signal("Pivot Level " .. Line .. " Crossed - Buy")
    elseif action == "SELL" and MargingPass() then
        log_values["Sell"] = "true";
        SELL(levels[Flag].stop_value, levels[Flag].limit_value);
        Signal("Pivot Level " .. Line .. " Crossed - Sell")
    elseif action == "CLOSE" then
        log_values["Close"] = "true";
        if AllowTrade then
            if haveTrades("B") then
                exitTrade("B")
                Signal("Pivot Level " .. Line .. " Crossed - Close Long")
            end

            if haveTrades("S") then
                exitTrade("S")
                Signal("Pivot Level " .. Line .. " Crossed - Close Short")
            end
        else
            Signal("Pivot Level " .. Line .. " Crossed - Close Trades!")
        end
    elseif action == "Alert" then
        Signal("Pivot Level " .. Line .. " Crossed!")
    end
end

-- ---------------------------------------------------------
-- Trace helper function
-- ---------------------------------------------------------
function ExtTrace(message)
    local theDate = core.dateToTable(core.host:execute("convertTime", 1, 4, math.max(instance.bid:date(instance.bid:size() - 1), instance.ask:date(instance.ask:size() - 1))))
    core.host:trace(string.format("%d/%02d/%02d %02d:%02d:%02d ", theDate.year, theDate.month, theDate.day, theDate.hour, theDate.min, theDate.sec) .. " " .. message)
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function BUY(stop, limit)
    if AllowTrade then
        if ALLOWEDSIDE == "Sell" then
            -- we are not allowed buys.
            return
        end

        enter("B", stop, limit)
    end
end

function SELL(stop, limit)
    if AllowTrade then
        if ALLOWEDSIDE == "Buy" then
            -- we are not allowed sells.
            return
        end

        enter("S", stop, limit)
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
    while row ~= nil do
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and
                (row.BS == BuySell or BuySell == nil)
         then
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
    while (row ~= nil) do
        if
            row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and
                (row.BS == BuySell or BuySell == nil)
         then
            found = true
            break
        end

        row = enum:next()
    end

    return found
end

local lastTradeTime = 0
local throttleCount = 0
function CheckThrottle()
    if (Throttle > 0) then
        -- if we have to check the throttle.
        local now = core.host:execute("getServerTime")
        local diff = now - lastTradeTime
        if (diff > 1) then
            -- throttle exceeded, reset.

            lastTradeTime = math.floor(now)
            throttleCount = 1
            return true
        end

        -- we are still within the throttle window. Make sure we haven't exceeded the throttle.
        if (throttleCount < Throttle) then
            throttleCount = throttleCount + 1
            return true
        end

        -- hit the throttle already.
        return false
    end

    -- throttle disabled.
    return true
end

-- enter into the specified direction
function enter(BuySell, stop, limit)
    if not (AllowTrade) then
        return true
    end

    -- do not enter if position in the
    -- specified direction already exists
    local count = tradesCount(BuySell)
    if (AllowMultiple) then
        -- if we allow multiple trades
        if (MultipleLimit > 0 and (count >= MultipleLimit)) then
            -- we have exceeded our multiple limit count.
            return true
        end
    else
        if count > 0 then
            -- if we have more than one trade and we aren't allowed multiple, abort.
            return true
        end
    end

    if (CheckThrottle()) then
        return MarketOrder(BuySell, stop, limit)
    end

    return false
end

-- enter into the specified direction
function MarketOrder(BuySell, stop, limit)
    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID

    valuemap.RateStop = stop;
    valuemap.RateLimit = limit;

    success, msg = terminal:execute(200, valuemap)

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
function exitTrade(BS)
    if not (AllowTrade) then
        return true
    end

    local valuemap, success, msg
    valuemap = core.valuemap()

    -- switch the direction since the order must be in oppsite direction
    if BS == "B" then
        BuySell = "S"
    else
        BuySell = "B"
    end
    valuemap.OrderType = "CM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.NetQtyFlag = "Y" -- this forces all trades to close in the opposite direction.
    valuemap.BuySell = BuySell
    valuemap.CustomID = CustomID
    success, msg = terminal:execute(201, valuemap)

    if not (success) then
        core.host:trace("Close order failed" .. msg)
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Close order failed" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    return true
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
