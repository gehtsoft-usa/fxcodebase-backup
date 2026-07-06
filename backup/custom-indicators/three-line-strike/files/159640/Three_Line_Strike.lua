-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76044

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
local vars = {};
function Init()
    indicator:name("IU Three Line Strike Candlestick Pattern");
    indicator:description("IU Three Line Strike Candlestick Pattern");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    signaler:Init(indicator.parameters);
end

local source;
local plot1;
local plot2;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["bear_candle"] = instance:addInternalStream(0, 0);
    vars["bullish_low_point"] = instance:addInternalStream(0, 0);
    signaler:Prepare(nameOnly);
    vars["bull_candle"] = instance:addInternalStream(0, 0);
    vars["bearish_high_point"] = instance:addInternalStream(0, 0);
    plot1 = instance:createTextOutput("plot1", "", "Arial", 12, core.H_Center, core.V_Center, core.colors().Green + math.floor(80 / 100 * 255) * 16777216);
    plot2 = instance:createTextOutput("plot2", "", "Arial", 12, core.H_Center, core.V_Center, core.colors().Red + math.floor(80 / 100 * 255) * 16777216);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Box:Clear();
        SafeSetFloat(vars["bullish_low_point"], period, nil);
        SafeSetFloat(vars["bearish_high_point"], period, nil);
    else
        SafeSetFloat(vars["bullish_low_point"], period, SafeGetFloat(vars["bullish_low_point"], period - 1));
        SafeSetFloat(vars["bearish_high_point"], period, SafeGetFloat(vars["bearish_high_point"], period - 1));
    end
    SafeSetBool(vars["bear_candle"], period, (source.close:tick(period) < source.open:tick(period)));
    three_bear_cond = SafeGetBool(vars["bear_candle"], period - 1) and SafeGetBool(vars["bear_candle"], period - 2) and SafeGetBool(vars["bear_candle"], period - 3);
    bear_close_cond = SafeGreater(source.close:tick(period - 3), source.close:tick(period - 2)) and SafeGreater(source.close:tick(period - 2), source.close:tick(period - 1));
    bull_pattern_cond = (source.close:tick(period) > source.open:tick(period)) and SafeGreater(source.close:tick(period), source.open:tick(period - 3)) and SafeGreater(source.high:tick(period), source.high:tick(period - 3)) and three_bear_cond and bear_close_cond;
    if bull_pattern_cond and (period ~= source:size() - 1 or mode == core.UpdateLast) then
        highest = SafeMax(source.high:tick(period), source.high:tick(period - 3), source.high:tick(period - 2), source.high:tick(period - 1));
        lowest = SafeMin(source.low:tick(period), source.low:tick(period - 3), source.low:tick(period - 2), source.low:tick(period - 1));
        SafeSetFloat(vars["bullish_low_point"], period, lowest);
        Box:New(core.formatDate(source:date(period - 4)), "1", period - 4, highest, period + 1, lowest):SetBgColor(core.colors().Lime + math.floor(70 / 100 * 255) * 16777216):SetBorderColor(nil);
        if "once_per_bar" == "all" or vars["alert1_last_date"] ~= source:date(period) then
            vars["alert1_last_date"] = source:date(period);
            signaler:SignalEx(nil, "Bullish Three Line Strike" .. SymInfo:GetTicker(), period, source);
        end
    end
    SafeSetBool(vars["bull_candle"], period, (source.close:tick(period) > source.open:tick(period)));
    three_bull_cond = SafeGetBool(vars["bull_candle"], period - 1) and SafeGetBool(vars["bull_candle"], period - 2) and SafeGetBool(vars["bull_candle"], period - 3);
    bull_close_cond = SafeLess(source.close:tick(period), source.close:tick(period - 2)) and SafeLess(source.close:tick(period), source.close:tick(period - 1));
    bear_pattern_cond = (source.close:tick(period) < source.open:tick(period)) and SafeLess(source.close:tick(period), source.open:tick(period - 3)) and SafeLess(source.low:tick(period), source.low:tick(period - 3)) and three_bull_cond and bull_close_cond;
    if bear_pattern_cond and (period ~= source:size() - 1 or mode == core.UpdateLast) then
        highest = SafeMax(source.high:tick(period), source.high:tick(period - 3), source.high:tick(period - 2), source.high:tick(period - 1));
        lowest = SafeMin(source.low:tick(period), source.low:tick(period - 3), source.high:tick(period - 2), source.high:tick(period - 1));
        SafeSetFloat(vars["bearish_high_point"], period, highest);
        Box:New(core.formatDate(source:date(period - 4)), "2", period - 4, highest, period + 1, lowest):SetBgColor(core.colors().Red + math.floor(70 / 100 * 255) * 16777216):SetBorderColor(nil);
        if "once_per_bar" == "all" or vars["alert2_last_date"] ~= source:date(period) then
            vars["alert2_last_date"] = source:date(period);
            signaler:SignalEx(nil, "Bearish Three Line Strike" .. SymInfo:GetTicker(), period, source);
        end
    end
    PlotShape:SetValue(plot1, period, source, Triary(bull_pattern_cond, SafeGetFloat(vars["bullish_low_point"], period), nil), "Bullish " .. "\n " .. "3 Line Strike", "Bullish " .. "\n " .. "3 Line Strike", "absolute");
    PlotShape:SetValue(plot2, period, source, Triary(bear_pattern_cond, SafeGetFloat(vars["bearish_high_point"], period), nil), "Bearish " .. "\n " .. "3 Line Strike", "Bearish " .. "\n " .. "3 Line Strike", "absolute");
end
function Draw(stage, context)
    Box:Draw(stage, context);
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
end
function SafeMinus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left - right;
end
function SafeMultiply(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left * right;
end
function SafePlus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left + right;
end
function SafeConcat(left, right)
    if left == nil then
        return right;
    end
    if right == nil then
        return left;
    end
    return left .. right;
end
function SafeDivide(left, right)
    if left == nil or right == nil or right == 0 then
        return nil;
    end
    return left / right;
end
function SafeGreater(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left > right;
end
function SafeGE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left >= right;
end
function SafeLess(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left < right;
end
function SafeLE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left <= right;
end
function SafeMax(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.max(left, right);
end
function SafeMin(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.min(left, right);
end
function SafeAbs(value)
    if value == nil then
        return nil;
    end
    return math.abs(value);
end
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function SafeSetBool(stream, period, value)
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil then
        return nil;
    end
    if not stream:hasData(period) then
        return nil;
    end
    return stream[period];
end
function Float(number)
    return number and number or nil;
end
function Int(number)
    return number and number or nil;
end
function Color(color)
    return color and color or nil;
end
function ToLine(line)
    return line;
end
function ToBox(box)
    return box;
end
function Round(num, idp)
    if num == nil then
        return nil;
    end
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
function Nz(value, defaultValue)
    if defaultValue == nil then
        defaultValue = 0;
    end
    return value and value or defaultValue;
end
function Triary(condition, trueValue, falseValue)
    if condition == nil or condition == false then
        return falseValue;
    end
    return trueValue;
end
function SafeCrossesUnder(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesUnder(val1, val2, period);
end
function SafeCrossesOver(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesOver(val1, val2, period);
end
function SafeCrosses(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crosses(val1, val2, period);
end
function SafeCos(val)
    if val == nil then
        return nil;
    end
    return math.cos(val);
end
function SafeSin(val)
    if val == nil then
        return nil;
    end
    return math.sin(val);
end
Graphics = {};
Graphics.NextId = 1;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
    if color == nil then
        return -1;
    end
    for i, pen in ipairs(Graphics.Pens) do
        if pen.Width == width and pen.Color == color then
            context:createPen(pen.Id, context:convertPenStyle(style), width, color);
            return pen.Id;
        end
    end
    local newPen = {};
    newPen.Id = Graphics.NextId;
    newPen.Width = width;
    newPen.Color = color;

    context:createPen(newPen.Id, context:convertPenStyle(style), width, color);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Pens[#Graphics.Pens + 1] = newPen;
    return newPen.Id;
end
function Graphics:FindBrush(color, context)
    if color == nil then
        return -1;
    end
    for i, brush in ipairs(Graphics.Brushes) do
        if brush.Color == color then
            context:createSolidBrush(brush.Id, color)
            return brush.Id;
        end
    end
    local newBrush = {};
    newBrush.Id = Graphics.NextId;
    newBrush.Color = color;
    context:createSolidBrush(newBrush.Id, color)
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Brushes[#Graphics.Brushes + 1] = newBrush;
    return newBrush.Id;
end
function Graphics:FindFont(font, xSize, ySize, corner, context)
    for i, font in ipairs(self.Fonts) do
        if font.xSize == xSize and font.Name == font then
            return font.Id;
        end
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    newFont.xSize = xSize;
    newFont.Name = font;
    context:createFont(newFont.Id, font, 0, xSize, context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Graphics:SplitColorAndTransparency(clr)
    if clr == nil then
        return nil, nil;
    end
    local transparency = (math.floor(clr / 16777216) % 255);
    local color = clr - transparency * 16777216;
    return color, transparency;
end
function Graphics:GetColor(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return color;
end
function Graphics:GetTransparency(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return transparency;
end
function Graphics:GetTransparencyPercent(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
Box = {};
Box.AllBoxs = {};
Box.AllSeries = {};
function Box:Clear()
    Box.AllBoxs = {};
    Box.AllSeries = {};
end
function Box:SetLeftTop(box, left, top)
    if box == nil then
        return;
    end
    box:SetLeft(left);
    box:SetTop(top);
end
function Box:SetRightBottom(box, right, bottom)
    if box == nil then
        return;
    end
    box:SetRight(right);
    box:SetBottom(bottom);
end
function Box:SetRight(box, right)
    if box == nil then
        return;
    end
    box:SetRight(right);
end
function Box:SetTop(box, top)
    if box == nil then
        return;
    end
    box:SetTop(top);
end
function Box:SetBottom(box, bottom)
    if box == nil then
        return;
    end
    box:SetBottom(bottom);
end
function Box:SetLeft(box, left)
    if box == nil then
        return;
    end
    box:SetLeft(left);
end
function Box:GetBottom(box)
    if box == nil then
        return nil;
    end
    return box:GetBottom();
end
function Box:GetTop(box)
    if box == nil then
        return nil;
    end
    return box:GetTop();
end
function Box:GetLeft(box)
    if box == nil then
        return nil;
    end
    return box:GetLeft();
end
function Box:GetRight(box)
    if box == nil then
        return nil;
    end
    return box:GetRight();
end
function Box:SetText(box, text)
    if box == nil then
        return;
    end
    box:SetText(text);
end
function Box:SetTextColor(box, text_color)
    if box == nil then
        return;
    end
    box:SetTextColor(text_color);
end
function Box:SetTextHAlign(box, text_halign)
    if box == nil then
        return;
    end
    box:SetTextHAlign(text_halign);
end
function Box:SetTextSize(box, text_size)
    if box == nil then
        return;
    end
    box:SetTextSize(text_size);
end
function Box:SetBorderStyle(box, style)
    if box == nil then
        return;
    end
    box:SetBorderStyle(style);
end
function Box:New(id, seriesId, left, top, right, bottom)
    local newBox = {};
    newBox.SeriesId = seriesId;
    newBox.Left = left;
    function newBox:SetLeft(left)
        self.Left = left;
        return self;
    end
    function newBox:GetLeft()
        return self.Left;
    end
    newBox.Top = top;
    function newBox:SetTop(top)
        self.Top = top;
        return self;
    end
    function newBox:GetTop()
        return self.Top;
    end
    newBox.Right = right;
    function newBox:SetRight(right)
        self.Right = right;
        return self;
    end
    function newBox:GetRight()
        return self.Right;
    end
    newBox.Bottom = bottom;
    function newBox:SetBottom(bottom)
        self.Bottom = bottom;
        return self;
    end
    function newBox:GetBottom()
        return self.Bottom;
    end
    newBox.BorderWidth = 1;
    newBox.BgColor = core.colors().Blue;
    function newBox:SetBgColor(clr)
        color, transparency = Graphics:SplitColorAndTransparency(clr);
        self.BgColorTransparency = transparency;
        self.BgColor = color;
        self.BrushId = nil;
        return self;
    end
    newBox.BorderColor = core.colors().Blue;
    function newBox:SetBorderColor(clr)
        color, transparency = Graphics:SplitColorAndTransparency(clr);
        self.BorderColor_transparency = transparency;
        self.BorderColor = color;
        self.PenId = nil;
        return self;
    end
    newBox.BorderStyle = "solid";
    newBox.BorderStyleIndicore = core.LINE_SOLID;
    function newBox:SetBorderStyle(style)
        self.BorderStyle = style;
        if style == "solid" or style == "arrow_right" or style == "arrow_left" or style == "arrow_both" then
            newBox.BorderStyleIndicore = core.LINE_SOLID;
        elseif style == "dotted" then
            newBox.BorderStyleIndicore = core.LINE_DOT;
        elseif style == "dashed" then
            newBox.BorderStyleIndicore = core.LINE_DASH;
        end
        self.PenId = nil;
        return self;
    end
    newBox.Text = nil;
    function newBox:SetText(text)
        self.Text = text;
        return self;
    end
    newBox.TextColor = nil;
    function newBox:SetTextColor(text_color)
        self.TextColor = text_color;
        return self;
    end
    newBox.TextHAlign = nil;
    function newBox:SetTextHAlign(text_halign)
        self.TextHAlign = text_halign;
        return self;
    end
    newBox.TextSize = nil;
    function newBox:SetTextSize(text_size)
        self.TextSize = text_size;
        return self;
    end
    function newBox:getCoordinates(context, x, y, W, H)
        return x - W / 2, y - H / 2, x + W / 2, y + H / 2;
    end
    function newBox:Draw(stage, context)
        if self.Top == nil or self.Left == nil or self.Bottom == nil or self.Right == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.BorderWidth, self.BorderColor, self.BorderStyleIndicore, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.BgColor, context);
        end
        _, y1 = context:pointOfPrice(self.Top);
        _, x1 = context:positionOfBar(self.Left);
        _, y2 = context:pointOfPrice(self.Bottom);
        _, x2 = context:positionOfBar(self.Right);
        if (x1 == x2) then
            x2 = x1 + 1;
        end
        if (y1 == y2) then
            y2 = y1 + 1
        end
        context:drawRectangle(self.PenId, self.BrushId, x1, y1, x2, y2, self.BgColorTransparency)
        context:drawRectangle(self.PenId, -1, x1, y1, x2, y2)
        if self.Text ~= nil and self.Text ~= "" then
            if self.FontId == nil then
                self.FontId = Graphics:FindFont("Arial", 10, 0, context.LEFT, context);
            end
            local W, H = context:measureText(self.FontId, self.Text, context.LEFT);
            local x_from, y_from, x_to, y_to = self:getCoordinates(context, (x1 + x2) / 2, (y1 + y2) / 2, W, H);
            context:drawText(self.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
        end
    end
    function newBox:Get(index)
        return Box.AllSeries[self.SeriesId][index + 1];
    end
    self.AllBoxs[id .. "_" .. seriesId] = newBox;
    if self.AllSeries[seriesId] == nil then
        self.AllSeries[seriesId] = {};
    end
    table.insert(self.AllSeries[seriesId], 1, newBox);
    return newBox;
end
function Box:Delete(box)
    if box == nil then
        return;
    end
    self:removeFromAllBoxes(box);
    self:removeFromSeries(box);
end
function Box:removeFromSeries(box)
    for i = 1, #self.AllSeries[box.SeriesId] do
        if self.AllSeries[box.SeriesId][i] == box then
            table.remove(self.AllSeries[box.SeriesId], i);
            return;
        end
    end
end
function Box:removeFromAllBoxes(box)
    for key, value in pairs(self.AllBoxs) do
        if value == box then
            self.AllBoxs[key] = nil;
            return;
        end
    end
end
function Box:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for id, Box in pairs(self.AllBoxs) do
        Box:Draw(stage, context);
    end
end
signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.7";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};
signaler._commands = {};
signaler.lastIndexSerial = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) 
    if modules == nil then
        self._ids_start = 100; 
        return;
    end
    for _, module in pairs(modules) do 
        self:OnNewModule(module); 
        module:OnNewModule(self); 
    end 
    modules[#modules + 1] = self; 
    self._ids_start = (#modules) * 100; 
end

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
    if cookie == self._advanced_alert_timer and (self.last_req == nil or not self.last_req:loading()) then
        if #self._alerts > 0 then
            local data = self:ArrayToJSON(self._alerts);
            self._alerts = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        end
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
function signaler:getSource(source)
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
    return source;
end
function signaler:SignalEx(index, message, period, source)
    source = self:getSource(source);
    if index ~= nil then
        if (self.lastIndexSerial[index] == source:serial(period)) then
            return;
        end
        self.lastIndexSerial[index] = source:serial(period);
    end
    local interval = string.find(message, "{{interval}}");
    if interval ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. source:barSize()
            .. string.sub(message, interval + string.len("{{interval}}"));
    end
    local close = string.find(message, "{{close}}");
    if close ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. win32.formatNumber(source.close[period], false, source:getDisplayPrecision())
            .. string.sub(message, interval + string.len("{{close}}"));
    end
    self:Signal(message, source);
end
function signaler:Signal(message, source)
    source = self:getSource(source);
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

function signaler:SendCommand(command)
    if self._external_executer_key == nil or core.host.Trading:getTradingProperty("isSimulation") or command == "" then
        return;
    end
    local command = 
    {
        Text = command
    };
    self._commands[#self._commands + 1] = command;
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
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end

    parameters:addGroup("  Telegram/Discord/Other platforms");
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");

    parameters:addGroup("  Trade coping");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
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
    end
    if instance.parameters.external_executer_key ~= "" and instance.parameters.use_external_executer then
        self._external_executer_key = instance.parameters.external_executer_key;
    end
    if self.external_executer_key ~= nil or self._advanced_alert_key ~= nil then
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
SymInfo = {};
function SymInfo:GetMintick()
    return instance.source:pipSize();
end
function SymInfo:GetType()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    if offer.InstrumentType == 1 then
        return "forex";
    elseif offer.InstrumentType == 2 then
        return "index";
    elseif offer.InstrumentType == 3 then
        return "commodity";
    elseif offer.InstrumentType == 4 then
        return "";
    elseif offer.InstrumentType == 5 then
        return "";
    elseif offer.InstrumentType == 6 then
        return "";
    elseif offer.InstrumentType == 7 then
        return "";
    elseif offer.InstrumentType == 8 then
        return "";
    elseif offer.InstrumentType == 9 then
        return "crypto";
    end
    return "";
end
function SymInfo:GetBaseCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.ContractCurrency;
end
function SymInfo:GetCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.Instrument;
end
function SymInfo:GetTicker()
    return instance.source:instrument();
end
PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location)
    if not value then
        plot:setNoData(period);
        return;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label);
        return;
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label);
        return;
    end
    plot:set(period, value, text, label);
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76044

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 