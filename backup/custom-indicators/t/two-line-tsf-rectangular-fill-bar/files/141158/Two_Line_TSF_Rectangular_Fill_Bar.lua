-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=71002

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--+------------------------------------------------------------------+
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

local Signal, Signal_fast, Signal_slow

local indi_alerts = {};
indi_alerts.Version = "2.2";
indi_alerts.inverted_arrows = false;
local alerts = 
{ 
    {
        Stage = 102,
        UpCondition = function (period)
            return Signal_fast[period] == 1 and Signal_slow[period] == 1;
        end,
        DownCondition = function (period)
            return Signal_fast[period] == -1 and Signal_slow[period] == -1;
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
        Name = "Box open"
    },
    {
        Stage = 102,
        UpCondition = function (period)
            return Signal_fast[period] == 1 and Signal_slow[period] == -1;
        end,
        DownCondition = function (period)
            return Signal_fast[period] == -1 and Signal_slow[period] == 1;
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
        Name = "Box close"
    }
};

function Init()
    indicator:name("Two Line TSF Rectangular Fill Tick")

    indicator:description("BOTH SLOW AND FAST MA IN ONE ")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("1.MA Calculation")

    indicator.parameters:addString("Price_slow", "Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price_slow", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price_slow", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price_slow", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price_slow", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price_slow", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price_slow", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price_slow", "WEIGHTED", "", "weighted")

    indicator.parameters:addInteger("PERIOD_slow", "Period for slow ma", "Period", 81)
    indicator.parameters:addInteger("lookback_slow", "Lookback for slow ma", "", 5)

    indicator.parameters:addInteger("LWMA_slow", "LWMA Weight", "", 3)
    indicator.parameters:addInteger("MA_slow", "MA Weight", "", 2)

    indicator.parameters:addString("Method_slow", "MA Type", "Method", "LWMA")
    indicator.parameters:addStringAlternative("Method_slow", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method_slow", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method_slow", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method_slow", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method_slow", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method_slow", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method_slow", "VIDYA", "VIDYA", "VIDYA")

    indicator.parameters:addGroup("2.MA Calculation")

    indicator.parameters:addString("Price_fast", "Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price_fast", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price_fast", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price_fast", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price_fast", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price_fast", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price_fast", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price_fast", "WEIGHTED", "", "weighted")

    indicator.parameters:addInteger("PERIOD_fast", "Period for fast ma", "Period", 13)

    indicator.parameters:addInteger("lookback_fast", "Lookback for fast ma", "", 5)

    indicator.parameters:addInteger("LWMA_fast", "LWMA Weight", "", 3)

    indicator.parameters:addInteger("MA_fast", "MA Weight", "", 2)

    indicator.parameters:addString("Method_fast", "MA Type", "Method", "LWMA")
    indicator.parameters:addStringAlternative("Method_fast", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method_fast", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method_fast", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method_fast", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method_fast", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method_fast", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method_fast", "VIDYA", "VIDYA", "VIDYA")

    indicator.parameters:addGroup("FillStyle")
    indicator.parameters:addColor("Up", "Strong Color", "Color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Weak Color", "Color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("Transparency", "Transparency", "Transparency", 50)

    indicator.parameters:addBoolean("TopToBottom", "Top To Bottom", "", false)
    indicator.parameters:addBoolean("Flip", "Flip on Confirmation", "", false)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("TSF_Up", "Color of Up Trend", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("TSF_Dn", "Color of Down Trend", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("TSF_width", "MA Width", "", 2, 1, 5)
    indicator.parameters:addInteger("TSF_style", "MA Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("TSF_style", core.FLAG_LEVEL_STYLE)

    indi_alerts:AddParameters(indicator.parameters);
    for i,alert in ipairs(alerts) do
        indi_alerts:AddAlert(alert.Name);
    end
end
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Price_slow, Price_fast
local lookback_slow
local lookbackfast

local Method_slow, Method_fast, ma_slow, ma_fast
local PERIOD_slow
local PERIOD_fast

local Flip

local first_slow, first_fast
local source = nil
local LWMA_slow, MA_slow
local LWMA_fast, MA_fast
-- Streams block

local TSF_slow = nil
local TSF_fast = nil

local TSF_width
local TSF_style

local Transparency
local TopToBottom

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Routine
function Prepare(nameOnly)
    lookback_slow = instance.parameters.lookback_slow
    Method_slow = instance.parameters.Method_slow
    PERIOD_slow = instance.parameters.PERIOD_slow
    LWMA_slow = instance.parameters.LWMA_slow
    MA_slow = instance.parameters.MA_slow
    TopToBottom = instance.parameters.TopToBottom

    lookback_fast = instance.parameters.lookback_fast
    Method_fast = instance.parameters.Method_fast
    PERIOD_fast = instance.parameters.PERIOD_fast
    LWMA_fast = instance.parameters.LWMA_fast
    MA_fast = instance.parameters.MA_fast

    Price_slow = instance.parameters.Price_slow
    Price_fast = instance.parameters.Price_fast

    Flip = instance.parameters.Flip

    source = instance.source
    first_slow = source:first() + PERIOD_slow - 1
    first_fast = source:first() + PERIOD_fast - 1

    TSF_width = instance.parameters.TSF_width
    TSF_style = instance.parameters.TSF_style

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);

    TSF_slow = instance:addStream("TSF", core.Line, name, "TSF_S", instance.parameters.TSF_Dn, first_slow)
    TSF_fast = instance:addStream("TSF", core.Line, name, "TSF_F", instance.parameters.TSF_Dn, first_fast)

    TSF_slow:setWidth(instance.parameters.TSF_width)
    TSF_slow:setStyle(instance.parameters.TSF_style)

    TSF_fast:setWidth(instance.parameters.TSF_width)
    TSF_fast:setStyle(instance.parameters.TSF_style)

    ma_slow = core.indicators:create(Method_slow, source[Price_slow], PERIOD_slow)
    ma_fast = core.indicators:create(Method_fast, source[Price_fast], PERIOD_fast)

    Signal = instance:addInternalStream(0, 0)
    Signal_fast = instance:addInternalStream(0, 0)
    Signal_slow = instance:addInternalStream(0, 0)

    instance:ownerDrawn(true)
end
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first_slow or not source:hasData(period) then
        return
    end
    if period < first_fast or not source:hasData(period) then
        return
    end

    local matype_slow
    ma_slow:update(mode)
    matype_slow = ma_slow.DATA[period]

    local matype_fast
    ma_fast:update(mode)
    matype_fast = ma_fast.DATA[period]

    --------------------------------------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------------------------------------

    TSF_slow[period] = LWMA_slow * matype_slow - MA_slow * matype_slow
    TSF_fast[period] = LWMA_fast * matype_fast - MA_fast * matype_fast

    --------------------------------------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------------------------------------

    if TSF_slow[period] > TSF_slow[period - lookback_slow] then
        TSF_slow:setColor(period, instance.parameters.TSF_Up)
        Signal_slow[period] = 1
    elseif TSF_slow[period] < TSF_slow[period - lookback_slow] then
        Signal_slow[period] = -1
        TSF_slow:setColor(period, instance.parameters.TSF_Dn)
    end
    --------------------------------------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------------------------------------

    if TSF_fast[period] > TSF_fast[period - lookback_fast] then
        TSF_fast:setColor(period, instance.parameters.TSF_Up)
        Signal_fast[period] = 1
    elseif TSF_fast[period] < TSF_fast[period - lookback_fast] then
        Signal_fast[period] = -1
        TSF_fast:setColor(period, instance.parameters.TSF_Dn)
    end

    if Flip then
        Signal[period] = Signal[period - 1]
    end

    if Signal_slow[period] == 1 and Signal_fast[period] == 1 then
        Signal[period] = 1
    elseif Signal_slow[period] == -1 and Signal_fast[period] == -1 then
        Signal[period] = -1
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

local init = false

function Draw(stage, context)
    indi_alerts:Draw(stage, context, source);
    if stage ~= 2 then
        return
    end

    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

    if not init then
        init = true
        Transparency = context:convertTransparency(instance.parameters.Transparency)

        context:createSolidBrush(1, instance.parameters.Up)
        context:createSolidBrush(2, instance.parameters.Down)
    end

    local First = math.max(source:first(), context:firstBar())
    local Last = math.min(context:lastBar(), source:size() - 1)

    local next
    local LastSignal = 0
    local y1, y2
    local Max, Min
    for period = Last, First, -1 do
        if LastSignal ~= Signal[period] then
            LastSignal = Signal[period]

            x, x1, x = context:positionOfBar(period)
            next, Min, Max = Next(period)

            if next ~= 0 then
                x, x, x2 = context:positionOfBar(next)

                if TopToBottom then
                    y1 = context:top()
                    y2 = context:bottom()
                else
                    visible, y1 = context:pointOfPrice(Max)
                    visible, y2 = context:pointOfPrice(Min)
                end

                if Signal[period] == 1 then
                    context:drawRectangle(-1, 1, x1, y1, x2, y2, Transparency)
                elseif Signal[period] == -1 then
                    context:drawRectangle(-1, 2, x1, y1, x2, y2, Transparency)
                end
            end
        end
    end
end

function Next(period)
    local Return = 0
    local Max = 0
    local Min = 0

    for i = period, source:first(), -1 do
        if Signal[period] ~= Signal[i] then
            Return = i
            break
        end
    end

    if Return ~= 0 and period > Return then
        Min, Max = mathex.minmax(source, Return, period)
    end

    return Return, Min, Max
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
indi_alerts.NextId = 3;
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
