-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68608

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ADR Percent Probability");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("adr_period", "ADR Period", "", 10);
    indicator.parameters:addInteger("loopback", "Loopback", "", 100);
    indicator.parameters:addInteger("level_1", "1. Level", "", 25);
    indicator.parameters:addInteger("level_2", "2. Level", "", 50);
    indicator.parameters:addInteger("level_3", "3. Level", "", 75);
    indicator.parameters:addInteger("level_4", "4. Level", "", 100);
    indicator.parameters:addInteger("level_5", "5. Level", "", 150);
    indicator.parameters:addColor("text_color", "Color", "", core.rgb(255, 0, 0));
end

local d1_source;
local loaded = false;
local adr;
local loopback;

local levels = {};
local other_levels = 0;
local dayoffset, weekoffset;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

    loopback = instance.parameters.loopback;

    d1_source = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), 0, 1, 2);

    local profile = core.indicators:findIndicator("AVERAGE RANGE");
    assert(profile ~= nil, "Please, download and install " .. "AVERAGE RANGE" .. ".LUA indicator");
    adr = core.indicators:create("AVERAGE RANGE", d1_source, instance.parameters.adr_period);
    for i = 1, 5 do
        local level = {};
        level.value = instance.parameters:getInteger("level_" .. i);
        levels[#levels + 1] = level;
    end
	
 

    instance:ownerDrawn(true);
end

function AddPercentage(change)
  -- for i, level in ipairs(levels) do
    
    for i= #levels , 0, -1 do
	       
	     level =levels[i];
         if level.value < change then
            level.count = level.count + 1;
            break;
			--return true;
        end
    end
    return false;
end

function Update(period, mode)
    if not loaded then
        return;
    end
    local change;
    adr:update(mode);
    if period == source:size() - 1 then
        for i, level in ipairs(levels) do
            level.count = 0;
        end
        other_levels = 0;
        for ii = adr.DATA:size() - 1, adr.DATA:size() - loopback, -1 do
            change = math.abs(adr.DATA[ii]) / source:pipSize();
           -- core.host:trace(tostring(adr.DATA[ii]));
            if not AddPercentage(change) then
                other_levels = other_levels + 1;
            end
        end
    end
end

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

local init = false;
local text_color;
local FONT_ID = 1;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        text_color = instance.parameters.text_color;
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(10), 0);
    end

    local title = "ADR Percentage";
    local title_w, title_h = context:measureText(FONT_ID, title, 0);
    CellsBuilder:Clear(context);
    for i, level in ipairs(levels) do
        CellsBuilder:Add(FONT_ID, tostring(level.value), text_color, 1, i, context.LEFT);
        if level.count ~= nil then
            local text = win32.formatNumber(level.count / loopback * 100.0, false, 0) .. "%";
            CellsBuilder:Add(FONT_ID, text, text_color, 2, i, context.LEFT);
        end
    end
    local text = win32.formatNumber(math.floor(other_levels / loopback * 100.0), false, 0) .. "%";
    CellsBuilder:Add(FONT_ID, "Other", text_color, 1, #levels + 1, context.LEFT);
    CellsBuilder:Add(FONT_ID, text, text_color, 2, #levels + 1, context.LEFT);

    local width = math.max(title_w, CellsBuilder:GetTotalWidth());
    context:drawText(FONT_ID, title, text_color, -1, context:right() - width, context:top(), context:right(), context:top() + title_h, 0);
    CellsBuilder:Draw(context:right() - width, context:top() + title_h * 1.2);
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if cookie == 1 then
        loaded = true;
         instance:updateFrom(0);
    elseif cookie == 2 then
        loaded = false;
    end
end