-- Id: 21362
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65959

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

-- Features of this indicator
-- 1：Display 3 RSI lines of different periods and the MA of the first RSI line.
-- 2：Display MA of the first RSI's MA. Crosses of the two MAs can be used as the signals. 
-- 3：Display histogram from RSI or MA to middle level.
-- 4：Colored level lines; 2 colors MA lines; Color filling between overbought and oversell levels.
-- About RSI value：
-- RSI value of this indicator = original RSI value - 50
-- This is to make RSI changes around 0 (not 50), which is convenient to draw histograms.

local indi_alerts = {};

function Init()
    indicator:name("RSI Signal")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addInteger("RSI1", "RSI 1 Period", "", 14)
    indicator.parameters:addColor("RSI1_color", "Line Color", "", core.colors().Aqua);
    indicator.parameters:addInteger("RSI1_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI1_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("RSI1_width", "Line Width", "", 1, 1, 5);
    
    indicator.parameters:addInteger("RSI2", "RSI 2 Period", "", 7)
    indicator.parameters:addColor("RSI2_color", "Line Color", "", core.colors().Aqua);
    indicator.parameters:addInteger("RSI2_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI2_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("RSI2_width", "Line Width", "", 1, 1, 5);

    indicator.parameters:addInteger("RSI3", "RSI 3 Period", "", 21)
    indicator.parameters:addColor("RSI3_color", "Line Color", "", core.colors().Aqua);
    indicator.parameters:addInteger("RSI3_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI3_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("RSI3_width", "Line Width", "", 1, 1, 5);

    indicator.parameters:addInteger("OverBought", "Overbought Level", "", 70)
    indicator.parameters:addColor("OverBought_color", "Line Color", "", core.colors().FireBrick);
    indicator.parameters:addInteger("OverBought_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("OverBought_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("OverBought_width", "Line Width", "", 2, 1, 5);

    indicator.parameters:addInteger("OverSell", "Oversell Level", "", 30)
    indicator.parameters:addColor("OverSell_color", "Up Line Color", "", core.colors().Blue);
    indicator.parameters:addInteger("OverSell_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("OverSell_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("OverSell_width", "Line Width", "", 2, 1, 5);

    indicator.parameters:addGroup("Smooth RSI 1")
    indicator.parameters:addInteger("MA1_Period", "Smooth Period", "", 10)
    indicator.parameters:addString("MA1_Method", "Smooth Period", "", "MVA");
    indicator.parameters:addStringAlternative("MA1_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA1_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA1_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA1_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA1_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA1_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA1_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA1_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA1_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA1_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA1_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA1_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA1_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA1_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA1_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA1_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA1_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA1_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA1_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA1_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA1_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addColor("MA1_color", "Up Line Color", "", core.colors().Lime);
    indicator.parameters:addColor("MA1_color_dn", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MA1_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MA1_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("MA1_width", "Line Width", "", 2, 1, 5);
    
    indicator.parameters:addGroup("Set MA of Smoothed RSI 1")
    indicator.parameters:addInteger("MA2_Period", "MA Period", "", 5)
    indicator.parameters:addString("MA2_Method", "Smooth Period", "", "MVA");
    indicator.parameters:addStringAlternative("MA2_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA2_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA2_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA2_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA2_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA2_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA2_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA2_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA2_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA2_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA2_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA2_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA2_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA2_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA2_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA2_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA2_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA2_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA2_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA2_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA2_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addColor("MA2_color", "Up Line Color", "", core.colors().Lime);
    indicator.parameters:addColor("MA2_color_dn", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MA2_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MA2_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("MA2_width", "Line Width", "", 2, 1, 5);

    indicator.parameters:addGroup("Choose The Lines You Want to Display")
    indicator.parameters:addBoolean("RSILine1", "Enable RSI 1 Line", "", true)
    indicator.parameters:addBoolean("RSILine2", "Enable RSI 2 Line", "", false)
    indicator.parameters:addBoolean("RSILine3", "Enable RSI 3 Line", "", false)
    indicator.parameters:addBoolean("MALine1", "Enable Smoothed RSI 1", "", true)
    indicator.parameters:addBoolean("MALine2", "Enable MA of Smoothed RSI 1", "", true)

    indicator.parameters:addString("Histogram", "Choose How to Draw Histogram", "", "MA1ToLevel0")
    indicator.parameters:addStringAlternative("Histogram", "Draw Histogram for RSI 1", "", "RSI1ToMA1")
    indicator.parameters:addStringAlternative("Histogram", "Draw Histogram for Smoothed RSI 1", "", "MA1ToLevel0")
    indicator.parameters:addStringAlternative("Histogram", "Disable Histogram", "", "None")

    indicator.parameters:addString("ChangeHistogramColor", "Choose How to Change Histogram Color", "", "AsPerRSI1AndSmoothedRSI1")
    indicator.parameters:addStringAlternative("ChangeHistogramColor", "As Per Smoothed RSI-1 Direction", "", "AsPerMA1Direction")
    indicator.parameters:addStringAlternative("ChangeHistogramColor", "As Per RSI-1 and Smoothed RSI-1", "", "AsPerRSI1AndSmoothedRSI1")

    indicator.parameters:addColor("HIST_color", "Up Line Color", "", core.colors().Green);
    indicator.parameters:addColor("HIST_color_dn", "Down Line Color", "", core.colors().Brown);

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Direction change of smoothed RSI1 (MA1)");
    indi_alerts:AddAlert("Smoothed RSI1 (MA1) crosses its MA (MA2)");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first
local source = nil

local Histo;

local RSILineBuffer1;
local RSILineBuffer2;
local RSILineBuffer3;

local MALine1Up;
local MALine2Up;

local RSI1;
local RSI2;
local RSI3;
local MALine1Buffer;
local MALine2Buffer;

-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end

    source = instance.source

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 

    RSI1 = core.indicators:create("RSI", source, instance.parameters.RSI1)
    RSI2 = core.indicators:create("RSI", source, instance.parameters.RSI2)
    RSI3 = core.indicators:create("RSI", source, instance.parameters.RSI3)

    RSILineBuffer1 = instance:addStream("RSI1", core.Line, "RSI1", "RSI1", instance.parameters.RSI1_color, 0)
    RSILineBuffer1:setPrecision(math.max(2, instance.source:getPrecision()));
    RSILineBuffer1:setWidth(instance.parameters.RSI1_width)
    RSILineBuffer1:setStyle(instance.parameters.RSI1_style)
    RSILineBuffer2 = instance:addStream("RSI2", core.Line, "RSI2", "RSI2", instance.parameters.RSI2_color, 0)
    RSILineBuffer2:setPrecision(math.max(2, instance.source:getPrecision()));
    RSILineBuffer2:setWidth(instance.parameters.RSI2_width)
    RSILineBuffer2:setStyle(instance.parameters.RSI2_style)
    RSILineBuffer3 = instance:addStream("RSI3", core.Line, "RSI3", "RSI3", instance.parameters.RSI3_color, 0)
    RSILineBuffer3:setPrecision(math.max(2, instance.source:getPrecision()));
    RSILineBuffer3:setWidth(instance.parameters.RSI3_width)
    RSILineBuffer3:setStyle(instance.parameters.RSI3_style)
    MALine1Up = core.indicators:create("AVERAGES", RSILineBuffer1, MA1_Method, MA1_Period, false);
    MALine1Buffer = instance:addStream("MA1", core.Line, "MA1", "MA1", instance.parameters.MA1_color, 0)
    MALine1Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
    MALine1Buffer:setWidth(instance.parameters.MA1_width)
    MALine1Buffer:setStyle(instance.parameters.MA1_style)
    MALine2Up = core.indicators:create("AVERAGES", MALine1Up.DATA, MA2_Method, MA2_Period, false);
    MALine2Buffer = instance:addStream("MA2", core.Line, "MA2", "MA2", instance.parameters.MA2_color, 0)
    MALine2Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
    MALine2Buffer:setWidth(instance.parameters.MA2_width)
    MALine2Buffer:setStyle(instance.parameters.MA2_style)
    RSILineBuffer1:addLevel(instance.parameters.OverSell - 50, instance.parameters.OverSell_style, instance.parameters.OverSell_width, instance.parameters.OverSell_color);
    RSILineBuffer1:addLevel(instance.parameters.OverBought - 50, instance.parameters.OverBought_style, instance.parameters.OverBought_width, instance.parameters.OverBought_color);

    Histo = instance:addStream("H1", core.Bar, "H1", "H1", instance.parameters.HIST_color, 0)
    Histo:setPrecision(math.max(2, instance.source:getPrecision()));

    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if alert.id == 1 and alert.ON then
        if MALine1Up.DATA[period] > MALine1Up.DATA[period - 1] and MALine1Up.DATA[period - 1] < MALine1Up.DATA[period - 2] then
            alert:UpAlert(source, period, alert.Label .. ". Up trend", source.high[period], historical_period);
        elseif MALine1Up.DATA[period] < MALine1Up.DATA[period - 1] and MALine1Up.DATA[period - 1] > MALine1Up.DATA[period - 2] then
            alert:DownAlert(source, period, alert.Label .. ". Down trend", source.low[period], historical_period);
        end
    end
    if alert.id == 2 and alert.ON then
        if core.crossesOver(MALine1Up.DATA, MALine2Up.DATA, period) then
            alert:UpAlert(source, period, alert.Label .. ". Cross up", source.high[period], historical_period);
        elseif core.crossesUnder(MALine1Up.DATA, MALine2Up.DATA, period) then
            alert:DownAlert(source, period, alert.Label .. ". Cross down", source.low[period], historical_period);
        end
    end
    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
end

-- Indicator calculation routine
function Update(period, mode)
    RSI1:update(mode)
    RSI2:update(mode)
    RSI3:update(mode)

    RSILineBuffer1[period] = RSI1.DATA[period] - 50.0;
    MALine1Up:update(mode)
    MALine2Up:update(mode)
    if (instance.parameters.RSILine2) then
        RSILineBuffer2[period] = RSI2.DATA[period] - 50.0;
    end
    if (instance.parameters.RSILine3) then
        RSILineBuffer3[period] = RSI3.DATA[period] - 50.0;
    end

    MALine1Buffer[period] = MALine1Up.DATA[period];
    if (MALine1Up.DATA[period] < MALine1Up.DATA[period - 1]) then
        MALine1Buffer:setColor(period, instance.parameters.MA1_color_dn);
    end

    if (instance.parameters.Histogram ~= "None") then
        -- Histogram type 2: draw histogram for MA-1 (MA of the RSI-1)
        if (instance.parameters.Histogram == "RSI1ToMA1") then
            local curDif = RSILineBuffer1[period] - MALine1Up.DATA[period];
            local preDif = RSILineBuffer1[period - 1] - MALine1Up.DATA[period - 1];
            Histo[period] = curDif;
            if (curDif > 0.0) then
                if (curDif > preDif) then
                    Histo:setColor(period, instance.parameters.HIST_color)
                else
                    Histo:setColor(period, instance.parameters.HIST_color_dn)
                end
            else
                if (curDif > preDif) then
                    Histo:setColor(period, instance.parameters.HIST_color)
                else
                    Histo:setColor(period, instance.parameters.HIST_color_dn)
                end
            end
        -- Histogram type 2: draw histogram for RSI-1
        elseif (instance.parameters.Histogram == "MA1ToLevel0") then
            local curMA = MALine1Up.DATA[period];
            Histo[period] = curMA;
            -- Option 1：Histogram color changes when RSI-1 and MA crosses.
            -- That is: When RSI1>MA1 or RSI-1<MA1, histogram color will change.
            if (instance.parameters.ChangeHistogramColor == "AsPerRSI1AndSmoothedRSI1") then
                local curDif = RSILineBuffer1[period] - MALine1Up.DATA[period];
                if (curDif > 0.0) then
                    Histo:setColor(period, instance.parameters.HIST_color)
                else
                    Histo:setColor(period, instance.parameters.HIST_color_dn)
                end
            -- Option 2：Histogram color changes according to direction of smoothed RSI-1 (MA-1)
            else
                local preMA = MALine1Up.DATA[period - 1];
                if (curMA > 0.0) then
                    if (curMA > preMA) then
                        Histo:setColor(period, instance.parameters.HIST_color)
                    else
                        Histo:setColor(period, instance.parameters.HIST_color_dn)
                    end
                else
                    if (curMA < preMA) then
                        Histo:setColor(period, instance.parameters.HIST_color_dn)
                    else
                        Histo:setColor(period, instance.parameters.HIST_color)
                    end
                end
            end
        end
    end
    -- calculate MA-2, MA of first RSI (RSI-1)'s MA.
    if (instance.parameters.MALine2) then
        if (MALine2Up.DATA[period] < MALine2Up.DATA[period - 1]) then
            MALine2Buffer:setColor(period, instance.parameters.MA2_color_dn);
        end
    end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function AsyncOperationFinished(cookie)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

indi_alerts.Version = "1.2";
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts.total_alerts = 2;
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
    indicator.parameters:addBoolean("use_telegram", "Send Telegram", "", false);
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

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Up Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    
    indicator.parameters:addFile("Down" .. self.last_id, Label .. " Down Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    
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
    for i = 1, self.total_alerts, 1 do 
        local alert = {};
        alert.id = i;
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

    if instance.parameters.telegram_key ~= "" and instance.parameters.use_telegram then
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

