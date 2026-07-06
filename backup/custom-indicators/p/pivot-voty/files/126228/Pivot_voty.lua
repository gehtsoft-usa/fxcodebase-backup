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

local indi_alerts = {};
indi_alerts.drawing_layer = 2;

function Init()
    indicator:name("Pivot Voty");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("tf", "Timeframe", "", "D1");
    indicator.parameters:setFlag("tf", core.FLAG_PERIODS);

    indicator.parameters:addInteger("LineStyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("width", "Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("LineStylePP", "Line Style PP", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStylePP", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("pp_width", "Line Width PP", "", 2, 1, 5);

    indicator.parameters:addColor("ColorP", "Color P", "", core.colors().Yellow);
    indicator.parameters:addColor("ColorR38", "Color R38", "", core.colors().Magenta);
    indicator.parameters:addColor("ColorS38", "Color S38", "", core.colors().Magenta);
    indicator.parameters:addColor("ColorR61", "Color R61", "", core.colors().LimeGreen);
    indicator.parameters:addColor("ColorS61", "Color S61", "", core.colors().LimeGreen);
    indicator.parameters:addColor("ColorR78", "Color R78", "", core.colors().Red);
    indicator.parameters:addColor("ColorS78", "Color S78", "", core.colors().Red);
    indicator.parameters:addColor("ColorR100", "Color R100", "", core.colors().Aqua);
    indicator.parameters:addColor("ColorS100", "Color S100", "", core.colors().Aqua);
    indicator.parameters:addColor("ColorR138", "Color R138", "", core.colors().Orange);
    indicator.parameters:addColor("ColorS138", "Color S138", "", core.colors().Orange);
    indicator.parameters:addColor("ColorR161", "Color R161", "", core.colors().Black);
    indicator.parameters:addColor("ColorS161", "Color S161", "", core.colors().Black);
    indicator.parameters:addColor("ColorR200", "Color R200", "", core.colors().Brown);
    indicator.parameters:addColor("ColorS200", "Color S200", "", core.colors().Brown);

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Pivot line");
    indi_alerts:AddAlert("Pivot 38");
    indi_alerts:AddAlert("Pivot 61");
    indi_alerts:AddAlert("Pivot 78");
    indi_alerts:AddAlert("Pivot 100");
    indi_alerts:AddAlert("Pivot 138");
    indi_alerts:AddAlert("Pivot 161");
    indi_alerts:AddAlert("Pivot 200");
end

local Res100, Res61, Res38, Pivot, Supp38, Supp61, Supp100, Res78, Supp78, Res138, Supp138, Res161, Supp161, Res200, Supp200;
local source, tf, tf_source;
local LOADING_STARTED_ID = 1;
local LOADING_FINISHED_ID = 2;
local ColorP, ColorR38, ColorR61, ColorR78, ColorR100, ColorR138, ColorR161, ColorR200, ColorS38, ColorS61, ColorS78, ColorS100, ColorS138, ColorS161, ColorS200
function Prepare(nameOnly)
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    if indi_alerts.drawing_layer >= 100 then
        instance:drawOnMainChart(true);
    else
        instance:ownerDrawn(true);
    end

    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    tf = instance.parameters.tf;
    if nameOnly then
        return ;
    end

    tf_source = core.host:execute("getSyncHistory", source:instrument(), tf, source:isBid(), 0, LOADING_FINISHED_ID, LOADING_STARTED_ID);

    ColorP = instance.parameters.ColorP;
    ColorR38 = instance.parameters.ColorR38;
    ColorR61 = instance.parameters.ColorR61;
    ColorR78 = instance.parameters.ColorR78;
    ColorR100 = instance.parameters.ColorR100;
    ColorR138 = instance.parameters.ColorR138;
    ColorR161 = instance.parameters.ColorR161;
    ColorR200 = instance.parameters.ColorR200;
    ColorS38 = instance.parameters.ColorS38;
    ColorS61 = instance.parameters.ColorS61;
    ColorS78 = instance.parameters.ColorS78;
    ColorS100 = instance.parameters.ColorS100;
    ColorS138 = instance.parameters.ColorS138;
    ColorS161 = instance.parameters.ColorS161;
    ColorS200 = instance.parameters.ColorS200;
    Pivot = instance:addStream("Pivot", core.Line, "Pivot", "Pivot", ColorP, 0, 0);
    Pivot:setStyle(instance.parameters.LineStylePP);
    Pivot:setWidth(instance.parameters.pp_width);
    Res38 = instance:addStream("Res38", core.Line, "Res38", "Res38", ColorR38, 0, 0);
    Res38:setStyle(instance.parameters.LineStyle);
    Res38:setWidth(instance.parameters.width);
    Res61 = instance:addStream("Res61", core.Line, "Res61", "Res61", ColorR61, 0, 0);
    Res61:setStyle(instance.parameters.LineStyle);
    Res61:setWidth(instance.parameters.width);
    Res78 = instance:addStream("Res78", core.Line, "Res78", "Res78", ColorR78, 0, 0);
    Res78:setStyle(instance.parameters.LineStyle);
    Res78:setWidth(instance.parameters.width);
    Res100 = instance:addStream("Res100", core.Line, "Res100", "Res100", ColorR100, 0, 0);
    Res100:setStyle(instance.parameters.LineStyle);
    Res100:setWidth(instance.parameters.width);
    Res138 = instance:addStream("Res138", core.Line, "Res138", "Res138", ColorR138, 0, 0);
    Res138:setStyle(instance.parameters.LineStyle);
    Res138:setWidth(instance.parameters.width);
    Res161 = instance:addStream("Res161", core.Line, "Res161", "Res161", ColorR161, 0, 0);
    Res161:setStyle(instance.parameters.LineStyle);
    Res161:setWidth(instance.parameters.width);
    Res200 = instance:addStream("Res200", core.Line, "Res200", "Res200", ColorR200, 0, 0);
    Res200:setStyle(instance.parameters.LineStyle);
    Res200:setWidth(instance.parameters.width);
    Supp38 = instance:addStream("Supp38", core.Line, "Supp38", "Supp38", ColorS38, 0, 0);
    Supp38:setStyle(instance.parameters.LineStyle);
    Supp38:setWidth(instance.parameters.width);
    Supp61 = instance:addStream("Supp61", core.Line, "Supp61", "Supp61", ColorS61, 0, 0);
    Supp61:setStyle(instance.parameters.LineStyle);
    Supp61:setWidth(instance.parameters.width);
    Supp78 = instance:addStream("Supp78", core.Line, "Supp78", "Supp78", ColorS78, 0, 0);
    Supp78:setStyle(instance.parameters.LineStyle);
    Supp78:setWidth(instance.parameters.width);
    Supp100 = instance:addStream("Supp100", core.Line, "Supp100", "Supp100", ColorS100, 0, 0);
    Supp100:setStyle(instance.parameters.LineStyle);
    Supp100:setWidth(instance.parameters.width);
    Supp138 = instance:addStream("Supp138", core.Line, "Supp138", "Supp138", ColorS138, 0, 0);
    Supp138:setStyle(instance.parameters.LineStyle);
    Supp138:setWidth(instance.parameters.width);
    Supp161 = instance:addStream("Supp161", core.Line, "Supp161", "Supp161", ColorS161, 0, 0);
    Supp161:setStyle(instance.parameters.LineStyle);
    Supp161:setWidth(instance.parameters.width);
    Supp200 = instance:addStream("Supp200", core.Line, "Supp200", "Supp200", ColorS200, 0, 0);
    Supp200:setStyle(instance.parameters.LineStyle);
    Supp200:setWidth(instance.parameters.width);
end

local init = false;
local FONT_ID = 2;
function Draw(stage, context)
    indi_alerts:Draw(stage, context, source); 
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(12), 0);
        init = true;
    end
    local period = math.max(source:size() - 1, context:lastBar());
    if period <= 0 then
        return;
    end
    local x = context:positionOfBar(period);
    local _, y = context:pointOfPrice(Pivot[period]);
    local w, h = context:measureText(FONT_ID, "P", 0);
    context:drawText(FONT_ID, "P", ColorP, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Res38[period]);
    local w, h = context:measureText(FONT_ID, "R38", 0);
    context:drawText(FONT_ID, "R38", ColorR38, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Supp38[period]);
    local w, h = context:measureText(FONT_ID, "S38", 0);
    context:drawText(FONT_ID, "S38", ColorS38, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Res61[period]);
    local w, h = context:measureText(FONT_ID, "R61", 0);
    context:drawText(FONT_ID, "R61", ColorR61, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Supp61[period]);
    local w, h = context:measureText(FONT_ID, "S61", 0);
    context:drawText(FONT_ID, "S61", ColorS61, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Res78[period]);
    local w, h = context:measureText(FONT_ID, "R78", 0);
    context:drawText(FONT_ID, "R78", ColorR78, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Supp78[period]);
    local w, h = context:measureText(FONT_ID, "S78", 0);
    context:drawText(FONT_ID, "S78", ColorS78, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Res100[period]);
    local w, h = context:measureText(FONT_ID, "R100", 0);
    context:drawText(FONT_ID, "R100", ColorR100, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Supp100[period]);
    local w, h = context:measureText(FONT_ID, "S100", 0);
    context:drawText(FONT_ID, "S100", ColorS100, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Res138[period]);
    local w, h = context:measureText(FONT_ID, "R138", 0);
    context:drawText(FONT_ID, "R138", ColorR138, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Supp138[period]);
    local w, h = context:measureText(FONT_ID, "S138", 0);
    context:drawText(FONT_ID, "S138", ColorS138, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Res161[period]);
    local w, h = context:measureText(FONT_ID, "R161", 0);
    context:drawText(FONT_ID, "R161", ColorR161, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Supp161[period]);
    local w, h = context:measureText(FONT_ID, "S161", 0);
    context:drawText(FONT_ID, "S161", ColorS161, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Res200[period]);
    local w, h = context:measureText(FONT_ID, "R200", 0);
    context:drawText(FONT_ID, "R200", ColorR200, -1, x - w, y - h, x, y, 0);
    
    local _, y = context:pointOfPrice(Supp200[period]);
    local w, h = context:measureText(FONT_ID, "S200", 0);
    context:drawText(FONT_ID, "S200", ColorS200, -1, x - w, y - h, x, y, 0);
end

function Update(period, mode)
    -- *****************************************************
    --    Find previous day's opening and closing bars.
    -- *****************************************************
      
    -- Find Our Week date.

    local WeekDate = source:date(period);
    local WeeklyBar = core.findDate(tf_source, WeekDate, false) - 1; 
    if WeeklyBar < 0 then
        return;
    end
    local PreviousHigh = tf_source.high[WeeklyBar];
    local PreviousLow = tf_source.low[WeeklyBar];
    local PreviousClose = tf_source.close[WeeklyBar];

    -- ************************************************************************
    --    Calculate Pivot lines and map into indicator buffers.
    -- ************************************************************************
    local P = (PreviousHigh + PreviousLow + PreviousClose) / 3;
    Pivot[period] = P;
    Res38[period] = P + ((PreviousHigh - PreviousLow) * 0.382);
    Supp38[period] = P - ((PreviousHigh - PreviousLow) * 0.382);
    Res61[period] = P + ((PreviousHigh - PreviousLow) * 0.618);
    Supp61[period] = P - ((PreviousHigh - PreviousLow) * 0.618);
    Res78[period] = P + ((PreviousHigh - PreviousLow) * 0.786);
    Supp78[period] = P - ((PreviousHigh - PreviousLow) * 0.786);
    Res100[period] = P + ((PreviousHigh - PreviousLow) * 1.000);
    Supp100[period] = P - ((PreviousHigh - PreviousLow) * 1.000);
    Res138[period] = P + ((PreviousHigh - PreviousLow) * 1.382);
    Supp138[period] = P - ((PreviousHigh - PreviousLow) * 1.382);
    Res161[period] = P + ((PreviousHigh - PreviousLow) * 1.618);
    Supp161[period] = P - ((PreviousHigh - PreviousLow) * 1.618);
    Res200[period] = P + ((PreviousHigh - PreviousLow) * 2.000);
    Supp200[period] =  P - ((PreviousHigh - PreviousLow) * 2.000);
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
        if core.crosses(source.close, Pivot, period) then
            alert:UpAlert(source, period, alert.Label .. " touched", source.high[period], historical_period);
        end
    elseif alert.id == 2 then
        if core.crossesOver(source.close, Res38, period) then
            alert:UpAlert(source, period, alert.Label .. " resistance touched", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, Supp38, period) then
            alert:DownAlert(source, period, alert.Label .. " support touched", source.low[period], historical_period);
        end
    elseif alert.id == 3 then
        if core.crossesOver(source.close, Res61, period) then
            alert:UpAlert(source, period, alert.Label .. " resistance touched", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, Supp61, period) then
            alert:DownAlert(source, period, alert.Label .. " support touched", source.low[period], historical_period);
        end
    elseif alert.id == 4 then
        if core.crossesOver(source.close, Res78, period) then
            alert:UpAlert(source, period, alert.Label .. " resistance touched", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, Supp78, period) then
            alert:DownAlert(source, period, alert.Label .. " support touched", source.low[period], historical_period);
        end
    elseif alert.id == 5 then
        if core.crossesOver(source.close, Res100, period) then
            alert:UpAlert(source, period, alert.Label .. " resistance touched", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, Supp100, period) then
            alert:DownAlert(source, period, alert.Label .. " support touched", source.low[period], historical_period);
        end
    elseif alert.id == 6 then
        if core.crossesOver(source.close, Res138, period) then
            alert:UpAlert(source, period, alert.Label .. " resistance touched", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, Supp138, period) then
            alert:DownAlert(source, period, alert.Label .. " support touched", source.low[period], historical_period);
        end
    elseif alert.id == 7 then
        if core.crossesOver(source.close, Res161, period) then
            alert:UpAlert(source, period, alert.Label .. " resistance touched", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, Supp161, period) then
            alert:DownAlert(source, period, alert.Label .. " support touched", source.low[period], historical_period);
        end
    elseif alert.id == 8 then
        if core.crossesOver(source.close, Res200, period) then
            alert:UpAlert(source, period, alert.Label .. " resistance touched", source.high[period], historical_period);
        elseif core.crossesUnder(source.close, Supp200, period) then
            alert:DownAlert(source, period, alert.Label .. " support touched", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == LOADING_FINISHED_ID then
        instance:updateFrom(0);
    end
end

indi_alerts.Version = "1.7";
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
    for i = 1, 100 do 
        local on = instance.parameters:getBoolean("ON" .. i);
        if on == nil then
            break;
        end 
        local alert = {};
        alert.id = i;
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = on;
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
