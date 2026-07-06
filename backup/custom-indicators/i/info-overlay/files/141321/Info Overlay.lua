-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15542

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

local Label = {
	"Account ID",
	"Account Name",
	"Balance",
	"Equity",
	"Day Profit/Loss",
	"Used Margin",
	"UsableMargin",
	"Gross Profit/Loss",
	"Instrument",
	"Pip Cost",
	"MMR",
	"ContractSize",
	"Rollover Short",
	"Rollover Long",
	"Ask",
	"Bid",
	"Spread",
	"Day Hi",
	"Day Low"
}

function Init()
	indicator:name("Info Overlay")
	indicator:description("Info Overlay")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addString("Account", "Account to trade", "", "")
	indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT)

	indicator.parameters:addInteger("Size", "Font Size", "", 10)
	indicator.parameters:addColor("color", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addColor("background", "Background Color", "", core.rgb(225, 225, 225))
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100)

	indicator.parameters:addString("location", "Location", "", "TL");
	indicator.parameters:addStringAlternative("location", "Top-left", "", "TL");
	indicator.parameters:addStringAlternative("location", "Top-tight", "", "TR");
	indicator.parameters:addStringAlternative("location", "Bottom-left", "", "BL");
	indicator.parameters:addStringAlternative("location", "Bottom-right", "", "BR");

	local i
	indicator.parameters:addGroup("Account Info")
	for i = 1, 8, 1 do
		indicator.parameters:addBoolean("On" .. i, "Show" .. Label[i], "", true)
	end

	indicator.parameters:addGroup("Instrument Info")
	for i = 9, 19, 1 do
		indicator.parameters:addBoolean("On" .. i, "Show" .. Label[i], "", true)
	end
end

local Label = {
	"Account ID",
	"Account Name",
	"Balance",
	"Equity",
	"Day Profit/Loss",
	"Used Margin",
	"UsableMargin",
	"Gross Profit/Loss",
	"Instrument",
	"Pip Cost",
	"MMR",
	"ContractSize",
	"Rollover Short",
	"Rollover Long",
	"Ask",
	"Bid",
	"Spread",
	"Day Hi",
	"Day Low"
}

local Account
local ON = {}
local first
local source = nil
local Data = {}
local Size
local color, background
local transparency
local location
-- Routine
function Prepare(nameOnly)
	Size = instance.parameters.Size

	location = instance.parameters.location;
	Account = instance.parameters.Account
	source = instance.source
	first = source:first()
	color = instance.parameters.color
	background = instance.parameters.background

	local i
	for i = 1, 19, 1 do
		ON[i] = instance.parameters:getBoolean("On" .. i)
	end

	transparency = instance.parameters.transparency
	if transparency == 100 then
		transparency = 255
	elseif transparency == 0 then
		transparency = 0
	else
		transparency = math.floor(255 * (transparency / 100.0) + 0.5)
	end

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Account) .. ")"
	instance:name(name)

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false
local Cell

-- Cells builder v.1.3
local CellsBuilder = {}
CellsBuilder.GapCoeff = 1.2
function CellsBuilder:Clear(context)
	self.Columns = {}
	self.RowHeights = {}
	self.Context = context
end
function CellsBuilder:Add(font, text, color, column, row, mode, backgound)
	if self.Columns[column] == nil then
		self.Columns[column] = {}
		self.Columns[column].Rows = {}
		self.Columns[column].MaxWidth = 0
		self.Columns[column].MaxHeight = 0
		self.Columns[column].MaxRowIndex = 0
	end
	local cell = {}
	cell.Text = text
	cell.Font = font
	cell.Color = color
	local w, h = self.Context:measureText(font, text, mode)
	cell.Width = w
	cell.Height = h
	cell.Mode = mode
	cell.Background = backgound
	self.Columns[column].Rows[row] = cell
	if self.Columns[column].MaxRowIndex < row then
		self.Columns[column].MaxRowIndex = row
	end
	if self.Columns[column].MaxWidth < w then
		self.Columns[column].MaxWidth = w
	end
	if self.RowHeights[row] == nil or self.RowHeights[row] < h then
		self.RowHeights[row] = h
	end
end
function CellsBuilder:GetTotalWidth()
	local width = 0
	for columnIndex, column in ipairs(self.Columns) do
		width = width + column.MaxWidth * self.GapCoeff
	end
	return width
end
function CellsBuilder:GetTotalHeight()
	local height = 0
	for i = 0, self.Columns[1].MaxRowIndex do
		if self.RowHeights[i] ~= nil then
			height = height + self.RowHeights[i] * self.GapCoeff
		end
	end
	return height
end
function CellsBuilder:Draw(x, y)
	local total_width = 0
	for columnIndex, column in ipairs(self.Columns) do
		local total_height = 0
		for i = 0, column.MaxRowIndex do
			local cell = column.Rows[i]
			if cell ~= nil then
				local background = -1
				if cell.Background ~= nil then
					background = cell.Background
				end
				self.Context:drawText(
					cell.Font,
					cell.Text,
					cell.Color,
					background,
					x + total_width,
					y + total_height,
					x + total_width + column.MaxWidth,
					y + total_height + cell.Height,
					cell.Mode
				)
			end
			if self.RowHeights[i] ~= nil then
				total_height = total_height + self.RowHeights[i] * self.GapCoeff
			end
		end
		total_width = total_width + column.MaxWidth * self.GapCoeff
	end
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end
	if not init then
		Cell = context:pointsToPixels(Size)
		context:createFont(1, "Arial", 0, Cell, 0)
		context:createPen(2, 1, 1, background)
		context:createSolidBrush(3, background)
		init = true
	end
	CellsBuilder:Clear(context)

	Data[9] = core.host:findTable("offers"):find("Instrument", source:instrument()).Instrument
	Data[10] = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost
	Data[11] = core.host:findTable("offers"):find("Instrument", source:instrument()).MMR
	Data[12] = core.host:findTable("offers"):find("Instrument", source:instrument()).ContractSize
	Data[13] = core.host:findTable("offers"):find("Instrument", source:instrument()).IntrS
	Data[14] = core.host:findTable("offers"):find("Instrument", source:instrument()).IntrB

	Data[15] = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask
	Data[16] = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid
	Data[17] = Data[15] - Data[16]
	Data[18] = core.host:findTable("offers"):find("Instrument", source:instrument()).Hi
	Data[19] = core.host:findTable("offers"):find("Instrument", source:instrument()).Low

	Data[1] = core.host:findTable("accounts"):find("AccountID", Account).AccountID
	Data[2] = core.host:findTable("accounts"):find("AccountID", Account).AccountName
	Data[3] = core.host:findTable("accounts"):find("AccountID", Account).Balance
	Data[4] = core.host:findTable("accounts"):find("AccountID", Account).Equity
	Data[5] = core.host:findTable("accounts"):find("AccountID", Account).DayPL
	Data[6] = core.host:findTable("accounts"):find("AccountID", Account).UsedMargin
	Data[7] = core.host:findTable("accounts"):find("AccountID", Account).UsableMargin
	Data[8] = core.host:findTable("accounts"):find("AccountID", Account).GrossPL

	local i
	local Text
	local row = 1
	for i = 1, 19, 1 do
		if ON[i] then
			if i == 1 or i == 2 or i == 9 then
				Text = Data[i]
			elseif i == 3 or i == 4 or i == 5 then
				Text = win32.formatNumber(Data[i], false, 2)
			else
				Text = win32.formatNumber(Data[i], false, 5)
			end
			CellsBuilder:Add(1, Label[i] .. " : ", color, 1, row, context.RIGHT)
			CellsBuilder:Add(1, tostring(Text), color, 2, row, context.LEFT)
			row = row + 1
		end
	end
	local x_start
	local y_start
	if location == "TR" then
		x_start = context:right() - CellsBuilder:GetTotalWidth()
		y_start = context:top()
	elseif location == "BL" then
		x_start = context:left()
		y_start = context:bottom() - CellsBuilder:GetTotalHeight()
	elseif location == "BR" then
		x_start = context:right() - CellsBuilder:GetTotalWidth()
		y_start = context:bottom() - CellsBuilder:GetTotalHeight()
	else
		x_start = context:left()
		y_start = context:top()
	end
	context:drawRectangle(2, 3, x_start, y_start, x_start + CellsBuilder:GetTotalWidth(), y_start + CellsBuilder:GetTotalHeight(), transparency)
	CellsBuilder:Draw(x_start, y_start)
end
