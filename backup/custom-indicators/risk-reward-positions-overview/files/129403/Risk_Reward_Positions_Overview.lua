-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66100

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

function Init()
    indicator:name("Risk Reward Positions Overview")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Placement")
    indicator.parameters:addBoolean("PositionCapInstrument", "Use Position Instrument", "", true)

    indicator.parameters:addGroup("Placement")
    indicator.parameters:addString("Y", " Y Placement", "", "Top")
    indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

    indicator.parameters:addString("X", " X Placement", "", "Left")
    indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
    indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
    indicator.parameters:addInteger("ShiftY", "Shift", "", 3)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
    indicator.parameters:addInteger("Size", "Font Size", "", 10)
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))
end

local first
local source = nil
local X, Y
local font
local Label
local Size
local ShiftY
local PositionCapInstrument
local Offer
local ask
local bid

-- Routine
function Prepare(nameOnly)
    Y = instance.parameters.Y
    X = instance.parameters.X
    ShiftY = instance.parameters.ShiftY
    Label = instance.parameters.Label

    Size = instance.parameters.Size
    source = instance.source
    first = source:first()

    PositionCapInstrument = instance.parameters.PositionCapInstrument

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    Offer = core.host:findTable("offers"):find("Instrument", source:instrument()).OfferID
    instance:ownerDrawn(true)

    if source:isBid() then
        bid = source
        ask = core.host:execute("getAskPrice")
    else
        ask = source
        bid = core.host:execute("getBidPrice")
    end
end

function Update(period)
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

local init = false
function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        context:createFont(1, "Arial", 0, context:pointsToPixels(Size), 0)
        init = true
    end
    CellsBuilder:Clear(context);
    local rowIndex = 1
    CellsBuilder:Add(1, "Ticket", Label, 1, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "Symbol", Label, 2, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "S/B", Label, 3, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "R/R", Label, 4, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "Pips", Label, 5, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "Gross P/L", Label, 6, rowIndex, context.LEFT);
    rowIndex = rowIndex + 1

    local Risk = "-"
    local Reward = "-"
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    local totalPL = 0;
    local totalGrossPL = 0;
    local tradesCount = 0;
    while (row ~= nil) do
        -- for every trade for this instance.
        if (not PositionCapInstrument or (row.OfferID == Offer and PositionCapInstrument)) then
            if row.Stop == 0 or row.Limit == 0 then
                Risk = "-"
                Reward = "-"
            else
                Risk = "1"
                Reward = math.abs(row.Open - row.Limit) / math.abs(row.Open - row.Stop)
            end

            local isDigit = tonumber(Reward)
            if isDigit then
                Reward = math.floor(Reward + 0.5)
            end
            totalPL = totalPL + row.PL;
            totalGrossPL = totalGrossPL + row.GrossPL;
            CellsBuilder:Add(1, row.TradeID, Label, 1, rowIndex, context.LEFT);
            CellsBuilder:Add(1, row.Instrument, Label, 2, rowIndex, context.LEFT);
            CellsBuilder:Add(1, row.BS, Label, 3, rowIndex, context.LEFT);
            CellsBuilder:Add(1, Risk .. ":" .. Reward, Label, 4, rowIndex, context.LEFT);
            CellsBuilder:Add(1, win32.formatNumber(row.PL, false, 2), Label, 5, rowIndex, context.LEFT);
            CellsBuilder:Add(1, win32.formatNumber(row.GrossPL, false, 2), Label, 6, rowIndex, context.LEFT);

            rowIndex = rowIndex + 1
            tradesCount = tradesCount + 1;
        end

        row = enum:next()
    end
    CellsBuilder:Add(1, "Total", Label, 4, rowIndex, context.LEFT);
    CellsBuilder:Add(1, win32.formatNumber(totalPL, false, 2), Label, 5, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "$" .. win32.formatNumber(totalGrossPL, false, 2), Label, 6, rowIndex, context.LEFT);
    rowIndex = rowIndex + 1;

    CellsBuilder:Add(1, "Active Trades: " .. tradesCount, Label, 1, rowIndex, context.LEFT);
    local ordersIndex = rowIndex + 1;
    rowIndex = rowIndex + 2;

    CellsBuilder:Add(1, "Ticket", Label, 1, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "Symbol", Label, 2, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "S/B", Label, 3, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "R/R", Label, 4, rowIndex, context.LEFT);
    CellsBuilder:Add(1, "Distance", Label, 5, rowIndex, context.LEFT);
    rowIndex = rowIndex + 1

    local orders = 0;
    enum = core.host:findTable("orders"):enumerator()
    row = enum:next()
    while (row ~= nil) do
        if row.Type == "SE" or row.Type == "LE" then
            if (not PositionCapInstrument or (row.OfferID == Offer and PositionCapInstrument)) then
                if row.Stop == 0 or row.Limit == 0 then
                    Risk = "-"
                    Reward = "-"
                else
                    Risk = "1"
                    local spread = ask[NOW] - bid[NOW]
                    local limitPips = 0
                    if row.TypeLimit == 3 or row.TypeLimit == 2 then
                        limitPips = math.abs(row.Limit)
                    else
                        limitPips = math.abs(row.Rate - row.Limit)
                    end

                    local stopPips = 0
                    if row.TypeStop == 3 or row.TypeStop == 2 then
                        stopPips = math.abs(row.Stop)
                    else
                        stopPips = (math.abs(row.Rate - row.Stop) - spread)
                    end

                    Reward = limitPips / stopPips
                end
                local isDigit = tonumber(Reward)
                if isDigit then
                    Reward = math.floor(Reward * 10 + 0.5) / 10
                end

                local distance = 0;
                if row.BS == "B" then
                    distance = math.abs(row.Rate - ask:tick(NOW)) / ask:pipSize();
                else
                    distance = math.abs(row.Rate - bid:tick(NOW)) / bid:pipSize();
                end
                CellsBuilder:Add(1, row.OrderID, Label, 1, rowIndex, context.LEFT);
                CellsBuilder:Add(1, row.Instrument, Label, 2, rowIndex, context.LEFT);
                CellsBuilder:Add(1, row.BS, Label, 3, rowIndex, context.LEFT);
                CellsBuilder:Add(1, Risk .. ":" .. Reward, Label, 4, rowIndex, context.LEFT);
                CellsBuilder:Add(1, win32.formatNumber(distance, false, 2), Label, 5, rowIndex, context.LEFT);
                orders = orders + 1;
            end
        end
        row = enum:next()
    end

    CellsBuilder:Add(1, "Entry Orders: " .. orders, Label, 1, ordersIndex, context.LEFT);

    local x = context:left();
    if X ~= "Left" then
        x = context:right();
    end
    local y = context:top();
    if Y ~= "Top" then
        y = context:bottom();
    end
    CellsBuilder:Draw(x, y)
end