-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=75315

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

local vars = {};
function Init()
    indicator:name("Follow Line");
    indicator:description("Follow Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "ATR Period", "", 5, 1);
    indicator.parameters:addInteger("param2", "Bollinger Bands Period", "", 21, 1);
    indicator.parameters:addDouble("param3", "Bollinger Bands Deviation", "", 1.00, 0.1);
    indicator.parameters:addBoolean("param4", "ATR Filter On/Off", "", true);
    indicator.parameters:addBoolean("param5", "Show Signals ", "", true);
    signaler:Init(indicator.parameters);
end

local source;
local plot1;
local plot2;
local plot3;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["ATRperiod"] = instance.parameters.param1;
    vars["BBperiod"] = instance.parameters.param2;
    vars["BBdeviation"] = instance.parameters.param3;
    vars["UseATRfilter"] = instance.parameters.param4;
    vars["showsignals"] = instance.parameters.param5;
    vars["MVA1"] = core.indicators:create("MVA", source.close, vars["BBperiod"]);
    vars["MVA2"] = core.indicators:create("MVA", source.close, vars["BBperiod"]);
    vars["ATR1"] = core.indicators:create("ATR", source, vars["ATRperiod"]);
    vars["FollowLine"] = instance:addInternalStream(0, 0);
    vars["BBSignal"] = instance:addInternalStream(0, 0);
    vars["iTrend"] = instance:addInternalStream(0, 0);
    vars["buy"] = 0.0;
    vars["sell"] = 0.0;
    signaler:Prepare(nameOnly);
    plot1 = instance:addStream("plot1", core.Line, "Follow Line", "Follow Line", core.colors().Blue, 0, 0);
    plot1:setWidth(2);
    plot1:setStyle(core.LINE_SOLID);
    plot2 = instance:createTextOutput("plot2", "", "Arial", 12, core.H_Center, core.V_Center, core.colors().Blue);
    plot3 = instance:createTextOutput("plot3", "", "Arial", 12, core.H_Center, core.V_Center, core.rgb(102, 15, 15));
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        SafeSetFloat(vars["FollowLine"], period, nil);
        SafeSetFloat(vars["BBSignal"], period, 0);
        SafeSetFloat(vars["iTrend"], period, 0);
    else
        SafeSetFloat(vars["FollowLine"], period, SafeGetFloat(vars["FollowLine"], period - 1));
        SafeSetFloat(vars["BBSignal"], period, SafeGetFloat(vars["BBSignal"], period - 1));
        SafeSetFloat(vars["iTrend"], period, SafeGetFloat(vars["iTrend"], period - 1));
    end
    vars["MVA1"]:update(mode);
    if source.close:first() > period - (vars["BBperiod"]) then return; end
    BBUpper = SafePlus(vars["MVA1"].DATA:tick(period), SafeMultiply(mathex.stdev(source.close, core.rangeTo(period, vars["BBperiod"])), vars["BBdeviation"]));
    vars["MVA2"]:update(mode);
    if source.close:first() > period - (vars["BBperiod"]) then return; end
    BBLower = SafeMinus(vars["MVA2"].DATA:tick(period), SafeMultiply(mathex.stdev(source.close, core.rangeTo(period, vars["BBperiod"])), vars["BBdeviation"]));
    vars["ATR1"]:update(mode);
    atrValue = vars["ATR1"].DATA:tick(period);
    if (SafeGreater(source.close:tick(period), BBUpper)) then
        SafeSetFloat(vars["BBSignal"], period, 1);
    elseif (SafeLess(source.close:tick(period), BBLower)) then
        SafeSetFloat(vars["BBSignal"], period, (-1));
    end
    if ((SafeGetFloat(vars["BBSignal"], period) == 1)) then
        if (vars["UseATRfilter"]) then
            SafeSetFloat(vars["FollowLine"], period, SafeMinus(source.low:tick(period), atrValue));
        else
            SafeSetFloat(vars["FollowLine"], period, source.low:tick(period));
        end
        if vars["FollowLine"]:first() > period - (1) then return; end
        if (SafeLess(SafeGetFloat(vars["FollowLine"], period), Nz(SafeGetFloat(vars["FollowLine"], period - 1)))) then
            if vars["FollowLine"]:first() > period - (1) then return; end
            SafeSetFloat(vars["FollowLine"], period, Nz(SafeGetFloat(vars["FollowLine"], period - 1)));
        end
    end
    if ((SafeGetFloat(vars["BBSignal"], period) == (-1))) then
        if (vars["UseATRfilter"]) then
            SafeSetFloat(vars["FollowLine"], period, SafePlus(source.high:tick(period), atrValue));
        else
            SafeSetFloat(vars["FollowLine"], period, source.high:tick(period));
        end
        if vars["FollowLine"]:first() > period - (1) then return; end
        if (SafeGreater(SafeGetFloat(vars["FollowLine"], period), Nz(SafeGetFloat(vars["FollowLine"], period - 1)))) then
            if vars["FollowLine"]:first() > period - (1) then return; end
            SafeSetFloat(vars["FollowLine"], period, Nz(SafeGetFloat(vars["FollowLine"], period - 1)));
        end
    end
    if vars["FollowLine"]:first() > period - (1) then return; end
    if vars["FollowLine"]:first() > period - (1) then return; end
    if (SafeGreater(Nz(SafeGetFloat(vars["FollowLine"], period)), Nz(SafeGetFloat(vars["FollowLine"], period - 1)))) then
        SafeSetFloat(vars["iTrend"], period, 1);
    elseif (SafeLess(Nz(SafeGetFloat(vars["FollowLine"], period)), Nz(SafeGetFloat(vars["FollowLine"], period - 1)))) then
        SafeSetFloat(vars["iTrend"], period, (-1));
    end
    lineColor = Triary((SafeGetFloat(vars["iTrend"], period) > 0), core.rgb(9, 98, 232), core.rgb(220, 20, 60) + math.floor(0 / 100 * 255) * 16777216);
    if vars["iTrend"]:first() > period - (1) then return; end
    vars["buy"] = Triary((SafeGetFloat(vars["iTrend"], period - 1) == (-1)) and (SafeGetFloat(vars["iTrend"], period) == 1), 1, nil);
    if vars["iTrend"]:first() > period - (1) then return; end
    vars["sell"] = Triary((SafeGetFloat(vars["iTrend"], period - 1) == 1) and (SafeGetFloat(vars["iTrend"], period) == (-1)), 1, nil);
    if (vars["sell"] == 1) and period == source:size() - 1 then
        signaler:SignalEx("Follow Line Sell", period, source);
    end
    if (vars["buy"] == 1) and period == source:size() - 1 then
        signaler:SignalEx("Follow Line Buy", period, source);
    end
    if ((vars["buy"] == 1) or (vars["sell"] == 1)) and period == source:size() - 1 then
        signaler:SignalEx("Follow Line Signal", period, source);
    end
    plot1[period] = SafeGetFloat(vars["FollowLine"], period);
    plot1:setColor(period, lineColor);
    plot2_series = Triary((vars["buy"] == 1) and vars["showsignals"], SafeMinus(SafeGetFloat(vars["FollowLine"], period), atrValue), nil);
    if plot2_series then
        plot2:set(period, plot2_series, "BUY", "BUY");
    else
        plot2:setNoData(period);
    end
    plot3_series = Triary((vars["sell"] == 1) and vars["showsignals"], SafePlus(SafeGetFloat(vars["FollowLine"], period), atrValue), nil);
    if plot3_series then
        plot3:set(period, plot3_series, "SELL", "SELL");
    else
        plot3:setNoData(period);
    end
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
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
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
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
function signaler:RegisterModule(modules) 
    if modules == nil then
        self._ids_start = 100; 
        return;
    end
    for _, module in pairs(modules) do 
        self:OnNewModule(module); 
        module:OnNewModule(self); 
    end 
    modules[#modules + 1] = self; 
    self._ids_start = (#modules) * 100; 
end

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
function signaler:getSource(source)
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
    return source;
end
function signaler:SignalEx(message, period, source)
    source = self:getSource(getSource);
    local interval = string.find(message, "{{interval}}");
    if interval ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. source:barSize()
            .. string.sub(message, interval + string.len("{{interval}}"));
    end
    local close = string.find(message, "{{close}}");
    if close ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. win32.formatNumber(source.close[period], false, source:getDisplayPrecision())
            .. string.sub(message, interval + string.len("{{close}}"));
    end
    self:Signal(message, source);
end
function signaler:Signal(message, source)
    source = self:getSource(getSource);
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

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+