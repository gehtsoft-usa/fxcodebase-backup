-- Id: 22398

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66704

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

-- Indicator profile initialization routine
function Init()
	indicator:name("ZigZag Pivot")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger(
		"Depth",
		"Depth",
		"the minimal amount of bars where there will not be the second maximum",
		12
	)
	indicator.parameters:addInteger(
		"Deviation",
		"Deviation",
		"Distance in pips to eliminate the second maximum in the last Depth periods",
		5
	)
	indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3)

	indicator.parameters:addGroup("Levels")

	indicator.parameters:addDouble("Level1", "1. Level", "1.Level", -0.272)
	indicator.parameters:addDouble("Level2", "2. Level", "2.Level", 0)
	indicator.parameters:addDouble("Level3", "3. Level", "3.Level", 0.236)
	indicator.parameters:addDouble("Level4", "4. Level", "4.Level", 0.382)
	indicator.parameters:addDouble("Level5", "5. Level", "5.Level", 0.618)
	indicator.parameters:addDouble("Level6", "6. Level", "6.Level", 0.764)
	indicator.parameters:addDouble("Level7", "7. Level", "7.Level", 1)
	indicator.parameters:addDouble("Level8", "8. Level", "8.Level", 1.272)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color1", "1. Line color", "Line color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_DASH)
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color2", "2. Line color", "Line color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color3", "3. Line color", "Line color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color4", "4. Line color", "Line color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color5", "5. Line color", "Line color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color6", "6. Line color", "Line color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color7", "7. Line color", "Line color", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width7", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style7", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE)

	indicator.parameters:addColor("color8", "8. Line color", "Line color", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width8", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style8", "Line style", "", core.LINE_DASH)
	indicator.parameters:setFlag("style8", core.FLAG_LINE_STYLE)

	indicator.parameters:addInteger("TextSize", "Text Size", "", 15)
	indicator.parameters:addColor("Label", "Label Color", "Label Color", core.COLOR_LABEL)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth
local Deviation
local Backstep
local ZigZag

local first
local source = nil

-- Streams block

local P1, P2

local Levels = {}
local style = {}
local width = {}
local color = {}
-- Routine
function Prepare(nameOnly)
	Depth = instance.parameters.Depth
	Deviation = instance.parameters.Deviation
	Backstep = instance.parameters.Backstep
	source = instance.source
	first = source:first()

	Levels[1] = instance.parameters.Level1
	Levels[2] = instance.parameters.Level2
	Levels[3] = instance.parameters.Level3
	Levels[4] = instance.parameters.Level4
	Levels[5] = instance.parameters.Level5
	Levels[6] = instance.parameters.Level6
	Levels[7] = instance.parameters.Level7
	Levels[8] = instance.parameters.Level8

	style[1] = instance.parameters.style1
	style[2] = instance.parameters.style2
	style[3] = instance.parameters.style3
	style[4] = instance.parameters.style4
	style[5] = instance.parameters.style5
	style[6] = instance.parameters.style6
	style[7] = instance.parameters.style7
	style[8] = instance.parameters.style8

	width[1] = instance.parameters.width1
	width[2] = instance.parameters.width2
	width[3] = instance.parameters.width3
	width[4] = instance.parameters.width4
	width[5] = instance.parameters.width5
	width[6] = instance.parameters.width6
	width[7] = instance.parameters.width7
	width[8] = instance.parameters.width8

	color[1] = instance.parameters.color1
	color[2] = instance.parameters.color2
	color[3] = instance.parameters.color3
	color[4] = instance.parameters.color4
	color[5] = instance.parameters.color5
	color[6] = instance.parameters.color6
	color[7] = instance.parameters.color7
	color[8] = instance.parameters.color8

	local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	P1 = 0
	P2 = 0

	ZigZag = core.indicators:create("ZIGZAG", source, Depth, Deviation, Backstep)

	instance:ownerDrawn(true)
end

function Update(period, mode)
	if period < source:size() - 1 then
		return
	end

	ZigZag:update(core.UpdateAll)

	P1 = 0
	P2 = 0

	FindLast(period)
end

function FindLast(period)
	for i = period, first, -1 do
		if P2 == 0 and ZigZag.DATA:hasData(i) then
			P2 = i
		elseif
			P1 == 0 and ZigZag.DATA:hasData(i + 1) and
				((ZigZag.DATA[i] < ZigZag.DATA[i + 1] and ZigZag.DATA[i] < ZigZag.DATA[i - 1]) or
					(ZigZag.DATA[i] > ZigZag.DATA[i + 1] and ZigZag.DATA[i] > ZigZag.DATA[i - 1]))
		 then
			P1 = i
		end

		if P2 ~= 0 and P1 ~= 0 then
			break
		end
	end
end

local Init = true
function Draw(stage, context)
	if stage ~= 2 or P1 == 0 or P2 == 0 then
		return
	end

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if Init then
		context:createFont(
			10,
			"Arial",
			context:pixelsToPoints(instance.parameters.TextSize),
			context:pixelsToPoints(instance.parameters.TextSize),
			0
		)
		for i = 1, 8, 1 do
			context:createPen(i, style[i], context:convertPenStyle(width[i]), color[i])
		end
		Init = false
	end

	x1, x = context:positionOfBar(P1)
	x2, x = context:positionOfBar(P2)
	x3, x = context:positionOfBar(source:size() - 1)

	visible, min = context:pointOfPrice(math.min(ZigZag.DATA[P1], ZigZag.DATA[P2]))
	visible, max = context:pointOfPrice(math.max(ZigZag.DATA[P1], ZigZag.DATA[P2]))
	local Delta
	local Value
	local Text
	for i = 1, 8, 1 do
		Delta = Levels[i] * (max - min)
		if ZigZag.DATA[P1] < ZigZag.DATA[P2] then
			Value = context:priceOfPoint(min + Delta)
			context:drawLine(i, x1, min + Delta, x3, min + Delta)
			Text = win32.formatNumber(Value, false, source:getPrecision())
			width, height = context:measureText(10, Text .. " - " .. Levels[i], 0)
			context:drawText(
				10,
				Text .. " - " .. Levels[i],
				instance.parameters.Label,
				-1,
				x3,
				min + Delta - height,
				x3 + width,
				min + Delta,
				0
			)
		else
			Value = context:priceOfPoint(max - Delta)
			context:drawLine(i, x1, max - Delta, x3, max - Delta)
			Text = win32.formatNumber(Value, false, source:getPrecision())
			width, height = context:measureText(10, Text .. " - " .. Levels[i], 0)
			context:drawText(
				10,
				Text .. " - " .. Levels[i],
				instance.parameters.Label,
				-1,
				x3,
				max - Delta - height,
				x3 + width,
				max - Delta,
				0
			)
		end
	end
end
