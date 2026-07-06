
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69991

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

local posi;
local indi_alerts = {};
indi_alerts.Version = "2.2";
indi_alerts.inverted_arrows = false;
local alerts = 
{ 
    {
        Stage = 2,
        UpCondition = function (period)
            if period == 0 then
                return false;
            end
            return core.crossesOver(posi, 0, period);
        end,
        DownCondition = function (period)
            if period == 0 then
                return false;
            end
            return core.crossesUnder(posi, 0, period);
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
                win32.formatNumber(source.close[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "Alert Name"
    }
};

function AddStyle(i)
    indicator.parameters:addColor("pl_color" .. i, "PL " .. i .. " Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("pl_width" .. i, "PL " .. i .. " Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("pl_style" .. i, "PL " .. i .. " Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("pl_style" .. i, core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("ph_color" .. i, "PH " .. i .. " Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("ph_width" .. i, "PH " .. i .. " Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ph_style" .. i, "PH " .. i .. " Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ph_style" .. i, core.FLAG_LINE_STYLE);
end

function Init()
    indicator:name("SILA Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("sensup", "Uptrend-sensivity", "", 5, -8, 8);
    indicator.parameters:addInteger("sensdn", "Downtrend-sensivity", "", 5, -8, 8);
    indicator.parameters:addBoolean("usewow", "Use trend-indicator WOW?", "", true)
    indicator.parameters:addBoolean("usebma", "Use trend-indicator BestMA?", "", true)
    indicator.parameters:addBoolean("usebc", "Use trend-indicator BarColor?", "", true)
    indicator.parameters:addBoolean("usest", "Use trend-indicator SuperTrend?", "", true)
    indicator.parameters:addBoolean("usedi", "Use trend-indicator DI?", "", true)
    indicator.parameters:addBoolean("usetts", "Use trend-indicator TTS?", "", true)
    indicator.parameters:addBoolean("usersi", "Use trend-indicator RSI?", "", true)
    indicator.parameters:addBoolean("usewto", "Use trend-indicator WTO?", "", true)
    indicator.parameters:addInteger("dist", "Distance SILA-lines", "", 100, 0, 100);
    indicator.parameters:addBoolean("usetl", "Need SILA-lines?", "", true)
    indicator.parameters:addBoolean("usemon", "Need money?", "", true)
    AddStyle(1);
    AddStyle(2);
    AddStyle(3);
    AddStyle(4);
    AddStyle(5);
    AddStyle(6);
    AddStyle(7);
    AddStyle(8);

    indi_alerts:AddParameters(indicator.parameters);
    for i,alert in ipairs(alerts) do
        indi_alerts:AddAlert(alert.Name);
    end
end

local source;
local sensup, sensdn, usewow, usebma, usebc, usest, usedi, usetts, usersi, usewto, dist, usetl, usemon
local trend1, trend2, WOWtrend, SMAOpen, SMAClose, BMAtrend, BARtrend, color, TrendUp, atr3, TrendDown, SUPtrend, DItrend;
local atr1, avgTR, TTStrend, ret, rsi, RSItrend, esa, d_source, d, ci, tci, WTOtrend, trends, pricehi, pricelo;
local pl = {};
local ph = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);
    sensup = instance.parameters.sensup;
    sensdn = instance.parameters.sensdn;
    usewow = instance.parameters.usewow;
    usebma = instance.parameters.usebma;
    usebc = instance.parameters.usebc;
    usest = instance.parameters.usest;
    usedi = instance.parameters.usedi;
    usetts = instance.parameters.usetts;
    usersi = instance.parameters.usersi;
    usewto = instance.parameters.usewto;
    dist = instance.parameters.dist;
    usetl = instance.parameters.usetl;
    usemon = instance.parameters.usemon;
    if usewow then
        trend1 = instance:addInternalStream(source:first() + 30, 0);
        trend2 = instance:addInternalStream(source:first() + 30, 0);
        WOWtrend = instance:addInternalStream(source:first() + 30, 0);
    end
    if usebma then
        SMAOpen = core.indicators:create("MVA", source.open, 30);
        SMAClose = core.indicators:create("MVA", source.close, 30);
        BMAtrend = instance:addInternalStream(source:first() + 30, 0);
    end
    if usebc then
        color = instance:addInternalStream(source:first(), 0);
        BARtrend = instance:addInternalStream(color:first() + 8, 0);
    end
    if usest then
        atr3 = core.indicators:create("ATR", source, 3);
        TrendUp = instance:addInternalStream(atr3.DATA:first(), 0);
        TrendDown = instance:addInternalStream(atr3.DATA:first(), 0);
        SUPtrend = instance:addInternalStream(atr3.DATA:first(), 0);
    end
    if usedi then
        dmi = core.indicators:create("DMI", source, 14);
        DItrend = instance:addInternalStream(dmi.DATA:first(), 0);
    end
    if usetts then
        atr1 = core.indicators:create("ATR", source, 1);
        avgTR = core.indicators:create("WMA", atr1.DATA, 21);
        ret = instance:addInternalStream(math.max(avgTR.DATA:first() + 1, 22), 0);
        TTStrend = instance:addInternalStream(ret:first(), 0);
    end
    if usersi then
        rsi = core.indicators:create("RSI", source, 13);
        RSItrend = instance:addInternalStream(rsi.DATA:first(), 0);
    end
    if usewto then
        esa = core.indicators:create("EMA", source.typical, 10);
        d_source = instance:addInternalStream(esa.DATA:first(), 0);
        d = core.indicators:create("EMA", d_source, 10);
        ci = instance:addInternalStream(d.DATA:first(), 0);
        tci = core.indicators:create("EMA", ci, 21);
        WTOtrend = instance:addInternalStream(tci.DATA:first(), 0);
    end
    trends = instance:addInternalStream(0, 0);
    if usetl then
        pricehi = core.indicators:create("MVA", source.high, 10);
        pricelo = core.indicators:create("MVA", source.low, 10);
    end
    posi = instance:addInternalStream(0, 0);
    for i = 1, 8 do
        pl[i] = instance:addStream("pl" .. i, core.Line, "PL" .. i, "PL" .. i, instance.parameters:getColor("pl_color" .. i), 0, 0);
        pl[i]:setWidth(instance.parameters:getInteger("pl_width" .. i));
        pl[i]:setStyle(instance.parameters:getInteger("pl_style" .. i));
        ph[i] = instance:addStream("ph" .. i, core.Line, "PH" .. i, "PH" .. i, instance.parameters:getColor("ph_color" .. i), 0, 0);
        ph[i]:setWidth(instance.parameters:getInteger("ph_width" .. i));
        ph[i]:setStyle(instance.parameters:getInteger("ph_style" .. i));
    end
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

function Center(period)
    local lastlow, lasthigh = mathex.minmax(source, core.rangeTo(period, 30));
    return (lasthigh + lastlow) / 2;
end

function getTrueRange(period)
    local hl = tAbs(history.high[period] - history.low[period]);
    local hc = tAbs(history.high[period] - history.close[period - 1]);
    local lc = tAbs(history.low[period] - history.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

function Update(period, mode)
    trends[period] = 0;
    if usewow and WOWtrend:first() <= period then
        local center = Center(period);
        local body = (source.open[period] + source.close[period]) / 2;
        if body > center then
            trend1[period] = 1 
        elseif body < center then
            trend1[period] = -1;
        else
            trend1[period] = trend1[period - 1];
        end
        local center1 = Center(period - 1);
        if center > center1 then
            trend2[period] = 1;
        elseif center < center1 then 
            trend2[period] = -1;
        else
            trend2[period] = trend2[period - 1];
        end
        if trend1[period] == 1 and trend2[period] == 1 then
            WOWtrend[period] = 1;
        elseif trend1[period] == -1 and trend2[period] == -1 then
            WOWtrend[period] = -1;
        else
            WOWtrend[period] = WOWtrend[period - 1];
        end
        trends[period] = trends[period] + WOWtrend[period];
    end
    if usewow and BMAtrend:first() <= period then
        SMAOpen:update(mode);
        SMAClose:update(mode);
        if SMAClose.DATA[period] > SMAOpen.DATA[period] then
            BMAtrend[period] = 1;
        elseif SMAClose.DATA[period] < SMAOpen.DATA[period] then
            BMAtrend[period] = -1;
        else
            BMAtrend[period] = BMAtrend[period - 1];
        end
        trends[period] = trends[period] + BMAtrend[period];
    end
    if usebc then
        if color:first() <= period then
            color[period] = source.close[period] > source.open[period] and 1 or 0;
        end
        if BARtrend:first() <= period then
            local score = color[period] + color[period - 1] + color[period - 2] + color[period - 3] + color[period - 4] + color[period - 5] + color[period - 6] + color[period - 7];
            if score > 5 then
                BARtrend[period] = 1;
            elseif score < 3 then
                BARtrend[period] = -1;
            else
                BARtrend[period] = BARtrend[period - 1];
            end
            trends[period] = trends[period] + BARtrend[period];
        end
    end
    if usest then
        atr3:update(mode);
        if atr3.DATA:hasData(period) then
            Up = source.median[period] - (7 * atr3.DATA[period]);
            Dn = source.median[period] + (7 * atr3.DATA[period]);
            if TrendUp:hasData(period - 1) and source.close[period - 1] > TrendUp[period - 1] then
                TrendUp[period] = math.max(Up, TrendUp[period - 1]);
            else
                TrendUp[period] = Up;
            end
            if TrendDown:hasData(period - 1) and source.close[period - 1] < TrendDown[period - 1] then
                TrendDown[period] = math.min(Dn, TrendDown[period - 1]);
            else
                TrendDown[period] = Dn;
            end
            if source.close[period] > TrendDown[period - 1] then
                SUPtrend[period] = 1;
            elseif source.close[period] < TrendDown[period - 1] then
                SUPtrend[period] = -1;
            else
                SUPtrend[period] = SUPtrend[period - 1];
            end
            trends[period] = trends[period] + SUPtrend[period];
        end
    end
    if usedi then
        dmi:update(mode);
        DItrend[period] = dmi.DIP[period] > dmi.DIM[period] and 1 or -1;
        trends[period] = trends[period] + DItrend[period];
    end
    if usetts then
        atr1:update(mode);
        avgTR:update(mode);
        if ret:first() <= period then
            local lowestC, highestC = mathex.minmax(source, core.rangeTo(period, 21));
            local lowestC1, highestC1 = mathex.minmax(source, core.rangeTo(period - 1, 21));
            hiLimit = highestC1 - (avgTR.DATA[period - 1] * 3);
            loLimit = lowestC1 + (avgTR.DATA[period - 1] * 3);
            if source.close[period] > hiLimit and source.close[period] > loLimit then
                ret[period] = hiLimit;
            elseif source.close[period] < loLimit and source.close[period] < hiLimit then
                ret[period] = loLimit;
            else
                ret[period] = ret[period - 1];
            end
            if source.close[period] > ret[period] then
                TTStrend[period] = 1;
            elseif source.close[period] < ret[period] then
                TTStrend[period] = -1;
            else
                TTStrend[period] = TTStrend[period - 1];
            end
            trends[period] = trends[period] + TTStrend[period];
        end
    end
    if usersi then
        rsi:update(mode);
        if rsi.DATA:hasData(period) then
            local RSIMain = (rsi.DATA[period] - 50) * 1.5;
            if RSIMain > -10 then
                RSItrend[period] = 1;
            elseif RSIMain < 10 then
                RSItrend[period] = -1;
            else
                RSItrend[period] = RSItrend[period - 1];
            end
            trends[period] = trends[period] + RSItrend[period];
        end
    end
    if usewto then
        esa:update(mode);
        if esa.DATA:hasData(period) then
            d_source[period] = source.typical[period] - esa.DATA[period];
            d:update(mode);
            if d.DATA:hasData(period) then
                ci[period] = (source.typical[period] - esa.DATA[period]) / (0.015 * d.DATA[period]);
                tci:update(mode);
                if tci.DATA:hasData(period) then
                    if tci.DATA[period] > 0 then
                        WTOtrend[period] = 1;
                    elseif tci.DATA[period] < 0 then
                        WTOtrend[period] = -1;
                    else
                        WTOtrend[period] = 0;
                    end
                    trends[period] = trends[period] + WTOtrend[period];
                end
            end
        end
    end
    if not usemon then
        trends[period] = trends[period] * (-1);
    end

    local per = 0;
    if usetl then
        pricehi:update(mode);
        pricelo:update(mode);
        per = dist / 10000;
        if trends[period] > 0 then
            pl[1][period] = pricelo.DATA[period] * (1 - per);
        end
        if trends[period] > 1 then
            pl[2][period] = pricelo.DATA[period] * (1 - 2 * per);
        end
        if trends[period] > 2 then
            pl[3][period] = pricelo.DATA[period] * (1 - 3 * per);
        end
        if trends[period] > 3 then
            pl[4][period] = pricelo.DATA[period] * (1 - 4 * per);
        end
        if trends[period] > 4 then
            pl[5][period] = pricelo.DATA[period] * (1 - 5 * per);
        end
        if trends[period] > 5 then
            pl[6][period] = pricelo.DATA[period] * (1 - 6 * per);
        end
        if trends[period] > 6 then
            pl[7][period] = pricelo.DATA[period] * (1 - 7 * per);
        end
        if trends[period] > 7 then
            pl[8][period] = pricelo.DATA[period] * (1 - 8 * per);
        end
        if trends[period] < 0 then
            ph[1][period] = pricehi.DATA[period] * (1 + per);
        end
        if trends[period] < 1 then
            ph[2][period] = pricehi.DATA[period] * (1 + 2 * per);
        end
        if trends[period] < 2 then
            ph[3][period] = pricehi.DATA[period] * (1 + 3 * per);
        end
        if trends[period] < 3 then
            ph[4][period] = pricehi.DATA[period] * (1 + 4 * per);
        end
        if trends[period] < 4 then
            ph[5][period] = pricehi.DATA[period] * (1 + 5 * per);
        end
        if trends[period] < 5 then
            ph[6][period] = pricehi.DATA[period] * (1 + 6 * per);
        end
        if trends[period] < 6 then
            ph[7][period] = pricehi.DATA[period] * (1 + 7 * per);
        end
        if trends[period] < 7 then
            ph[8][period] = pricehi.DATA[period] * (1 + 8 * per);
        end
    end
    if trends[period] >= sensup then
        posi[period] = 1;
    elseif trends[period] <= (-1) * sensdn then
        posi[period] = -1;
    else
        posi[period] = posi[period - 1];
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
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
        alert:UpAlert(source, period, source.high[period], historical_period, upMetadata);
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
        alert:DownAlert(source, period, source.low[period], historical_period, downMetadata);
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
