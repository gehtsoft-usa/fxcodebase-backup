-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=29&t=7741

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    strategy:name("Indicator alert")
    strategy:description("Alerts when a certain indicator/oscillator crosses a certain level")
    strategy:setTag("Version", "3")

    strategy.parameters:addGroup("Parameters")

    strategy.parameters:addString("Indicator", "Indicator", "", "MVA")
    strategy.parameters:setFlag("Indicator", core.FLAG_INDICATOR)

    strategy.parameters:addInteger("Index", "Index of stream", "The number of the indicator stream (for indicators with more than one output stream, e.g. MACD).", 1, 1, 30)

    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addBoolean("use_close_price", "Use close price", "", true);
    strategy.parameters:addDouble("Price", "Price Level", "", 0)

    strategy.parameters:addString("Condition", "Condition", "", "C")
    strategy.parameters:addStringAlternative("Condition", "Crosses", "", "C")
    strategy.parameters:addStringAlternative("Condition", "Crosses or touches", "", "CT")
    strategy.parameters:addStringAlternative("Condition", "Crosses above", "", "CA")
    strategy.parameters:addStringAlternative("Condition", "Crosses above or touches", "", "CAT")
    strategy.parameters:addStringAlternative("Condition", "Crosses below", "", "CB")
    strategy.parameters:addStringAlternative("Condition", "Crosses below or touches", "", "CBT")

    strategy.parameters:addString("Period", "Period size", "", "m1")
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS)

    strategy.parameters:addGroup("Notification")

    signaler:Init(strategy.parameters);

    strategy.parameters:addGroup("Alert Parameters")
    strategy.parameters:addString("Live", "Execution", "", "Live")
    strategy.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
    strategy.parameters:addStringAlternative("Live", "Live", "", "Live")
end

local gSource = nil -- the source stream
local indi = nil

local CT_CROSS = 1
local CT_CROSSTOUCH = 2
local CT_CROSSABOVE = 3
local CT_CROSSABOVETOUCH = 4
local CT_CROSSBELOW = 5
local CT_CROSSBELOWTOUCH = 6
local Price
local use_close_price
local gCondition
local index
local indiStream

local first
local MAIN_COLLECTION = 1
local LIVE_COLLECTION = 2
local act_on_live_source

function Prepare(nameOnly)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    local Condition

    -- collect parameters
    Price = instance.parameters.Price
    use_close_price = instance.parameters.use_close_price;
    Condition = instance.parameters.Condition
    local Period = instance.parameters.Period
    index = instance.parameters.Index

    SIGNAL = "Condition met"

    local indiProfile = core.indicators:findIndicator(instance.parameters.Indicator)

    if indiProfile:requiredSource() == core.Bar and Period == "t1" then
        error(indiProfile:name() .. " cannot be applied on Tick, please change the parameter Period size.")
    end

    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. Period .. ")" .. ", " .. instance.parameters.Indicator .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end

    if indiProfile:requiredSource() == core.Bar then
        gSource = ExtSubscribe(MAIN_COLLECTION, nil, Period, instance.parameters.Type == "Bid", "bar")
    else
        gSource = ExtSubscribe(MAIN_COLLECTION, nil, Period, instance.parameters.Type == "Bid", "close")
    end

    if instance.parameters.Live == "Live" then
        ExtSubscribe(LIVE_COLLECTION, nil, "t1", instance.parameters.Type == "Bid", "close")
        act_on_live_source = true
    end

    indi = indiProfile:createInstance(gSource, instance.parameters:getCustomParameters("Indicator"))
    local streamCount = indi:getStreamCount()

    assert((index <= streamCount), "Incorrect index of stream. The indicator has only " .. streamCount .. " stream(s).")

    indiStream = indi:getStream(index - 1)

    if Condition == "C" then
        gCondition = CT_CROSS
        SIGNAL = "Indicator crosses the specified level"
    elseif Condition == "CT" then
        gCondition = CT_CROSSTOUCH
        SIGNAL = "Indicator crosses or touches the specified level"
    elseif Condition == "CA" then
        gCondition = CT_CROSSABOVE
        SIGNAL = "Indicator crosses above the specified level"
    elseif Condition == "CAT" then
        gCondition = CT_CROSSABOVETOUCH
        SIGNAL = "Indicator crosses above or touches the specified level"
    elseif Condition == "CB" then
        gCondition = CT_CROSSBELOW
        SIGNAL = "Indicator crosses below the specified level"
    elseif Condition == "CBT" then
        gCondition = CT_CROSSBELOWTOUCH
        SIGNAL = "Indicator crosses below or touches the specified level"
    end

    first = indiStream:first() + 1
end

function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
end

local last_serial;

-- when tick source is updated
function ExtUpdate(id, source, period)
    for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
    -- update indicator
    if indi ~= nil then
        indi:update(core.UpdateLast)
    end

    if act_on_live_source and id ~= LIVE_COLLECTION then
        return
    elseif act_on_live_source and id == LIVE_COLLECTION then
        period = gSource:size() - 1
    end

    if period < first then
        return
    end

    if (indiStream:hasData(period - 1)) and (indiStream:hasData(period)) and last_serial ~= gSource:serial(period) then
        local price = Price;
        if use_close_price then
            price = gSource.close[period];
        end
        if gCondition == CT_CROSS and core.crosses(indiStream, price, period) then
            signaler:Signal(SIGNAL, gSource)
            last_serial = gSource:serial(period);
        elseif gCondition == CT_CROSSTOUCH and (core.crosses(indiStream, price, period) or indiStream[period] == price) then
            signaler:Signal(SIGNAL, gSource)
            last_serial = gSource:serial(period);
        elseif gCondition == CT_CROSSABOVE and core.crossesOver(indiStream, price, period) then
            signaler:Signal(SIGNAL, gSource)
            last_serial = gSource:serial(period);
        elseif gCondition == CT_CROSSABOVETOUCH and (core.crossesOverOrTouch(indiStream, price, period)) then
            signaler:Signal(SIGNAL, gSource)
            last_serial = gSource:serial(period);
        elseif gCondition == CT_CROSSBELOW and core.crossesUnder(indiStream, price, period) then
            signaler:Signal(SIGNAL, gSource)
            last_serial = gSource:serial(period);
        elseif gCondition == CT_CROSSBELOWTOUCH and (core.crossesUnderOrTouch(indiStream, price, period)) then
            signaler:Signal(SIGNAL, gSource)
            last_serial = gSource:serial(period);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.4";

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

function signaler:Signal(label, source)
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
        terminal:alertMessage(source:instrument(), source[NOW], label, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. label, self:FormatEmail(source, NOW, label));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(label, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(label);
    end

    if self._show_popup == true then
        local subject, text = self:FormatEmail(source, NOW, label);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
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
    parameters:addBoolean("signaler_debug_alert", "Print into log", "", false);
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram message or Channel post", false);
    parameters:addString("advanced_alert_key", "Advanced Alert Key", "You can get it via @profit_robots_bot Telegram bot", "");
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
signaler:RegisterModule(Modules);