-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68778

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

local indi_alerts = {};
indi_alerts.Version = "1.11";
indi_alerts.inverted_arrows = false;
local alert_stages = { 2 };

function Init()
    indicator:name("ssTTM Squeeze")
    indicator:description("ssTTM Squeeze")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addBoolean("Draw_Oscillator_Lines", "Draw_Oscillator_Lines", "", false);
    indicator.parameters:addGroup("RSI");
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 14);
    indicator.parameters:addColor("rsi_color", "RSI Color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("rsi_width", "RSI Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("rsi_style", "RSI Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("rsi_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addGroup("STOCHASTIC");
    indicator.parameters:addInteger("ssd_k_1", "%K #1", "", 8);
    indicator.parameters:addInteger("ssd_sd_1", "%SD #1", "", 3);
    indicator.parameters:addInteger("ssd_d_1", "%D #1", "", 3);
    indicator.parameters:addColor("ssd1_color", "SSD #1 Color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ssd1_width", "SSD #1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ssd1_style", "SSD #1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ssd1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addInteger("ssd_k_2", "%K #1", "", 8);
    indicator.parameters:addInteger("ssd_sd_2", "%SD #1", "", 3);
    indicator.parameters:addInteger("ssd_d_2", "%D #1", "", 3);
    indicator.parameters:addColor("ssd2_color", "SSD #2 Color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ssd2_width", "SSD #2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ssd2_style", "SSD #2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ssd2_style", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("hist_up_color", "Histogram Up Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("hist_down_color", "Histogram Down Color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("hist_no_color", "Histogram Neutral Color", "Color", core.rgb(128, 128, 128));

    indicator.parameters:addBoolean("Draw_HullTrend", "Draw_HullTrend", "", true);
    indicator.parameters:addInteger("hull_period", "Hull Period", "", 12);
    indicator.parameters:addColor("hull_up_color", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("hull_down_color", "Down Color", "", core.rgb(255, 0, 0));
    
    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Alert Name");
    indicator.parameters:addDouble("Alert_Threshold_Line", "Alert_Threshold_Line", "", 20);
end

local source = nil
local rsi, rsi_out;
local ssd1, ssd2, ssd1_out, ssd2_out, hist;
local hist_up_color, hist_down_color, hist_no_color, Alert_Threshold_Line;
local hma, hma_out, hull_up_color, hull_down_color;

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name)
    hist_up_color = instance.parameters.hist_up_color;
    hist_down_color = instance.parameters.hist_down_color;
    hist_no_color = instance.parameters.hist_no_color;
    Alert_Threshold_Line = instance.parameters.Alert_Threshold_Line;
    hull_up_color = instance.parameters.hull_up_color;
    hull_down_color = instance.parameters.hull_down_color;
    if nameOnly then
        return;
    end
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);

    rsi = core.indicators:create("RSI", source, instance.parameters.RSI_Period);
    ssd1 = core.indicators:create("SSD", source, instance.parameters.ssd_k_1, instance.parameters.ssd_sd_1, instance.parameters.ssd_d_1);
    ssd2 = core.indicators:create("SSD", source, instance.parameters.ssd_k_2, instance.parameters.ssd_sd_2, instance.parameters.ssd_d_2);
    if instance.parameters.Draw_Oscillator_Lines then
        rsi_out = instance:addStream("rsi", core.Line, "RSI", "RSI", instance.parameters.rsi_color, 0, 0);
    rsi_out:setPrecision(math.max(2, instance.source:getPrecision()));
        rsi_out:setWidth(instance.parameters.rsi_width);
        rsi_out:setStyle(instance.parameters.rsi_style);
        ssd1_out = instance:addStream("SSD1", core.Line, "SSD1", "SSD1", instance.parameters.ssd1_color, 0, 0);
    ssd1_out:setPrecision(math.max(2, instance.source:getPrecision()));
        ssd1_out:setWidth(instance.parameters.ssd1_width);
        ssd1_out:setStyle(instance.parameters.ssd1_width);
        ssd2_out = instance:addStream("SSD2", core.Line, "SSD2", "SSD2", instance.parameters.ssd2_color, 0, 0);
    ssd2_out:setPrecision(math.max(2, instance.source:getPrecision()));
        ssd2_out:setWidth(instance.parameters.ssd2_width);
        ssd2_out:setStyle(instance.parameters.ssd2_width);
    end
    if instance.parameters.Draw_HullTrend then
        local profile = core.indicators:findIndicator("HMA");
        assert(profile ~= nil, "Please, download and install " .. "HMA" .. ".LUA indicator");
        local indicatorParams = profile:parameters();
        hma = core.indicators:create("HMA", source, instance.parameters.hull_period);
        hma_out = instance:addStream("hma_out", core.Dot, "HMA", "HMA", hull_up_color, 0, 0);
    hma_out:setPrecision(math.max(2, instance.source:getPrecision()));
        hma_out:setWidth(3);
    end
    HIST = instance:addStream("HIST", core.Bar, "HIST", "HIST", hist_up_color, 0, 0);
    HIST:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    rsi:update(mode);
    ssd1:update(mode);
    ssd2:update(mode);
    if (hma ~= nil) then
        hma:update(mode);
        if (period > 0) then
            hma_out[period] = 0;
            if hma.DATA[period] > hma.DATA[period - 1] then
                hma_out:setColor(period, hull_up_color);
            else
                hma_out:setColor(period, hull_down_color);
            end
        end
    end
    if rsi_out ~= nil then
        rsi_out[period] = rsi.DATA[period] - 50;
        ssd1_out[period] = ssd1.K[period] - 50;
        ssd2_out[period] = ssd2.K[period] - 50;
    end

    HIST[period] = ssd2.K[period] - 50;
    if rsi.DATA[period] - 50 > 0 and ssd1.K[period] - 50 > 0 and ssd2.K[period] - 50 > 0 then
        HIST:setColor(period, hist_up_color);
    elseif rsi.DATA[period] - 50 < 0 and ssd1.K[period] - 50 < 0 and ssd2.K[period] - 50 < 0 then
        HIST:setColor(period, hist_down_color);
    else
        HIST:setColor(period, hist_no_color);
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function Up(period)
    return rsi.DATA[period] - 50 > 0 and ssd1.K[period] - 50 > 0 and ssd2.K[period] - 50 > 0 and HIST[period] > Alert_Threshold_Line;
end

function Down(period)
    return rsi.DATA[period] - 50 < 0 and ssd1.K[period] - 50 < 0 and ssd2.K[period] - 50 < 0 and HIST[period] < -Alert_Threshold_Line;
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if alert.id == 1 then
        if Up(period) and not Up(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Bull pattern", source.high[period], historical_period);
        elseif Down(period) and not Down(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Bear pattern", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
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
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    
    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
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
    local i;
    for i = 1, 100 do 
        local on = instance.parameters:getBoolean("ON" .. i);
        if on == nil then
            break;
        end 
        local alert = {};
        alert.id = i;
        alert.Stage = alert_stages[i];
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
    alert.Alert:setPrecision(math.max(2, instance.source:getPrecision()));
        else
            alert.Alert = instance:addInternalStream(0, 0);
        end
        alert.AlertLevel = instance:addInternalStream(0, 0);
        function alert:DownAlert(source, period, text, level, historical_period)
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = -1;
            self.AlertLevel[period] = level;
            self.U = nil;
            if self.D ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.D = source:serial(period);
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
        function alert:UpAlert(source, period, text, level, historical_period)
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = 1;
            self.AlertLevel[period] = level;
            self.D = nil;
            if self.U ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.U = source:serial(period);
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
            for i = period, 0, -1 do
                if self.Alert:hasData(i) and self.Alert[i] ~= 0 then
                    return self.Alert[i], i, self.AlertLevel[i];
                end
            end
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
