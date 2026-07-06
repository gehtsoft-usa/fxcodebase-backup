
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74410

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
    indicator:name("Dynamic Linear Regression Channels");
    indicator:description("Dynamic Linear Regression Channels");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addDouble("param1", "Upper Deviation", "", 2.0);
    indicator.parameters:addColor("param2", "Upper Color", "", core.colors().Blue);
    indicator.parameters:addDouble("param3", "Lower Deviation", "", 2.0);
    indicator.parameters:addColor("param4", "Lower Color", "", core.colors().Red);
end

local source;
local vars = {};
local start_index;
local calcSlopeFunc1_param2;
local calcDevFunc2_param2;
local calcDevFunc2_param3;
local calcDevFunc2_param4;
local calcDevFunc2_param5;
local startPrice;
local endPrice;
local upperStartPrice;
local upperEndPrice;
local lowerStartPrice;
local lowerEndPrice;
function Create_calcSlope(__source, length)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            if ((period == 0 or mode == core.UpdateAll) or (length:tick(period) <= 1)) then
                return Float(nil), Float(nil), Float(nil);
            else
                sumX = 0.0;
                sumY = 0.0;
                sumXSqr = 0.0;
                sumXY = 0.0;
                for i = 0, length:tick(period) - 1, 1 do
                    val = __source:tick(period - i);
                    per = i + 1.0;
                    sumX = sumX + per;
                    sumY = sumY + val;
                    sumXSqr = sumXSqr + per * per;
                    sumXY = sumXY + val * per;
                end
                slope = (length:tick(period) * sumXY - sumX * sumY) / (length:tick(period) * sumXSqr - sumX * sumX);
                average = sumY / length:tick(period);
                intercept = average - slope * sumX / length:tick(period) + slope;
                return slope, average, intercept;
            end
        end
    };
end
function Create_calcDev(__source, length, slope, average, intercept)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            if ((period == 0 or mode == core.UpdateAll) or (length:tick(period) <= 1)) then
                return Float(nil), Float(nil), Float(nil), Float(nil);
            else
                upDev = 0.0;
                dnDev = 0.0;
                stdDevAcc = 0.0;
                dsxx = 0.0;
                dsyy = 0.0;
                dsxy = 0.0;
                periods = length:tick(period) - 1;
                daY = intercept:tick(period) + slope:tick(period) * periods / 2;
                val = intercept:tick(period);
                for j = 0, periods, 1 do
                    price = source.high:tick(period - j) - val;
                    if (price > upDev) then
                        upDev = price;
                    end
                    price = val - source.low:tick(period - j);
                    if (price > dnDev) then
                        dnDev = price;
                    end
                    price = __source:tick(period - j);
                    dxt = price - average:tick(period);
                    dyt = val - daY;
                    price = price - val;
                    stdDevAcc = stdDevAcc + price * price;
                    dsxx = dsxx + dxt * dxt;
                    dsyy = dsyy + dyt * dyt;
                    dsxy = dsxy + dxt * dyt;
                    val = val + slope:tick(period);
                end
                stdDev = math.sqrt(stdDevAcc / ((((periods == 0)) and (1) or (periods))));
                pearsonR = ((((dsxx == 0) or (dsyy == 0))) and (0) or (SafeDivide(dsxy, math.sqrt(dsxx * dsyy))));
                return stdDev, pearsonR, upDev, dnDev;
            end
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
    vars["upperMultInput"] = instance.parameters.param1;
    vars["colorUpper"] = instance.parameters.param2;
    vars["lowerMultInput"] = instance.parameters.param3;
    vars["colorLower"] = instance.parameters.param4;
    start_index = instance:addInternalStream(0, 0);
    calcSlopeFunc1_param2 = instance:addInternalStream(0, 0);
    vars["calcSlopeFunc1"] = Create_calcSlope(source.close, calcSlopeFunc1_param2);
    calcDevFunc2_param2 = instance:addInternalStream(0, 0);
    calcDevFunc2_param3 = instance:addInternalStream(0, 0);
    calcDevFunc2_param4 = instance:addInternalStream(0, 0);
    calcDevFunc2_param5 = instance:addInternalStream(0, 0);
    vars["calcDevFunc2"] = Create_calcDev(source.close, calcDevFunc2_param2, calcDevFunc2_param3, calcDevFunc2_param4, calcDevFunc2_param5);
    startPrice = instance:addInternalStream(0, 0);
    endPrice = instance:addInternalStream(0, 0);
    upperStartPrice = instance:addInternalStream(0, 0);
    upperEndPrice = instance:addInternalStream(0, 0);
    lowerStartPrice = instance:addInternalStream(0, 0);
    lowerEndPrice = instance:addInternalStream(0, 0);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Linefill:Clear();
        start_index[period] = 1;
        vars["baseLine"] = Line:New(nil, nil, nil, nil):SetColor(vars["colorLower"] + math.floor(0 / 100 * 256) * 16777216);
        vars["upper"] = Line:New(nil, nil, nil, nil):SetColor(vars["colorUpper"] + math.floor(0 / 100 * 256) * 16777216);
        vars["lower"] = Line:New(nil, nil, nil, nil):SetColor(vars["colorUpper"] + math.floor(0 / 100 * 256) * 16777216);
    else
        start_index[period] = start_index:tick(period - 1);
    end
    lengthInput = period - start_index:tick(period) + 1;
    calcSlopeFunc1_param2[period] = lengthInput;
    s, a, i = vars["calcSlopeFunc1"].GetValue(period, mode);
    startPrice[period] = i + s * (lengthInput - 1);
    endPrice[period] = i;
    calcDevFunc2_param2[period] = lengthInput;
    calcDevFunc2_param3[period] = s;
    calcDevFunc2_param4[period] = a;
    calcDevFunc2_param5[period] = i;
    stdDev, pearsonR, upDev, dnDev = vars["calcDevFunc2"].GetValue(period, mode);
    upperStartPrice[period] = SafePlus(startPrice:tick(period), SafeMultiply(vars["upperMultInput"], stdDev));
    upperEndPrice[period] = SafePlus(endPrice:tick(period), SafeMultiply(vars["upperMultInput"], stdDev));
    lowerStartPrice[period] = SafeMinus(startPrice:tick(period), SafeMultiply(vars["lowerMultInput"], stdDev));
    lowerEndPrice[period] = SafeMinus(endPrice:tick(period), SafeMultiply(vars["lowerMultInput"], stdDev));
    Linefill:New(vars["upper"], vars["baseLine"]):SetColor(vars["colorUpper"], 85);
    Linefill:New(vars["baseLine"], vars["lower"]):SetColor(vars["colorLower"], 85);
    if ((SafeGreater(source.close:tick(period), upperEndPrice:tick(period)) or SafeLess(source.close:tick(period), lowerEndPrice:tick(period)))) and ((not (period == source:size() - 1) or (period ~= source:size() - 1 or mode == core.UpdateLast))) then
        if startPrice:first() > period - 1 then return; end
        if endPrice:first() > period - 1 then return; end
        _baseLine = Line:New(period - lengthInput + 1, startPrice:tick(period - 1), period - 1, endPrice:tick(period - 1)):SetColor(vars["colorLower"] + math.floor(0 / 100 * 256) * 16777216);
        if upperStartPrice:first() > period - 1 then return; end
        if upperEndPrice:first() > period - 1 then return; end
        _upper = Line:New(period - lengthInput + 1, upperStartPrice:tick(period - 1), period - 1, upperEndPrice:tick(period - 1)):SetColor(vars["colorUpper"] + math.floor(0 / 100 * 256) * 16777216);
        if lowerStartPrice:first() > period - 1 then return; end
        if lowerEndPrice:first() > period - 1 then return; end
        _lower = Line:New(period - lengthInput + 1, lowerStartPrice:tick(period - 1), period - 1, lowerEndPrice:tick(period - 1)):SetColor(vars["colorUpper"] + math.floor(0 / 100 * 256) * 16777216);
        Linefill:New(_upper, _baseLine):SetColor(vars["colorUpper"], 85);
        Linefill:New(_baseLine, _lower):SetColor(vars["colorLower"], 85);
        start_index[period] = period;
    elseif period == source:size() - 1 then
        j = (((SafeGreater(source.close:tick(period), upperEndPrice:tick(period)) or SafeLess(source.close:tick(period), lowerEndPrice:tick(period)))) and (1) or (0));
        if startPrice:first() > period - j then return; end
        Line:SetXY1(vars["baseLine"], period - lengthInput + 1, startPrice:tick(period - j));
        if endPrice:first() > period - j then return; end
        Line:SetXY2(vars["baseLine"], period - j, endPrice:tick(period - j));
        if upperStartPrice:first() > period - j then return; end
        Line:SetXY1(vars["upper"], period - lengthInput + 1, upperStartPrice:tick(period - j));
        if upperEndPrice:first() > period - j then return; end
        Line:SetXY2(vars["upper"], period - j, upperEndPrice:tick(period - j));
        if lowerStartPrice:first() > period - j then return; end
        Line:SetXY1(vars["lower"], period - lengthInput + 1, lowerStartPrice:tick(period - j));
        if lowerEndPrice:first() > period - j then return; end
        Line:SetXY2(vars["lower"], period - j, lowerEndPrice:tick(period - j));
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Linefill:Draw(stage, context);
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
function Float(number)
    return number and number or 0.0;
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
        self.PenValid = false;
        return self;
    end
    newLine.Width = 1;
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenValid = false;
        return self;
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
Linefill = {};
Linefill.AllLinefills = {};
function Linefill:Clear()
    Linefill.AllLinefills = {};
end
function Linefill:SetColor(Linefill, clr)
    if Linefill == nil then
        return;
    end
    Linefill:SetColor(clr);
end
function Linefill:New(line1, line2)
    for i, fill in ipairs(Linefill.AllLinefills) do
        if fill.Line1 == line1 and fill.Line2 == line2 then
            return fill;
        end
    end
    local newLinefill = {};
    newLinefill.Line1 = line1;
    newLinefill.Line2 = line2;
    newLinefill.Color = core.colors().Blue;
    function newLinefill:SetColor(clr, transparency)
        self.Color = clr;
        self.ColorTransparency = transparency and transparency or (math.floor(clr / 16777216) % 256);
        self.PenId = nil;
        self.BrushId = nil;
    end
    function newLinefill:Draw(stage, context)
        if self.Line1 == nil or self.Line2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(1, self.Color, core.LINE_SOLID, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.Color, context);
        end
        
        local points = context:createPoints();
        _, y1 = context:pointOfPrice(self.Line1:GetY1());
        _, x1 = context:positionOfBar(self.Line1:GetX1());
        _, y2 = context:pointOfPrice(self.Line1:GetY2());
        _, x2 = context:positionOfBar(self.Line1:GetX2());
        points:add(x1, y1);
        points:add(x2, y2);
        _, y1 = context:pointOfPrice(self.Line2:GetY1());
        _, x1 = context:positionOfBar(self.Line2:GetX1());
        _, y2 = context:pointOfPrice(self.Line2:GetY2());
        _, x2 = context:positionOfBar(self.Line2:GetX2());
        points:add(x2, y2);
        points:add(x1, y1);
        context:drawPolygon(self.PenId, self.BrushId, points, self.ColorTransparency);
    end
    self.AllLinefills[#self.AllLinefills + 1] = newLinefill;
    return newLinefill;
end
function Linefill:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLinefills) do
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