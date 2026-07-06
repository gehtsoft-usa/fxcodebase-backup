-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65172

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Free Capital Indicator")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addString("Account", "Account to trade", "", "")
	indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT)

	indicator.parameters:addBoolean("Use_GrossPL", "Use Gross PL", "", true)
	indicator.parameters:addBoolean("Use_UsedMargin", "Use Used Margin", "", true)
	indicator.parameters:addBoolean("Use_Stop", "Use Stop Level", "", true)

	indicator.parameters:addGroup("Placement")
	indicator.parameters:addString("Y", " Y Placement", "", "Top")
	indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
	indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

	indicator.parameters:addString("X", " X Placement", "", "Left")
	indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
	indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
	indicator.parameters:addInteger("ShiftY", "Shift", "", 0)

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

local first
local source = nil
local X, Y
local font
local Label
local Size
local ShiftY
local Free_Capital = 0
local Account

local Use_GrossPL
local Use_UsedMargin
local Use_Stop
-- Routine

function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Y = instance.parameters.Y
	X = instance.parameters.X
	ShiftY = instance.parameters.ShiftY
	Label = instance.parameters.Label
	Size = instance.parameters.Size

	Account = instance.parameters.Account
	Use_GrossPL = instance.parameters.Use_GrossPL
	Use_UsedMargin = instance.parameters.Use_UsedMargin
	Use_Stop = instance.parameters.Use_Stop

	source = instance.source
	first = source:first()

	instance:ownerDrawn(true)

	core.host:execute("setTimer", 1, 1)
end

function ReleaseInstance()
	core.host:execute("killTimer", 1)
end

function AsyncOperationFinished(cookie)
	if cookie == 1 then
		Free_Capital = 0

		--//Accounts//
		-- Balance
		--GrossPL
		--Equity
		-- UsableMargin

		local Balance = core.host:findTable("accounts"):find("AccountID", Account).Balance
		local UsedMargin = core.host:findTable("accounts"):find("AccountID", Account).UsedMargin
		local GrossPL = core.host:findTable("accounts"):find("AccountID", Account).GrossPL
		local Stop = Stop_Calculation()

		Free_Capital = Free_Capital + Balance
		if Use_UsedMargin then
			Free_Capital = Free_Capital - UsedMargin
		end
		if Use_GrossPL then
			Free_Capital = Free_Capital + GrossPL
		end

		if Use_Stop then
			if Stop == -1 then
				Free_Capital = 0
			else
				Free_Capital = Free_Capital - Stop
			end
		end
	end
end

function Stop_Calculation()
	local Stop = 0
	local enum, row
	local Huge = false
	enum = core.host:findTable("trades"):enumerator()
	row = enum:next()

	local PipCost, Point

	while row ~= nil do
		if row.AccountID == Account then
			PipCost = core.host:findTable("offers"):find("Instrument", row.Instrument).PipCost
			Point = core.host:findTable("offers"):find("Instrument", row.Instrument).PointSize
            local base_size = core.host:execute("getTradingProperty", "baseUnitSize", row.Instrument, Account);
			local sign = (row.BS == "S" and -1 or 1)
			Stop = Stop + (row.Lot / base_size) * (sign * (row.Open - row.Stop) / Point) * PipCost
			if row.Stop == 0 then
				Huge = true
			end
		end

		row = enum:next()
	end

	if Huge then
		Stop = -1
	end

	return Stop
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createFont(1, "Arial", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
		init = true
	end

	local Text1 = "Free Capital : " .. win32.formatNumber(Free_Capital, false, 2)

	local i = 1
	width, height = context:measureText(1, Text1, 0)
	context:drawText(
		1,
		Text1,
		Label,
		-1,
		iX(context, width, 0, 1),
		iY(context, height, i, 0),
		iX(context, width, 0, 2),
		iY(context, height, i, 1),
		0
	)
end

function iX(context, width, Shift, x)
	if X == "Left" then
		return context:left() + Shift * width + width * (x - 1)
	else
		return context:right() - width * Shift - width * (1 - (x - 1))
	end
end

function iY(context, height, Index, Line)
	if Y == "Top" then
		return context:top() + Index * height + ShiftY * height + Line * height
	else
		if Line == 1 then
			return context:bottom() - (Index + 1) * height - ShiftY * height + height
		else
			return context:bottom() - (Index + 1) * height - ShiftY * height
		end
	end
end
