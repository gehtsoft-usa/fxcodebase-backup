-- More information about this indicator can be found at:
-- http://fxcodebase.com

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

-- Dashboard template v.1.1

local timeframes_list = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
local Modules = {};

-- USER DEFINITIONS SECTION
local indi_name = "Volatility";
local indi_version = "3";

function CreateParameters()
    indicator.parameters:addInteger("periods", "Periods", "", 10);
    indicator.parameters:addString("mode", "Mode", "", "pips")
    indicator.parameters:addStringAlternative("mode", "Pips", "", "pips");
    indicator.parameters:addStringAlternative("mode", "% of daily", "", "daily");
end

-- ENF OF USER DEFINITIONS SECTION

function Init()
    indicator:name(indi_name .. " v." .. indi_version);
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("Version", indi_version)

    CreateParameters();

    indicator.parameters:addGroup("Time Frame Selector");
    for i = 1, #timeframes_list do
        AddTimeFrame(i, timeframes_list[i], "show");
    end

    indicator.parameters:addColor("text_color", "Text color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("background_color", "Background color", "", core.rgb(255, 255, 255));
    indicator.parameters:addColor("bar_color", "Bar color", "", core.rgb(128, 128, 255));
    indicator.parameters:addColor("current_bar_color", "Current bar color", "", core.rgb(255, 128, 128));
    signaler:Init(indicator.parameters);
end

function AddTimeFrame(id, FRAME, DEFAULT)
    indicator.parameters:addString("Use" .. id, "Show " .. FRAME, "", DEFAULT); 
    indicator.parameters:addStringAlternative("Use" .. id, "Do not show", "", "-")
    indicator.parameters:addStringAlternative("Use" .. id, "Show", "", "show")
    indicator.parameters:addStringAlternative("Use" .. id, "Show on top", "", "top")
end

local symbols = {};
local instruments = {};
local timeframes = {};

local text_color;
local TIMER_ID = 1;
local last_id = 1;
local D1Source, W1Source;

function FindSource(symbol, timeframe)
    for _, item in ipairs(symbols) do
        if item.Pair == symbol and item.TF == timeframe then
            return item;
        end
    end
    return nil;
end

function CreateSource(instrument, timeframe, timeframe_index)
    local symbol = {};
    symbol.Pair = instrument;
    symbol.Point = core.host:findTable("offers"):find("Instrument", symbol.Pair).PointSize;
    symbol.TF = timeframe;
    symbol.LoadingId = last_id + 1;
    symbol.LoadedId = last_id + 2;
    symbol.Loading = true;
    symbol.SymbolIndex = #instruments + 1;
    symbol.TimeframeIndex = timeframe_index;
    function symbol:DoLoad()
        self.Source = core.host:execute("getSyncHistory", self.Pair, self.TF, instance.source:isBid(), 300, self.LoadedId, self.LoadingId);
        self.D1Source = D1Source;
    end
    last_id = last_id + 2;
    return symbol;
end

function PrepareInstrument(instrument)
    for i, tf in ipairs(timeframes) do
        local symbol = FindSource(instrument, tf);
        if symbol == nil then
            symbol = CreateSource(instrument, tf, i);
            symbols[#symbols + 1] = symbol;
        end
    end
    instruments[#instruments + 1] = instrument;
end

local source;
local timer_handle;

function Prepare(nameOnly)
    signaler:Prepare(nameOnly);
    instance:name(indi_name);
    if nameOnly then
        return;
    end
    source = instance.source;
    text_color = instance.parameters.text_color;
    D1Source = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), 300, last_id + 1, last_id + 2);
    last_id = last_id + 2;
    W1Source = core.host:execute("getSyncHistory", source:instrument(), "W1", source:isBid(), 300, last_id + 1, last_id + 2);
    last_id = last_id + 2;

    for ii = 1, #timeframes_list do
        use = instance.parameters:getString("Use" .. ii);
        if use == "top" then
            timeframes[#timeframes + 1] = timeframes_list[ii];
        end
    end
    for ii = 1, #timeframes_list do
        use = instance.parameters:getString("Use" .. ii);
        if use == "show" then
            timeframes[#timeframes + 1] = timeframes_list[ii];
        end
    end
    PrepareInstrument(source:instrument());
    timer_handle = core.host:execute("setTimer", TIMER_ID, 1);
    core.host:execute("setStatus", "Loading");
    instance:ownerDrawn(true);
    instance:drawOnMainChart(true)
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

local CellsBuilder2 = {};
CellsBuilder2.GapCoeff = 1.2;
function CellsBuilder2:Clear(context)
    self.Columns = {};
    self.RowHeights = {};
    self.Context = context;
end
function CellsBuilder2:Add(font, text, color, column, row, mode, backgound)
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
function CellsBuilder2:GetTotalWidth()
    local width = 0;
    for columnIndex, column in ipairs(self.Columns) do
        width = width + column.MaxWidth * self.GapCoeff;
    end
    return width;
end
function CellsBuilder2:GetTotalHeight()
    local height = 0;
    for i = 0, self.Columns[1].MaxRowIndex do
        if self.RowHeights[i] ~= nil then
            height = height + self.RowHeights[i] * self.GapCoeff;
        end
    end
    return height;
end
function CellsBuilder2:Draw(x, y)
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

function FormatTime(time)
    local diff = core.host:execute("getServerTime") - time;
    if (diff > 1) then
        return math.floor(diff) .. " d.";
    end
    local diff_date = core.dateToTable(diff);
    if (diff_date.hour > 0) then
        return diff_date.hour .. " h.";
    end
    if (diff_date.min > 0) then
        return diff_date.min .. " min.";
    end
    return "now";
end

local init_main = false;
local init = false;
local FONT = 1;
local FONT_TEXT = 2;
local BG_PEN = 3;
local BG_BRUSH = 4;
local BAR_PEN = 5;
local BAR_BRUSH = 6;
local CURRENT_BAR_PEN = 7;
local CURRENT_BAR_BRUSH = 8;

function DrawMainChart(stage, context) 
    if not init then
        context:createFont(FONT_TEXT, "Arial", 0, context:pointsToPixels(8), 0)
        context:createPen(BG_PEN, context.SOLID, 1, instance.parameters.background_color);
        context:createSolidBrush(BG_BRUSH, instance.parameters.background_color);
        init = true;
    end
    CellsBuilder:Clear(context);
    local title_w, title_h = context:measureText(FONT_TEXT, indi_name, 0);
    for i = 1, #timeframes do
        CellsBuilder:Add(FONT_TEXT, timeframes[i], text_color, 1, i + 1, context.LEFT);
    end
    for i = 1, #instruments do
        CellsBuilder:Add(FONT_TEXT, instruments[i], text_color, i + 1, 1, context.CENTER);
    end
    for _, symbol in ipairs(symbols) do
        if not symbol.Loading and symbol.Source:size() > instance.parameters.periods then
            local row = symbol.TimeframeIndex + 1;
            local column = symbol.SymbolIndex + 1;
            local min, max = mathex.minmax(symbol.Source, symbol.Source:size() - 1 - instance.parameters.periods, symbol.Source:size() - 1);
            local dist = (max - min) / symbol.Source:pipSize();
            if instance.parameters.mode == "pips" then
                CellsBuilder:Add(FONT_TEXT, win32.formatNumber(dist, false, 1), text_color, column, row, context.CENTER);
            elseif symbol.D1Source:size() > 0 then
                local dailyRange = (symbol.D1Source.high[NOW] - symbol.D1Source.low[NOW]) / symbol.Source:pipSize();
                CellsBuilder:Add(FONT_TEXT, win32.formatNumber(dist / dailyRange * 100, false, 0) .. "%", text_color, column, row, context.CENTER);
            end
        end
    end
    local width = math.max(title_w, CellsBuilder:GetTotalWidth());
    context:drawRectangle(BG_PEN, BG_BRUSH, context:right() - width, context:top(), context:right(), context:top() + title_h * 1.2 + CellsBuilder:GetTotalHeight());
    context:drawText(FONT_TEXT, indi_name, text_color, -1, context:right() - width, context:top(), context:right(), context:top() + title_h, 0);
    CellsBuilder:Draw(context:right() - width, context:top() + title_h * 1.2);
end

function Draw(stage, context) 
    if stage == 102 then
        DrawMainChart(stage, context);
    elseif stage == 2 then
        if not init_main then
            context:createFont(FONT_TEXT, "Arial", 0, context:pointsToPixels(8), 0)
            context:createPen(BAR_PEN, context.SOLID, 1, instance.parameters.bar_color);
            context:createSolidBrush(BAR_BRUSH, instance.parameters.bar_color);
            context:createPen(CURRENT_BAR_PEN, context.SOLID, 1, instance.parameters.current_bar_color);
            context:createSolidBrush(CURRENT_BAR_BRUSH, instance.parameters.current_bar_color);
            init_main = true;
        end
        CellsBuilder2:Clear(context);
        CellsBuilder2:Add(FONT_TEXT, "High", text_color, 2, 1, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "Date", text_color, 3, 1, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "Present", text_color, 4, 1, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "Low", text_color, 5, 1, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "Date", text_color, 6, 1, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "Present", text_color, 7, 1, context.LEFT);
        
        CellsBuilder2:Add(FONT_TEXT, "Daily", text_color, 1, 2, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "Weekly", text_color, 1, 3, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "1M", text_color, 1, 4, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "3M", text_color, 1, 5, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "6M", text_color, 1, 6, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "1Y", text_color, 1, 7, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "3Y", text_color, 1, 8, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "5Y", text_color, 1, 9, context.LEFT);
        CellsBuilder2:Add(FONT_TEXT, "10Y", text_color, 1, 10, context.LEFT);
        local table_width = CellsBuilder2:GetTotalWidth();
        CellsBuilder2:Draw(context:right() - table_width, context:top());

        DrawDaysInMonth(context, table_width);
        DrawDaysInWeek(context, table_width);
    end
end

function DrawDaysInWeek(context, table_width)
    if D1Source:size() == 0 then
        return;
    end
    local graph_width = context:right() - context:left() - table_width;
    local graph_center = context:left() + graph_width / 2;
    local total_height = context:bottom() - context:top();

    local graph_end = graph_width
    local bar_width = (graph_width - 4) / 14;
    local ranges = {};
    local max = 0;
    for i = 0, 6 do
        local range = (D1Source.high[NOW - i] - D1Source.low[NOW - i]) / D1Source:pipSize();
        ranges[i + 1] = range;
        if max < range then
            max = range;
        end
    end
    local x1 = graph_end - bar_width + 1;
    local x2 = graph_end - 1;
    context:drawRectangle(CURRENT_BAR_PEN, CURRENT_BAR_BRUSH, 
        x1, context:bottom(), x2, context:bottom() - total_height * (ranges[1] / max));
    local date = core.dateToTable(D1Source:date(NOW));
    local w, h = context:measureText(FONT_TEXT, date.day, context.CENTER);
    context:drawText(FONT_TEXT, date.day, text_color, -1, x1, context:bottom() - h, x2, context:bottom(), context.CENTER);
    
    for i = 1, 6 do
        local x1 = graph_end - (i + 1) * bar_width + 1;
        local x2 = graph_end - i * bar_width - 1;
        context:drawRectangle(BAR_PEN, BAR_BRUSH, 
            x1, context:bottom(), x2, context:bottom() - total_height * (ranges[i + 1] / max));
            
        local date = core.dateToTable(D1Source:date(NOW - i));
        local w, h = context:measureText(FONT_TEXT, date.day, context.CENTER);
        context:drawText(FONT_TEXT, date.day, text_color, -1, x1, context:bottom() - h, x2, context:bottom(), context.CENTER);
    end
end

function DrawDaysInMonth(context, table_width)
    if D1Source:size() == 0 then
        return;
    end
    local graph_width = context:right() - context:left() - table_width;
    local graph_center = context:left() + graph_width / 2;
    local total_height = context:bottom() - context:top();

    local graph_end = graph_center - 2
    local bar_width = (graph_width - 4) / 62;
    local ranges = {};
    local max = 0;
    for i = 0, 30 do
        local range = (D1Source.high[NOW - i] - D1Source.low[NOW - i]) / D1Source:pipSize();
        ranges[i + 1] = range;
        if max < range then
            max = range;
        end
    end
    local x1 = graph_end - bar_width + 1;
    local x2 = graph_end - 1;
    context:drawRectangle(CURRENT_BAR_PEN, CURRENT_BAR_BRUSH, 
        x1, context:bottom(), x2, context:bottom() - total_height * (ranges[1] / max));
    local date = core.dateToTable(D1Source:date(NOW));
    local w, h = context:measureText(FONT_TEXT, date.day, context.CENTER);
    context:drawText(FONT_TEXT, date.day, text_color, -1, x1, context:bottom() - h, x2, context:bottom(), context.CENTER);
    
    for i = 1, 30 do
        local x1 = graph_end - (i + 1) * bar_width + 1;
        local x2 = graph_end - i * bar_width - 1;
        context:drawRectangle(BAR_PEN, BAR_BRUSH, 
            x1, context:bottom(), x2, context:bottom() - total_height * (ranges[i + 1] / max));
            
        local date = core.dateToTable(D1Source:date(NOW - i));
        local w, h = context:measureText(FONT_TEXT, date.day, context.CENTER);
        context:drawText(FONT_TEXT, date.day, text_color, -1, x1, context:bottom() - h, x2, context:bottom(), context.CENTER);
    end
end

function Update(period, mode)
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(nil, nil, nil); end end
    for _, symbol in ipairs(symbols) do
        if symbol.Indicator ~= nil then
            symbol.Indicator:update(core.UpdateLast);
        end
    end
end

local MAX_LOADING = 10;

function AsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == TIMER_ID then
        local loading_count = 0;
        for _, symbol in ipairs(symbols) do
            if symbol.Source == nil then
                symbol:DoLoad();
                loading_count = loading_count + 1;
            elseif symbol.Loading then
                loading_count = loading_count + 1;
            end
            if loading_count == MAX_LOADING then
                return;
            end
        end
        core.host:execute("setStatus", "");
        core.host:execute("killTimer", timer_handle);
    else
        for _, symbol in ipairs(symbols) do
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
signaler.Version = "1.5";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};

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
    if cookie == self._advanced_alert_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._advanced_alert_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
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
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram message or Channel post", false);
    parameters:addString("advanced_alert_key", "Advanced Alert Key", "You can get it via @profit_robots_bot Telegram bot", "");
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end
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