-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71252

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Pairs Percent Change");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addString("StartTime", "Start Time", "", "00:00:00");
    indicator.parameters:addBoolean("show_AUD", "Show AUD", "", true);
    indicator.parameters:addBoolean("show_CAD", "Show CAD", "", true);
    indicator.parameters:addBoolean("show_CHF", "Show CHF", "", true);
    indicator.parameters:addBoolean("show_EUR", "Show EUR", "", true);
    indicator.parameters:addBoolean("show_GBP", "Show GBP", "", true);
    indicator.parameters:addBoolean("show_JPY", "Show JPY", "", true);
    indicator.parameters:addBoolean("show_NZD", "Show NZD", "", true);
    indicator.parameters:addBoolean("show_USD", "Show USD", "", true);
    indicator.parameters:addBoolean("show_C07", "Show C07", "", true);
    indicator.parameters:addBoolean("show_All", "Show All", "", true);
    
    indicator.parameters:addColor("color", "Main color", "", core.colors().Red);
    indicator.parameters:addColor("GRID_color", "Grid Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("GRID_width", "Grid Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("GRID_style", "Grid Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("GRID_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("x", "X", "", 50);
    indicator.parameters:addInteger("y", "Y", "", 50);
end

-- Sources v1.3
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf, isBid, instrument)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

    if tf == nil then
        tf = source:barSize()
    end
	if isBid == nil then
		isBid = source:isBid()
    end
    if instrument == nil then
        instrument = source:instrument();
    end
    
	self.items[id] = core.host:execute("getSyncHistory", instrument, tf, isBid, 100, ids.loaded_id, ids.loading_id)
	return self.items[id];
end
function sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
	for index, ids in pairs(self.ids) do
		if ids.loaded_id == cookie then
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
			ids.loaded = false
			self.allLoaded = false
			return false
		end
	end
	return false
end
function sources:IsAllLoaded()
	if self.allLoaded == nil then
		for index, ids in pairs(self.ids) do
			if not ids.loaded then
				self.allLoaded = false
				return false
			end
		end
		self.allLoaded = true
	end
	return self.allLoaded
end
function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end
local source;
local streams = {};
local items = {};

function Create(ccy, symbols)
    local item = {};
    item.Currency = ccy;
    item.Symbols = {};
    for i, symbol in ipairs(symbols) do
        Offer = core.host:findTable("offers"):find("Instrument", symbol)
        if Offer ~= nil then
            if streams[symbol] == nil then
                streams[symbol] = sources:Request(#streams + 1, source, source:barSize(), source:isBid(), symbol);
            end
            item.Symbols[#item.Symbols + 1] = symbol;
        end
    end
    return item;
end

local shift_seconds;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    shift_seconds, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    if instance.parameters:getBoolean("show_AUD") then
        items[#items + 1] = Create("AUD", {"AUD/CAD","AUD/CHF","EUR/AUD","GBP/AUD","AUD/JPY","AUD/NZD","AUD/USD"});
    end
    if instance.parameters:getBoolean("show_CAD") then
        items[#items + 1] = Create("CAD", {"CAD/JPY","CAD/CHF","AUD/CAD","NZD/CAD","USD/CAD","GBP/CAD","EUR/CAD"});
    end
    if instance.parameters:getBoolean("show_CHF") then
        items[#items + 1] = Create("CHF", {"AUD/CHF","CAD/CHF","GBP/CHF","NZD/CHF","USD/CHF","EUR/CHF","CHF/JPY"});
    end
    if instance.parameters:getBoolean("show_EUR") then
        items[#items + 1] = Create("EUR", {"EUR/AUD","EUR/NZD","EUR/CAD","EUR/USD","EUR/GBP","EUR/CHF","EUR/JPY"});
    end
    if instance.parameters:getBoolean("show_GBP") then
        items[#items + 1] = Create("GBP", {"EUR/GBP","GBP/AUD","GBP/CAD","GBP/USD","GBP/CHF","GBP/JPY","GBP/NZD"});
    end
    if instance.parameters:getBoolean("show_JPY") then
        items[#items + 1] = Create("JPY", {"AUD/JPY","GBP/JPY","CAD/JPY","USD/JPY","NZD/JPY","CHF/JPY","EUR/JPY"});
    end
    if instance.parameters:getBoolean("show_NZD") then
        items[#items + 1] = Create("NZD", {"AUD/NZD","EUR/NZD","GBP/NZD","NZD/CAD","NZD/USD","NZD/CHF","NZD/JPY"});
    end
    if instance.parameters:getBoolean("show_USD") then
        items[#items + 1] = Create("USD", {"USD/CHF","USD/CAD","USD/JPY","AUD/USD","NZD/USD","GBP/USD","EUR/USD"});
    end
    if instance.parameters:getBoolean("show_C07") then
        items[#items + 1] = Create("C07", {"USD/CHF","NZD/USD","GBP/USD","EUR/USD","USD/JPY","AUD/USD","USD/CAD"});
    end
    if instance.parameters:getBoolean("show_All") then
        items[#items + 1] = Create("All", {"GBP/NZD","EUR/NZD","GBP/AUD","GBP/CAD","GBP/JPY","GBP/CHF","CAD/JPY","EUR/CAD","EUR/AUD",
            "USD/CHF","GBP/USD","EUR/JPY","NZD/JPY","AUD/CHF","AUD/JPY","USD/JPY","EUR/USD","NZD/CHF",
            "CAD/CHF","AUD/NZD","NZD/USD","CHF/JPY","AUD/CAD","USD/CAD","NZD/CAD","AUD/USD","EUR/CHF","EUR/GBP"});
    end
    
    instance:ownerDrawn(true);
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
end

function Change(symbol)
    if streams[symbol] == nil or streams[symbol]:size() == 0 then
        return 0;
    end
    local shift = GetTimeShift(streams[symbol]);
    if shift < 0 then
        return 0;
    end
    local open = streams[symbol].open[shift];
    local close = streams[symbol].close[shift];
    return (close - open) / streams[symbol]:pipSize();
end

function Percent_Change(symbol)
    if streams[symbol] == nil or streams[symbol]:size() == 0 then
        return 0;
    end
    local shift = GetTimeShift(streams[symbol]);
    if shift < 0 then
        return 0;
    end
    local change = Change(symbol);
    if change == 0 then
        return 0;
    end
    local open = streams[symbol].open[shift];
    return change / open * 100 * streams[symbol]:pipSize();
end

function GetTimeShift(stream)
    local currentTime = stream:date(NOW);
    local ref_time = math.floor(currentTime) + shift_seconds;
    if (ref_time >= currentTime) then
        ref_time = ref_time - 1;
    end
    return core.findDate(stream, ref_time, false);
end

function Update(period, mode)
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

function Compare(left, right)
    return left.Value < right.Value;
end

local init = false;
local x, y, color;
local FONT_ID = 1;
local GRID_pen = 2;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        x = instance.parameters.x;
        y = instance.parameters.y;
        color = instance.parameters.color;
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(10), context.LEFT);
        context:createPen(GRID_pen, context:convertPenStyle(instance.parameters.GRID_style), instance.parameters.GRID_width, instance.parameters.GRID_color);
        init = true;
    end
    CellsBuilder:Clear(context);
    for i, item in ipairs(items) do
        local shift = (i - 1) * 3;
        CellsBuilder:Add(FONT_ID, item.Currency, color, 1 + shift, 1, context.CENTER, -1, GRID_pen, true, true);
        CellsBuilder:Add(FONT_ID, "Change", color, 2 + shift, 1, context.CENTER, -1, GRID_pen, true, true);
        CellsBuilder:Add(FONT_ID, "% Change", color, 3 + shift, 1, context.CENTER, -1, GRID_pen, true, true);
        local sorted = {};
        for ii, symbol in ipairs(item.Symbols) do
            local val = {};
            val.Symbol = symbol;
            val.Value = Percent_Change(symbol);
            sorted[#sorted + 1] = val;
        end
        table.sort(sorted, Compare);
        for ii, sortedItem in ipairs(sorted) do
            local change = Change(sortedItem.Symbol);
            CellsBuilder:Add(FONT_ID, sortedItem.Symbol, color, 1 + shift, 1 + ii, context.CENTER, -1, GRID_pen, true, true);
            CellsBuilder:Add(FONT_ID, win32.formatNumber(change, false, 1), color, 2 + shift, 1 + ii, context.CENTER, -1, GRID_pen, true, true);
            CellsBuilder:Add(FONT_ID, win32.formatNumber(sortedItem.Value, false, 2), color, 3 + shift, 1 + ii, context.CENTER, -1, GRID_pen, true, true);
        end
    end
    CellsBuilder:Draw(x, y);
end