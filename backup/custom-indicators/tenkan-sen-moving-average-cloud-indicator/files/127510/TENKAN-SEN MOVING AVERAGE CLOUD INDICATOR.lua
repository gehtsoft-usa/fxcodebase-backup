-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68703

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
indi_alerts.drawing_layer = 2;
indi_alerts.inverted_arrows = false;

local Cloud_Box;
function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
end

function CreateAverates(method, source, period)
    if method == "MVA" or method == "EMA" or method == "ARSI" 
        or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function Add(id, TF)
    indicator.parameters:addGroup("Timeframe #" .. id)
    indicator.parameters:addString("timeframe" .. id, "Timeframe", "", TF);
    indicator.parameters:setFlag("timeframe" .. id, core.FLAG_PERIODS);
    indicator.parameters:addBoolean("use_ich_" .. id, "Use Ichimoku", "", true);

	
	
    indicator.parameters:addInteger("TenkanSenPeriod" .. id, "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KijunSenPeriod" .. id, "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SenkouSpanPeriod" .. id, "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);
    indicator.parameters:addColor("ich_color" .. id, "Ichimonku Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addBoolean("use_mva_" .. id, "Use MA", "", true);
    indicator.parameters:addInteger("period" .. id, "Period", "", 7, 1, 1000);
    AddAverages("method" .. id, "Method", "MVA");
    indicator.parameters:addColor("mva_color" .. id, "MA Color", "", core.rgb(255, 0, 0));
end

function Init()
    indicator:name("TENKAN-SEN & MOVING AVERAGE CLOUD INDICATOR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addString("reference_tf", "Timeframe for area", "", "D1");
    indicator.parameters:setFlag("reference_tf", core.FLAG_PERIODS);
    Add(1,"m30");
    Add(2,"H1");
    Add(3,"H2");
    Add(4,"H4");
    indicator.parameters:addColor("color", "Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
	indicator.parameters:addBoolean("Cloud_Box", "Use Cloud Box", "", true);
    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Breakout Alert");
end 



-- Sources v1.1
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf, isBid)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids
    if isBid == nil then
        isBid = source:isBid();
    end
	self.items[id] = core.host:execute("getSyncHistory", source:instrument(), tf, isBid, 100, ids.loaded_id, ids.loading_id)
	return self.items[id];
end
function sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
	for index, ids in pairs(self.ids) do
		if ids.loaded_id == cookie then
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
			ids.loaded = false
			self.allLoaded = false
			return false
		end
	end
	return false
end
function sources:IsAllLoaded()
	if self.allLoaded == nil then
		for index, ids in pairs(self.ids) do
			if not ids.loaded then
				self.allLoaded = false
				return false
			end
		end
		self.allLoaded = true
	end
	return self.allLoaded
end

local indicators = {};
local streams_bid = {};
local streams_ask = {};
local tradingWeekOffset;
local tradingDayOffset;
local min, max;

function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	Cloud_Box=instance.parameters.Cloud_Box;
    for id = 1, 4 do
        local source_ask = sources:Request(1, source, instance.parameters:getString("timeframe" .. id), false);
        local source_bid = sources:Request(1, source, instance.parameters:getString("timeframe" .. id), true);
        if instance.parameters:getBoolean("use_ich_" .. id) then
            indicators[#indicators + 1] = core.indicators:create("ICH", source_ask, instance.parameters:getInteger("TenkanSenPeriod" .. id),
                instance.parameters:getInteger("KijunSenPeriod" .. id), instance.parameters:getInteger("SenkouSpanPeriod" .. id))
            local data = {};
            data.stream = indicators[#indicators].TL;
            data.color = instance.parameters:getColor("ich_color" .. id);
            streams_ask[#streams_ask + 1] = data;

            indicators[#indicators + 1] = core.indicators:create("ICH", source_bid, instance.parameters:getInteger("TenkanSenPeriod" .. id),
                instance.parameters:getInteger("KijunSenPeriod" .. id), instance.parameters:getInteger("SenkouSpanPeriod" .. id))
            local data = {};
            data.stream = indicators[#indicators].TL;
            data.color = instance.parameters:getColor("ich_color" .. id);
            streams_bid[#streams_bid + 1] = data;
        end
        if instance.parameters:getBoolean("use_mva_" .. id) then
            indicators[#indicators + 1] = CreateAverates(instance.parameters:getString("method" .. id), source_ask, instance.parameters:getInteger("period" .. id))
            local data = {};
            data.stream = indicators[#indicators].DATA;
            data.color = instance.parameters:getColor("mva_color" .. id);
            streams_ask[#streams_ask + 1] = data;

            indicators[#indicators + 1] = CreateAverates(instance.parameters:getString("method" .. id), source_bid, instance.parameters:getInteger("period" .. id))
            local data = {};
            data.stream = indicators[#indicators].DATA;
            data.color = instance.parameters:getColor("mva_color" .. id);
            streams_bid[#streams_bid + 1] = data;
        end
    end
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    if indi_alerts.drawing_layer >= 100 then
        instance:drawOnMainChart(true);
    else
        instance:ownerDrawn(true);
    end
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    min = instance:addInternalStream(0, 0);
    max = instance:addInternalStream(0, 0);
    instance:ownerDrawn(true);
end

local PEN = 1;
local BRUSH = 2;
local LAST = 3;
local init = false;
local reference_tf;
local transparency;
local FONT = 3;
function Draw(stage, context)
    if stage ~= 2 or not sources:IsAllLoaded() then
        return;
    end
    if not init then
        init = true;
        context:createPen(PEN, context.SOLID, 1, instance.parameters.color);
        context:createSolidBrush(BRUSH, instance.parameters.color);
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(10), 0);
        reference_tf = instance.parameters.reference_tf;
        transparency = context:convertTransparency(instance.parameters.transparency);
        for i, stream in ipairs(streams_bid) do
            stream.line_id = LAST + i;
            context:createPen(stream.line_id, context.SOLID, 1, stream.color);
        end
        LAST = LAST + #streams_bid;
        for i, stream in ipairs(streams_ask) do
            stream.line_id = LAST + i;
            context:createPen(stream.line_id, context.SOLID, 1, stream.color);
        end
        LAST = LAST + #streams_ask;
        indi_alerts.NextId = LAST + 1;
    end
    indi_alerts:Draw(stage, context, source);

    for _, stream in ipairs(streams_bid) do
        if stream.stream:size() == 0 then
            return;
        end
        local val = stream.stream:tick(stream.stream:size() - 1);
        local _, y = context:pointOfPrice(val);
        context:drawLine(stream.line_id, context:left(), y, context:right(), y);

        local w, h = context:measureText(FONT, stream.stream:name(), 0);
        context:drawText(FONT, stream.stream:name(), stream.color, -1, context:left(), y - h, context:left() + w, y, 0);

        local label = win32.formatNumber(val, false, stream.stream:getDisplayPrecision())
        local w, h = context:measureText(FONT, label, 0);
        context:drawText(FONT, label, stream.color, -1, context:right() - w, y - h, context:right(), y, 0);
    end
    for _, stream in ipairs(streams_ask) do
        if stream.stream:size() == 0 then
            return;
        end
        local val = stream.stream:tick(stream.stream:size() - 1);
        local _, y = context:pointOfPrice(val);
        context:drawLine(stream.line_id, context:left(), y, context:right(), y);

        local w, h = context:measureText(FONT, stream.stream:name(), 0);
        context:drawText(FONT, stream.stream:name(), stream.color, -1, context:left(), y - h, context:left() + w, y, 0);

        local label = win32.formatNumber(val, false, stream.stream:getDisplayPrecision())
        local w, h = context:measureText(FONT, label, 0);
        context:drawText(FONT, label, stream.color, -1, context:right() - w, y - h, context:right(), y, 0);
    end

    local s, e = core.getcandle(reference_tf, source:date(source:size() - 1), tradingDayOffset, tradingWeekOffset)
    local x1 = context:positionOfDate(s);
    local x2 = context:positionOfDate(e);
    local _, y1 = context:pointOfPrice(min[source:size() - 1]);
    local _, y2 = context:pointOfPrice(max[source:size() - 1]);
	
	if Cloud_Box then
    context:drawRectangle(PEN, BRUSH, x1, y1, x2, y2, transparency);
	end
end

function Update(period, mode)
    for _, indi in ipairs(indicators) do
        indi:update(mode);
    end
    if not sources:IsAllLoaded() then
        return;
    end
    for _, stream in ipairs(streams_bid) do
        local index = core.findDate(stream.stream, source:date(period), false);
        if (index >= 0 and stream.stream:hasData(index)) then
            local val = stream.stream:tick(index);
            if not min:hasData(period) then
                min[period] = val;
            end
            if min[period] > val then
                min[period] = val;
            end
        end
    end
    for _, stream in ipairs(streams_ask) do
        local index = core.findDate(stream.stream, source:date(period), false);
        if (index >= 0 and stream.stream:hasData(index)) then
            local val = stream.stream:tick(index);
            if not max:hasData(period) then
                max[period] = val;
            end
            if max[period] < val then
                max[period] = val;
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
    if alert.id == 1 and period > 0 then
        if core.crossesOver(source.close, max, period) then
            alert:UpAlert(source, period, alert.Label .. ". Bull pattern", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, min, period) then
            alert:DownAlert(source, period, alert.Label .. ". Bear pattern", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) and sources:IsAllLoaded() then
		instance:updateFrom(0);
    end
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

indi_alerts.Version = "1.10";
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
function indi_alerts:AddAlert(Label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. Label .." Alert" , "", true);

    indicator.parameters:addString("drawing_mode" .. self.last_id, "Drawing mode", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Arrows", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Vertical lines", "", "vlines");

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

indi_alerts.init = false;

function indi_alerts:DrawAlert(context, alert, period)
    if not alert.Alert:hasData(period) then
        return;
    end

    if alert.Alert[period] == 1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self.FONT_ID, alert.UpSymbol, 0);
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
			context:drawText(self.FONT_ID, alert.UpSymbol, alert.UpColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.UpLinePen, x, context:top(), x, context:bottom());
        end
	elseif alert.Alert[period] == -1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self.FONT_ID, alert.DownSymbol, 0);
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
            context:drawText(self.FONT_ID, alert.DownSymbol, alert.DownColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.DownLinePen, x, context:top(), x, context:bottom());
        end
    end
end
indi_alerts.NextId = 1;
function indi_alerts:Draw(stage, context)
    if stage ~= indi_alerts.drawing_layer then
        return;
    end
    if not self.init then
        local createFont = false;
        for _, level in ipairs(self.Alerts) do
            if level.DrawingMode == "vlines" then
                level.UpLinePen = self.NextId;
                self.NextId = self.NextId + 1;
                level.DownLinePen = self.NextId;
                self.NextId = self.NextId + 1;
                context:createPen(level.UpLinePen, context.SOLID, 1, level.UpColor);
                context:createPen(level.DownLinePen, context.SOLID, 1, level.DownColor);
            else
                createFont = true;
            end
        end
        if createFont and self.FONT_ID == nil then
            self.FONT_ID = self.NextId;
			self.NextId = self.NextId + 1;
            context:createFont(self.FONT_ID, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0);
        end
        self.init = true;
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size()-1), 1 do
        for _, level in ipairs(self.Alerts) do
            self:DrawAlert(context, level, period);
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
