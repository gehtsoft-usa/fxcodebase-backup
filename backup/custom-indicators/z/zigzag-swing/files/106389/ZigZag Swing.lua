-- Id: 16090
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63503

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("ZigZag Swing")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Line Selector")
	indicator.parameters:addBoolean("S1", "Show 1. Level", "", true)
	indicator.parameters:addBoolean("S2", "Show 2. Level", "", true)
	indicator.parameters:addBoolean("S3", "Show 3. Level", "", true)

	indicator.parameters:addGroup("Fractal Selector")
	indicator.parameters:addBoolean("L1", "Show 1. Level", "", true)
	indicator.parameters:addBoolean("L2", "Show 2. Level", "", true)
	indicator.parameters:addBoolean("L3", "Show 3. Level", "", true)

	indicator.parameters:addGroup("Style")

	indicator.parameters:addInteger("Level1", "1. Level Size", "", 10)
	indicator.parameters:addInteger("Level2", "2. Level Size", "", 20)
	indicator.parameters:addInteger("Level3", "3. Level Size", "", 30)

	indicator.parameters:addColor("Up", "Up Color", "", core.COLOR_UPCANDLE)
	indicator.parameters:addColor("Down", "Down Color", "", core.COLOR_DOWNCANDLE)

	indicator.parameters:addColor("C1", "1. Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("C2", "2. Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("C3", "3. Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end
local S1, S2, S3
local L1, L2, L3
local C1, C2, C3
local source
local Up, Down
local Level = {}
local FractalUp1
local FractalDown1
local FractalUp2
local FractalDown2
local FractalUp3
local FractalDown3
local xFractalUp1
local xFractalDown1
local xFractalUp2
local xFractalDown2
local xFractalUp3
local xFractalDown3
local style, width, colorUp, colorDown
function Prepare(nameOnly)
	source = instance.source
	Level[1] = instance.parameters.Level1
	Level[2] = instance.parameters.Level2
	Level[3] = instance.parameters.Level3
	L1 = instance.parameters.L1
	L2 = instance.parameters.L2
	L3 = instance.parameters.L3
	S1 = instance.parameters.S1
	S2 = instance.parameters.S2
	S3 = instance.parameters.S3
	C1 = instance.parameters.C1
	C2 = instance.parameters.C2
	C3 = instance.parameters.C3
	Up = instance.parameters.Up
	Down = instance.parameters.Down

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end
	FractalUp1 = instance:addInternalStream(source:first(), 0)
	FractalDown1 = instance:addInternalStream(source:first(), 0)
	FractalUp2 = instance:addInternalStream(source:first(), 0)
	FractalDown2 = instance:addInternalStream(source:first(), 0)
	FractalUp3 = instance:addInternalStream(source:first(), 0)
	FractalDown3 = instance:addInternalStream(source:first(), 0)

	xFractalUp1 = instance:addInternalStream(source:first(), 0)
	xFractalDown1 = instance:addInternalStream(source:first(), 0)
	xFractalUp2 = instance:addInternalStream(source:first(), 0)
	xFractalDown2 = instance:addInternalStream(source:first(), 0)
	xFractalUp3 = instance:addInternalStream(source:first(), 0)
	xFractalDown3 = instance:addInternalStream(source:first(), 0)

	style = instance.parameters.style
	width = instance.parameters.width
	colorUp = instance.parameters.colorUp
	colorDown = instance.parameters.colorDown

	instance:ownerDrawn(true)
end

--<<i>>
-->>i<<

function Update(period)
	period = period - 1

	FractalUp1[period] = 0
	FractalDown1[period] = 0
	FractalUp2[period] = 0
	FractalDown2[period] = 0
	FractalUp3[period] = 0
	FractalDown3[period] = 0

	if (period < 3) then
		return
	end

	--1. Stage
	local curr = source.high[period]

	if curr > source.high[period - 1] and curr > source.high[period + 1] then
		FractalUp1[period] = 1
	end

	curr = source.low[period]
	if curr < source.low[period - 1] and curr < source.low[period + 1] then
		FractalDown1[period] = -1
	end

	if period < source:size() - 2 then
		return
	end

	--2. stage
	for periodx = source:first(), source:size() - 1, 1 do
		if FractalUp1[periodx] == 1 then
			T1, T2 = Top(FractalUp1, periodx)
			if T1 ~= 0 and T2 ~= 0 then
				if source.high[periodx] > source.high[T1] and source.high[periodx] > source.high[T2] then
					FractalUp2[periodx] = 2
				end
			end
		end
		if FractalDown1[periodx] == -1 then
			B1, B2 = Bottom(FractalDown1, periodx)

			if B1 ~= 0 and B2 ~= 0 then
				if source.low[periodx] < source.low[B1] and source.low[periodx] < source.low[B2] then
					FractalDown2[periodx] = -2
				end
			end
		end
	end

	-----3. stage

	for periodx = source:first(), source:size() - 1, 1 do
		if FractalUp2[periodx] == 2 then
			T1, T2 = Top(FractalUp2, periodx)
			if T1 ~= 0 and T2 ~= 0 then
				if source.high[periodx] > source.high[T1] and source.high[periodx] > source.high[T2] then
					FractalUp3[periodx] = 3
				end
			end
		end
		if FractalDown2[periodx] == -2 then
			B1, B2 = Bottom(FractalDown2, periodx)

			if B1 ~= 0 and B2 ~= 0 then
				if source.low[periodx] < source.low[B1] and source.low[periodx] < source.low[B2] then
					FractalDown3[periodx] = -3
				end
			end
		end
	end

	-----Filter
	for period = source:first(), source:size() - 1, 1 do
		Filter1(period)
		Filter2(period)
		Filter3(period)
	end
end

function Filter3(Start)
	if S3 then
		if FractalDown3[Start] ~= 0 then
			xFractalDown3[Start] = -3

			for period = Start, source:first(), -1 do
				if FractalUp3[period] ~= 0 then
					break
				end
				if FractalDown3[period] ~= 0 and source.low[period] < source.low[Start] then
					xFractalDown3[Start] = 0
				end

				if FractalDown3[period] ~= 0 and source.low[period] > source.low[Start] then
					xFractalDown3[period] = 0
				end
			end
		end

		if FractalUp3[Start] ~= 0 then
			xFractalUp3[Start] = 3

			for period = Start, source:first(), -1 do
				if FractalDown3[period] ~= 0 then
					break
				end
				if FractalUp3[period] ~= 0 and source.high[period] > source.high[Start] then
					xFractalUp3[Start] = 0
				end

				if FractalUp3[period] ~= 0 and source.high[period] < source.high[Start] then
					xFractalUp3[period] = 0
				end
			end
		end
	end
end

function Filter2(Start)
	if S2 then
		if FractalDown2[Start] ~= 0 then
			xFractalDown2[Start] = -2

			for period = Start, source:first(), -1 do
				if FractalUp2[period] ~= 0 then
					break
				end
				if FractalDown2[period] ~= 0 and source.low[period] < source.low[Start] then
					xFractalDown2[Start] = 0
				end

				if FractalDown2[period] ~= 0 and source.low[period] > source.low[Start] then
					xFractalDown2[period] = 0
				end
			end
		end

		if FractalUp2[Start] ~= 0 then
			xFractalUp2[Start] = 2

			for period = Start, source:first(), -1 do
				if FractalDown2[period] ~= 0 then
					break
				end
				if FractalUp2[period] ~= 0 and source.high[period] > source.high[Start] then
					xFractalUp2[Start] = 0
				end

				if FractalUp2[period] ~= 0 and source.high[period] < source.high[Start] then
					xFractalUp2[period] = 0
				end
			end
		end
	end
end

function Filter1(Start)
	if S1 then
		if FractalDown1[Start] ~= 0 then
			xFractalDown1[Start] = -1

			for period = Start, source:first(), -1 do
				if FractalUp1[period] ~= 0 then
					break
				end
				if FractalDown1[period] ~= 0 and source.low[period] < source.low[Start] then
					xFractalDown1[Start] = 0
				end

				if FractalDown1[period] ~= 0 and source.low[period] > source.low[Start] then
					xFractalDown1[period] = 0
				end
			end
		end

		if FractalUp1[Start] ~= 0 then
			xFractalUp1[Start] = 1

			for period = Start, source:first(), -1 do
				if FractalDown1[period] ~= 0 then
					break
				end
				if FractalUp1[period] ~= 0 and source.high[period] > source.high[Start] then
					xFractalUp1[Start] = 0
				end

				if FractalUp1[period] ~= 0 and source.high[period] < source.high[Start] then
					xFractalUp1[period] = 0
				end
			end
		end
	end
end

function Top(Data, period)
	local D1 = 0
	local D2 = 0

	for i = period + 1, source:size() - 1, 1 do
		if Data[i] ~= 0 then
			D2 = i
			break
		end
	end

	for i = period - 1, source:first(), -1 do
		if Data[i] ~= 0 then
			D1 = i
			break
		end
	end

	return D1, D2
end

function Bottom(Data, period)
	local D1 = 0
	local D2 = 0

	for i = period + 1, source:size() - 1, 1 do
		if Data[i] ~= 0 then
			D2 = i
			break
		end
	end

	for i = period - 1, source:first(), -1 do
		if Data[i] ~= 0 then
			D1 = i
			break
		end
	end

	return D1, D2
end

function TopX3(period)
	local D1 = 0
	local D2 = period

	for i = period - 1, source:first(), -1 do
		if xFractalUp3[i] ~= 0 then
			if D1 == 0 then
				D1 = i
			elseif D1 ~= 0 and source.high[i] > source.high[D1] then
				D1 = i
			end

			if xFractalUp3[i] ~= 0 then
				break
			end
		end
	end

	return D1, D2
end

function BottomX3(period)
	local D1 = 0
	local D2 = period

	for i = period - 1, source:first(), -1 do
		if xFractalDown3[i] ~= 0 then
			if D1 == 0 then
				D1 = i
			elseif D1 ~= 0 and source.low[i] < source.low[D1] then
				D1 = i
			end
			if xFractalDown3[i] ~= 0 then
				break
			end
		end
	end

	return D1, D2
end

--2--

function TopX2(period)
	local D1 = 0
	local D2 = period

	for i = period - 1, source:first(), -1 do
		if xFractalUp2[i] ~= 0 then
			if D1 == 0 then
				D1 = i
			elseif D1 ~= 0 and source.high[i] > source.high[D1] then
				D1 = i
			end

			if xFractalUp2[i] ~= 0 then
				break
			end
		end
	end

	return D1, D2
end

function BottomX2(period)
	local D1 = 0
	local D2 = period

	for i = period - 1, source:first(), -1 do
		if xFractalDown2[i] ~= 0 then
			if D1 == 0 then
				D1 = i
			elseif D1 ~= 0 and source.low[i] < source.low[D1] then
				D1 = i
			end
			if xFractalDown2[i] ~= 0 then
				break
			end
		end
	end

	return D1, D2
end

function TopX1(period)
	local D1 = 0
	local D2 = period

	for i = period - 1, source:first(), -1 do
		if xFractalUp1[i] ~= 0 then
			if D1 == 0 then
				D1 = i
			elseif D1 ~= 0 and source.high[i] > source.high[D1] then
				D1 = i
			end

			if xFractalUp1[i] ~= 0 then
				break
			end
		end
	end

	return D1, D2
end

function BottomX1(period)
	local D1 = 0
	local D2 = period

	for i = period - 1, source:first(), -1 do
		if xFractalDown1[i] ~= 0 then
			if D1 == 0 then
				D1 = i
			elseif D1 ~= 0 and source.low[i] < source.low[D1] then
				D1 = i
			end
			if xFractalDown1[i] ~= 0 then
				break
			end
		end
	end

	return D1, D2
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		init = true
		context:createFont(1, "Wingdings", Level[1], Level[1], 0)
		context:createFont(2, "Wingdings", Level[2], Level[2], 0)
		context:createFont(3, "Wingdings", Level[3], Level[3], 0)
		context:createPen(4, context:convertPenStyle(style), context:pointsToPixels(width), C1)
		context:createPen(5, context:convertPenStyle(style), context:pointsToPixels(width), C2)
		context:createPen(6, context:convertPenStyle(style), context:pointsToPixels(width), C3)
	end

	for period = math.max(source:first(), context:firstBar()), math.min(source:size() - 1, context:lastBar()), 1 do
		text = nil

		if (FractalUp1[period] > 0) or (FractalUp2[period] > 0) or (FractalUp3[period] > 0) then
			text = "\217"
			color = Up
		else
			text = nil
		end

		Size = math.abs(math.max(FractalUp1[period], FractalUp2[period], FractalUp3[period]))
		if text ~= nil and ((Size == 1 and L1) or (Size == 2 and L2) or (Size == 3 and L3)) then
			x, x1, x2 = context:positionOfBar(period)
			width, height = context:measureText(Size, text, 0)
			visible, y = context:pointOfPrice(source.high[period])
			context:drawText(Size, text, color, -1, x - width / 2, y - width, x + width / 2, y, 0)
		end

		text = nil

		if (FractalDown1[period] < 0) or (FractalDown2[period] < 0) or (FractalDown3[period] < 0) then
			text = "\218"
			color = Down
		else
			text = nil
		end

		X2, x = context:positionOfBar(period)

		Size = math.abs(math.min(FractalDown1[period], FractalDown2[period], FractalDown3[period]))
		if text ~= nil and ((Size == 1 and L1) or (Size == 2 and L2) or (Size == 3 and L3)) then
			width, height = context:measureText(Size, text, 0)
			visible, y = context:pointOfPrice(source.low[period])
			context:drawText(Size, text, color, -1, X2 - width / 2, y, X2 + width / 2, y + width, 0)
		end

		if S3 then
			if xFractalUp3[period] > 0 then
				B1, B2 = BottomX3(period)
				X1, x = context:positionOfBar(B1)
				X2, x = context:positionOfBar(B2)
				visible, y1 = context:pointOfPrice(source.low[B1])
				visible, y2 = context:pointOfPrice(source.high[B2])
				context:drawLine(6, X1, y1, X2, y2)
			end
			if xFractalDown3[period] < 0 then
				T1, T2 = TopX3(period)
				X1, x = context:positionOfBar(T1)
				X2, x = context:positionOfBar(T2)
				visible, y1 = context:pointOfPrice(source.high[T1])
				visible, y2 = context:pointOfPrice(source.low[T2])
				context:drawLine(6, X1, y1, X2, y2)
			end
		end

		if S2 then
			if xFractalUp2[period] > 0 then
				B1, B2 = BottomX2(period)
				X1, x = context:positionOfBar(B1)
				X2, x = context:positionOfBar(B2)
				visible, y1 = context:pointOfPrice(source.low[B1])
				visible, y2 = context:pointOfPrice(source.high[B2])
				context:drawLine(5, X1, y1, X2, y2)
			end
			if xFractalDown2[period] < 0 then
				T1, T2 = TopX2(period)
				X1, x = context:positionOfBar(T1)
				X2, x = context:positionOfBar(T2)
				visible, y1 = context:pointOfPrice(source.high[T1])
				visible, y2 = context:pointOfPrice(source.low[T2])
				context:drawLine(5, X1, y1, X2, y2)
			end
		end

		if S1 then
			if xFractalUp1[period] > 0 then
				B1, B2 = BottomX1(period)
				X1, x = context:positionOfBar(B1)
				X2, x = context:positionOfBar(B2)
				visible, y1 = context:pointOfPrice(source.low[B1])
				visible, y2 = context:pointOfPrice(source.high[B2])
				context:drawLine(4, X1, y1, X2, y2)
			end
			if xFractalDown1[period] < 0 then
				T1, T2 = TopX1(period)
				X1, x = context:positionOfBar(T1)
				X2, x = context:positionOfBar(T2)
				visible, y1 = context:pointOfPrice(source.high[T1])
				visible, y2 = context:pointOfPrice(source.low[T2])
				context:drawLine(4, X1, y1, X2, y2)
			end
		end
	end
end
