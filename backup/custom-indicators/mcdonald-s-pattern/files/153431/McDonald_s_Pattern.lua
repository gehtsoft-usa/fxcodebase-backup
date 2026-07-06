-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74191

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
    indicator:name("McDonald's Pattern [LuxAlgo]");
    indicator:description("McDonald's Pattern [LuxAlgo]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "", "", 30);
    indicator.parameters:addBoolean("param2", "Use First Bar As Vertex", "", true);
    indicator.parameters:addColor("param3", "Shape Color", "", core.rgb(255, 199, 44));
    indicator.parameters:addInteger("param4", "Width", "", 2);
    indicator.parameters:addInteger("param5", "", "", 30);
    indicator.parameters:addBoolean("param6", "Area", "", true);
    indicator.parameters:addColor("param7", "", "", core.rgb(218, 41, 28));
    indicator.parameters:addColor("param8", "", "", core.rgb(12, 181, 26));
    indicator.parameters:addBoolean("param9", "McDonald's Score", "", true);
end

local source;
local params = {};
local valtop;
local valbtm;
local a;
local b;
local os;
local plot1;
local plot2;
local vars = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["length"] = instance.parameters.param1;
    vars["from_start"] = instance.parameters.param2;
    vars["css"] = instance.parameters.param3;
    vars["min_width"] = instance.parameters.param4;
    vars["max_width"] = instance.parameters.param5;
    vars["colored_area"] = instance.parameters.param6;
    vars["css_dn"] = instance.parameters.param7;
    vars["css_up"] = instance.parameters.param8;
    vars["show_score"] = instance.parameters.param9;
    valtop = instance:addInternalStream(0, 0);
    valbtm = instance:addInternalStream(0, 0);
    a = instance:addInternalStream(0, 0);
    b = instance:addInternalStream(0, 0);
    os = instance:addInternalStream(0, 0);
    plot1 = instance:createTextOutput("plot1", "plot1", "Verdana", 10, core.H_Center, core.V_Top, core.colors().Blue, 0);
    plot2 = instance:createTextOutput("plot2", "plot2", "Verdana", 10, core.H_Center, core.V_Top, core.colors().Blue, 0);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        valtop[period] = nil;
        valbtm[period] = nil;
        Table:Clear();
        vars["tb"] = Table:New("top_right", 1, 2);
        vars["Y"] = Array:NewFloat(0);
        vars["X"] = Array:NewInt(0);
        Line:Clear();
        Box:Clear();
    else
        valtop[period] = valtop:tick(period - 1);
        valbtm[period] = valbtm:tick(period - 1);
    end
    os[period] = 0;
    src = source.close[period];
    n = period;
    a[period] = math.max(source.close[period], source.open[period]);
    b[period] = math.min(source.close[period], source.open[period]);
    if a:first() > period - vars["length"] then return; end
    upper = mathex.max(a, core.rangeTo(period, vars["length"]));
    if b:first() > period - vars["length"] then return; end
    lower = mathex.min(b, core.rangeTo(period, vars["length"]));
    if a:first() > period - vars["length"] then return; end
    if b:first() > period - vars["length"] then return; end
    if os:first() > period - 1 then return; end
    os[period] = (((a:tick(period - vars["length"]) > upper)) and (0) or ((((b:tick(period - vars["length"]) < lower)) and (1) or (os:tick(period - 1)))));
    if os:first() > period - 1 then return; end
    btm = (os:tick(period) == 1) and (os:tick(period - 1) ~= 1);
    if os:first() > period - 1 then return; end
    top = (os:tick(period) == 0) and (os:tick(period - 1) ~= 0);
    if top then
        if a:first() > period - vars["length"] then return; end
        vars["Y"]:Unshift(a:tick(period - vars["length"]));
        vars["X"]:Unshift(n - vars["length"]);
    end
    if btm then
        if b:first() > period - vars["length"] then return; end
        vars["Y"]:Unshift(b:tick(period - vars["length"]));
        vars["X"]:Unshift(n - vars["length"]);
    end
    if ((top) and (source.high[period - vars["length"]]) or (nil)) then
        plot1:set(period, source.close[period], "T", "");
    end
    if ((btm) and (source.low[period - vars["length"]]) or (nil)) then
        plot2:set(period, source.close[period], "B", "");
    end
    a_y = 0.;
    b_y = 0.;
    c_y = 0.;
    d_y = 0.;
    if period == source:size() - 1 then
        dist_a = 0.;
        dist_b = 0.;
        for _, l in ipairs(Line.AllLines) do
            Line:Delete(l);
        end
        if vars["from_start"] then
            vars["Y"]:Unshift(source.close[period]);
            vars["X"]:Unshift(n);
        end
        max = vars["Y"]:Slice(0, 5):Max();
        min = vars["Y"]:Slice(0, 5):Min();
        val = (((vars["Y"]:Get(0) < vars["Y"]:Get(1))) and (min) or (max));
        dist1 = vars["X"]:Get(0) - vars["X"]:Get(2);
        a_y = vars["Y"]:Get(2);
        b_y = vars["Y"]:Get(1);
        c_y = vars["Y"]:Get(1);
        d_y = vars["Y"]:Get(0);
        y1 = nil;
        for i = 0, dist1, 1 do
            k = i / dist1;
            y2 = a_y * math.pow(1 - k, 3) + 3 * b_y * math.pow(1 - k, 2) * k + 3 * c_y * (1 - k) * math.pow(k, 2) + d_y * math.pow(k, 3);
            dist_a = dist_a + math.abs(y2 - val);
            r = (vars["X"]:Get(0) - vars["X"]:Get(1)) / dist1;
            w = vars["min_width"] + math.abs(i / dist1 - r) * (vars["max_width"] - vars["min_width"]);
            Line:New(vars["X"]:Get(2) + i, y2, vars["X"]:Get(2) + i - 1, y1):SetColor(vars["css"]);
            y1 = y2;
        end
        dist2 = vars["X"]:Get(2) - vars["X"]:Get(4);
        a_y = vars["Y"]:Get(4);
        b_y = vars["Y"]:Get(3);
        c_y = vars["Y"]:Get(3);
        d_y = vars["Y"]:Get(2);
        y1 = nil;
        for i = 0, dist2, 1 do
            k = i / dist2;
            y2 = a_y * math.pow(1 - k, 3) + 3 * b_y * math.pow(1 - k, 2) * k + 3 * c_y * (1 - k) * math.pow(k, 2) + d_y * math.pow(k, 3);
            dist_b = dist_b + math.abs(y2 - val);
            r = (vars["X"]:Get(3) - vars["X"]:Get(4)) / dist2;
            w = vars["min_width"] + math.abs(i / dist2 - r) * (vars["max_width"] - vars["min_width"]);
            Line:New(vars["X"]:Get(4) + i, y2, vars["X"]:Get(4) + i - 1, y1):SetColor(vars["css"]);
            y1 = y2;
        end
        if vars["colored_area"] then
            area_css = (((vars["Y"]:Get(0) < vars["Y"]:Get(1))) and (vars["css_dn"]) or (vars["css_up"]));
            Box:Delete(Box:New(core.formatDate(source:date(vars["X"]:Get(4))), "1", vars["X"]:Get(4), max, vars["X"]:Get(0), min):SetBgColor(area_css + math.floor(80 / 100 * 256) * 16777216):Get(1));
        end
        if vars["from_start"] then
            vars["Y"]:Shift();
            vars["X"]:Shift();
        end
        a[period] = dist_a / dist1;
        b[period] = dist_b / dist2;
        score = (1 - math.abs(a:tick(period) / (a:tick(period) + b:tick(period)) - .5) * 2) * 100;
        if vars["show_score"] then
            vars["tb"]:CellText(0, 0, "McDonald's Score"):CellTextColor(0, 0, core.colors().Gray);
            vars["tb"]:CellText(0, 1, Str:ToString(score, "#.##") .. "%"):CellTextColor(0, 1, core.colors().Gray);
        end
    end
end
function Draw(stage, context)
    Table:Draw(stage, context);
    Line:Draw(stage, context);
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
    function newTable:getRowDirection()
        if self.position == "top_left" or self.position == "top_right" or self.position == "top_middle" then
            return 1;
        end
        if self.position == "bottom_left" or self.position == "bottom_right" or self.position == "bottom_middle" then
            return -1;
        end
        return 0;
    end
    function newTable:getColumnDirection()
        if self.position == "top_left" or self.position == "bottom_left" or self.position == "middle_left" then
            return 1;
        end
        if self.position == "top_right" or self.position == "bottom_right" or self.position == "middle_right" then
            return -1;
        end
        return 0;
    end
    function newTable:measureCells(context)
        local columnWidths = {};
        local rowHeights = {};
        local cellSizes = {};
        for row = 1, #self.rows do
            cellSizes[row] = {};
            for column = 1, #self.rows[row] do
                local W, H = context:measureText(Table.FontId, self.rows[row][column].text, context.LEFT);
                if columnWidths[column] == nil or columnWidths[column] < W then
                    columnWidths[column] = W;
                end
                if rowHeights[row] == nil or rowHeights[row] < H then
                    rowHeights[row] = H;
                end
                cellSizes[row][column] = {};
                cellSizes[row][column].H = H;
                cellSizes[row][column].W = W;
            end
        end
        return rowHeights, columnWidths, cellSizes;
    end
    function newTable:Draw(stage, context)
        if self.bgcolor ~= nil and self.BgBrushId == nil then
            self.BgBrushId = Graphics:FindBrush(self.bgcolor, context);
        end
        if self.FramePenId == nil then
            self.FramePenId = Graphics:FindPen(self.border_width, self.border_color, self.border_style, context);
        end
        local rowHeights, columnWidths, cellSizes = self:measureCells(context);
        
        local rowDirection = self:getRowDirection();
        local columnDirection = self:getColumnDirection();
        local yStart = rowDirection == 1 and context:top() or context:bottom();
        local totalRows = #self.rows;
        for rowIt = 1, totalRows do
            local row = rowIt;
            if rowDirection == -1 then
                row = totalRows - rowIt + 1;
            end
            local xStart = columnDirection == 1 and context:left() or context:right(); 
            local totalCoumns = #self.rows[rowIt];
            for columnIt = 1, totalCoumns do
                local column = columnIt;
                if columnDirection == -1 then
                    column = totalCoumns - columnIt + 1;
                end

                local rectangle_x1;
                local rectangle_x2;
                local rectangle_y1;
                local rectangle_y2;
                if rowDirection == -1 then
                    rectangle_y1 = yStart - rowHeights[row];
                    rectangle_y2 = yStart;
                elseif rowDirection == 1 then
                    rectangle_y1 = yStart;
                    rectangle_y2 = yStart + rowHeights[row];
                end
                if columnDirection == -1 then
                    rectangle_x1 = xStart - columnWidths[column];
                    rectangle_x2 = xStart;
                    xStart = rectangle_x1;
                elseif columnDirection == 1 then
                    rectangle_x1 = xStart;
                    rectangle_x2 = xStart + columnWidths[column];
                    xStart = rectangle_x2;
                end
                local x = (rectangle_x1 + rectangle_x2) / 2;
                local text_x1 = x - cellSizes[row][column].W / 2;
                local text_x2 = text_x1 + cellSizes[row][column].W;
                local y = (rectangle_y1 + rectangle_y2) / 2;
                local text_y1 = y - cellSizes[row][column].H / 2;
                local text_y2 = y + cellSizes[row][column].H;
                if self.BgBrushId ~= nil then
                    context:drawRectangle(self.FramePenId, self.BgBrushId, rectangle_x1, rectangle_y1, rectangle_x2, rectangle_y2)
                end
                context:drawText(Table.FontId, self.rows[row][column].text, self.rows[row][column].text_color, -1, 
                    text_x1, text_y1, text_x2, text_y2, 0);
            end
            if rowDirection == -1 then
                yStart = yStart - rowHeights[row];
            elseif rowDirection == 1 then
                yStart = yStart + rowHeights[row];
            end
        end
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
Array = {};
function Array:Max(array)
    local maxVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if maxVal == nil or maxVal < val then
            maxVal = val;
        end
    end
    return maxVal;
end
function Array:Min(array)
    local minVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if minVal == nil or minVal > val then
            minVal = val;
        end
    end
    return minVal;
end
function Array:NewArray(size)
    local newArray = {};
    newArray.arr = {};
    for i = 1, size, 1 do
        newArray.arr[i] = nil;
    end
    function newArray:Push(item) self.arr[#self.arr + 1] = item; end
    function newArray:Get(index) return self.arr[index + 1]; end
    function newArray:Max() return Array:Max(self); end
    function newArray:Min() return Array:Min(self); end
    function newArray:Size() return #self.arr; end
    function newArray:Sum()
        local sum = 0;
        for i, v in ipairs(self.arr) do
            sum = sum + v;
        end
        return sum;
    end
    function newArray:Unshift(value)
        local nextValue = value;
        for i = 1, #self.arr, 1 do
            local current = self.arr[i];
            self.arr[i] = nextValue;
            nextValue = current;
        end
        self.arr[#self.arr + 1] = nextValue;
    end
    function newArray:Shift(value)
        table.remove(self.arr, 1);
        self.arr[#self.arr + 1] = nextValue;
    end
    function newArray:Slice(from, to)
        local slice = {};
        slice.Parent = self;
        slice.From = from;
        slice.To = to;
        function slice:Get(index)
            return self.Parent:Get(index + self.From);
        end
        function slice:Size()
            return self.To - self.From;
        end
        function slice:Max()
            return Array:Max(self);
        end
        function slice:Min()
            return Array:Min(self);
        end
        return slice;
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
        self.BgColorTransparency = (math.floor(clr / 16777216) % 256);
        self.BgColor = clr - self.BgColorTransparency * 16777216;
        self.BrushId = nil;
        return self;
    end
    newBox.BorderColor = core.colors().Blue;
    function newBox:SetBorderColor(clr)
        self.BorderColor = clr;
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
Str = {};
function Str:ToString(value, pattern)
    local luaPattern = "";
    local waitNumber = false;
    local digits = 0;
    for i = 1, #pattern do
        local char = string.sub(pattern, i, i);
        if not waitNumber then
            if char == "#" then
                waitNumber = true;
                luaPattern = luaPattern .. "%";
            else
                luaPattern = luaPattern .. char;
            end
        else
            if char == "." then
                luaPattern = luaPattern .. ".";
            elseif char == "#" then
                digits = digits + 1;
            else
                luaPattern = luaPattern .. digits .. "f";
                waitNumber = false;
                digits = 0;
            end
        end
    end
    if waitNumber then
        luaPattern = luaPattern .. digits .. "f";
        waitNumber = false;
        digits = 0;
    end
    
    return string.format(luaPattern, value);
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