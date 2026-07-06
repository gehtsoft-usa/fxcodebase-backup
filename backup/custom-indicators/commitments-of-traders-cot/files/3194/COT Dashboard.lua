-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=1615&hilit=cot

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC |
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

local labels = {
    ["!090741"] = "CANADIAN DOLLAR",
    ["!092741"] = "SWISS FRANC",
    ["!095741"] = "MEXICAN PESO",
    ["!096742"] = "BRITISH POUND",
    ["!097741"] = "JAPANESE YEN",
    ["!098662"] = "U.S. DOLLAR INDEX",
    ["!099741"] = "EURO FX",
    ["!112741"] = "NEW ZEALAND DOLLAR",
    ["!232741"] = "AUSTRALIAN DOLLAR",
    ["!089741"] = "RUSSIAN RUBLE",
    ["!102741"] = "BRAZILIAN REAL - CHICAGO MERCANTILE EXCHANGE",
    ["!1170E1"] = "VIX FUTURES",   		
    ["!042601"] = "2-YEAR U.S. TREASURY NOTES",   
    ["!043602"] = "10-YEAR U.S. TREASURY NOTES",   
    ["!044601"] = "5-YEAR U.S. TREASURY NOTES",   
    ["!33874A"] = "E-MINI S&P 400 STOCK INDEX",   
    ["!23977A"] = "RUSSELL 2000 MINI INDEX FUTURE",   
    ["!240741"] = "NIKKEI STOCK AVERAGE - CHICAGO MERCANTILE EXCHANGE", 
    ["!209742"] = "NASDAQ-100 STOCK INDEX (MINI)",     
    ["!138741"] = "S&P 500 STOCK INDEX - CHICAGO MERCANTILE EXCHANGE",   
    ["!088691"] = "GOLD",
    ["!085692"] = "COPPER",   
    ["!084691"] = "SILVER",  
    ["!075651"] = "PALLADIUM",   
    ["!076651"] = "PLATINUM",
    ["!067411"] = "CRUDE OIL, LIGHT SWEET - ICE FUTURES EUROPE",
    ["!067651"] = "CRUDE OIL, LIGHT SWEET - NEW YORK MERCANTILE EXCHANGE",
    ["!06765T"] = "BRENT CRUDE OIL LAST DAY - NEW YORK MERCANTILE EXCHANGE",
}

-- Light dashboard template v.1.1

local Modules = {};

-- USER DEFINITIONS SECTION
local indi_name = "COT Dashboard";
local indi_version = "1";
local LAST_PEN = 6;

function CreateIndicators(source, k)
    local indicators = {};
    local profile = core.indicators:findIndicator("COT");
    assert(profile ~= nil, "Please, download and install " .. "COT" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indicatorParams:setString("instrument", k);
    indicators[1] = core.indicators:create("COT", source, indicatorParams);
    return indicators;
end

function CreateParameters()
end

function GetSignal(symbol, reverse)
    local signal = {};
    if symbol.Indicators[1].COT:size() > 0 then
        local Value = symbol.Indicators[1].COT[NOW];
        local Value1 = symbol.Indicators[1].COT[NOW - instance.parameters.periods_back];
        signal.Text = win32.formatNumber(Value, false, 0);
        signal.DiffText = win32.formatNumber(Value - Value1, false, 0);
    else
        signal.Text = "...";
    end
    return signal;
end
-- ENF OF USER DEFINITIONS SECTION

function Init()
    indicator:name(indi_name .. " v." .. indi_version);
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("Version", indi_version)

    CreateParameters();

    indicator.parameters:addInteger("periods_back", "Periods Back", "", 10);
    indicator.parameters:addGroup("Styling");
    indicator.parameters:addColor("text_color", "Text color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("background_color", "Background color", "", core.rgb(255, 255, 255));
    indicator.parameters:addInteger("load_quota", "Loading quota", "Prevents freeze. Use 0 to disable", 0);
    indicator.parameters:addDouble("cells_gap", "Gap coefficient", "", 1.2);
    indicator.parameters:addColor("grid_color", "Grid color", "", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("update_rate", "Update rate, seconds", "", 5);
end

local items = {};

local text_color, symbol_text_color;
local TIMER_ID = 1;

function PrepareInstrument()
    for k, v in pairs(labels) do
        local symbol = {};
        symbol.Label = v;
        symbol.SymbolIndex = #items;
        symbol.TimeframeIndex = 1;
        symbol.Indicators = CreateIndicators(instance.source, k);
        items[#items + 1] = symbol;
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
    
    text_color = instance.parameters.text_color;
    symbol_text_color = instance.parameters.symbol_text_color;
    timer_handle = core.host:execute("setTimer", TIMER_ID, instance.parameters.update_rate);
    core.host:execute("setStatus", "Loading");
    instance:ownerDrawn(true);
    CellsBuilder.GapCoeff = instance.parameters.cells_gap;
    PrepareInstrument();
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

    CellsBuilder:Add(FONT_TEXT, symbol.Signal.Text, text_color, 2, symbol.SymbolIndex + 1, context.CENTER, -1, GRID_PEN, true, true);
    CellsBuilder:Add(FONT_TEXT, symbol.Signal.DiffText, text_color, 3, symbol.SymbolIndex + 1, context.CENTER, -1, GRID_PEN, true, true);
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
        init = true;
    end
    local title_w, title_h = context:measureText(FONT_TEXT, indi_name, 0);
    CellsBuilder:Clear(context);
    CellsBuilder:Add(FONT_TEXT, "Symbol", text_color, 1, 1, context.CENTER, nil, GRID_PEN, true, false);
    CellsBuilder:Add(FONT_TEXT, "COT", text_color, 2, 1, context.CENTER, nil, GRID_PEN, true, false);
    CellsBuilder:Add(FONT_TEXT, "Diff", text_color, 3, 1, context.CENTER, nil, GRID_PEN, true, false);
    for i = 1, #items do
        CellsBuilder:Add(FONT_TEXT, items[i].Label, text_color, 1, i + 1, context.CENTER, nil, GRID_PEN, true, false);
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

function UpdateData()
    local offers = {};
    for _, symbol in ipairs(items) do
        if symbol.Indicators ~= nil then
            for i, indicator in ipairs(symbol.Indicators) do
                indicator:update(core.UpdateLast);
            end
            symbol.Signal = GetSignal(symbol);
        end
    end
end

local loading_finished = true;
function AsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == TIMER_ID then
        UpdateData();
        core.host:execute("setStatus", "");
    end
end
