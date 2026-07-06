-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25151
-- Id: 7791

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function AddParam(id, frame)
	indicator.parameters:addGroup(id .. ". Time Frame")

	indicator.parameters:addBoolean("USE" .. id, "Use this Slot", "", true)

	indicator.parameters:addString("TF" .. id, "Time frame", "", frame)
	indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)

	indicator.parameters:addString("Pair" .. id, "Pair", "", "EUR/USD")
	indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end

function Init()
	indicator:name("MTF MCP Multimeter List")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addBoolean("Chart", "Use Chart Price Source", "", true)

	AddParam(1, "m1")
	AddParam(2, "m5")
	AddParam(3, "m15")
	AddParam(4, "m30")
	AddParam(5, "H1")
	AddParam(6, "H2")
	AddParam(7, "H3")
	AddParam(8, "H4")
	AddParam(9, "H6")
	AddParam(10, "H8")
	AddParam(11, "D1")
	AddParam(12, "W1")
	AddParam(13, "M1")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0))
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90)
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 50)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local UP, DN, NO
local source = nil
local TF = {}
local Pair = {}
local L = {}
local host
local offset
local weekoffset
local SourceData = {}
local loading = {}
local Size
local USE = {}
local Count = 13
local Number
local Chart
local Label
local Shift

-- Routine
function Prepare(nameOnly)
	Chart = instance.parameters.Chart
	source = instance.source
	UP = instance.parameters.UP
	DN = instance.parameters.DN
	NO = instance.parameters.NO

	Label = instance.parameters.Label
	Shift = instance.parameters.Shift
	Size = instance.parameters.Size

	host = core.host
	offset = host:execute("getTradingDayOffset")
	weekoffset = host:execute("getTradingWeekOffset")

	local i
	local name = profile:id() .. "(" .. source:name()

	Number = 0

	for i = 1, Count, 1 do
		USE[i] = instance.parameters:getBoolean("USE" .. i)

		if USE[i] then
			Number = Number + 1

			if Chart then
				Pair[Number] = source:name()
			else
				Pair[Number] = instance.parameters:getString("Pair" .. i)
			end

			TF[Number] = instance.parameters:getString("TF" .. i)

			L[Number] = TF[Number] .. ", " .. Pair[Number]
			name = name .. ", " .. "(" .. TF[Number] .. ", " .. Pair[Number] .. ")"
		end
	end
	name = name .. ")"
	instance:name(name)
	if nameOnly then
		return;
	end

	for i = 1, Number, 1 do
		if (TF[i] == source:barSize() and Pair[i] == source:name()) then
			SourceData[i] = source
			loading[i] = false
		else
			SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(), 2, 200 + i, 100 + i)
			loading[i] = true
		end
	end

	instance:ownerDrawn(true)
end

function Initialization(id, period)
	local Candle
	Candle = core.getcandle(TF[id], source:date(period), offset, weekoffset)

	if loading[id] or SourceData[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local p = core.findDate(SourceData[id], Candle, false)

	-- candle is not found
	if p < 0 then
		return false
	else
		return p
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	local Flag = false

	for j = 1, Number, 1 do
		if loading[j] then
			Flag = true
		end
	end

	if Flag then
		return
	end

	local xCell = (context:right() - context:left()) / (Number + 1)
	local yCell = (context:bottom() - context:top()) / 15

	for i = 1, Number, 1 do
		local Color

		if SourceData[i].close[SourceData[i].close:size() - 1] > SourceData[i].close[SourceData[i].close:size() - 2] then
			Color = UP
		elseif SourceData[i].close[SourceData[i].close:size() - 1] < SourceData[i].close[SourceData[i].close:size() - 2] then
			Color = DN
		else
			Color = NO
		end

		context:createFont(1, "Arial", (xCell / 10) * (Size / 100), yCell * (Size / 100), 0)

		width, height = context:measureText(1, tostring(Pair[i]), 0)
		context:drawText(
			1,
			tostring(Pair[i]),
			Label,
			-1,
			context:left() + (i - 1) * xCell,
			context:top() + Shift + yCell / 4,
			context:left() + (i - 1) * xCell + width,
			context:top() + Shift + yCell / 4 + height,
			0
		)

		width, height = context:measureText(1, tostring(TF[i]), 0)
		context:drawText(
			1,
			tostring(TF[i]),
			Color,
			-1,
			context:left() + (i - 1) * xCell,
			context:top() + Shift + yCell * (5 / 4),
			context:left() + (i - 1) * xCell + width,
			context:top() + Shift + yCell * (5 / 4) + height,
			0
		)
	end
end

-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)
	local j
	local Flag = false
	local Count = 0

	for j = 1, Number, 1 do
		if cookie == (100 + j) then
			loading[j] = true
		elseif cookie == (200 + j) then
			loading[j] = false
			instance:updateFrom(0)
		end

		if loading[j] then
			Count = Count + 1
			Flag = true
		end
	end

	if Flag then
		core.host:execute("setStatus", " Loading " .. (Number - Count) .. "/" .. Number)
	else
		core.host:execute("setStatus", " Loaded " .. (Number - Count) .. "/" .. Number)
	end

	return core.ASYNC_REDRAW
end
