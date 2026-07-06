-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70538

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+


function Init()
	indicator:name("Moving Averages Scalping Tool  Oscillator")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("Period1", "1. MA Period", "", 50, 1, 1000)
	indicator.parameters:addInteger("Period2", "2. MA Period", "", 100, 1, 1000)
	indicator.parameters:addInteger("Period3", "3. MA Period", "", 200, 1, 1000)
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Selector")

	indicator.parameters:addBoolean("Off", "Exclude 1. MA filtering", "", true);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 255, 0));
 
	indicator.parameters:addString("Account", "Account to trade on", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    indicator.parameters:addString("amount_type", "Amount Units", "", "lots");
    indicator.parameters:addStringAlternative("amount_type", "Lots", "", "lots");
    indicator.parameters:addStringAlternative("amount_type", "% of equity", "", "equity");
	indicator.parameters:addDouble("Amount", "Trade Amount", "", 1, 1, 1000000);
	indicator.parameters:addString("custom_id", "Custom ID", "", "");
	indicator.parameters:addBoolean("use_stop", "Set Stop", "", false);
    indicator.parameters:addDouble("stop_pips", "Stop, pips", "", 10);
    indicator.parameters:addBoolean("use_trailing", "Trailing stop order", "", false);
    indicator.parameters:addInteger("trailing", "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);
    indicator.parameters:addBoolean("use_limit", "Set Limit", "", false);
	indicator.parameters:addDouble("limit_pips", "Limit, pips", "", 20);
	
	indicator.parameters:addInteger("bars_no_trading", "Wait bars after cross", "", 10);
end

local OPEN_TRADE_ID = 100;
local CLOSE_TRADES_ID = 101;
local AUTO_CLOSE_ID = 102;

local first;
local source;
local Period1, Period2, Period3,Method;
local Off;
local open = nil;
local close = nil;
local high = nil;
local low = nil;

--local MA = nil;
local MA1,MA2,MA3;
local ma1, ma2, ma3;
local Up, Down;
local Ratio;
local Lines;
local Transparency;
local Trend;
local LastCross;
local Account, amount_type, Amount, custom_id, use_stop, stop_pips, use_trailing, trailing, use_limit, limit_pips, bars_no_trading;
function Prepare(nameOnly)
	bars_no_trading = instance.parameters.bars_no_trading;
	Account = instance.parameters.Account;
	amount_type = instance.parameters.amount_type;
	Amount = instance.parameters.Amount;
	custom_id = instance.parameters.custom_id;
	use_stop = instance.parameters.use_stop;
	stop_pips = instance.parameters.stop_pips;
	use_trailing = instance.parameters.use_trailing;
	trailing = instance.parameters.trailing;
	use_limit = instance.parameters.use_limit;
	limit_pips = instance.parameters.limit_pips;
	 
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	Method = instance.parameters.Method;
	Off= instance.parameters.Off;
	source = instance.source;

	Up = instance.parameters.Up;
	Down = instance.parameters.Down;

	local name = profile:id() .. "(" .. source:name() .. ", " .. Period1, Period2, Period3 .. ", " .. Method .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA1 = core.indicators:create(Method, source , Period1);
	MA2 = core.indicators:create(Method, source , Period2);
    MA3 = core.indicators:create(Method, source , Period3);
	first = math.max(MA1.DATA:first(),MA2.DATA:first(),MA3.DATA:first());
     
	 
	Trend = instance:addStream("Trend" , core.Bar, "Trend","Trend",instance.parameters.color, first ); 
    Trend:setPrecision(math.max(2, source:getPrecision()));
	 
	ma1 = instance:addInternalStream(0, 0);
	ma2 = instance:addInternalStream(0, 0);
	ma3 = instance:addInternalStream(0, 0);

    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;
    amount_type = instance.parameters.amount_type;
    custom_id = instance.parameters.custom_id;

	base_size = core.host:execute("getTradingProperty", "baseUnitSize", source:instrument(), Account);
    offer_id = core.host:findTable("offers"):find("Instrument", source:instrument()).OfferID;

	core.host:execute("addCommand", OPEN_TRADE_ID, "Open Trade", "Open Trade");
	core.host:execute("addCommand", CLOSE_TRADES_ID, "Close Trades", "Close Trades");
	core.host:execute("addCommand", AUTO_CLOSE_ID, "Auto Close", "Auto Close");
	instance:ownerDrawn(true);
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

local autoclose = false;
local FONT_ID = 1;
local init = false;
local colors = core.colors();
function Draw(stage, context)
	if stage ~= 2 then
		return;
	end
	if not init then
		context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(8), context.LEFT);
		init = true;
	end
	CellsBuilder:Clear(context);
	CellsBuilder:Add(FONT_ID, "Direction", colors.Gray, 1, 1, 0);
	local trend = GetTrend();
	if trend == 0 then
		CellsBuilder:Add(FONT_ID, "No trading", colors.Gray, 2, 1, 0);
	elseif trend == 1 then
		CellsBuilder:Add(FONT_ID, "Long", colors.Green, 2, 1, 0);
	else
		CellsBuilder:Add(FONT_ID, "Short", colors.Red, 2, 1, 0);
	end
	if autoclose then
		CellsBuilder:Add(FONT_ID, "Autoclose", colors.Blue, 1, 2, 0);
	else
		CellsBuilder:Add(FONT_ID, "Autoclose", colors.Gray, 1, 2, 0);
	end
	local width = CellsBuilder:GetTotalWidth();
	CellsBuilder:Draw(context:right() - width, context:top());
end

function GetTrend()
	for i = 0, bars_no_trading - 1 do
		if core.crosses(MA1.DATA, MA2.DATA, MA1.DATA:size() - 1 - i) then
			return 0;
		end
	end
	return Trend[NOW];
end

function Update(period, mode)
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	
	if period < first then
		return
	end
	
	ma1[period]=MA1.DATA[period];
	ma2[period]=MA2.DATA[period];
	ma3[period]=MA3.DATA[period];

	Trend[period]=0;
	
	if source[period]> MA1.DATA[period]
	and (MA1.DATA[period]> MA1.DATA[period-1] or Off )
	and MA2.DATA[period]> MA2.DATA[period-1]
	and MA3.DATA[period]> MA3.DATA[period-1]
	and (MA1.DATA[period]> MA2.DATA[period] or Off )
	and MA2.DATA[period]> MA3.DATA[period]
	then
	Trend[period]=1;
	elseif  source[period]< MA1.DATA[period]
 	and (MA1.DATA[period]< MA1.DATA[period-1]  or Off )
	and MA2.DATA[period]< MA2.DATA[period-1]
	and MA3.DATA[period]< MA3.DATA[period-1]
	and (MA1.DATA[period]< MA2.DATA[period] or Off )
	and MA2.DATA[period]< MA3.DATA[period]
	then
	Trend[period]=-1;
	end
	if autoclose and period == source:size() - 1 then
		if source.close[period] < MA3.DATA[period] then
			CloseTrades("B");
			CloseTrades("S");
		end
	end
end 

function CloseTrades(side)
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.BS == side
            and row.Instrument == source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            CloseTrade(row);
        end
        row = enum:next();
    end
end

function OpenTrade(side)
    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = offer_id;
    valuemap.AcctID = Account;
    if amount_type == "lots" then
        valuemap.Quantity = Amount * base_size;
    else
        local equity = core.host:findTable("accounts"):find("AccountID", valuemap.AcctID).Equity;
        local used_equity = equity * Amount / 100.0;
        local emr = core.host:getTradingProperty("EMR", instance.bid:instrument(), valuemap.AcctID);
        valuemap.Quantity = math.floor(used_equity / emr) * base_size;
    end
    valuemap.BuySell = side;
    valuemap.CustomID = custom_id;
    if use_stop then
        valuemap.PegTypeStop = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -stop_pips;
        else
            valuemap.PegPriceOffsetPipsStop = stop_pips;
        end
        if use_trailing then
            valuemap.TrailStepStop = trailing;
        end
    end
    if use_limit then
        valuemap.PegTypeLimit = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = limit_pips;
        else
            valuemap.PegPriceOffsetPipsLimit = -limit_pips;
        end
    end
    local success, msg = terminal:execute(3, valuemap);
end

function CloseTrade(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(2, valuemap);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
	if cookie == OPEN_TRADE_ID then
		for i = 0, bars_no_trading - 1 do
			if core.crosses(MA1.DATA, MA2.DATA, MA1.DATA:size() - 1 - i) then
				core.host:trace("Blocked by a cross");
				return;
			end
		end
		if Trend[NOW] == 1 then
			OpenTrade("B");
		elseif Trend[NOW] == -1 then
			OpenTrade("S");
		else
			core.host:trace("Blocked by a trend");
		end
	elseif cookie == CLOSE_TRADES_ID then
		CloseTrades("B");
		CloseTrades("S");
	elseif cookie == AUTO_CLOSE_ID then
		autoclose = true;
	end
end