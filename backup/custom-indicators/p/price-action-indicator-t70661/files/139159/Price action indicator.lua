-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70661

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

local source, distance
local Modules = {};
local indi_alerts = {};
indi_alerts.Version = "2.2";
indi_alerts.inverted_arrows = false;
local alerts = 
{ 
    {
        Stage = 102,
        UpCondition = function (period)
            local DistanceB = (source.close[period] - source.open[period]) / source:pipSize();
            if DistanceB < distance then
                return false;
            end

            if trading:FindTrade()
                :WhenInstrument(source:instrument())
                :WhenSide("S"):Any()
            then
                return false;
            end

            local last_trade;
            trading:FindTrade()
                :WhenInstrument(source:instrument())
                :WhenSide("B")
                :Do(function (trade)
                    if last_trade == nil or trade.Time > last_trade.Time then
                        last_trade = trade;
                    end
                end);
            if last_trade == nil then
                return true;
            end

            return last_trade.Open < source.close[period];
        end,
        DownCondition = function (period)
            local DistanceB = (source.open[period] - source.close[period]) / source:pipSize();
            if DistanceB < distance then
                return false;
            end

            if trading:FindTrade()
                :WhenInstrument(source:instrument())
                :WhenSide("B"):Any()
            then
                return false;
            end

            local last_trade;
            trading:FindTrade()
                :WhenInstrument(source:instrument())
                :WhenSide("S")
                :Do(function (trade)
                    if last_trade == nil or trade.Time > last_trade.Time then
                        last_trade = trade;
                    end
                end);
            if last_trade == nil then
                return true;
            end

            return last_trade.Open > source.close[period];
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "Alert Name"
    }
};

function Init()
    indicator:name("Price action indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addDouble("distance", "Distance, pips", "", 50);
    indi_alerts:AddParameters(indicator.parameters);
    for i,alert in ipairs(alerts) do
        indi_alerts:AddAlert(alert.Name);
    end
end

function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    distance = instance.parameters.distance;
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

function Update(period, mode)
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        return;
    end
    local isUp, upMetadata = alert.UpCondition(period);
    if isUp then
        if alert.OnChange then
            local isUpPrev, _ = alert.UpCondition(period - 1);
            if isUpPrev then
                return;
            end
        end
        if source:isBar() then
            alert:UpAlert(source, period, source.high[period], historical_period, upMetadata);
        else
            alert:UpAlert(source, period, source[period], historical_period, upMetadata);
        end
        return;
    end
    local isDown, downMetadata = alert.DownCondition(period);
    if isDown then
        if alert.OnChange then
            local isDownPrev, _ = alert.DownCondition(period - 1);
            if isDownPrev then
                return;
            end
        end
        if source:isBar() then
            alert:DownAlert(source, period, source.low[period], historical_period, downMetadata);
        else
            alert:DownAlert(source, period, source[period], historical_period, downMetadata);
        end
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

indi_alerts.last_id = 0;
indi_alerts._alerts = {};
indi_alerts._advanced_alert_timer = nil;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Alert Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    indicator.parameters:addBoolean("strategy_output", "Output for strategies", "Used by the strategies", false);

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false);
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    
    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    indicator.parameters:addGroup("External Alerts");
    indicator.parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	indicator.parameters:addString("advanced_alert_key", "Advanced Alert Key",
		"You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for Discord/other platform keys", "")
end

function indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2) if cookie == self._advanced_alert_timer and #self._alerts > 0 then if self._advanced_alert_key == nil then return; end local data = self:ArrayToJSON(self._alerts); self._alerts = {}; local req = http_lua.createRequest(); local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}', self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data); req:setRequestHeader("Content-Type", "application/json"); req:setRequestHeader("Content-Length", tostring(string.len(query))); req:start("http://profitrobots.com/api/v1/notification", "POST", query); end end
function indi_alerts:ToJSON(item)
    local json = {};
    function json:AddStr(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value)); end
    function json:AddNumber(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0); end
    function json:AddBool(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false"); end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    local first = true; for idx,t in pairs(item) do  local stype = type(t) if stype == "number" then json:AddNumber(idx, t); elseif stype == "string" then json:AddStr(idx, t); elseif stype == "boolean" then json:AddBool(idx, t); elseif stype == "function" or stype == "table" then else core.host:trace(tostring(idx) .. " " .. tostring(stype)); end end
    return json:ToString();
end
function indi_alerts:ArrayToJSON(arr) local str = "["; for i, t in ipairs(self._alerts) do local json = self:ToJSON(t); if str == "[" then str = str .. json; else str = str .. "," .. json; end end return str .. "]"; end
function indi_alerts:AddAlert(label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. label .." Alert" , "", true);

    indicator.parameters:addString("drawing_mode" .. self.last_id, "Drawing mode", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Arrows", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Vertical lines", "", "vlines");

    indicator.parameters:addFile("Up" .. self.last_id, label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Up Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Up Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addFile("Down" .. self.last_id, label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("DownSymbol" .. self.last_id, "Down Symbol", "", 218);
    indicator.parameters:addColor("DownColor" .. self.last_id, "Down Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addString("Label" .. self.last_id, "Label", "", label);
end

function indi_alerts:AddSingleAlert(Label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. Label .." Alert" , "", true);

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addString("Label" .. self.last_id, "Label", "", Label);
end

function indi_alerts:DrawAlert(context, alert, period)
    if not alert.Alert:hasData(period) then
        return;
    end

    if alert.Alert[period] == 1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self._stages[alert.Stage].FONT_ID, alert.UpSymbol, 0);
            local x1 = x - width / 2;
            local x2 = x + width / 2;
            local y1, y2;
            if self.inverted_arrows then
                y1 = y;
                y2 = y + height;
            else
                y1 = y - height;
                y2 = y;
            end
			context:drawText(self._stages[alert.Stage].FONT_ID, alert.UpSymbol, alert.UpColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.UpLinePen, x, context:top(), x, context:bottom());
        end
	elseif alert.Alert[period] == -1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self._stages[alert.Stage].FONT_ID, alert.DownSymbol, 0);
            local x1 = x - width / 2;
            local x2 = x + width / 2;
            local y1, y2;
            if self.inverted_arrows then
                y1 = y - height;
                y2 = y;
            else
                y1 = y;
                y2 = y + height;
            end
            context:drawText(self._stages[alert.Stage].FONT_ID, alert.DownSymbol, alert.DownColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.DownLinePen, x, context:top(), x, context:bottom());
        end
    end
end
indi_alerts.NextId = 1;
indi_alerts._stages = {};
function indi_alerts:Draw(stage, context)
    if self._stages[stage] == nil then
        self._stages[stage] = {};
        self._stages[stage].createFont = false;
        for _, level in ipairs(self.Alerts) do
            if level.Stage == stage then
                if level.DrawingMode == "vlines" then
                    level.UpLinePen = self.NextId;
                    self.NextId = self.NextId + 1;
                    level.DownLinePen = self.NextId;
                    self.NextId = self.NextId + 1;
                    context:createPen(level.UpLinePen, context.SOLID, 1, level.UpColor);
                    context:createPen(level.DownLinePen, context.SOLID, 1, level.DownColor);
                else
                    self._stages[stage].createFont = true;
                end
            end
        end
        if self._stages[stage].createFont and self._stages[stage].FONT_ID == nil then
            self._stages[stage].FONT_ID = self.NextId;
			self.NextId = self.NextId + 1;
            context:createFont(self._stages[stage].FONT_ID, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0);
        end
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size()-1), 1 do
        for _, level in ipairs(self.Alerts) do
            if level.Stage == stage then
                self:DrawAlert(context, level, period);
            end
        end
    end
end
indi_alerts.Alerts = {};
function indi_alerts:GetTimezone()
    local tz = instance.parameters.ToTime;
    if tz == 1 then
        return core.TZ_EST
    elseif tz == 2 then
        return core.TZ_UTC
    elseif tz == 3 then
        return core.TZ_LOCAL
    elseif tz == 4 then
        return core.TZ_SERVER
    elseif tz == 5 then
        return core.TZ_FINANCIAL
    elseif tz == 6 then
        return core.TZ_TS
    end
end
function indi_alerts:Prepare()
    self.Show = instance.parameters.Show;
    self.Live = instance.parameters.Live;
    self.ShowAlert = instance.parameters.ShowAlert;
    self.ToTime = self:GetTimezone();
    
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    for i = 1, 100 do 
        local on = instance.parameters:getBoolean("ON" .. i);
        if on == nil then
            break;
        end 
        local alert = {};
        alert.id = i;
        alert.UpCondition = alerts[i].UpCondition;
        alert.FormatMessage = alerts[i].FormatMessage;
        alert.DownCondition = alerts[i].DownCondition;
        alert.OnChange = alerts[i].OnChange;
        alert.Stage = alerts[i].Stage;
        alert.FilterConsecutive = alerts[i].FilterConsecutive;
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = on;
        alert.DrawingMode = instance.parameters:getString("drawing_mode" .. i);
        alert.UpSymbol = string.char(instance.parameters:getInteger("UpSymbol" .. i));
        local down_symbol = instance.parameters:getInteger("DownSymbol" .. i);
        if down_symbol ~= nil then
            alert.DownSymbol = string.char(down_symbol);
        end
        alert.UpColor = instance.parameters:getColor("UpColor" .. i);
        alert.DownColor = instance.parameters:getColor("DownColor" .. i);
        alert.Up = self.PlaySound and instance.parameters:getString("Up" .. i) or nil;
        alert.Down = self.PlaySound and instance.parameters:getString("Down" .. i) or nil;
        if alert.DownSymbol == nil then
            alert.DownSymbol = alert.UpSymbol;
            alert.DownColor = alert.UpColor;
            alert.Down = alert.Up;
        end
        assert(not(self.PlaySound) or (self.PlaySound and alert.Up ~= "") or (self.PlaySound and alert.Up ~= ""), "Sound file must be chosen"); 
        assert(not(self.PlaySound) or (self.PlaySound and alert.Down ~= "") or (self.PlaySound and alert.Down ~= ""), "Sound file must be chosen");
        alert.U = nil;
        alert.D = nil;
        if instance.parameters.strategy_output then
            alert.Alert = instance:addStream("strat_signal_" .. i, core.Dot, "strat_signal_" .. i, "Strategy signal #" .. i, core.rgb(0, 0, 0), 0, 0);
        else
            alert.Alert = instance:addInternalStream(0, 0);
        end
        alert.AlertLevel = instance:addInternalStream(0, 0);
        function alert:Clear(period)
            local bookmark = self.Alert:getBookmark(i);
            if bookmark ~= period then
                return;
            end
            local i = 1;
            while (bookmark ~= -1) do
                bookmark = self.Alert:getBookmark(i + 1);
                self.Alert:setBookmark(i, bookmark);
                i = i + 1;
            end
        end
        function alert:AddBookmark(period)
            local i = 1;
            local bookmark = self.Alert:getBookmark(i);
            if bookmark == period then
                return;
            end
            self.Alert:setBookmark(1, period);
            while (bookmark ~= -1) do
                local last_bookmark = self.Alert:getBookmark(i + 1);
                self.Alert:setBookmark(i + 1, bookmark);
                bookmark = last_bookmark;
                i = i + 1;
            end
        end
        function alert:DownAlert(source, period, level, historical_period, metadata)
            if self.FilterConsecutive then
                local last_signal = self:GetLast(period - 1);
                if last_signal == -1 then
                    return;
                end
            end
            local text = self.FormatMessage(source, period, level, self.Label, false, metadata);
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = -1;
            self:AddBookmark(period);
            self.AlertLevel[period] = level;
            self.U = nil;
            if self.D ~= source:date(period) and period == source:size() - 1 - shift then
                self.D = source:date(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Down);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:UpAlert(source, period, level, historical_period, metadata)
            if self.FilterConsecutive then
                local last_signal = self:GetLast(period - 1);
                if last_signal == 1 then
                    return;
                end
            end
            local text = self.FormatMessage(source, period, level, self.Label, true, metadata);
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = 1;
            self:AddBookmark(period);
            self.AlertLevel[period] = level;
            self.D = nil;
            if self.U ~= source:date(period) and period == source:size() - 1 - shift then
                self.U = source:date(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Up);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:GetLast(period)
            local index = self.Alert:getBookmark(1);
            if index == -1 then
                return nil;
            end
            return self.Alert[index], index, self.AlertLevel[index];
        end
        self.Alerts[#self.Alerts + 1] = alert;
    end

    self.Email = self.SendEmail and instance.parameters.Email or nil;
    assert(not(self.SendEmail) or (self.SendEmail and self.Email ~= ""), "E-mail address must be specified");
    self.RecurrentSound = instance.parameters.RecurrentSound;

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = 1234;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, self.source:instrument() .. " " .. label .. " : " .. note);
end

function indi_alerts:SoundAlert(Sound)
    if not self.PlaySound then
        return;
    end
    terminal:alertSound(Sound, self.RecurrentSound);
end

function indi_alerts:EmailAlert(label, Subject, period)
    if not self.SendEmail then
        return
    end

    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;   
    local Symbol = "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(self.Email, profile:id(), text);
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return;
    end
    
    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;
    local Symbol= "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW));
end

function indi_alerts:AlertTelegram(message, instrument, timeframe) local alert = {}; alert.Text = message or ""; alert.Instrument = instrument or ""; alert.TimeFrame = timeframe or ""; self._alerts[#self._alerts + 1] = alert; end


trading = {};
trading.Name = "Trading";
trading.Version = "4.33";
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
        parameters:addStringAlternative("amount_type" .. id, "% of Margin", "", "margin");
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

function trading:PartialClose(trade, amount)
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
        if self._order == nil and self.RequestID ~= nil then
            self._order = core.host:findTable("orders"):find("RequestID", self.RequestID);
            if self._order == nil then
                return nil;
            end
        end
        if not self._order:refresh() then return nil; end
        return self._order;
    end
    function res:GetTrade()
        if self._trade == nil and self.RequestID ~= nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then
                return nil;
            end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil and self.RequestID ~= nil then
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
    function builder:SetPercentOfMarginAmount(percent) self._PercentOfMarginAmount = percent; return self; end
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
        elseif self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).UsableMargin;
            local used_equity = equity * self._PercentOfMarginAmount / 100.0;
            local emr = core.host:getTradingProperty("EMR", self.Offer.Instrument, self.valuemap.AcctID);
            self.valuemap.Quantity = math.floor(used_equity / emr) * self:_GetBaseUnitSize();
        else
            self.valuemap.Quantity = self.amount * self:_GetBaseUnitSize();
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
        if self._closed_trade == nil and self.RequestID ~= nil then
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
    function builder:SetPercentOfMarginAmount(percent) self._PercentOfMarginAmount = percent; return self; end
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
        elseif self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).UsableMargin;
            local used_equity = equity * self._PercentOfMarginAmount / 100.0;
            local emr = core.host:getTradingProperty("EMR", self.Offer.Instrument, self.valuemap.AcctID);
            self.valuemap.Quantity = math.floor(used_equity / emr) * self:_GetBaseUnitSize();
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
