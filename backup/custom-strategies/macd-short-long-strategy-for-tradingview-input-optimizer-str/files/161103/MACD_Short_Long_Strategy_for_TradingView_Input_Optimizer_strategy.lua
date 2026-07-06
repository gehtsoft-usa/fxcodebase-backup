local STRATEGY_NAME = "Strategy";
function CreateParameters() 
    STRATEGY_NAME = "MACD Short/Long Strategy for TradingView Input Optimizer" .. " Strategy";
    strategy.parameters:addBoolean("param1", "Allow Long", "", true);
    strategy.parameters:addInteger("param2", "Fast Length Long", "", 13);
    strategy.parameters:addInteger("param3", "Slow Length Long", "", 19);
    strategy.parameters:addString("param4", "Source Long", "", "close");
    strategy.parameters:addStringAlternative("param4", "Open", "", "open");
    strategy.parameters:addStringAlternative("param4", "High", "", "high");
    strategy.parameters:addStringAlternative("param4", "Low", "", "low");
    strategy.parameters:addStringAlternative("param4", "Close", "", "close");
    strategy.parameters:addStringAlternative("param4", "Median", "", "median");
    strategy.parameters:addStringAlternative("param4", "Typical", "", "typical");
    strategy.parameters:addStringAlternative("param4", "Weighted", "", "weighted");
    strategy.parameters:addStringAlternative("param4", "OHLC4", "", "ohlc4");
    strategy.parameters:addStringAlternative("param4", "HLCC4", "", "hlcc4");
    strategy.parameters:addInteger("param5", "Signal Smoothing Long", "", 9, 1, 50);
    strategy.parameters:addString("param6", "Oscillator MA Type Long", "", "EMA");
    strategy.parameters:addStringAlternative("param6", "SMA", "", "SMA");
    strategy.parameters:addStringAlternative("param6", "EMA", "", "EMA");
    strategy.parameters:addString("param7", "Signal Line MA Type Long", "", "EMA");
    strategy.parameters:addStringAlternative("param7", "SMA", "", "SMA");
    strategy.parameters:addStringAlternative("param7", "EMA", "", "EMA");
    strategy.parameters:addInteger("param8", "Cross Point Long", "", 0);
    strategy.parameters:addInteger("param9", "MacD Cross Delay Long", "", 0);
    strategy.parameters:addBoolean("param10", "Signal Must Also Cross Long", "", false);
    strategy.parameters:addInteger("param11", "Signal Cross Delay Long", "", 0);
    strategy.parameters:addBoolean("param12", "Allow Short", "", true);
    strategy.parameters:addInteger("param13", "Fast Length Short", "", 11);
    strategy.parameters:addInteger("param14", "Slow Length Short", "", 20);
    strategy.parameters:addString("param15", "Source Short", "", "close");
    strategy.parameters:addStringAlternative("param15", "Open", "", "open");
    strategy.parameters:addStringAlternative("param15", "High", "", "high");
    strategy.parameters:addStringAlternative("param15", "Low", "", "low");
    strategy.parameters:addStringAlternative("param15", "Close", "", "close");
    strategy.parameters:addStringAlternative("param15", "Median", "", "median");
    strategy.parameters:addStringAlternative("param15", "Typical", "", "typical");
    strategy.parameters:addStringAlternative("param15", "Weighted", "", "weighted");
    strategy.parameters:addStringAlternative("param15", "OHLC4", "", "ohlc4");
    strategy.parameters:addStringAlternative("param15", "HLCC4", "", "hlcc4");
    strategy.parameters:addInteger("param16", "Signal Smoothing Short", "", 9, 1, 50);
    strategy.parameters:addString("param17", "Oscillator MA Type Short", "", "EMA");
    strategy.parameters:addStringAlternative("param17", "SMA", "", "SMA");
    strategy.parameters:addStringAlternative("param17", "EMA", "", "EMA");
    strategy.parameters:addString("param18", "Signal Line MA Type Short", "", "EMA");
    strategy.parameters:addStringAlternative("param18", "SMA", "", "SMA");
    strategy.parameters:addStringAlternative("param18", "EMA", "", "EMA");
    strategy.parameters:addInteger("param19", "Cross Point Short", "", 0);
    strategy.parameters:addInteger("param20", "MacD Cross Delay Short", "", 1);
    strategy.parameters:addBoolean("param21", "Signal Must Also Cross Short", "", false);
    strategy.parameters:addInteger("param22", "Signal Cross Delay Short", "", 0);
    strategy.parameters:addBoolean("param23", "Use Stop Loss Long", "", false);
    strategy.parameters:addDouble("param24", "Stop Loss % Long", "", 1, 0.0);
    strategy.parameters:addBoolean("param25", "Use Take Profit Long", "", false);
    strategy.parameters:addDouble("param26", "Take Profit % Long", "", 1, 0.0);
    strategy.parameters:addBoolean("param27", "Use Stop Loss Short", "", true);
    strategy.parameters:addDouble("param28", "Stop Loss % Short", "", 21, 0.0);
    strategy.parameters:addBoolean("param29", "Use Take Profit Short", "", true);
    strategy.parameters:addDouble("param30", "Take Profit % Short", "", 20, 0.0);
    strategy.parameters:addColor("param31", "MACD Line Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(41, 98, 255), 0)));
    strategy.parameters:addColor("param32", "Signal Line Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 109, 0), 0)));
    strategy.parameters:addColor("param33", "Grow Above Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(38, 166, 154), 0)));
    strategy.parameters:addColor("param34", "Fall Above Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(178, 223, 219), 0)));
    strategy.parameters:addColor("param35", "Grow Below Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 205, 210), 0)));
    strategy.parameters:addColor("param36", "Fall Below Long", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 82, 82), 0)));
    strategy.parameters:addColor("param37", "MACD Line Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(176, 61, 255), 0)));
    strategy.parameters:addColor("param38", "Signal Line Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 255, 232), 0)));
    strategy.parameters:addColor("param39", "Grow Above Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(217, 89, 101), 0)));
    strategy.parameters:addColor("param40", "Fall Above Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(77, 32, 36), 0)));
    strategy.parameters:addColor("param41", "Grow Below Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 50, 45), 0)));
    strategy.parameters:addColor("param42", "Fall Below Short", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 173, 173), 0)));
end

local indi;
local streams = {};
function FindStream(id)
    local streamsCount = indi:getStreamCount();
    for i = 0, streamsCount - 1 do
        local stream = indi:getStream(i);
        if stream:id() == id then
            return stream;
        end
    end
    return nil;
end
function InitStream(id)
    if streams[id] ~= nil then
        return;
    end
    streams[id] = FindStream(id);
end
function AssignPrameters(indicatorParams)
    indicatorParams:setBoolean("param1", instance.parameters.param1);
    indicatorParams:setInteger("param2", instance.parameters.param2);
    indicatorParams:setInteger("param3", instance.parameters.param3);
    indicatorParams:setString("param4", instance.parameters.param4);
    indicatorParams:setInteger("param5", instance.parameters.param5);
    indicatorParams:setString("param6", instance.parameters.param6);
    indicatorParams:setString("param7", instance.parameters.param7);
    indicatorParams:setInteger("param8", instance.parameters.param8);
    indicatorParams:setInteger("param9", instance.parameters.param9);
    indicatorParams:setBoolean("param10", instance.parameters.param10);
    indicatorParams:setInteger("param11", instance.parameters.param11);
    indicatorParams:setBoolean("param12", instance.parameters.param12);
    indicatorParams:setInteger("param13", instance.parameters.param13);
    indicatorParams:setInteger("param14", instance.parameters.param14);
    indicatorParams:setString("param15", instance.parameters.param15);
    indicatorParams:setInteger("param16", instance.parameters.param16);
    indicatorParams:setString("param17", instance.parameters.param17);
    indicatorParams:setString("param18", instance.parameters.param18);
    indicatorParams:setInteger("param19", instance.parameters.param19);
    indicatorParams:setInteger("param20", instance.parameters.param20);
    indicatorParams:setBoolean("param21", instance.parameters.param21);
    indicatorParams:setInteger("param22", instance.parameters.param22);
    indicatorParams:setBoolean("param23", instance.parameters.param23);
    indicatorParams:setDouble("param24", instance.parameters.param24);
    indicatorParams:setBoolean("param25", instance.parameters.param25);
    indicatorParams:setDouble("param26", instance.parameters.param26);
    indicatorParams:setBoolean("param27", instance.parameters.param27);
    indicatorParams:setDouble("param28", instance.parameters.param28);
    indicatorParams:setBoolean("param29", instance.parameters.param29);
    indicatorParams:setDouble("param30", instance.parameters.param30);
    indicatorParams:setColor("param31", instance.parameters.param31);
    indicatorParams:setColor("param32", instance.parameters.param32);
    indicatorParams:setColor("param33", instance.parameters.param33);
    indicatorParams:setColor("param34", instance.parameters.param34);
    indicatorParams:setColor("param35", instance.parameters.param35);
    indicatorParams:setColor("param36", instance.parameters.param36);
    indicatorParams:setColor("param37", instance.parameters.param37);
    indicatorParams:setColor("param38", instance.parameters.param38);
    indicatorParams:setColor("param39", instance.parameters.param39);
    indicatorParams:setColor("param40", instance.parameters.param40);
    indicatorParams:setColor("param41", instance.parameters.param41);
    indicatorParams:setColor("param42", instance.parameters.param42);
end

function UpdateIndicators()
    indi:update(core.UpdateLast);
end

function OnNewBar(source, period)
end

function IsEntryLong(source, period)
    if (streams["entry_signal" .. "long"][period] == 1) then return true; end
    if (streams["entry_signal" .. "long"][period] == 1) then return true; end
    if (streams["entry_signal" .. "short"][period] == 1) then return true; end
    if (streams["entry_signal" .. "short"][period] == 1) then return true; end
    return false;
end
function IsEntryShort(source, period)
    if (streams["entry_signal" .. "long"][period] == -1) then return true; end
    if (streams["entry_signal" .. "long"][period] == -1) then return true; end
    if (streams["entry_signal" .. "short"][period] == -1) then return true; end
    if (streams["entry_signal" .. "short"][period] == -1) then return true; end
    return false;
end
function IsExitLong(source, period)
    if (streams["close_signal".. "long"][period] == 1) then return true; end
    if (streams["close_signal".. "long"][period] == 1) then return true; end
    if (streams["close_signal".. "short"][period] == 1) then return true; end
    if (streams["close_signal".. "short"][period] == 1) then return true; end
    return false;
end
function IsExitShort(source, period)
    if (streams["close_signal".. "long"][period] == -1) then return true; end
    if (streams["close_signal".. "long"][period] == -1) then return true; end
    if (streams["close_signal".. "short"][period] == -1) then return true; end
    if (streams["close_signal".. "short"][period] == -1) then return true; end
    return false;
end

function Init()
    strategy:type(core.Both);
    strategy:setTag("NonOptimizableParameters", "StartTime,StopTime,ToTime,signaler_ToTime,signaler_show_alert,signaler_play_soundsignaler_sound_file,signaler_recurrent_sound,signaler_send_email,signaler_email,signaler_show_popup,signaler_debug_alert,use_advanced_alert,advanced_alert_key");
    strategy.parameters:addGroup("Algorithm Parameters")
    CreateParameters();
    strategy:name(STRATEGY_NAME);
    strategy:description("");
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
    strategy.parameters:addString("trade_direction", "Trade Direction", "", "Direct");
    strategy.parameters:addStringAlternative("trade_direction", "Direct", "", "Direct");
    strategy.parameters:addStringAlternative("trade_direction", "Reversed", "", "Reversed");
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

function MakeId(name)
    name = string.gsub(name, "/", "_");
    return string.upper(name);
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
local use_mandatory_closing, exit_time, trade_direction;
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    trade_direction = instance.parameters.trade_direction;
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
    local indi_name = MakeId("MACD_Short_Long_Strategy_for_TradingView_Input_Optimizer");
    local profile = core.indicators:findIndicator(indi_name);
    assert(profile ~= nil, "Please, download and install " .. indi_name .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    AssignPrameters(indicatorParams);
    indi = core.indicators:create(indi_name, main_source, indicatorParams);
    InitStream("entry_signal" .. "long");
    InitStream("entry_signal" .. "long");
    InitStream("entry_signal" .. "short");
    InitStream("entry_signal" .. "short");
    InitStream("close_signal" .. "long");
    InitStream("close_signal" .. "long");
    InitStream("close_signal" .. "short");
    InitStream("close_signal" .. "short");
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
    now = math.floor(now * 86400 + 0.5);
    openTime = math.floor(openTime * 86400 + 0.5);
    closeTime = math.floor(closeTime * 86400 + 0.5);
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
    if main_source:size() <= entry_period then
        return;
    end
    UpdateIndicators();
    if last_bar == nil then
        last_bar = main_source:date(entry_period);
    elseif last_bar ~= main_source:date(entry_period) then
        last_bar = main_source:date(entry_period);
        OnNewBar(main_source, entry_period);
    end

    if IsExitLong(main_source, entry_period) and last_exit ~= main_source:date(NOW) then
        if trade_direction == "Direct" then
            if AllowTrade then
                CloseTrades("B");
            end
            Signal("Exit long", main_source);
        else
            if AllowTrade then
                CloseTrades("S");
            end
            Signal("Exit short", main_source);
        end
        last_exit = main_source:date(NOW);
    end
    if IsExitShort(main_source, entry_period) and last_exit ~= main_source:date(NOW) then
        if trade_direction == "Direct" then
            if AllowTrade then
                CloseTrades("S");
            end
            Signal("Exit short", main_source);
        else
            if AllowTrade then
                CloseTrades("B");
            end
            Signal("Exit long", main_source);
        end
        last_exit = main_source:date(NOW);
    end

    local now = core.host:execute("convertTime", core.TZ_EST, _ToTime, core.host:execute("getServerTime"));
    now = now - math.floor(now);
    if not InRange(now, OpenTime, CloseTime) then
        return;
    end
    local longSignal, longSerial = IsEntryLong(main_source, entry_period);
    if longSerial == nil then
        longSerial = main_source:date(NOW);
    end
    if longSignal and last_entry ~= longSerial then
        if AllowTrade then
            local closed_positions = 0;
            if close_on_opposite then
                if trade_direction == "Direct" then
                    closed_positions = CloseTrades("S");
                else
                    closed_positions = CloseTrades("B");
                end
            end
            if closed_positions > 0 or not PositionsLimitHit() then
                if trade_direction == "Direct" then
                    OpenTrade("B");
                else
                    OpenTrade("S");
                end
            end
        end
        if trade_direction == "Direct" then
            Signal("Entry long", main_source);
        else
            Signal("Entry short", main_source);
        end
        last_entry = longSerial;
    end
    local shortSignal, shortSerial = IsEntryShort(main_source, entry_period);
    if shortSerial == nil then
        shortSerial = main_source:date(NOW);
    end
    if shortSignal and last_entry ~= shortSerial then
        if AllowTrade then
            local closed_positions = 0;
            if close_on_opposite then
                if trade_direction == "Direct" then
                    closed_positions = CloseTrades("B");
                else
                    closed_positions = CloseTrades("S");
                end
            end
            if closed_positions > 0 or not PositionsLimitHit() then
                if trade_direction == "Direct" then
                    OpenTrade("S");
                else
                    OpenTrade("B");
                end
            end
        end
        if trade_direction == "Direct" then
            Signal("Entry short", main_source);
        else
            Signal("Entry long", main_source);
        end
        last_entry = shortSerial;
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
        if row.Instrument == main_source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            count = count + 1;
        end
        row = enum:next();
    end
    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.Instrument == main_source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            count = count + 1;
        end
        row = enum:next();
    end
    return count >= position_limit;
end

local closed_orders = {};
function DeleteOrders()
    local closed = false;
    local enum = core.host:findTable("orders"):enumerator()
    local row = enum:next()
    while row ~= nil do
        if row.AccountID == Account 
            and row.Instrument == main_source:instrument() 
            and closed_orders[row.OrderID] ~= true
        then
            local valuemap = core.valuemap()
            valuemap.Command = "DeleteOrder"
            valuemap.OrderID = row.OrderID
            success, msg = terminal:execute(4, valuemap)
            closed_orders[row.OrderID] = success;
            if not (success) then
                if log_file ~= nil then
                    log_file:write(msg .. "\n");
                end
                terminal:alertMessage(
                    instance.bid:instrument(),
                    instance.bid[NOW],
                    "Failed delete order " .. row.OrderID .. ":" .. msg,
                    instance.bid:date(NOW)
                )
            end
            closed = true;
        end
        row = enum:next()
    end
    return false;
end

function CloseTrades(side)
    local count = 0;
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.BS == side
            and row.Instrument == main_source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            CloseTrade(row);
            count = count + 1;
        end
        row = enum:next();
    end
    return count;
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == MANDATORY_CLOSE_TIMER_ID then
        DoMandatoryClosing();
    end
end

function OpenTrade(side)
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
        valuemap.PegTypeStop = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -stop_pips;
        else
            valuemap.PegPriceOffsetPipsStop = stop_pips;
        end
        if use_trailing then
            valuemap.TrailStepStop = trailing;
        end
    end
    if use_limit then
        valuemap.PegTypeLimit = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = limit_pips;
        else
            valuemap.PegPriceOffsetPipsLimit = -limit_pips;
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
Graphics = {};
Graphics.NextId = 1;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
    if color == nil then
        return -1;
    end
    for i, pen in ipairs(Graphics.Pens) do
        if pen.Width == width and pen.Color == color then
            context:createPen(pen.Id, context:convertPenStyle(style), width, color);
            return pen.Id;
        end
    end
    local newPen = {};
    newPen.Id = Graphics.NextId;
    newPen.Width = width;
    newPen.Color = color;

    context:createPen(newPen.Id, context:convertPenStyle(style), width, color);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Pens[#Graphics.Pens + 1] = newPen;
    return newPen.Id;
end
function Graphics:FindBrush(color, context)
    if color == nil then
        return -1;
    end
    for i, brush in ipairs(Graphics.Brushes) do
        if brush.Color == color then
            context:createSolidBrush(brush.Id, color)
            return brush.Id;
        end
    end
    local newBrush = {};
    newBrush.Id = Graphics.NextId;
    newBrush.Color = color;
    context:createSolidBrush(newBrush.Id, color)
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Brushes[#Graphics.Brushes + 1] = newBrush;
    return newBrush.Id;
end
function Graphics:FindFont(font, xSize, ySize, corner, context)
    for i, font in ipairs(self.Fonts) do
        if font.xSize == xSize and font.Name == font then
            return font.Id;
        end
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    newFont.xSize = xSize;
    newFont.Name = font;
    context:createFont(newFont.Id, font, 0, xSize, context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Graphics:SplitColorAndTransparency(clr)
    if clr == nil then
        return nil, nil;
    end
    local transparency = (math.floor(clr / 16777216) % 255);
    local color = clr - transparency * 16777216;
    return color, transparency;
end
function Graphics:GetColor(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return color;
end
function Graphics:GetTransparency(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return transparency;
end
function Graphics:GetTransparencyPercent(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    if transparency == nil then
        return nil;
    end
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil or transp == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
function SafeMinus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left - right;
end
function SafeMultiply(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left * right;
end
function SafePlus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left + right;
end
function SafeConcat(left, right)
    if left == nil then
        return right;
    end
    if right == nil then
        return left;
    end
    return left .. right;
end
function SafeDivide(left, right)
    if left == nil or right == nil or right == 0 then
        return nil;
    end
    return left / right;
end
function SafeGreater(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left > right;
end
function SafeGE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left >= right;
end
function SafeLess(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left < right;
end
function SafeLE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left <= right;
end
function SafeMax(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.max(left, right);
end
function SafeMin(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.min(left, right);
end
function SafeAbs(value)
    if value == nil then
        return nil;
    end
    return math.abs(value);
end
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function SafeSetBool(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or period == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil or period == nil then
        return nil;
    end
    if not stream:hasData(period) then
        return nil;
    end
    return stream[period];
end
function Float(number)
    return number and number or nil;
end
function Int(number)
    return number and number or nil;
end
function Color(color)
    return color and color or nil;
end
function ToLine(line)
    return line;
end
function ToBox(box)
    return box;
end
function Round(num, idp)
    if num == nil then
        return nil;
    end
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
function Nz(value, defaultValue)
    if defaultValue == nil then
        defaultValue = 0;
    end
    return value and value or defaultValue;
end
function Triary(condition, trueValue, falseValue)
    if condition == nil or condition == false then
        return falseValue;
    end
    return trueValue;
end
function SafeCrossesUnder(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesUnder(val1, val2, period);
end
function SafeCrossesOver(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesOver(val1, val2, period);
end
function SafeCrosses(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crosses(val1, val2, period);
end
function SafeCos(val)
    if val == nil then
        return nil;
    end
    return math.cos(val);
end
function SafeSin(val)
    if val == nil then
        return nil;
    end
    return math.sin(val);
end
function SafeMathExMax(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.max(source, core.rangeTo(period, length));
end
function SafeMathExMin(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.min(source, core.rangeTo(period, length));
end
function SafeMathExStdev(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.stdev(source, core.rangeTo(period, length));
end
PineStrategy = {};
PineStrategy.streams = {};
function PineStrategy:CreateEntrySignalV4(id)
    local signal = {};
    if self.streams["entry_signal" .. id] == nil then
        self.streams["entry_signal" .. id] = instance:addStream("entry_signal" .. id, core.Line, "Entry Signal " .. id, "Entry Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["entry_signal" .. id];
    function signal:Execute(period, id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
        if when then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateEntrySignalV5(id)
    local signal = {};
    if self.streams["entry_signal" .. id] == nil then
        self.streams["entry_signal" .. id] = instance:addStream("entry_signal" .. id, core.Line, "Entry Signal " .. id, "Entry Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["entry_signal" .. id];
    function signal:Execute(period, id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
        if when then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateCloseSignalV4(id)
    local signal = {};
    if self.streams["close_signal" .. id] == nil then
        self.streams["close_signal" .. id] = instance:addStream("close_signal" .. id, core.Line, "Close Signal " .. id, "Close Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["close_signal" .. id];
    function signal:Execute(period, id, when, qty, qty_percent, comment, alert_message)
        if when then
            self.stream[period] = 1;
        end
    end
    return signal;
end
function PineStrategy:CreateCloseSignalV5(id)
    local signal = {};
    if self.streams["close_signal" .. id] == nil then
        self.streams["close_signal" .. id] = instance:addStream("close_signal" .. id, core.Line, "Close Signal " .. id, "Close Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["close_signal" .. id];
    function signal:Execute(period, id, comment, qty, qty_percent, alert_message, immediately, disable_alert)
        if immediately then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:CreateExitSignalV4(id)
    local signal = {};
    local stream_id_1 = "exit_signal" .. id .. "_tp";
    local stream_id_2 = "exit_signal" .. id .. "_sl";
    if self.streams[stream_id_1] == nil then
        self.streams[stream_id_1] = instance:addStream(stream_id_1, core.Line, "TP Signal " .. id, "TP Signal " .. id, core.colors().Red, 0, 0);
        self.streams[stream_id_2] = instance:addStream(stream_id_2, core.Line, "SL Signal " .. id, "SL Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream_tp = self.streams[stream_id_1];
    signal.stream_sl = self.streams[stream_id_2];
    function signal:Execute(period, id, from_entry, qty, qty_percent, profit, limit, loss, stop, trail_price, trail_points, trail_offset, oca_name, comment, when, alert_message)
        if when then
            self.stream_sl[period] = limit;
            self.stream_tp[period] = stop;
        end
    end
    return signal;
end
function PineStrategy:CreateExitSignalV5(id)
    local signal = {};
    local stream_id_1 = "exit_signal" .. id .. "_tp";
    local stream_id_2 = "exit_signal" .. id .. "_sl";
    if self.streams[stream_id_1] == nil then
        self.streams[stream_id_1] = instance:addStream(stream_id_1, core.Line, "TP Signal " .. id, "TP Signal " .. id, core.colors().Red, 0, 0);
        self.streams[stream_id_2] = instance:addStream(stream_id_2, core.Line, "SL Signal " .. id, "SL Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream_tp = self.streams[stream_id_1];
    signal.stream_sl = self.streams[stream_id_2];
    function signal:Execute(period, id, from_entry, qty, qty_percent, profit, limit, loss, stop, trail_price, trail_points, trail_offset, oca_name, comment, 
            comment_profit, comment_loss, comment_trailing, alert_message, alert_profit, alert_loss, alert_trailing, disable_alert)
        self.stream_sl[period] = limit;
        self.stream_tp[period] = stop;
    end
    return signal;
end
function PineStrategy:EntryV4(id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:EntryV5(id, direction, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:CloseV4(id, when, qty, qty_percent, comment, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:CloseV5(id, comment, qty, qty_percent, alert_message, immediately, disable_alert)
    if disable_alert == true then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:Equity(account)
    local accounts = core.host:findTable("accounts");
    if account == nil then
        local enum = accounts:enumerator();
        local row = enum:next();
        while row ~= nil do
            return row.Equity;
        end
        return 0;
    end
    return accounts:find("AccountID", account).Equity;
end
function PineStrategy:PositionSize(symbol)
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    local total = 0;
    while row ~= nil do
        if row.Instrument == symbol then
            if row.BS == "B" then
                total = total + row.Lot;
            else
                total = total - row.Lot;
            end
        end
        row = enum:next();
    end
    return total;
end
function PineStrategy:PositionAvgPrice(symbol)
    return 0;
end
