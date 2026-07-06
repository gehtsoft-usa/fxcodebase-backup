-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65729

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

-- Indicator profile initialization routine
local indi_alerts = {};

function Init()
    indicator:name("Volume Price Change")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("length", "Period", "", 15, 2, 2000)
    indicator.parameters:addInteger("price_smoothing", "Price Smoothing", "", 15)
    indicator.parameters:addInteger("signal_smoothing", "Signal Smoothing", "", 15)
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color1", "Line Color Down", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("color2", "Line Color Up", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5)

    indicator.parameters:addColor("color3", "Signal Line Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5)

    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Line/Zero");
    indi_alerts:AddAlert("Line/Signal");
    indi_alerts:AddAlert("Line/Oversold");
    indi_alerts:AddAlert("Line/Overbought");
    indi_alerts:AddAlert("Divergence");
end

local length, price_smoothing, signal_smoothing
local first
local source = nil
local MVA, EMA1, EMA2, EMA3
local vpc, signal
local DN_color, UP_color, UP, DN, V;

function Prepare(nameOnly)
    length = instance.parameters.length
    price_smoothing = instance.parameters.price_smoothing
    signal_smoothing = instance.parameters.signal_smoothing

    local name = profile:id() .. "(" .. instance.source:name() .. ", " .. length .. ", " .. signal_smoothing .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    UP = instance:createTextOutput("UpD", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
    DN = instance:createTextOutput("DnD", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);

    source = instance.source

    if price_smoothing > 1 then
        EMA1 = core.indicators:create("EMA", source.close, price_smoothing)
        EMA2 = core.indicators:create("EMA", source.volume, price_smoothing)

        MVA = core.indicators:create("MVA", EMA2.DATA, length)
        first = MVA.DATA:first()
    else
        MVA = core.indicators:create("MVA", source.volume, length)
        first = MVA.DATA:first()
    end

    vpc = instance:addStream("vpc", core.Line, "vpc", "vpc", instance.parameters.color1, first)
    vpc:setWidth(instance.parameters.width1)
    vpc:setStyle(instance.parameters.style1)
    V = vpc;

    vpc:addLevel(0)
    vpc:setPrecision(math.max(2, source:getPrecision()))

    EMA3 = core.indicators:create("EMA", vpc, signal_smoothing)
    signal = instance:addStream("signal", core.Line, "signal", "signal", instance.parameters.color3, first)
    signal:setWidth(instance.parameters.width2)
    signal:setStyle(instance.parameters.style2)
    signal:setPrecision(math.max(2, source:getPrecision()))
end

local pperiod = nil;
local pperiod1 = nil;
local lines = {};

local init = false;
local init1 = false;
local init2 = false;
local UP_PEN = 42;
local DN_PEN = 43;
function Draw(stage, context) 
    indi_alerts:Draw(stage, context, source);
    if stage == 102 then
        if not init1 then
            context:createPen(UP_PEN, context.SOLID, 1, instance.parameters.UP_color);
            context:createPen(DN_PEN, context.SOLID, 1, instance.parameters.DN_color);
            init1 = true;
        end
        for _, line in ipairs(lines) do
            local x1 = context:positionOfDate(line.Date1);
            local x2 = context:positionOfDate(line.Date2);
            local visible, y1 = context:pointOfPrice(line.Price1);
            local visible, y2 = context:pointOfPrice(line.Price2);
            context:drawLine(line.IsDown and DN_PEN or UP_PEN, x1, y1, x2, y2);
        end
    elseif stage == 2 then
        if not init2 then
            context:createPen(UP_PEN, context.SOLID, 1, instance.parameters.UP_color);
            context:createPen(DN_PEN, context.SOLID, 1, instance.parameters.DN_color);
            init2 = true;
        end
        for _, line in ipairs(lines) do
            local x1 = context:positionOfDate(line.Date1);
            local x2 = context:positionOfDate(line.Date2);
            local visible, y1 = context:pointOfPrice(line.IndiVal1);
            local visible, y2 = context:pointOfPrice(line.IndiVal2);
            context:drawLine(line.IsDown and DN_PEN or UP_PEN, x1, y1, x2, y2);
        end
    end
end

-- Indicator calculation routine
function Update(period, mode)
    if price_smoothing > 1 then
        EMA1:update(mode)
        EMA2:update(mode)
        MVA:update(mode)

        if period < MVA.DATA:first() then
            return
        end

        vpc[period] = (EMA1.DATA[period] - EMA1.DATA[period - length + 1]) * MVA.DATA[period]
    else
        MVA:update(mode)

        if period < MVA.DATA:first() then
            return
        end

        vpc[period] = (source.close[period] - source.close[period - length + 1]) * MVA.DATA[period]
    end

    EMA3:update(mode)

    if period < EMA3.DATA:first() then
        return
    end

    signal[period] = EMA3.DATA[period]

    if vpc[period] > signal[period] then
        vpc:setColor(period, instance.parameters.color1)
    else
        vpc:setColor(period, instance.parameters.color2)
    end

    if pperiod ~= nil and pperiod > period or period <= first then
        lines = {};
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    
    period = period - 1;
    pperiod1 = source:serial(period);

    if period >= first then
        if period >= first + 2 then
            processBullish(period - 2);
            processBearish(period - 2);
        end
    end

    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function processBullish(period)
    if isTrough(period) then
        local curr, prev;
        curr = period;
        prev = prevTrough(period);
        if prev ~= nil then
            if V[curr] > V[prev] and source.low[curr] < source.low[prev] then
                DN:set(curr, V[curr], "\225", "Classic bullish");
                local line = {};
                line.Date1 = source:date(prev);
                line.Date2 = source:date(curr);
                line.IndiVal1 = V[prev];
                line.IndiVal2 = V[curr];
                line.Price1 = source.low[prev];
                line.Price2 = source.low[curr]
                line.IsDown = true;
                lines[#lines + 1] = line;
            elseif V[curr] < V[prev] and source.low[curr] > source.low[prev] then
                DN:set(curr, V[curr], "\225", "Reversal bullish");
                local line = {};
                line.Date1 = source:date(prev);
                line.Date2 = source:date(curr);
                line.IndiVal1 = V[prev];
                line.IndiVal2 = V[curr];
                line.Price1 = source.low[prev];
                line.Price2 = source.low[curr]
                line.IsDown = true;
                lines[#lines + 1] = line;
            end
        end
    end
end

function isTrough(period)
    local i;
    if V[period] < V[period - 1] and V[period] < V[period + 1] then
        for i = period - 1, first, -1 do
            if V[i] > V[period] then
                return true;
            elseif V[period] > V[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if V[i] <= V[i - 1] and V[i] < V[i - 2] and
           V[i] <= V[i + 1] and V[i] < V[i + 2] then
           return i;
        end
    end
    return nil;
end

function processBearish(period)
    if isPeak(period) then
        local curr, prev;
        curr = period;
        prev = prevPeak(period);
        if prev ~= nil then
            if V[curr] < V[prev] and source.high[curr] > source.high[prev] then
                UP:set(curr, V[curr], "\226", "Classic bearish");
                local line = {};
                line.Date1 = source:date(prev);
                line.Date2 = source:date(curr);
                line.IndiVal1 = V[prev];
                line.IndiVal2 = V[curr];
                line.Price1 = source.high[prev];
                line.Price2 = source.high[curr];
                line.IsDown = false;
                lines[#lines + 1] = line;
            elseif V[curr] > V[prev] and source.high[curr] < source.high[prev] then
                UP:set(curr, V[curr], "\226", "Reversal bearish");
                local line = {};
                line.Date1 = source:date(prev);
                line.Date2 = source:date(curr);
                line.IndiVal1 = V[prev];
                line.IndiVal2 = V[curr];
                line.Price1 = source.high[prev];
                line.Price2 = source.high[curr];
                line.IsDown = false;
                lines[#lines + 1] = line;
            end
        end
    end
end

function isPeak(period)
    local i;
    if V[period] > V[period - 1] and V[period] > V[period + 1] then
        for i = period - 1, first, -1 do
            if V[i] < V[period] then
                return true;
            elseif V[period] < V[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if V[i] >= V[i - 1] and V[i] > V[i - 2] and
           V[i] >= V[i + 1] and V[i] > V[i + 2] then
           return i;
        end
    end
    return nil;
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if alert.id == 1 then
        if vpc[period] > 0 and vpc[period - 1] <= 0 then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period);
        elseif vpc[period] < 0 and vpc[period - 1] >= 0 then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period);
        end
    end
    if alert.id == 2 then
        if vpc[period] > signal[period] and vpc[period - 1] <= signal[period - 1] then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period);
        elseif vpc[period] < signal[period] and vpc[period - 1] >= signal[period - 1] then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period);
        end
    end
    if alert.id == 3 then
        if core.crossesOver(signal, instance.parameters.oversold, period) then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period);
        elseif core.crossesUnder(signal, instance.parameters.oversold, period) then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period);
        end
    end
    if alert.id == 4 then
        if core.crossesOver(signal, instance.parameters.overbought, period) then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period);
        elseif core.crossesUnder(signal, instance.parameters.overbought, period) then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period);
        end
    end
    if alert.id == 5 then
        if period > 2 and UP:hasData(period - 2) then
            alert:UpAlert(source, period, alert.Label .. ". Bull divergence", source.high[period], historical_period);
        elseif period > 2 and DN:hasData(period - 2) then
            alert:DownAlert(source, period, alert.Label .. ". Bear divergence", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

indi_alerts.Version = "1.5";
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts.total_alerts = 4;
indi_alerts._alerts = {};
indi_alerts._advanced_alert_timer = nil;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Alert Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
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
    indicator.parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram or Telegram Channel", false);
    indicator.parameters:addString("telegram_key", "Advanced Alert Key", "Start converstation with @profit_robots_bot Telegram Bot to get the key", "");
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
function indi_alerts:AddAlert(Label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. Label .." Alert" , "", true);

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Up Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Up Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addFile("Down" .. self.last_id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("DownSymbol" .. self.last_id, "Down Symbol", "", 218);
    indicator.parameters:addColor("DownColor" .. self.last_id, "Down Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addString("Label" .. self.last_id, "Label", "", Label);
end

indi_alerts.init = false;
function indi_alerts:Draw(stage, context)
    if stage ~= 102 then
        return;
    end
    if not self.init then
        context:createFont(1, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0);
        self.init = true;
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size()-1), 1 do
        x, x1, x2= context:positionOfBar(period);
        for _, level in ipairs(self.Alerts) do
            if level.Alert:hasData(period) then
                if level.Alert[period] == 1 then
                    visible, y = context:pointOfPrice(level.AlertLevel[period]);
                    width, height = context:measureText(1, level.UpSymbol, 0);
                    context:drawText(1, level.UpSymbol, level.UpColor, -1, x - width / 2, y - height, x+width / 2, y, 0);
                elseif level.Alert[period] == -1 then
                    visible, y = context:pointOfPrice(level.AlertLevel[period]);
                    width, height = context:measureText(1, level.DownSymbol, 0);
                    context:drawText(1, level.DownSymbol, level.DownColor, -1, x - width / 2, y, x + width/2, y + height, 0);
                end
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
    
    self.UpTrendColor = instance.parameters.UpTrendColor;
    self.DownTrendColor = instance.parameters.DownTrendColor;
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    local i;
    for i = 1, self.total_alerts, 1 do 
        local alert = {};
        alert.id = i;
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = instance.parameters:getBoolean("ON" .. i);
        alert.UpSymbol = string.char(instance.parameters:getInteger("UpSymbol" .. i));
        alert.DownSymbol = string.char(instance.parameters:getInteger("DownSymbol" .. i));
        alert.UpColor = instance.parameters:getColor("UpColor" .. i);
        alert.DownColor = instance.parameters:getColor("DownColor" .. i);
        alert.Up = self.PlaySound and instance.parameters:getString("Up" .. i) or nil;
        alert.Down = self.PlaySound and instance.parameters:getString("Down" .. i) or nil;
        assert(not(self.PlaySound) or (self.PlaySound and alert.Up ~= "") or (self.PlaySound and alert.Up ~= ""), "Sound file must be chosen"); 
        assert(not(self.PlaySound) or (self.PlaySound and alert.Down ~= "") or (self.PlaySound and alert.Down ~= ""), "Sound file must be chosen");
        alert.U = nil;
        alert.D = nil;
        alert.Alert = instance:addInternalStream(0, 0);
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
                self.U=source:serial(period);
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

