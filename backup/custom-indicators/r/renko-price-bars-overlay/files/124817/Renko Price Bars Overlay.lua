-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67755

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local indi_alerts = {};
indi_alerts.total_alerts = 1;
indi_alerts.drawing_layer = 2;

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
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function InitStyle(id, name, color, style, width)
    indicator.parameters:addColor("color_" .. id, name .. " Color", "", color)
    indicator.parameters:addInteger("style_" .. id, name .. " Style", "", style)
    indicator.parameters:setFlag("style_" .. id, core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width_" .. id, name .. " Width", "", width, 1, 5)
end

function GetColor(id)
    return instance.parameters:getColor("color_" .. id);
end

function SetStyle(id, stream)
    stream:setWidth(instance.parameters:getInteger("width_" .. id));
    stream:setStyle(instance.parameters:getInteger("style_" .. id));
end

function Init()
    indicator:name("Renko Price Bars Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
     
    indicator.parameters:addString("type", "Type", "", "Traditional")
    indicator.parameters:addStringAlternative("type", "Traditional", "", "Traditional")
    --indicator.parameters:addStringAlternative("type", "ATR", "", "ATR")

    indicator.parameters:addInteger("size", "Box Tick Size (Traditional Mode)", "", 100);
   -- indicator.parameters:addInteger("atrLen", "ATR Length (ATR Mode)", "", 14);
   -- indicator.parameters:addDouble("atrMult", "ATR Multiplier (ATR Mode)", "", 1);
   -- indicator.parameters:addInteger("round", "Box Tick Size Rounding (ATR Mode)", "", 1);

    AddAverages("maType", "Moving Average Type", "EMA");
    indicator.parameters:addInteger("maLen", "Moving Average Length", "", 21);
    indicator.parameters:addGroup("BB");
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 10000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2.0, 0.0001, 1000.0);

    indicator.parameters:addBoolean("showBand", "Show Renko Band?", "", true);
    indicator.parameters:addColor("bull_renko", "Bull Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("bear_renko", "Bear Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("renko_fill_transp", "Renko Fill Transparency", "", 95, 0, 100)

    indicator.parameters:addBoolean("showBreakHist", "Show New Brick Price Level History?", "", false);
    InitStyle("break_top", "Break top line", core.rgb(255, 255, 0), core.LINE_SOLID, 1);
    InitStyle("break_bottom", "Break bottom line", core.rgb(255, 255, 0), core.LINE_SOLID, 1);
    InitStyle("break_middle", "Break middle line", core.rgb(255, 255, 0), core.LINE_SOLID, 1);
    indicator.parameters:addInteger("break_fill_transp", "Break Fill Transparency", "", 95, 0, 100)

    InitStyle("bb_top", "BB Top line", core.rgb(255, 0, 255), core.LINE_SOLID, 1);
    InitStyle("bb_bottom", "BB Bottom line", core.rgb(255, 0, 255), core.LINE_SOLID, 1);

    InitStyle("ma_close", "MA open line", core.rgb(0, 0, 255), core.LINE_SOLID, 1);
    InitStyle("ma_open", "MA close line", core.rgb(0, 0, 255), core.LINE_SOLID, 1);
    indicator.parameters:addInteger("ma_fill_transp", "MA Fill Transparency", "", 95, 0, 100)

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Break");
end

local first;
local source = nil;

local out_o, out_c, tu, tl, tm, bbtl, bbbl, mC, mO, mC_stream, mO_stream, tu_stream, tl_stream;
local renko, renko_ma_open, renko_ma_close, renko_bb;
function Prepare(nameOnly)   
    local name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end
    source = instance.source;
    if instance.parameters.type == "Traditional" then
        renko = core.indicators:create("RENKO_CANDLES", nil, source:instrument(),
            source:barSize(), source:isBid(), instance.parameters.size);
    else
        assert(false, "not implemented yet");
    end
    renko_ma_open = CreateAverates(instance.parameters.maType, renko.open, instance.parameters.maLen);
    renko_ma_close = CreateAverates(instance.parameters.maType, renko.close, instance.parameters.maLen);
    renko_bb = core.indicators:create("BB", renko.close, instance.parameters.Period, instance.parameters.bbStdMult)

    if instance.parameters.showBand then
        out_o = instance:addStream("O", core.Line, "Open (Anchored to Interval Open)", 
            "Open (Anchored to Interval Open)", instance.parameters.bull_renko, 0);
        out_c = instance:addStream("C", core.Line, "Close (Anchored to Interval Open)", 
            "Close (Anchored to Interval Open)", instance.parameters.bear_renko, 0);
        instance:createChannelGroup("Fill (Close - Open)", "CO", out_o, out_c, instance.parameters.bull_renko, 100 - instance.parameters.renko_fill_transp);
    end
    if instance.parameters.showBreakHist then
        tu = instance:addStream("TU", core.Line, "Target High History", 
            "Target High History", GetColor("break_top"), 0);
        SetStyle("break_top", tu)
        tu_stream = instance:addInternalStream(0, 0)
        tl = instance:addStream("TL", core.Line, "Target Low History", 
            "Target Low History", GetColor("break_bottom"), 0);
        SetStyle("break_bottom", tl)
        tl_stream = instance:addInternalStream(0, 0)
        tm = instance:addStream("TM", core.Line, "Target Mid History", 
            "Target Mid History", GetColor("break_middle"), 0);
        SetStyle("break_middle", tm)
        instance:createChannelGroup("Fill (Target Up - Target Low)", "TUTL", tu, tl, GetColor("break_top"), 100 - instance.parameters.break_fill_transp);
    end

    bbtl = instance:addStream("BBTL", core.Line, "Bollinger Band Renko Up", 
        "Bollinger Band Renko Up", GetColor("bb_top"), 0);
    SetStyle("bb_top", bbtl);
    bbbl = instance:addStream("BBBL", core.Line, "Bollinger Band Renko Down",
        "Bollinger Band Renko Down", GetColor("bb_bottom"), 0);
    SetStyle("bb_top", bbbl);

    mC = instance:addStream("MC", core.Line, "Moving Average of Band Close", 
        "Moving Average of Band Close", GetColor("ma_close"), 0);
    mC_stream = instance:addInternalStream(0, 0)
    SetStyle("ma_close", mC);
    mO = instance:addStream("MC", core.Line, "Moving Average of Band Open", 
        "Moving Average of Band Open", GetColor("ma_open"), 0);
    mO_stream = instance:addInternalStream(0, 0)
    SetStyle("ma_open", mO);
    instance:createChannelGroup("Moving Average Fill", "mcmo", mC_stream, mO_stream,  GetColor("ma_close"), 100 - instance.parameters.ma_fill_transp);

    core.host:execute("setTimer", 1, 1);

    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    if indi_alerts.drawing_layer >= 100 then
        instance:drawOnMainChart(true);
    else
        instance:ownerDrawn(true);
    end
end
function Draw(stage, context) indi_alerts:Draw(stage, context, source); end
local updateNeeded = true;

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if alert.id == 1 then
        if core.crossesOver(source.close, math.max(out_o[period], out_c[period]), period) then
            alert:UpAlert(source, period, alert.Label .. ". Bull pattern", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, math.min(out_o[period], out_c[period]), period) then
            alert:DownAlert(source, period, alert.Label .. ". Bear pattern", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function Update(period, mode)
    renko:update(mode);
    renko_ma_open:update(mode);
    renko_ma_close:update(mode);
    renko_bb:update(mode);
    local renko_period = core.findDate(renko.open, source:date(period), false);
    if renko_period < 0 then
        return;
    end

    if out_o ~= nil then
        out_o[period] = renko.open[renko_period];
        out_c[period] = renko.close[renko_period];
        if out_o[period] > out_c[period] then
            out_o:setColor(period, instance.parameters.bear_renko)
            out_c:setColor(period, instance.parameters.bear_renko)
        else
            out_o:setColor(period, instance.parameters.bull_renko)
            out_c:setColor(period, instance.parameters.bull_renko)
        end
        if period > 0 and (out_o[period] ~= out_o[period - 1] or out_c[period] ~= out_c[period - 1]) then
            out_o:setBreak(period, true);
            out_c:setBreak(period, true);
        end
    end
    if tu ~= nil then
        tu = targetUp[period];
        tl = targetDn[period];
        tu_stream = targetUp[period];
        tl_stream = targetDn[period];
        tm = (targetUp[period] + targetDn[period]) / 2;
    end
    if renko_ma_close.DATA:hasData(renko_period) then
        mC[period] = renko_ma_close.DATA[renko_period];
        mO[period] = renko_ma_open.DATA[renko_period];
        mC_stream[period] = renko_ma_close.DATA[renko_period];
        mO_stream[period] = renko_ma_open.DATA[renko_period];
    end
    if renko_bb.TL:hasData(renko_period) then
        bbtl[period] = renko_bb.TL[renko_period];
        bbbl[period] = renko_bb.BL[renko_period];
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end
function AsyncOperationFinished(cookie, successful, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1 then
        if renko.open:size() > 0 and updateNeeded then
            instance:updateFrom(0);
            updateNeeded = false;
        end
    end
end

indi_alerts.Version = "1.6";
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
		"You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "")
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
    if stage ~= indi_alerts.drawing_layer then
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
        if instance.parameters.strategy_output then
            alert.Alert = instance:addStream("strat_signal_" .. i, core.Dot, "strat_signal_" .. i, "Strategy signal #" .. i, core.rgb(0, 0, 0), 0, 0);
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
