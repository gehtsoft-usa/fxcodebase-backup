-- Id: 20530
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65714

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

local indi_alerts = {};
indi_alerts.Version = "1.0";
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts._alerts = {};
indi_alerts._telegram_timer = nil;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    
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

    indicator.parameters:addGroup("Alerts Telegram");
    indicator.parameters:addString("telegram_key", "Telegram Key", "Used for @profit_robots_bot", "");
end

function indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2) if cookie == self._telegram_timer and #self._alerts > 0 then if self._telegram_key == nil then return; end local data = self:ArrayToJSON(self._alerts); self._alerts = {}; local req = http_lua.createRequest(); local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}', self._telegram_key, string.gsub(self.StrategyName or "", '"', '\\"'), data); req:setRequestHeader("Content-Type", "application/json"); req:setRequestHeader("Content-Length", tostring(string.len(query))); req:start("http://profitrobots.com/api/v1/notification", "POST", query); end end
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
    
    indicator.parameters:addFile("Down" .. self.last_id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    
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
                if level.Alert[period]== 1 then
                    visible, y = context:pointOfPrice (level.AlertLevel[period]);
                    width, height = context:measureText (1,  "\225", 0);
                    context:drawText (1,   "\225", self.UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );    
                elseif level.Alert[period]== -1 then
                    visible, y = context:pointOfPrice (level.AlertLevel[period]);
                    width, height = context:measureText (1,  "\226", 0);
                    context:drawText (1,   "\226", self.DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );    
                end
            end
        end
    end
end
indi_alerts.Alerts = {};
function indi_alerts:Prepare()
    self.Show = instance.parameters.Show;
    self.Live = instance.parameters.Live;
    self.ShowAlert = instance.parameters.ShowAlert;
    
    self.UpTrendColor = instance.parameters.UpTrendColor;
    self.DownTrendColor = instance.parameters.DownTrendColor;
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    local i;
    for i = 1, 2, 1 do 
        local alert = {};
        alert.id = 1;
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = instance.parameters:getBoolean("ON" .. i);
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

    if instance.parameters.telegram_key ~= "" then
        self._telegram_key = instance.parameters.telegram_key;
        require("http_lua");
        self._telegram_timer = 1234;
        core.host:execute("setTimer", self._telegram_timer, 1);
    end
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, " ( " .. self.source:instrument() .. label .. " : " .. note);
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

    local date = self.source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";  
    local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;   
    local Symbol = "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local text = Note  .. delim ..  Symbol .. delim .. Time;
    terminal:alertEmail(self.Email, profile:id(), text);
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return;
    end
    
    local date = self.source:date(period);
    local DATA = core.dateToTable (date);
    local delim = "\013\010";  
    local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;
    local Symbol= "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
    local TF= "Time Frame : " .. self.source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW));
end

function indi_alerts:AlertTelegram(message, instrument, timeframe) local alert = {}; alert.Text = message or ""; alert.Instrument = instrument or ""; alert.TimeFrame = timeframe or ""; self._alerts[#self._alerts + 1] = alert; end

function Init()
    indicator:name("Regularized ema");
    indicator:description("Regularized ema");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("TimeFrame", "Time frame", "", "m1");
    indicator.parameters:setFlag("TimeFrame", core.FLAG_BARPERIODS);
    indicator.parameters:addInteger("Length", "Length", "", 14);
    indicator.parameters:addInteger("EmaPeriod", "Ema period", "", 5);
    indicator.parameters:addString("EmaPrice", "Price to use", "", "pr_close");
    indicator.parameters:addStringAlternative("EmaPrice", "Close", "", "pr_close");
    indicator.parameters:addStringAlternative("EmaPrice", "Open", "", "pr_open");
    indicator.parameters:addStringAlternative("EmaPrice", "High", "", "pr_high");
    indicator.parameters:addStringAlternative("EmaPrice", "Low", "", "pr_low");
    indicator.parameters:addStringAlternative("EmaPrice", "Median", "", "pr_median");
    indicator.parameters:addStringAlternative("EmaPrice", "Typical", "", "pr_typical");
    indicator.parameters:addStringAlternative("EmaPrice", "Weighted", "", "pr_weighted");
    indicator.parameters:addStringAlternative("EmaPrice", "Average (high+low+open+close)/4", "", "pr_average");
    indicator.parameters:addStringAlternative("EmaPrice", "Average median body (open+close)/2", "", "pr_medianb");
    indicator.parameters:addStringAlternative("EmaPrice", "Trend biased price", "", "pr_tbiased");
    indicator.parameters:addStringAlternative("EmaPrice", "Trend biased (extreme) price", "", "pr_tbiased2");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi close", "", "pr_haclose");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi open", "", "pr_haopen");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi high", "", "pr_hahigh");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi low", "", "pr_halow");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi median", "", "pr_hamedian");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi typical", "", "pr_hatypical");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi weighted", "", "pr_haweighted");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi average", "", "pr_haaverage");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi median body", "", "pr_hamedianb");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi trend biased price", "", "pr_hatbiased");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi trend biased (extreme) price", "", "pr_hatbiased2");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) close", "", "pr_habclose");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) open", "", "pr_habopen");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) high", "", "pr_habhigh");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) low", "", "pr_hablow");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) median", "", "pr_habmedian");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) typical", "", "pr_habtypical");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) weighted", "", "pr_habweighted");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) average", "", "pr_habaverage");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) median body", "", "pr_habmedianb");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) trend biased price", "", "pr_habtbiased");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) trend biased (extreme) price", "", "pr_habtbiased2");
    
    indicator.parameters:addDouble("Lambda", "Lambda", "", 5);
    indicator.parameters:addDouble("Filter", "Filter", "Filter to use for filtering (<=0 - no filtering)", 0);
    indicator.parameters:addInteger("FilterPeriod", "Filter Period", "Filter period (0<= use ema period)", 0);
    indicator.parameters:addString("FilterOn", "Apply filter to", "", "flt_01");
    indicator.parameters:addStringAlternative("FilterOn", "Filter the prices", "", "flt_01");
    indicator.parameters:addStringAlternative("FilterOn", "Filter the ema value", "", "flt_02");
    indicator.parameters:addStringAlternative("FilterOn", "Filter prices and the ema value", "", "flt_03");

    indicator.parameters:addInteger("LinesWidth", "Lines Width", "Lines width (when lines are included in display)", 3);
    
    indi_alerts:AddParameters(indicator.parameters);
    indicator.parameters:addColor("rema", "rema", "", core.colors().DeepSkyBlue);
    indicator.parameters:addColor("remda", "remda", "", core.colors().SandyBrown);
    indicator.parameters:addColor("remdb", "remdb", "", core.colors().SandyBrown);

    indi_alerts:AddAlert("Slope changed");
end

local source;
local first;
local workRema = {};
local _remaInstances = 2;
local _remaInstancesSize = 9;
local _priceInstances = 1;
local _priceInstancesSize = 4;
local _priceWorkHa = {};
local btf;

local EMPTY_VALUE = nil;
local Length;
local TimeFrame;
local EmaPeriod;
local EmaPrice;
local Lambda;
local Filter;
local FilterPeriod;
local FilterOn;
local LinesWidth;

local rema;--DRAW_LINE
local remda;--DRAW_LINE
local remdb;--DRAW_LINE

local tperiod;
local pfilter;
local vfilter;
local alpha;
local regf1;
local regf2;

local mom;
local slope;
local count;
local workFil = {};
-- Routine
function Prepare(name_only)
    source = instance.source;
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    first = source:first();
    TimeFrame = instance.parameters.TimeFrame;
    Length = instance.parameters.Length;
    EmaPeriod = instance.parameters.EmaPeriod;
    EmaPrice = instance.parameters.EmaPrice;
    Lambda = instance.parameters.Lambda;
    Filter = instance.parameters.Filter;
    FilterPeriod = instance.parameters.FilterPeriod;
    FilterOn = instance.parameters.FilterOn;
    LinesWidth = instance.parameters.LinesWidth;
    tperiod = FilterPeriod > 0 and FilterPeriod or Length;
    pfilter = FilterOn ~= "flt_02" and Filter or 0;
    vfilter = FilterOn ~= "flt_01" and Filter or 0;
    alpha = 2.0 / (1.0 + Length);
    regf1 = (1.0+Lambda*2.0);
    regf2 = (1.0+Lambda);
    
    local name = string.format("%s (%s, %d)", profile:id(), TimeFrame, EmaPeriod);
    instance:name(name);

    if name_only then
        return;
    end

    count = instance:addInternalStream(0, 0);
    slope = instance:addInternalStream(0, 0);
    mom = instance:addInternalStream(0, 0);

    rema = instance:addStream("rema", core.Line, name .. ".rema", "rema", instance.parameters.rema, 0);
    rema:setWidth(instance.parameters.LinesWidth);
    remda = instance:addStream("remda", core.Line, name .. ".remda", "remda", instance.parameters.remda, 0);
    remda:setWidth(instance.parameters.LinesWidth);
    remdb = instance:addStream("remdb", core.Line, name .. ".remdb", "remdb", instance.parameters.remdb, 0);
    remdb:setWidth(instance.parameters.LinesWidth);

    for i = 0, _remaInstances * _remaInstancesSize - 1 do
        workRema[i] = instance:addInternalStream(0, 0);
    end
    for i = 0, _priceInstances * _priceInstancesSize - 1 do
        _priceWorkHa[i] = instance:addInternalStream(0, 0);
    end
    for i = 0, 5 do
        workFil[i] = instance:addInternalStream(0, 0);
    end

    if TimeFrame ~= source:barSize() then
        Source = core.host:execute("getSyncHistory", source:instrument(), TimeFrame, source:isBid(), 0, 100, 101);
    assert(core.indicators:findIndicator("REGULARIZED EMD - MTF & ALERTS 1.6") ~= nil, "REGULARIZED EMD - MTF & ALERTS 1.6" .. " indicator must be installed");
        btf = core.indicators:create("REGULARIZED EMD - MTF & ALERTS 1.6", Source, TimeFrame, Length, EmaPeriod, EmaPrice
            , Lambda, Filter, FilterPeriod, FilterOn, LinesWidth);
    else
        loading = false;
    end
    instance:ownerDrawn(true);
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

local loading = true;

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if alert.id == 1 and alert.ON then
        if slope[period] ~= slope[period - 1] and slope[period] == 1 then
            alert:UpAlert(source, period, alert.Label .. ". Changed to up", source.close[period], historical_period);
        elseif slope[period] ~= slope[period - 1] and slope[period] == -1 then
            alert:DownAlert(source, period, alert.Label .. ". Changed to down", source.close[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
    
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

function Update(period, mode)
    if btf ~= nil then
        if loading then
            return;
        end
        btf:update(mode);
        local btf_period = core.findDate(Source, source:date(period), false);
        rema[period] = btf.rema[btf_period];
        remda[period] = btf.remda[btf_period];
        remdb[period] = btf.remdb[btf_period];
        return;
    end
    
    local p = getPrice(EmaPrice, period);
    core.host:trace(tostring(p));
    local price = iFilter(p, pfilter, tperiod, period, 0);
    core.host:trace(tostring(EmaPrice));
    if period > 2 then
        rema[period] = iFilter((regf1 * rema[period - 1] + alpha * (price - rema[period - 1]) - Lambda * rema[period - 2]) / regf2, vfilter, tperiod, period, 1);
    else
        rema[period] = price;
    end
    if period > 1 then
        if rema[period] > rema[period - 1] then
            slope[period] = 1;
        elseif rema[period] < rema[period - 1] then
            slope[period] = -1;
        else 
            slope[period] = slope[period - 1];
        end
    else
        slope[period] = 0;
    end
    remda[period]  = EMPTY_VALUE;
    remdb[period]  = EMPTY_VALUE;
    if slope[period] == -1 then
        PlotPoint(period,remda,remdb,rema);
    end
    
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, mode ~= core.UpdateLast); end
end

local _fchange = 0;
local _fachang = 1;
local _fprice = 2;

function iFilter(tprice, filter, period, i, instanceNo)
    if filter <= 0 then
        return tprice;
    end
    workFil[instanceNo + _fprice][period] = tprice;
    if i < 1 then
        return(tprice);
    end
    workFil[instanceNo + _fchange][period] = math.abs(workFil[instanceNo + _fprice][period] - workFil[instanceNo + _fprice][i - 1]);
    workFil[instanceNo + _fachang][period] = workFil[instanceNo + _fchange][period];
    for k = 1, period do
        if workFil[0]:size() > i + k then
            workFil[instanceNo + _fachang][period] = workFil[instanceNo + _fachang][period] + workFil[instanceNo + _fchange][i + k];
            workFil[instanceNo + _fachang][period] = workFil[instanceNo + _fachang][period] / period;
        end
    end
    
    local stddev = 0;
    for k = 0, period do
        if workFil[0]:size() > i + k then
            stddev = stddev + math.pow(workFil[instanceNo + _fchange][i + k] - workFil[instanceNo + _fachang][i + k], 2);
        end
    end
    stddev = math.sqrt(stddev/period); 
    local filtev = filter * stddev;
    if math.abs(workFil[instanceNo + _fprice][period] - workFil[instanceNo + _fprice][i - 1]) < filtev then
        workFil[instanceNo + _fprice][period] = workFil[instanceNo + _fprice][i - 1];
    end
    return workFil[instanceNo + _fprice][period];
end

function PlotPoint(period, first, second, from)
    if period <= 2 then
        return;
    end
    if first[period - 1] == EMPTY_VALUE then
        if first[period - 2] == EMPTY_VALUE then
            first[period] = from[period];
            first[period + 1] = from[period + 1];
            second[period] = EMPTY_VALUE;
        else
            second[period] = from[period];
            second[period + 1] = from[period + 1];
            first[period] = EMPTY_VALUE;
        end
    else
        first[period] = from[period];
        second[period] = EMPTY_VALUE;
    end
end

function CleanPoint(i, first, second)
    if i <= 3 then
        return;
    end
    if (second[period] ~= EMPTY_VALUE) and (second[i - 1] ~= EMPTY_VALUE) then
        second[i - 1] = EMPTY_VALUE;
    elseif (first[period] ~= EMPTY_VALUE) and (first[i - 1] ~= EMPTY_VALUE) and (first[i - 2] == EMPTY_VALUE) then
        first[i - 1] = EMPTY_VALUE;
    end
end

function iRema(price, period, r, instanceNo)
    instanceNo = instanceNo * _remaInstancesSize;
    local _aa = (2. / (1. + period));
    if r > 0 and period > 1 then
        local _cc = 1. - _aa;
        workRema[instanceNo][r] = _aa * price + _cc * workRema[instanceNo][r - 1];
        for i = 1, 8 do
            workRema[i + instanceNo][r] = math.pow(_cc, math.pow(2, i - 1)) * workRema[i - 1 + instanceNo][r] + workRema[i - 1 + instanceNo][r - 1];
        end
        return workRema[instanceNo][r] - _aa * workRema[8 + instanceNo][r];
    end
    for i = 0, 8 do
        workRema[i + instanceNo][r] = price;
    end
    return 0;
end

function _prHABF(_prtype)
    return _prtype == "pr_habclose" or _prtype == "pr_habopen" or _prtype == "pr_habhigh"
        or _prtype == "pr_hablow" or _prtype == "pr_habmedian" or _prtype == "pr_habtypical"
        or _prtype == "pr_habweighted" or _prtype == "pr_habaverage" or _prtype == "pr_habmedianb"
        or _prtype == "pr_habtbiased" or _prtype == "pr_habtbiased2";
end

function getPrice(tprice, period)
    if tprice == "pr_haclose" or _prHABF(tprice) or tprice == "pr_hatbiased2" or tprice == "pr_hatbiased"
        or tprice == "pr_haaverage" or tprice == "pr_haweighted" or tprice == "pr_hatypical"
        or tprice == "pr_hamedianb" or tprice == "pr_hamedian" or tprice == "pr_halow" or tprice == "pr_hahigh"
        or tprice == "pr_haopen" 
    then
        local r = i;
        local haOpen = (r > 0) and ((_priceWorkHa[2][r - 1] + _priceWorkHa[3][r - 1]) / 2.0) or ((source.open[period] + source.close[period]) / 2);
        local haClose = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4.0;
        if _prHABF(tprice) then
            if source.high[period] ~= source.low[period] then
                haClose = (source.open[period] + source.close[period]) / 2.0 + (((source.close[period] - source.open[period]) / (source.high[period] - source.low[period])) * math.abs((source.close[period] - source.open[period]) / 2.0));
            else
                haClose = (source.open[period] + source.close[period]) / 2.0; 
            end
        end
        local haHigh = math.max(source.high[period], math.max(haOpen, haClose));
        local haLow = math.min(source.low[period], math.min(haOpen, haClose));
        if (haOpen < haClose) then
            _priceWorkHa[0][r] = haLow;
            _priceWorkHa[1][r] = haHigh;
        else
            _priceWorkHa[0][r] = haHigh;
            _priceWorkHa[1][r] = haLow;
        end
        _priceWorkHa[2][r] = haOpen;
        _priceWorkHa[3][r] = haClose;
        if tprice == "pr_haclose" or tprice == "pr_habclose" then return haClose; end
        if tprice == "pr_haopen" or tprice == "pr_habopen" then return haOpen; end
        if tprice == "pr_hahigh" or tprice == "pr_habhigh" then return haHigh; end
        if tprice == "pr_halow" or tprice == "pr_hablow" then return haLow; end
        if tprice == "pr_hamedian" or tprice == "pr_habmedian" then return (haHigh + haLow) / 2.0; end
        if tprice == "pr_hamedianb" or tprice == "pr_habmedianb" then return (haOpen + haClose) / 2.0; end
        if tprice == "pr_hatypical" or tprice == "pr_habtypical" then return (haHigh + haLow + haClose) / 3.0; end
        if tprice == "pr_haweighted" or tprice == "pr_habweighted" then return (haHigh + haLow + haClose + haClose) / 4.0; end
        if tprice == "pr_haaverage" or tprice == "pr_habaverage" then return (haHigh + haLow + haClose + haOpen) / 4.0; end
        if tprice == "pr_hatbiased" or tprice == "pr_habtbiased" then
            if haClose > haOpen then
                return (haHigh + haClose) / 2.0;
            else
                return (haLow + haClose) / 2.0;
            end
        end
        if tprice == "pr_hatbiased2" or tprice == "pr_habtbiased2" then
            if (haClose > haOpen) then
                return haHigh;
            end
            if (haClose < haOpen) then
                return haLow;
            end
        end
        return haClose;
    end
    if tprice == "pr_close" then return source.close[period]; end
    if tprice == "pr_open" then return source.open[period]; end
    if tprice == "pr_high" then return source.high[period]; end
    if tprice == "pr_low" then return source.low[period]; end
    if tprice == "pr_median" then return (source.high[period] + source.low[period]) / 2.0; end
    if tprice == "pr_medianb" then return (source.open[period] + source.close[period]) / 2.0; end
    if tprice == "pr_typical" then return (source.high[period] + source.low[period] + source.close[period]) / 3.0; end
    if tprice == "pr_weighted" then return (source.high[period] + source.low[period] + source.close[period] + source.close[period]) / 4.0; end
    if tprice == "pr_average" then  return (source.high[period] + source.low[period] + source.close[period] + source.open[period]) / 4.0; end
    if tprice == "pr_tbiased" then
        if source.close[period] > source.open[period] then
            return (source.high[period] + source.close[period]) / 2.0;
        else
            return (source.low[period] + source.close[period]) / 2.0;
        end
    end
    if tprice == "pr_tbiased2" then
        if source.close[period] > source.open[period] then
            return source.high[period];
        end
        if source.close[period] < source.open[period] then
            return source.low[period];
        end
        return source.close[period];
    end
    return 0;
end
 
