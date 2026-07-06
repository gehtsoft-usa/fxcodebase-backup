-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=29&t=892

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

local Modules = {};

function Init()
	strategy:name("EMA RSI Signal")
	strategy:description("EMA RSI STO Signal")

	strategy.parameters:addGroup("Parameters")

	strategy.parameters:addInteger("FastN", "Fast Period", "", 5)
	strategy.parameters:addInteger("SlowN", "Slow Period", "", 10)
	strategy.parameters:addInteger("RSIN", "RSI Period", "", 14, 2, 1000)
	strategy.parameters:addInteger("STOK", "K% LinePeriod", "", 14, 2, 1000)
	strategy.parameters:addInteger("STOD", "D% Line Period", "", 3, 2, 1000)
	strategy.parameters:addInteger("STOSD", "Slow %D Period", "", 3, 2, 1000)

	strategy.parameters:addString("Method", "Price Smoothing method", "", "EMA")
	strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA")
	strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA")
	strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA")

	strategy.parameters:addString("Type", "Price type", "", "Bid")
	strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
	strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

	strategy.parameters:addString("Period", "Timeframe", "", "m5")
	strategy.parameters:setFlag("Period", core.FLAG_PERIODS)

	strategy.parameters:addGroup("Signals")
	signaler:Init(strategy.parameters);
end

local FastMA, SlowMA, RSI, STO
local BUY, SELL
local BarSource = nil -- the source stream

local FastN, SlowN, RSIN, STOK, STOD, STOSD

local FastFlag
local RSIFlag, RSIOver, STOFlag, STOOver
local FLAG
local reset
local first

function Prepare(nameOnly)
	for _, module in pairs(Modules) do module:Prepare(nameOnly); end
	-- collect parameters
	FastN = instance.parameters.FastN
	SlowN = instance.parameters.SlowN

	RSIN = instance.parameters.RSIN

	STOK = instance.parameters.STOK
	STOD = instance.parameters.STOD
	STOSD = instance.parameters.STOSD

	assert(FastN < SlowN, "Number of periods for Fast MA must be less than number of periods for Mid MA")

	SELL = "Short"
	BUY = "Long"

	BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar")

	assert(
		core.indicators:findIndicator(instance.parameters.Method) ~= nil,
		instance.parameters.Method .. " indicator must be installed"
	)
	FastMA = core.indicators:create(instance.parameters.Method, BarSource.close, FastN)
	SlowMA = core.indicators:create(instance.parameters.Method, BarSource.close, SlowN)

	RSI = core.indicators:create("RSI", BarSource.close, RSIN)
	STO =
		core.indicators:create(
		"STOCHASTIC",
		BarSource,
		STOK,
		STOSD,
		STOD,
		instance.parameters.Method,
		instance.parameters.Method
	)
	first = math.max(FastMA.DATA:first(), SlowMA.DATA:first(), RSI.DATA:first(), STO.D:first()) + 1

	local name =
		profile:id() ..
		"(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period .. ")" .. "," .. FastN .. SlowN .. ")"
	instance:name(name)
end

-- when tick source is updated
function ExtUpdate(id, source, period)
	for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
	FastMA:update(core.UpdateLast)
	SlowMA:update(core.UpdateLast)
	RSI:update(core.UpdateLast)
	STO:update(core.UpdateLast)

	if period < first then
		return
	end

	if core.crossesOver(FastMA.DATA, SlowMA.DATA, period) then
		FastFlag = "Buy"
		reset = 1
	end

	if core.crossesUnder(FastMA.DATA, SlowMA.DATA, period) then
		FastFlag = "Sell"
		reset = 1
	end

	if core.crossesOver(RSI.DATA, 50, period) then
		RSIFlag = "Buy"
		RSIOver = nil
		reset = 1
	end

	if core.crossesUnder(RSI.DATA, 50, period) then
		RSIFlag = "Sell"
		RSIOver = nil
		reset = 1
	end

	if core.crossesOver(RSI.DATA, 70, period) then
		RSIOver = "Buy"
		RSIFlag = nil
		reset = 1
	end

	if core.crossesUnder(RSI.DATA, 30, period) then
		RSIOver = "Sell"
		RSIFlag = nil

		reset = 1
	end

	if core.crossesOver(STO.K, STO.D, period) then
		STOFlag = "Buy"
		STOOver = nil
		reset = 1
	end

	if core.crossesUnder(STO.K, STO.D, period) then
		STOFlag = "Sell"
		STOOver = nil
		reset = 1
	end

	if core.crossesOver(STO.K, 80, period) then
		STOOver = "Buy"
		STOFlag = nil
		reset = 1
	end

	if core.crossesUnder(STO.K, 20, period) then
		STOOver = "Sell"
		STOFlag = nil
		reset = 1
	end

	if reset == 1 then
		FLAG = nil
		reset = 0
	end

	if
		FastFlag == "Buy" and FLAG ~= "Buy" and RSIFlag == "Buy" and RSIOver ~= "Buy" and
			FastMA.DATA[period] > FastMA.DATA[period - 1] and
			STOFlag == "Buy" and
			STOOver ~= "Buy"
	 then
		FLAG = "Buy"
		signaler:Signal(BUY)
	end

	if
		FastFlag == "Sell" and FLAG ~= "Sell" and RSIFlag == "Sell" and RSIOver ~= "Sell" and
			FastMA.DATA[period] < FastMA.DATA[period - 1] and
			STOFlag == "Sell" and
			STOOver ~= "Sell"
	 then
		FLAG = "Sell"
		signaler:Signal(SELL)
	end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.6";

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

            self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
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
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end
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