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

function Init()
	indicator:name("Risk Management");
	indicator:description("");
	indicator:requiredSource(core.Bar);
	indicator:type(core.Oscillator);
	indicator.parameters:addString("ACCOUNT", resources:get("account"), "", "");
    indicator.parameters:setFlag("ACCOUNT", core.FLAG_ACCOUNT);
	indicator.parameters:addDouble("risk", "Position Risk Percentage", "", 2);
    indicator.parameters:addDouble("rrr", "Reward to Risk Ratio, x:1", "", 2);
    indicator.parameters:addString("bs", "Side", "", "B");
    indicator.parameters:addStringAlternative("bs", "Buy", "", "B");
    indicator.parameters:addStringAlternative("bs", "Sell", "", "S");
    indicator.parameters:addDouble("stop", "Stop Loss in Pips", "", 100)
    indicator.parameters:addDouble("expected_volatility", "Expected Volatility", "", 5)
    indicator.parameters:addInteger("time", "Time (Days)", "", 5);
    indicator.parameters:addInteger("confidence", "Confidence level", "", 90);
    
	indicator.parameters:addColor("text_color", "Text color", "", core.colors().Red);
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

local source;
function Prepare(nameOnly)
	source = instance.source;
	local name = string.format("%s(%s)", profile:id(), source:name());
	instance:name(name);
	if nameOnly then
		return ;
	end
	instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local MAIN_FONT = 1;
local text_color;
local ACCOUNT, risk, rrr, bid, ask, stop, bs, expected_volatility, time, confidence;
function Draw(stage, context)
	if stage ~= 2 then
		return;
	end
	if not init then
		init = true;
		context:createFont(MAIN_FONT, "Arial", 0, context:pointsToPixels(10), context.LEFT);
		text_color = instance.parameters.text_color;
		ACCOUNT = instance.parameters.ACCOUNT;
		risk = instance.parameters.risk;
        rrr = instance.parameters.rrr;
        bid = core.host:execute("getBidPrice");
        ask = core.host:execute("getAskPrice");
        stop = instance.parameters.stop;
        bs = instance.parameters.bs;
        time = instance.parameters.time;
        expected_volatility = instance.parameters.expected_volatility;
        confidence = instance.parameters.confidence;
	end
	CellsBuilder:Clear(context);

	local row = 1;
	CellsBuilder:Add(MAIN_FONT, "Account Equity", text_color, 1, row, 0);
	equityAmount = core.host:findTable("accounts"):find("AccountID", ACCOUNT).Equity;
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(equityAmount, false, 2), text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:AddGap(1, row, 5, 5)
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Position Risk Percentage", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(risk, false, 2) .. "%", text_color, 2, row, 0);
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Reward to Risk Ratio", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(rrr, false, 2) .. ":1", text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:Add(MAIN_FONT, "Position Risk Value", text_color, 1, row, 0);
    local position_risk_value = equityAmount * risk / 100;
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(position_risk_value, false, 2), text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:AddGap(1, row, 5, 5)
	row = row + 1;

	CellsBuilder:Add(MAIN_FONT, "Instrument", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, source:instrument(), text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:Add(MAIN_FONT, "Bid Price", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(bid:tick(NOW), false, source:getPrecision()), text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:Add(MAIN_FONT, "Ask Price", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(ask:tick(NOW), false, source:getPrecision()), text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:Add(MAIN_FONT, "Spread", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(ask:tick(NOW) - bid:tick(NOW), false, source:getPrecision()), text_color, 2, row, 0);
	row = row + 1;

    local MMR = core.host:execute("getTradingProperty", "MMR", source:instrument(), ACCOUNT);
	CellsBuilder:Add(MAIN_FONT, "MMR", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(MMR, false, 2), text_color, 2, row, 0);
	row = row + 1;

    local offer = core.host:findTable("offers"):find("Instrument", source:instrument());
    
    CellsBuilder:Add(MAIN_FONT, "Pip Cost", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(source:getPrecision(), false, 2), text_color, 2, row, 0);
	row = row + 1;

    local baseUnitSize = core.host:execute("getTradingProperty", "baseUnitSize", source:instrument(), ACCOUNT)
    CellsBuilder:Add(MAIN_FONT, "Lot Size", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, tostring(baseUnitSize), text_color, 2, row, 0);
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Stop Loss in Pips", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(stop, false, 2), text_color, 2, row, 0);
	row = row + 1;

    local stop_price;
    local entry_price;
    if bs == "B" then
        entry_price = ask:tick(NOW);
        stop_price = bid:tick(NOW) - stop * bid:pipSize();
    else
        entry_price = bid:tick(NOW);
        stop_price = ask:tick(NOW) + stop * bid:pipSize();
    end
    local pip_value = source:getPrecision() * stop;
    local lots = position_risk_value / pip_value;

    local stop_curr = source:getPrecision() * lots * stop;
    CellsBuilder:Add(MAIN_FONT, "Stop Loss in $", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(stop_curr, false, 2), text_color, 2, row, 0);
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Stop Loss Price", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(stop_price, false, bid:getPrecision()), text_color, 2, row, 0);
	row = row + 1;	

    CellsBuilder:Add(MAIN_FONT, "Pip Value", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(pip_value, false, 2), text_color, 2, row, 0);
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Lots", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(lots, false, 0), text_color, 2, row, 0);
	row = row + 1;
    
    CellsBuilder:Add(MAIN_FONT, "Position Cost", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(MMR * lots, false, 2), text_color, 2, row, 0);
	row = row + 1;
    
    local position_value = entry_price * baseUnitSize * lots;
    CellsBuilder:Add(MAIN_FONT, "Position Value", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(position_value, false, 2), text_color, 2, row, 0);
	row = row + 1;
    
    local leverage = (baseUnitSize * lots * entry_price / equityAmount);
    CellsBuilder:Add(MAIN_FONT, "Applied Leverage", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(leverage, false, 2) .. ":1", text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:AddGap(1, row, 5, 5)
	row = row + 1;

    local limit_pips = stop * rrr;
    local limit_curr = bid:pipSize() * limit_pips * lots;
    local limit_price;
    if bs == "B" then
        limit_price = entry_price + (limit_pips * bid:pipSize());
    else
        limit_price = entry_price - (limit_pips * bid:pipSize());
    end
	
    CellsBuilder:Add(MAIN_FONT, "Limit Profit in Pips", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(limit_pips, false, 2), text_color, 2, row, 0);
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Limit Profit in $", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(limit_curr, false, 2), text_color, 2, row, 0);
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Profit Target Price", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(limit_price, false, bid:getPrecision()), text_color, 2, row, 0);
	row = row + 1;
    
    CellsBuilder:Add(MAIN_FONT, "Position Profit Margin %", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(100 * limit_curr / equityAmount, false, 2) .. "%", text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:AddGap(1, row, 5, 5)
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Expected Volatility", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(expected_volatility, false, 2) .. "%", text_color, 2, row, 0);
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Time (days)", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(time, false, 0), text_color, 2, row, 0);
	row = row + 1;

    CellsBuilder:Add(MAIN_FONT, "Confidence level", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(confidence, false, 2) .. "%", text_color, 2, row, 0);
	row = row + 1;

    local stress_event = NormSInv(confidence / 100);
    CellsBuilder:Add(MAIN_FONT, "Stress event", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(stress_event, false, 2), text_color, 2, row, 0);
	row = row + 1;

    local value_at_risk = position_value * stress_event * expected_volatility / 100 * math.sqrt(time / 252);
    CellsBuilder:Add(MAIN_FONT, "Value at Risk", text_color, 1, row, 0);
	CellsBuilder:Add(MAIN_FONT, win32.formatNumber(value_at_risk, false, 2), text_color, 2, row, 0);
	row = row + 1;

	CellsBuilder:Draw(context:left(), context:top());
end

function NormSInv(p)
    --https://www.source-code.biz/snippets/vbasic/9.htm
    local a1 = -39.6968302866538
    local a2 = 220.946098424521
    local a3 = -275.928510446969
    local a4 = 138.357751867269
    local a5 = -30.6647980661472
    local a6 = 2.50662827745924
    local b1 = -54.4760987982241
    local b2 = 161.585836858041
    local b3 = -155.698979859887
    local b4 = 66.8013118877197
    local b5 = -13.2806815528857
    local c1 = -7.78489400243029E-03
    local c2 = -0.322396458041136
    local c3 = -2.40075827716184
    local c4 = -2.54973253934373
    local c5 = 4.37466414146497
    local c6 = 2.93816398269878
    local d1 = 7.78469570904146E-03
    local d2 = 0.32246712907004
    local d3 = 2.445134137143
    local d4 = 3.75440866190742
    local p_low = 0.02425
    local p_high = 1 - p_low
    if p < p_low then
        q = math.sqr(-2 * math.log(p))
        return (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) / ((((d1 * q + d2) * q + d3) * q + d4) * q + 1);
    elseif p <= p_high then
        q = p - 0.5
        r = q * q
        return (((((a1 * r + a2) * r + a3) * r + a4) * r + a5) * r + a6) * q / (((((b1 * r + b2) * r + b3) * r + b4) * r + b5) * r + 1)
    end
    q = math.sqr(-2 * math.log(1 - p))
    return -(((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) / ((((d1 * q + d2) * q + d3) * q + d4) * q + 1)
end