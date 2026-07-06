-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=27184&start=10

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

local open;
local indi_alerts = {};
indi_alerts.Version = "2.1";
indi_alerts.inverted_arrows = false;
local alerts = 
{ 
    {
        Stage = 102,
		UpCondition = function (period)
			return open:colorI(period) == instance.parameters.Up
				and open:colorI(period - 1) == instance.parameters.No
        end,
		DownCondition = function (period)
			return open:colorI(period) == instance.parameters.Dn
				and open:colorI(period - 1) == instance.parameters.No
        end,
        FormatMessage = function(source, period, level, label, isUp)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source.close[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        OnChange = true,
        Name = "Alert Name"
    }
};

function Init()
	indicator:name("Consensus of Five")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("One", "Use DMI Filter", "", true)
	indicator.parameters:addBoolean("Two", "Use ADX Filter", "", true)
	indicator.parameters:addBoolean("Three", "Use CCI Filter", "", true)
	indicator.parameters:addBoolean("Four", "Use MACD Filter", "", true)
	indicator.parameters:addBoolean("Five", "Use Stochastic Filter", "", true)

	indicator.parameters:addGroup("DMI Calculation")
	indicator.parameters:addInteger("DMI", "Period", "", 14)

	indicator.parameters:addGroup("ADX Calculation")
	indicator.parameters:addInteger("ADX", "Period", "", 14)
	indicator.parameters:addDouble("ADX_Entry", "Entry Level", "", 20)
	indicator.parameters:addDouble("ADX_Exit", "Exit Level", "", 40)

	indicator.parameters:addGroup("CCI Calculation")
	indicator.parameters:addInteger("CCI", "Period", "", 14)
	indicator.parameters:addDouble("CCI_Buy", "Buy Level", "", 0)
	indicator.parameters:addDouble("CCI_Sell", "Sell Level", "", 0)

	indicator.parameters:addGroup("MACD Calculation")
	indicator.parameters:addInteger("MACD_Short", "Short Period", "", 12)
	indicator.parameters:addInteger("MACD_Long", "Long Period", "", 26)
	indicator.parameters:addDouble("MACD_Buy", "Buy Level", "", 0)
	indicator.parameters:addDouble("MACD_Sell", "Sell Level", "", 0)

	indicator.parameters:addString("MACD_Price", "Price Source", "", "close")
	indicator.parameters:addStringAlternative("MACD_Price", "OPEN", "", "open")
	indicator.parameters:addStringAlternative("MACD_Price", "HIGH", "", "high")
	indicator.parameters:addStringAlternative("MACD_Price", "LOW", "", "low")
	indicator.parameters:addStringAlternative("MACD_Price", "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("MACD_Price", "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("MACD_Price", "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("MACD_Price", "WEIGHTED", "", "weighted")

	indicator.parameters:addGroup("Stochastic Calculation")

	indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000)
	indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000)
	indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000)

	indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA")
	indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT")
	indicator.parameters:addStringAlternative("MVAT_K", "LWMA", "", "LWMA")
	indicator.parameters:addStringAlternative("MVAT_K", "KAMA", "", "KAMA")
	indicator.parameters:addStringAlternative("MVAT_K", "SMMA", "", "SMMA")
	indicator.parameters:addStringAlternative("MVAT_K", "TMA", "", "TMA")
	indicator.parameters:addStringAlternative("MVAT_K", "VIDYA", "", "VIDYA")
	indicator.parameters:addStringAlternative("MVAT_K", "WMA", "", "WMA")

	indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA")
	indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("MVAT_D", "LWMA", "", "LWMA")
	indicator.parameters:addStringAlternative("MVAT_D", "KAMA", "", "KAMA")
	indicator.parameters:addStringAlternative("MVAT_D", "SMMA", "", "SMMA")
	indicator.parameters:addStringAlternative("MVAT_D", "TMA", "", "TMA")
	indicator.parameters:addStringAlternative("MVAT_D", "VIDYA", "", "VIDYA")
	indicator.parameters:addStringAlternative("MVAT_D", "WMA", "", "WMA")

	indicator.parameters:addDouble("OB", "OB Level", "", 80)
	indicator.parameters:addDouble("OS", "OS Level", "", 20)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40, 0, 100)

	indi_alerts:AddParameters(indicator.parameters);
    for i,alert in ipairs(alerts) do
        indi_alerts:AddAlert(alert.Name);
    end
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first
local source = nil
local close
local Parameters = {}
local Indicator = {}
local One, Two, Three, Four, Five

local k
local d
local sd
local averageTypeK = nil
local averageTypeD = nil
local OB, OS

-- Routine
function Prepare(nameOnly)
	Transparency = (100 - instance.parameters.Transparency)
	One = instance.parameters.One
	Two = instance.parameters.Two
	Three = instance.parameters.Three
	Four = instance.parameters.Four
	Five = instance.parameters.Five

	Parameters["DMI"] = instance.parameters.DMI
	Parameters["ADX"] = instance.parameters.ADX
	Parameters["ADX_Entry"] = instance.parameters.ADX_Entry
	Parameters["ADX_Exit"] = instance.parameters.ADX_Exit

	Parameters["CCI"] = instance.parameters.CCI
	Parameters["CCI_Buy"] = instance.parameters.CCI_Buy
	Parameters["CCI_Sell"] = instance.parameters.CCI_Sell

	Parameters["MACD_Short"] = instance.parameters.MACD_Short
	Parameters["MACD_Long"] = instance.parameters.MACD_Long
	Parameters["MACD_Buy"] = instance.parameters.MACD_Buy
	Parameters["MACD_Sell"] = instance.parameters.MACD_Sell
	Parameters["MACD_Price"] = instance.parameters.MACD_Price

	k = instance.parameters.K
	d = instance.parameters.D
	sd = instance.parameters.SD

	averageTypeK = instance.parameters.MVAT_K
	averageTypeD = instance.parameters.MVAT_D

	OB = instance.parameters.OB
	OS = instance.parameters.OS

	source = instance.source
	first = source:first()

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if nameOnly then
		return
	end

	if One then
		Indicator["DMI"] = core.indicators:create("DMI", source, Parameters["DMI"])
		first = math.max(first, Indicator["DMI"].DATA:first())
	end

	if Two then
		Indicator["ADX"] = core.indicators:create("ADX", source, Parameters["ADX"])
		first = math.max(first, Indicator["ADX"].DATA:first())
	end

	if Three then
		Indicator["CCI"] = core.indicators:create("CCI", source, Parameters["CCI"])
		first = math.max(first, Indicator["CCI"].DATA:first())
	end

	if Four then
		Indicator["MACD"] =
			core.indicators:create("MACD", source[Parameters["MACD_Price"]], Parameters["MACD_Short"], Parameters["MACD_Long"])
		first = math.max(first, Indicator["MACD"].DATA:first())
	end

	if Five then
		Indicator["STO"] = core.indicators:create("STOCHASTIC", source, k, d, sd, averageTypeK, averageTypeD)
		first = math.max(first, Indicator["STO"].D:first())
	end

	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first)
	open:setPrecision(math.max(2, instance.source:getPrecision()))
	close:setPrecision(math.max(2, instance.source:getPrecision()))
	instance:createChannelGroup("UpGroup", "Up", open, close, instance.parameters.Up, Transparency)

	indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

function Update(period, mode)
	open[period] = 1
	close[period] = 0

	open:setColor(period, instance.parameters.No)

	local ONE = nil
	local TWO = nil
	local THREE_B = nil
	local THREE_S = nil
	local FOUR_B = nil
	local FOUR_S = nil
	local FIVE_B = nil
	local FIVE_S = nil

	if One then
		Indicator["DMI"]:update(mode)

		if Indicator["DMI"]:getStream(0)[period] > Indicator["DMI"]:getStream(1)[period] then
			ONE = true
		else
			ONE = false
		end
	end

	if Two then
		Indicator["ADX"]:update(mode)

		if Indicator["ADX"].DATA[period] > Parameters["ADX_Entry"] and Indicator["ADX"].DATA[period] < Parameters["ADX_Exit"] then
			TWO = true
		else
			TWO = false
		end
	end

	if Three then
		Indicator["CCI"]:update(mode)

		if Indicator["CCI"].DATA[period] > Parameters["CCI_Buy"] then
			THREE_B = true
		else
			THREE_B = false
		end

		if Indicator["CCI"].DATA[period] < Parameters["CCI_Sell"] then
			THREE_S = false
		else
			THREE_S = true
		end
	end

	if Four then
		Indicator["MACD"]:update(mode)

		if Indicator["MACD"].DATA[period] > Parameters["MACD_Buy"] then
			FOUR_B = true
		else
			FOUR_B = false
		end

		if Indicator["MACD"].DATA[period] < Parameters["MACD_Sell"] then
			FOUR_S = false
		else
			FOUR_S = true
		end
	end

	if Five then
		Indicator["STO"]:update(mode)

		if Indicator["STO"].K[period] > Indicator["STO"].D[period] and Indicator["STO"].D[period] < OB then
			FIVE_B = true
		else
			FIVE_B = false
		end

		if Indicator["STO"].K[period] < Indicator["STO"].D[period] and Indicator["STO"].D[period] > OS then
			FIVE_S = false
		else
			FIVE_S = true
		end
	end

	if
		ONE == nil and TWO == nil and THREE_B == nil and THREE_S == nil and FOUR_B == nil and FOUR_S == nil and FIVE_B == nil and
			FIVE_S == nil
	 then
		open:setColor(period, instance.parameters.No)
	elseif
		(ONE == true or ONE == nil) and (TWO == true or TWO == nil) and (THREE_B == true or THREE_B == nil) and
			(FOUR_B == true or FOUR_B == nil) and
			(FIVE_B == true or FIVE_B == nil)
	 then
		open:setColor(period, instance.parameters.Up)
	elseif
		(ONE == false or ONE == nil) and (TWO == true or TWO == nil) and (THREE_S == false or THREE_S == nil) and
			(FOUR_S == false or FOUR_S == nil) and
			(FIVE_S == false or FIVE_S == nil)
	 then
		open:setColor(period, instance.parameters.Dn)
	else
		open:setColor(period, instance.parameters.No)
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
        alert:UpAlert(source, period, source.high[period], historical_period);
    elseif alert.DownCondition(period) and (not alert.OnChange or not alert.DownCondition(period - 1)) then
        alert:DownAlert(source, period, source.low[period], historical_period);
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
    local i;
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
        function alert:DownAlert(source, period, level, historical_period)
            local text = self.FormatMessage(source, period, level, self.Label, false);
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = -1;
            self.AlertLevel[period] = level;
            self.U = nil;
            if self.D ~= source:date(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
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
        function alert:UpAlert(source, period, level, historical_period)
            local text = self.FormatMessage(source, period, level, self.Label, true);
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = 1;
            self.AlertLevel[period] = level;
            self.D = nil;
            if self.U ~= source:date(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
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
