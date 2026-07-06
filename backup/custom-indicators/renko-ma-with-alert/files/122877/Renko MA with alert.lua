-- Id:
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=50&t=67173

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

local Modules = {};

function Init()
    indicator:name("Renko MA")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.View)
    indicator:setTag("Version", "2")

    indicator.parameters:addString("instrument", "Instrument", "", "EUR/USD")
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS)
    indicator.parameters:addString("frame", "Timeframe", "", "H1")
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS)
    indicator.parameters:addBoolean("type", "Price type", "", true)
    indicator.parameters:setFlag("type", core.FLAG_BIDASK)
    indicator.parameters:addInteger("Step", "Renko brick size", "", 20, 1, 1000)

    indicator.parameters:addDate("from", "From date", "", -1000)
    indicator.parameters:addDate("to", "To date", "", 0)
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL)

    indicator.parameters:addInteger("ma_period", "MA period", "", 7)
    indicator.parameters:addInteger("min_bricks", "Min. bricks", "", 2)
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMA", "Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthMA", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMA", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMA", core.FLAG_LEVEL_STYLE);

    signaler:Init(indicator.parameters);
end

local loading
local instrument
local frame
local StepPips
local history
local open, high, low, close, volume
local offer
local offset
local OneSecond
local LastTime
local MA;
local MA_indi

-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument
    frame = instance.parameters.frame
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end

    local name = profile:id() .. "(" .. instrument .. "." .. frame .. ")"
    instance:name(name)

    if onlyName then
        return
    end

    -- check whether the instrument is available
    local offers = core.host:findTable("offers")
    local enum = offers:enumerator()
    local row = enum:next()
    while row ~= nil do
        if row.Instrument == instrument then
            break
        end
        row = enum:next()
    end

    assert(row ~= nil, "Instrument not found")

    offer = row.OfferID

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0)

    loading = true
    history =
        core.host:execute(
        "getHistory",
        1000,
        instrument,
        frame,
        instance.parameters.from,
        instance.parameters.to,
        instance.parameters.type
    )
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers")
    end
    StepPips = instance.parameters.Step * history.close:pipSize()
    core.host:execute("setStatus", "Loading...")

    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0)
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0)
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0)
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0)
    volume =
        instance:addStream(
        "volume",
        core.Line,
        name .. "." .. "Volume",
        "volume",
        core.host:execute("getProperty", "VolumeColor"),
        0,
        0
    )
    MA = instance:addStream("MA", core.Line, name .. "." .. "MA", "MA", instance.parameters.clrMA, 0, 0)
    MA:setWidth(instance.parameters.widthMA)
    MA:setStyle(instance.parameters.styleMA)
    MA_indi = core.indicators:create("MVA", close, instance.parameters.ma_period)

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume, frame)

    OneSecond = 1 / 86400
end

function Update(period, mode)
    -- shall never be called, ignore the call
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == 1000 then
        if success then
            handleHistory()
            core.host:execute("setStatus", "")
        else
            core.host:trace("The indicator could not get the history")
        end
    elseif cookie == 2000 then
        if message == offer then
            handleUpdate()
        end
    end
end

function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end

local lastDirection

function calcFirstValueValue(current, i)
    local source = history.close
    local open_val = math.floor(source[0] / StepPips) * StepPips
    while source[i] > open_val + StepPips do
        current = current + 1
        if current == 0 then
            instance:addViewBar(source:date(0))
            volume[current] = history.volume[i]
        else
            instance:addViewBar(open:date(current - 1) + OneSecond)
            volume[current] = 0
        end
        open[current] = open_val
        close[current] = open[current] + StepPips
        low[current] = open[current]
        high[current] = close[current]
        MA_indi:update(core.UpdateLast);
        if MA_indi.DATA:hasData(current) then
            MA[current] = MA_indi.DATA[current];
        end
        lastDirection = 1
        open_val = open_val + StepPips
    end
    open_val = math.floor(source[0] / StepPips) * StepPips
    while source[i] < open_val - StepPips do
        current = current + 1
        if current == 0 then
            instance:addViewBar(source:date(0))
            volume[current] = history.volume[i]
        else
            instance:addViewBar(open:date(current - 1) + OneSecond)
            volume[current] = 0
        end
        open[current] = open_val
        close[current] = open[current] - StepPips
        high[current] = open[current]
        low[current] = close[current]
        MA_indi:update(core.UpdateLast);
        if MA_indi.DATA:hasData(current) then
            MA[current] = MA_indi.DATA[current];
        end
        lastDirection = -1
        open_val = open_val - StepPips
    end

    return current
end

function calcValue(current, i)
    if current == -1 then
        return calcFirstValueValue(current, i)
    end
    local source = history.close
    local diff = close[current] - open[current]
    if diff > 0 or (diff == 0 and lastDirection == 1) then
        lastDirection = 1
        if source[i] <= close[current] + StepPips and source[i] >= close[current] - 2 * StepPips then
            volume[current] = volume[current] + history.volume[i]
        end
        while source[i] > close[current] + StepPips do
            current = current + 1
            if open:date(current - 1) < source:date(i) then
                instance:addViewBar(source:date(i))
                volume[current] = history.volume[i]
            else
                instance:addViewBar(open:date(current - 1) + OneSecond)
                volume[current] = 0
            end
            open[current] = close[current - 1]
            low[current] = open[current]
            close[current] = open[current] + StepPips
            high[current] = close[current]
            MA_indi:update(core.UpdateLast);
            if MA_indi.DATA:hasData(current) then
                MA[current] = MA_indi.DATA[current];
            end
        end
        if source[i] < close[current] - 2 * StepPips then
            while source[i] < close[current] - StepPips do
                current = current + 1
                if open:date(current - 1) < source:date(i) then
                    instance:addViewBar(source:date(i))
                    volume[current] = history.volume[i]
                else
                    instance:addViewBar(open:date(current - 1) + OneSecond)
                    volume[current] = 0
                end
                if close[current - 1] > open[current - 1] then
                    open[current] = close[current - 1] - StepPips
                else
                    open[current] = close[current - 1]
                end
                high[current] = open[current]
                close[current] = open[current] - StepPips
                low[current] = close[current]
                MA_indi:update(core.UpdateLast);
                if MA_indi.DATA:hasData(current) then
                    MA[current] = MA_indi.DATA[current];
                end
            end
        end
    end

    if diff < 0 or (diff == 0 and lastDirection == -1) then
        lastDirection = -1
        if source[i] >= close[current] - StepPips and source[i] <= close[current] + 2 * StepPips then
            volume[current] = volume[current] + history.volume[i]
        end
        while source[i] < close[current] - StepPips do
            current = current + 1
            if open:date(current - 1) < source:date(i) then
                instance:addViewBar(source:date(i))
                volume[current] = history.volume[i]
            else
                instance:addViewBar(open:date(current - 1) + OneSecond)
                volume[current] = 0
            end
            open[current] = close[current - 1]
            high[current] = open[current]
            close[current] = open[current] - StepPips
            low[current] = close[current]
            MA_indi:update(core.UpdateLast);
            if MA_indi.DATA:hasData(current) then
                MA[current] = MA_indi.DATA[current];
            end
        end
        if source[i] > close[current] + 2 * StepPips then
            while source[i] > close[current] + StepPips do
                current = current + 1
                if open:date(current - 1) < source:date(i) then
                    instance:addViewBar(source:date(i))
                    volume[current] = history.volume[i]
                else
                    instance:addViewBar(open:date(current - 1) + OneSecond)
                    volume[current] = 0
                end
                if close[current - 1] < open[current - 1] then
                    open[current] = close[current - 1] + StepPips
                else
                    open[current] = close[current - 1]
                end
                low[current] = open[current]
                close[current] = open[current] + StepPips
                high[current] = close[current]
                MA_indi:update(core.UpdateLast);
                if MA_indi.DATA:hasData(current) then
                    MA[current] = MA_indi.DATA[current];
                end
            end
        end
    end
    return current
end

function handleHistory()
    local s = history:size() - 1
    local i
    local current = open:size() - 1
    MA_indi:update(core.UpdateLast);
    for i = 1, s, 1 do
        current = calcValue(current, i)
    end
    loading = false
    LastTime = history:date(history:size() - 1)
end

local last_serial;

function FindCross()
    for i = close:size() - 1, 1, -1 do
        if core.crossesOver(close, MA_indi.DATA, i) then
            return 1, i;
        end
        if core.crossesUnder(close, MA_indi.DATA, i) then
            return -1, i;
        end
    end
end

function IsBuyCondition(source, period)
    if MA_indi.DATA:size() < instance.parameters.min_bricks + 2 
        or not MA_indi.DATA:hasData(NOW - instance.parameters.min_bricks - 2) 
    then
        return false;
    end
    local side, p = FindCross();
    if side ~= 1 then
        return false;
    end
    return (last_serial == nil or close:date(p) > last_serial) 
        and close:size() - 1 - p >= instance.parameters.min_bricks;
end

function IsSellCondition(source, period)
    if MA_indi.DATA:size() < instance.parameters.min_bricks + 2 
        or not MA_indi.DATA:hasData(NOW - instance.parameters.min_bricks - 2) 
    then
        return false;
    end
    local side, p = FindCross();
    if side ~= -1 then
        return false;
    end
    return (last_serial == nil or close:date(p) > last_serial) 
        and close:size() - 1 - p >= instance.parameters.min_bricks;
end

function handleUpdate()
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(1, close, close:size() - 1); end end
    MA_indi:update(core.UpdateLast);
    if not loading and history:size() > 0 then
        if history:date(history:size() - 1) ~= LastTime then
            calcValue(open:size() - 1, history:size() - 2)
            LastTime = history:date(history:size() - 1)
        end
        if IsBuyCondition(close, NOW) then
            signaler:Signal("Buy");
            last_serial = close:date(NOW);
        end
        if IsSellCondition(close, now) then
            signaler:Signal("Sell");
            last_serial = close:date(NOW);
        end
    end
end

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.5";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};

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
    if cookie == self._advanced_alert_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._advanced_alert_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
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
        source = instance.bid;
        if instance.bid == nil then
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        else
            source = instance.bid;
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
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram message or Channel post", false);
    parameters:addString("advanced_alert_key", "Advanced Alert Key", "You can get it via @profit_robots_bot Telegram bot", "");
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