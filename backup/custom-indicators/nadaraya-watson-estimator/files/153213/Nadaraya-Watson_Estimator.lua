-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=74323

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
    indicator:name("Nadaraya-Watson Estimator [LUX]");
    indicator:description("Nadaraya-Watson Estimator [LUX]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addDouble("param1", "Bandwidth", "", 8.);
    indicator.parameters:addString("param2", "Source", "", "close");
    indicator.parameters:addStringAlternative("param2", "Open", "", "open");
    indicator.parameters:addStringAlternative("param2", "High", "", "high");
    indicator.parameters:addStringAlternative("param2", "Low", "", "low");
    indicator.parameters:addStringAlternative("param2", "Close", "", "close");
    indicator.parameters:addStringAlternative("param2", "Median", "", "median");
    indicator.parameters:addStringAlternative("param2", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param2", "Weighted", "", "weighted");
end

local source;
local params = {};
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
    vars["ln"] = Array:NewLine(0);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    n = period;
    if period == 0 then
        for i = 0, 499, 1 do
            vars["ln"]:Push(Line:New(nil, nil, nil, nil));
        end
    end
    y2 = nil;
    y1 = nil;
    y1_d = nil;
    l = nil;
    lb = nil;
    if period == source:size() - 1 then
        for i = 0, math.min(499, n - 1), 1 do
            vars["sum"] = 0.;
            vars["sumw"] = 0.;
            for j = 0, math.min(499, n - 1), 1 do
                w = math.exp((-(math.pow(i - j, 2) / (vars["h"] * vars["h"] * 2))));
                vars["sum"] = vars["sum"] + vars["src"]:tick(period - j) * w;
                vars["sumw"] = vars["sumw"] + w;
            end
            y2 = vars["sum"] / vars["sumw"];
            d = SafeMinus(y2, y1);
            l = vars["ln"]:Get(i);
            l:SetXY1(n - i + 1, y1);
            l:SetXY2(n - i, y2);
            l:SetColor((SafeGrater(y2, y1) and core.rgb(255, 17, 0) or core.rgb(57, 255, 20)));
            l:SetWidth(2);
            if SafeGrater(d, 0) and SafeLess(y1_d, 0) then
                Label:New(core.formatDate(source:date(n - i + 1)) .. "_1", n - i + 1, vars["src"]:tick(period - i)):SetText("U"):SetColor(core.rgb(0, 0, 0)):SetTextColor(core.rgb(57, 255, 20));
            end
            if SafeLess(d, 0) and SafeGrater(y1_d, 0) then
                Label:New(core.formatDate(source:date(n - i + 1)) .. "_2", n - i + 1, vars["src"]:tick(period - i)):SetText("D"):SetColor(core.rgb(0, 0, 0)):SetTextColor(core.rgb(255, 17, 0));
            end
            y1 = y2;
            y1_d = d;
        end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
Array = {};
function Array:NewLine()
    local newArray = {};
    newArray.arr = {};
    function newArray:Push(item)
        self.arr[#self.arr + 1] = item;
    end
    function newArray:Get(index)
        return self.arr[index + 1];
    end
    return newArray;
end
Line = {};
Line.AllLines = {};
Line.NextId = 10;
Line.Pens = {};
function Line:FindPen(width, color, context)
    for i, pen in ipairs(Line.Pens) do
        if pen.Width == width and pen.Color == color then
            context:createPen(pen.Id, context:convertPenStyle(core.LINE_SOLID), width, color);
            return pen.Id;
        end
    end
    local newPen = {};
    newPen.Id = Line.NextId;
    newPen.Width = width;
    newPen.Color = color;
    context:createPen(newPen.Id, context:convertPenStyle(core.LINE_SOLID), width, color);
    Line.NextId = Line.NextId + 1;
    Line.Pens[#Line.Pens + 1] = newPen;
    return newPen.Id;
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
    function newLine:SetColor(clr)
        self.Color = clr;
        self.PenValid = false;
    end
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenValid = false;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil then
            return;
        end
        if not self.PenValid then
            self.PenId = Line:FindPen(self.Width, self.Color, context);
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
        visible, y = context:pointOfPrice(newLabel.Y);
        x1, x = context:positionOfBar(newLabel.X)
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
        Label.FontId = 1;
        context:createFont(Label.FontId, "Arial", 0, context:pointsToPixels(10), context.LEFT);
    end
    for id, label in pairs(self.AllLabels) do
        label:Draw(stage, context);
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