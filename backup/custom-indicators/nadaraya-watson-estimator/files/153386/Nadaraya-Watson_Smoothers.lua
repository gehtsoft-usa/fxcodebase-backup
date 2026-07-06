-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74323&p=153386#p153386

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
    indicator:name("Nadaraya-Watson Smoothers [LuxAlgo]");
    indicator:description("Nadaraya-Watson Smoothers [LuxAlgo]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addDouble("param1", "Bandwidth", "", 8., 0);
    indicator.parameters:addString("param2", "Source", "", "close");
    indicator.parameters:addStringAlternative("param2", "Open", "", "open");
    indicator.parameters:addStringAlternative("param2", "High", "", "high");
    indicator.parameters:addStringAlternative("param2", "Low", "", "low");
    indicator.parameters:addStringAlternative("param2", "Close", "", "close");
    indicator.parameters:addStringAlternative("param2", "Median", "", "median");
    indicator.parameters:addStringAlternative("param2", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param2", "Weighted", "", "weighted");
    indicator.parameters:addBoolean("param3", "Repainting Smoothing", "", false);
    indicator.parameters:addColor("param4", "Up Color", "", core.colors().Teal);
    indicator.parameters:addColor("param5", "Down Color", "", core.colors().Red);
end

local source;
local params = {};
local den;
local gaussFunc1_param1;
function Create_gauss(x, h)
    return {
        GetValue = function(period)
            return math.exp((-(math.pow(x:tick(period), 2) / (h * h * 2))));
        end
    };
end
local gaussFunc2_param1;
local out;
local plot1;
local vars = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["h"] = instance.parameters.param1;
    vars["src"] = source[instance.parameters.param2];
    vars["repaint"] = instance.parameters.param3;
    vars["upCss"] = instance.parameters.param4;
    vars["dnCss"] = instance.parameters.param5;
    den = instance:addInternalStream(0, 0);
    gaussFunc1_param1 = instance:addInternalStream(0, 0);
    vars["gaussFunc1"] = Create_gauss(gaussFunc1_param1, vars["h"]);
    gaussFunc2_param1 = instance:addInternalStream(0, 0);
    vars["gaussFunc2"] = Create_gauss(gaussFunc2_param1, vars["h"]);
    out = instance:addInternalStream(0, 0);
    plot1 = instance:addStream("plot1", core.Line, "NWE Endpoint Estimator", "NWE Endpoint Estimator", core.colors().Blue, 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    instance:ownerDrawn(true);
end

function Update(period, mode)


	
    if period == 0 or mode == core.UpdateAll then
        vars["ln"] = Array:NewLine(0);
        Line:Clear();
        vars["coefs"] = Array:NewFloat(0);
        den[period] = 0.;
        Label:Clear();
        Table:Clear();
        vars["tb"] = Table:New("top_right", 1, 1):SetBorderWidth(1):SetBgColor(core.rgb(30, 34, 45)):SetBorderColor(core.rgb(55, 58, 70)):SetFrameColor(core.rgb(55, 58, 70)):SetFrameWidth(1);
    else
        den[period] = den:tick(period - 1);
    end
    n = period;
	
	

	
    if (period == 0 or mode == core.UpdateAll) and vars["repaint"] then
        for i = 0, 499, 1 do
            vars["ln"]:Push(Line:New(nil, nil, nil, nil));
        end
    end
    if (period == 0 or mode == core.UpdateAll) and not vars["repaint"] then
        for i = 0, 499, 1 do
            gaussFunc1_param1[period] = i;
            w = vars["gaussFunc1"].GetValue(period);
            vars["coefs"]:Push(w);
        end
        den[period] = vars["coefs"]:Sum();
    end
    out[period] = 0.;
	
	if period <= 499 then
	return;
	end
	
    if not vars["repaint"] then
        for i = 0, 499, 1 do
            out[period] = out[period] + vars["src"]:tick(period - i) * vars["coefs"]:Get(i);
        end
    end
    out[period] = out[period] / den:tick(period);
    y2 = nil;
    y1 = nil;
    y1_d = nil;
    l = nil;
    lb = nil;
    if period == source:size() - 1 and vars["repaint"] then
        for i = 0, math.min(499, n - 1), 1 do
            sum = 0.;
            sumw = 0.;
            for j = 0, math.min(499, n - 1), 1 do
                gaussFunc2_param1[period] = i - j;
                w = vars["gaussFunc2"].GetValue(period);
                sum = sum + vars["src"]:tick(period - j) * w;
                sumw = sumw + w;
            end
            y2 = sum / sumw;
            d = SafeMinus(y2, y1);
            l = vars["ln"]:Get(i);
            l:SetXY1(n - i + 1, y1);
            l:SetXY2(n - i, y2);
            l:SetColor(((SafeGrater(y2, y1)) and (vars["dnCss"]) or (vars["upCss"])));
            l:SetWidth(2);
            if SafeLess(SafeMultiply(d, y1_d), 0) then
                Label:New(core.formatDate(source:date(n - i + 1)) .. "_1", n - i + 1, vars["src"]:tick(period - i)):SetText(((SafeLess(y1_d, 0)) and ("Up") or ("Dn"))):SetColor(Color(nil)):SetTextColor(((SafeLess(y1_d, 0)) and (vars["upCss"]) or (vars["dnCss"])));
            end
            y1 = y2;
            y1_d = d;
        end
    end
    if vars["repaint"] then
        vars["tb"]:CellText(0, 0, "Repainting Mode Enabled"):CellTextColor(0, 0, core.colors().White);
    end
    plot1[period] = ((vars["repaint"]) and (nil) or (out[period]));
    if out:first() > period - 1 then return; end
    plot1:setColor(period, (((out[period] > out[period - 1])) and (vars["upCss"]) or (vars["dnCss"])));
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
    Table:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
Array = {};
function Array:NewArray(size)
    local newArray = {};
    newArray.arr = {};
    for i = 1, size, 1 do
        newArray.arr[i] = nil;
    end
    function newArray:Push(item)
        self.arr[#self.arr + 1] = item;
    end
    function newArray:Get(index)
        return self.arr[index + 1];
    end
    function newArray:Sum()
        local sum = 0;
        for i, v in ipairs(self.arr) do
            sum = sum + v;
        end
        return sum;
    end
    return newArray;
end
function Array:NewLine(size)
    return Array:NewArray(size);
end
function Array:NewInt(size)
    return Array:NewArray(size);
end
function Array:NewFloat(size)
    return Array:NewArray(size);
end
function Array:NewLabel(size)
    return Array:NewArray(size);
end
function Array:NewString(size)
    return Array:NewArray(size);
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
function Line:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLines) do
        value:Draw(stage, context);
    end
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
function SafeGrater(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left > right;
end
function SafeLess(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left < right;
end
Label = {};
Label.AllLabels = {};
function Label:Clear()
    Label.AllLabels = {};
end
function Label:New(id, period, price)
    local newLabel = {};
    newLabel.X = period;
    newLabel.Y = price;
    newLabel.Text = "";
    newLabel.BGColor = core.colors().Black;
    newLabel.TextColor = core.colors().Red;
    function newLabel:SetText(text)
        self.Text = text;
        return self;
    end
    function newLabel:SetColor(clr)
        self.BGColor = clr;
        return self;
    end
    function newLabel:SetTextColor(clr)
        self.TextColor = clr;
        return self;
    end
    function newLabel:Draw(stage, context)
        local W, H = context:measureText(Label.FontId, self.Text, context.LEFT);
        visible, y = context:pointOfPrice(self.Y);
        x1, x = context:positionOfBar(self.X)
        context:drawText(Label.FontId, self.Text, self.TextColor, -1, x - W / 2, y - H / 2, x + W /2, y + H / 2, 0);
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
Table = {};
Table.AllTables = {};
function Table:Clear()
    Table.AllTables = {};
end
function Table:New(position, columns, rows)
    local newTable = {};
    newTable.position = position;
    newTable.border_width = 1;
    function newTable:SetBorderWidth(width)
        self.border_width = width;
        return self;
    end
    newTable.bgcolor = nil;
    function newTable:SetBgColor(color)
        self.bgcolor = color;
        return self;
    end
    newTable.border_color = core.colors().Gray;
    newTable.border_style = core.LINE_SOLID;
    function newTable:SetBorderColor(color)
        self.border_color = color;
        return self;
    end
    newTable.frame_color = core.colors().Gray;
    function newTable:SetFrameColor(color)
        self.frame_color = color;
        return self;
    end
    newTable.frame_width = 1;
    function newTable:SetFrameWidth(width)
        self.frame_width = width;
        return self;
    end
    newTable.rows = {};
    for i = 1, rows, 1 do
        newTable.rows[i] = {};
        for ii = 1, columns, 1 do
            local cell = {};
            cell.text = "";
            cell.text_color = core.COLOR_LABEL;
            newTable.rows[i][ii] = cell;
        end
    end
    function newTable:CellText(column, row, text)
        self.rows[row + 1][column + 1].text = text;
        return self;
    end
    function newTable:CellTextColor(column, row, color)
        self.rows[row + 1][column + 1].text_color = color;
        return self;
    end
    function newTable:GetCoordinates(context, W, H)
        if self.position == "top_left" then
            local x1 = context:left() + 5;
            local y1 = context:top() + 5;
            return x1, y1, x1 + W, y1 + H;
        elseif self.position == "top_right" then
            local x1 = context:right() - 5;
            local y1 = context:top() + 5;
            return x1 - W, y1, x1, y1 + H;
        end
    end
    function newTable:Draw(stage, context)
        if self.bgcolor ~= nil and self.BgBrushId == nil then
            self.BgBrushId = Graphics:FindBrush(self.bgcolor, context);
        end
        if self.FramePenId == nil then
            self.FramePenId = Graphics:FindPen(self.border_width, self.border_color, self.border_style, context);
        end

        local W, H = context:measureText(Table.FontId, self.rows[1][1].text, context.LEFT);
        x1, y1, x2, y2 = self:GetCoordinates(context, W, H);
        if self.BgBrushId ~= nil then
            context:drawRectangle(self.FramePenId, self.BgBrushId, x1, y1, x2, y2)
        end
        context:drawRectangle(self.FramePenId, -1, x1, y1, x2, y2)
        context:drawText(Table.FontId, self.rows[1][1].text, self.rows[1][1].text_color, -1, x1, y1, x2, y2, 0);
    end
    self.AllTables[#self.AllTables + 1] = newTable;
    return newTable;
end
function Table:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if Table.FontId == nil then
        Table.FontId = Graphics:FindFont("Arial", 0, context:pointsToPixels(10), context.LEFT, context);
    end
    for id, table in pairs(self.AllTables) do
        table:Draw(stage, context);
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