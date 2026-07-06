-- Light dashboard template v.1.1

local currencies = { "USD", "EUR", "JPY", "GBP", "CHF", "CAD", "AUD", "CNY", "HKD", "XAG", "XAU" };
local ranges = { -2.5, -0.5, -0.05, 0.05, 0.5, 2.5 };
local default_colors = { core.colors().Pink, core.colors().Red, core.colors().DarkRed, core.colors().Gray, core.colors().DarkGreen, core.colors().Green, core.colors().Lime };
local Modules = {};

-- USER DEFINITIONS SECTION
local indi_name = "Dashboard";
local indi_version = "1";
local LAST_PEN = 6;

function CreateIndicators(source)
    local indicators = {};
    return indicators;
end

function CreateParameters()
end

function GetColorIndex(value)
    for i, rangeValue in ipairs(ranges) do
        if value < rangeValue then
            return i;
        end
    end
    return #ranges + 1;
end

function GetSignal(symbol, reverse)
    local signal = {};
    if symbol.Source == nil and not symbol.Loading then
        signal.Text = "-";
        signal.RevText = "-";
        signal.ColorIndex = -LAST_PEN - 1;
        signal.RevColorIndex = -LAST_PEN - 1;
        return signal;
    end
    if symbol.Loading or symbol.Source:size() == 0 or symbol.Source2:size() == 0 then
        signal.Text = "...";
        signal.RevText = "...";
        signal.ColorIndex = -LAST_PEN - 1;
        signal.RevColorIndex = -LAST_PEN - 1;
        return signal;
    end
    local range = symbol.Source2.high[NOW] - symbol.Source2.low[NOW];
    local Value = (symbol.Source.close[NOW] - symbol.Source.open[NOW]) / range * 100.0;
    signal.ColorIndex = GetColorIndex(Value);
    signal.Text = win32.formatNumber(symbol.Source[NOW], false, symbol.Source:getPrecision());
    
    local range = 1 / symbol.Source2.high[NOW] - 1 / symbol.Source2.low[NOW];
    local Value = (1 / symbol.Source.close[NOW] - 1 / symbol.Source.open[NOW]) / range * 100.0;
    signal.RevColorIndex = GetColorIndex(Value);
    signal.RevText = win32.formatNumber(1 / symbol.Source[NOW], false, symbol.Source:getPrecision());
    return signal;
end
-- ENF OF USER DEFINITIONS SECTION

function Init()
    indicator:name(indi_name .. " v." .. indi_version);
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);
    indicator:setTag("Version", indi_version)

    CreateParameters();

    indicator.parameters:addString("tf", "Timeframe", "", "m5");
    indicator.parameters:setFlag("tf", core.FLAG_BARPERIODS);

    indicator.parameters:addGroup("Levels");
    for i, rangeValue in ipairs(ranges) do
        indicator.parameters:addDouble("level_" .. i, "Level " .. i, "", ranges[i]);
        if i == 1 then
            indicator.parameters:addColor("clr_" .. i, "Val < Level " .. i .. " Color", "", default_colors[i]);
        else
            indicator.parameters:addColor("clr_" .. i, "Level " .. (i - 1) .. " < val < Level " .. i .. " Color", "", default_colors[i]);
        end
    end
    indicator.parameters:addColor("clr_" .. (#ranges + 1), "Val > Level " .. (#ranges) .. " Color", "", default_colors[#ranges + 1]);

    indicator.parameters:addGroup("Styling");
    indicator.parameters:addColor("up_color", "Up color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("dn_color", "Down color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("text_color", "Text color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("background_color", "Background color", "", core.rgb(255, 255, 255));
    indicator.parameters:addInteger("load_quota", "Loading quota", "Prevents freeze. Use 0 to disable", 0);
    indicator.parameters:addDouble("cells_gap", "Gap coefficient", "", 1.2);
    indicator.parameters:addColor("grid_color", "Grid color", "", core.rgb(128, 128, 128));
end

local items = {};

local text_color, symbol_text_color;
local TIMER_ID = 1;
local last_id = 1;

function PrepareInstrument()
    for i = 1, #currencies do
        for ii = i + 1, #currencies do
            local pair = currencies[i] .. "/" .. currencies[ii];
            local offer = core.host:findTable("offers"):find("Instrument", pair);
            if offer == nil then
                pair = currencies[ii] .. "/" .. currencies[i];
                offer = core.host:findTable("offers"):find("Instrument", pair);
            end
            if offer ~= nil then
                local symbol = {};
                symbol.Pair = offer.Instrument;
                symbol.Point = offer.PointSize;
                symbol.TF = instance.parameters.tf;
                symbol.LoadingId = last_id + 1;
                symbol.LoadedId = last_id + 2;
                symbol.Loading2Id = last_id + 3;
                symbol.Loaded2Id = last_id + 4;
                symbol.Loading = true;
                symbol.SymbolIndex = i;
                symbol.TimeframeIndex = ii;
                function symbol:DoLoad()
                    self.Source = core.host:execute("getSyncHistory", self.Pair, self.TF, instance.source:isBid(), 300, self.LoadedId, self.LoadingId);
                    self.Source2 = core.host:execute("getSyncHistory", self.Pair, "D1", instance.source:isBid(), 300, self.Loaded2Id, self.Loading2Id);
                    self.Indicators = CreateIndicators(self.Source);
                end
                last_id = last_id + 4;
                items[#items + 1] = symbol;
            else
                local symbol = {};
                symbol.SymbolIndex = i;
                symbol.TimeframeIndex = ii;
                function symbol:DoLoad()
                    self.Loading = false;
                end
                items[#items + 1] = symbol;
            end
        end
    end
end

local timer_handle;
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
    local selectedrow = self.Columns[column].Rows[row];
    if selectedrow == nil then
        selectedrow = {};
        selectedrow.Cells = {};
        self.Columns[column].Rows[row] = selectedrow;
    end
    selectedrow.Background = backgound;
    selectedrow.GridPen = grid_pen;
    selectedrow.DrawGridTop = grid_top;
    selectedrow.DrawGridBottom = grid_bottom;
    selectedrow.Cells[#selectedrow.Cells + 1] = cell;
    local totalW = 0;
    for i, c in ipairs(selectedrow.Cells) do
        totalW = totalW + c.Width;
    end
    if self.Columns[column].MaxRowIndex < row then
        self.Columns[column].MaxRowIndex = row;
    end
    if self.Columns[column].MaxWidth < totalW then
        self.Columns[column].MaxWidth = totalW;
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
            local row = column.Rows[i];
            if row ~= nil then
                local x_start = x + total_width;
                local y_start = y + total_height;
                local x_end = x_start + column.MaxWidth * self.GapCoeff;
                local y_end = y_start + self.RowHeights[i] * self.GapCoeff;
                local y_shift = 0;
                if row.Background ~= nil then
                    self.Context:drawRectangle(row.GridPen, row.Background, x_start, y_start, x_end, y_end);
                end
                local widthToDraw = 0;
                local maxRowSpan = 1;
                for i, cell in ipairs(row.Cells) do
                    widthToDraw = widthToDraw + cell.Width;
                    if cell.RowSpan ~= nil and cell.RowSpan > 1 then
                        maxRowSpan = math.max(maxRowSpan, cell.RowSpan);
                    end
                end
                for ii = i + 1, i + maxRowSpan - 1 do
                    y_end = y_end + self.RowHeights[ii] * self.GapCoeff;
                    y_shift = (self.RowHeights[ii] * self.GapCoeff) / 2;
                end
                local drawn = 0;
                for i, cell in ipairs(row.Cells) do
                    widthToDraw = widthToDraw - cell.Width;
                    self.Context:drawText(cell.Font, cell.Text, 
                        cell.Color, -1, 
                        x_start + drawn + column.MaxWidth * (self.GapCoeff - 1) / 2, 
                        y_start + y_shift + self.RowHeights[i] * (self.GapCoeff - 1) / 2, 
                        x_end - widthToDraw, 
                        y_end,
                        cell.Mode);
                    drawn = drawn + cell.Width;
                end
                if row.GridPen ~= nil then
                    if row.DrawGridTop then
                        self.Context:drawLine(row.GridPen, x_start, y_start, x_end, y_start); -- top
                    end
                    if row.DrawGridBottom then
                        self.Context:drawLine(row.GridPen, x_start, y_end, x_end, y_end); -- bottom
                    end
                    self.Context:drawLine(row.GridPen, x_start, y_start, x_start, y_end); -- left
                    self.Context:drawLine(row.GridPen, x_end, y_start, x_end, y_end); -- right
                end
            end
            if self.RowHeights[i] ~= nil then
                total_height = total_height + self.RowHeights[i] * self.GapCoeff;
            end
        end
        total_width = total_width + column.MaxWidth * self.GapCoeff;
    end
end

function Prepare(nameOnly)
    instance:name(indi_name);
    if nameOnly then
        return;
    end
    
    for i, rangeValue in ipairs(ranges) do
        ranges[i] = instance.parameters:getDouble("level_" .. i);
        default_colors[i] = instance.parameters:getColor("clr_" .. i);
    end
    default_colors[#ranges + 1] = instance.parameters:getColor("clr_" .. (#ranges + 1));

    text_color = instance.parameters.text_color;
    symbol_text_color = instance.parameters.symbol_text_color;
    timer_handle = core.host:execute("setTimer", TIMER_ID, 1);
    core.host:execute("setStatus", "Loading");
    instance:ownerDrawn(true);
    CellsBuilder.GapCoeff = instance.parameters.cells_gap;
    PrepareInstrument();
    O = instance:addStream("O", core.Line, "O", "O", core.rgb(255, 0, 0), 0);
    instance:initView(indi_name, 2, 0.01, true, false);
end

local init = false;
local FONT = 1;
local FONT_TEXT = 2;
local FONT_ARROWS = 6;
local BG_PEN = 3;
local BG_BRUSH = 4;
local GRID_PEN = 5;

function DrawSignal(symbol, context, index)
    if symbol.Signal == nil then
        return;
    end

    CellsBuilder:Add(FONT_TEXT, symbol.Signal.Text, text_color, symbol.SymbolIndex + 1, symbol.TimeframeIndex + 1, context.CENTER, LAST_PEN + symbol.Signal.ColorIndex, GRID_PEN, true, true);
    if symbol.SymbolIndex ~= symbol.TimeframeIndex then
        CellsBuilder:Add(FONT_TEXT, symbol.Signal.RevText, text_color, symbol.TimeframeIndex + 1, symbol.SymbolIndex + 1, context.CENTER, LAST_PEN + symbol.Signal.RevColorIndex, GRID_PEN, true, true);
    end
end
function Draw(stage, context) 
    if stage ~= 2 then
        return;
    end
    if not init then
        instrument_bg_brushes = {};
        context:createFont(FONT_TEXT, "Arial", 0, context:pointsToPixels(8), 0);
        context:createFont(FONT_ARROWS, "Wingdings", 0, context:pointsToPixels(8), 0);
        context:createPen(BG_PEN, context.SOLID, 1, instance.parameters.background_color);
        context:createSolidBrush(BG_BRUSH, instance.parameters.background_color);
        context:createPen(GRID_PEN, context.SOLID, 1, instance.parameters.grid_color);
        for i, clr in ipairs(default_colors) do
            context:createSolidBrush(LAST_PEN + i, clr);
        end
        init = true;
    end
    local title_w, title_h = context:measureText(FONT_TEXT, indi_name, 0);
    CellsBuilder:Clear(context);
    for i = 1, #currencies do
        local text = "   " .. currencies[i] .. "   ";
        CellsBuilder:Add(FONT_TEXT, text, text_color, 1, i + 1, context.CENTER, nil, GRID_PEN, true, false);
        CellsBuilder:Add(FONT_TEXT, text, text_color, i + 1, 1, context.CENTER, nil, GRID_PEN, true, false);
    end
    for ii, symbol in ipairs(items) do
        DrawSignal(symbol, context, ii);
    end
    local width = math.max(title_w, CellsBuilder:GetTotalWidth());
    context:drawRectangle(BG_PEN, BG_BRUSH, context:right() - width, context:top(), context:right(), context:top() + title_h * 1.2 + CellsBuilder:GetTotalHeight());
    context:drawText(FONT_TEXT, indi_name, text_color, -1, context:right() - width, context:top(), context:right(), context:top() + title_h, 0);
    CellsBuilder:Draw(context:right() - width, context:top() + title_h * 1.2);
end

function Update(period, mode)
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(nil, nil, nil); end end
end

local added = false;

function UpdateData()
    for _, symbol in ipairs(items) do
        if symbol.Indicators ~= nil then
            for i, indicator in ipairs(symbol.Indicators) do
                indicator:update(core.UpdateLast);
            end
        end
        symbol.Signal = GetSignal(symbol);
    end
    if not added then
        instance:addViewBar(core.now());
        added = true;
    end
end

local loading_finished = false;
function AsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == TIMER_ID then
        UpdateData();
        if not loading_finished then
            local loading_count = 0;
            for _, symbol in ipairs(items) do
                if symbol.Source == nil then
                    symbol:DoLoad();
                    loading_count = loading_count + 1;
                elseif symbol.Loading then
                    loading_count = loading_count + 1;
                end
                if loading_count == instance.parameters.load_quota and instance.parameters.load_quota > 0 then
                    return;
                end
            end
            core.host:execute("setStatus", "");
            loading_finished = true;
        end
    else
        for _, symbol in ipairs(items) do
            if cookie == symbol.LoadingId then
                symbol.Loading = true;
                return;
            elseif cookie == symbol.LoadedId then
                symbol.Loading = false;
                return;
            end
        end
    end
end
