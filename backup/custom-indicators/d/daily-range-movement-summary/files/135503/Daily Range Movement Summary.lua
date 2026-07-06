-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70109

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
    indicator:name("Daily Range Movement Summary");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("ADRPeriod", "ADR Period", "", 7);
    indicator.parameters:addInteger("ADMPeriod", "ADM Period", "", 7);
    indicator.parameters:addColor("font_color", "Font color", "", core.colors().Red);
    indicator.parameters:addInteger("x", "X", "", 50);
    indicator.parameters:addInteger("y", "Y", "", 50);
end

local source, ADRPeriod, ADMPeriod, tradingWeekOffset, tradingDayOffset, adr;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    ADRPeriod = instance.parameters.ADRPeriod;
    ADMPeriod = instance.parameters.ADMPeriod;
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");

    local profile = core.indicators:findIndicator("AVERAGE DAILY RANGE OSCILLATOR");
    assert(profile ~= nil, "Please, download and install " .. "AVERAGE DAILY RANGE OSCILLATOR" .. ".LUA indicator");
    adr = core.indicators:create("AVERAGE DAILY RANGE OSCILLATOR", source, "D1", ADRPeriod, 1)
    instance:ownerDrawn(true)
end

local adm;

-- Cells builder v.1.3
local CellsBuilder = {};
CellsBuilder.GapCoeff = 1.2;
function CellsBuilder:Clear(context)
    self.Columns = {};
    self.RowHeights = {};
    self.Context = context;
end
function CellsBuilder:Add(font, text, color, column, row, mode, backgound)
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
    local total_width = 0;
    for columnIndex, column in ipairs(self.Columns) do
        local total_height = 0;
        for i = 0, column.MaxRowIndex do
            local cell = column.Rows[i];
            if cell ~= nil then
                local background = -1;
                if cell.Background ~= nil then
                    background = cell.Background;
                end
                self.Context:drawText(cell.Font, cell.Text, 
                    cell.Color, background, 
                    x + total_width, 
                    y + total_height, 
                    x + total_width + column.MaxWidth, 
                    y + total_height + cell.Height,
                    cell.Mode);
            end
            if self.RowHeights[i] ~= nil then
                total_height = total_height + self.RowHeights[i] * self.GapCoeff;
            end
        end
        total_width = total_width + column.MaxWidth * self.GapCoeff;
    end
end

function Update(period, mode)
    adr:update(mode);
    adm = 0;
    local s, e = core.getcandle("D1", source:date(period), tradingDayOffset, tradingWeekOffset);
    local start_period = core.findDate(source, s - ADMPeriod, false);
    local end_period = core.findDate(source, e, false);
    for i = start_period, end_period do
        adm = adm + math.abs(source.open[i] - source.close[i]);
    end
    adm = adm / ADMPeriod;
end

local init = false;
local font = 1;
local font_color;
local x, y;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        font_color = instance.parameters.font_color;
        context:createFont(font, "Arial", 0, context:pointsToPixels(12), context.LEFT);
        x = instance.parameters.x;
        y = instance.parameters.y;
        init = true;
    end
    CellsBuilder:Clear(context);
    CellsBuilder:Add(font, "ADR: ", font_color, 1, 1, context.LEFT);
    if adr.DATA:size() > 0 then
        CellsBuilder:Add(font, win32.formatNumber(adr.DATA[NOW], false, 1), font_color, 2, 1, context.LEFT);
    end
    CellsBuilder:Add(font, "ADM: ", font_color, 1, 2, context.LEFT);
    if adm ~= nil then
        CellsBuilder:Add(font, win32.formatNumber(adm, false, 1), font_color, 2, 2, context.LEFT);
    end
    CellsBuilder:Draw(context:left() + x, context:top() + y);
end