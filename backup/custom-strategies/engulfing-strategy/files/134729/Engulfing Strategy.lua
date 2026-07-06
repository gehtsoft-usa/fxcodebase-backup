-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=69984

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

-- START OF CUSTOMIZATION SECTION
-- Trading time parameters. You can turn it off if you never use it.
local IncludeTradingTime = true;
-- Whether to take into account positions created only by this strategy
-- or take into account positions created by other strategies and by the user as well.
-- If set to false the strategy may close positions created by the user and other strategies
local UseOwnPositionsOnly = true;

-- History preload count
local HISTORY_PRELOAD_BARS = 300;
-- Whether to request both prices: bid and ask
local RequestBidAsk = false;
-- wether to allow timeframes like m2 (true) or limit to the standard ones (false)
local USE_CUSTOM_TIMEFRAMES = false;

local ENFORCE_POSITION_CAP = false;

-- Enforce execution type. When set to Live/EndOfTurn the execution type parameters will be hiden
local ENFORCE_entry_execution_type = nil; -- Live/EndOfTurn
local ENFORCE_exit_execution_type = nil; -- Live/EndOfTurn
local EXIT_TIMEFRAME_IN_PARAMS = false;
local DISABLE_EXIT = true;

local STRATEGY_NAME = "Engulfing Strategy";
local STRATEGY_VERSION = "1";
-- END OF CUSTOMIZATION SECTION

local Modules = {};
local EntryActions = {};
local ExitActions = {};
local LAST_ID = 2;

-- START OF USER DEFINED SECTION
-- Set it to true when you define your own timeframe and is_bid parameters
local CustomTimeframeDefined = false;

function OnNewBar(source, period) end
function CreateParameters()
	strategy.parameters:addBoolean("Complet", "Use Complet candle", "", false)
	strategy.parameters:addBoolean("Same", "Same Color Filter", "", false)
	strategy.parameters:addBoolean("ma", "MA Filter", "", false)
	strategy.parameters:addInteger("Period", "MA Period", "Period", 50)
	strategy.parameters:addString("Method", "MA Method", "Method", "MVA")
	strategy.parameters:addStringAlternative("Method", "MVA", "MVA", "MVA")
	strategy.parameters:addStringAlternative("Method", "EMA", "EMA", "EMA")
	strategy.parameters:addStringAlternative("Method", "LWMA", "LWMA", "LWMA")
	strategy.parameters:addStringAlternative("Method", "TMA", "TMA", "TMA")
	strategy.parameters:addStringAlternative("Method", "SMMA", "SMMA", "SMMA")
	strategy.parameters:addStringAlternative("Method", "KAMA", "KAMA", "KAMA")
	strategy.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA")
	strategy.parameters:addStringAlternative("Method", "WMA", "WMA", "WMA")
end

local indi;
function CreateEntryIndicators(source) 
    local profile = core.indicators:findIndicator("ENGULFING");
    assert(profile ~= nil, "Please, download and install " .. "ENGULFING" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indicatorParams:setBoolean("Complet", instance.parameters.Complet);
    indicatorParams:setBoolean("Same", instance.parameters.Same);
    indicatorParams:setBoolean("ma", instance.parameters.ma);
    indicatorParams:setInteger("Period", instance.parameters.Period);
    indicatorParams:setString("Method", instance.parameters.Method);
    indi = core.indicators:create("ENGULFING", source, indicatorParams)
end
function CreateExitIndicators(source) end

function UpdateIndicators()
    indi:update(core.UpdateLast);
end

function LogIndicatorsHeaders(log)
    --log[#log + 1] = indi.DATA:name();
end

function LogIndicatorsValues(log, period)
    --log[indi.DATA:name()] = tostring(indi.DATA[period]);
end

function CreateCustomActions()
    if not DISABLE_EXIT then
        local exitLongAction = {};
        exitLongAction.ActOnSwitch = false;
        exitLongAction.Cache = {};
        exitLongAction.IsPass = function (source, period, periodFromLast, data)
            return false; -- TODO: implement
        end

        local exitShortAction = {};
        exitShortAction.ActOnSwitch = false;
        exitShortAction.Cache = {};
        exitShortAction.IsPass = function (source, period, periodFromLast, data)
            return false; -- TODO: implement
        end
        if instance.parameters.Direction == "direct" then
            exitLongAction.Execute = CloseLong;
            exitShortAction.Execute = CloseShort;
        else
            exitLongAction.Execute = CloseShort;
            exitShortAction.Execute = CloseLong;
        end
        ExitActions[#ExitActions + 1] = exitLongAction;
        ExitActions[#ExitActions + 1] = exitShortAction;
    end

    local enterLongAction = {};
    enterLongAction.ActOnSwitch = true;
    enterLongAction.Cache = {};
    enterLongAction.AddHeaders = function (headers)
        --headers[#headers + 1] = "Buy value name";
    end
    enterLongAction.AddLog = function (source, period, periodFromLast, data, values)
        --values["Buy value name"] = value;
    end
    enterLongAction.IsPass = function (source, period, periodFromLast, data)
        return indi:getTextOutput(0):hasData(period);
    end

    local enterShortAction = {};
    enterShortAction.ActOnSwitch = true;
    enterShortAction.Cache = {};
    enterShortAction.AddHeaders = function (headers)
        --headers[#headers + 1] = "Sell value name";
    end
    enterShortAction.AddLog = function (source, period, periodFromLast, data, values)
        --values["Sell value name"] = value;
    end
    enterShortAction.IsPass = function (source, period, periodFromLast, data)
        return indi:getTextOutput(1):hasData(period);
    end

    if instance.parameters.Direction == "direct" then
        enterLongAction.Execute = GoLong;
        enterShortAction.Execute = GoShort;
        enterLongAction.ExecuteData = CreateBuyPositions(trading_logic.MainSource);
        enterShortAction.ExecuteData = CreateSellPositions(trading_logic.MainSource);
    else
        enterLongAction.Execute = GoShort;
        enterShortAction.Execute = GoLong;
        enterLongAction.ExecuteData = CreateSellPositions(trading_logic.MainSource);
        enterShortAction.ExecuteData = CreateBuyPositions(trading_logic.MainSource);
    end
    EntryActions[#EntryActions + 1] = enterLongAction;
    EntryActions[#EntryActions + 1] = enterShortAction;
end

function GetSignalSerial(source, period)
    --if renko.DATA:size() < 2 then
    --     return nil;
    --end
    --return renko.DATA:date(NOW);
    return source:serial(period);
end
-- END OF USER DEFINED SECTION

function Init()
    strategy:name(STRATEGY_NAME .. " v" .. STRATEGY_VERSION);
    strategy:description("");
    strategy:type(core.Both);
    strategy:setTag("Version", STRATEGY_VERSION);
    strategy:setTag("NonOptimizableParameters", "StartTime,StopTime,ToTime,signaler_ToTime,signaler_show_alert,signaler_play_soundsignaler_sound_file,signaler_recurrent_sound,signaler_send_email,signaler_email,signaler_show_popup,signaler_debug_alert,use_advanced_alert,advanced_alert_key");

    CreateParameters();

    strategy.parameters:addGroup("Trading");
    strategy.parameters:addString("Direction", "Type of Signal / Trade", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Reverse", "", "reverse");
    trading_logic:Init(strategy.parameters);
    trading.AddLimitParameter = SetCustomLimit == nil;
    trading:Init(strategy.parameters, 1);
    strategy.parameters:addGroup("Time Parameters");
    strategy.parameters:addInteger("ToTime", "Convert the date to", "", core.TZ_TS);
    strategy.parameters:addIntegerAlternative("ToTime", "EST", "", core.TZ_EST);
    strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", core.TZ_UTC);
    strategy.parameters:addIntegerAlternative("ToTime", "Local", "", core.TZ_LOCAL);
    strategy.parameters:addIntegerAlternative("ToTime", "Server", "", core.TZ_SERVER);
    strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", core.TZ_FINANCIAL);
    strategy.parameters:addIntegerAlternative("ToTime", "Display", "", core.TZ_TS);
    
    if IncludeTradingTime then
        strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
        strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");
    end
    strategy.parameters:addBoolean("use_mandatory_closing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("mandatory_closing_exit_time", "Mandatory Closing Time", "", "23:59:59");
    strategy.parameters:addInteger("mandatory_closing_valid_interval", "Valid Interval for Operation, in second", "", 60);
    strategy.parameters:addGroup("Alert");
    signaler:Init(strategy.parameters);

    strategy.parameters:addBoolean("add_log", "Add log info to signals", "", false);
    strategy.parameters:addFile("log_file", "Log file (csv)", "You can open it in Excel", core.app_path() .. "\\log\\" .. STRATEGY_NAME .. ".csv");
end

function CreateAction(id)
    local actionType = instance.parameters:getString("Action" .. id);
    local action = {};
    action.Cache = {};
    if actionType == "NO" then
        action.Execute = DisabledAction;
    elseif actionType == "SELL" then
        action.Execute = GoShort;
        action.ExecuteData = CreateSellPositions(trading_logic.MainSource);
    elseif actionType == "BUY" then
        action.Execute = GoLong;
        action.ExecuteData = CreateBuyPositions(trading_logic.MainSource);
    elseif actionType == "CLOSE" then
        action.Execute = CloseAll;
    end

    return action, actionType ~= "CLOSE";
end

function AddAction(id, name)
    strategy.parameters:addString("Action" .. id, name, "", "NO")
    strategy.parameters:addStringAlternative("Action" .. id, "No Action", "", "NO")
    strategy.parameters:addStringAlternative("Action" .. id, "Sell", "", "SELL")
    strategy.parameters:addStringAlternative("Action" .. id, "Buy", "", "BUY")
    strategy.parameters:addStringAlternative("Action" .. id, "Close Position", "", "CLOSE")
end

local MANDATORY_CLOSE_TIMER_ID = 1;
local TICKS_SOURCE_ID = 2;

local tick_source;
local ToTime;
local custom_id;
local OpenTime, CloseTime, exit_time;
local last_serial;

function CreatePositions(side, source)
    local positions = {};
    positions[#positions + 1] = CreatePositionStrategy(source, side, "");
    return positions;
end

function CreateBuyPositions(source)
    if instance.parameters.allow_side == "sell" then
        return {};
    end
    return CreatePositions("B", source);
end

function CreateSellPositions(source)
    if instance.parameters.allow_side == "buy" then
        return {};
    end
    return CreatePositions("S", source);
end

local add_log;
local log_file;
local use_mandatory_closing;
local headers = {};

function Prepare(name_only)
    trading_logic.HistoryPreloadBars = HISTORY_PRELOAD_BARS;
    trading_logic.RequestBidAsk = RequestBidAsk;
    add_log = instance.parameters.add_log;
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end

    instance:name(profile:id() .. "(" .. instance.bid:name() ..  ")");
    if name_only then 
        return ; 
    end
    use_mandatory_closing = instance.parameters.use_mandatory_closing;

    CreateEntryIndicators(trading_logic.MainSource);
    CreateExitIndicators(trading_logic.ExitSource);
    CreateCustomActions();

    if add_log then
        log_file = io.open(instance.parameters.log_file, "w");
        headers[#headers + 1] = "date";
        for _, action in ipairs(EntryActions) do
            if action.AddLog ~= nil then
                action.AddHeaders(headers);
            end
        end
        for _, action in ipairs(ExitActions) do
            if action.AddLog ~= nil then
                action.AddHeaders(headers);
            end
        end
        LogIndicatorsHeaders(headers);
        for i, header in ipairs(headers) do
            log_file:write(header .. ";")
        end
        log_file:write("\n");
    end

    local valid;
    if IncludeTradingTime then
        OpenTime, valid = ParseTime(instance.parameters.StartTime);
        assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
        CloseTime, valid = ParseTime(instance.parameters.StopTime);
        assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");
    end
    ToTime = instance.parameters.ToTime;
    trading_logic.DoTrading = EntryFunction;
    trading_logic.DoExit = ExitFunction;
    if instance.parameters.custom_id == "" then
        custom_id = instance.parameters.custom_id;
    else
        custom_id = profile:id() .. "_" .. instance.bid:name();
    end

    if use_mandatory_closing then
        exit_time, valid = ParseTime(instance.parameters.mandatory_closing_exit_time);
        assert(valid, "Time " .. instance.parameters.mandatory_closing_exit_time .. " is invalid");
        core.host:execute("setTimer", MANDATORY_CLOSE_TIMER_ID, math.max(instance.parameters.mandatory_closing_valid_interval / 2, 1));
    end
end

function CreatePositionStrategy(source, side, id)
    local position_strategy = {};
    if SetCustomStop == nil then
        position_strategy.StopType = instance.parameters:getString("stop_type" .. id);
    elseif SaveCustomStopParameters ~= nil then
        SaveCustomStopParameters(position_strategy, id);
    end
    if SetCustomLimit == nil then
        position_strategy.LimitType = instance.parameters:getString("limit_type" .. id);
        assert(position_strategy.LimitType ~= "stop" or position_strategy.StopType == "pips" or CreateStopParameters ~= nil, "To use limit based on stop you need to set stop in pips");
    elseif SaveCustomLimitParameters ~= nil then
        SaveCustomLimitParameters(position_strategy, id);
    end

    position_strategy.Id = id;
    position_strategy.Side = side;
    position_strategy.Source = source;
    position_strategy.Amount = instance.parameters:getInteger("amount" .. id);
    position_strategy.Amount_Type = instance.parameters:getString("amount_type" .. id);
    if SetCustomStop == nil then
        position_strategy.Stop = instance.parameters:getDouble("stop" .. id);
        if instance.parameters:getBoolean("use_trailing" .. id) then
            position_strategy.Trailing = instance.parameters:getInteger("trailing" .. id);
        end
    end
    if SetCustomLimit == nil then
        position_strategy.Limit = instance.parameters:getDouble("limit" .. id);
    end
    if CreateCustomBreakeven == nil then
        position_strategy.UseBreakeven = instance.parameters:getBoolean("use_breakeven" .. id);
        position_strategy.BreakevenWhen = instance.parameters:getDouble("breakeven_when" .. id);
        position_strategy.BreakevenTo = instance.parameters:getDouble("breakeven_to" .. id);
        position_strategy.BreakevenTrailing = instance.parameters:getString("breakeven_trailing");
        position_strategy.BreakevenTrailingValue = instance.parameters:getInteger("trailing" .. id);
        if instance.parameters:getBoolean("breakeven_close" .. id) then
            position_strategy.BreakevenCloseAmount = instance.parameters:getDouble("breakeven_close_amount" .. id);
        end
        if position_strategy.UseBreakeven and tick_source == nil then
            tick_source, TICKS_SOURCE_ID = trading_logic:SubscribeHistory(position_strategy.Source.close:instrument(), "t1", true);
        end
    end

    function position_strategy:SetDefaultLimit(command, stop_value, period)
        if self.LimitType == "pips" then
            return command:SetPipLimit(nil, self.Limit);
        end
        if self.LimitType == "stop" then
            if stop_value == nil then
                if self.Side == "B" then
                    stop_value = (instance.ask[NOW] - command.valuemap.RateStop) / instance.bid:pipSize();
                else
                    stop_value = (command.valuemap.RateStop - instance.bid[NOW]) / instance.bid:pipSize();
                end
            end
            return command:SetPipLimit(nil, stop_value * self.Limit);
        end
        if self.LimitType == "highlow" then
            if self.Side == "B" then
                return command:SetPipLimit(nil, (self.Source.high[period] - self.Source.close[period]) / self.Source:pipSize() + self.Limit);
            end
            return command:SetPipLimit(nil, (self.Source.close[period] - self.Source.low[period]) / self.Source:pipSize() + self.Limit);
        end
        return command;
    end

    function position_strategy:Open(period, periods_from_last)
        local rate = nil;
        if GetEntryRate ~= nil then
            rate = GetEntryRate(self.Source, self.Side, period);
        end
        local command;
        if rate == nil then
            command = trading:MarketOrder(self.Source.close:instrument());
        else
            command = trading:EntryOrder(self.Source.close:instrument())
                :SetRate(rate);
        end
        command:SetSide(self.Side)
            :SetAccountID(instance.parameters.account)
            :SetCustomID(custom_id);
        if self.Amount_Type == "lots" then
            command:SetAmount(self.Amount)
        elseif self.Amount_Type == "risk_equity" then
            command:SetRiskPercentOfEquityAmount(self.Amount)
        elseif self.Amount_Type == "equity" then
            command:SetPercentOfEquityAmount(self.Amount)
        end
        local default_stop = SetCustomStop == nil or not SetCustomStop(self, command, period, periods_from_last, source);
        local default_limit = SetCustomLimit == nil or not SetCustomLimit(self, command, period, periods_from_last, source);
        if default_stop then
            local stop_value;
            if self.StopType == "pips" then
                stop_value = self.Stop;
                command = command:SetPipStop(nil, self.Stop, self.Trailing);
            elseif self.StopType == "highlow" then
                if self.Side == "B" then
                    stop_value = (self.Source.close[period] - self.Source.low[period]) / self.Source:pipSize() + self.Stop;
                    command = command:SetPipStop(nil, stop_value, self.Trailing);
                else
                    stop_value = (self.Source.high[period] - self.Source.close[period]) / self.Source:pipSize() + self.Stop;
                    command = command:SetPipStop(nil, stop_value, self.Trailing);
                end
            end
        end
        if default_limit then
            command = self:SetDefaultLimit(command, stop_value, period);
        end
        local result = command:Execute();
        if result.Finished and not result.Success then
            return result;
        end
        local default_breakeven = CreateCustomBreakeven == nil or not CreateCustomBreakeven(self, result, period, periods_from_last);
        if default_breakeven then
            if self.UseBreakeven then
                local controller = breakeven:CreateController()
                    :SetRequestID(result.RequestID)
                    :SetWhen(self.BreakevenWhen)
                    :SetTo(self.BreakevenTo);
                if self.BreakevenTrailing == "set" then
                    controller:SetTrailing(self.BreakevenTrailingValue);
                end
                if self.BreakevenCloseAmount ~= nil then
                    controller:SetPartialClose(self.BreakevenCloseAmount);
                end
            end
        end
        return result;
    end
    function position_strategy:CreateTrailingLimit(result)
        if self.TrailingLimitType == "Unfavorable" then
            breakeven:CreateTrailingLimitController()
                :SetDirection(-1)
                :SetTrigger(self.TrailingLimitTrigger)
                :SetStep(self.TrailingLimitStep)
                :SetRequestID(result.RequestID);
        elseif self.TrailingLimitType == "Favorable" then
            breakeven:CreateTrailingLimitController()
                :SetDirection(1)
                :SetTrigger(self.TrailingLimitTrigger)
                :SetStep(self.TrailingLimitStep)
                :SetRequestID(result.RequestID);
        end
    end
    return position_strategy;
end

function EnsureIndicatorInstalled(name)
    local profile = core.indicators:findIndicator(name);
    assert(profile ~= nil, "Please, download and install " .. name .. ".LUA indicator");
    return profile;
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

local log_values;
function ExtUpdate(id, source, period)
    if id == trading_logic._trading_source_id then
        OnNewBar(source, period);
    end
    if use_mandatory_closing and core.host.Trading:getTradingProperty("isSimulation") then
        DoMandatoryClosing();
    end
    UpdateIndicators();
    if log_file ~= nil then
        log_values = {};
        log_values["date"] = core.formatDate(core.host:execute("getServerTime"));
        LogIndicatorsValues(log_values, period);
    end
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end 
    if log_file ~= nil then
        for i, header in ipairs(headers) do
            log_file:write(tostring(log_values[header]) .. ";");
        end
        log_file:write("\n");
        log_file:flush();
    end
end
function ReleaseInstance() 
    for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end 
    if log_file ~= nil then
        log_file:close();
    end
end

function DoCloseOnOpposite(side)
    if instance.parameters.close_on_opposite then
        local it = trading:FindTrade():WhenSide(trading:getOppositeSide(side))
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        it:Do(function (trade) trading:Close(trade); end);
    end
end

function DisabledAction(source, period) return false; end

function CloseAll(source, period)
    local closedCount = 0;
    if instance.parameters.allow_trade then
        local it = trading:FindTrade();
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        closedCount = it:Do(function (trade) trading:Close(trade); end);
    end
    if closedCount > 0 then
        signaler:Signal("Close all for " .. source.close:instrument(), source);
    end
end

function CloseLong(source, period)
    local closedCount = 0;
    if instance.parameters.allow_trade then
        local it = trading:FindTrade():WhenSide("B");
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        closedCount = it:Do(function (trade) trading:Close(trade); end);
    end
    if closedCount > 0 then
        signaler:Signal("Close long for " .. source.close:instrument(), source);
    end
end

function CloseShort(source, period)
    local closedCount = 0;
    if instance.parameters.allow_trade then
        local it = trading:FindTrade():WhenSide("S");
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        closedCount = it:Do(function (trade) trading:Close(trade); end);
    end
    if closedCount > 0 then
        signaler:Signal("Close short for " .. source.close:instrument(), source);
    end
end

function IsPositionLimitHit(side, side_limit)
    if ENFORCE_POSITION_CAP == true then
        local sideIt = trading:FindTrade();
        local allIt = trading:FindTrade();
        if UseOwnPositionsOnly then
            sideIt:WhenCustomID(custom_id);
            allIt:WhenCustomID(custom_id)
        end
        local side_positions = sideIt:Count();
        local positions = allIt:Count();
        return positions >= 1 or side_positions >= 1;
    end
    if not instance.parameters.position_cap then
        return false;
    end
    local sideIt = trading:FindTrade()
        :WhenSide(side);
    local allIt = trading:FindTrade();
    if UseOwnPositionsOnly then
        sideIt:WhenCustomID(custom_id);
        allIt:WhenCustomID(custom_id)
    end
    local side_positions = sideIt:Count();
    local positions = allIt:Count();
    return positions >= instance.parameters.no_of_positions or side_positions >= side_limit;
end

function GoLong(source, period, positions, log)
    if instance.parameters.allow_trade then
        DoCloseOnOpposite("B");
        if IsPositionLimitHit("B", instance.parameters.no_of_buy_position) then
            signaler:Signal("Positions limit has been reached", source);
            return;
        end
        for _, position in ipairs(positions) do
            position:Open(period, source:size() - period - 1);
        end
    end
    local message = "Buy " .. source.close:instrument()
    if log ~= nil then
        message = message .. "\r\nSignal info: " .. log;
    end
    signaler:Signal(message, source);
    last_serial = GetSignalSerial(source, period);
end

function GoShort(source, period, positions, log)
    if instance.parameters.allow_trade then
        DoCloseOnOpposite("S");
        if IsPositionLimitHit("S", instance.parameters.no_of_sell_position) then
            signaler:Signal("Positions limit has been reached", source);
            return;
        end
        for _, position in ipairs(positions) do
            position:Open(period, source:size() - period - 1);
        end
    end
    local message = "Sell " .. source.close:instrument()
    if log ~= nil then
        message = message .. "\nSignal info: " .. log;
    end
    signaler:Signal(message, source);
    last_serial = GetSignalSerial(source, period);
end
function EntryFunction(source, period)
    local current_serial = GetSignalSerial(source, period);
    if last_serial == current_serial then
        return;
    end
    local now = core.host:execute("convertTime", core.TZ_EST, ToTime, core.host:execute("getServerTime"));
    now = now - math.floor(now);
    if IncludeTradingTime then
        if not InRange(now, OpenTime, CloseTime) then
            return;
        end
    end

    local periodFromLast = source:size() - period - 1;
    for _, action in ipairs(EntryActions) do
        local isPass = action.IsPass(source, period, periodFromLast, action.Data);
        action.Cache[current_serial] = isPass;
        if action.CurrentSerial ~= current_serial then
            action.LastSerial = action.CurrentSerial;
            action.CurrentSerial = current_serial;
        end

        if add_log and action.AddLog ~= nil then
            action.AddLog(source, period, periodFromLast, action.Data, log_values);
        end

        if isPass and (not action.ActOnSwitch or action.Cache[action.LastSerial] == false) then
            action.Execute(source, period, action.ExecuteData);
        end
    end
end

function ExitFunction(source, period)
    local current_serial = GetSignalSerial(source, period);
    if last_serial == current_serial then
        return;
    end
    local now = core.host:execute("convertTime", core.TZ_EST, ToTime, core.host:execute("getServerTime"));
    now = now - math.floor(now);
    if IncludeTradingTime then
        if not InRange(now, OpenTime, CloseTime) then
            return;
        end
    end

    local periodFromLast = source:size() - period - 1;
    for _, action in ipairs(ExitActions) do
        local isPass = action.IsPass(source, period, periodFromLast, action.Data);
        action.Cache[current_serial] = isPass;
        if action.CurrentSerial ~= current_serial then
            action.LastSerial = action.CurrentSerial;
            action.CurrentSerial = current_serial;
        end
        
        if add_log and action.AddLog ~= nil then
            action.AddLog(source, period, periodFromLast, action.Data, log_values);
        end
        
        if isPass and (not action.ActOnSwitch or action.Cache[action.LastSerial] == false) then
            action.Execute(source, period, action.ExecuteData);
        end
    end
end

function DoMandatoryClosing()
    local now = core.host:execute("convertTime", core.TZ_EST, ToTime, core.host:execute("getServerTime"));
    now = now - math.floor(now);
    if InRange(now, exit_time, exit_time + (instance.parameters.mandatory_closing_valid_interval / 86400.0)) then
        local it = trading:FindTrade();
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        it:Do(function (trade) trading:Close(trade); end );
        signaler:Signal("Mandatory closing");
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == MANDATORY_CLOSE_TIMER_ID then
        DoMandatoryClosing();
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

breakeven = {};
-- public fields
breakeven.Name = "Breakeven";
breakeven.Version = "2.1";
breakeven.Debug = false;
--private fields
breakeven._moved_stops = {};
breakeven._request_id = nil;
breakeven._used_stop_orders = {};
breakeven._ids_start = nil;
breakeven._trading = nil;
breakeven._controllers = {};

function breakeven:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function breakeven:OnNewModule(module)
    if module.Name == "Trading" then self._trading = module; end
    if module.Name == "Tables monitor" then
        module:ListenCloseTrade(BreakevenOnClosedTrade);
    end
    if module.Name == "Signaler" then
        self._signaler = module;
    end
end
function BreakevenOnClosedTrade(closed_trade)
    for _, controller in ipairs(breakeven._controllers) do
        if controller.TradeID == closed_trade.TradeID then
            controller._trade = core.host:findTable("trades"):find("TradeID", closed_trade.TradeIDRemain);
            controller.TradeID = closed_trade.TradeIDRemain;
        elseif controller.TradeID == closed_trade.TradeIDRemain then
            controller._executed = true;
            controller._close_percent = nil;
        end
    end
end
function breakeven:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function breakeven:Init(parameters)
end

function breakeven:Prepare(nameOnly)
end

function breakeven:ExtUpdate(id, source, period)
    for _, controller in ipairs(self._controllers) do
        controller:DoBreakeven();
    end
end

function breakeven:round(num, idp)
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function breakeven:CreateBaseController()
    local controller = {};
    controller._parent = self;
    controller._executed = false;
    function controller:SetTrade(trade)
        self._trade = trade;
        self.TradeID = trade.TradeID;
        return self;
    end
    function controller:GetOffer()
        if self._offer == nil then
            local order = self:GetOrder();
            if order == nil then
                order = self:GetTrade();
            end
            self._offer = core.host:findTable("offers"):find("Instrument", order.Instrument);
        end
        return self._offer;
    end
    function controller:SetRequestID(trade_request_id)
        self._request_id = trade_request_id;
        return self;
    end
    function controller:GetOrder()
        if self._order == nil then
            self._order = core.host:findTable("orders"):find("RequestID", self._request_id);
        end
        return self._order;
    end
    function controller:GetTrade()
        if self._trade == nil and self._request_id ~= nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self._request_id);
            if self._trade == nil then
                return nil;
            end
            self.TradeID = self._trade.TradeID;
            self._initial_limit = self._trade.Limit;
            self._initial_stop = self._trade.Stop;
        end
        return self._trade;
    end
    return controller;
end

function breakeven:CreateMartingale(openFunction)
    local controller = self:CreateBaseController();
    controller.OpenFunction = openFunction;
    function controller:SetStep(step)
        self._step = step;
        return self;
    end
    function controller:SetLotSizingValue(martingale_lot_sizing_val)
        self._martingale_lot_sizing_val = martingale_lot_sizing_val;
        return self;
    end
    function controller:SetStop(Stop)
        self._martingale_stop = Stop;
        return self;
    end
    function controller:SetLimit(Limit)
        self._martingale_limit = Limit;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if self._current_lot == nil then
            self._current_lot = trade.AmountK;
        end
        local pipSize = self:GetOffer().PointSize;
        if trade.BS == "B" then
            local movement = (trade.Close - trade.Open) / pipSize;
            local enoughtMovement = false;
            if self._step >= 0 then
                enoughtMovement = movement <= -self._step;
            else
                enoughtMovement = movement >= -self._step;
            end
            if enoughtMovement then
                self._current_lot = self._current_lot * self._martingale_lot_sizing_val;
                local result = self.OpenFunction("B", math.floor(self._current_lot + 0.5), trade);
                self._trade = nil;
                self:SetRequestID(result.RequestID);
                if self._signaler ~= nil then
                    local command = string.format("action=create symbol=%s side=buy quantity=%s"
                        , trade.Instrument
                        , tostring(math.floor(self._current_lot + 0.5)));
                    self._signaler:SendCommand(command);
                end
                return true;
            end
        else
            local movement = (trade.Open - trade.Close) / pipSize;
            if self._step >= 0 then
                enoughtMovement = movement <= -self._step;
            else
                enoughtMovement = movement >= -self._step;
            end
            if enoughtMovement then
                self._current_lot = self._current_lot * self._martingale_lot_sizing_val;
                local result = self.OpenFunction("S", math.floor(self._current_lot + 0.5), trade);
                self._trade = nil;
                self:SetRequestID(result.RequestID);
                if self._signaler ~= nil then
                    local command = string.format("action=create symbol=%s side=sell quantity=%s"
                        , trade.Instrument
                        , tostring(math.floor(self._current_lot + 0.5)));
                    self._signaler:SendCommand(command);
                end
                return true;
            end
        end
        self:UpdateStopLimits();
        return true;
    end
    function controller:CloseAll()
        core.host:trace("Closing all positions");
        local it = trading:FindTrade():WhenCustomID(CustomID)
        it:Do(function (trade) trading:Close(trade); end);
        if self._signaler ~= nil then
            signaler:SendCommand("action=close");
        end
        self._executed = true;
    end
    function controller:UpdateStopLimits()
        local trade = self:GetTrade();
        if trade == nil then
            return;
        end
        local offer = self:GetOffer();
        local bAmount = 0;
        local bPriceSumm = 0;
        local sAmount = 0;
        local sPriceSumm = 0;
        trading:FindTrade()
            :WhenCustomID(CustomID)
            :Do(function (trade)
                if trade.BS == "B" then
                    bAmount = bAmount + trade.AmountK
                    bPriceSumm = bPriceSumm + trade.Open * trade.AmountK;
                else
                    sAmount = sAmount + trade.AmountK
                    sPriceSumm = sPriceSumm + trade.Open * trade.AmountK;
                end
            end);
        local avgBPrice = bPriceSumm / bAmount;
        local avgSPrice = sPriceSumm / sAmount;
        local totalAmount = bAmount + sAmount;
        local avgPrice = avgBPrice * (bAmount / totalAmount) + avgSPrice * (sAmount / totalAmount);
        local stopPrice, limitPrice;
        if trade.BS == "B" then
            if self._martingale_stop ~= nil then
                stopPrice = avgPrice - self._martingale_stop * offer.PointSize;
                if trade.Close <= stopPrice then
                    self:CloseAll();
                end
                return;
            end
            if self._martingale_limit ~= nil then
                limitPrice = avgPrice + self._martingale_limit * offer.PointSize;
                if trade.Close >= limitPrice then
                    self:CloseAll();
                end
            end
            return;
        end
        if self._martingale_stop ~= nil then
            stopPrice = avgPrice + self._martingale_stop * offer.PointSize;
            if trade.Close >= stopPrice then
                self:CloseAll();
                return;
            end
        end
        if self._martingale_limit ~= nil then
            limitPrice = avgPrice - self._martingale_limit * offer.PointSize;
            if trade.Close <= limitPrice then
                self:CloseAll();
            end
        end
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

breakeven.STOP_ID = 1;
breakeven.LIMIT_ID = 2;

function breakeven:CreateOrderTrailingController()
    local controller = self:CreateBaseController();
    function controller:SetTrailingTarget(id)
        self._target_id = id;
        return self;
    end
    function controller:MoveUpOnly()
        self._up_only = true;
        return self;
    end
    function controller:SetIndicatorStream(stream, multiplicator, is_distance)
        self._stream = stream;
        self._stream_in_distance = is_distance;
        self._stream_multiplicator = multiplicator;
        return self;
    end
    function controller:SetIndicatorStreamShift(x, y)
        self._stream_x_shift = x;
        self._stream_y_shift = y;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local order = self:GetOrder();
        if order == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not order:refresh() then
            self._executed = true;
            return false;
        end
        local streamPeriod = NOW;
        if self._stream_x_shift ~= nil then
            streamPeriod = streamPeriod - self._stream_x_shift;
        end
        if not self._stream:hasData(streamPeriod) then
            return true;
        end
        return self:DoOrderTrailing(order, streamPeriod);
    end
    function controller:DoOrderTrailing(order, streamPeriod)
        local new_level;
        local offer = self:GetOffer();
        if self._stream_in_distance then
            local tick = self._stream:tick(streamPeriod) * self._stream_multiplicator;
            if self._stream_y_shift ~= nil then
                tick = tick + self._stream_y_shift * offer.PointSize;
            end
            if order.BS == "B" then
                new_level = breakeven:round(offer.Bid + tick, offer.Digits);
            else
                new_level = breakeven:round(offer.Ask - tick, offer.Digits);
            end
        else
            local tick = self._stream:tick(streamPeriod);
            if self._stream_y_shift ~= nil then
                if order.BS == "B" then
                    tick = tick - self._stream_y_shift * offer.PointSize;
                else
                    tick = tick + self._stream_y_shift * offer.PointSize;
                end
            end
            new_level = breakeven:round(tick, offer.Digits);
        end
        if self._up_only then
            if order.BS == "B" then
                if order.Rate >= new_level then
                    return true;
                end
            else
                if order.Rate <= new_level then
                    return true;
                end
            end
        end
        if self._min_profit ~= nil then
            if order.BS == "B" then
                if (offer.Bid - new_level) / offer.PointSize < self._min_profit then
                    return true;
                end
            else
                if (new_level - offer.Ask) / offer.PointSize < self._min_profit then
                    return true;
                end
            end
        end
        if order.Rate ~= new_level then
            self._move_command = self._parent._trading:ChangeOrder(order, new_level, order.TrlMinMove);
        end
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateIndicatorTrailingController()
    local controller = self:CreateBaseController();
    function controller:SetTrailingTarget(id)
        self._target_id = id;
        return self;
    end
    function controller:MoveUpOnly()
        self._up_only = true;
        return self;
    end
    function controller:SetMinProfit(min_profit)
        self._min_profit = min_profit;
        return self;
    end
    function controller:SetIndicatorStream(stream, multiplicator, is_distance)
        self._stream = stream;
        self._stream_in_distance = is_distance;
        self._stream_multiplicator = multiplicator;
        return self;
    end
    function controller:SetIndicatorStreamShift(x, y)
        self._stream_x_shift = x;
        self._stream_y_shift = y;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        local streamPeriod = NOW;
        if self._stream_x_shift ~= nil then
            streamPeriod = streamPeriod - self._stream_x_shift;
        end
        if not self._stream:hasData(streamPeriod) then
            return true;
        end
        if self._target_id == breakeven.STOP_ID then
            return self:DoStopTrailing(trade, streamPeriod);
        elseif self._target_id == breakeven.LIMIT_ID then
            return self:DoLimitTrailing(trade, streamPeriod);
        end
        return self:DoOrderTrailing(trade, streamPeriod);
    end
    function controller:DoStopTrailing(trade, streamPeriod)
        local new_level;
        local offer = self:GetOffer();
        if self._stream_in_distance then
            local tick = self._stream:tick(streamPeriod) * self._stream_multiplicator;
            if self._stream_y_shift ~= nil then
                tick = tick + self._stream_y_shift * offer.PointSize;
            end
            if trade.BS == "B" then
                new_level = breakeven:round(trade.Open - tick, offer.Digits);
            else
                new_level = breakeven:round(trade.Open + tick, offer.Digits);
            end
        else
            local tick = self._stream:tick(streamPeriod);
            if self._stream_y_shift ~= nil then
                if trade.BS == "B" then
                    tick = tick + self._stream_y_shift * offer.PointSize;
                else
                    tick = tick - self._stream_y_shift * offer.PointSize;
                end
            end
            new_level = breakeven:round(self._stream:tick(streamPeriod), offer.Digits);
        end
        if self._min_profit ~= nil then
            if trade.BS == "B" then
                if (new_level - trade.Open) / offer.PointSize < self._min_profit then
                    return true;
                end
            else
                if (trade.Open - new_level) / offer.PointSize < self._min_profit then
                    return true;
                end
            end
        end
        if self._up_only then
            if trade.BS == "B" then
                if trade.Stop >= new_level then
                    return true;
                end
            else
                if trade.Stop <= new_level then
                    return true;
                end
            end
            return true;
        end
        if trade.Stop ~= new_level then
            self._move_command = self._parent._trading:MoveStop(trade, new_level);
        end
        return true;
    end
    function controller:DoLimitTrailing(trade, streamPeriod)
        assert(self._up_only == nil, "Not implemented!!!");
        local new_level;
        local offer = self:GetOffer();
        if self._stream_in_distance then
            local tick = self._stream:tick(streamPeriod) * self._stream_multiplicator;
            if self._stream_y_shift ~= nil then
                tick = tick + self._stream_y_shift * offer.PointSize;
            end
            if trade.BS == "B" then
                new_level = breakeven:round(trade.Open + tick, offer.Digits);
            else
                new_level = breakeven:round(trade.Open - tick, offer.Digits);
            end
        else
            local tick = self._stream:tick(streamPeriod);
            if self._stream_y_shift ~= nil then
                if trade.BS == "B" then
                    tick = tick - self._stream_y_shift * offer.PointSize;
                else
                    tick = tick + self._stream_y_shift * offer.PointSize;
                end
            end
            new_level = breakeven:round(tick, offer.Digits);
        end
        if self._min_profit ~= nil then
            if trade.BS == "B" then
                if (trade.Open - new_level) / offer.PointSize < self._min_profit then
                    return true;
                end
            else
                if (new_level - trade.Open) / offer.PointSize < self._min_profit then
                    return true;
                end
            end
        end
        if trade.Limit ~= new_level then
            self._move_command = self._parent._trading:MoveLimit(trade, new_level);
        end
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateTrailingLimitController()
    local controller = self:CreateBaseController();
    function controller:SetDirection(direction)
        self._direction = direction;
        return self;
    end
    function controller:SetTrigger(trigger)
        self._trigger = trigger;
        return self;
    end
    function controller:SetStep(step)
        self._step = step;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if self._direction == 1 then
            if trade.PL >= self._trigger then
                local offer = self:GetOffer();
                local target_limit;
                if trade.BS == "B" then
                    target_limit = self._initial_limit + self._step * offer.PointSize; 
                else
                    target_limit = self._initial_limit - self._step * offer.PointSize; 
                end
                self._initial_limit = target_limit;
                self._trigger = self._trigger + self._step;
                self._move_command = self._parent._trading:MoveLimit(trade, target_limit);
                return true;
            end
        elseif self._direction == -1 then
            if trade.PL <= -self._trigger then
                local offer = self:GetOffer();
                local target_limit;
                if trade.BS == "B" then
                    target_limit = self._initial_limit - self._step * offer.PointSize; 
                else
                    target_limit = self._initial_limit + self._step * offer.PointSize; 
                end
                self._initial_limit = target_limit;
                self._trigger = self._trigger + self._step;
                self._move_command = self._parent._trading:MoveLimit(trade, target_limit);
                return true;
            end
        else
            core.host:trace("No direction is set for the trailing limit");
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:ActionOnTrade(action)
    local controller = self:CreateBaseController();
    controller._action = action;
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        self._action(trade, self);
        self._executed = true;
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateOnCandleClose()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    function controller:SetSource(source)
        self._source = source;
        return self;
    end
    function controller:SetBarsToLive(bars_to_live)
        self._bars_to_live = bars_to_live;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        local index = core.findDate(self._source, trade.Time, false);
        if self._source:size() - 1 - index >= self._bars_to_live then
            self._command = self._parent._trading:Close(trade);
            self._executed = true;
            return false;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:PartialClose()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    function controller:SetWhen(when)
        self._when = when;
        return self;
    end
    function controller:SetPartialClose(amountPercent)
        self._close_percent = amountPercent;
        return self;
    end
    function controller:DoPartialClose()
        
    end
    function controller:DoBreakeven()
        if self._close_percent == nil then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._close_percent = nil;
            return false;
        end
        if trade.PL >= self._when then
            local base_size = core.host:execute("getTradingProperty", "baseUnitSize", trade.Instrument, trade.AccountID);
            local to_close = breakeven:round(trade.Lot * self._close_percent / 100.0 / base_size) * base_size;
            trading:ParialClose(trade, to_close);
            self._close_percent = nil;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateController()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    function controller:SetWhen(when)
        self._when = when;
        return self;
    end
    function controller:SetTo(to)
        self._to = to;
        return self;
    end
    function controller:SetTrailing(trailing)
        self._trailing = trailing
        return self;
    end
    function controller:SetPartialClose(amountPercent)
        self._close_percent = amountPercent;
        return self;
    end
    function controller:getTo()
        local trade = self:GetTrade();
        local offer = self:GetOffer();
        if trade.BS == "B" then
            return offer.Bid - (trade.PL - self._to) * offer.PointSize;
        else
            return offer.Ask + (trade.PL - self._to) * offer.PointSize;
        end
    end
    function controller:DoPartialClose()
        local trade = self:GetTrade();
        if trade == nil then
            self._close_percent = nil;
            return true;
        end
        if not trade:refresh() then
            self._close_percent = nil;
            return false;
        end
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", trade.Instrument, trade.AccountID);
        local to_close = breakeven:round(trade.Lot * self._close_percent / 100.0 / base_size) * base_size;
        trading:ParialClose(trade, to_close);
        self._close_percent = nil;
        return true;
    end
    function controller:DoBreakeven()
        if self._executed then
            if self._close_percent ~= nil then
                if self._command ~= nil and self._command.Finished or self._command == nil then
                    return self:DoPartialClose();
                end
            end
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL >= self._when then
            if self._to ~= nil then
                self._command = self._parent._trading:MoveStop(trade, self:getTo(), self._trailing);
            end
            self._executed = true;
            return false;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:RestoreTrailingOnProfitController(controller)
    controller._parent = self;
    function controller:SetProfitPercentage(profit_pr, min_profit)
        self._profit_pr = profit_pr;
        self._min_profit = min_profit;
        return self;
    end
    function controller:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self._request_id);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function controller:getStopPips(trade)
        local stop = trading:FindStopOrder(trade);
        if stop == nil then
            return nil;
        end
        local offer = self:GetOffer();
        if trade.BS == "B" then
            return (stop.Rate - trade.Open) / offer.PointSize;
        else
            return (trade.Open - stop.Rate) / offer.PointSize;
        end
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        if self._move_command ~= nil and not self._move_command.Finished then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            if self:GetClosedTrade() ~= nil then
                self._executed = true;
            end
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL < self._min_profit then
            return true;
        end
        local new_stop = trade.PL * (self._profit_pr / 100);
        local current_stop = self:getStopPips(trade);
        if current_stop == nil or current_stop < new_stop then
            local offer = self:GetOffer();
            if trade.BS == "B" then
                if not trailing_mark:hasData(NOW) then
                    trailing_mark[NOW] = trade.Close;
                end
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open + new_stop * offer.PointSize);
            else
                if not trailing_mark:hasData(NOW) then
                    trailing_mark[NOW] = trade.Close;
                end
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open - new_stop * offer.PointSize);
            end
            return true;
        end
        return true;
    end
end

function breakeven:CreateTrailingOnProfitController()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    self:RestoreTrailingOnProfitController(controller);
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end
breakeven:RegisterModule(Modules);
signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.7";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};
signaler._commands = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and (self.last_req == nil or not self.last_req:loading()) then
        if #self._alerts > 0 then
            local data = self:ArrayToJSON(self._alerts);
            self._alerts = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        end
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(message, source)
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
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
    end
end

function signaler:SendCommand(command)
    if self._external_executer_key == nil or core.host.Trading:getTradingProperty("isSimulation") or command == "" then
        return;
    end
    local command = 
    {
        Text = command
    };
    self._commands[#self._commands + 1] = command;
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end

    parameters:addGroup("  Telegram/Discord/Other platforms");
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");

    parameters:addGroup("  Trade coping");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
    end
    if instance.parameters.external_executer_key ~= "" and instance.parameters.use_external_executer then
        self._external_executer_key = instance.parameters.external_executer_key;
    end
    if self.external_executer_key ~= nil or self._advanced_alert_key ~= nil then
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);
tables_monitor = {};
tables_monitor.Name = "Tables monitor";
tables_monitor.Version = "1.2";
tables_monitor.Debug = false;
tables_monitor._ids_start = nil;
tables_monitor._new_trade_id = nil;
tables_monitor._trade_listeners = {};
tables_monitor._closed_trade_listeners = {};
tables_monitor._close_order_listeners = {};
tables_monitor.closing_order_types = {};
function tables_monitor:ListenTrade(func)
    self._trade_listeners[#self._trade_listeners + 1] = func;
end
function tables_monitor:ListenCloseTrade(func)
    self._closed_trade_listeners[#self._closed_trade_listeners + 1] = func;
end
function tables_monitor:ListenCloseOrder(func)
    self._close_order_listeners[#self._close_order_listeners + 1] = func;
end
function tables_monitor:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function tables_monitor:Init(parameters) end
function tables_monitor:Prepare(name_only)
    if name_only then return; end
    self._new_trade_id = self._ids_start;
    self._order_change_id = self._ids_start + 1;
    self._ids_start = self._ids_start + 2;
    core.host:execute("subscribeTradeEvents", self._order_change_id, "orders");
    core.host:execute("subscribeTradeEvents", self._new_trade_id, "trades");
end
function tables_monitor:OnNewModule(module) end
function tables_monitor:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end
function tables_monitor:ReleaseInstance() end
function tables_monitor:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._new_trade_id then
        local trade_id = message;
        local close_trade = success;
        if close_trade then
            local closed_trade = core.host:findTable("closed trades"):find("TradeID", trade_id);
            if closed_trade ~= nil then
                for _, callback in ipairs(self._closed_trade_listeners) do
                    callback(closed_trade);
                end
            end
        else
            local trade = core.host:findTable("trades"):find("TradeID", message);
            if trade ~= nil then
                for _, callback in ipairs(self._trade_listeners) do
                    callback(trade);
                end
            end
        end
    elseif cookie == self._order_change_id then
        local order_id = message;
        local order = core.host:findTable("orders"):find("OrderID", order_id);
        local fix_status = message1;
        if order ~= nil then
            if order.Stage == "C" then
                self.closing_order_types[order.OrderID] = order.Type;
                for _, callback in ipairs(self._close_order_listeners) do
                    callback(order);
                end
            end
        end
    end
end
function tables_monitor:ExtUpdate(id, source, period) end
function tables_monitor:BlockTrading(id, source, period) return false; end
function tables_monitor:BlockOrder(order_value_map) return false; end
function tables_monitor:OnOrder(order_value_map) end
tables_monitor:RegisterModule(Modules);
trading_logic = {};
-- public fields
trading_logic.Name = "Trading logic";
trading_logic.Version = "1.13";
trading_logic.Debug = false;
trading_logic.DoTrading = nil;
trading_logic.DoExit = nil;
trading_logic.MainSource = nil;
trading_logic.HistoryPreloadBars = 300;
trading_logic.RequestBidAsk = false;
--private fields
trading_logic._histories = {};
trading_logic._ids_start = nil;
trading_logic._last_id = nil;
trading_logic._trading_source_id = nil;
function trading_logic:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading_logic:OnNewModule(module) end
function trading_logic:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; 
    self._last_id = self._ids_start - 1;
end
function trading_logic:Init(parameters)
    if not CustomTimeframeDefined then
        parameters:addBoolean("is_bid", "Price Type", "", true);
        parameters:setFlag("is_bid", core.FLAG_BIDASK);
        if not DISABLE_HA_SOURCE then
            parameters:addBoolean("ha_as_source", "Use HA as source", "", false);
        end
        parameters:addString("timeframe", "Entry Time frame", "", "m5");
        if USE_CUSTOM_TIMEFRAMES then
            parameters:setFlag("timeframe", core.FLAG_BARPERIODS_EDIT);
        else
            parameters:setFlag("timeframe", core.FLAG_BARPERIODS);
        end
    end
    if ENFORCE_entry_execution_type == nil then
        parameters:addString("entry_execution_type", "Entry Execution Type", "Once per bar close or on every tick", "EndOfTurn");
        parameters:addStringAlternative("entry_execution_type", "End of Turn", "", "EndOfTurn");
        parameters:addStringAlternative("entry_execution_type", "Live", "", "Live");
    end
    if not CustomTimeframeDefined and not DISABLE_EXIT and EXIT_TIMEFRAME_IN_PARAMS then
        parameters:addString("exit_timeframe", "Exit Time frame", "", "m5");
        if USE_CUSTOM_TIMEFRAMES then
            parameters:setFlag("exit_timeframe", core.FLAG_BARPERIODS_EDIT);
        else
            parameters:setFlag("exit_timeframe", core.FLAG_BARPERIODS);
        end
    end
    if ENFORCE_exit_execution_type == nil and not DISABLE_EXIT then
        parameters:addString("exit_execution_type", "Exit Execution Type", "Once per bar close or on every tick", "Live");
        parameters:addStringAlternative("exit_execution_type", "End of Turn", "", "EndOfTurn");
        parameters:addStringAlternative("exit_execution_type", "Live", "", "Live");
    end
end
function trading_logic:GetLastPeriod(source_period, source, target)
    if source_period < 0 or target:size() < 2 then
        return nil;
    end
    local s1, e1 = core.getcandle(source:barSize(), source:date(source_period), -7, 0);
    local s2, e2 = core.getcandle(target:barSize(), target:date(NOW - 1), -7, 0);
    if e1 == e2 then
        return target:size() - 2;
    else
        return target:size() - 1;
    end
end
function trading_logic:GetPeriod(source_period, source, target)
    if source_period < 0 then
        return nil;
    end
    local source_date = source:date(source_period);
    local index = core.findDate(target, source_date, false);
    if index == -1 then
        return nil;
    end
    return index;
end
function trading_logic:SubscribeHistory(instrument, timeframe, is_bid)
    if instrument == nil then
        instrument = instance.bid:instrument();
    end
    if self._histories[instrument] == nil then
    self._histories[instrument] = {};
    end
    if self._histories[instrument][timeframe] == nil then
    self._histories[instrument][timeframe] = {};
    end
    local data = self._histories[instrument][timeframe][is_bid];
    if data == nil then
        data = {};
        data.id = self._last_id + 1;
        data.source = ExtSubscribe1(data.id, instrument, timeframe, self.HistoryPreloadBars, is_bid, "bar");
        self._last_id = self._last_id + 1;
        self._histories[instrument][timeframe][is_bid] = data;
    end
    return data.source, data.id;
end
function trading_logic:Prepare(name_only)
    if name_only then
        return;
    end
    local exit_timeframe = instance.parameters.exit_timeframe or instance.parameters.timeframe;
    if instance.parameters.ha_as_source then
        local MainSource, mainId = self:SubscribeHistory(nil, instance.parameters.timeframe, instance.parameters.is_bid);
        local ExitSource, exitId = self:SubscribeHistory(nil, exit_timeframe, instance.parameters.is_bid);
        
        local mainHA = core.indicators:create("HA", MainSource);
        self.MainSourceHA = mainHA;
        self.MainSource = mainHA:getCandleOutput(0);
        self._trading_source_id = mainId;
        
        local exitHA = core.indicators:create("HA", ExitSource);
        self.ExitSourceHA = exitHA;
        self.ExitSource = exitHA:getCandleOutput(0);
        self._exit_source_id = exitId;
    else
        self.MainSource, self._trading_source_id = self:SubscribeHistory(nil, instance.parameters.timeframe, instance.parameters.is_bid);
        self.ExitSource, self._exit_source_id = self:SubscribeHistory(nil, exit_timeframe, instance.parameters.is_bid);
    end
    if instance.parameters.entry_execution_type == "Live" or ENFORCE_entry_execution_type == "Live" then
        _, self._trading_source_id = self:SubscribeHistory(nil, "t1", instance.parameters.is_bid);
    end
    if instance.parameters.exit_execution_type == "Live" or ENFORCE_exit_execution_type == "Live" then
        _, self._exit_source_id = self:SubscribeHistory(nil, "t1", instance.parameters.is_bid);
    end
    if self.RequestBidAsk then
        if instance.parameters.is_bid then
            self.MainSourceBid = self.MainSource;
            self.MainSourceAsk, _ = self:SubscribeHistory(nil, instance.parameters.timeframe, not instance.parameters.is_bid);
        else
            self.MainSourceAsk = self.MainSource;
            self.MainSourceBid, _ = self:SubscribeHistory(nil, instance.parameters.timeframe, not instance.parameters.is_bid);
        end
    end
end
function trading_logic:ExtUpdate(id, source, period)
    if self.MainSourceHA ~= nil then
        self.MainSourceHA:update(core.UpdateLast);
    end
    if self.ExitSourceHA ~= nil then
        self.ExitSourceHA:update(core.UpdateLast);
    end
    if id == self._trading_source_id and self.DoTrading ~= nil then
        local period2 = period;
        if source ~= self.MainSource then
            period2 = core.findDate(self.MainSource, source:date(period), false);
            if period2 == -1 then
                return;
            end
        end
        self.DoTrading(self.MainSource, period2);
    end
    if id == self._exit_source_id and self.DoExit ~= nil then
        local period2 = period;
        if source ~= self.ExitSource then
            period2 = core.findDate(self.ExitSource, source:date(period), false);
            if period2 == -1 then
                return;
            end
        end
        self.DoExit(self.ExitSource, period2);
    end
end
trading_logic:RegisterModule(Modules);
trading = {};
trading.Name = "Trading";
trading.Version = "4.30";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopParameter = true;
trading.AddLimitParameter = true;
trading._ids_start = nil;
trading._signaler = nil;
trading._account = nil;
trading._all_modules = {};
trading._request_id = {};
trading._waiting_requests = {};
trading._used_stop_orders = {};
trading._used_limit_orders = {};
function trading:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function trading:AddPositionParameters(parameters, id, section_id)
    if self.AddAmountParameter then
        parameters:addDouble("amount" .. id, "Trade Amount", "", 1);
        parameters:addString("amount_type" .. id, "Amount Unit", "", "lots");
        parameters:addStringAlternative("amount_type" .. id, "In Lots", "", "lots");
        parameters:addStringAlternative("amount_type" .. id, "% of Equity", "", "equity");
        parameters:addStringAlternative("amount_type" .. id, "Risk % of Equity", "", "risk_equity");
    end
    if CreateStopParameters == nil or not CreateStopParameters(parameters, id) then
        parameters:addGroup("  Stop parameters " .. section_id);
        parameters:addString("stop_type" .. id, "Stop Order", "", "no");
        parameters:addStringAlternative("stop_type" .. id, "No stop", "", "no");
        parameters:addStringAlternative("stop_type" .. id, "In Pips", "", "pips");
        if not DISABLE_ATR_STOP_LIMIT then
            parameters:addStringAlternative("stop_type" .. id, "ATR", "", "atr");
        end
        parameters:addStringAlternative("stop_type" .. id, "High/low", "", "highlow");
        parameters:addDouble("stop" .. id, "Stop Value", "In pips or ATR period", 30);
        if not DISABLE_ATR_STOP_LIMIT then
            parameters:addDouble("atr_stop_mult" .. id, "ATR Stop Multiplicator", "", 2.0);
        end
        parameters:addBoolean("use_trailing" .. id, "Trailing stop order", "", false);
        parameters:addInteger("trailing" .. id, "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);
    end
    if CreateLimitParameters == nil or not CreateLimitParameters(parameters, id) then
        parameters:addGroup("  Limit parameters " .. section_id);
        parameters:addString("limit_type" .. id, "Limit Order", "", "no");
        parameters:addStringAlternative("limit_type" .. id, "No limit", "", "no");
        parameters:addStringAlternative("limit_type" .. id, "In Pips", "", "pips");
        if not DISABLE_ATR_STOP_LIMIT then
            parameters:addStringAlternative("limit_type" .. id, "ATR", "", "atr");
        end
        parameters:addStringAlternative("limit_type" .. id, "Multiplicator of stop", "", "stop");
        parameters:addStringAlternative("limit_type" .. id, "High/low", "", "highlow");
        parameters:addDouble("limit" .. id, "Limit Value", "In pips or ATR period", 30);
        if not DISABLE_ATR_STOP_LIMIT then
            parameters:addDouble("atr_limit_mult" .. id, "ATR Limit Multiplicator", "", 2.0);
        end
        if not DISABLE_LIMIT_TRAILING then
            parameters:addString("TRAILING_LIMIT_TYPE" .. id, "Trailing Limit", "", "Off");
            parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Off", "", "Off");
            parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Favorable", "moves limit up for long/buy positions, vice versa for short/sell", "Favorable");
            parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Unfavorable", "moves limit down for long/buy positions, vice versa for short/sell", "Unfavorable");
            parameters:addDouble("TRAILING_LIMIT_TRIGGER" .. id, "Trailing Limit Trigger in Pips", "", 0);
            parameters:addDouble("TRAILING_LIMIT_STEP" .. id, "Trailing Limit Step in Pips", "", 10);
        end
    end
    if CreateCustomBreakeven == nil then
        parameters:addGroup("  Breakeven parameters " .. section_id);
        parameters:addBoolean("use_breakeven" .. id, "Use Breakeven", "", false);
        parameters:addDouble("breakeven_when" .. id, "Breakeven Activation Value, in pips", "", 10);
        parameters:addDouble("breakeven_to" .. id, "Breakeven To, in pips", "", 0);
        parameters:addString("breakeven_trailing" .. id, "Trailing after breakeven", "", "default");
        parameters:addStringAlternative("breakeven_trailing" .. id, "Do not change", "", "default");
        parameters:addStringAlternative("breakeven_trailing" .. id, "Set trailing", "", "set");
        parameters:addBoolean("breakeven_close" .. id, "Partial close on breakeven", "", false);
        parameters:addDouble("breakeven_close_amount" .. id, "Partial close amount, %", "", 50);
    end
end

function trading:Init(parameters, count)
    parameters:addBoolean("allow_trade", "Allow strategy to trade", "", true);
    parameters:setFlag("allow_trade", core.FLAG_ALLOW_TRADE);
    parameters:addString("account", "Account to trade on", "", "");
    parameters:setFlag("account", core.FLAG_ACCOUNT);
    parameters:addString("allow_side", "Allow side", "", "both")
    parameters:addStringAlternative("allow_side", "Both", "", "both")
    parameters:addStringAlternative("allow_side", "Long/buy only", "", "buy")
    parameters:addStringAlternative("allow_side", "Short/sell only", "", "sell")
    parameters:addString("custom_id", "Custom ID", "", "id");
    parameters:addBoolean("close_on_opposite", "Close on Opposite", "", true);
    if ENFORCE_POSITION_CAP ~= true then
        parameters:addBoolean("position_cap", "Position Cap", "", false);
        parameters:addInteger("no_of_positions", "Max # of open positions", "", 1);
        parameters:addInteger("no_of_buy_position", "Max # of buy positions", "", 1);
        parameters:addInteger("no_of_sell_position", "Max # of sell positions", "", 1);
    end
    
    if count == nil or count == 1 then
        parameters:addGroup("Position");
        self:AddPositionParameters(parameters, "", "");
    else
        for i = 1, count do
            parameters:addGroup("Position #" .. i);
            parameters:addBoolean("use_position_" .. i, "Open position #" .. i, "", i == 1);
            self:AddPositionParameters(parameters, "_" .. i, "#" .. i);
        end
    end
end

function trading:Prepare(name_only)
    if name_only then return; end
end

function trading:ExtUpdate(id, source, period)
end

function trading:OnNewModule(module)
    if module.Name == "Signaler" then self._signaler = module; end
    self._all_modules[#self._all_modules + 1] = module;
end

function trading:AsyncOperationFinished(cookie, success, message, message1, message2)
    local res = self._waiting_requests[cookie];
    if res ~= nil then
        res.Finished = true;
        res.Success = success;
        if not success then
            res.Error = message;
            if self._signaler ~= nil then
                self._signaler:Signal(res.Error);
            else
                self:trace(res.Error);
            end
        elseif res.OnSuccess ~= nil then
            res:OnSuccess();
        end
        self._waiting_requests[cookie] = nil;
    elseif cookie == self._order_update_id then
        for _, order in ipairs(self._monitored_orders) do
            if order.RequestID == message2 then
                order.FixStatus = message1;
            end
        end
    elseif cookie == self._ids_start + 2 then
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal("Close order failed: " .. message);
            else
                self:trace("Close order failed: " .. message);
            end
        end
    end
end

function trading:getOppositeSide(side) if side == "B" then return "S"; end return "B"; end

function trading:getId()
    for id = self._ids_start, self._ids_start + 100 do
        if self._waiting_requests[id] == nil then return id; end
    end
    return self._ids_start;
end

function trading:CreateStopOrder(trade, stop_rate, trailing)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = stop_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end

    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "S";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
        valuemap.TrailUpdatePips = trailing;
    else
        valuemap.OrderType = "SE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Failed create stop " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    self._request_id[trade.TradeID] = msg;
    return res;
end

function trading:CreateLimitOrder(trade, limit_rate)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = limit_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "L";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
    else
        valuemap.OrderType = "LE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end
    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        terminal:alertMessage(trade.Instrument, limit_rate, "Failed create limit " .. msg, core.now());
    else
        self._request_id[trade.TradeID] = msg;
    end
end

function trading:ChangeOrder(order, rate, trailing)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.TrailUpdatePips = trailing;
        valuemap.Rate = rate;
        local id = self:getId();
        local success, msg = terminal:execute(id, valuemap);
        if not(success) then
            local message = "Failed change order " .. msg;
            self:trace(message);
            if self._signaler ~= nil then
                self._signaler:Signal(message);
            end
            local res = {};
            res.Finished = true;
            res.Success = false;
            res.Error = message;
            return res;
        end
        local res = {};
        res.Finished = false;
        res.RequestID = msg;
        self._waiting_requests[id] = res;
        return res;
    end
    local res = {};
    res.Finished = true;
    res.Success = true;
    return res;
end

function trading:IsLimitOrder(order)
    local order_type = order.Type;
    if order_type == "L" or order_type == "LT" or order_type == "LTE" then
        return true;
    end
    return order.ContingencyType == 3 and order_type == "LE";
end

function trading:IsStopOrder(order) 
    local order_type = order.Type;
    if order_type == "S" or order_type == "ST" or order_type == "STE" then
        return true;
    end
    return order.ContingencyType == 3 and order_type == "SE";
end

function trading:IsLimitOrderType(order_type) return order_type == "L" or order_type == "LE" or order_type == "LT" or order_type == "LTE"; end

function trading:IsStopOrderType(order_type) return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE"; end

function trading:FindLimitOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.LimitOrderID ~= nil and trade.LimitOrderID ~= "" then
            order_id = trade.LimitOrderID;
            self:trace("Using limit order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching limit order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:IsLimitOrder(row) and self._used_limit_orders[row.OrderID] ~= true then
                self._used_limit_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:FindStopOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
            order_id = trade.StopOrderID;
            self:trace("Using stop order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching stop order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:IsStopOrder(row) and self._used_stop_orders[row.OrderID] ~= true then
                self._used_stop_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:MoveStop(trade, stop_rate, trailing)
    local order = self:FindStopOrder(trade);
    if order == nil then
        if trailing == 0 then
            trailing = nil;
        end
        return self:CreateStopOrder(trade, stop_rate, trailing);
    else
        if trailing == 0 then
            if order.TrlMinMove ~= 0 then
                trailing = order.TrlMinMove
            else
                trailing = nil;
            end
        end
        return self:ChangeOrder(order, stop_rate, trailing);
    end
end

function trading:MoveLimit(trade, limit_rate)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        self:trace("Limit order not found, creating a new one");
        return self:CreateLimitOrder(trade, limit_rate);
    else
        return self:ChangeOrder(order, limit_rate);
    end
end

function trading:RemoveStop(trade)
    self:trace("Searching for a stop");
    local order = self:FindStopOrder(trade);
    if order == nil then self:trace("No stop"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:RemoveLimit(trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then self:trace("No limit"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:DeleteOrder(order)
    self:trace(string.format("Deleting order %s", order.OrderID));
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OrderID = order.OrderID;

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Delete order failed: " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    return res;
end

function trading:GetCustomID(qtxt)
    if qtxt == nil then
        return nil;
    end
    local metadata = self:GetMetadata(qtxt);
    if metadata == nil then
        return qtxt;
    end
    return metadata.CustomID;
end

function trading:FindOrder()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenRate(rate) self.Rate = rate; return self; end
    function search:WhenOrderType(orderType) self.OrderType = orderType; return self; end
    function search:Do(action)
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local count = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                if action(row) then
                    count = count + 1;
                end
            end
            row = enum:next();
        end
        return count;
    end
    function search:Summ(action)
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local summ = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                summ = summ + action(row);
            end
            row = enum:next();
        end
        return summ;
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.Rate == self.Rate or not self.Rate)
            and (row.Type == self.OrderType or not self.OrderType);
    end
    function search:All()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local orders = {};
        while (row ~= nil) do
            if self:PassFilter(row) then orders[#orders + 1] = row; end
            row = enum:next();
        end
        return orders;
    end
    function search:First()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    function search:Count()
        local count = 0;
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then count = count + 1; end
            row = enum:next();
        end
        return count;
    end
    return search;
end

function trading:FindTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpen(open) self.Open = open; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:Do(action)
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local count = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                if action(row) then
                    count = count + 1;
                end
            end
            row = enum:next();
        end
        return count;
    end
    function search:Summ(action)
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local summ = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                summ = summ + action(row);
            end
            row = enum:next();
        end
        return summ;
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.Open == self.Open or not self.Open)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:All()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:Any()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then 
                return true;
            end
            row = enum:next();
        end
        return false;
    end
    function search:Count()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local count = 0;
        while (row ~= nil) do
            if self:PassFilter(row) then count = count + 1; end
            row = enum:next();
        end
        return count;
    end
    function search:First()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindClosedTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:WhenTradeIDRemain(trade_id_remain) self.TradeIDRemain = trade_id_remain; return self; end
    function search:WhenCloseOrderID(close_order_id) self.CloseOrderID = close_order_id; return self; end
    function search:PassFilter(row)
        if self.TradeIDRemain ~= nil and row.TradeIDRemain ~= self.TradeIDRemain then return false; end
        if self.CloseOrderID ~= nil and row.CloseOrderID ~= self.CloseOrderID then return false; end
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:Do(action)
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        local count = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                if action(row) then
                    count = count + 1;
                end
            end
            row = enum:next();
        end
        return count;
    end
    function search:Any()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then
                return true;
            end
            row = enum:next();
        end
        return false;
    end
    function search:All()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:First()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:ParialClose(trade, amount)
    -- not finished
    local account = core.host:findTable("accounts"):find("AccountID", trade.AccountID);
    local id = self:getId();
    if account.Hedging == "Y" then
        local valuemap = core.valuemap();
        valuemap.BuySell = trade.BS == "B" and "S" or "B";
        valuemap.OrderType = "CM";
        valuemap.OfferID = trade.OfferID;
        valuemap.AcctID = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = math.min(amount, trade.Lot);
        local success, msg = terminal:execute(id, valuemap);
        if success then
            local res = trading:ClosePartialSuccessResult(msg);
            self._waiting_requests[id] = res;
            return res;
        end
        return trading:ClosePartialFailResult(msg);
    end

    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.Quantity = math.min(amount, trade.Lot);
    valuemap.BuySell = trading:getOppositeSide(trade.BS);
    local success, msg = terminal:execute(id, valuemap);
    if success then
        local res = trading:ClosePartialSuccessResult(msg);
        self._waiting_requests[id] = res;
        return res;
    end
    return trading:ClosePartialFailResult(msg);
end

function trading:ClosePartialSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:ClosePartialFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    return res;
end

function trading:Close(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(self._ids_start + 3, valuemap);
    if not(success) then
        if self._signaler ~= nil then self._signaler:Signal("Close failed: " .. msg); end
        return false;
    end

    return true;
end

function trading:ObjectToJson(obj)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:AddTable(name, value)
        local str = trading:ObjectToJson(value);
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), tostring(str));
    end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    
    local first = true;
    for idx,t in pairs(obj) do
        local stype = type(t)
        if stype == "number" then json:AddNumber(idx, t);
        elseif stype == "string" then json:AddStr(idx, t);
        elseif stype == "boolean" then json:AddBool(idx, t);
        elseif stype == "function" then --do nothing
        elseif stype == "table" then json:AddTable(idx, t);
        else core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function trading:CreateEntryOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:IsOrderExecuted()
        return self.FixStatus ~= nil and self.FixStatus == "F";
    end
    function res:GetOrder()
        if self._order == nil then
            self._order = core.host:findTable("orders"):find("RequestID", self.RequestID);
            if self._order == nil then return nil; end
        end
        if not self._order:refresh() then return nil; end
        return self._order;
    end
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:CreateEntryOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetOrder() return nil; end
    function res:GetTrade() return nil; end
    function res:GetClosedTrade() return nil; end
    function res:IsOrderExecuted() return false; end
    return res;
end

function trading:EntryOrder(instrument)
    local builder = {};
    builder.Offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OfferID = builder.Offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:_GetBaseUnitSize() if self._base_size == nil then self._base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID); end return self._base_size; end

    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetAmount(amount) self.amount = amount; return self; end
    function builder:SetRiskPercentOfEquityAmount(percent) self._RiskPercentOfEquityAmount = percent; return self; end
    function builder:SetPercentOfEquityAmount(percent) self._PercentOfEquityAmount = percent; return self; end
    function builder:UpdateOrderType()
        if self.valuemap.BuySell == nil or self.valuemap.Rate == nil then
            return;
        end
        if self.valuemap.BuySell == "B" then 
            self.valuemap.OrderType = self.Offer.Ask > self.valuemap.Rate and "LE" or "SE"; 
        else 
            self.valuemap.OrderType = self.Offer.Bid > self.valuemap.Rate and "SE" or "LE"; 
        end 
    end
    function builder:SetSide(buy_sell) 
        self.valuemap.BuySell = buy_sell; 
        self:UpdateOrderType();
        return self; 
    end
    function builder:SetRate(rate) 
        self.valuemap.Rate = rate; 
        self:UpdateOrderType();
        return self; 
    end
    function builder:SetPipLimit(limit_type, limit) self.valuemap.PegTypeLimit = limit_type or "M"; self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit; return self; end
    function builder:SetLimit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop) self.valuemap.PegTypeStop = stop_type or "O"; self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetStop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:UseDefaultCustomId() self.valuemap.CustomID = self.Parent.CustomID; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:BuildValueMap()
        self.valuemap.Quantity = self.amount * self:_GetBaseUnitSize();
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        if self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local used_equity = equity * self._PercentOfEquityAmount / 100.0;
            local emr = core.host:getTradingProperty("EMR", self.Offer.Instrument, self.valuemap.AcctID);
            self.valuemap.Quantity = math.floor(used_equity / emr) * self:_GetBaseUnitSize();
        elseif self._RiskPercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local affordable_loss = equity * self._RiskPercentOfEquityAmount / 100.0;
            assert(self.valuemap.RateStop ~= nil, "Only absolute stop is supported");
            local stop = math.abs(self.valuemap.RateStop - self.valuemap.Rate) / self.Offer.PointSize;
            local possible_loss = self.Offer.PipCost * stop;
            self.valuemap.Quantity = math.floor(affordable_loss / possible_loss) * self:_GetBaseUnitSize();
        end
        return self.valuemap;
    end
    function builder:Execute()
        self:BuildValueMap();
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then self.Parent._signaler:Signal(message); end
            return trading:CreateEntryOrderFailResult(message);
        end
        local res = trading:CreateEntryOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:StoreMarketOrderResults(res)
    local str = "[";
    for i, t in ipairs(res) do
        local json = t:ToJSON();
        if str == "[" then str = str .. json; else str = str .. "," .. json; end
    end
    return str .. "]";
end
function trading:RestoreMarketOrderResults(str)
    local results = {};
    local position = 2;
    local result;
    while (position < str:len()) do
        local ch = string.sub(str, position, position);
        if ch == "{" then
            result = trading:CreateMarketOrderSuccessResult();
            position = position + 1;
        elseif ch == "}" then
            results[#results + 1] = result;
            result = nil;
            position = position + 1;
        elseif ch == "," then
            position = position + 1;
        else
            local name, value = string.match(str, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return results;
end
function trading:CreateMarketOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        local json = {};
        function json:AddStr(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
        end
        function json:AddNumber(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
        end
        function json:AddBool(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
        end
        function json:ToString() return "{" .. (self.str or "") .. "}"; end
        
        local first = true;
        for idx,t in pairs(self) do
            local stype = type(t)
            if stype == "number" then json:AddNumber(idx, t);
            elseif stype == "string" then json:AddStr(idx, t);
            elseif stype == "boolean" then json:AddBool(idx, t);
            elseif stype == "function" or stype == "table" then --do nothing
            else core.host:trace(tostring(idx) .. " " .. tostring(stype));
            end
        end
        return json:ToString();
    end
    return res;
end
function trading:CreateMarketOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetTrade() return nil; end
    return res;
end

function trading:MarketOrder(instrument)
    local builder = {};
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Offer = offer;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OrderType = "OM";
    builder.valuemap.OfferID = offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:_GetBaseUnitSize() if self._base_size == nil then self._base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID); end return self._base_size; end
    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetAmount(amount) self._amount = amount; return self; end
    function builder:SetRiskPercentOfEquityAmount(percent) self._RiskPercentOfEquityAmount = percent; return self; end
    function builder:SetPercentOfEquityAmount(percent) self._PercentOfEquityAmount = percent; return self; end
    function builder:SetSide(buy_sell) self.valuemap.BuySell = buy_sell; return self; end
    function builder:SetPipLimit(limit_type, limit)
        self.valuemap.PegTypeLimit = limit_type or "O";
        self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit;
        return self;
    end
    function builder:SetLimit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop)
        self.valuemap.PegTypeStop = stop_type or "O";
        self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop;
        self.valuemap.TrailStepStop = trailing_stop;
        return self;
    end
    function builder:SetStop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:FillFields()
        local base_size = self:_GetBaseUnitSize();
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        if self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local used_equity = equity * self._PercentOfEquityAmount / 100.0;
            local emr = core.host:getTradingProperty("EMR", self.Offer.Instrument, self.valuemap.AcctID);
            self.valuemap.Quantity = math.floor(used_equity / emr) * base_size;
        elseif self._RiskPercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local affordable_loss = equity * self._RiskPercentOfEquityAmount / 100.0;
            assert(self.valuemap.PegPriceOffsetPipsStop ~= nil, "Only pip stop are supported");
            local possible_loss = self.Offer.PipCost * self.valuemap.PegPriceOffsetPipsStop;
            self.valuemap.Quantity = math.floor(affordable_loss / possible_loss) * base_size;
        else
            self.valuemap.Quantity = self._amount * base_size;
        end
    end
    function builder:Execute()
        self.Parent:trace(string.format("Creating %s OM for %s", self.valuemap.BuySell, self.Instrument));
        self:FillFields();
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            return trading:CreateMarketOrderFailResult(message);
        end
        local res = trading:CreateMarketOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:ReadValue(json, position)
    local whaitFor = "";
    local start = position;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        position = position + 1;
        if ch == "\"" then
            start = position - 1;
            whaitFor = ch;
            break;
        elseif ch == "{" then
            start = position - 1;
            whaitFor = "}";
            break;
        elseif ch == "," or ch == "}" then
            return string.sub(json, start, position - 2), position - 1;
        end
    end
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        position = position + 1;
        if ch == whaitFor then
            return string.sub(json, start, position - 1), position;
        end
    end
    return "", position;
end
function trading:JsonToObject(json)
    local position = 1;
    local result;
    local results;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            if results ~= nil then
                position = position + 1;
                results[#results + 1] = result;
            else
                return result;
            end
        elseif ch == "," then
            position = position + 1;
        elseif ch == "[" then
            position = position + 1;
            results = {};
        elseif ch == "]" then
            return results;
        else
            if result == nil then
                return nil;
            end
            local name = string.match(json, '"([^"]+)":', position);
            local value, new_pos = trading:ReadValue(json, position + name:len() + 3);
            position = new_pos;
            if value == "false" then
                result[name] = false;
            elseif value == "true" then
                result[name] = true;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value:sub(2, value:len() - 1);
                elseif string.sub(value, 1, 1) == "{" then
                    result[name] = trading:JsonToObject(value);
                else
                    result[name] = tonumber(value);
                end
            end
        end
    end
    return nil;
end

function trading:GetMetadata(qtxt)
    if qtxt == "" then
        return nil;
    end
    local position = 1;
    local result;
    while (position < qtxt:len() + 1) do
        local ch = string.sub(qtxt, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            return result;
        elseif ch == "," then
            position = position + 1;
        else
            if result == nil then
                return nil;
            end
            local name, value = string.match(qtxt, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return nil;
end

function trading:GetTradeMetadata(trade)
    return self:GetMetadata(trade.QTXT);
end
trading:RegisterModule(Modules);
