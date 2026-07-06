-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69143

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

-- Dashboard template v.1.6

local timeframes_list = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
local timeframes_modes = {"disabled", "disabled", "disabled", "disabled", "display", "disabled", "disabled", "disabled", "disabled", "disabled", "display", "display", "display"};
local Modules = {};

-- USER DEFINITIONS SECTION
local indi_name = "Bollinger Band / Chinkou Span Cross Dashboard";
local indi_version = "1";
local kijun;

function CreateIndicators(source)
    local indicators = {};

    indicators[#indicators + 1] = core.indicators:create("BB", source, instance.parameters.N, instance.parameters.Dev)
    kijun = instance.parameters.kijun;

    return indicators;
end

function CreateParameters()
    indicator.parameters:addGroup("BB Calculation");
    indicator.parameters:addInteger("N", "Period","Period", 20, 1, 10000);
	indicator.parameters:addDouble("Dev","Number of standard deviations","The number of standard deviations.", 2.0, 0.0001, 1000.0);
	
	indicator.parameters:addGroup("Chinkou Span Calculation");
	indicator.parameters:addInteger("kijun", "Kijun-sen period","Kijun-sen period", 26, 1, 10000);
end

function GetPatternName(signal)
    if signal == 1 then
        return "Top B";
    elseif signal == -1 then
        return "Top S";
    elseif signal == 2 then
        return "Bottom B";
    elseif signal == -2 then
        return "Bottom S";
    elseif signal == 3 then
        return "Middle B";
    elseif signal == -3 then
        return "Middle S";
    end

    return "-";
end

function GetLastSignal(indi, source)
    if core.crossesOver(source.close, indi[1].TL, indi[1].TL:size() - 1 - kijun) then
        return 1;
    end
    if core.crossesUnder(source.close, indi[1].TL, indi[1].TL:size() - 1 - kijun) then
        return -1;
    end
    if core.crossesOver(source.close, indi[1].BL, indi[1].TL:size() - 1 - kijun) then
        return 2;
    end
    if core.crossesUnder(source.close, indi[1].BL, indi[1].TL:size() - 1 - kijun) then
        return -2;
    end
    if core.crossesOver(source.close, indi[1].AL, indi[1].TL:size() - 1 - kijun) then
        return 3;
    end
    if core.crossesUnder(source.close, indi[1].AL, indi[1].TL:size() - 1 - kijun) then
        return -3;
    end
    return 0;
end
-- ENF OF USER DEFINITIONS SECTION

function Init()
    indicator:name(indi_name .. " v." .. indi_version);
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("Version", indi_version)

    CreateParameters();

    indicator.parameters:addGroup("Instruments");
    indicator.parameters:addBoolean("all_instruments", "All instruments", "", false);
    for i = 1, 20, 1 do
        Add(i);
    end
    
    indicator.parameters:addGroup("Time Frame Selector");
    for i = 1, #timeframes_list do
        AddTimeFrame(i, timeframes_list[i], timeframes_modes[i]);
    end

    indicator.parameters:addGroup("Styling");
    indicator.parameters:addColor("up_color", "Up color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("dn_color", "Down color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("text_color", "Text color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("background_color", "Background color", "", core.rgb(255, 255, 255));
    indicator.parameters:addColor("signal_background_color", "Active signal background color", "", core.rgb(250, 250, 210));
    indicator.parameters:addInteger("load_quota", "Loading quota", "Prevents freeze. Use 0 to disable", 0);
    indicator.parameters:addDouble("cells_gap", "Gap coefficient", "", 1.2);
    indicator.parameters:addColor("grid_color", "Grid color", "", core.rgb(128, 128, 128));
    indicator.parameters:addBoolean("draw_grid", "Draw grid", "", false);
    indicator.parameters:addString("grid_mode", "Grid mode", "", "v")
    indicator.parameters:addStringAlternative("grid_mode", "Horizontal", "", "h")
    indicator.parameters:addStringAlternative("grid_mode", "Vertical", "", "v")
end

function Add(id)
    local Init = {"EUR/USD", "USD/JPY", "GBP/USD", "USD/CHF", "EUR/CHF"
                , "AUD/USD", "USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
                , "GBP/JPY", "CHF/JPY", "GBP/CHF", "EUR/AUD", "EUR/CAD"
                , "AUD/CAD", "AUD/JPY", "CAD/JPY", "NZD/JPY", "GBP/CAD"
            };
    indicator.parameters:addBoolean("use_pair" .. id, "Use This Slot", "", id <= 5);
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
end

function AddTimeFrame(id, FRAME, DEFAULT)
    local paramId = "Use" .. id;
    indicator.parameters:addString(paramId, FRAME, "", DEFAULT); 
    indicator.parameters:addStringAlternative(paramId, "Do not use", "", "disabled");
    indicator.parameters:addStringAlternative(paramId, "Display only", "", "display");
end

local items = {};
local instruments = {};
local timeframes = {};

local text_color;
local TIMER_ID = 1;
local last_id = 1;

local dde_server, dde_topic;
function PrepareInstrument(instrument)
    local timeframe_index = 1;
    for ii = 1, #timeframes_list do
        use = instance.parameters:getString("Use" .. ii);
        if use ~= "no" then
            local symbol = {};
            symbol.Mode = use;
            symbol.Pair = instrument;
            symbol.Point = core.host:findTable("offers"):find("Instrument", symbol.Pair).PointSize;
            symbol.TF = timeframes_list[ii];
            symbol.LoadingId = last_id + 1;
            symbol.LoadedId = last_id + 2;
            symbol.Loading = true;
            symbol.SymbolIndex = #instruments + 1;
            if use == "both" or use == "display" then
                symbol.TimeframeIndex = timeframe_index;
            end
            function symbol:DoLoad()
                self.Source = core.host:execute("getSyncHistory", self.Pair, self.TF, instance.source:isBid(), 300, self.LoadedId, self.LoadingId);
                self.Indicators = CreateIndicators(self.Source);
            end
            if instance.parameters.dde_export_values then
                symbol.dde = dde_server:addValue(dde_topic, string.gsub(instrument, "/", "") .. "_" .. symbol.TF);
            end
            last_id = last_id + 2;
            items[#items + 1] = symbol;
            if use == "both" or use == "display" then
                timeframes[timeframe_index] = timeframes_list[ii];
                timeframe_index = timeframe_index + 1;
            end
        end
    end
    instruments[#instruments + 1] = instrument;
end

local timer_handle;
-- Cells builder v.1.3
local CellsBuilder = {};
CellsBuilder.GapCoeff = 1.2;
function CellsBuilder:Clear(context)
    self.Columns = {};
    self.RowHeights = {};
    self.Context = context;
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
                local background = -1;
                if cell.Background ~= nil then
                    background = cell.Background;
                end
                local x_start = x + total_width;
                local y_start = y + total_height;
                local x_end = x + total_width + column.MaxWidth * self.GapCoeff;
                local y_end = y + total_height + self.RowHeights[i] * self.GapCoeff;
                self.Context:drawText(cell.Font, cell.Text, 
                    cell.Color, background, 
                    x_start + column.MaxWidth * (self.GapCoeff - 1) / 2, 
                    y_start + self.RowHeights[i] * (self.GapCoeff - 1) / 2, 
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

function Prepare(nameOnly)
    instance:name(indi_name);
    if nameOnly then
        return;
    end
    text_color = instance.parameters.text_color;

    if instance.parameters.dde_export_values then
        if ddeserver_lua == nil then
            require("ddeserver_lua");
        end
        dde_server = ddeserver_lua.new(instance.parameters.dde_service);
        dde_topic = dde_server:addTopic(instance.parameters.dde_topic);
    end

    if instance.parameters.all_instruments then
        local enum = core.host:findTable("offers"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            PrepareInstrument(row.Instrument);
            row = enum:next();
        end
    else
        for i = 1, 20, 1 do
            if instance.parameters:getBoolean("use_pair" .. i) then
                PrepareInstrument(instance.parameters:getString("Pair" .. i));
            end
        end
    end
    timer_handle = core.host:execute("setTimer", TIMER_ID, 1);
    core.host:execute("setStatus", "Loading");
    instance:ownerDrawn(true);
    CellsBuilder.GapCoeff = instance.parameters.cells_gap;
end

local init = false;
local FONT = 1;
local FONT_TEXT = 2;
local BG_PEN = 3;
local BG_BRUSH = 4;
local GRID_PEN = 5;

local draw_grid, grid_mode;

function GetTableIndex(symbol)
    if grid_mode == "h" then
        return (symbol.TimeframeIndex + 1), symbol.SymbolIndex + 1;
    end

    return (symbol.SymbolIndex + 1), symbol.TimeframeIndex + 1;
end

function DrawSignal(symbol, context)
    if (symbol.Mode ~= "both" and symbol.Mode ~= "display") or symbol.Text == nil then
        return;
    end
    local row, column = GetTableIndex(symbol);
    if symbol.Signal == 0 or symbol.Signal == nil then
        CellsBuilder:Add(FONT_TEXT, symbol.Text, text_color, column, row, context.CENTER, backgound, GRID_PEN, true, false);
        return;
    end

    local backgound = -1;
    local color = symbol.Signal > 0 and instance.parameters.up_color or instance.parameters.dn_color;
    CellsBuilder:Add(FONT_TEXT, symbol.Text, color, column, row, context.CENTER, backgound, GRID_PEN, true, false);
end
function Draw(stage, context) 
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(FONT, "Wingdings", 0, context:pointsToPixels(8), 0)
        context:createFont(FONT_TEXT, "Arial", 0, context:pointsToPixels(8), 0)
        context:createPen(BG_PEN, context.SOLID, 1, instance.parameters.background_color);
        context:createSolidBrush(BG_BRUSH, instance.parameters.background_color);
        draw_grid = instance.parameters.draw_grid;
        grid_mode = instance.parameters.grid_mode;
        if draw_grid then
            context:createPen(GRID_PEN, context.SOLID, 1, instance.parameters.grid_color);
        else
            GRID_PEN = nil;
        end
        init = true;
    end
    local title_w, title_h = context:measureText(FONT_TEXT, indi_name, 0);
    CellsBuilder:Clear(context);
    for i = 1, #timeframes do
        if grid_mode == "h" then
            CellsBuilder:Add(FONT_TEXT, timeframes[i], text_color, 1, (i + 1), context.LEFT);
        else
            CellsBuilder:Add(FONT_TEXT, timeframes[i], text_color, i + 1, 1, context.LEFT);
        end
    end
    for i = 1, #instruments do
        if grid_mode == "h" then
            CellsBuilder:Add(FONT_TEXT, instruments[i], text_color, i + 1, 1, context.CENTER);
        else
            CellsBuilder:Add(FONT_TEXT, instruments[i], text_color, 1, (i + 1), context.CENTER);
        end
    end
    for _, symbol in ipairs(items) do
        DrawSignal(symbol, context);
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
    for _, symbol in ipairs(items) do
        if symbol.Indicators ~= nil and not symbol.Loading then
            for i, indicator in ipairs(symbol.Indicators) do
                indicator:update(core.UpdateLast);
            end
            local signal = GetLastSignal(symbol.Indicators, symbol.Source);
            symbol.Signal = signal;
            if signal == 0 then
                symbol.Text = "-";
            else
                symbol.Text = GetPatternName(symbol.Signal);
            end
		else
            symbol.Text = "...";
        end
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
