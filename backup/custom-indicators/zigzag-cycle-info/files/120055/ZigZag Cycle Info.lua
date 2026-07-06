-- Id: 21728
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
local HighMap = nil
local LowMap = nil
local pipSize
local Flag

local ZigZag

local X
local Label
local Size
local ShiftY

local NumberOfCycles
local MaxSize
local MinSize

local AvgUp
local AvgDown
local Avg

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

    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first)
    out:setWidth(instance.parameters.widthZigZag)
    out:setStyle(instance.parameters.styleZigZag)

    ZigC = instance.parameters.Zig_color
    ZagC = instance.parameters.Zag_color

    HighMap = instance:addInternalStream(0, 0)
    LowMap = instance:addInternalStream(0, 0)
    SearchMode = instance:addInternalStream(0, 0)
    Peak = instance:addInternalStream(0, 0)
    Flag = instance:addInternalStream(0, 0)
    pipSize = source:pipSize()

    ZigZag = instance:addInternalStream(0, 0)

    instance:ownerDrawn(true)

    core.host:execute("setTimer", 1, 1)
end

local last_swing = 0;
local NumberOfCycles = 0
local NumberOfCyclesUp = 0
local NumberOfCyclesDown = 0
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
        local SwingDirection;

        if Period == 0 then
            FIRST = first
        else
            FIRST = math.max(first, source:size() - 1 - Period)
        end

        for period = source:size() - 1, FIRST, -1 do
            if Flag[period] ~= 0 then
                NumberOfCycles = NumberOfCycles + 1

                MaxSize = math.max(math.abs(ZigZag[period] / pipSize), MaxSize)

                if MinSize == 0 then
                    MinSize = math.abs(ZigZag[period]) / pipSize
                elseif ZigZag[period] ~= 0 then
                    MinSize = math.min(math.abs(ZigZag[period] / pipSize), MinSize)
                end

                if Flag[period] == 1 then
                    AvgUp = AvgUp + math.abs(ZigZag[period]) / pipSize
                    if SwingDirection == nil then
                        SwingDirection = 1;
                    end
                    NumberOfCyclesUp = NumberOfCyclesUp + 1
                elseif Flag[period] == -1 then
                    AvgDown = AvgDown + math.abs(ZigZag[period]) / pipSize
                    if SwingDirection == nil then
                        SwingDirection = -1;
                    end
                    NumberOfCyclesDown = NumberOfCyclesDown + 1
                end
                Avg = Avg + math.abs(ZigZag[period]) / pipSize
            end
        end
        if NumberOfCycles ~= 0 then
            Avg = Avg / NumberOfCycles
        else
            Avg = 0
        end

        if NumberOfCyclesUp ~= 0 then
            AvgUp = AvgUp / NumberOfCyclesUp
        else
            AvgUp = 0
        end

        if NumberOfCyclesDown ~= 0 then
            AvgDown = AvgDown / NumberOfCyclesDown
        else
            AvgDown = 0
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

local searchBoth = 0
local searchPeak = 1
local searchLawn = -1
local lastlow = nil
local lashhigh = nil

-- optimization hint
local peak_count = 0

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1
    out:setBookmark(peak_count, period)
    SearchMode[period] = mode
    Peak[period] = peak
end

function ReplaceLastPeak(period, mode, peak)
    --peak_count = peak_count + 1;
    out:setBookmark(peak_count, period)
    SearchMode[period] = mode
    Peak[period] = peak
end

function GetPeak(offset)
    local peak
    peak = peak_count + offset
    if peak < 1 then
        return -1
    end
    peak = out:getBookmark(peak)
    if peak < 0 then
        return -1
    end
    return peak
end

local lastperiod = -1

function DeleteLabels(startBar, endBar)
    local i
    for i = startBar, endBar, 1 do
        Flag[i] = 0
        ZigZag[i] = 0
    end
    return
end

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1
    Flag[period] = 0

    if period == lastperiod then
        return
    end

    if period < lastperiod then
        lastlow = nil
        lasthigh = nil
        peak_count = 0
    end

    lastperiod = period

    if period >= Depth then
        -- fill high/low maps
        local range = period - Depth + 1
        local val
        local i
        -- get the lowest low for the last depth periods
        val = mathex.min(source.low, range, period)
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil
        else
            -- keep it
            lastlow = val
            -- if current low is higher for more than Deviation pips, ignore
            if (source.low[period] - val) > (source:pipSize() * Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = 0
                    end
                end
            end
        end
        if source.low[period] == val then
            LowMap[period] = val
        else
            LowMap[period] = 0
        end
        -- get the lowest low for the last depth periods
        val = mathex.max(source.high, range, period)
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil
        else
            -- keep it
            lasthigh = val
            -- if current low is higher for more than Deviation pips, ignore
            if (val - source.high[period]) > (source:pipSize() * Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = 0
                    end
                end
            end
        end

        if source.high[period] == val then
            HighMap[period] = val
        else
            HighMap[period] = 0
        end

        local start
        local last_peak
        local last_peak_i
        local prev_peak
        local searchMode = searchBoth

        i = GetPeak(-4)
        if i == -1 then
            prev_peak = nil
        else
            prev_peak = i
        end

        start = Depth
        i = GetPeak(-3)
        if i == -1 then
            last_peak_i = nil
            last_peak = nil
        else
            last_peak_i = i
            last_peak = Peak[i]
            searchMode = SearchMode[i]
            start = i
        end

        peak_count = peak_count - 3

        for i = start, period, 1 do
            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i
                    last_peak = HighMap[i]
                    searchMode = searchLawn
                    RegisterPeak(i, searchMode, last_peak)
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i
                    last_peak = LowMap[i]
                    searchMode = searchPeak
                    RegisterPeak(i, searchMode, last_peak)
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i]
                    last_peak_i = i
                    if prev_peak ~= nil then
                        if Peak[prev_peak] > LowMap[i] then
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZagC)
                            out:setColor(prev_peak, ZigC)
                            DeleteLabels(prev_peak + 1, i)
                            --TextBuff:set(i, LowMap[i], TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i]));
                            Flag[i] = -1

                            ZigZag[i] = Peak[prev_peak] - LowMap[i]
                        else
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC)
                            out:setColor(prev_peak, ZagC)
                            DeleteLabels(prev_peak + 1, i)
                            --TextBuff:set(i, LowMap[i], TextFormat(i-prev_peak, Peak[prev_peak]-LowMap[i]));
                            Flag[i] = -1
                            ZigZag[i] = Peak[prev_peak] - LowMap[i]
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak)
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC)
                    out:setColor(last_peak_i, ZagC)
                    DeleteLabels(last_peak_i + 1, i)
                    --TextBuff:set(i, HighMap[i], TextFormat(i-last_peak_i, HighMap[i]-last_peak));
                    Flag[i] = 1
                    ZigZag[i] = last_peak - HighMap[i]
                    prev_peak = last_peak_i
                    last_peak = HighMap[i]
                    last_peak_i = i
                    searchMode = searchLawn
                    RegisterPeak(i, searchMode, last_peak)
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i]
                    last_peak_i = i
                    if prev_peak ~= nil then
                        core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i, ZigC)
                        out:setColor(prev_peak, ZagC)
                        DeleteLabels(prev_peak + 1, i)
                        -- TextBuff:set(i, HighMap[i], TextFormat(i-prev_peak, HighMap[i]-Peak[prev_peak]));
                        Flag[i] = 1
                        ZigZag[i] = Peak[prev_peak] - HighMap[i]
                    end
                    ReplaceLastPeak(i, searchMode, last_peak)
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    if last_peak > LowMap[i] then
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC)
                        out:setColor(last_peak_i, ZigC)
                        DeleteLabels(last_peak_i + 1, i)
                        -- TextBuff:set(i, LowMap[i], TextFormat(i-last_peak_i, last_peak-LowMap[i]));
                        Flag[i] = -1
                        ZigZag[i] = last_peak - LowMap[i]
                    else
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC)
                        out:setColor(last_peak_i, ZagC)
                        DeleteLabels(last_peak_i + 1, i)
                        -- TextBuff:set(i, LowMap[i], TextFormat(i-last_peak_i, last_peak-LowMap[i]));
                        Flag[i] = -1
                        ZigZag[i] = last_peak - LowMap[i]
                    end
                    prev_peak = last_peak_i
                    last_peak = LowMap[i]
                    last_peak_i = i
                    searchMode = searchPeak
                    RegisterPeak(i, searchMode, last_peak)
                end
            end
        end
    end
end

local Init = true
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())
    -- context:pixelsToPoints (instance.parameters.TextSize)
    if Init then
        context:createFont(1, "Arial", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
        Init = false
    end

    if NumberOfCycles ~= 0 then
        Text = "Number of Cycles : " .. NumberOfCycles

        i = 1
        width, height = context:measureText(1, Text, 0)
        context:drawText(
            1,
            Text,
            Label,
            -1,
            iX(context, width, 0, 1),
            iY(context, height, i, 0),
            iX(context, width, 0, 2),
            iY(context, height, i, 1),
            0
        )
    end

    if MaxSize ~= 0 then
        Text = "Max Size : " .. round(MaxSize, 1)

        i = 5
        width, height = context:measureText(1, Text, 0)
        context:drawText(
            1,
            Text,
            Label,
            -1,
            iX(context, width, 0, 1),
            iY(context, height, i, 0),
            iX(context, width, 0, 2),
            iY(context, height, i, 1),
            0
        )
    end

    if MinSize ~= 0 then
        Text = "Min Size : " .. round(MinSize, 1)

        i = 6
        width, height = context:measureText(1, Text, 0)
        context:drawText(
            1,
            Text,
            Label,
            -1,
            iX(context, width, 0, 1),
            iY(context, height, i, 0),
            iX(context, width, 0, 2),
            iY(context, height, i, 1),
            0
        )
    end

    if Avg ~= 0 then
        Text = "Average Cycle: " .. round(Avg, 1)

        i = 2
        width, height = context:measureText(1, Text, 0)
        context:drawText(
            1,
            Text,
            Label,
            -1,
            iX(context, width, 0, 1),
            iY(context, height, i, 0),
            iX(context, width, 0, 2),
            iY(context, height, i, 1),
            0
        )
    end

    if AvgUp ~= 0 then
        Text = "Average Up Cycle: " .. round(AvgUp, 1)

        i = 3
        width, height = context:measureText(1, Text, 0)
        context:drawText(
            1,
            Text,
            Label,
            -1,
            iX(context, width, 0, 1),
            iY(context, height, i, 0),
            iX(context, width, 0, 2),
            iY(context, height, i, 1),
            0
        )
    end

    if AvgDown ~= 0 then
        Text = "Average Down Cycle: " .. round(AvgDown, 1)

        i = 4
        width, height = context:measureText(1, Text, 0)
        context:drawText(
            1,
            Text,
            Label,
            -1,
            iX(context, width, 0, 1),
            iY(context, height, i, 0),
            iX(context, width, 0, 2),
            iY(context, height, i, 1),
            0
        )
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