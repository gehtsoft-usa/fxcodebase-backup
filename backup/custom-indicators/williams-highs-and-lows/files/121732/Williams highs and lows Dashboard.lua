-- Id: 22521
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66856

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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

local iTF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};

function Init()
    indicator:name("Williams’s highs and lows Dashboard");
    indicator:description("v 1 (2018-10-19)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Instruments");
    indicator.parameters:addBoolean("all_instruments", "All instruments", "", true);
    for i = 1, 20, 1 do
        Add(i);
    end
    
    indicator.parameters:addGroup("Time Frame Selector");
    for i = 1, #iTF do
        AddTimeFrame(i, iTF[i], true);
    end

    indicator.parameters:addColor("up_color", "Up color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("dn_color", "Down color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("text_color", "Text color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("background_color", "Background color", "", core.rgb(255, 255, 255));
end

function Add(id)
    local Init = {"EUR/USD", "USD/JPY", "GBP/USD", "USD/CHF", "EUR/CHF"
                , "AUD/USD", "USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
                , "GBP/JPY", "CHF/JPY", "GBP/CHF", "EUR/AUD", "EUR/CAD"
                , "AUD/CAD", "AUD/JPY", "CAD/JPY", "NZD/JPY", "GBP/CAD"
            };
    indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", id <= 5);
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
end

function AddTimeFrame(id , FRAME , DEFAULT  )
    indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT); 
end

local symbols = {};
local instruments = {};
local timeframes = {};

local text_color;
local source;
local last_id = 0;

function PrepareInstrument(instrument)
    local timeframe_index = 1;
    for ii = 1, #iTF do
        use = instance.parameters:getBoolean("Use" .. ii);
        if use then
            local symbol = {};
            symbol.Pair = instrument;
            symbol.Point = core.host:findTable("offers"):find("Instrument", symbol.Pair).PointSize;
            symbol.TF = iTF[ii];
            symbol.LoadingId = last_id + 1;
            symbol.LoadedId = last_id + 2;
            symbol.Source = core.host:execute("getSyncHistory", symbol.Pair, symbol.TF, source:isBid(), 0, symbol.LoadedId, symbol.LoadingId);
            symbol.Loading = true;
            symbol.SymbolIndex = #instruments + 1;
            symbol.TimeframeIndex = timeframe_index;
    assert(core.indicators:findIndicator("WILLIAMS HIGHS AND LOWS") ~= nil, "WILLIAMS HIGHS AND LOWS" .. " indicator must be installed");
            symbol.Indicator = core.indicators:create("WILLIAMS HIGHS AND LOWS", symbol.Source);
            last_id = last_id + 2;
            symbols[#symbols + 1] = symbol;
            timeframes[timeframe_index] = iTF[ii];
            timeframe_index = timeframe_index + 1;
        end
    end
    instruments[#instruments + 1] = instrument;
end

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
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
            if instance.parameters:getBoolean("Dodaj" .. i) then
                PrepareInstrument(instance.parameters:getString("Pair" .. i));
            end
        end
    end
    instance:ownerDrawn(true);
end

local CellsBuilder = {};
CellsBuilder.GapCoeff = 1.2;
function CellsBuilder:Clear(context)
    self.Columns = {};
    self.RowHeights = {};
    self.Context = context;
end
function CellsBuilder:Add(font, text, color, column, row, mode)
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
                self.Context:drawText(cell.Font, cell.Text, 
                    cell.Color, -1, 
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

local init = false;
local FONT = 1;
local FONT_TEXT = 2;
local BG_PEN = 3;
local BG_BRUSH = 4;
function Draw(stage, context) 
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(FONT, "Wingdings", 0, context:pointsToPixels(8), 0)
        context:createFont(FONT_TEXT, "Arial", 0, context:pointsToPixels(8), 0)
        context:createPen(BG_PEN, context.SOLID, 1, instance.parameters.background_color);
        context:createSolidBrush(BG_BRUSH, instance.parameters.background_color);
        init = true;
    end
    local title = "Williams's Highs and Lows Dashboard";
    local title_w, title_h = context:measureText(FONT_TEXT, title, 0);
    CellsBuilder:Clear(context);
    for i = 1, #timeframes do
        CellsBuilder:Add(FONT_TEXT, timeframes[i], text_color, 1, (i + 1) * 2, context.LEFT);
    end
    for i = 1, #instruments do
        CellsBuilder:Add(FONT_TEXT, instruments[i], text_color, i + 1, 1, context.CENTER);
    end
    for _, symbol in ipairs(symbols) do
        if not symbol.Loading then
            if symbol.Updated == nil then
                symbol.Indicator:update(core.UpdateLast);
                symbol.Updated = true;
            end
            local signal, time = GetLastSignal(symbol.Indicator, symbol.Source);
            local row = (symbol.TimeframeIndex + 1) * 2;
            local column = symbol.SymbolIndex + 1;
            if signal == 0 then
                CellsBuilder:Add(FONT_TEXT, "-", text_color, column, row, context.CENTER);
                CellsBuilder:Add(FONT_TEXT, "-", text_color, column, row + 1, context.CENTER);
            elseif signal == 1 then
                CellsBuilder:Add(FONT, "\233", instance.parameters.up_color, column, row, context.CENTER);
                CellsBuilder:Add(FONT_TEXT, FormatTime(time), text_color, column, row + 1, context.CENTER);
            else
                CellsBuilder:Add(FONT, "\234", instance.parameters.dn_color, column, row, context.CENTER);
                CellsBuilder:Add(FONT_TEXT, FormatTime(time), text_color, column, row + 1, context.CENTER);
            end
        end
    end
    local width = math.max(title_w, CellsBuilder:GetTotalWidth());
    context:drawRectangle(BG_PEN, BG_BRUSH, context:right() - width, context:top(), context:right(), context:top() + title_h * 1.2 + CellsBuilder:GetTotalHeight());
    context:drawText(FONT_TEXT, title, text_color, -1, context:right() - width, context:top(), context:right(), context:top() + title_h, 0);
    CellsBuilder:Draw(context:right() - width, context:top() + title_h * 1.2);
end

function Update(period, mode)
    for _, symbol in ipairs(symbols) do
        symbol.Indicator:update(core.UpdateLast);
    end
end

function AsyncOperationFinished(cookie)
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

function GetLastSignal(indi, source)
    local up = indi:getTextOutput(0);
    local down = indi:getTextOutput(1);
    for i = 0, up:size() - 1 do
        if up:hasData(NOW - i) then
            return 1, source:date(NOW - i);
        end
        if down:hasData(NOW - i) then
            return -1, source:date(NOW - i);
        end
    end
    return 0;
end