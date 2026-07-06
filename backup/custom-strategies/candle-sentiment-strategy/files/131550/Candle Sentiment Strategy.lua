-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=69470

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

local EntryActions = {};
local ExitActions = {};

-- START OF USER DEFINED SECTION
local STRATEGY_NAME = "Candle Sentiment Strategy";
function CreateParameters() 
    strategy.parameters:addInteger("BBLength", "BBLength", "", 10);
    strategy.parameters:addDouble("BBNumDevs", "BBNumDevs", "", 0.5);
    strategy.parameters:addInteger("AvgLength1", "AvgLength1", "", 4)
    strategy.parameters:addInteger("AvgLength2", "AvgLength2", "", 4)
    strategy.parameters:addInteger("BBILength", "BBILength", "", 60)
    strategy.parameters:addDouble("NumDevsUp", "NumDevsUp", "", 1.5)
    strategy.parameters:addDouble("NumDevsDn", "NumDevsDn", "", 1.5)

    strategy.parameters:addInteger("ssd_K", "Number of periods for %K", "The number of periods for %K.", 10, 2, 1000);
    strategy.parameters:addInteger("ssd_SD", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000);
    strategy.parameters:addInteger("ssd_D", "Number of periods for %D", "The number of periods for %D.", 5, 2, 1000);
end

local indi, ssd;
function CreateEntryIndicators(source)
    local profile = core.indicators:findIndicator("CANDLE SENTIMENT");
    assert(profile ~= nil, "Please, download and install " .. "CANDLE SENTIMENT" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indi = core.indicators:create("CANDLE SENTIMENT", source, instance.parameters.BBLength,
        instance.parameters.BBNumDevs, instance.parameters.AvgLength1, instance.parameters.AvgLength2,
        instance.parameters.BBILength, instance.parameters.NumDevsUp, instance.parameters.NumDevsDn)

    ssd = core.indicators:create("SSD", source, instance.parameters.ssd_K, instance.parameters.ssd_SD, instance.parameters.ssd_D);
end

function UpdateIndicators()
    indi:update(core.UpdateLast);
    ssd:update(core.UpdateLast);
end

function GetZone(period)
    for i = 0, 100 do
        if period < i + 1 or not indi.Index:hasData(period - i - 1) then
            return nil;
        end
        if core.crossesOver(indi.Index, indi.UpperBand, period - i) then
            return 3;
        elseif core.crossesUnder(indi.Index, indi.UpperBand, period - i) then
            return 6;
        elseif core.crossesOver(indi.Index, indi.LowerBand, period - i) then
            return 4;
        elseif core.crossesUnder(indi.Index, indi.LowerBand, period - i) then
            return 5;
        end
    end
end

function IsEntryLong(source, period)
    local zone = GetZone(period);
    return core.crossesOver(ssd.K, ssd.D, period) and (zone == 4 or zone == 3 or zone == 5);
end
function IsEntryShort(source, period)
    local zone = GetZone(period);
    return core.crossesUnder(ssd.K, ssd.D, period) and (zone == 6 or zone == 3 or zone == 5);
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

local MAIN_SOURCE_ID = 1;
local TICK_SOURCE_ID = 2;
local entry_source_id;
local main_source;
local base_size, offer_id, Account, Amount, AllowTrade, close_on_opposite, custom_id, AllowedSide;
local use_stop, stop_pips, use_limit, limit_pips, entry_execution_type, use_trailing, trailing, use_position_limit, position_limit;
local _show_alert, _sound_file, _recurrent_sound, _email;
local _ToTime;
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

local last_entry, last_exit;
function ExtUpdate(id, source, period)
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
    if IsEntryLong(main_source, entry_period) and last_entry ~= main_source:date(NOW) and not PositionsLimitHit() then
        if AllowTrade then
            if close_on_opposite then
                CloseTrades("S");
            end
            OpenTrade("B");
        else
            Signal("Entry long", main_source);
        end
        last_entry = main_source:date(NOW);
    end
    if IsEntryShort(main_source, entry_period) and last_entry ~= main_source:date(NOW) and not PositionsLimitHit() then
        if AllowTrade then
            if close_on_opposite then
                CloseTrades("B");
            end
            OpenTrade("S");
        else
            Signal("Entry short", main_source);
        end
        last_entry = main_source:date(NOW);
    end
    if IsExitLong(main_source, entry_period) and last_exit ~= main_source:date(NOW) then
        if AllowTrade then
            CloseTrades("B");
        else
            Signal("Exit long", main_source);
        end
        last_exit = main_source:date(NOW);
    end
    if IsExitShort(main_source, entry_period) and last_exit ~= main_source:date(NOW) then
        if AllowTrade then
            CloseTrades("S");
        else
            Signal("Exit short", main_source);
        end
        last_exit = main_source:date(NOW);
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
    return count >= position_limit;
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
    valuemap.Quantity = Amount * base_size;
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