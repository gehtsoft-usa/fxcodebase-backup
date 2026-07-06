-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=70209

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+


-- START OF USER DEFINED SECTION
local STRATEGY_NAME = "Highest high and lowest low of the candle Strategy";
function CreateParameters() 
    strategy.parameters:addInteger("period", "Period", "", 14)
end

local indi;
function CreateEntryIndicators(source)
    indi = core.indicators:create("EMA", source, instance.parameters.period);
end

function UpdateIndicators()
    indi:update(core.UpdateLast);
end

function OnNewBar(source, period)
    if source.close[period] > indi.DATA[period] then
        local enum = core.host:findTable("orders"):enumerator()
        local row = enum:next()
        while row ~= nil do
            if row.AccountID == Account and row.Instrument == main_source:instrument() and row.BS == "B" then
                local valuemap = core.valuemap()
                valuemap.Command = "DeleteOrder"
                valuemap.OrderID = row.OrderID
                success, msg = terminal:execute(4, valuemap)
                if not (success) then
                    terminal:alertMessage(
                        instance.bid:instrument(),
                        instance.bid[NOW],
                        "Failed delete order " .. row.OrderID .. ":" .. msg,
                        instance.bid:date(NOW)
                    )
                end
            end
            row = enum:next()
        end
    else
        local enum = core.host:findTable("orders"):enumerator()
        local row = enum:next()
        while row ~= nil do
            if row.AccountID == Account and row.Instrument == main_source:instrument() and row.BS == "S" then
                local valuemap = core.valuemap()
                valuemap.Command = "DeleteOrder"
                valuemap.OrderID = row.OrderID
                success, msg = terminal:execute(4, valuemap)
                if not (success) then
                    terminal:alertMessage(
                        instance.bid:instrument(),
                        instance.bid[NOW],
                        "Failed delete order " .. row.OrderID .. ":" .. msg,
                        instance.bid:date(NOW)
                    )
                end
            end
            row = enum:next()
        end
    end
end

function IsEntryLong(source, period)
    if not indi.DATA:hasData(period - 1) then
        return false;
    end
    return source.close[period] > indi.DATA[period] and source.close[period] < source.open[period];
end
function IsEntryShort(source, period)
    if not indi.DATA:hasData(period - 1) then
        return false;
    end
    return source.close[period] < indi.DATA[period] and source.close[period] > source.open[period];
end
function IsExitLong(source, period)
    return false;
end
function IsExitShort(source, period)
    return false;
end
-- END OF USER DEFINED SECTION

function Init()
    strategy:name(STRATEGY_NAME);
    strategy:description("");
    strategy:type(core.Both);
    strategy:setTag("NonOptimizableParameters", "StartTime,StopTime,ToTime,signaler_ToTime,signaler_show_alert,signaler_play_soundsignaler_sound_file,signaler_recurrent_sound,signaler_send_email,signaler_email,signaler_show_popup,signaler_debug_alert,use_advanced_alert,advanced_alert_key");
    strategy.parameters:addGroup("Algorithm Parameters")
    CreateParameters();
    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("type", "Price Type", "", true);
    strategy.parameters:setFlag("type", core.FLAG_BIDASK);
    strategy.parameters:addString("timeframe", "Timeframe", "", "m1");
    strategy.parameters:setFlag("timeframe", core.FLAG_PERIODS);
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("AllowedSide", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("AllowedSide", "Both", "", "Both");
    strategy.parameters:addStringAlternative("AllowedSide", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("AllowedSide", "Sell", "", "Sell");
    strategy.parameters:addString("entry_execution_type", "Execution Type", "Once per bar close or on every tick", "Live");
    strategy.parameters:addStringAlternative("entry_execution_type", "End of Turn", "", "EndOfTurn");
    strategy.parameters:addStringAlternative("entry_execution_type", "Live", "", "Live");
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("amount_type", "Amount Units", "", "lots");
    strategy.parameters:addStringAlternative("amount_type", "Lots", "", "lots");
    strategy.parameters:addStringAlternative("amount_type", "% of equity", "", "equity");
    strategy.parameters:addDouble("Amount", "Trade Amount", "", 1, 1, 1000000);
    strategy.parameters:addGroup("Money Management");
    strategy.parameters:addBoolean("use_stop", "Set Stop", "", false);
    strategy.parameters:addDouble("stop_pips", "Stop, pips", "", 10);
    strategy.parameters:addBoolean("use_trailing", "Trailing stop order", "", false);
    strategy.parameters:addInteger("trailing", "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);
    strategy.parameters:addBoolean("use_limit", "Set Limit", "", false);
    strategy.parameters:addDouble("limit_pips", "Limit, pips", "", 20);
    strategy.parameters:addBoolean("use_position_limit", "Use Position limit", "", true);
    strategy.parameters:addInteger("position_limit", "Limit", "", 1);
    strategy.parameters:addBoolean("close_on_opposite", "Close on opposite", "", true);
    strategy.parameters:addString("custom_id", "Custom ID", "", STRATEGY_NAME);

    strategy.parameters:addGroup("Trading time");
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");
    strategy.parameters:addBoolean("use_mandatory_closing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("mandatory_closing_exit_time", "Mandatory Closing Time", "", "23:59:59");
    strategy.parameters:addInteger("mandatory_closing_valid_interval", "Valid Interval for Operation, in second", "", 60);

    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    strategy.parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    strategy.parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    strategy.parameters:addFile("signaler_sound_file", "Sound File", "", "");
    strategy.parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    strategy.parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    strategy.parameters:addString("signaler_email", "Email", "", "");
    strategy.parameters:setFlag("signaler_email", core.FLAG_EMAIL);
end

local MAIN_SOURCE_ID = 1;
local TICK_SOURCE_ID = 2;
local MANDATORY_CLOSE_TIMER_ID = 3;
local entry_source_id;
local main_source;
local base_size, offer_id, Account, Amount, amount_type, AllowTrade, close_on_opposite, custom_id, AllowedSide;
local use_stop, stop_pips, use_limit, limit_pips, entry_execution_type, use_trailing, trailing, use_position_limit, position_limit;
local _show_alert, _sound_file, _recurrent_sound, _email;
local _ToTime, OpenTime, CloseTime;
local use_mandatory_closing, exit_time;
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    use_mandatory_closing = instance.parameters.use_mandatory_closing;
    use_position_limit = instance.parameters.use_position_limit;
    position_limit = instance.parameters.position_limit;
    use_trailing = instance.parameters.use_trailing;
    trailing = instance.parameters.trailing;
    AllowedSide = instance.parameters.AllowedSide;
    entry_execution_type = instance.parameters.entry_execution_type;
    limit_pips = instance.parameters.limit_pips;
    use_limit = instance.parameters.use_limit;
    use_stop = instance.parameters.use_stop;
    stop_pips = instance.parameters.stop_pips;
    AllowTrade = instance.parameters.AllowTrade;
    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;
    amount_type = instance.parameters.amount_type;
    close_on_opposite = instance.parameters.close_on_opposite;
    custom_id = instance.parameters.custom_id;
    main_source = ExtSubscribe(MAIN_SOURCE_ID, nil, instance.parameters.timeframe, instance.parameters.type, "bar")
    if entry_execution_type == "Live" then
        tick_source = ExtSubscribe(TICK_SOURCE_ID, nil, "t1", instance.parameters.type, "bar");
        entry_source_id = TICK_SOURCE_ID;
    else
        entry_source_id = MAIN_SOURCE_ID;
    end
    CreateEntryIndicators(main_source);
    base_size = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    offer_id = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;

    local valid;
    OpenTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    CloseTime, valid = ParseTime(instance.parameters.StopTime);
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");

    _ToTime = instance.parameters.signaler_ToTime
    if _ToTime == 1 then
        _ToTime = core.TZ_EST
    elseif _ToTime == 2 then
        _ToTime = core.TZ_UTC
    elseif _ToTime == 3 then
        _ToTime = core.TZ_LOCAL
    elseif _ToTime == 4 then
        _ToTime = core.TZ_SERVER
    elseif _ToTime == 5 then
        _ToTime = core.TZ_FINANCIAL
    elseif _ToTime == 6 then
        _ToTime = core.TZ_TS
    end
    if instance.parameters.signaler_play_sound then
        _sound_file = instance.parameters.signaler_sound_file;
        assert(_sound_file ~= "", "Sound file must be chosen");
    end
    _show_alert = instance.parameters.signaler_show_alert;
    _recurrent_sound = instance.parameters.signaler_recurrent_sound;
    if instance.parameters.signaler_send_email then
        _email = instance.parameters.signaler_email;
        assert(_email ~= "", "E-mail address must be specified");
    end
    if use_mandatory_closing then
        exit_time, valid = ParseTime(instance.parameters.mandatory_closing_exit_time);
        assert(valid, "Time " .. instance.parameters.mandatory_closing_exit_time .. " is invalid");
        core.host:execute("setTimer", MANDATORY_CLOSE_TIMER_ID, math.max(instance.parameters.mandatory_closing_valid_interval / 2, 1));
    end
end

function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime == closeTime then
        return true;
    end
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

local last_entry, last_exit, last_bar;
function ExtUpdate(id, source, period)
    if use_mandatory_closing and core.host.Trading:getTradingProperty("isSimulation") then
        DoMandatoryClosing();
    end
    if id ~= entry_source_id then
        return;
    end
    local entry_period;
    if entry_execution_type == "Live" then
        entry_period = main_source:size() - 1;
    else
        entry_period = period;
    end
    UpdateIndicators();
    if last_bar == nil then
        last_bar = main_source:date(entry_period);
    elseif last_bar ~= main_source:date(entry_period) then
        last_bar = main_source:date(entry_period);
        OnNewBar(main_source, entry_period);
    end

    if IsExitLong(main_source, entry_period) and last_exit ~= main_source:date(NOW) then
        if AllowTrade then
            CloseTrades("B");
        end
        Signal("Exit long", main_source);
        last_exit = main_source:date(NOW);
    end
    if IsExitShort(main_source, entry_period) and last_exit ~= main_source:date(NOW) then
        if AllowTrade then
            CloseTrades("S");
        end
        Signal("Exit short", main_source);
        last_exit = main_source:date(NOW);
    end

    local now = core.host:execute("convertTime", core.TZ_EST, _ToTime, core.host:execute("getServerTime"));
    now = now - math.floor(now);
    if not InRange(now, OpenTime, CloseTime) then
        return;
    end
    if IsEntryLong(main_source, entry_period) and last_entry ~= main_source:date(NOW) and not PositionsLimitHit() then
        if AllowTrade then
            if close_on_opposite then
                CloseTrades("S");
            end
            OpenTrade("B", main_source, entry_period);
        end
        Signal("Entry long", main_source);
        last_entry = main_source:date(NOW);
    end
    if IsEntryShort(main_source, entry_period) and last_entry ~= main_source:date(NOW) and not PositionsLimitHit() then
        if AllowTrade then
            if close_on_opposite then
                CloseTrades("B");
            end
            OpenTrade("S", main_source, entry_period);
        end
        Signal("Entry short", main_source);
        last_entry = main_source:date(NOW);
    end
end

function DoMandatoryClosing()
    if not use_mandatory_closing then
        return;
    end
    local now = core.host:execute("convertTime", core.TZ_EST, _ToTime, core.host:execute("getServerTime"));
    now = now - math.floor(now);
    if InRange(now, exit_time, exit_time + (instance.parameters.mandatory_closing_valid_interval / 86400.0)) then
        CloseTrades("B");
        CloseTrades("S");
        DeleteOrders();
    end
end

function PositionsLimitHit()
    if not use_position_limit then
        return false;
    end
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    local count = 0;
    while row ~= nil do
        if row.BS == side
            and row.Instrument == main_source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            count = count + 1;
        end
        row = enum:next();
    end
    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.BS == side
            and row.Instrument == main_source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            count = count + 1;
        end
        row = enum:next();
    end
    return count >= position_limit;
end

function DeleteOrders()
    local enum = core.host:findTable("orders"):enumerator()
    local row = enum:next()
    while row ~= nil do
        if row.AccountID == Account and row.Instrument == main_source:instrument() then
            local valuemap = core.valuemap()
            valuemap.Command = "DeleteOrder"
            valuemap.OrderID = row.OrderID
            success, msg = terminal:execute(4, valuemap)
            if not (success) then
                terminal:alertMessage(
                    instance.bid:instrument(),
                    instance.bid[NOW],
                    "Failed delete order " .. row.OrderID .. ":" .. msg,
                    instance.bid:date(NOW)
                )
            end
        end
        row = enum:next()
    end
end

function CloseTrades(side)
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.BS == side
            and row.Instrument == main_source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            CloseTrade(row);
        end
        row = enum:next();
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == MANDATORY_CLOSE_TIMER_ID then
        DoMandatoryClosing();
    end
end

function OpenTrade(side, source, period)
    if AllowedSide ~= "Both" then
        if AllowedSide == "Buy" and side == "S" then
            return;
        end
        if AllowedSide == "Sell" and side == "B" then
            return;
        end
    end
    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = offer_id;
    valuemap.AcctID = Account;
    if amount_type == "lots" then
        valuemap.Quantity = Amount * base_size;
    else
        local equity = core.host:findTable("accounts"):find("AccountID", valuemap.AcctID).Equity;
        local used_equity = equity * Amount / 100.0;
        local emr = core.host:getTradingProperty("EMR", instance.bid:instrument(), valuemap.AcctID);
        valuemap.Quantity = math.floor(used_equity / emr) * base_size;
    end
    valuemap.BuySell = side;
    valuemap.CustomID = custom_id;
    if use_stop then
        if side == "B" then
            valuemap.RateStop = source.low[period];
        else
            valuemap.RateStop = source.high[period];
        end
        if use_trailing then
            valuemap.TrailStepStop = trailing;
        end
    end
    if use_limit then
        valuemap.PegTypeLimit = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = (source.high[period] - source.low[period]) / source:pipSize();
        else
            valuemap.PegPriceOffsetPipsLimit = -(source.high[period] - source.low[period]) / source:pipSize();
        end
    end
    local success, msg = terminal:execute(3, valuemap);
end

function CloseTrade(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(2, valuemap);
end

function FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (STRATEGY_NAME or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, _ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function Signal(message, source)
    if source == nil then
        if instance.source ~= nil then
            source = instance.source;
        elseif instance.bid ~= nil then
            source = instance.bid;
        else
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        end
    end
    if _show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if _sound_file ~= nil then
        terminal:alertSound(_sound_file, _recurrent_sound);
    end

    if _email ~= nil then
        terminal:alertEmail(_email, profile:id().. " : " .. message, FormatEmail(source, NOW, message));
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");