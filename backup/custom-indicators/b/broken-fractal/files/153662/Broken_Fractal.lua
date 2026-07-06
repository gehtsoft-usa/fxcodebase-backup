-- Available @   https://fxcodebase.com/code/viewtopic.php?f=17&t=74437

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
    indicator:name("Broken Fractal");
    indicator:description("Broken Fractal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "n==1 or 2", "", 2);
    indicator.parameters:addBoolean("param2", "bgColor", "", false);
    indicator.parameters:addBoolean("param3", "drawBoxes", "", true);
    indicator.parameters:addBoolean("param4", "showBullishSignal", "", true);
    indicator.parameters:addBoolean("param5", "showBearishSignal", "", true);
end

local source;
local vars = {};
local fractalCounter;
local highAtDownFractal;
local lowAtUpFractal;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["n"] = instance.parameters.param1;
    vars["bgColor"] = instance.parameters.param2;
    vars["drawBoxes"] = instance.parameters.param3;
    vars["showBullishSignal"] = instance.parameters.param4;
    vars["showBearishSignal"] = instance.parameters.param5;
    fractalCounter = instance:addInternalStream(0, 0);
    highAtDownFractal = instance:addInternalStream(0, 0);
    lowAtUpFractal = instance:addInternalStream(0, 0);
    Line:Prepare(50);
    vars["bgcolor_1"] = BGColor:Create();
    vars["bgcolor_2"] = BGColor:Create();
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        BGColor:Clear();
        Box:Clear();
        fractalCounter_value = 0;
        if fractalCounter_value then
            fractalCounter[period] = fractalCounter_value;
        else
            fractalCounter:setNoData(period);
        end
        highAtDownFractal_value = 0.0;
        if highAtDownFractal_value then
            highAtDownFractal[period] = highAtDownFractal_value;
        else
            highAtDownFractal:setNoData(period);
        end
        lowAtUpFractal_value = 0.0;
        if lowAtUpFractal_value then
            lowAtUpFractal[period] = lowAtUpFractal_value;
        else
            lowAtUpFractal:setNoData(period);
        end
    else
        fractalCounter_value = (fractalCounter:hasData(period - 1) and fractalCounter:tick(period - 1) or nil);
        if fractalCounter_value then
            fractalCounter[period] = fractalCounter_value;
        else
            fractalCounter:setNoData(period);
        end
        highAtDownFractal_value = (highAtDownFractal:hasData(period - 1) and highAtDownFractal:tick(period - 1) or nil);
        if highAtDownFractal_value then
            highAtDownFractal[period] = highAtDownFractal_value;
        else
            highAtDownFractal:setNoData(period);
        end
        lowAtUpFractal_value = (lowAtUpFractal:hasData(period - 1) and lowAtUpFractal:tick(period - 1) or nil);
        if lowAtUpFractal_value then
            lowAtUpFractal[period] = lowAtUpFractal_value;
        else
            lowAtUpFractal:setNoData(period);
        end
    end
    downFractal = ((((vars["n"] == 2)) and (((source.high:tick(period - vars["n"] - 2) < source.high:tick(period - vars["n"]))) and ((source.high:tick(period - vars["n"] - 1) < source.high:tick(period - vars["n"]))) and ((source.high:tick(period - vars["n"] + 1) < source.high:tick(period - vars["n"]))) and ((source.high:tick(period - vars["n"] + 2) < source.high:tick(period - vars["n"])))) or (((source.high:tick(period - 1) > source.high:tick(period - 0))) and ((source.high:tick(period - 1) > source.high:tick(period - 2))))));
    if downFractal then
        Line:New(period - 1, source.high:tick(period - vars["n"]), period, source.high:tick(period - vars["n"])):SetColor(core.colors().Silver):SetExtend("none"):SetStyle("solid"):SetWidth(1);
        if ((fractalCounter:hasData(period) and fractalCounter:tick(period) or nil) > 0) then
            fractalCounter_value = 0;
            if fractalCounter_value then
                fractalCounter[period] = fractalCounter_value;
            else
                fractalCounter:setNoData(period);
            end
        end
        highAtDownFractal_value = source.high:tick(period - vars["n"]);
        if highAtDownFractal_value then
            highAtDownFractal[period] = highAtDownFractal_value;
        else
            highAtDownFractal:setNoData(period);
        end
        fractalCounter_value = (fractalCounter:hasData(period) and fractalCounter:tick(period) or nil) - 1;
        if fractalCounter_value then
            fractalCounter[period] = fractalCounter_value;
        else
            fractalCounter:setNoData(period);
        end
    end
    upFractal = ((((vars["n"] == 2)) and (((source.low:tick(period - vars["n"] - 2) > source.low:tick(period - vars["n"]))) and ((source.low:tick(period - vars["n"] - 1) > source.low:tick(period - vars["n"]))) and ((source.low:tick(period - vars["n"] + 1) > source.low:tick(period - vars["n"]))) and ((source.low:tick(period - vars["n"] + 2) > source.low:tick(period - vars["n"])))) or (((source.low:tick(period - 1) < source.low:tick(period - 0))) and ((source.low:tick(period - 1) < source.low:tick(period - 2))))));
    if upFractal then
        Line:New(period - 1, source.low:tick(period - vars["n"]), period, source.low:tick(period - vars["n"])):SetColor(core.colors().Silver):SetExtend("none"):SetStyle("solid"):SetWidth(1);
        if ((fractalCounter:hasData(period) and fractalCounter:tick(period) or nil) < 0) then
            fractalCounter_value = 0;
            if fractalCounter_value then
                fractalCounter[period] = fractalCounter_value;
            else
                fractalCounter:setNoData(period);
            end
        end
        lowAtUpFractal_value = source.low:tick(period - vars["n"]);
        if lowAtUpFractal_value then
            lowAtUpFractal[period] = lowAtUpFractal_value;
        else
            lowAtUpFractal:setNoData(period);
        end
        fractalCounter_value = (fractalCounter:hasData(period) and fractalCounter:tick(period) or nil) + 1;
        if fractalCounter_value then
            fractalCounter[period] = fractalCounter_value;
        else
            fractalCounter:setNoData(period);
        end
    end
    sellSignal = (((fractalCounter:hasData(period) and fractalCounter:tick(period) or nil) < 0)) and ((source.open:tick(period) > (lowAtUpFractal:hasData(period) and lowAtUpFractal:tick(period) or nil))) and ((source.close:tick(period) < (lowAtUpFractal:hasData(period) and lowAtUpFractal:tick(period) or nil)));
    vars["bgcolor_1"]:Set(period, Graphics:AddTransparency((((sellSignal and vars["bgColor"] and vars["showBearishSignal"]) and (core.colors().Red) or (nil))), 80));
    if sellSignal and vars["drawBoxes"] and vars["showBearishSignal"] then
        Box:New(core.formatDate(source:date(period)), "1", period, (lowAtUpFractal:hasData(period) and lowAtUpFractal:tick(period) or nil), period + 10, (highAtDownFractal:hasData(period) and highAtDownFractal:tick(period) or nil)):SetBgColor(core.colors().Red + math.floor(90 / 100 * 255) * 16777216):SetBorderColor(core.colors().Red + math.floor(10 / 100 * 255) * 16777216);
    end
    if source.close:first() > period - 1 then return; end
    if highAtDownFractal:first() > period - 1 then return; end
    buySignal = (((fractalCounter:hasData(period) and fractalCounter:tick(period) or nil) >= 1)) and core.crossesOver(source.close, highAtDownFractal, period);
    vars["bgcolor_2"]:Set(period, Graphics:AddTransparency((((buySignal and vars["bgColor"] and vars["showBullishSignal"]) and (core.colors().Green) or (nil))), 80));
    if buySignal and vars["drawBoxes"] and vars["showBullishSignal"] then
        Box:New(core.formatDate(source:date(period)), "2", period, (highAtDownFractal:hasData(period) and highAtDownFractal:tick(period) or nil), period + 10, (lowAtUpFractal:hasData(period) and lowAtUpFractal:tick(period) or nil)):SetBgColor(core.colors().Green + math.floor(90 / 100 * 255) * 16777216):SetBorderColor(core.colors().Green + math.floor(10 / 100 * 255) * 16777216);
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    BGColor:Draw(stage, context);
    Box:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
function Graphics:SplitColorAndTransparency(clr)
    local transparency = (math.floor(clr / 16777216) % 255);
    local color = clr - transparency * 16777216;
    return color, transparency;
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216
end
Line = {};
Line.AllLines = {};
function Line:Clear()
    Line.AllLines = {};
end
function Line:Prepare(max_lines_count)
    Line.max_lines_count = max_lines_count;
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
function Line:SetXLoc(line, x1, x2, xloc)
    if line == nil then
        return;
    end
    line:SetXLoc(x1, x2, xloc);
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
    newLine.XLoc = "bar_index";
    function newLine:SetXLoc(x1, x2, xloc)
        newLine.X1 = x1;
        newLine.X2 = x2;
        newLine.XLoc = xloc;
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
        self.ColorTransparency = (math.floor(clr / 16777216) % 255);
        self.Color = clr - self.ColorTransparency * 16777216;
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
    function newLine:converXToPoints(context, x)
        if self.XLoc == "bar_time" then
            return context:positionOfDate(x / 86400000);
        end
        _, x1 = context:positionOfBar(x);
        return x1;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil or self.X1 == nil or self.X2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        x1 = self:converXToPoints(context, self.X1);
        x2 = self:converXToPoints(context, self.X2);
        _, y1 = context:pointOfPrice(self.Y1);
        _, y2 = context:pointOfPrice(self.Y2);
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:right() + c;
            context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
        end
        if self.Extend == "left" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:left() + c;
            context:drawLine(self.PenId, x1, y1, context:left(), y3, self.ColorTransparency);
        end
    end
    self.AllLines[#self.AllLines + 1] = newLine;
    if #self.AllLines > self.max_lines_count then
        table.remove(self.AllLines, 1);
    end
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
BGColor = {};
BGColor.AllBGColors = {};
function BGColor:Clear()
end
function BGColor:Create()
    local newBGColor = {};
    newBGColor.Items = {};
    function newBGColor:Draw(stage, context)
        for date, bar in pairs(self.Items) do
            local index = core.findDate(instance.source, date, false);
            if index ~= -1 and index >= context:firstBar() and index <= context:lastBar() then
                if bar.PenId == nil then
                    bar.PenId = Graphics:FindPen(1, bar.Color, core.LINE_SOLID, context);
                end
                if bar.BrushId == nil then
                    bar.BrushId = Graphics:FindBrush(bar.Color, context);
                end
                x, xs, xe = context:positionOfBar(index);
                context:drawRectangle(bar.PenId, bar.BrushId, xs, context:top(), xe, context:bottom(), bar.Transparency);
            end
        end
    end
    function newBGColor:Set(period, clr)
        local date = instance.source:date(period);
        if clr == nil then
            newBGColor.Items[date] = nil;
            return;
        end
        if newBGColor.Items[date] == nil then
            newBGColor.Items[date] = {};
        end
        color, transp = Graphics:SplitColorAndTransparency(clr);
        newBGColor.Items[date].Color = color;
        newBGColor.Items[date].Transparency = transp;
        newBGColor.Items[date].PenId = nil;
        newBGColor.Items[date].BrushId = nil;
    end
    self.AllBGColors[#self.AllBGColors + 1] = newBGColor
    return newBGColor;
end
function BGColor:Draw(stage, context)
    if stage ~= 0 then
        return;
    end
    for i, bgcolor in ipairs(self.AllBGColors) do
        bgcolor:Draw(stage, context);
    end
end
Box = {};
Box.AllBoxs = {};
Box.AllSeries = {};
function Box:Clear()
    Box.AllBoxs = {};
    Box.AllSeries = {};
end
function Box:New(id, seriesId, left, top, right, bottom)
    local newBox = {};
    newBox.SeriesId = seriesId;
    newBox.Left = left;
    newBox.Top = top;
    newBox.Right = right;
    newBox.Bottom = bottom;
    newBox.BorderWidth = 1;
    newBox.BorderStyle = core.LINE_SOLID;
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
    function newBox:Draw(stage, context)
        if self.Top == nil or self.Left == nil or self.Bottom == nil or self.Right == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.BorderWidth, self.BorderColor, self.BorderStyle, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.BgColor, context);
        end
        _, y1 = context:pointOfPrice(self.Top);
        _, x1 = context:positionOfBar(self.Left);
        _, y2 = context:pointOfPrice(self.Bottom);
        _, x2 = context:positionOfBar(self.Right);
        context:drawRectangle(self.PenId, self.BrushId, x1, y1, x2, y2, self.BgColorTransparency)
        context:drawRectangle(self.PenId, -1, x1, y1, x2, y2)
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
    for i = 1, #self.AllBoxs do
        if self.AllBoxs[i] == box then
            table.remove(self.AllBoxs, i);
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