-- Id: 20594
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65751

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local indi_alerts = {};
indi_alerts.Version = "1.0";
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts._alerts = {};
indi_alerts._telegram_timer = nil;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    
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

    indicator.parameters:addGroup("Alerts Telegram");
    indicator.parameters:addString("telegram_key", "Telegram Key", "Used for @profit_robots_bot", "");
end

function indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2) if cookie == self._telegram_timer and #self._alerts > 0 then if self._telegram_key == nil then return; end local data = self:ArrayToJSON(self._alerts); self._alerts = {}; local req = http_lua.createRequest(); local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}', self._telegram_key, string.gsub(self.StrategyName or "", '"', '\\"'), data); req:setRequestHeader("Content-Type", "application/json"); req:setRequestHeader("Content-Length", tostring(string.len(query))); req:start("http://profitrobots.com/api/v1/notification", "POST", query); end end
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
    
    indicator.parameters:addFile("Down" .. self.last_id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    
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
                if level.Alert[period]== 1 then
                    visible, y = context:pointOfPrice (level.AlertLevel[period]);
                    width, height = context:measureText (1,  "\225", 0);
                    context:drawText (1,   "\225", self.UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );    
                elseif level.Alert[period]== -1 then
                    visible, y = context:pointOfPrice (level.AlertLevel[period]);
                    width, height = context:measureText (1,  "\226", 0);
                    context:drawText (1,   "\226", self.DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );    
                end
            end
        end
    end
end
indi_alerts.Alerts = {};
function indi_alerts:Prepare()
    self.Show = instance.parameters.Show;
    self.Live = instance.parameters.Live;
    self.ShowAlert = instance.parameters.ShowAlert;
    
    self.UpTrendColor = instance.parameters.UpTrendColor;
    self.DownTrendColor = instance.parameters.DownTrendColor;
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    local i;
    for i = 1, 2, 1 do 
        local alert = {};
        alert.id = 1;
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = instance.parameters:getBoolean("ON" .. i);
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

    if instance.parameters.telegram_key ~= "" then
        self._telegram_key = instance.parameters.telegram_key;
        require("http_lua");
        self._telegram_timer = 1234;
        core.host:execute("setTimer", self._telegram_timer, 1);
    end
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, " ( " .. self.source:instrument() .. label .. " : " .. note);
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

    local date = self.source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";  
    local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;   
    local Symbol = "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local text = Note  .. delim ..  Symbol .. delim .. Time;
    terminal:alertEmail(self.Email, profile:id(), text);
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return;
    end
    
    local date = self.source:date(period);
    local DATA = core.dateToTable (date);
    local delim = "\013\010";  
    local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;
    local Symbol= "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
    local TF= "Time Frame : " .. self.source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW));
end

function indi_alerts:AlertTelegram(message, instrument, timeframe) local alert = {}; alert.Text = message or ""; alert.Instrument = instrument or ""; alert.TimeFrame = timeframe or ""; self._alerts[#self._alerts + 1] = alert; end


function Init()
    indicator:name("Finding the Check mark pattern");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("The base indicator parameters");
    indicator.parameters:addString("i_indicatorType", "Base indicator", "", "STOCHASTIC");
    indicator.parameters:setFlag("i_indicatorType",core.FLAG_INDICATOR);
    indicator.parameters:addInteger("i_customBuffer", "Index of data buffer", "", 0);

    indicator.parameters:addColor("i_bullsPatternColor", "Color of bulls pattern", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("i_bearsPatternColor", "Color of bears divergence line", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color", "Color", "", core.rgb(128, 128, 255));
    indicator.parameters:addInteger("widthCCI", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);
    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Check Mark Detected");
end

local g_indValues;
local indi;

function Prepare(onlyName)
    source = instance.source;
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    local profile1 = core.indicators:findIndicator(instance.parameters:getString("i_indicatorType"));
    local params1 = instance.parameters:getCustomParameters("i_indicatorType");
    indi = profile1:createInstance(source, params1);
    local name = profile:id() .. "(" .. source:name() .. "," .. indi:name() .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    first = indi.DATA:first();
    g_indValues = instance:addStream("out", core.Line, name, "out", instance.parameters.color, first);
    g_indValues:setPrecision(math.max(2, instance.source:getPrecision()));
    g_indValues:setWidth(instance.parameters.widthCCI);
    g_indValues:setStyle(instance.parameters.styleCCI);
    instance:drawOnMainChart(true);
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

function Activate(alert, period, historical_period, indExtremum)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if alert.id == 1 and alert.ON then
        if (indExtremum == -1) then
            alert:UpAlert(source, period, alert.Label .. ". Bull pattern", source.high[period], historical_period);
        elseif (indExtremum == 1) then
            alert:DownAlert(source, period, alert.Label .. ". Bear pattern", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function AsyncOperationFinished(cookie)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

function Update(period, mode)
    indi:update(mode);
    g_indValues[period] = indi:getStream(instance.parameters.i_customBuffer):tick(period);
    local indExtremum = GetIndicatorExtremum(period);
    if (indExtremum == 0) then
        return;
    end
    local marketExtremum = GetMarketExtremum(period);
    if (marketExtremum == 0 or marketExtremum == indExtremum) then
        return;
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, mode ~= core.UpdateLast, indExtremum); end
end

function GetIndicatorExtremum(period)
    if (period < 2) then
        return 0;
    end
    if (g_indValues[period] > g_indValues[period - 1] and g_indValues[period - 1] < g_indValues[period - 2]) then
        return -1;
    end
    if (g_indValues[period] < g_indValues[period - 1] and g_indValues[period - 1] > g_indValues[period - 2]) then
        return 1;
    end
    return 0;
end

function GetMarketExtremum(period)
    if (period < 2) then
        return 0;
    end
    local closeRight = source.close[period];
    local closeCenter = source.close[period - 1];
    local closeLeft = source.close[period - 2];
    if (closeRight > closeCenter and closeCenter < closeLeft) then
        return -1;
    end
    if (closeRight < closeCenter and closeCenter > closeLeft) then
        return 1;
    end
    return 0;
end

