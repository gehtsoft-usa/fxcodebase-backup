-- Id: 15850

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63357

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

function AddParam(id, frame)
	indicator.parameters:addGroup(id .. ". Time Frame")

	indicator.parameters:addBoolean("USE" .. id, "Use this Slot", "", true)

	indicator.parameters:addString("TF" .. id, "Time frame", "", frame)
	indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)

	indicator.parameters:addInteger("width" .. id, "Line width", "", id)
	indicator.parameters:addInteger("style" .. id, "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style" .. id, core.FLAG_LINE_STYLE)
end

function Init()
	indicator:name("Fractal Support Resistence")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addBoolean("Extend", "Extend Lines", "", false)
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

	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addDouble("Size", "Font Size", "", 10)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local UP, DN, NO
local source = nil
local TF = {}
local L = {}
local host
local offset
local weekoffset
local SourceData = {}
local loading = {}
local USE = {}
local Count = 13
local Number
local Width = {}
local Style = {}
local Extend
local Label, Size
-- Routine
function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	source = instance.source
	UP = instance.parameters.UP
	DN = instance.parameters.DN
	Extend = instance.parameters.Extend
	Label = instance.parameters.Label
	Size = instance.parameters.Size

	host = core.host
	offset = host:execute("getTradingDayOffset")
	weekoffset = host:execute("getTradingWeekOffset")

	local i

	Number = 0

	for i = 1, Count, 1 do
		USE[i] = instance.parameters:getBoolean("USE" .. i)

		if USE[i] then
			Number = Number + 1

			Style[Number] = instance.parameters:getInteger("style" .. i)
			Width[Number] = instance.parameters:getInteger("width" .. i)
			TF[Number] = instance.parameters:getString("TF" .. i)

			L[Number] = TF[Number]
		end
	end

	for i = 1, Number, 1 do
		SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), 50, 200 + i, 100 + i)
		loading[i] = true
	end

	instance:ownerDrawn(true)
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

	local Flag = false

	for j = 1, Number, 1 do
		if loading[j] then
			Flag = true
		end
	end

	if Flag then
		return
	end

	if not init then
		init = true
		for i = 1, Number, 1 do
			context:createPen(i, context:convertPenStyle(Style[i]), Width[i], UP)
			context:createPen(20 + i, context:convertPenStyle(Style[i]), Width[i], DN)
			context:createFont(50, "Arial", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
		end
	end

	for i = 1, Number, 1 do
		X = source:size() - 1
		X, x = context:positionOfBar(X)

		if not Extend then
			start, stop = core.getcandle(TF[i], SourceData[i]:date(SourceData[i]:size() - 1), offset, weekoffset)
			period1 = core.findDate(source, start, false)
			period2 = core.findDate(source, stop, false)
		else
			period1 = 0
			period2 = 0
		end

		price1, price2 = FindFractal(i)

		if price1 ~= nil and price2 ~= nil and period1 ~= -1 and period2 ~= -1 then
			visible, y1 = context:pointOfPrice(price1)
			visible, y2 = context:pointOfPrice(price2)

			if not Extend then
				x1, x = context:positionOfBar(period1)
				x2, x = context:positionOfBar(period2)
			else
				x1 = context:left()
				x2 = context:right()
			end

			context:drawLine(i, x1, y1, x2, y1)
			context:drawLine(20 + i, x1, y2, x2, y2)

			width, height = context:measureText(50, tostring(TF[i]), context.RIGHT)
			context:drawText(
				50,
				tostring(TF[i]),
				Label,
				-1,
				X + ((i - 1) * width),
				y1 - height,
				X + (i * width),
				y1,
				context.RIGHT
			)
			context:drawText(
				50,
				tostring(TF[i]),
				Label,
				-1,
				X + ((i - 1) * width),
				y2 - height,
				X + (i * width),
				y2,
				context.RIGHT
			)
		end
	end
end

function FindFractal(i)
	local price1 = nil
	local price2 = nil

	for period = SourceData[i]:size() - 1, SourceData[i]:first(), -1 do
		if price1 == nil then
			curr = SourceData[i].high[period - 2]
			if
				(curr > SourceData[i].high[period - 4] and curr > SourceData[i].high[period - 3] and
					curr > SourceData[i].high[period - 1] and
					curr > SourceData[i].high[period])
			 then
				price1 = curr
			end
		end
		if price2 == nil then
			curr = SourceData[i].low[period - 2]
			if
				(curr < SourceData[i].low[period - 4] and curr < SourceData[i].low[period - 3] and
					curr < SourceData[i].low[period - 1] and
					curr < SourceData[i].low[period])
			 then
				price2 = curr
			end
		end

		if price1 ~= nil and price2 ~= nil then
			break
		end
	end

	return price1, price2
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
		end

		if loading[j] then
			Count = Count + 1
			Flag = true
		end
	end

	if Flag then
		core.host:execute("setStatus", " Loading " .. (Number - Count) .. "/" .. Number)
	else
		instance:updateFrom(0)
		core.host:execute("setStatus", " Loaded " .. (Number - Count) .. "/" .. Number)
	end

	return core.ASYNC_REDRAW
end
