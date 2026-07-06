-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70584

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Time of high/low");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addColor("label_color", "Labels color", "", core.colors().Red);
    indicator.parameters:addInteger("x", "X", "", 20);
    indicator.parameters:addInteger("y", "Y", "", 100);
end

local source, m1, tradingWeekOffset, tradingDayOffset;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    m1 = core.host:execute("getSyncHistory", source:instrument(), "m1", true, 300, 1, 2);

    instance:ownerDrawn(true);
end

local highTime;
local lowTime;
local notEnoughtData;

function Update(period, mode)
    if m1:size() == 0 then
        return;
    end
    local s, e = core.getcandle("D1", source:date(period), tradingDayOffset, tradingWeekOffset);
    local index = core.findDate(m1, s, false);
    if index < 0 then
        return;
    end
    local min, max, minpos, maxpos = mathex.minmax(m1, core.range(index, m1:size() - 1));
    highTime = m1:date(maxpos);
    lowTime = m1:date(minpos);
    notEnoughtData = maxpos == 0 or minpos == 0;
end


-- Cells builder v1.4
local CellsBuilder = {};
CellsBuilder.GapCoeff = 1.2;
function CellsBuilder:Clear(context)
    self.Columns = {};
    self.RowHeights = {};
    self.Context = context;
end
function CellsBuilder:AddGap(column, row, w, h)
    if self.Columns[column] == nil then
        self.Columns[column] = {};
        self.Columns[column].Rows = {};
        self.Columns[column].MaxWidth = 0;
        self.Columns[column].MaxHeight = 0;
        self.Columns[column].MaxRowIndex = 0;
    end
    if self.Columns[column].MaxRowIndex < row then
        self.Columns[column].MaxRowIndex = row;
    end
    if self.Columns[column].MaxWidth < w then
        self.Columns[column].MaxWidth = w;
    end
    if self.RowHeights[row] == nil or self.RowHeights[row] < h then
        self.RowHeights[row] = h;
    end
end
function CellsBuilder:Add(font, text, color, column, row, mode, backgound, grid_pen, grid_top, grid_bottom)
    if self.Columns[column] == nil then
        self.Columns[column] = {};
        self.Columns[column].Rows = {};
        self.Columns[column].MaxWidth = 0;
        self.Columns[column].MaxHeight = 0;
        self.Columns[column].MaxRowIndex = 0;
    end
    local cell = {};
    cell.Text = text;
    cell.Font = font;
    cell.Color = color;
    local w, h = self.Context:measureText(font, text, mode);
    cell.Width = w;
    cell.Height = h;
    cell.Mode = mode;
    cell.Background = backgound;
    cell.GridPen = grid_pen;
    cell.DrawGridTop = grid_top;
    cell.DrawGridBottom = grid_bottom;
    self.Columns[column].Rows[row] = cell;
    if self.Columns[column].MaxRowIndex < row then
        self.Columns[column].MaxRowIndex = row;
    end
    if self.Columns[column].MaxWidth < w then
        self.Columns[column].MaxWidth = w;
    end
    if self.RowHeights[row] == nil or self.RowHeights[row] < h then
        self.RowHeights[row] = h;
    end
    return cell;
end
function CellsBuilder:GetTotalWidth()
    local width = 0;
    for columnIndex, column in ipairs(self.Columns) do
        width = width + column.MaxWidth * self.GapCoeff;
    end
    return width;
end
function CellsBuilder:GetTotalHeight()
    local height = 0;
    for i = 0, self.Columns[1].MaxRowIndex do
        if self.RowHeights[i] ~= nil then
            height = height + self.RowHeights[i] * self.GapCoeff;
        end
    end
    return height;
end
function CellsBuilder:Draw(x, y)
    local max_height = self:GetTotalHeight();
    local max_width = self:GetTotalWidth();
    local total_width = 0;
    for columnIndex, column in ipairs(self.Columns) do
        local total_height = 0;
        for i = 0, column.MaxRowIndex do
            local cell = column.Rows[i];
            if cell ~= nil then
                local x_start = x + total_width;
                local y_start = y + total_height;
                local x_end = x_start + column.MaxWidth * self.GapCoeff;
                local y_end = y_start + self.RowHeights[i] * self.GapCoeff;
                local y_shift = 0;
                if cell.RowSpan ~= nil and cell.RowSpan > 1 then
                    for ii = i + 1, i + cell.RowSpan - 1 do
                        y_end = y_end + self.RowHeights[ii] * self.GapCoeff;
                        y_shift = (self.RowHeights[ii] * self.GapCoeff) / 2;
                    end
                end
                if cell.Background ~= nil then
                    self.Context:drawRectangle(cell.GridPen, cell.Background, x_start, y_start, x_end, y_end);
                end
                self.Context:drawText(cell.Font, cell.Text, 
                    cell.Color, -1, 
                    x_start + column.MaxWidth * (self.GapCoeff - 1) / 2, 
                    y_start + y_shift + self.RowHeights[i] * (self.GapCoeff - 1) / 2, 
                    x_end, 
                    y_end,
                    cell.Mode);
                if cell.GridPen ~= nil then
                    if cell.DrawGridTop then
                        self.Context:drawLine(cell.GridPen, x_start, y_start, x_end, y_start); -- top
                    end
                    if cell.DrawGridBottom then
                        self.Context:drawLine(cell.GridPen, x_start, y_end, x_end, y_end); -- bottom
                    end
                    self.Context:drawLine(cell.GridPen, x_start, y_start, x_start, y_end); -- left
                    self.Context:drawLine(cell.GridPen, x_end, y_start, x_end, y_end); -- right
                end
            end
            if self.RowHeights[i] ~= nil then
                total_height = total_height + self.RowHeights[i] * self.GapCoeff;
            end
        end
        total_width = total_width + column.MaxWidth * self.GapCoeff;
    end
end

local init = false;
local label_color;
local FONT_ID = 1;
function Draw(stage, context)
    if stage ~= 2 or highTime == nil then
        return;
    end
    if not init then
        init = true;
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(10), context.LEFT);
        label_color = instance.parameters.label_color;
    end
    CellsBuilder:Clear(context);
    if notEnoughtData then
        CellsBuilder:Add(FONT_ID, "Not enought data. Select a higher timeframe", label_color, 1, 1, 0);
    else
        CellsBuilder:Add(FONT_ID, "High", label_color, 1, 1, 0);
        CellsBuilder:Add(FONT_ID, "Low", label_color, 1, 2, 0);
        CellsBuilder:Add(FONT_ID, core.formatDate(highTime), label_color, 2, 1, 0);
        CellsBuilder:Add(FONT_ID, core.formatDate(lowTime), label_color, 2, 2, 0);
    end
    CellsBuilder:Draw(instance.parameters.x, instance.parameters.y);
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
end