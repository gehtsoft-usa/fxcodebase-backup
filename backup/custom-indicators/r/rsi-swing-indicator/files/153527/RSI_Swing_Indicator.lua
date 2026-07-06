-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74399

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+


function Init()
    indicator:name("RSI Swing Indicator");
    indicator:description("RSI Swing Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addString("param1", "RSI Source", "", "close");
    indicator.parameters:addStringAlternative("param1", "Open", "", "open");
    indicator.parameters:addStringAlternative("param1", "High", "", "high");
    indicator.parameters:addStringAlternative("param1", "Low", "", "low");
    indicator.parameters:addStringAlternative("param1", "Close", "", "close");
    indicator.parameters:addStringAlternative("param1", "Median", "", "median");
    indicator.parameters:addStringAlternative("param1", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param1", "Weighted", "", "weighted");
    indicator.parameters:addInteger("param2", "RSI Length", "", 7);
    indicator.parameters:addInteger("param3", "RSI Overbought", "", 70);
    indicator.parameters:addInteger("param4", "RSI Oversold", "", 30);
end

local source;
local vars = {};
local laststate;
local hh;
local ll;
local last_actual_label_hh_price;
local last_actual_label_ll_price;
function Create_obLabelText()
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            if (last_actual_label_hh_price:tick(period) < source.high[period]) then
                return "HH";
            else
                return "LH";
            end
        end
    };
end
function Create_osLabelText()
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            if (last_actual_label_ll_price:tick(period) < source.low[period]) then
                return "HL";
            else
                return "LL";
            end
        end
    };
end
function Create_createOverBoughtLabel(isIt)
    local local_vars = {};
    local_vars["obLabelTextFunc2"] = Create_obLabelText();
    local_vars["osLabelTextFunc3"] = Create_osLabelText();
    return {
        GetValue = function(period, mode)
            if isIt then
                return Label:New(core.formatDate(source:date(period)) .. "_1", period, nil):SetText(local_vars["obLabelTextFunc2"].GetValue(period, mode)):SetColor(core.colors().Red);
            else
                return Label:New(core.formatDate(source:date(period)) .. "_2", period, nil):SetText(local_vars["osLabelTextFunc3"].GetValue(period, mode)):SetColor(core.colors().Green);
            end
        end
    };
end
function Create_moveOverBoughtLabel()
    local local_vars = {};
    local_vars["obLabelTextFunc6"] = Create_obLabelText();
    return {
        GetValue = function(period, mode)
            Label:SetX(vars["labelhh"], period);
            Label:SetY(vars["labelhh"], source.high[period]);
            Label:SetText(vars["labelhh"], local_vars["obLabelTextFunc6"].GetValue(period, mode));
            Line:SetX1(vars["line_up"], period);
            return Line:SetY1(vars["line_up"], source.high[period]);
        end
    };
end
function Create_moveOversoldLabel()
    local local_vars = {};
    local_vars["osLabelTextFunc8"] = Create_osLabelText();
    return {
        GetValue = function(period, mode)
            Label:SetX(vars["labelll"], period);
            Label:SetY(vars["labelll"], source.low[period]);
            Label:SetText(vars["labelll"], local_vars["osLabelTextFunc8"].GetValue(period, mode));
            Line:SetX1(vars["line_down"], period);
            return Line:SetY1(vars["line_down"], source.low[period]);
        end
    };
end
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["rsiSource"] = source[instance.parameters.param1];
    vars["rsiLength"] = instance.parameters.param2;
    vars["rsiOverbought"] = instance.parameters.param3;
    vars["rsiOvesold"] = instance.parameters.param4;
    vars["RSI1"] = core.indicators:create("RSI", vars["rsiSource"], vars["rsiLength"]);
    laststate = instance:addInternalStream(0, 0);
    hh = instance:addInternalStream(0, 0);
    ll = instance:addInternalStream(0, 0);
    last_actual_label_hh_price = instance:addInternalStream(0, 0);
    last_actual_label_ll_price = instance:addInternalStream(0, 0);
    vars["createOverBoughtLabelFunc1"] = Create_createOverBoughtLabel(true);
    vars["createOverBoughtLabelFunc4"] = Create_createOverBoughtLabel(false);
    vars["moveOverBoughtLabelFunc5"] = Create_moveOverBoughtLabel();
    vars["moveOversoldLabelFunc7"] = Create_moveOversoldLabel();
    vars["moveOverBoughtLabelFunc9"] = Create_moveOverBoughtLabel();
    vars["moveOversoldLabelFunc10"] = Create_moveOversoldLabel();
    vars["moveOverBoughtLabelFunc11"] = Create_moveOverBoughtLabel();
    vars["moveOversoldLabelFunc12"] = Create_moveOversoldLabel();
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Label:Clear();
        Line:Clear();
        laststate[period] = 0;
        hh[period] = source.low[period];
        ll[period] = source.high[period];
        vars["labelll"] = nil;
        vars["labelhh"] = nil;
        vars["line_up"] = nil;
        vars["line_down"] = nil;
        last_actual_label_hh_price[period] = 0.0;
        last_actual_label_ll_price[period] = 0.0;
    else
        laststate[period] = laststate:tick(period - 1);
        hh[period] = hh:tick(period - 1);
        ll[period] = ll:tick(period - 1);
        last_actual_label_hh_price[period] = last_actual_label_hh_price:tick(period - 1);
        last_actual_label_ll_price[period] = last_actual_label_ll_price:tick(period - 1);
    end
    vars["RSI1"]:update(mode);
    rsiValue = vars["RSI1"].DATA:tick(period);
    isOverbought = SafeGE(rsiValue, vars["rsiOverbought"]);
    isOversold = SafeLE(rsiValue, vars["rsiOvesold"]);
    if (laststate:tick(period) == 2) and isOverbought then
        hh[period] = source.high[period];
        vars["labelhh"] = vars["createOverBoughtLabelFunc1"].GetValue(period, mode);
        last_actual_label_ll_price[period] = Label:GetY(vars["labelll"]);
        labelll_ts = Label:GetX(vars["labelll"]);
        labelll_price = Label:GetY(vars["labelll"]);
        vars["line_up"] = Line:New(period, source.high[period], labelll_ts, labelll_price);
    end
    if (laststate:tick(period) == 1) and isOversold then
        ll[period] = source.low[period];
        vars["labelll"] = vars["createOverBoughtLabelFunc4"].GetValue(period, mode);
        last_actual_label_hh_price[period] = Label:GetY(vars["labelhh"]);
        labelhh_ts = Label:GetX(vars["labelhh"]);
        labelhh_price = Label:GetY(vars["labelhh"]);
        vars["line_down"] = Line:New(period, source.high[period], labelhh_ts, labelhh_price);
    end
    if isOverbought then
        if (source.high[period] >= hh:tick(period)) then
            hh[period] = source.high[period];
            vars["moveOverBoughtLabelFunc5"].GetValue(period, mode);
        end
        laststate[period] = 1;
    end
    if isOversold then
        if (source.low[period] <= ll:tick(period)) then
            ll[period] = source.low[period];
            vars["moveOversoldLabelFunc7"].GetValue(period, mode);
        end
        laststate[period] = 2;
    end
    if (laststate:tick(period) == 1) and isOverbought then
        if (hh:tick(period) <= source.high[period]) then
            hh[period] = source.high[period];
            vars["moveOverBoughtLabelFunc9"].GetValue(period, mode);
        end
    end
    if (laststate:tick(period) == 2) and isOversold then
        if (source.low[period] <= ll:tick(period)) then
            ll[period] = source.low[period];
            vars["moveOversoldLabelFunc10"].GetValue(period, mode);
        end
    end
    if (laststate:tick(period) == 1) then
        if (hh:tick(period) <= source.high[period]) then
            hh[period] = source.high[period];
            vars["moveOverBoughtLabelFunc11"].GetValue(period, mode);
        end
    end
    if (laststate:tick(period) == 2) then
        if (ll:tick(period) >= source.low[period]) then
            ll[period] = source.low[period];
            vars["moveOversoldLabelFunc12"].GetValue(period, mode);
        end
    end
end
function Draw(stage, context)
    Label:Draw(stage, context);
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
Label = {};
Label.AllLabels = {};
function Label:Clear()
    Label.AllLabels = {};
end
function Label:SetText(label, text)
    if label == nil then
        return;
    end
    label:SetText(text);
end
function Label:SetX(label, x)
    if label == nil then
        return;
    end
    label:SetX(x);
end
function Label:SetY(label, y)
    if label == nil then
        return;
    end
    label:SetY(y);
end
function Label:GetX(label)
    if label == nil then
        return;
    end
    return label:GetX();
end
function Label:GetY(label)
    if label == nil then
        return;
    end
    return label:GetY();
end
function Label:New(id, period, price)
    local newLabel = {};
    newLabel.X = period;
    function newLabel:SetX(x)
        self.X = x;
        return self;
    end
    function newLabel:GetX()
        return self.X;
    end
    newLabel.Y = price;
    function newLabel:SetY(y)
        self.Y = y;
        return self;
    end
    function newLabel:GetY()
        return self.Y;
    end
    newLabel.Text = "";
    function newLabel:SetText(text)
        self.Text = text;
        return self;
    end
    newLabel.BGColor = nil;
    function newLabel:SetColor(clr)
        self.BgColorTransparency = (math.floor(clr / 16777216) % 256);
        self.BGColor = clr;
        self.BGPenId = nil;
        self.BGBrushId = nil;
        return self;
    end
    newLabel.TextColor = core.colors().Black;
    function newLabel:SetTextColor(clr)
        self.TextColor = clr;
        return self;
    end
    function newLabel:Draw(stage, context)
        if self.X == nil or self.Y == nil then
            return;
        end
        local W, H = context:measureText(Label.FontId, self.Text, context.LEFT);
        visible, y = context:pointOfPrice(self.Y);
        x1, x = context:positionOfBar(self.X)
        x_from = x - W / 2;
        y_from = y - H / 2;
        x_to = x + W / 2;
        y_to = y + H / 2;
        if self.BGColor ~= nil then
            if self.BGPenId == nil then
                self.BGPenId = Graphics:FindPen(1, self.BGColor, core.LINE_SOLID, context);
            end
            if self.BGBrushId == nil then
                self.BGBrushId = Graphics:FindBrush(self.BGColor, context);
            end
            context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency)
        end
        context:drawText(Label.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
    end
    self.AllLabels[id] = newLabel;
    return newLabel;
end
function Label:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if Label.FontId == nil then
        Label.FontId = Graphics:FindFont("Arial", 0, context:pointsToPixels(10), context.LEFT, context);
    end
    for id, label in pairs(self.AllLabels) do
        label:Draw(stage, context);
    end
end
Graphics = {};
Graphics.NextId = 2;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
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
    if Graphics.Fonts[1] ~= nil then
        return Graphics.Fonts[1].Id;
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    context:createFont(newFont.Id, "Arial", 0, context:pointsToPixels(10), context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Color(color)
    if color == nil then
        return core.colors().Black + 4294967296;
    end
    return color;
end
Line = {};
Line.AllLines = {};
function Line:Clear()
    Line.AllLines = {};
end
function Line:SetXY1(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY1(x, y);
end
function Line:SetXY2(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY2(x, y);
end
function Line:SetX1(line, x)
    if line == nil then
        return;
    end
    line:SetX1(x);
end
function Line:SetX2(line, x)
    if line == nil then
        return;
    end
    line:SetX2(x);
end
function Line:SetY1(line, y)
    if line == nil then
        return;
    end
    line:SetY1(y);
end
function Line:SetY2(line, y)
    if line == nil then
        return;
    end
    line:SetY2(y);
end
function Line:SetColor(line, clr)
    if line == nil then
        return;
    end
    line:SetColor(clr);
end
function Line:SetWidth(line, width)
    if line == nil then
        return;
    end
    line:SetWidth(width);
end
function Line:New(x1, y1, x2, y2)
    local newLine = {};
    newLine.X1 = x1;
    newLine.Y1 = y1;
    newLine.X2 = x2;
    newLine.Y2 = y2;
    function newLine:SetXY1(x, y)
        self.X1 = x;
        self.Y1 = y;
    end
    function newLine:SetXY2(x, y)
        self.X2 = x;
        self.Y2 = y;
    end
    function newLine:SetX1(x)
        self.X1 = x;
    end
    function newLine:SetX2(x)
        self.X2 = x;
    end
    function newLine:SetY1(y)
        self.Y1 = y;
    end
    function newLine:SetY2(y)
        self.Y2 = y;
    end
    newLine.Color = core.colors().Blue;
    function newLine:SetColor(clr)
        self.Color = clr;
        self.PenValid = false;
    end
    newLine.Width = 1;
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenValid = false;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil then
            return;
        end
        if not self.PenValid then
            self.PenId = Graphics:FindPen(self.Width, self.Color, core.LINE_SOLID, context);
            self.PenValid = true;
        end
        _, y1 = context:pointOfPrice(self.Y1);
        _, x1 = context:positionOfBar(self.X1);
        _, y2 = context:pointOfPrice(self.Y2);
        _, x2 = context:positionOfBar(self.X2);
        context:drawLine(self.PenId, x1, y1, x2, y2);
    end
    self.AllLines[#self.AllLines + 1] = newLine;
    return newLine;
end
function Line:Delete(line)
    for i = 1, #self.AllLines do
        if self.AllLines[i] == line then
            table.remove(self.AllLines, i);
            return;
        end
    end
end
function Line:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLines) do
        value:Draw(stage, context);
    end
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+