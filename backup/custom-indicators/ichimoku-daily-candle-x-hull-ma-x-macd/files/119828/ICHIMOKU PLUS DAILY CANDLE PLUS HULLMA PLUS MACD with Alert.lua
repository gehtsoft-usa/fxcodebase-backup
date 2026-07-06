-- Id: 21651
-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 21401
-- Id: 21486

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

function Init()
    indicator:name("Ichimoku + Daily-Candle_X + HULL-MA_X + MacD")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addInteger("keh", "Double HullMA", "", 14);
    indicator.parameters:addDouble("dt", "Decision Threshold (0.001)", "", 0.001);
    indicator.parameters:addInteger("conversionPeriods", "Conversion Line Periods", "", 9);
    indicator.parameters:addInteger("basePeriods", "Base Line Periods", "", 26);
    indicator.parameters:addInteger("laggingSpan2Periods", "Lagging Span 2 Periods", "", 52);
    indicator.parameters:addInteger("displacement", "Displacement", "", 26);
    indicator.parameters:addInteger("MACD_Length", "MACD Length", "", 9);
    indicator.parameters:addInteger("MACD_fastLength", "MACD Fast Length", "", 12);
    indicator.parameters:addInteger("MACD_slowLength", "MACD Slow Length", "", 26);
    
    indicator.parameters:addColor("n1_color", "N1 Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("n1_width", "N1 Line width","", 1, 1, 5);
    indicator.parameters:addInteger("n1_style", "N1 Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("n1_style", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("n2_color", "N2 Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("n2_width", "N2 Line width","", 1, 1, 5);
    indicator.parameters:addInteger("n2_style", "N2 Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("n2_style", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addColor("c_color", "C Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("c_width", "C Line width","", 1, 1, 5);
    indicator.parameters:addInteger("c_style", "C Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("c_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addString("Live", "Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live"); 
    signaler:Init(indicator.parameters);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local source = nil
local keh;
local wma_1;
local wma_2;
local diff;
local diff1;
local wma_3;
local wma_4;
local N1;
local N2;
local C;
local source_d1;
local Live;

local dt;
local conversionPeriods;
local basePeriods;
local laggingSpan2Periods;
local displacement;
local MACD_Length;
local MACD_fastLength;
local MACD_slowLength;
local macd;

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name()
    instance:name(name)

    if (nameOnly) then
        return
    end
	
	Live = instance.parameters.Live;

    signaler:Prepare(nameOnly);

    keh = instance.parameters.keh;
    dt = instance.parameters.dt;
    conversionPeriods = instance.parameters.conversionPeriods;
    basePeriods = instance.parameters.basePeriods;
    laggingSpan2Periods = instance.parameters.laggingSpan2Periods;
    displacement = instance.parameters.displacement;
    MACD_Length = instance.parameters.MACD_Length;
    MACD_fastLength = instance.parameters.MACD_fastLength;
    MACD_slowLength = instance.parameters.MACD_slowLength;

   -- assert(core.indicators:findIndicator("ICHIMOKU PLUS DAILY CANDLE PLUS HULLMA PLUS MACD") ~= nil, "Please, download and install ICHIMOKU PLUS DAILY CANDLE PLUS HULLMA PLUS MACD indicator");
    macd = core.indicators:create("MACD", instance.source, MACD_fastLength, MACD_slowLength, MACD_Length);
    
    wma_1 = core.indicators:create("LWMA", instance.source, math.floor(keh / 2 + 0.5));
    wma_2 = core.indicators:create("LWMA", instance.source, keh);
    diff = instance:addInternalStream(0, 0);
    diff1 = instance:addInternalStream(0, 0);
    local sqn = math.floor(math.sqrt(keh) + 0.5);
    wma_3 = core.indicators:create("LWMA", diff, sqn);
    wma_4 = core.indicators:create("LWMA", diff1, sqn);
    source_d1 = core.host:execute("getSyncHistory", instance.source:instrument(), "D1", instance.source:isBid(), 300, 100, 101);
    
    N1 = instance:addStream("N1", core.Line, "N1", "N1", instance.parameters.n1_color, 0);
    N1:setPrecision(math.max(2, instance.source:getPrecision()));
    N1:setWidth(instance.parameters.n1_width);
    N1:setStyle(instance.parameters.n1_style);
    N2 = instance:addStream("N2", core.Line, "N2", "N2",instance.parameters.n2_color, 0);
    N2:setPrecision(math.max(2, instance.source:getPrecision()));
    N2:setWidth(instance.parameters.n2_width);
    N2:setStyle(instance.parameters.n2_style);
    C = instance:addStream("C", core.Line, "C", "C", instance.parameters.c_color, 0);
    C:setWidth(instance.parameters.c_width);
    C:setStyle(instance.parameters.c_style);
    C:setPrecision(6);
    core.host:execute("attachOuputToChart", "N1");
    core.host:execute("attachOuputToChart", "N2");
end

local loading = true;

function donchian(period, len)
    local lowest = mathex.min(instance.source.low, period - len, period);
    local highest = mathex.max(instance.source.high, period - len, period);
    return (lowest + highest) / 2;
end

local last_serial;
local last_signal;
-- Indicator calculation routine
function Update(period, mode)
    wma_1:update(core.UpdateLast);
    wma_2:update(core.UpdateLast);
    macd:update(core.UpdateLast);
    if not wma_1.DATA:hasData(period) or not wma_2.DATA:hasData(period) or loading then
        return;
    end

    local n2ma = 2 * wma_1.DATA[period];
    local nma = wma_2.DATA[period];
    diff[period] = n2ma - nma;
    diff1[period] = diff[period - 1];
    wma_3:update(core.UpdateLast);
    wma_4:update(core.UpdateLast);
    if not wma_3.DATA:hasData(period) or not wma_4.DATA:hasData(period) then
        return;
    end
    N1[period] = wma_3.DATA[period];
    N2[period] = wma_4.DATA[period];
    C[period] = (source_d1[NOW] - source_d1[NOW - 1]) / source_d1[NOW - 1];

    if not macd.MACD:hasData(period) or not macd.SIGNAL:hasData(period)
        or period < conversionPeriods or period < basePeriods or period < laggingSpan2Periods
        or not N1:hasData(period) or not N2:hasData(period)
    then
        return;
    end
    local confidence = C[period];
    local conversionLine = donchian(period, conversionPeriods);
    local baseLine = donchian(period, basePeriods);
    local leadLine1 = (conversionLine + baseLine) / 2;
    local leadLine2 = donchian(period, laggingSpan2Periods);
    local LS = instance.source.close[period];
    local MACD = macd.MACD[period];
    local aMACD = macd.SIGNAL[period];

    local is_last_bar = false;
    if Live ~= "Live" then
        period = period - 1;
        local serial = instance.source:serial(period);
        is_last_bar = period == instance.source:size() - 1 and last_serial ~= serial;
        last_serial = serial;
    else
        is_last_bar = period == instance.source:size() - 1;
    end

    if is_last_bar then
        if N1[period] > N2[period] 
            and confidence > dt
            and LS > N2[period] 
            and leadLine1 > leadLine2
            and instance.source.open[period] < LS
            and MACD > aMACD
            and last_signal ~= "Buy"
        then
            last_signal = "Buy";
            core.host:trace(last_signal);
            signaler:Signal("Buy", instance.source);
        end
        if N1[period] < N2[period] 
            and confidence < dt
            and LS < N2[period] 
            and leadLine1 < leadLine2
            and instance.source.open[period] > LS
            and MACD < aMACD
            and last_signal ~= "Sell"
        then
            last_signal = "Sell";
            core.host:trace(last_signal);
            signaler:Signal("Sell", instance.source);
        end
    end
end

function AsyncOperationFinished(cookie)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.1.6";

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