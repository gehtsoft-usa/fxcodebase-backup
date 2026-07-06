-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=966
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

local indi_alerts = {};
indi_alerts.Version = "1.13";
indi_alerts.inverted_arrows = false;
local H, L;         -- high/low lines
local PH, PL;       -- period band borders
local BH, BL;       -- box band borders
local source;
local alerts = 
{ 
    {
        Stage = 2,
        UpCondition = function (period)
            if period < 1 then
                return false;
            end
            return core.crossesOver(source.close, H, period);
        end,
        DownCondition = function (period)
            if period < 1 then
                return false;
            end
            return core.crossesUnder(source.close, L, period);
        end,
        OnChange = true,
        Name = "Breakout"
    }
};

function Init()
    indicator:name("Breakout Highlight");
    indicator:description("The indicator detects and highlight periods and boxes for the breakout strategy");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("PeriodBegin", "The hour and minute when the period begins", "", "00:00");
    indicator.parameters:addString("PeriodEnd", "The hour and minute when the period ends", "", "05:30");
    indicator.parameters:addString("BoxEnd", "The hour and minute when the box ends", "", "23:00");
    indicator.parameters:addString("Type", "The time type", "", "TD");
    indicator.parameters:addStringAlternative("Type", "Local Time", "", "LT");
    indicator.parameters:addStringAlternative("Type", "EST Time", "", "EST");
    indicator.parameters:addStringAlternative("Type", "GMT Time", "", "GMT");
    indicator.parameters:addStringAlternative("Type", "Trading Day time", "", "TD");
    indicator.parameters:addString("time_period", "Time period", "", "D");
    indicator.parameters:addStringAlternative("time_period", "Daily", "", "D");
    indicator.parameters:addStringAlternative("time_period", "Weekly (Monday)", "", "W");
    indicator.parameters:addStringAlternative("time_period", "Monthly", "", "M");
    indicator.parameters:addBoolean("MSMode", "Marketscope mode", "Leave true for this parameter!", true);
    indicator.parameters:addColor("HighLowColor", "The High/Low Lines color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("PeriodColor", "The period highlight color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("PeriodTran", "The period highlight transparency", "", 90, 0, 100);
    indicator.parameters:addColor("BoxColor", "The box highlight color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("BoxTran", "The box transparency", "", 90, 0, 100);
    indicator.parameters:addColor("labels_color", "Labels color", "", core.rgb(128, 128, 128));
    
    indi_alerts:AddParameters(indicator.parameters);
    for i,alert in ipairs(alerts) do
        indi_alerts:AddAlert(alert.Name);
    end
end

local first;
local MSMode;
local PeriodBegin, PeriodEnd, BoxEnd;
local Type = 0;
local time_period;
local T_LT = 1;
local T_EST = 2;
local T_GMT = 3;
local T_TD = 4;
local day_offset;
local week_offset;
local host;
local P = nil;

function Prepare(nameOnly)
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);

    source = instance.source;
    first = source:first();

    MSMode = instance.parameters.MSMode;
    time_period = instance.parameters.time_period;

    host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0);
    assert ((e - s) <= (1.0 / 24), "The time frame must be 1 hour or less");

    PeriodBegin = ParseTime(instance.parameters.PeriodBegin);
    PeriodEnd = ParseTime(instance.parameters.PeriodEnd);
    BoxEnd = ParseTime(instance.parameters.BoxEnd);

    if (PeriodBegin > BoxEnd) then
        PeriodBegin = PeriodBegin - 86400;
    end
    
    if (PeriodEnd > BoxEnd) then
        PeriodEnd = PeriodEnd - 86400;
    end;
    
    assert(PeriodBegin < PeriodEnd, "Period begin must be before the period end");
    assert(PeriodEnd < BoxEnd, "The period end must be before the period end");

    if instance.parameters.Type == "LT" then
        Type = T_LT;
    elseif instance.parameters.Type == "EST" then
        Type = T_EST;
    elseif instance.parameters.Type == "GMT" then
        Type = T_GMT;
    elseif instance.parameters.Type == "TD" then
        Type = T_TD;
    end

    assert(Type ~= 0, "The type is unknown");

    local name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.PeriodBegin .. "," .. instance.parameters.PeriodEnd .. "," .. instance.parameters.BoxEnd .. "," .. instance.parameters.Type .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    if MSMode then
        PH = instance:addStream("PH", core.Line, name .. "." .. "PH", "PH", instance.parameters.PeriodColor, first);
        PL = instance:addStream("PL", core.Line, name .. "." .. "PL", "PL", instance.parameters.PeriodColor, first);
        instance:createChannelGroup("P", "P", PH, PL, instance.parameters.PeriodColor, 100 - instance.parameters.PeriodTran);
        BH = instance:addStream("BH", core.Line, name .. "." .. "BH", "BH", instance.parameters.BoxColor, first);
        BL = instance:addStream("BL", core.Line, name .. "." .. "BL", "BL", instance.parameters.BoxColor, first);
        instance:createChannelGroup("B", "P", BH, BL, instance.parameters.BoxColor, 100 - instance.parameters.BoxTran);
        P = instance:addInternalStream(0, 0);
    else
        PH = instance:addInternalStream(0, 0);
        PL = instance:addInternalStream(0, 0);
        BH = instance:addInternalStream(0, 0);
        BL = instance:addInternalStream(0, 0);
        P = instance:addStream("P", core.Line, name .. "." .. "P", "P", instance.parameters.HighLowColor, first);
    end
    H = instance:addStream("H", core.Line, name .. "." .. "H", "H", instance.parameters.HighLowColor, first);
    L = instance:addStream("L", core.Line, name .. "." .. "L", "L", instance.parameters.HighLowColor, first);
end

local init = false;
local labels_color;
function Draw(stage, context)
    indi_alerts:Draw(stage, context, source); 
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(1, "Arial", 0, context:pointsToPixels(12), 0);
        labels_color = instance.parameters.labels_color;
        init = true;
    end

    for period = math.max(context:firstBar(), source:first() + 1), math.min(context:lastBar(), source:size() - 1), 1 do
        if not H:hasData(period) and H:hasData(period - 1) then
            x, x1, x2 = context:positionOfBar(period);
            visible, y = context:pointOfPrice(H[period - 1]);
            local range = string.format("%.1f", (H[period - 1] - L[period - 1]) / source:pipSize());
            width, height = context:measureText(1, tostring(range), 0);
            context:drawText(1, tostring(range), labels_color, -1, x - width, y - height, x, y, 0);
        end
    end
end

local ptime = "(%d%d?):(%d%d?)";

function ParseTime(time)
    local a, b;
    a, b = string.match(time, ptime);
    a = tonumber(a);
    b = tonumber(b);
    assert(a ~= nil, "Can't recognize the time:" .. time);
    assert (a >= 0 and a <= 23, "Hour must be between 0 and 23");
    assert (b >= 0 and b <= 59, "Minute must be between 0 and 59");
    return b * 60 + a * 60 * 60;    -- return number of second past...
end

local BE_NONE = 0;      -- belongs to period
local BE_PERIOD = 1;    -- belongs to period
local BE_BOX = 2;       -- belongs to box

function BelongsTo(time)
    if time_period == "W" then
        local s, e = core.getcandle("W1", time, day_offset, week_offset);
        local ds, de = core.getcandle("D1", s, day_offset, week_offset);
        core.host:trace("%s %s %s", core.formatDate(time), core.formatDate(ds), core.formatDate(de));
        if time > de + 1 or time < ds + 1 then
            return BE_NONE;
        end
    elseif time_period == "M" then
        local s, e = core.getcandle("M1", time, day_offset, week_offset);
        local ds, de = core.getcandle("D1", s, day_offset, week_offset);
        if time > de or time < ds then
            return BE_NONE;
        end
    end
    -- calculate the number of seconds since...
    local t;
    if Type == T_TD then
        -- tranding day
        t = core.getcandle("D1", time, day_offset);
        t = math.floor((time - t) * 86400 + 0.5);
    elseif Type == T_EST then
        t = time - math.floor(time);    -- get only time
        t = math.floor(t * 86400 + 0.5);
    elseif Type == T_GMT then
        t = host:execute("convertTime", 1, 2, time);   -- EST->GMT
        t = t - math.floor(t);    -- get only time
        t = math.floor(t * 86400 + 0.5);
    elseif Type == T_LT then
        t = host:execute("convertTime", 1, 3, time);   -- EST->Local
        t = t - math.floor(t);    -- get only time
        t = math.floor(t * 86400 + 0.5);
    end

    if (PeriodBegin < 0 and t >= BoxEnd) then
        t = t - 86400;
    end
    
    if t >= PeriodBegin and t < PeriodEnd then
        return BE_PERIOD;
    elseif t >= PeriodEnd and t < BoxEnd then
        return BE_BOX;
    else
        return BE_NONE;
    end
end

function Update(period, mode)
    if period >= first then
        local curr, prior, i;
        if P:hasData(period - 1) then
            prior = P[period - 1];
        else
            prior = BE_NONE;
        end

        curr = BelongsTo(source:date(period));
        P[period] = curr;

        if curr == BE_NONE then
            return ;
        elseif curr == BE_BOX then
            if H:hasData(period - 1) then
                H[period] = H[period - 1];
                L[period] = L[period - 1];
                BH[period] = H[period - 1];
                BL[period] = L[period - 1];
            end
        elseif curr == BE_PERIOD then
            if prior ~= BE_PERIOD then
                P:setBookmark(1, period);
            end
            local p, h, l;
            p = P:getBookmark(1)
            l, h = core.minmax(source, core.range(p, period));
            if H:hasData(period - 1) and
               H[period - 1] == h and
               L:hasData(period - 1) and
               L[period - 1] == l then
                H[period] = h;
                L[period] = l;
                PH[period] = h;
                PL[period] = l;
            else
                for i = p, period, 1 do
                    H[i] = h;
                    L[i] = l;
                    PH[i] = h;
                    PL[i] = l;
                end
            end
        end
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if alert.UpCondition(period) and (not alert.OnChange or not alert.UpCondition(period - 1)) then
        alert:UpAlert(source, period, alert.Label .. ". Bull pattern", source.high[period], historical_period);
    elseif alert.DownCondition(period) and (not alert.OnChange or not alert.DownCondition(period - 1)) then
        alert:DownAlert(source, period, alert.Label .. ". Bear pattern", source.low[period], historical_period);
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
    local i;
    for i = 1, 100 do 
        local on = instance.parameters:getBoolean("ON" .. i);
        if on == nil then
            break;
        end 
        local alert = {};
        alert.id = i;
        alert.UpCondition = alerts[i].UpCondition;
        alert.DownCondition = alerts[i].DownCondition;
        alert.OnChange = alerts[i].OnChange;
        alert.Stage = alerts[i].Stage;
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
