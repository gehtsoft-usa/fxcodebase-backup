-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66279

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

-- Indicator profile initialization routine
function Init()
    indicator:name("ZigZag Cycle Info")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12)
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5)
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Period", "Period in Candles", "0 for All", 0)

    indicator.parameters:addInteger("max_cycles", "Max. cycles", "", 6);

    indicator.parameters:addGroup("Line Style")
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE)

    indicator.parameters:addGroup("Placement")

    indicator.parameters:addString("X", " X Placement", "", "Right")
    indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
    indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
    indicator.parameters:addInteger("ShiftY", "Vertical Shift", "", 25)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
    indicator.parameters:addInteger("Size", "Font Size", "", 20)
    indicator.parameters:addInteger("Size2", "ZigZag Font Size", "", 8)
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))

    signaler:Init(indicator.parameters);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth
local Deviation
local Backstep

local first
local FIRST
local source = nil
local Period
-- Streams block
local ZigC
local ZagC
local out
local pipSize

local X
local Label
local Size, Size2
local ShiftY

local NumberOfCycles
local MaxSize
local MinSize

local AvgUp
local AvgDown
local Avg
local max_cycles;

local zz;

-- Routine
function Prepare(nameOnly)
    signaler:Prepare(nameOnly);
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
    Period = instance.parameters.Period
    source = instance.source
    first = source:first()

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    NumberOfCycles = 0
    MaxSize = 0
    MinSize = 0

    AvgUp = 0
    AvgDown = 0
    Avg = 0

    X = instance.parameters.X
    ShiftY = instance.parameters.ShiftY
    Label = instance.parameters.Label
    Size = instance.parameters.Size
    Size2 = instance.parameters.Size2;
    max_cycles = instance.parameters.max_cycles;

    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first)
    out:setWidth(instance.parameters.widthZigZag)
    out:setStyle(instance.parameters.styleZigZag)
    ZigC = instance.parameters.Zig_color
    ZagC = instance.parameters.Zag_color

    zz = CreateZigZag(out, Depth, Deviation, Backstep, ZigC, ZagC)

    pipSize = source:pipSize()

    instance:ownerDrawn(true)

    core.host:execute("setTimer", 1, 1)
end

function CreateZigZag(stream, Depth, Deviation, Backstep, ZigC, ZagC)
    local searchBoth = 0
    local searchPeak = 1
    local searchLawn = -1
    local zz = {};
    zz.out = stream;
    zz.Depth = Depth;
    zz.Deviation = Deviation;
    zz.Backstep = Backstep;
    zz.TotalPeaks = 0;
    zz.SearchMode = instance:addInternalStream(0, 0)
    zz.Peak = instance:addInternalStream(0, 0)
    zz.HighMap = instance:addInternalStream(0, 0)
    zz.LowMap = instance:addInternalStream(0, 0)
    function zz:RegisterPeak(period, mode, peak)
        local index = 1;
        local bookmark = self.out:getBookmark(index);
        while (bookmark ~= -1) do
            local nextBookmark = self.out:getBookmark(index + 1);
            self.out:setBookmark(index + 1, bookmark)
            bookmark = nextBookmark;
            index = index + 1;
        end
        self.TotalPeaks = index - 1;
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
    end
    function zz:EnumPeaks()
        local enum = {};
        enum.zz = self;
        enum.Index = 0;
        function enum:Next()
            self.Index = self.Index + 1;
            return self.Index <= self.zz.TotalPeaks;
        end
        function enum:GetData()
            local period = self.zz.out:getBookmark(self.Index);
            if period == -1 then
                return nil;
            end
            return period, self.zz.Peak[period], self.zz.SearchMode[period];
        end
        return enum;
    end
    function zz:ReplaceLastPeak(period, mode, peak)
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
    end
    function zz:Clear()
        self.lastlow = nil
        self.lasthigh = nil
        self.TotalPeaks = 0;
    end
    function zz:Calc(period)
        if (period < self.Depth) then
            return;
        end
        local range = period - self.Depth + 1
        local val = mathex.min(source, range, period)
        if val ~= self.lastlow then
            self.lastlow = val
            if (source[period] - val) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.LowMap[i] ~= 0) and (self.LowMap[i] > val) then
                        self.LowMap[i] = 0
                    end
                end
            end
            if source[period] == val then
                self.LowMap[period] = val
            else
                self.LowMap[period] = 0
            end
        end
        val = mathex.max(source, range, period)
        if val ~= lasthigh then
            self.lasthigh = val
            if (val - source[period]) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.HighMap[i] ~= 0) and (self.HighMap[i] < val) then
                        self.HighMap[i] = 0
                    end
                end
            end
            if source[period] == val then
                self.HighMap[period] = val
            else
                self.HighMap[period] = 0
            end
        end

        local prev_peak = self.out:getBookmark(2)
        local start = self.Depth
        local last_peak_i = self.out:getBookmark(1)
        if last_peak_i ~= -1 then
            start = last_peak_i
        end

        for i = start, period, 1 do
            if last_peak_i == -1 then
                if (self.HighMap[i] ~= 0) then
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                elseif (self.LowMap[i] ~= 0) then
                    last_peak_i = i
                    self:RegisterPeak(i, searchPeak, self.LowMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchPeak then
                if (self.LowMap[i] ~= 0 and self.LowMap[i] < self.Peak[last_peak_i]) then
                    last_peak_i = i
                    if prev_peak ~= -1 then
                        core.drawLine(self.out, core.range(prev_peak, i), self.Peak[prev_peak], prev_peak, self.LowMap[i], i, ZagC)
                        self.out:setColor(prev_peak, ZigC)
                    end
                    self:ReplaceLastPeak(i, searchPeak, self.LowMap[i])
                end
                if self.HighMap[i] ~= 0 and self.LowMap[i] == 0 then
                    core.drawLine(self.out, core.range(last_peak_i, i), self.Peak[last_peak_i], last_peak_i, self.HighMap[i], i, ZigC)
                    self.out:setColor(last_peak_i, ZagC)
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchLawn then
                if (self.HighMap[i] ~= 0 and self.HighMap[i] > self.Peak[last_peak_i]) then
                    last_peak_i = i
                    if prev_peak ~= -1 then
                        core.drawLine(self.out, core.range(prev_peak, i), self.Peak[prev_peak], prev_peak, self.HighMap[i], i, ZigC)
                        self.out:setColor(prev_peak, ZagC)
                    end
                    self:ReplaceLastPeak(i, searchLawn, self.HighMap[i])
                end
                if self.LowMap[i] ~= 0 and self.HighMap[i] == 0 then
                    if self.Peak[last_peak_i] > self.LowMap[i] then
                        core.drawLine(self.out, core.range(last_peak_i, i), self.Peak[last_peak_i], last_peak_i, self.LowMap[i], i, ZagC)
                        self.out:setColor(last_peak_i, ZigC)
                    else
                        core.drawLine(self.out, core.range(last_peak_i, i), self.Peak[last_peak_i], last_peak_i, self.LowMap[i], i, ZigC)
                        self.out:setColor(last_peak_i, ZagC)
                    end
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchPeak, self.LowMap[i])
                end
            end
        end
    end
    
    return zz;
end

local last_swing = 0;
local NumberOfCycles = 0
local NumberOfCyclesUp = 0
local NumberOfCyclesDown = 0
local total_bars = 0;
function AsyncOperationFinished(cookie)
    if cookie == 1 then
        NumberOfCycles = 0
        MaxSize = 0
        MinSize = 0

        AvgUp = 0
        AvgDown = 0
        Avg = 0

        NumberOfCyclesUp = 0
        NumberOfCyclesDown = 0
        total_bars = 0;

        if Period == 0 then
            FIRST = first
        else
            FIRST = math.max(first, source:size() - 1 - Period)
        end

        local enum = zz:EnumPeaks();
        if not enum:Next() then
            return;
        end
        local current_period, current_value, current_direction = enum:GetData();
        local SwingDirection = current_direction * (-1);
        while (enum:Next()) do
            local next_period, next_value, next_direction = enum:GetData();

            local val = math.abs(current_value - next_value) / pipSize;
            NumberOfCycles = NumberOfCycles + 1
            MaxSize = math.max(val, MaxSize)
            if MinSize == 0 then
                MinSize = val
            elseif val ~= 0 then
                MinSize = math.min(val, MinSize)
            end
            total_bars = total_bars + current_period - next_period;

            if next_direction == 1 then
                AvgUp = AvgUp + val
                NumberOfCyclesUp = NumberOfCyclesUp + 1
            else
                AvgDown = AvgDown + val
                NumberOfCyclesDown = NumberOfCyclesDown + 1
            end
            Avg = Avg + val
            
            current_period = next_period;
            current_value = next_value;
            current_direction = next_direction;

            if max_cycles ~= 0 and NumberOfCycles == max_cycles then
                break;
            end
        end
        if NumberOfCycles ~= 0 then
            Avg = Avg / NumberOfCycles
        end
        if NumberOfCyclesUp ~= 0 then
            AvgUp = AvgUp / NumberOfCyclesUp
        end
        if NumberOfCyclesDown ~= 0 then
            AvgDown = AvgDown / NumberOfCyclesDown
        end
        if last_swing ~= SwingDirection then
            last_swing = SwingDirection;
            if last_swing == 1 then
                signaler:Signal("New down cycle is started");
            else
                signaler:Signal("New up cycle is started");
            end
        end
    end
end

function ReleaseInstance()
    core.host:execute("killTimer", 1)
end

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1
    if period < 0 or source:serial(period) == lastserial then
        return
    end

    if mode == core.UpdateAll then
        zz:Clear();
    end

    lastserial = source:serial(period);
    zz:Calc(period);
end

local Init = true
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())
    if Init then
        context:createFont(1, "Arial", 0, context:pointsToPixels(Size), 0)
        context:createFont(2, "Arial", 0, context:pointsToPixels(Size2), 0)
        Init = false
    end

    if NumberOfCycles ~= 0 then
        Text = "Number of Cycles : " .. NumberOfCycles

        i = 1
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, i, 0),
            iX(context, width, 0, 2), iY(context, height, i, 1), 0)
        
        Text = "Avg Bars : " .. win32.formatNumber(total_bars / NumberOfCycles, false, 1);
        i = 7
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, i, 0),
            iX(context, width, 0, 2), iY(context, height, i, 1), 0)
    end

    if MaxSize ~= 0 then
        Text = "Max Size : " .. round(MaxSize, 1)

        i = 5
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, i, 0),
            iX(context, width, 0, 2), iY(context, height, i, 1), 0)
    end

    if MinSize ~= 0 then
        Text = "Min Size : " .. round(MinSize, 1)

        i = 6
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, i, 0),
            iX(context, width, 0, 2), iY(context, height, i, 1), 0)
    end

    if Avg ~= 0 then
        Text = "Average Cycle: " .. round(Avg, 1)

        i = 2
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, i, 0),
            iX(context, width, 0, 2), iY(context, height, i, 1), 0)
    end

    if AvgUp ~= 0 then
        Text = "Average Up Cycle: " .. round(AvgUp, 1)

        i = 3
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, i, 0),
            iX(context, width, 0, 2), iY(context, height, i, 1), 0)
    end

    if AvgDown ~= 0 then
        Text = "Average Down Cycle: " .. round(AvgDown, 1)

        i = 4
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, i, 0),
            iX(context, width, 0, 2), iY(context, height, i, 1), 0)
    end

    local enum = zz:EnumPeaks();
    if not enum:Next() then
        return;
    end
    local current_period, current_value, current_direction = enum:GetData();
    while (enum:Next()) do
        local next_period, next_value, next_direction = enum:GetData();
        if current_value > next_value then
            Text = math.ceil(math.abs(current_value - next_value) / source:pipSize());
            local x = context:positionOfBar(current_period);
            local _, y = context:pointOfPrice(current_value);
            width, height = context:measureText(2, Text, 0)
            context:drawText(2, Text, Label, -1, x - width / 2, y - height, x + width / 2, y, 0)
        else
            Text = math.ceil(math.abs(current_value - next_value) / source:pipSize());
            local x = context:positionOfBar(current_period);
            local _, y = context:pointOfPrice(current_value);
            width, height = context:measureText(2, Text, 0)
            context:drawText(2, Text, Label, -1, x - width / 2, y, x + width / 2, y + height, 0)
        end

        current_period = next_period;
        current_value = next_value;
        current_direction = next_direction;
    end
end

function round(num, idp)
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function iX(context, width, Shift, x)
    if X == "Left" then
        return context:left() + Shift * width + width * (x - 1)
    else
        return context:right() - width * Shift - width * (1 - (x - 1))
    end
end

function iY(context, height, Index, Line)
    return context:top() + Index * height + ShiftY + Line * height
end

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.2.0";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._telegram_timer = nil;
signaler._tz = nil;
signaler._alerts = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._telegram_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._external_service_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._external_service_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", 1, 4, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(label, source)
    if source == nil then
        source = instance.bid;
        if instance.bid == nil then
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        else
            source = instance.bid;
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], label, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. label, self:FormatEmail(source, NOW, label));
    end

    if self._external_service_key ~= nil then
        self:AlertTelegram(label, source:instrument(), source:barSize());
    end
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addGroup("Alerts");
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    parameters:addBoolean("use_external_service", "Send to external service", "Telegram message or Channel post", false);
    parameters:addString("external_service_key", "External service Key", "You can get it via @profit_robots_bot Telegram bot", "");
end

function signaler:Prepare(name_only)
    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.external_service_key ~= "" and instance.parameters.use_external_service then
        self._external_service_key = instance.parameters.external_service_key;
        require("http_lua");
        self._telegram_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._telegram_timer, 1);
    end
end