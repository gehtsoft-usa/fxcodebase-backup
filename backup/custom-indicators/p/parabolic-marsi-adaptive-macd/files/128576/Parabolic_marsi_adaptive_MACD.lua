-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66031

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
indi_alerts.Version = "1.11";
indi_alerts.inverted_arrows = false;
local alert_stages = { 102 };

-- Indicator profile initialization routine
function Init()
    indicator:name("Parabolic marsi adaptive MACD")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("1. RSI Calculation")
    indicator.parameters:addInteger("RsiPeriod1", "Period", "", 14)
    indicator.parameters:addDouble("Speed1", "Speed", "", 1.2)

    indicator.parameters:addGroup("2. RSI Calculation")
    indicator.parameters:addInteger("RsiPeriod2", "Period", "", 34)
    indicator.parameters:addDouble("Speed2", "Speed", "", 0.8)

    indicator.parameters:addGroup("SAR Calculation")
    indicator.parameters:addDouble("AccStep", "Speed", "", 0.01)
    indicator.parameters:addDouble("AccLimit", "Speed", "", 0.1)

    indicator.parameters:addInteger("SignalPeriod", "Signal Period", "", 9);
    indicator.parameters:addString("SignalMethod", "Method", "", "Median");
    indicator.parameters:addStringAlternative("SignalMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SignalMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SignalMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SignalMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SignalMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SignalMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SignalMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SignalMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SignalMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SignalMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SignalMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SignalMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SignalMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SignalMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SignalMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SignalMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SignalMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SignalMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SignalMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SignalMethod", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("SignalMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SignalMethod", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("SignalMethod", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("SignalMethod", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("SignalMethod", "VAMA", "", "VAMA");
    
    indicator.parameters:addGroup("MACD Style")
    indicator.parameters:addColor("color11", "Up Trend  Up Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("color12", "Up Trend Down Color", "", core.rgb(0, 200, 0))
    indicator.parameters:addColor("color21", "Down Trend  Up Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("color22", "Down Trend Down Color", "", core.rgb(200, 0, 0))
    indicator.parameters:addColor("signal_color", "Signal Color", "", core.colors().Yellow)
    indicator.parameters:addInteger("signal_width", "Signal Width", "", 1, 1, 5)

    indicator.parameters:addGroup("SAR Style")
    indicator.parameters:addColor("color31", "Up Trend Color", "", core.rgb(0, 0, 255))
    indicator.parameters:addColor("color32", "Down Trend Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5)

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Cross with 0");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local RsiPeriod1, Price1, Speed1, RsiPrice1
local RsiPeriod2, Price2, Speed2, RsiPrice2
local first
local source = nil

local AccStep, AccLimit
local Raw = {}
local macdMi
local RSI = {}

local macd;
local signal;
local workMaRsi = {};
local slope;
local sarDn;
local sarUp;
local saraUp;
local saraDn;
local work = {};
local custom_ma;

function CreateRSI(period)
    rsi = {}
    rsi[0] = core.indicators:create("RSI", source.close, period)
    rsi[1] = core.indicators:create("RSI", source.open, period)
    rsi[2] = core.indicators:create("RSI", source.high, period)
    rsi[3] = core.indicators:create("RSI", source.low, period)
    rsi[4] = core.indicators:create("RSI", source.median, period)
    rsi[5] = core.indicators:create("RSI", source.typical, period)
    rsi[6] = core.indicators:create("RSI", source.weighted, period)
    return rsi;
end

-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);

    RsiPeriod1 = instance.parameters.RsiPeriod1
    Price1 = instance.parameters.Price1
    Speed1 = instance.parameters.Speed1
    RsiPrice1 = instance.parameters.RsiPrice1

    RsiPeriod2 = instance.parameters.RsiPeriod2
    Price2 = instance.parameters.Price2
    Speed2 = instance.parameters.Speed2
    RsiPrice2 = instance.parameters.RsiPrice2

    AccStep = instance.parameters.AccStep
    AccLimit = instance.parameters.AccLimit

    Period = instance.parameters.Period
    Method = instance.parameters.Method

    source = instance.source

    workMaRsi[0] = instance:addInternalStream(0, 0)
    workMaRsi[1] = instance:addInternalStream(0, 0)
    workMaRsi[2] = instance:addInternalStream(0, 0)
    workMaRsi[3] = instance:addInternalStream(0, 0)
    workMaRsi[4] = instance:addInternalStream(0, 0)
    workMaRsi[5] = instance:addInternalStream(0, 0)
    work[0] = instance:addInternalStream(0, 0)
    work[1] = instance:addInternalStream(0, 0)
    work[2] = instance:addInternalStream(0, 0)
    work[3] = instance:addInternalStream(0, 0)
    work[4] = instance:addInternalStream(0, 0)
    work[5] = instance:addInternalStream(0, 0)
    work[6] = instance:addInternalStream(0, 0)
    macdMi = instance:addInternalStream(0, 0);

    RSI[0] = CreateRSI(RsiPeriod1)
    RSI[1] = CreateRSI(RsiPeriod2)

    macd = instance:addStream("MACD" , core.Bar, "MACD","MACD",instance.parameters.color11,0);
    macd:setPrecision(math.max(2, instance.source:getPrecision()));
    signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.signal_color, 0);
    signal:setPrecision(math.max(2, instance.source:getPrecision()));
    signal:setWidth(instance.parameters.signal_width);
    sarDn = instance:addStream("sarDn", core.Dot, name .. ".sarDn", "sarDn", instance.parameters.color32, 0);
    sarDn:setPrecision(math.max(2, instance.source:getPrecision()));
    sarDn:setWidth(instance.parameters.width3);
    sarUp = instance:addStream("sarUp", core.Dot, name .. ".sarUp", "sarUp", instance.parameters.color31, 0);
    sarUp:setPrecision(math.max(2, instance.source:getPrecision()));
    sarUp:setWidth(instance.parameters.width3);
    saraUp = instance:addStream("saraUp", core.Dot, name .. ".saraUp", "saraUp", instance.parameters.color31, 0);
    saraUp:setPrecision(math.max(2, instance.source:getPrecision()));
    saraUp:setWidth(instance.parameters.width3 + 1);
    saraDn = instance:addStream("saraDn", core.Dot, name .. ".saraDn", "saraDn", instance.parameters.color32, 0);
    saraDn:setPrecision(math.max(2, instance.source:getPrecision()));
    saraDn:setWidth(instance.parameters.width3 + 1);

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator")

    custom_ma = core.indicators:create("AVERAGES", macd, instance.parameters.SignalMethod, instance.parameters.SignalPeriod);
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

function Update(period, mode)
    custom_ma:update(mode);

    local i = period;
    local macdHi = iMaRsi(math.floor(source.high[i]), 0, Speed1, i, 0) - iMaRsi(math.floor(source.high[i]), 1, Speed2, i, 1);
    local macdLo = iMaRsi(math.floor(source.low[i]), 0, Speed1, i, 2) - iMaRsi(math.floor(source.low[i]), 1, Speed2, i, 3);
    macdMi[period] = (macdHi + macdLo) * 0.5;
    macd[i] = iMaRsi(math.floor(macdMi[period]), 0, Speed1, i, 4) - iMaRsi(math.floor(macdMi[period]), 1, Speed2, i, 5);
    signal[i] = custom_ma.DATA[i];
    
    if macd[period] > 0 then
        if macd[period]>  macd[period-1] then
            macd:setColor(period, instance.parameters.color11);
        else
            macd:setColor(period, instance.parameters.color12);
        end
    else
        if macd[period]>  macd[period-1] then
            macd:setColor(period, instance.parameters.color21);
        else
            macd:setColor(period, instance.parameters.color22);
        end
    end
    
    local sarClose, sarPosition, sarChange = iParabolic(macd[i], macd[i], AccStep, AccLimit, i);
    if (sarPosition==1) then
        sarUp[i] = sarClose;
        sarDn[i]  = nil;
    else
        sarDn[i] = sarClose;
        sarUp[i]  = nil;
    end
    saraUp[i] = nil;
    saraDn[i] = nil;
    if (sarChange ~= 0) then
        if (sarPosition==1) then
            saraUp[i] = sarClose;
        else
            saraDn[i] = sarClose;
        end
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function GetPrice(price)
    if price == 6 then
        return source.weighted;
    elseif price == 1 then
        return source.open;
    elseif price == 2 then
        return source.high;
    elseif price == 3 then
        return source.low;
    elseif price == 4 then
        return source.median;
    elseif price == 5 then
        return source.typical;
    end
    return source.close;
end

function iMaRsi(price, rsi_period, speed, period, Index, mode)
    rsi = RSI[rsi_period][price];
    if rsi == null then
        rsi = RSI[rsi_period][0];
    end
    rsi:update(mode)

    local tprice = GetPrice(price)[period];
    if period > 0 and workMaRsi[Index]:hasData(period - 1) then
        workMaRsi[Index][period] = workMaRsi[Index][period - 1] 
            + (speed * math.abs(rsi.DATA[period] / 100.0 - 0.5)) * (tprice - workMaRsi[Index][period - 1]);
    else
        workMaRsi[Index][period] = tprice;
    end

    return workMaRsi[Index][period]
end

local _high = 0
local _low = 1
local _ohigh = 2
local _olow = 3
local _open = 4
local _position = 5
local _af = 6

function iParabolic(high, low, step, limit, i)
    local pClose, pPosition, pChange;
    pChange = 0;
    work[_ohigh][i] = high;
    work[_olow][i] = low;
    if (i < 1) then
        work[_high][i] = high;
        work[_low][i] = low;
        work[_open][i] = high;
        work[_position][i] = -1;
        return;
    end
    work[_open][i]     = work[_open][i-1];
    work[_af][i]       = work[_af][i-1];
    work[_position][i] = work[_position][i-1];
    work[_high][i]     = math.max(work[_high][i-1], high);
    work[_low][i]      = math.min(work[_low][i-1], low);
    if (work[_position][i] == 1) then
        if (low <= work[_open][i]) then
            work[_position][i] = -1;
            pChange = -1;
            pClose  = work[_high][i];
            work[_high][i] = high;
            work[_low][i]  = low;
            work[_af][i]   = step;
            work[_open][i] = pClose + work[_af][i] * (work[_low][i] - pClose);
            if (work[_open][i] < work[_ohigh][i]) then
                work[_open][i] = work[_ohigh][i];
            end
            if (work[_open][i] < work[_ohigh][i-1]) then
                work[_open][i] = work[_ohigh][i-1];
            end
        else
            pClose = work[_open][i];
            if (work[_high][i] > work[_high][i-1] and work[_af][i] < limit) then
                work[_af][i] = math.min(work[_af][i] + step, limit);
            end
            work[_open][i] = pClose + work[_af][i] * (work[_high][i] - pClose);
            if (work[_open][i]>work[_olow][i]) then
                work[_open][i] = work[_olow][i];
            end
            if (work[_open][i]>work[_olow][i-1]) then
                work[_open][i] = work[_olow][i-1];
            end
        end
    else
        if (high>=work[_open][i]) then
            work[_position][i] = 1;
            pChange = 1;
            pClose  = work[_low][i];
            work[_low][i]  = low;
            work[_high][i] = high;
            work[_af][i]   = step;
            work[_open][i] = pClose + work[_af][i]*(work[_high][i]-pClose);
            if (work[_open][i]>work[_olow][i]) then
                work[_open][i] = work[_olow][i];
            end
            if (work[_open][i]>work[_olow][i-1]) then
                work[_open][i] = work[_olow][i-1];
            end
        else
            pClose = work[_open][i];
            if (work[_low][i]<work[_low][i-1] and work[_af][i]<limit) then
                work[_af][i] = math.min(work[_af][i]+step,limit);
            end
            work[_open][i] = pClose + work[_af][i]*(work[_low][i]-pClose);
            if (work[_open][i]<work[_ohigh][i]) then
                work[_open][i] = work[_ohigh][i];
            end
            if (work[_open][i]<work[_ohigh][i-1]) then
                work[_open][i] = work[_ohigh][i-1];
            end
        end
    end
    pPosition = work[_position][i];
    return pClose, pPosition, pChange;
end

function UpCondition(period)
    return sarUp:hasData(period) and macd[period] > 0;
end

function DownCondition(period)
    return sarDn:hasData(period) and macd[period] < 0;
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if alert.id == 1 then
        if UpCondition(period) and not UpCondition(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Bull pattern", source.high[period], historical_period);
        elseif DownCondition(period) and not DownCondition(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Bear pattern", source.low[period], historical_period);
        end
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
        alert.Stage = alert_stages[i];
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
    alert.Alert:setPrecision(math.max(2, instance.source:getPrecision()));
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
