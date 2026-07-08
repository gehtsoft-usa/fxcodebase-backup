-- Id: 9218
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=280

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

local indi_alerts = {};

function Init()
    indicator:name("Keltner with Alert")
    indicator:description("v1 2018-11-03")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addString("Price", "Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

    indicator.parameters:addInteger("NM", "Number of the periods to smooth the center line", "", 50)
    indicator.parameters:addInteger("NB", "Number of periods to smooth deviation", "", 50)
    indicator.parameters:addDouble("F", "Factor which is used to apply the deviation", "", 1)

    -- source smoothing method
    indicator.parameters:addBoolean("SC", "Show the center line", "", true)
    indicator.parameters:addString("MS", "The center line smoothing method", "", "MVA")
    indicator.parameters:addStringAlternative("MS", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("MS", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("MS", "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("MS", "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative("MS", "Wilders", "", "WMA")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addString("MV", "Variation Method", "", "AHL")
    indicator.parameters:addStringAlternative("MV", "Smoothed H-L", "", "AHL")
    indicator.parameters:addStringAlternative("MV", "ATR of source", "", "ATR")
    indicator.parameters:addGroup("Upper Band Style")
    indicator.parameters:addColor("H_color", "Color of Upper Band Line", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("H_width", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("H_style", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("H_style", core.FLAG_LINE_STYLE)
    indicator.parameters:addGroup("Middle Band Style")
    indicator.parameters:addColor("M_color", "Color of Middle Band Line", "", core.rgb(0, 255, 255))
    indicator.parameters:addInteger("M_width", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("M_style", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("M_style", core.FLAG_LINE_STYLE)
    indicator.parameters:addGroup("Lower Band Style")
    indicator.parameters:addColor("L_color", "Color of Lower Band Line", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("L_width", "Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("L_style", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE)

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Price / Top Line");
    indi_alerts:AddAlert("Price / Central Line");
    indi_alerts:AddAlert("Price / Bottom Line");
end

-- Parameters block
local NM
local NB
local MS
local MV
local SRC
local F
local SC
local Price
local first
local source = nil

-- Streams block
local H = nil
local M = nil
local L = nil

local AS  -- alternative source
local MI  -- middle line smoothed

local VM1  -- the source stream for H-L variation method
local VMI  -- the indicator for smoothing H-L variation method
local ATR  -- ATR indicator for smoothing method

local FIRST = true

-- Routine
function Prepare(nameOnly)
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);

    SC = instance.parameters.SC
    NM = instance.parameters.NM
    NB = instance.parameters.NB
    Price = instance.parameters.Price

    FIRST = true

    F = instance.parameters.F
    MV = instance.parameters.MV
    MS = instance.parameters.MS
    source = instance.source

    local name = profile:id() .. "(" .. source:name() .. ", "

    -- create an indicator to calculate the middle line
    name = name .. MS .. "(" .. NM .. "), "
    if not nameOnly then
    assert(core.indicators:findIndicator(MS) ~= nil, MS .. " indicator must be installed");
        MI = core.indicators:create(MS, source[Price], NM)
        first = MI.DATA:first()
    end

    if MV == "AHL" then
        name = name .. MS .. "(H-L, " .. NB .. "), "
        if not nameOnly then
            VM1 = instance:addInternalStream(source:first(), 0)
            VMI = core.indicators:create(MS, VM1, NB)
            if VMI.DATA:first() > first then
                first = MI.DATA:first()
            end
        end
    elseif MV == "ATR" then
        name = name .. "ATR(" .. NB .. "), "
        if not nameOnly then
            ATR = core.indicators:create("ATR", source, NB)
            if ATR.DATA:first() > first then
                first = ATR.DATA:first()
            end
        end
    else
        assert(false, "The variation method is unknown")
    end
    name = name .. F .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end

    H = instance:addStream("H", core.Line, name .. ".H", "H", instance.parameters.H_color, first)
    H:setWidth(instance.parameters.H_width)
    H:setStyle(instance.parameters.H_style)
    if SC then
        M = instance:addStream("M", core.Line, name .. ".M", "M", instance.parameters.M_color, first)
        M:setWidth(instance.parameters.M_width)
        M:setStyle(instance.parameters.M_style)
    else
        M = instance:addInternalStream(first, 0)
    end
    L = instance:addStream("L", core.Line, name .. ".L", "L", instance.parameters.L_color, first)
    L:setWidth(instance.parameters.L_width)
    L:setStyle(instance.parameters.L_style)
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    if (period <= 0) then
        return;
    end
    alert.Alert[period] = 0;
    if alert.id == 1 and alert.ON then
        if core.crossesOver(source.close, H, period) then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, H, period) then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period);
        end
    end
    if alert.id == 2 and alert.ON then
        if core.crossesOver(source.close, M, period) then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, M, period) then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period);
        end
    end
    if alert.id == 3 and alert.ON then
        if core.crossesOver(source.close, L, period) then
            alert:UpAlert(source, period, alert.Label .. ". Cross Over", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, L, period) then
            alert:DownAlert(source, period, alert.Label .. ". Cross Under", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function Update(period, mode)
    Calculation(period, mode)

    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function Calculation(period, mode)
    if period < source:first() then
        return
    end

    -- update the source smoothing indicator
    MI:update(mode)

    if MV == "AHL" then
        VM1[period] = source.high[period] - source.low[period]
        VMI:update(mode)
    elseif MV == "ATR" then
        ATR:update(mode)
    end

    if period < first then
        return
    end
    local v
    M[period] = MI.DATA[period]
    if MV == "AHL" then
        VM1[period] = source.high[period] - source.low[period]
        v = VMI.DATA[period]
    elseif MV == "ATR" then
        v = ATR.DATA[period]
    end
    H[period] = M[period] + v * F
    L[period] = M[period] - v * F
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

indi_alerts.Version = "1.5";
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts.total_alerts = 3;
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
