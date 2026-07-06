-- Id: 23599
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67253

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local indi_alerts = {};

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
    assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function Init()
    indicator:name("TDI Red Green Alerts mod")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 13);
    indicator.parameters:addInteger("Volatility_Bands_Period", "Volatility_Bands_Period", "", 34);
    indicator.parameters:addInteger("RSI_Price_Line_Period", "RSI_Price_Line_Period", "", 2);
    AddAverages("RSI_Price_Type", "RSI_Price_Type", "MVA");
    indicator.parameters:addInteger("Trade_Signal_Line_Period", "Trade_Signal_Line_Period", "", 7);
    AddAverages("Trade_Signal_Type", "Trade_Signal_Type", "MVA");
    indicator.parameters:addBoolean("ShowVolatilityBands", "ShowVolatilityBands", "", true);
    indicator.parameters:addBoolean("ShowMarketBaseLine", "ShowMarketBaseLine", "", false);
    indicator.parameters:addBoolean("ShowRsiPriceLine", "ShowRsiPriceLine", "", true);
    indicator.parameters:addBoolean("ShowTradeSignalLine", "ShowTradeSignalLine", "", true);

    local colour = core.colors();
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VB_high_line", "VB high line color", "", colour.DodgerBlue);
    indicator.parameters:addColor("Market_Base_Line", "Market Base Line color", "", colour.Yellow);
    indicator.parameters:addColor("VB_low_line", "VB low line", "", colour.DodgerBlue)
    
    indicator.parameters:addColor("Rsi_Price_line", "Rsi Price line", "", colour.LimeGreen)
    indicator.parameters:addColor("Trade_Signal_line", "Trade Signal line", "", colour.Red)

    indicator.parameters:addGroup("Alert");
    indicator.parameters:addBoolean("RsiTradeSignalLineCrossAlerts", "Alerts", "", true);
    indicator.parameters:addBoolean("RsiMarketBaseLineCrossAlerts", "Alerts", "", false);
    indicator.parameters:addBoolean("RsiVolatilityBandsCrossAlerts", "Alerts", "", true);
    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Rsi/Trade Signal Line");
    indi_alerts:AddAlert("Rsi/Market Base Line");
    indi_alerts:AddAlert("Rsi/Volatility Up Zone");
    indi_alerts:AddAlert("Rsi/Volatility Down Zone");
end

local source = nil

local RSI_Period;
local Volatility_Bands_Period;
local RSI_Price_Line_Period;
local RSI_Price_Type;
local Trade_Signal_Line_Period;
local Trade_Signal_Type;
local ShowVolatilityBands;
local ShowMarketBaseLine;
local ShowRsiPriceLine;
local ShowTradeSignalLine;
local VB_high_line;
local Market_Base_Line;
local VB_low_line;
local Rsi_Price_line;
local Trade_Signal_line;
local RsiTradeSignalLineCrossAlerts;
local RsiMarketBaseLineCrossAlerts;
local RsiVolatilityBandsCrossAlerts;

local RSIBuf;
local UpZone;
local MdZone;
local DnZone;
local MaBuf;
local MbBuf;
function Prepare(nameOnly)
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    source = instance.source;
    RSI_Period = instance.parameters.RSI_Period;
    Volatility_Bands_Period = instance.parameters.Volatility_Bands_Period;
    RSI_Price_Line_Period = instance.parameters.RSI_Price_Line_Period;
    RSI_Price_Type = instance.parameters.RSI_Price_Type;
    Trade_Signal_Line_Period = instance.parameters.Trade_Signal_Line_Period;
    Trade_Signal_Type = instance.parameters.Trade_Signal_Type;
    ShowVolatilityBands = instance.parameters.ShowVolatilityBands;
    ShowMarketBaseLine = instance.parameters.ShowMarketBaseLine;
    ShowRsiPriceLine = instance.parameters.ShowRsiPriceLine;
    ShowTradeSignalLine = instance.parameters.ShowTradeSignalLine;
    VB_high_line = instance.parameters.VB_high_line;
    Market_Base_Line = instance.parameters.Market_Base_Line;
    VB_low_line = instance.parameters.VB_low_line;
    Rsi_Price_line = instance.parameters.Rsi_Price_line;
    Trade_Signal_line = instance.parameters.Trade_Signal_line;
    RsiTradeSignalLineCrossAlerts = instance.parameters.RsiTradeSignalLineCrossAlerts;
    RsiMarketBaseLineCrossAlerts = instance.parameters.RsiMarketBaseLineCrossAlerts;
    RsiVolatilityBandsCrossAlerts = instance.parameters.RsiVolatilityBandsCrossAlerts;

    RSIBuf = core.indicators:create("RSI", source, RSI_Period);
    Ma = CreateAverates(RSI_Price_Type, source, RSI_Price_Line_Period);
    Mb = CreateAverates(Trade_Signal_Type, source, Trade_Signal_Line_Period);
    if (ShowVolatilityBands) then
        UpZone = instance:addStream("UpZone", core.Line, "UpZone", "Vb high", VB_high_line, 0);
        DnZone = instance:addStream("DnZone", core.Line, "DnZone", "Vb low", VB_low_line, 0);
    else
        UpZone = instance:addInternalStream(0, 0);
        DnZone = instance:addInternalStream(0, 0);
    end
    if ShowMarketBaseLine then
        MdZone = instance:addStream("MdZone", core.Line, "MdZone", "MarketBaseLine", Market_Base_Line, 0);
    else
        MdZone = instance:addInternalStream(0, 0);
    end
    if ShowRsiPriceLine then
        MaBuf = instance:addStream("MaBuf", core.Line, "MaBuf", "RsiPriceLine", Rsi_Price_line, 0);
    else
        MaBuf = instance:addInternalStream(0, 0);
    end
    if ShowTradeSignalLine then
        MbBuf = instance:addStream("MbBuf", core.Line, "MbBuf", "TradeSignalLine", Trade_Signal_line, 0);
    else
        MbBuf = instance:addInternalStream(0, 0);
    end
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

local lastrsitsalert;
local lastrsimbalert;
local lastrsivbhalert;
local lastrsivblalert;
-- Indicator calculation routine
function Update(period, mode)
    RSIBuf:update(mode);
    Ma:update(mode);
    Mb:update(mode);
    MaBuf[period] = Ma.DATA[period];
    MbBuf[period] = Mb.DATA[period];
    if period <= Volatility_Bands_Period or not RSIBuf.DATA:hasData(period - Volatility_Bands_Period) then
        return;
    end
    local MA = mathex.sum(RSIBuf.DATA, period - Volatility_Bands_Period, period);
    UpZone[period] = MA + (1.6185 * mathex.stdev(RSIBuf.DATA, period - Volatility_Bands_Period, period));
    DnZone[period] = MA - (1.6185 * mathex.stdev(RSIBuf.DATA, period - Volatility_Bands_Period, period));
    MdZone[period] = (UpZone[period] + DnZone[period]) / 2.0;

    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if alert.id == 1 then
        if MaBuf[period] > MbBuf[period] and MaBuf[period - 1] <= MbBuf[period - 1] then
            alert:UpAlert(source, period, alert.Label .. ". UP -> RSI TradeSignal", source.high[period], historical_period);
        elseif MaBuf[period] < MbBuf[period] and MaBuf[period - 1] >= MbBuf[period - 1] then
            alert:DownAlert(source, period, alert.Label .. ". DN -> RSI TradeSignal", source.low[period], historical_period);
        end
    end
    if alert.id == 2 then
        if MaBuf[period] > MdZone[period] and MaBuf[period - 1] <= MdZone[period - 1] then
            alert:UpAlert(source, period, alert.Label .. ". UP -> RSI MarketBaseLine", source.high[period], historical_period);
        elseif MaBuf[period] < MdZone[period] and MaBuf[period - 1] >= MdZone[period - 1] then
            alert:DownAlert(source, period, alert.Label .. ". DN -> RSI MarketBaseLine", source.low[period], historical_period);
        end
    end
    if alert.id == 3 then
        if MaBuf[period] > UpZone[period] and MaBuf[period - 1] <= UpZone[period - 1] then
            alert:UpAlert(source, period, alert.Label .. ". UP -> RSI Vb high", source.high[period], historical_period);
        elseif MaBuf[period] < UpZone[period] and MaBuf[period - 1] >= UpZone[period - 1] then
            alert:DownAlert(source, period, alert.Label .. ". DN -> RSI Vb low", source.low[period], historical_period);
        end
    end
    if alert.id == 4 then
        if MaBuf[period] > DnZone[period] and MaBuf[period - 1] <= DnZone[period - 1] then
            alert:UpAlert(source, period, alert.Label .. ". UP -> RSI Vb low", source.high[period], historical_period);
        elseif MaBuf[period] < DnZone[period] and MaBuf[period - 1] >= DnZone[period - 1] then
            alert:DownAlert(source, period, alert.Label .. ". DN -> RSI Vb low", source.low[period], historical_period);
        end
    end
    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

indi_alerts.Version = "1.5";
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts.total_alerts = 4;
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
