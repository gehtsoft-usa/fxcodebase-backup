-- Id: 11333

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59571

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

function AddLevel(id, name)
    indicator.parameters:addGroup(name)
    indicator.parameters:addColor(id .. "_color", "Color of level lines", "", core.rgb(255, 255, 0))
    indicator.parameters:addInteger(id .. "_width", "Width of level lines", "", 1, 1, 5)
    indicator.parameters:addInteger(id .. "_style", "Style level lines", "", core.LINE_SOLID)
    indicator.parameters:setFlag(id .. "_style", core.FLAG_LINE_STYLE)
end

function Init()
    indicator:name("ZigZag with Fibonacci")
    indicator:description("Automatic Fib or Gann levels on the base of H/L values")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Zig Zag Parameters")
    indicator.parameters:addInteger(
        "Depth",
        "Depth",
        "the minimal amount of bars where there will not be the second maximum",
        12
    )
    indicator.parameters:addInteger(
        "Deviation",
        "Deviation",
        "Distance in pips to eliminate the second maximum in the last Depth periods",
        5
    )
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)
    indicator.parameters:addColor("ZigZag_color", "Color of ZigZag", "Color of ZigZag", core.rgb(255, 0, 0))

    indicator.parameters:addGroup("Fibonacci/Gann Parameters")
    indicator.parameters:addBoolean("Show_lines", "Show Lines", "", true)
    indicator.parameters:addString("M", "Lines Method", "", "F")
    indicator.parameters:addStringAlternative("M", "Fibonacci", "", "F")
    indicator.parameters:addStringAlternative("M", "Gann", "", "G")
    indicator.parameters:addString("L", "Levels number", "", "3")
    indicator.parameters:addStringAlternative("L", "3 Lines", "", "3")
    indicator.parameters:addStringAlternative("L", "3 Lines (alt)", "", "3a")
    indicator.parameters:addStringAlternative("L", "5 Lines", "", "5")
    indicator.parameters:addStringAlternative("L", "7 Lines", "", "7")
    indicator.parameters:addStringAlternative("L", "9 Lines", "", "9")
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("L_color", "Color of level lines", "", core.rgb(255, 255, 0))
    indicator.parameters:addInteger("L_width", "Width of level lines", "", 1, 1, 5)
    indicator.parameters:addInteger("L_style", "Style level lines", "", core.LINE_SOLID)
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("M_color", "Time marker color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("M_width", "Width of level lines", "", 1, 1, 5)
    indicator.parameters:addInteger("M_style", "Style level lines", "", core.LINE_DOT)
    indicator.parameters:setFlag("M_style", core.FLAG_LINE_STYLE)

    AddLevel("L1", "-0.236/0");
    AddLevel("L2", "0/0.125");
    AddLevel("L3", "0.236/0.25");
    AddLevel("L4", "0.382/0.375");
    AddLevel("L5", "0.5/0.5");
    AddLevel("L6", "0.618/0.625");
    AddLevel("L7", "0.764/0.75");
    AddLevel("L8", "1/0.875");
    AddLevel("L9", "1.272/1");

    indicator.parameters:addBoolean("ShowLabels", "Show Line Labels", "", true)

    indicator.parameters:addColor("Color", "Font color", "", core.rgb(0, 0, 0))

    indicator.parameters:addBoolean("ShowZigZag", "Show ZigZag Line", "", true)
    indicator.parameters:addBoolean("Extend", "Extend Lines", "", true)

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("ABC");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth
local Deviation
local Backstep

local Show
local M
local L
local E
local L_color
local L_width
local L_style
local M_color
local M_width
local M_style
local ShowLabels
local Extend, Size, Color, ShowZigZag

local barSize
local format

local first
local source = nil

-- Streams block
local ZigZag = nil
local Zig
-- Routine
function Prepare(nameOnly)
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    Extend = instance.parameters.Extend
    Size = instance.parameters.Size
    Color = instance.parameters.Color
    ShowZigZag = instance.parameters.ShowZigZag

    Show = instance.parameters.Show_lines
    M = instance.parameters.M
    L = instance.parameters.L
    -- E = instance.parameters.E;
    L_color = instance.parameters.L_color
    L_width = instance.parameters.L_width
    L_style = instance.parameters.L_style
    M_color = instance.parameters.M_color
    M_width = instance.parameters.M_width
    M_style = instance.parameters.M_style
    ShowLabels = instance.parameters.ShowLabels

    source = instance.source
    local s, e
    s, e = core.getcandle(source:barSize(), core.now(), 0)
    barSize = math.floor(((e - s) * 1440) + 0.5) / 1440

    format = "%.3f=%." .. source:getPrecision() .. "f"

    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep

    local name =
        profile:id() ..
        "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ", " .. M .. ", " .. L .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    Zig = core.indicators:create("ZIGZAG", source, Depth, Deviation, Backstep)
    first = Zig.DATA:first()

    if ShowZigZag then
        ZigZag = instance:addStream("ZigZag", core.Line, name, "ZigZag", instance.parameters.ZigZag_color, first)
    else
        ZigZag = instance:addInternalStream(0, 0)
    end

    instance:ownerDrawn(true)
end

local MIN = nil
local MAX = nil
local P = nil
local levels = nil
local index = nil

function Update(period, mode)
    Zig:update(mode)

    if period < first then
        return
    end

    if Zig.DATA[period] == 0 or Zig.DATA[period] == nil then
        ZigZag[period] = nil
    else
        ZigZag[period] = Zig.DATA[period]
    end
    
    local index = GetNextCrest(period);
    local last = GetNextCrest(index);
    if index > 0 and last > 0 then
        local swingSize = math.abs(Zig.DATA[index] - Zig.DATA[last]) / source:pipSize();
        core.host:execute("setStatus", "Last swing: " .. win32.formatNumber(swingSize, false, 1));
    end
    
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, index, period ~= source:size() - 1 and Zig.DATA:hasData(index + 1)); end
end

function IsABCUp(index)
    if index == Zig.DATA:size() - 1 then
        return false;
    end
    if source.close[index + 1] >= source.open[index] then
        return false
    end
    local d = Zig.DATA[index];
    if d == nil then
        return false;
    end
    index = GetNextCrest(index);
    local c = Zig.DATA[index];
    if c == nil then
        return false;
    end
    index = GetNextCrest(index);
    local b = Zig.DATA[index];
    if b == nil then
        return false;
    end
    index = GetNextCrest(index);
    local a = Zig.DATA[index];
    if a == nil then
        return false;
    end
    return d < b and c < a;
end

function IsABCDown(index)
    if index == Zig.DATA:size() - 1 then
        return false;
    end
    if source.close[index + 1] <= source.open[index] then
        return false;
    end
    local d = Zig.DATA[index];
    if d == nil then
        return false;
    end
    index = GetNextCrest(index);
    local c = Zig.DATA[index];
    if c == nil then
        return false;
    end
    index = GetNextCrest(index);
    local b = Zig.DATA[index];
    if b == nil then
        return false;
    end
    index = GetNextCrest(index);
    local a = Zig.DATA[index];
    if a == nil then
        return false;
    end
    return d > b and c > a
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if alert.id == 1 then
        if IsABCDown(period) then
            alert:UpAlert(source, period, alert.Label .. ". Bull pattern", source.high[period], historical_period);
        elseif IsABCUp(period) then
            alert:DownAlert(source, period, alert.Label .. ". Bear pattern", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

function GetNextCrest(index)
    if not Zig.DATA:hasData(index) then
        while index > 0 and not Zig.DATA:hasData(index) do
            index = index - 1;
        end
        return index;
    end
    local isascending = Zig.DATA[index - 1] < Zig.DATA[index];
    while index > 0 and Zig.DATA[index - 1] < Zig.DATA[index] == isascending do
        index = index - 1;
    end
    return index;
end

local init = false

function Draw(stage, context)
    indi_alerts:Draw(stage, context, source);
    if not Show then
        return;
    end
    
    if stage ~= 2 then
        return
    end

    if not init then
        context:createPen(4, context:convertPenStyle(L_style), L_width, L_color)
        context:createPen(2, context:convertPenStyle(M_style), M_width, M_color)
        context:createFont(3, "Arial", Size, Size, context.LEFT)
        for i = 1, 9 do
            local color = instance.parameters:getColor("L" .. i .. "_color");
            local style = instance.parameters:getInteger("L" .. i .. "_style");
            local width = instance.parameters:getInteger("L" .. i .. "_width");
            context:createPen(4 + i, context:convertPenStyle(style), width, color)
        end
        init = true
    end

    local min, max, minp, maxp
    local p1 = nil
    local p2 = nil

    for i = source:size() - 2, first, -1 do
        if Zig.DATA[i] == 0 or Zig.DATA[i] == nil then
            ZigZag[i] = nil
        else
            ZigZag[i] = Zig.DATA[i]
        end

        if
            p1 == nil and ZigZag[i + 1] ~= nil and ZigZag[i] ~= nil and ZigZag[i - 1] ~= nil and ZigZag[i + 1] ~= 0 and
                ZigZag[i] ~= 0 and
                ZigZag[i - 1] ~= 0
         then
            if ZigZag[i] > ZigZag[i - 1] and ZigZag[i] > ZigZag[i + 1] then
                p1 = i
            end
        end

        if
            p2 == nil and ZigZag[i + 1] ~= nil and ZigZag[i] ~= nil and ZigZag[i - 1] ~= nil and ZigZag[i + 1] ~= 0 and
                ZigZag[i] ~= 0 and
                ZigZag[i - 1] ~= 0
         then
            if ZigZag[i] < ZigZag[i - 1] and ZigZag[i] < ZigZag[i + 1] then
                p2 = i
            end
        end

        if p1 ~= nil and p2 ~= nil then
            break
        end
    end

    local Direction

    if ZigZag[p1] > ZigZag[p2] then
        min = ZigZag[p2]
        max = ZigZag[p1]
        minp = p2
        maxp = p1
        Direction = 1
    elseif ZigZag[p1] > ZigZag[p2] then
        min = ZigZag[p1]
        max = ZigZag[p2]
        minp = p1
        maxp = p2
        Direction = -1
    else
        return
    end

    CalculateLevels(min, max, minp, maxp, Direction, context)
end

function CalculateLevels(min, max, minp, maxp, Direction, context)
    local N = 10

    local p, k, v, f, t, price, d, label

    p = math.min(minp, maxp)

    MIN = min
    MAX = max
    d = max - min
    P = p

    if levels == nil then
        CalcLevels(Direction)
    end
    local idx
    idx = index[L]

    if Extend then
        t = context:right()
        f, x1, x2 = context:positionOfBar(p)
    else
        t = context:positionOfBar(source:size() - 1)
        f, x1, x2 = context:positionOfBar(p)
    end

    for k, v in pairs(idx) do
        if Direction == -1 then
            price = min + d * levels[v]
        else
            price = max - d * levels[v]
        end
        --i

        label = string.format(format, levels[v], price)

        visible1, y1 = context:pointOfPrice(price)

        context:drawLine(4 + v, f, y1, t, y1)

        if ShowLabels then
            local width, height = context:measureText(3, label, context.LEFT)
            context:drawText(3, label, Color, -1, f, y1 - height, f + width, y1, context.LEFT)
        end
    end

    visible1, y1 = context:pointOfPrice(min)
    visible2, y2 = context:pointOfPrice(max)
    context:drawLine(2, f, y1, f, y2)
end

function CalcLevels()
    levels = {}
    index = {}

    if M == "F" then
        levels[1] = -0.236
        levels[2] = 0
        levels[3] = 0.236
        levels[4] = 0.382
        levels[5] = 0.5
        levels[6] = 0.618
        levels[7] = 0.764
        levels[8] = 1
        levels[9] = 1.272
        index["3"] = {4, 5, 6}
        index["3a"] = {2, 5, 8}
        index["5"] = {2, 4, 5, 6, 8}
        index["7"] = {2, 3, 4, 5, 6, 7, 8}
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    else
        levels[1] = 0
        levels[2] = 0.125
        levels[3] = 0.25
        levels[4] = 0.375
        levels[5] = 0.5
        levels[6] = 0.625
        levels[7] = 0.75
        levels[8] = 0.875
        levels[9] = 1
        index["3"] = {3, 5, 7}
        index["3a"] = {1, 5, 9}
        index["5"] = {1, 3, 5, 7, 9}
        index["7"] = {1, 3, 4, 5, 6, 7, 9}
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    end
end

indi_alerts.Version = "1.5";
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts.total_alerts = 1;
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
    if stage ~= 2 then
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