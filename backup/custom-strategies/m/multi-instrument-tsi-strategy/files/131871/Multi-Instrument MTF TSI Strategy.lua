
local EntryActions = {};
local ExitActions = {};

-- START OF USER DEFINED SECTION
local STRATEGY_NAME = "Multi-Instrument MTF TSI Strategy";
function CreateParameters() 
    --create your algorithm strategy.parameters here
    strategy.parameters:addInteger("Period1", "MA Period", "", 200)

    strategy.parameters:addInteger("TSI_Period1", "TSI Short Period", "", 7)
    strategy.parameters:addInteger("TSI_Period2", "TSI Long Period", "", 14)

    strategy.parameters:addInteger("RLW_Period", "RLW Period", "", 14)
    strategy.parameters:addInteger("Period2", "MA Period", "", 250)
end

function CreateEntryIndicators(source)
    --create your indicators here
    local indicators = {};
    indicators["MA1"] = core.indicators:create("MVA", source, instance.parameters.Period1);
    indicators["TSI"] = core.indicators:create("TSI", source, instance.parameters.TSI_Period1, instance.parameters.TSI_Period1)
    indicators["RLW"] = core.indicators:create("RLW", source, instance.parameters.RLW_Period)
    indicators["MA2"] = core.indicators:create("MVA", source, instance.parameters.Period2)
    return indicators;
end

function UpdateIndicators(indicators)
    --update your indicators here
    indicators["MA1"]:update(core.UpdateLast);
    indicators["TSI"]:update(core.UpdateLast);
    indicators["RLW"]:update(core.UpdateLast);
    indicators["MA2"]:update(core.UpdateLast);
end

function IsEntryLong(source, period, indicators)
    return indicators["MA2"].DATA[period] > indicators["MA2"].DATA[period - 1] 
        and source.close[period] > indicators["MA1"].DATA[period] 
        and source.close[period - 1] <= indicators["MA1"].DATA[period - 1] 
        and indicators["TSI"].DATA[period] < 0 
        and indicators["RLW"].DATA[period] < -80;
end
function IsEntryShort(source, period, indicators)
    return indicators["MA2"].DATA[period] < indicators["MA2"].DATA[period - 1] 
        and source.close[period] < indicators["MA1"].DATA[period] 
        and source.close[period - 1] >= indicators["MA1"].DATA[period - 1] 
        and indicators["TSI"].DATA[period] > 0 
        and indicators["RLW"].DATA[period] > -20;
end
function IsExitLong(source, period, indicators)
    return (indicators["TSI"].DATA[period] < 15 and indicators["TSI"].DATA[period - 1] >= 15) or
            (indicators["TSI"].DATA[period] < 34 and indicators["TSI"].DATA[period - 1] >= 34);
end
function IsExitShort(source, period, indicators)
    return (indicators["TSI"].DATA[period] > -15 and indicators["TSI"].DATA[period - 1] <= -15) or
            (indicators["TSI"].DATA[period] > -34 and indicators["TSI"].DATA[period - 1] <= -34);
end
-- END OF USER DEFINED SECTION

local default_timeframes = {"m1", "m5", "m15", "m30", "H1", "H4", "D1"};

function AddTF(id, def)
    strategy.parameters:addBoolean("trade_tf_" .. id, "Use timeframe " .. id, "", true)
    strategy.parameters:addString("timeframe_" .. id, "Timeframe " .. id, "", def);
    strategy.parameters:setFlag("timeframe_" .. id, core.FLAG_PERIODS);
end

function Init()
    strategy:name(STRATEGY_NAME);
    strategy:description("");
    strategy:type(core.Both);
    strategy:setTag("NonOptimizableParameters", "StartTime,StopTime,ToTime,signaler_ToTime,signaler_show_alert,signaler_play_soundsignaler_sound_file,signaler_recurrent_sound,signaler_send_email,signaler_email,signaler_show_popup,signaler_debug_alert,use_advanced_alert,advanced_alert_key");
    strategy.parameters:addBoolean("type", "Price Type", "", true);
    strategy.parameters:setFlag("type", core.FLAG_BIDASK);

    strategy.parameters:addGroup("Trading targets")
    strategy.parameters:addBoolean("trade_all_instruments", "Trade all instruments", "", false);
    for i, tf in ipairs(default_timeframes) do
        AddTF(i, tf);
    end

    strategy.parameters:addGroup("Trading parameters")
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
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
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
    CreateParameters();

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

local next_id = 1;
local Account, Amount, AllowTrade, close_on_opposite, custom_id, AllowedSide;
local use_stop, stop_pips, use_limit, limit_pips, entry_execution_type, use_trailing, trailing, use_position_limit, position_limit;
local _show_alert, _sound_file, _recurrent_sound, _email;
local _ToTime;
local data = {};

function CreateDataForTF(offer, tf)
    local d = {};
    d.MAIN_SOURCE_ID = next_id;
    next_id = next_id + 1;
    d.main_source = ExtSubscribe(d.MAIN_SOURCE_ID, offer.Instrument, tf, instance.parameters.type, "bar")
    if entry_execution_type == "Live" then
        d.TICK_SOURCE_ID = next_id;
        next_id = next_id + 1;
        d.tick_source = ExtSubscribe(d.TICK_SOURCE_ID, offer.Instrument, "t1", instance.parameters.type, "bar");
        d.entry_source_id = d.TICK_SOURCE_ID;
    else
        d.entry_source_id = d.MAIN_SOURCE_ID;
    end
    d.indicators = CreateEntryIndicators(d.main_source);
    d.base_size = core.host:execute("getTradingProperty", "baseUnitSize", offer.Instrument, Account);
    d.offer_id = offer.OfferID;
    return d;
end

function GetDataByID(id)
    for i, d in ipairs(data) do
        if d.entry_source_id == id then
            return d;
        end
    end
    return nil;
end

function CreateData(offer)
    for i, tf in ipairs(default_timeframes) do
        if instance.parameters:getBoolean("trade_tf_" .. i) then
            data[#data + 1] = CreateDataForTF(offer, instance.parameters:getString("timeframe_" .. i));
        end
    end
end

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
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
    close_on_opposite = instance.parameters.close_on_opposite;
    custom_id = instance.parameters.custom_id;
    if instance.parameters.trade_all_instruments then
        local enum = core.host:findTable("offers"):enumerator();
        local row = enum:next();
        while row ~= nil do
            CreateData(row);
            row = enum:next();
        end
    else
        CreateData(core.host:findTable("offers"):find("Instrument", instance.bid:instrument()));
    end
    
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
end

function ExtUpdate(id, source, period)
    local d = GetDataByID(id);
    if d == nil then
        return;
    end
    local entry_period;
    if entry_execution_type == "Live" then
        entry_period = d.main_source:size() - 1;
    else
        entry_period = period;
    end
    UpdateIndicators(d.indicators);
    if IsEntryLong(d.main_source, entry_period, d.indicators) and d.last_entry ~= d.main_source:date(NOW) and not PositionsLimitHit(d.main_source) then
        if AllowTrade then
            if close_on_opposite then
                CloseTrades(d.main_source, "S");
            end
            OpenTrade("B", d);
        else
            Signal("Entry long", d.main_source);
        end
        d.last_entry = d.main_source:date(NOW);
    end
    if IsEntryShort(d.main_source, entry_period, d.indicators) and d.last_entry ~= d.main_source:date(NOW) and not PositionsLimitHit(d.main_source) then
        if AllowTrade then
            if close_on_opposite then
                CloseTrades("B", d.main_source);
            end
            OpenTrade("S", d);
        else
            Signal("Entry short", d.main_source);
        end
        d.last_entry = d.main_source:date(NOW);
    end
    if IsExitLong(d.main_source, entry_period, d.indicators) and d.last_exit ~= d.main_source:date(NOW) then
        if AllowTrade then
            CloseTrades("B", d.main_source);
        else
            Signal("Exit long", d.main_source);
        end
        d.last_exit = d.main_source:date(NOW);
    end
    if IsExitShort(d.main_source, entry_period, d.indicators) and d.last_exit ~= d.main_source:date(NOW) then
        if AllowTrade then
            CloseTrades("S", d.main_source);
        else
            Signal("Exit short", d.main_source);
        end
        d.last_exit = d.main_source:date(NOW);
    end
end

function PositionsLimitHit(main_source)
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

function CloseTrades(side, main_source)
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
end

function OpenTrade(side, d)
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
    valuemap.OfferID = d.offer_id;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * d.base_size;
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