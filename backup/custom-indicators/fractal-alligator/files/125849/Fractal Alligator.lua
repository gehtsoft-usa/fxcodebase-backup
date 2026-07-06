-- Id: 24737
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

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
    indicator:name("Fractal - Alligator")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator:setTag("group", "Bill Williams")

    indicator.parameters:addGroup("Alligator Calculation")
    indicator.parameters:addInteger("JawN", "Alligator Jaw smoothing periods", "", 13, 1, 300)
    indicator.parameters:addInteger("JawS", "Alligator Jaw shifting periods", "", 8, 0, 300)

    indicator.parameters:addInteger("TeethN", "Alligator Teeth smoothing periods", "", 8, 1, 300)
    indicator.parameters:addInteger("TeethS", "Alligator Teeth shifting periods", "", 5, 0, 300)

    indicator.parameters:addInteger("LipsN", "Alligator Lips smoothing periods", "", 5, 1, 300)
    indicator.parameters:addInteger("LipsS", "Alligator Lips shifting periods", "", 3, 0, 300)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("clrUP", "Up Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addInteger("UPW", "Up Width", "", 1, 1, 5);
    indicator.parameters:addInteger("UPSt", "Up Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("UPSt", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clrDN", "Down Color", "", core.COLOR_DOWNCANDLE)
    indicator.parameters:addInteger("DNW", "Down Width", "", 1, 1, 5);
    indicator.parameters:addInteger("DNSt", "Down Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("DNSt", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clrUPActivated", "Activated Up Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addInteger("UPActivatedW", "Activated Up Width", "", 1, 1, 5);
    indicator.parameters:addInteger("UPActivatedSt", "Activated Up Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("UPActivatedSt", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clrDNActivated", "Activated Down Color", "", core.COLOR_DOWNCANDLE)
    indicator.parameters:addInteger("DNActivatedW", "Activated Down Width", "", 1, 1, 5);
    indicator.parameters:addInteger("DNActivatedSt", "Activated Down Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("DNActivatedSt", core.FLAG_LINE_STYLE);

    signaler:Init(indicator.parameters);
end

local source
local JawN, JawS, TeethN, TeethS, LipsN, LipsS
local alligator;

function Prepare(nameOnly)
    signaler:Prepare(nameOnly);
    source = instance.source

    JawN = instance.parameters.JawN;
    JawS = instance.parameters.JawS;
    TeethN = instance.parameters.TeethN;
    TeethS = instance.parameters.TeethS;
    LipsN = instance.parameters.LipsN;
    LipsS = instance.parameters.LipsS;

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    alligator = core.indicators:create("ALLIGATOR", source, JawN, JawS, TeethN, TeethS, LipsN, LipsS)

    instance:ownerDrawn(true);
end

local fractals = {};
local UP_PEN = 1;
local DOWN_PEN = 2;
local ACTIVATED_UP_PEN = 3;
local ACTIVATED_DOWN_PEN = 4;
local init = false;

function DrawFractal(context, fractal)
    if fractal == nil then
        return;
    end
    local x1 = context:positionOfDate(fractal.Start);
    local x2 = context:right();
    if fractal.TriggeredDate ~= nil then
        x2 = context:positionOfDate(fractal.TriggeredDate);
    end
    local _, y = context:pointOfPrice(fractal.Level);
    if x1 < context:right() and x2 > context:left() then
        local pen;
        if fractal.IsUp then
            pen = fractal.Triggered and ACTIVATED_UP_PEN or UP_PEN;
        else
            pen = fractal.Triggered and ACTIVATED_DOWN_PEN or DOWN_PEN;
        end
        context:drawLine(pen, x1, y, x2, y);
    end
end

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(UP_PEN, context:convertPenStyle(instance.parameters.UPSt), instance.parameters.UPW, instance.parameters.clrUP);
        context:createPen(DOWN_PEN, context:convertPenStyle(instance.parameters.DNSt), instance.parameters.DNW, instance.parameters.clrDN);
        context:createPen(ACTIVATED_UP_PEN, context:convertPenStyle(instance.parameters.UPActivatedSt), instance.parameters.UPActivatedW, instance.parameters.clrUPActivated);
        context:createPen(ACTIVATED_DOWN_PEN, context:convertPenStyle(instance.parameters.DNActivatedSt), instance.parameters.DNActivatedW, instance.parameters.clrDNActivated);
        init = true;
    end

    local lastUp, prevUp, lastDown, prevDown;
    for _, fractal in ipairs(fractals) do
        if fractal.IsUp then
            prevUp = lastUp;
            lastUp = fractal;
        else
            prevDown = lastDown;
            lastDown = fractal;
        end
    end
    DrawFractal(context, prevUp);
    DrawFractal(context, lastUp);
    DrawFractal(context, prevDown);
    DrawFractal(context, lastDown);
end

function Update(period, mode)
    if mode == core.UpdateAll then
        fractals = {};
    end
    for _, fractal in ipairs(fractals) do
        if not fractal.Triggered then
            if fractal.IsUp and source.high[period] > fractal.Level then
                fractal.Triggered = true;
                fractal.TriggeredDate = source:date(period);
                if period == source:size() - 1 then
                    signaler:Signal("Up level crossed by price")
                end
            elseif not fractal.IsUp and source.low[period] < fractal.Level then
                fractal.Triggered = true;
                fractal.TriggeredDate = source:date(period);
                if period == source:size() - 1 then
                    signaler:Signal("Down level crossed by price")
                end
            end
        end
    end
    period = period - 1;
    if (period <= 6) then
        return;
    end
    alligator:update(mode);
    local curr = source.high[period - 2]
    if curr > source.high[period - 4] 
        and curr > source.high[period - 3] 
        and curr > source.high[period - 1] 
        and curr > source.high[period]
        and curr >= alligator.Teeth[period - 2]
        and alligator.Teeth[period - 2] >= alligator.Teeth[period - 3]
    then
        for _, fractal in ipairs(fractals) do
            if not fractal.Triggered and fractal.IsUp then
                fractal.Triggered = true;
                fractal.TriggeredDate = source:date(period + 1);
            end
        end
        local fractal =
        {
            IsUp = true;
            Level = source.high[period - 2];
            Triggered = false;
            Start = source:date(period - 2);
        };
        fractals[#fractals + 1] = fractal;
    end
    curr = source.low[period - 2]
    if curr < source.low[period - 4] 
        and curr < source.low[period - 3] 
        and curr < source.low[period - 1] 
        and curr < source.low[period]
        and curr <= alligator.Teeth[period - 2]
        and alligator.Teeth[period - 2] <= alligator.Teeth[period - 3]
    then
        for _, fractal in ipairs(fractals) do
            if not fractal.Triggered and not fractal.IsUp then
                fractal.Triggered = true;
                fractal.TriggeredDate = source:date(period + 1);
            end
        end
        local fractal =
        {
            IsUp = false;
            Level = source.low[period - 2];
            Triggered = false;
            Start = source:date(period - 2);
        };
        fractals[#fractals + 1] = fractal;
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, successful, message, message1, message2);
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
		"You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "")
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