-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61301
-- Id: 16426

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
function Init()
	indicator:name("Grid")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Data Entry")

	indicator.parameters:addDouble("Level1", "Level", "", 0)
	indicator.parameters:setFlag("Level1", core.FLAG_PRICE)

	indicator.parameters:addString("Method", "Method", "Method", "Grid")
	indicator.parameters:addStringAlternative("Method", "Grid", "Grid", "Grid")
	indicator.parameters:addStringAlternative("Method", "Horizontal", "Horizontal", "Horizontal")
	indicator.parameters:addStringAlternative("Method", "Vertical", "Vertical", "Vertical")

	indicator.parameters:addDate("Date1", "Date", "", 0)
	indicator.parameters:setFlag("Date1", core.FLAG_DATETIME)

	indicator.parameters:addDouble("yDelta", "Delta (in Pips)", "", 10)
	indicator.parameters:addInteger("xDelta", "Delta (in Candle)", "", 10)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("StartColor", "Start Line Color", "Start Line Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Color", "Line Color", "Line Color", core.rgb(255, 0, 0))

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Level1, Date1, xDelta, yDelta
local first
local source = nil
local StartColor, Color
local Method
-- Streams block

local BL, DL, HL, ML

-- Routine
function Prepare(nameOnly)
	StartColor = instance.parameters.StartColor
	Color = instance.parameters.Color

	Level1 = instance.parameters.Level1
	Date1 = instance.parameters.Date1
	xDelta = instance.parameters.xDelta
	yDelta = instance.parameters.yDelta
	Method = instance.parameters.Method

	source = instance.source
	first = source:first()

	instance:ownerDrawn(true)

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
end

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	-- initialize GDI objects
	if not init then
		context:createPen(1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, StartColor)

		context:createPen(3, context:convertPenStyle(instance.parameters.style), instance.parameters.width, Color)

		init = true
	end

	visible, y1 = context:pointOfPrice(Level1)

	local Index1 = ResolveData(Date1)
	if Method ~= "Vertical" and Index1 ~= -1 then
		context:drawLine(1, context:left(), y1, context:right(), y1)

		local n = 1
		while (true) do
			L1 = Level1 + (n) * (yDelta * source:pipSize())
			L2 = Level1 - (n) * (yDelta * source:pipSize())
			visible, Y1 = context:pointOfPrice(L1)
			visible, Y2 = context:pointOfPrice(L2)

			if Y1 < context:top() and Y2 > context:bottom() then
				break
			end

			context:drawLine(3, context:left(), Y1, context:right(), Y1)
			context:drawLine(3, context:left(), Y2, context:right(), Y2)

			n = n + 1
		end
	end

	if Method ~= "Horizontal" then
		x1, x = context:positionOfBar(Index1)

		context:drawLine(1, x1, context:top(), x1, context:bottom())

		n = 1
		while (true) do
			I1 = Index1 - xDelta * n
			I2 = Index1 + xDelta * n

			X1, x = context:positionOfBar(I1)
			X2, x = context:positionOfBar(I2)

			if I1 < context:firstBar() and I2 > context:lastBar() then
				break
			end

			context:drawLine(3, X1, context:top(), X1, context:bottom())
			context:drawLine(3, X2, context:top(), X2, context:bottom())

			n = n + 1
		end
	end
end

function ResolveData(Value)
	local Data = core.findDate(source, Value, false)

	return Data
end

function Update(period)
end
