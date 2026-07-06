-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66681

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

-- Dashboard template v.1.2

local timeframes_list = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
local Modules = {};

-- USER DEFINITIONS SECTION
local indi_name = "Genesis Matrix Trading Dashboard";
local indi_version = "1";

function CreateIndicator1(source)
	assert(core.indicators:findIndicator("TVI") ~= nil, "Please, download and install TVI.LUA indicator")
    return core.indicators:create("TVI", source, instance.parameters.r, instance.parameters.s, instance.parameters.u)
end
function CreateIndicator2(source)
    assert(core.indicators:findIndicator("T3X6") ~= nil, "Please, download and install T3X6.LUA indicator")
	return core.indicators:create("T3X6", source.close, instance.parameters.F, instance.parameters.VF)
end
function CreateIndicator3(source)
    return core.indicators:create("CCI", source, instance.parameters.CCI_Period)
end
function CreateIndicator4(source)
	return core.indicators:create("MVA", source.high, instance.parameters.Period)
end
function CreateIndicator5(source)
	return core.indicators:create("MVA", source.low, instance.parameters.Period)
end

function CreateParameters()
    indicator.parameters:addGroup("TVI Calculation")
	indicator.parameters:addInteger("r", "First Smoothing", "", 12)
	indicator.parameters:addInteger("s", "Second Smoothing", "", 12)
	indicator.parameters:addInteger("u", "Signal", "u", 5)

	indicator.parameters:addGroup("CCI Calculation")
	indicator.parameters:addInteger("CCI_Period", "Period", "Period", 20)

	indicator.parameters:addGroup("T3 Calculation")
	indicator.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.618, 0, 1)
	indicator.parameters:addInteger("F", "Period", "Period", 8, 2, 2000)

	indicator.parameters:addGroup("GannHiLo Calculation")
	indicator.parameters:addInteger("Period", "Period", "", 10)
end

function GetPatternName(signal)
    if signal == 1 then
        return "B";
    elseif signal == -1 then
        return "S";
    end

    return "-";
end

function GetLastSignal(indi1, indi2, indi3, indi4, indi5, source)
    for i = 0, source:size() - 2 do
        if indi1.DATA[NOW - i] > indi1.DATA[NOW - i - 1] 
            and indi3.DATA[NOW - i] > 0 
            and indi2.DATA[NOW - i] > indi2.DATA[NOW - i - 1]
            and source.close[NOW - i] > indi4.DATA[NOW - i - 1]
        then
            return 1, source:date(NOW - i)
        elseif indi1.DATA[NOW - i] < indi1.DATA[NOW - i - 1] 
            and indi3.DATA[NOW - i] < 0 
            and indi2.DATA[NOW - i] < indi2.DATA[NOW - i - 1]
            and source.close[NOW - i] < indi5.DATA[NOW - i - 1]
        then
            return -1, source:date(NOW - i)
        end
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
    indicator.parameters:addBoolean("all_instruments", "All instruments", "", true);
    for i = 1, 20, 1 do
        Add(i);
    end
    
    indicator.parameters:addGroup("Time Frame Selector");
   -- for i = 1, #timeframes_list do
      --  AddTimeFrame(i, timeframes_list[i], true);
  --  end
  
  AddTimeFrame(1, timeframes_list[1], false);
  AddTimeFrame(2, timeframes_list[2], false);
  AddTimeFrame(3, timeframes_list[3], false);
  AddTimeFrame(4, timeframes_list[4], false);
  AddTimeFrame(5, timeframes_list[5], true);
  AddTimeFrame(6, timeframes_list[6], false);
  AddTimeFrame(7, timeframes_list[7], false);
  AddTimeFrame(8, timeframes_list[8], false);
  AddTimeFrame(9, timeframes_list[9], false);
  AddTimeFrame(10, timeframes_list[10], true);
  AddTimeFrame(11, timeframes_list[11], true);
  AddTimeFrame(12, timeframes_list[12], true);
  AddTimeFrame(13, timeframes_list[13], true);
  

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
    indicator.parameters:addString("grid_mode", "Grid mode", "", "h")
    indicator.parameters:addStringAlternative("grid_mode", "Horizontal", "", "h")
    indicator.parameters:addStringAlternative("grid_mode", "Vertical", "", "v")
    indicator.parameters:addGroup("Alerts");
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
end

function AddTimeFrame(id, FRAME, DEFAULT)
    indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT); 
end

local symbols = {};
local instruments = {};
local timeframes = {};

local text_color;
local TIMER_ID = 1;
local last_id = 1;

function PrepareInstrument(instrument)
    local timeframe_index = 1;
    for ii = 1, #timeframes_list do
        use = instance.parameters:getBoolean("Use" .. ii);
        if use then
            local symbol = {};
            symbol.Pair = instrument;
            symbol.Point = core.host:findTable("offers"):find("Instrument", symbol.Pair).PointSize;
            symbol.TF = timeframes_list[ii];
            symbol.LoadingId = last_id + 1;
            symbol.LoadedId = last_id + 2;
            symbol.Loading = true;
            symbol.SymbolIndex = #instruments + 1;
            symbol.TimeframeIndex = timeframe_index;
            function symbol:DoLoad()
                self.Source = core.host:execute("getSyncHistory", self.Pair, self.TF, instance.source:isBid(), 300, self.LoadedId, self.LoadingId);
                self.Indicator1 = CreateIndicator1(self.Source);
                self.Indicator2 = CreateIndicator2(self.Source);
                self.Indicator3 = CreateIndicator3(self.Source);
                self.Indicator4 = CreateIndicator4(self.Source);
                self.Indicator5 = CreateIndicator5(self.Source);
            end
            last_id = last_id + 2;
            symbols[#symbols + 1] = symbol;
            timeframes[timeframe_index] = timeframes_list[ii];
            timeframe_index = timeframe_index + 1;
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
    signaler:Prepare(nameOnly);
    instance:name(indi_name);
    if nameOnly then
        return;
    end
    text_color = instance.parameters.text_color;

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

local init = false;
local FONT = 1;
local FONT_TEXT = 2;
local BG_PEN = 3;
local BG_BRUSH = 4;
local GRID_PEN = 5;

local draw_grid, grid_mode;
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
            CellsBuilder:Add(FONT_TEXT, timeframes[i], text_color, 1, (i + 1) * 2, context.LEFT);
        else
            CellsBuilder:Add(FONT_TEXT, timeframes[i], text_color, i + 1, 1, context.LEFT);
        end
    end
    for i = 1, #instruments do
        if grid_mode == "h" then
            CellsBuilder:Add(FONT_TEXT, instruments[i], text_color, i + 1, 1, context.CENTER);
        else
            CellsBuilder:Add(FONT_TEXT, instruments[i], text_color, 1, (i + 1) * 2, context.CENTER);
        end
    end
    for _, symbol in ipairs(symbols) do
        if not symbol.Loading then
            if symbol.Updated == nil then
                symbol.Indicator1:update(core.UpdateLast);
                symbol.Indicator2:update(core.UpdateLast);
                symbol.Indicator3:update(core.UpdateLast);
                symbol.Indicator4:update(core.UpdateLast);
                symbol.Indicator5:update(core.UpdateLast);
                symbol.Updated = true;
            end
            local signal, time = GetLastSignal(symbol.Indicator1, symbol.Indicator2, symbol.Indicator3, symbol.Indicator4, symbol.Indicator5, symbol.Source);
            local row;
            local column;
            if grid_mode == "h" then
                row = (symbol.TimeframeIndex + 1) * 2;
                column = symbol.SymbolIndex + 1;
            else
                column = symbol.TimeframeIndex + 1;
                row = (symbol.SymbolIndex + 1) * 2;
            end
            if signal == 0 then
                CellsBuilder:Add(FONT_TEXT, "-", text_color, column, row, context.CENTER, backgound, GRID_PEN, true, false);
                CellsBuilder:Add(FONT_TEXT, "-", text_color, column, row + 1, context.CENTER, backgound, GRID_PEN, false, true);
            elseif signal > 0 then
                local is_current_bar = symbol.Source:date(NOW - 3) <= time;
                local backgound = -1;
                if is_current_bar then
                    backgound = instance.parameters.signal_background_color;
                end
                local pattern_name = GetPatternName(signal);
                CellsBuilder:Add(FONT_TEXT, pattern_name, instance.parameters.up_color, column, row, context.CENTER, backgound, GRID_PEN, true, false);
                CellsBuilder:Add(FONT_TEXT, FormatTime(time), text_color, column, row + 1, context.CENTER, backgound, GRID_PEN, false, true);
                if is_current_bar and symbol.last_alert ~= time then
                    signaler:Signal(symbol.Source:instrument() .. "(" .. symbol.Source:barSize() .. "): " .. pattern_name);
                    symbol.last_alert = time;
                end
            else
                local is_current_bar = symbol.Source:date(NOW) <= time;
                local backgound = -1;
                if is_current_bar then
                    backgound = instance.parameters.signal_background_color;
                end
                local pattern_name = GetPatternName(signal);
                CellsBuilder:Add(FONT_TEXT, pattern_name, instance.parameters.dn_color, column, row, context.CENTER, backgound, GRID_PEN, true, false);
                CellsBuilder:Add(FONT_TEXT, FormatTime(time), text_color, column, row + 1, context.CENTER, backgound, GRID_PEN, false, true);
                if is_current_bar and symbol.last_alert ~= time then
                    signaler:Signal(symbol.Source:instrument() .. "(" .. symbol.Source:barSize() .. "): " .. pattern_name);
                    symbol.last_alert = time;
                end
            end
        end
    end
    local width = math.max(title_w, CellsBuilder:GetTotalWidth());
    context:drawRectangle(BG_PEN, BG_BRUSH, context:right() - width, context:top(), context:right(), context:top() + title_h * 1.2 + CellsBuilder:GetTotalHeight());
    context:drawText(FONT_TEXT, indi_name, text_color, -1, context:right() - width, context:top(), context:right(), context:top() + title_h, 0);
    CellsBuilder:Draw(context:right() - width, context:top() + title_h * 1.2);
end

function Update(period, mode)
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(nil, nil, nil); end end
    for _, symbol in ipairs(symbols) do
        if symbol.Indicator1 ~= nil then
            symbol.Indicator1:update(core.UpdateLast);
        end
        if symbol.Indicator2 ~= nil then
            symbol.Indicator2:update(core.UpdateLast);
        end
        if symbol.Indicator3 ~= nil then
            symbol.Indicator3:update(core.UpdateLast);
        end
        if symbol.Indicator4 ~= nil then
            symbol.Indicator4:update(core.UpdateLast);
        end
        if symbol.Indicator5 ~= nil then
            symbol.Indicator5:update(core.UpdateLast);
        end
    end
end

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
            if loading_count == instance.parameters.load_quota and instance.parameters.load_quota > 0 then
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
signaler.Version = "1.6";

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

            self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
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
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
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