-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65816

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("RSI Value on Chart")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("RSI Calculation")
	indicator.parameters:addBoolean("show_rsi", "Show RSI", "", true);
	indicator.parameters:addInteger("Period", "Period", "", 14)
	indicator.parameters:addGroup("CCI Calculation")
	indicator.parameters:addBoolean("show_cci", "Show CCI", "", true);
	indicator.parameters:addInteger("cci_period", "Period", "", 14)
	indicator.parameters:addGroup("MACD Calculation")
	indicator.parameters:addBoolean("show_macd", "Show MACD", "", true);
	indicator.parameters:addBoolean("show_signal", "Show MACD Signal", "", true);
	indicator.parameters:addBoolean("show_histogram", "Show MACD Histogram", "", true);
    indicator.parameters:addInteger("FMA", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 100);
    indicator.parameters:addInteger("SMA", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 200);
    indicator.parameters:addInteger("SigMA", "Signal MA Duration in seconds", "Signal MA Duration in seconds", 90);
	indicator.parameters:addGroup("Stochastic Calculation")
	indicator.parameters:addBoolean("show_stoch", "Show Stochastic", "", true);
    indicator.parameters:addInteger("ssd_K", "Number of periods for %K", "The number of periods for %K.", 10, 2, 1000);
    indicator.parameters:addInteger("ssd_SD", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000);
    indicator.parameters:addInteger("ssd_D", "Number of periods for %D", "The number of periods for %D.", 5, 2, 1000);

	indicator.parameters:addGroup("Placement")
	indicator.parameters:addString("Y", " Y Placement", "", "Top")
	indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
	indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

	indicator.parameters:addString("X", " X Placement", "", "Right")
	indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
	indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
	indicator.parameters:addInteger("ShiftY", "Y axis Shift", "", 0)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("Size", "Font Size", "", 20)
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSI, cci, stoch, macd
local first
local source = nil
local X, Y
local font
local Label
local Size
local ShiftY
local show_rsi, show_cci, show_macd, show_stoch, show_signal, show_histogram;
-- Routine
function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)
	source = instance.source

	if (nameOnly) then
		return
	end
	
	cci = core.indicators:create("CCI", source, instance.parameters.cci_period);
	macd = core.indicators:create("MACD", source, instance.parameters.FMA, instance.parameters.SMA, instance.parameters.SigMA);
	stoch = core.indicators:create("SSD", source, instance.parameters.ssd_K, instance.parameters.ssd_SD, instance.parameters.ssd_D);
	show_rsi = instance.parameters.show_rsi;
	show_cci = instance.parameters.show_cci;
	show_macd = instance.parameters.show_macd;
	show_signal= instance.parameters.show_signal;
	show_histogram= instance.parameters.show_histogram;
	show_stoch = instance.parameters.show_stoch;
	Y = instance.parameters.Y
	X = instance.parameters.X

	Period = instance.parameters.Period

	ShiftY = instance.parameters.ShiftY
	Label = instance.parameters.Label
	Size = instance.parameters.Size

	RSI = core.indicators:create("RSI", source, Period)

	first = RSI.DATA:first()

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period, mode)
	RSI:update(mode)
	cci:update(mode);
	macd:update(mode);
	stoch:update(mode);
end

local init = false

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

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createFont(1, "Arial", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
		init = true
	end

    CellsBuilder:Clear(context);
    local row = 1;
	if show_rsi then
		CellsBuilder:Add(1, "RSI", Label, 1, row, 0, -1);
        CellsBuilder:Add(1, win32.formatNumber(RSI.DATA[NOW], false, source:getPrecision()), Label, 2, row, 0, -1);
        row = row + 1;
	end
	if show_cci then
		CellsBuilder:Add(1, "CCI", Label, 1, row, 0, -1);
        CellsBuilder:Add(1, win32.formatNumber(cci.DATA[NOW], false, source:getPrecision()), Label, 2, row, 0, -1);
        row = row + 1;
	end
	if show_macd then
		CellsBuilder:Add(1, "MACD.MACD", Label, 1, row, 0, -1);
		CellsBuilder:Add(1, win32.formatNumber(macd.MACD[NOW], false, source:getPrecision()), Label, 2, row, 0, -1);
        row = row + 1;
	end

	if show_signal then
		CellsBuilder:Add(1, "MACD.SIGNAL", Label, 1, row, 0, -1);
		CellsBuilder:Add(1, win32.formatNumber(macd.SIGNAL[NOW], false, source:getPrecision()), Label, 2, row, 0, -1);
        row = row + 1;
	end	
	
	if show_histogram then
		CellsBuilder:Add(1, "MACD.HISTOGRAM", Label, 1, row, 0, -1);
		CellsBuilder:Add(1, win32.formatNumber(macd.HISTOGRAM[NOW], false, source:getPrecision()), Label, 2, row, 0, -1);
        row = row + 1;
	end	
	
	if show_stoch then
		CellsBuilder:Add(1, "Stoch.K", Label, 1, row, 0, -1);
		CellsBuilder:Add(1, win32.formatNumber(stoch.K[NOW], false, source:getPrecision()), Label, 2, row, 0, -1);
        row = row + 1;
		CellsBuilder:Add(1, "Stoch.D", Label, 1, row, 0, -1);
		CellsBuilder:Add(1, win32.formatNumber(stoch.D[NOW], false, source:getPrecision()), Label, 2, row, 0, -1);
        row = row + 1;
	end
	
	CellsBuilder:Draw(iX(context, CellsBuilder:GetTotalWidth(), 0, 1), iY(context, CellsBuilder:GetTotalHeight(), 0, 1));
end

function iX(context, width)
	if X == "Left" then
		return context:left()
	else
		return context:right() - width
	end
end

function iY(context, height)
	if Y == "Top" then
		return context:top() + ShiftY
	else
    	return context:bottom()-ShiftY - height
	end
end
