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
local Modules = {};
function Init()
    indicator:name("2 bar supply and demand");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("OutputSD", "Output supply/demand values", "", false);
    indicator.parameters:addBoolean("FillArea", "Fill area", "", false);

    local colors = core.colors();
    indicator.parameters:addColor("FreshDemandColor", "Color of the fresh demand levels", "", colors.Red);
    indicator.parameters:addColor("FreshSupplyColor", "Color of the fresh supply levels", "", colors.Green)
    indicator.parameters:addColor("RetestedDemandColor", "Color of the retested demand levels", "", colors.Pink);
    indicator.parameters:addColor("RetestedSupplyColor", "Color of the retested supply levels", "", colors.Lime);
    indicator.parameters:addColor("DemandBarsColor", "Color for demand bars", "", colors.Red);
    indicator.parameters:addColor("SupplyBarsColor", "Color for supply bars", "", colors.Green);

    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addGroup("Alerts");
    signaler:Init(indicator.parameters);
end

local first;
local source = nil;
local OutputSD;
local FillArea;
local FreshDemandColor;
local FreshSupplyColor;
local RetestedDemandColor;
local RetestedSupplyColor;
local DemandBarsColor;
local SupplyBarsColor;
local out_supply;
local out_supply_wide;
local out_demand;
local out_demand_wide;
local candles;
local width;
local style;

function CandleStreams(id)
    local candles = {};
    candles.open = instance:addStream(id .. "_open", core.Line, "open", "open", core.rgb(0, 0, 0), 0);
    candles.close = instance:addStream(id .. "_close", core.Line, "close", "close", core.rgb(0, 0, 0), 0);
    candles.high = instance:addStream(id .. "_high", core.Line, "high", "high", core.rgb(0, 0, 0), 0);
    candles.low = instance:addStream(id .. "_low", core.Line, "low", "low", core.rgb(0, 0, 0), 0);
    instance:createCandleGroup(id, id, candles.open, candles.high, candles.low, candles.close);
    function candles:Set(index, open, high, low, close, color)
        self.open[index] = open;
        self.high[index] = high;
        self.low[index] = low;
        self.close[index] = close;
        self.open:setColor(index, color);
    end
    return candles;
end

function SDLevelStreams(id, color)
    local level = {};
    level.high = instance:addStream(id .. "_high", core.Line, "high", "high", color, 0);
    level.low = instance:addStream(id .. "_low", core.Line, "low", "low", color, 0);
    level.high:setWidth(width);
    level.high:setStyle(style);
    level.low:setWidth(width);
    level.low:setStyle(style);
    function level:Set(pos, low, high)
        self.high[pos] = high;
        self.low[pos] = low;
    end
    return level;
end

function Prepare(nameOnly)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end

    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    width = instance.parameters.width;
    style = instance.parameters.style;
    OutputSD = instance.parameters.OutputSD;
    FillArea = instance.parameters.FillArea;
    FreshDemandColor = instance.parameters.FreshDemandColor;
    FreshSupplyColor = instance.parameters.FreshSupplyColor;
    RetestedDemandColor = instance.parameters.RetestedDemandColor;
    RetestedSupplyColor = instance.parameters.RetestedSupplyColor;
    DemandBarsColor = instance.parameters.DemandBarsColor;
    SupplyBarsColor = instance.parameters.SupplyBarsColor;
    if OutputSD then
        out_supply = SDLevelStreams("supply", SupplyBarsColor);
        out_supply_wide = SDLevelStreams("supply_wide", SupplyBarsColor);
        out_demand = SDLevelStreams("demand", DemandBarsColor);
        out_demand_wide = SDLevelStreams("demand_wide", DemandBarsColor);
    end
    candles = CandleStreams("candles");

    instance:ownerDrawn(true);
end

local levels = {};

local RETESTED_SUPPLY_PEN = 1;
local RETESTED_SUPPLY_BRUSH = 2;
local RETESTED_DEMAND_PEN = 3;
local RETESTED_DEMAND_BRUSH = 4;
local SUPPLY_PEN = 5;
local SUPPLY_BRUSH = 6;
local DEMAND_PEN = 7;
local DEMAND_BRUSH = 8;

function SDLevel(low, high, isSupply, date, dateEnd)
    local level = {};
    level.low = low;
    level.high = high;
    level.isSupply = isSupply;
    level.tested = false;
    level.date = date;
    level.dateEnd = dateEnd;
    level.lastDate = dateEnd;
    function level:Test(period)
        if self.tested or self.dateEnd == source:date(period) then
            return;
        end

        if (not self.isSupply and source.low[period] <= self.high) or (self.isSupply and source.high[period] >= self.low) then
            self.tested = true;
            self.lastDate = source:date(period);
        end
    end

    function level:Draw(context)
        local pen;
        local brush;
        if self.tested then
            if self.isSupply then
                pen = RETESTED_SUPPLY_PEN;
                brush = RETESTED_SUPPLY_BRUSH;
            else
                pen = RETESTED_DEMAND_PEN;
                brush = RETESTED_DEMAND_BRUSH;
            end
        else
            if self.isSupply then
                pen = SUPPLY_PEN;
                brush = SUPPLY_BRUSH;
            else
                pen = DEMAND_PEN;
                brush = DEMAND_BRUSH;
            end
        end
        local x1 = context:positionOfDate(self.date);
        local x2 = context:positionOfDate(self.lastDate);
        local _, y1 = context:pointOfPrice(self.low);
        local _, y2 = context:pointOfPrice(self.high);
        if FillArea then
            context:drawRectangle(pen, brush, x1, y1, x2, y2);
        else
            context:drawLine(pen, x1, y1, x2, y1);
            context:drawLine(pen, x1, y2, x2, y2);
        end
    end
    return level;
end

local init = false;

function Draw(stage, context)
    if stage ~= 0 then
        return;
    end
    if not init then
        init = true;
        context:createPen(RETESTED_SUPPLY_PEN, context:convertPenStyle(style), width, RetestedSupplyColor);
        context:createPen(RETESTED_DEMAND_PEN, context:convertPenStyle(style), width, RetestedDemandColor);
        context:createPen(SUPPLY_PEN, context:convertPenStyle(style), width, FreshSupplyColor);
        context:createPen(DEMAND_PEN, context:convertPenStyle(style), width, FreshDemandColor);
        context:createSolidBrush(RETESTED_SUPPLY_BRUSH, RetestedSupplyColor);
        context:createSolidBrush(RETESTED_DEMAND_BRUSH, RetestedDemandColor);
        context:createSolidBrush(SUPPLY_BRUSH, FreshSupplyColor);
        context:createSolidBrush(DEMAND_BRUSH, FreshDemandColor);
    end
    for _, level in ipairs(levels) do
        level:Draw(context);
    end
end

function Update(period, mode)
    if (period < first) then
        return;
    end
    
    local rangePrev = source.high[period - 1] - source.low[period - 1];
    local prev50Pr = source.high[period - 1] - rangePrev / 2;
    local rangeCurrent = source.high[period] - source.low[period];
    local curr50Pr = source.high[period] - rangeCurrent / 2;

    local supplyRule1 = source.close[period - 1] < prev50Pr;
    local supplyRule2 = source.high[period] <= prev50Pr;
    local supplyRule3 = rangeCurrent > rangePrev;
    local supplyRule4 = source.close[period] < curr50Pr; 
    if supplyRule1 and supplyRule2 and supplyRule3 and supplyRule4 then
        levels[#levels + 1] = SDLevel(source.low[period - 1], source.high[period], true, source:date(period - 1), source:date(period));
        levels[#levels + 1] = SDLevel(source.low[period - 1], source.high[period - 1], true, source:date(period - 1), source:date(period));

        if (OutputSD) then
            out_supply:Set(period, source.low[period - 1], source.high[period]);
            out_supply_wide:Set(period, source.low[period - 1], source.high[period - 1]);
        end
        if period == source:size() - 1 then
            signaler:Signal("Supply bars on " .. source:instrument() .. ", " .. source:barSize());
        end
        candles:Set(period, source.open[period], source.high[period], source.low[period], source.close[period], SupplyBarsColor);
        candles:Set(period - 1, source.open[period - 1], source.high[period - 1], source.low[period - 1], source.close[period - 1], SupplyBarsColor);
    end

    local demandRule1 = source.close[period - 1] > prev50Pr;
    local demandRule2 = source.low[period] >= prev50Pr;
    local demandRule3 = rangeCurrent > rangePrev;
    local demandRule4 = source.close[period] > curr50Pr;
    if demandRule1 and demandRule2 and demandRule3 and demandRule4 then
        levels[#levels + 1] = SDLevel(source.low[period], source.high[period - 1], false, source:date(period - 1), source:date(period));
        levels[#levels + 1] = SDLevel(source.low[period - 1], source.high[period - 1], false, source:date(period - 1), source:date(period));

        if (OutputSD) then
            out_demand:Set(period, source.low[period], source.high[period - 1]);
            out_demand_wide:Set(period, source.low[period - 1], source.high[period - 1]);
        end
        if period == source:size() - 1 then
            signaler:Signal("Demand bars on " .. source:instrument() .. ", " .. source:barSize());
        end
        candles:Set(period, source.open[period], source.high[period], source.low[period], source.close[period], DemandBarsColor);
        candles:Set(period - 1, source.open[period - 1], source.high[period - 1], source.low[period - 1], source.close[period - 1], DemandBarsColor);
    end

    for _, level in ipairs(levels) do
        level:Test(period);
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end 
end

function ReleaseInstance()
    for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end
end

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.5";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
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
    if cookie == self._advanced_alert_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._advanced_alert_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
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
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(message, source)
    if source == nil then
        if instance.source ~= nil then
            source = instance.source;
        elseif instance.bid ~= nil then
            source = instance.bid;
        else
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
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
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", false);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", false);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram message or Channel post", false);
    parameters:addString("advanced_alert_key", "Advanced Alert Key", "You can get it via @profit_robots_bot Telegram bot", "");
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);