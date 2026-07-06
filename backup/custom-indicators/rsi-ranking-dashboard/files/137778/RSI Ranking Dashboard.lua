-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70469

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

local timeframes_list = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
local timeframes_modes = {"disabled", "disabled", "disabled", "disabled", "display", "disabled", "disabled", "disabled", "disabled", "disabled", "display", "display", "display"};
local Modules = {};

-- USER DEFINITIONS SECTION
local indi_name = "RSI Ranking Dashboard";
local indi_version = "1";

function CreateIndicators(source)
    local indicators = {};
    indicators[#indicators + 1] = core.indicators:create("RSI", source, instance.parameters.rsi_period);
    return indicators;
end

function CreateParameters()
    indicator.parameters:addInteger("rsi_period", "RSI Period", "", 14);
end

function GetSignal(indicators, source)
    local signal = {};
    signal.Label = source:instrument();
    signal.Value = indicators[1].DATA[NOW];
    signal.IsUp = true;
    signal.ValueLabel = win32.formatNumber(signal.Value, false, 1);
    signal.IsHistoricalUp = indicators[1].DATA[NOW] > indicators[1].DATA[NOW - 1];
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

    indicator.parameters:addGroup("Instruments");
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
    indicator.parameters:addColor("symbol_text_color", "Instrument Text color", "", core.rgb(255, 255, 255));
    indicator.parameters:addColor("background_color", "Background color", "", core.rgb(255, 255, 255));
    indicator.parameters:addInteger("load_quota", "Loading quota", "Prevents freeze. Use 0 to disable", 0);
    indicator.parameters:addDouble("cells_gap", "Gap coefficient", "", 1.2);
    indicator.parameters:addColor("grid_color", "Grid color", "", core.rgb(128, 128, 128));
    indicator.parameters:addString("grid_mode", "Grid mode", "", "v")
    indicator.parameters:addStringAlternative("grid_mode", "Horizontal", "", "h")
    indicator.parameters:addStringAlternative("grid_mode", "Vertical", "", "v")
    signaler:Init(indicator.parameters);
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
    indicator.parameters:addColor("Color" .. id, "Color", "", core.colors().Green);
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

local text_color, symbol_text_color;
local TIMER_ID = 1;
local last_id = 1;

local dde_server, dde_topic;
function PrepareInstrument(instrument, color)
    local timeframe_index = 1;
    for ii = 1, #timeframes_list do
        use = instance.parameters:getString("Use" .. ii);
        if use ~= "disabled" then
            local symbol = {};
            symbol.Pair = instrument;
            symbol.BGColor = color;
            symbol.Point = core.host:findTable("offers"):find("Instrument", symbol.Pair).PointSize;
            symbol.TF = timeframes_list[ii];
            symbol.LoadingId = last_id + 1;
            symbol.LoadedId = last_id + 2;
            symbol.Loading = true;
            symbol.SymbolIndex = #instruments + 1;
            symbol.TimeframeIndex = timeframe_index;
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

    if instance.parameters.dde_export_values then
        if ddeserver_lua == nil then
            require("ddeserver_lua");
        end
        dde_server = ddeserver_lua.new(instance.parameters.dde_service);
        dde_topic = dde_server:addTopic(instance.parameters.dde_topic);
    end

    for i = 1, 20, 1 do
        if instance.parameters:getBoolean("use_pair" .. i) then
            PrepareInstrument(instance.parameters:getString("Pair" .. i), instance.parameters:getColor("Color" .. i));
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
local FONT_ARROWS = 6;
local BG_PEN = 3;
local BG_BRUSH = 4;
local GRID_PEN = 5;
local LAST_PEN = 6;

local grid_mode;

function DrawSignal(symbol, context, index)
    if symbol.Signal == nil then
        return;
    end
    local historicalColor = symbol.Signal.IsHistoricalUp and instance.parameters.up_color or instance.parameters.dn_color;
    local historicalSymbol = symbol.Signal.IsHistoricalUp and string.char(217) or string.char(218);
    local color = symbol.Signal.IsUp and instance.parameters.up_color or instance.parameters.dn_color;
    if grid_mode == "h" then
        CellsBuilder:Add(FONT_TEXT, symbol.Signal.Label, symbol_text_color, index + 1, (symbol.TimeframeIndex * 3) - 2, context.CENTER, symbol.BGBrush, GRID_PEN, true, true);
        CellsBuilder:Add(FONT_TEXT, symbol.Signal.ValueLabel .. "   ", color, index + 1, (symbol.TimeframeIndex * 3) - 1, context.CENTER, nil, GRID_PEN, true, true);
        CellsBuilder:Add(FONT_ARROWS, historicalSymbol, historicalColor, index + 1, (symbol.TimeframeIndex * 3) - 1, context.CENTER, nil, GRID_PEN, true, true);
        CellsBuilder:AddGap(index + 1, (symbol.TimeframeIndex * 3), 5, 5);
        return;
    end

    CellsBuilder:Add(FONT_TEXT, symbol.Signal.Label, symbol_text_color, symbol.TimeframeIndex * 2 - 1, index * 2, context.CENTER, symbol.BGBrush, GRID_PEN, true, true);
    CellsBuilder:Add(FONT_TEXT, symbol.Signal.ValueLabel .. "   ", color, symbol.TimeframeIndex * 2 - 1, index * 2 + 1, context.CENTER, nil, GRID_PEN, true, true);
    CellsBuilder:Add(FONT_ARROWS, historicalSymbol, historicalColor, symbol.TimeframeIndex * 2 - 1, index * 2 + 1, context.CENTER, nil, GRID_PEN, true, true);
end
local instrument_bg_brushes = {};
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
        grid_mode = instance.parameters.grid_mode;
        context:createPen(GRID_PEN, context.SOLID, 1, instance.parameters.grid_color);
        for i, symbol in ipairs(items) do
            if instrument_bg_brushes[symbol.SymbolIndex] == nil then
                instrument_bg_brushes[symbol.SymbolIndex] = LAST_PEN + i;
                context:createSolidBrush(instrument_bg_brushes[symbol.SymbolIndex], symbol.BGColor);
            end
            symbol.BGBrush = instrument_bg_brushes[symbol.SymbolIndex];
        end
        init = true;
    end
    local title_w, title_h = context:measureText(FONT_TEXT, indi_name, 0);
    CellsBuilder:Clear(context);
    for i = 1, #timeframes do
        if grid_mode == "h" then
            local cell = CellsBuilder:Add(FONT_TEXT, "   " .. timeframes[i] .. "   ", text_color, 1, i * 3 - 2, context.CENTER, nil, GRID_PEN, true, false);
            cell.RowSpan = 2;
            CellsBuilder:Add(FONT_TEXT, " ", text_color, 1, i * 3 - 1, context.CENTER, nil, GRID_PEN, false, true);
            CellsBuilder:AddGap(1, i * 3, 5, 5);
        else
            CellsBuilder:Add(FONT_TEXT, timeframes[i], text_color, i * 2 - 1, 1, context.CENTER, nil, GRID_PEN, true, true);
            CellsBuilder:AddGap(i * 2, 1, 5, 5);
        end
        local symbolsToDraw = {};
        for _, symbol in ipairs(items) do
            if symbol.TimeframeIndex == i then
                symbolsToDraw[#symbolsToDraw + 1] = symbol;
            end
        end
        table.sort(symbolsToDraw, function(left, right) 
            if left.Signal == nil then
                return false;
            end
            if right.Signal == nil then
                return true;
            end
            return left.Signal.Value > right.Signal.Value;
        end)
        for ii, symbol in ipairs(symbolsToDraw) do
            DrawSignal(symbol, context, ii);
        end
    end
    local width = math.max(title_w, CellsBuilder:GetTotalWidth());
    context:drawRectangle(BG_PEN, BG_BRUSH, context:right() - width, context:top(), context:right(), context:top() + title_h * 1.2 + CellsBuilder:GetTotalHeight());
    context:drawText(FONT_TEXT, indi_name, text_color, -1, context:right() - width, context:top(), context:right(), context:top() + title_h, 0);
    CellsBuilder:Draw(context:right() - width, context:top() + title_h * 1.2);
end

function Update(period, mode)
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(nil, nil, nil); end end
end

local last_checks = {};
local last_dates = {};

function GetRank(tf)
    local symbolsToDraw = {};
    for _, symbol in ipairs(items) do
        if symbol.TF == tf then
            symbolsToDraw[#symbolsToDraw + 1] = symbol;
        end
    end
    table.sort(symbolsToDraw, function(left, right) 
        if left.Signal == nil then
            return false;
        end
        if right.Signal == nil then
            return true;
        end
        return left.Signal.Value > right.Signal.Value;
    end)
    return symbolsToDraw[1].Pair .. " Rank 1 - " .. tf .. "\r\n" 
        .. symbolsToDraw[2].Pair .. " Rank 2 - " .. tf .. "\r\n"
        .. symbolsToDraw[3].Pair .. " Rank 3 - " .. tf
end

function UpdateData()
    for _, symbol in ipairs(items) do
        if symbol.Indicators ~= nil and not symbol.Loading then
            for i, indicator in ipairs(symbol.Indicators) do
                indicator:update(core.UpdateLast);
            end
            local signal = GetSignal(symbol.Indicators, symbol.Source);
            if symbol.Source ~= nil and symbol.Source:size() > 0 then
                if last_dates[symbol.TF] == nil or last_dates[symbol.TF] < symbol.Source:date(NOW) then
                    last_dates[symbol.TF] = symbol.Source:date(NOW);
                end
            end
            symbol.Signal = signal;
		else
            symbol.Signal = nil;
        end
    end
    for ii = 1, #timeframes_list do
        use = instance.parameters:getString("Use" .. ii);
        if use ~= "no" then
            if last_checks[timeframes_list[ii]] ~= last_dates[timeframes_list[ii]] then
                local rank = GetRank(timeframes_list[ii]);
                signaler:Signal(rank);
                last_checks[timeframes_list[ii]] = last_dates[timeframes_list[ii]];
            end
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

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.7";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};
signaler._commands = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and (self.last_req == nil or not self.last_req:loading()) then
        if #self._alerts > 0 then
            local data = self:ArrayToJSON(self._alerts);
            self._alerts = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        end
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(message, source)
    if source == nil then
        if instance.source ~= nil then
            source = instance.source;
        elseif instance.bid ~= nil then
            source = instance.bid;
        else
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
    end
end

function signaler:SendCommand(command)
    if self._external_executer_key == nil or core.host.Trading:getTradingProperty("isSimulation") or command == "" then
        return;
    end
    local command = 
    {
        Text = command
    };
    self._commands[#self._commands + 1] = command;
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end

    parameters:addGroup("  Telegram/Discord/Other platforms");
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");

    parameters:addGroup("  Trade coping");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
    end
    if instance.parameters.external_executer_key ~= "" and instance.parameters.use_external_executer then
        self._external_executer_key = instance.parameters.external_executer_key;
    end
    if self.external_executer_key ~= nil or self._advanced_alert_key ~= nil then
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);