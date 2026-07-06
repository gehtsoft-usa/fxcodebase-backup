-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74418

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
    indicator:name("Market Structure - By Leviathan");
    indicator:description("Market Structure - By Leviathan");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Swing Length", "", 20);
    indicator.parameters:addString("param2", "BOS Confirmation", "", "Candle Close");
    indicator.parameters:addStringAlternative("param2", "Candle Close", "", "Candle Close");
    indicator.parameters:addStringAlternative("param2", "Wicks", "", "Wicks");
    indicator.parameters:addBoolean("param3", "Show CHoCH", "", false);
    indicator.parameters:addBoolean("param4", "Show Swing Points", "", true);
    indicator.parameters:addBoolean("param5", "Show 0.5 Retracement Level", "", false);
    indicator.parameters:addColor("param6", "Color", "", core.rgb(41, 39, 176));
    indicator.parameters:addString("param7", "Line Style", "", "Solid");
    indicator.parameters:addStringAlternative("param7", "Solid", "", "Solid");
    indicator.parameters:addStringAlternative("param7", "Dashed", "", "Dashed");
    indicator.parameters:addStringAlternative("param7", "Dotted", "", "Dotted");
    indicator.parameters:addInteger("param8", "Width", "", 1);
    indicator.parameters:addColor("param9", "Color", "", core.rgb(112, 114, 119));
    indicator.parameters:addString("param10", "Line Style", "", "Dashed");
    indicator.parameters:addStringAlternative("param10", "Solid", "", "Solid");
    indicator.parameters:addStringAlternative("param10", "Dashed", "", "Dashed");
    indicator.parameters:addStringAlternative("param10", "Dotted", "", "Dotted");
    indicator.parameters:addInteger("param11", "Width", "", 1);
end

local source;
local vars = {};
local prevHigh;
local prevLow;
local prevHighIndex;
local prevLowIndex;
local highActive;
local lowActive;
local prevSwing;
local prevBreakoutDir;
function Create_lineStyle(x)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            return (((x == "Solid")) and ("solid") or ((((x == "Dashed")) and ("dashed") or ((((x == "Dotted")) and ("dotted") or (nil))))));
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
    vars["swingSize"] = instance.parameters.param1;
    vars["bosConfType"] = instance.parameters.param2;
    vars["choch"] = instance.parameters.param3;
    vars["showSwing"] = instance.parameters.param4;
    vars["showHalf"] = instance.parameters.param5;
    vars["halfColor"] = instance.parameters.param6;
    vars["halfStyle"] = instance.parameters.param7;
    vars["halfWidth"] = instance.parameters.param8;
    vars["bosColor"] = instance.parameters.param9;
    vars["bosStyle"] = instance.parameters.param10;
    vars["bosWidth"] = instance.parameters.param11;
    vars["__pivothigh1"] = CreatePivotHigh(source.high, vars["swingSize"], vars["swingSize"]);
    vars["__pivotlow1"] = CreatePivotLow(source.low, vars["swingSize"], vars["swingSize"]);
    prevHigh = instance:addInternalStream(0, 0);
    prevLow = instance:addInternalStream(0, 0);
    prevHighIndex = instance:addInternalStream(0, 0);
    prevLowIndex = instance:addInternalStream(0, 0);
    highActive = instance:addInternalStream(0, 0);
    lowActive = instance:addInternalStream(0, 0);
    prevSwing = instance:addInternalStream(0, 0);
    prevBreakoutDir = instance:addInternalStream(0, 0);
    vars["lineStyleFunc1"] = Create_lineStyle(vars["halfStyle"]);
    vars["lineStyleFunc2"] = Create_lineStyle(vars["halfStyle"]);
    vars["lineStyleFunc3"] = Create_lineStyle(vars["bosStyle"]);
    vars["lineStyleFunc4"] = Create_lineStyle(vars["bosStyle"]);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Label:Clear();
        Line:Clear();
        prevHigh_value = nil;
        if prevHigh_value then
            prevHigh[period] = prevHigh_value;
        else
            prevHigh:setNoData(period);
        end
        prevLow_value = nil;
        if prevLow_value then
            prevLow[period] = prevLow_value;
        else
            prevLow:setNoData(period);
        end
        prevHighIndex_value = nil;
        if prevHighIndex_value then
            prevHighIndex[period] = prevHighIndex_value;
        else
            prevHighIndex:setNoData(period);
        end
        prevLowIndex_value = nil;
        if prevLowIndex_value then
            prevLowIndex[period] = prevLowIndex_value;
        else
            prevLowIndex:setNoData(period);
        end
        highActive_value = false;
        if highActive_value then
            highActive[period] = highActive_value and 1 or 0;
        else
            highActive:setNoData(period);
        end
        lowActive_value = false;
        if lowActive_value then
            lowActive[period] = lowActive_value and 1 or 0;
        else
            lowActive:setNoData(period);
        end
        prevSwing_value = 0;
        if prevSwing_value then
            prevSwing[period] = prevSwing_value;
        else
            prevSwing:setNoData(period);
        end
        prevBreakoutDir_value = 0;
        if prevBreakoutDir_value then
            prevBreakoutDir[period] = prevBreakoutDir_value;
        else
            prevBreakoutDir:setNoData(period);
        end
    else
        prevHigh_value = (prevHigh:hasData(period - 1) and prevHigh:tick(period - 1) or nil);
        if prevHigh_value then
            prevHigh[period] = prevHigh_value;
        else
            prevHigh:setNoData(period);
        end
        prevLow_value = (prevLow:hasData(period - 1) and prevLow:tick(period - 1) or nil);
        if prevLow_value then
            prevLow[period] = prevLow_value;
        else
            prevLow:setNoData(period);
        end
        prevHighIndex_value = (prevHighIndex:hasData(period - 1) and prevHighIndex:tick(period - 1) or nil);
        if prevHighIndex_value then
            prevHighIndex[period] = prevHighIndex_value;
        else
            prevHighIndex:setNoData(period);
        end
        prevLowIndex_value = (prevLowIndex:hasData(period - 1) and prevLowIndex:tick(period - 1) or nil);
        if prevLowIndex_value then
            prevLowIndex[period] = prevLowIndex_value;
        else
            prevLowIndex:setNoData(period);
        end
        highActive_value = (highActive:hasData(period - 1) and highActive:tick(period - 1) == 1 or nil);
        if highActive_value then
            highActive[period] = highActive_value and 1 or 0;
        else
            highActive:setNoData(period);
        end
        lowActive_value = (lowActive:hasData(period - 1) and lowActive:tick(period - 1) == 1 or nil);
        if lowActive_value then
            lowActive[period] = lowActive_value and 1 or 0;
        else
            lowActive:setNoData(period);
        end
        prevSwing_value = (prevSwing:hasData(period - 1) and prevSwing:tick(period - 1) or nil);
        if prevSwing_value then
            prevSwing[period] = prevSwing_value;
        else
            prevSwing:setNoData(period);
        end
        prevBreakoutDir_value = (prevBreakoutDir:hasData(period - 1) and prevBreakoutDir:tick(period - 1) or nil);
        if prevBreakoutDir_value then
            prevBreakoutDir[period] = prevBreakoutDir_value;
        else
            prevBreakoutDir:setNoData(period);
        end
    end
    CLEAR = core.rgb(0, 0, 0) + math.floor(100 / 100 * 255) * 16777216;
    pivHi = vars["__pivothigh1"]:get(period);
    pivLo = vars["__pivotlow1"]:get(period);
    hh = false;
    lh = false;
    hl = false;
    ll = false;
    if not (pivHi == nil) then
        if SafeGE(pivHi, (prevHigh:hasData(period) and prevHigh:tick(period) or nil)) then
            hh = true;
            prevSwing_value = 2;
            if prevSwing_value then
                prevSwing[period] = prevSwing_value;
            else
                prevSwing:setNoData(period);
            end
        else
            lh = true;
            prevSwing_value = 1;
            if prevSwing_value then
                prevSwing[period] = prevSwing_value;
            else
                prevSwing:setNoData(period);
            end
        end
        prevHigh_value = pivHi;
        if prevHigh_value then
            prevHigh[period] = prevHigh_value;
        else
            prevHigh:setNoData(period);
        end
        highActive_value = true;
        if highActive_value then
            highActive[period] = highActive_value and 1 or 0;
        else
            highActive:setNoData(period);
        end
        prevHighIndex_value = period - vars["swingSize"];
        if prevHighIndex_value then
            prevHighIndex[period] = prevHighIndex_value;
        else
            prevHighIndex:setNoData(period);
        end
    end
    if not (pivLo == nil) then
        if SafeGE(pivLo, (prevLow:hasData(period) and prevLow:tick(period) or nil)) then
            hl = true;
            prevSwing_value = (-1);
            if prevSwing_value then
                prevSwing[period] = prevSwing_value;
            else
                prevSwing:setNoData(period);
            end
        else
            ll = true;
            prevSwing_value = (-2);
            if prevSwing_value then
                prevSwing[period] = prevSwing_value;
            else
                prevSwing:setNoData(period);
            end
        end
        prevLow_value = pivLo;
        if prevLow_value then
            prevLow[period] = prevLow_value;
        else
            prevLow:setNoData(period);
        end
        lowActive_value = true;
        if lowActive_value then
            lowActive[period] = lowActive_value and 1 or 0;
        else
            lowActive:setNoData(period);
        end
        prevLowIndex_value = period - vars["swingSize"];
        if prevLowIndex_value then
            prevLowIndex[period] = prevLowIndex_value;
        else
            prevLowIndex:setNoData(period);
        end
    end
    highBroken = false;
    lowBroken = false;
    highSrc = (((vars["bosConfType"] == "Candle Close")) and (source.close:tick(period)) or (source.high:tick(period)));
    lowSrc = (((vars["bosConfType"] == "Candle Close")) and (source.close:tick(period)) or (source.low:tick(period)));
    if SafeGreater(highSrc, (prevHigh:hasData(period) and prevHigh:tick(period) or nil)) and (highActive:hasData(period) and highActive:tick(period) == 1 or nil) then
        highBroken = true;
        highActive_value = false;
        if highActive_value then
            highActive[period] = highActive_value and 1 or 0;
        else
            highActive:setNoData(period);
        end
    end
    if SafeLess(lowSrc, (prevLow:hasData(period) and prevLow:tick(period) or nil)) and (lowActive:hasData(period) and lowActive:tick(period) == 1 or nil) then
        lowBroken = true;
        lowActive_value = false;
        if lowActive_value then
            lowActive[period] = lowActive_value and 1 or 0;
        else
            lowActive:setNoData(period);
        end
    end
    if hh and vars["showSwing"] then
        Label:New(core.formatDate(source:date(period - vars["swingSize"])) .. "_1", period - vars["swingSize"], pivHi):SetText("HH"):SetColor(CLEAR):SetTextColor(core.COLOR_LABEL);
        if prevSwing:first() > period - 1 then return; end
        if ((prevSwing:hasData(period - 1) and prevSwing:tick(period - 1) or nil) == (-1)) and vars["showHalf"] then
            Line:New((prevLowIndex:hasData(period) and prevLowIndex:tick(period) or nil), (SafePlus((prevLow:hasData(period) and prevLow:tick(period) or nil), pivHi)) / 2, period - vars["swingSize"], (SafePlus((prevLow:hasData(period) and prevLow:tick(period) or nil), pivHi)) / 2):SetColor(vars["halfColor"]):SetStyle(vars["lineStyleFunc1"].GetValue(period, mode));
        end
    end
    if lh and vars["showSwing"] then
        Label:New(core.formatDate(source:date(period - vars["swingSize"])) .. "_2", period - vars["swingSize"], pivHi):SetText("LH"):SetColor(CLEAR):SetTextColor(core.COLOR_LABEL);
    end
    if hl and vars["showSwing"] then
        Label:New(core.formatDate(source:date(period - vars["swingSize"])) .. "_3", period - vars["swingSize"], pivLo):SetText("HL"):SetColor(CLEAR):SetTextColor(core.COLOR_LABEL);
    end
    if ll and vars["showSwing"] then
        Label:New(core.formatDate(source:date(period - vars["swingSize"])) .. "_4", period - vars["swingSize"], pivLo):SetText("LL"):SetColor(CLEAR):SetTextColor(core.COLOR_LABEL);
        if prevSwing:first() > period - 1 then return; end
        if ((prevSwing:hasData(period - 1) and prevSwing:tick(period - 1) or nil) == 1) and vars["showHalf"] then
            Line:New((prevHighIndex:hasData(period) and prevHighIndex:tick(period) or nil), (SafePlus((prevHigh:hasData(period) and prevHigh:tick(period) or nil), pivLo)) / 2, period - vars["swingSize"], (SafePlus((prevHigh:hasData(period) and prevHigh:tick(period) or nil), pivLo)) / 2):SetColor(vars["halfColor"]):SetStyle(vars["lineStyleFunc2"].GetValue(period, mode));
        end
    end
    if highBroken then
        Line:New((prevHighIndex:hasData(period) and prevHighIndex:tick(period) or nil), (prevHigh:hasData(period) and prevHigh:tick(period) or nil), period, (prevHigh:hasData(period) and prevHigh:tick(period) or nil)):SetColor(vars["bosColor"]):SetStyle(vars["lineStyleFunc3"].GetValue(period, mode));
        Label:New(core.formatDate(source:date(math.floor(period - (SafeMinus(period, (prevHighIndex:hasData(period) and prevHighIndex:tick(period) or nil))) / 2))) .. "_5", math.floor(period - (SafeMinus(period, (prevHighIndex:hasData(period) and prevHighIndex:tick(period) or nil))) / 2), (prevHigh:hasData(period) and prevHigh:tick(period) or nil)):SetText(((((prevBreakoutDir:hasData(period) and prevBreakoutDir:tick(period) or nil) == (-1)) and vars["choch"]) and ("CHoCH") or ("BOS"))):SetColor(CLEAR):SetTextColor(vars["bosColor"]);
        prevBreakoutDir_value = 1;
        if prevBreakoutDir_value then
            prevBreakoutDir[period] = prevBreakoutDir_value;
        else
            prevBreakoutDir:setNoData(period);
        end
    end
    if lowBroken then
        Line:New((prevLowIndex:hasData(period) and prevLowIndex:tick(period) or nil), (prevLow:hasData(period) and prevLow:tick(period) or nil), period, (prevLow:hasData(period) and prevLow:tick(period) or nil)):SetColor(vars["bosColor"]):SetStyle(vars["lineStyleFunc4"].GetValue(period, mode));
        Label:New(core.formatDate(source:date(math.floor(period - (SafeMinus(period, (prevLowIndex:hasData(period) and prevLowIndex:tick(period) or nil))) / 2))) .. "_6", math.floor(period - (SafeMinus(period, (prevLowIndex:hasData(period) and prevLowIndex:tick(period) or nil))) / 2), (prevLow:hasData(period) and prevLow:tick(period) or nil)):SetText(((((prevBreakoutDir:hasData(period) and prevBreakoutDir:tick(period) or nil) == 1) and vars["choch"]) and ("CHoCH") or ("BOS"))):SetColor(CLEAR):SetTextColor(vars["bosColor"]);
        prevBreakoutDir_value = (-1);
        if prevBreakoutDir_value then
            prevBreakoutDir[period] = prevBreakoutDir_value;
        else
            prevBreakoutDir:setNoData(period);
        end
    end
end
function Draw(stage, context)
    Label:Draw(stage, context);
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
function CreatePivotHigh(source, leftbars, rightbars)
    local pivot = {};
    pivot.Source = source;
    pivot.LeftBars = leftbars;
    pivot.RightBars = rightbars;
    function pivot:get(period)
        if period - self.RightBars - self.LeftBars - 1 < 0 or not self.Source:hasData(period - self.RightBars) then
            return nil;
        end
        local ref = self.Source:tick(period - self.RightBars);
        for i = period - self.RightBars - self.LeftBars, period - self.RightBars - 1 do
            if not self.Source:hasData(i) or self.Source:tick(i) >= ref then
                return nil;
            end
        end
        for i = period - self.LeftBars + 1, period do
            if not self.Source:hasData(i) or self.Source:tick(i) >= ref then
                return nil;
            end
        end
        return ref;
    end
    return pivot;
end
function CreatePivotLow(source, leftbars, rightbars)
    local pivot = {};
    pivot.Source = source;
    pivot.LeftBars = leftbars;
    pivot.RightBars = rightbars;
    function pivot:get(period)
        if period - self.RightBars - self.LeftBars - 1 < 0 or not self.Source:hasData(period - self.RightBars) then
            return nil;
        end
        local ref = self.Source:tick(period - self.RightBars);
        for i = period - self.RightBars - self.LeftBars, period - self.RightBars - 1 do
            if not self.Source:hasData(i) or self.Source:tick(i) <= ref then
                return nil;
            end
        end
        for i = period - self.LeftBars + 1, period do
            if not self.Source:hasData(i) or self.Source:tick(i) <= ref then
                return nil;
            end
        end
        return ref;
    end
    return pivot;
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
function Float(number)
    return number and number or 0.0;
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
        self.BGColor = clr - self.BgColorTransparency * 16777216;
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
function Line:SetStyle(line, style)
    if line == nil then
        return;
    end
    line:SetStyle(style);
end
function Line:SetExtend(line, extend)
    if line == nil then
        return;
    end
    line:SetExtend(extend);
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
        return self;
    end
    function newLine:SetXY2(x, y)
        self.X2 = x;
        self.Y2 = y;
        return self;
    end
    function newLine:SetX1(x)
        self.X1 = x;
        return self;
    end
    function newLine:SetX2(x)
        self.X2 = x;
        return self;
    end
    function newLine:SetY1(y)
        self.Y1 = y;
        return self;
    end
    function newLine:SetY2(y)
        self.Y2 = y;
        return self;
    end
    function newLine:GetX1()
        return self.X1;
    end
    function newLine:GetX2()
        return self.X2;
    end
    function newLine:GetY1()
        return self.Y1;
    end
    function newLine:GetY2()
        return self.Y2;
    end
    newLine.Color = core.colors().Blue;
    function newLine:SetColor(clr)
        self.Color = clr;
        self.PenId = nil;
        return self;
    end
    newLine.Width = 1;
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenId = nil;
        return self;
    end
    newLine.Extend = "none";
    function newLine:SetExtend(extend)
        self.Extend = extend;
        return self;
    end
    newLine.Style = "solid";
    function newLine:SetStyle(style)
        self.Style = style;
        self.PenId = nil;
        return self;
    end
    function newLine:getStyleForContext()
        if self.Style == "solid" or self.Style == "arrow_left" or self.Style == "arrow_both" or self.Style == "arrow_right" then
            return core.LINE_SOLID;
        elseif self.Style == "dotted" then
            return core.LINE_DOT;
        elseif self.Style == "dashed" then
            return core.LINE_DASH;
        end
        return core.LINE_SOLID;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        _, y1 = context:pointOfPrice(self.Y1);
        _, x1 = context:positionOfBar(self.X1);
        _, y2 = context:pointOfPrice(self.Y2);
        _, x2 = context:positionOfBar(self.X2);
        context:drawLine(self.PenId, x1, y1, x2, y2);
        if self.Extend == "right" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:right() + c;
            context:drawLine(self.PenId, x2, y2, context:right(), y3);
        end
        if self.Extend == "left" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:left() + c;
            context:drawLine(self.PenId, x1, y1, context:left(), y3);
        end
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