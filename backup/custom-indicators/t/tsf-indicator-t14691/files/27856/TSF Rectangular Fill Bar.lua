-- Id: 24593
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14691

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("TSF")
	indicator:description("TSF")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addString("Price", "Price Source", "", "close")
	indicator.parameters:addStringAlternative("Price", "OPEN", "", "open")
	indicator.parameters:addStringAlternative("Price", "HIGH", "", "high")
	indicator.parameters:addStringAlternative("Price", "LOW", "", "low")
	indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

	indicator.parameters:addInteger("PERIOD", "Period", "Period", 20)
	indicator.parameters:addInteger("LWMA", "LWMA Weight", "", 3)
	indicator.parameters:addInteger("MA", "MA Weight", "", 2)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("TSF_Up", "Color of Up Trend", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("TSF_Dn", "Color of Down Trend", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("FillStyle")
	indicator.parameters:addColor("Up", "Strong Color", "Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Weak Color", "Color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("Transparency", "Transparency", "Transparency", 50)

	indicator.parameters:addBoolean("TopToBottom", "Top To Bottom", "", false)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD

local first
local source = nil
local LWMA, MA
-- Streams block
local TSF = nil
local Transparency
local Signal
local TopToBottom
local Price
-- Routine
function Prepare(nameOnly)
	PERIOD = instance.parameters.PERIOD
	TopToBottom = instance.parameters.TopToBottom
	Price = instance.parameters.Price

	source = instance.source
	first = source:first() + PERIOD - 1
	LWMA = instance.parameters.LWMA
	MA = instance.parameters.MA

	local name =
		profile:id() ..
		"(" .. source:name() .. ", " .. tostring(PERIOD) .. ", " .. tostring(LWMA) .. ", " .. tostring(MA) .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Signal = instance:addInternalStream(0, 0)

	TSF = instance:addStream("TSF", core.Line, name, "TSF", instance.parameters.TSF_Up, first)
	TSF:setWidth(instance.parameters.width)
	TSF:setStyle(instance.parameters.style)

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	if period < first or not source:hasData(period) then
		return
	end

	TSF[period] =
		LWMA * mathex.lwma(source[Price], period - PERIOD + 1, period) -
		MA * mathex.avg(source[Price], period - PERIOD + 1, period)

	Signal[period] = Signal[period - 1]

	if TSF[period] > TSF[period - 1] then
		TSF:setColor(period, instance.parameters.TSF_Up)
		Signal[period] = 1
	else
		TSF:setColor(period, instance.parameters.TSF_Dn)
		Signal[period] = -1
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if not init then
		init = true
		Transparency = context:convertTransparency(instance.parameters.Transparency)

		context:createSolidBrush(1, instance.parameters.Up)
		context:createSolidBrush(2, instance.parameters.Down)
	end

	local First = math.max(source:first(), context:firstBar())
	local Last = math.min(context:lastBar(), source:size() - 1)

	local next
	local LastSignal = 0
	local y1, y2
	local Max, Min
	for period = Last, First, -1 do
		if LastSignal ~= Signal[period] then
			LastSignal = Signal[period]

			x, x1 = context:positionOfBar(period)
			next, Min, Max = Next(period)

			if next ~= 0 then
				x, _, x2 = context:positionOfBar(next)

				if TopToBottom then
					y1 = context:top()
					y2 = context:bottom()
				else
					visible, y1 = context:pointOfPrice(Max)
					visible, y2 = context:pointOfPrice(Min)
				end

				if Signal[period] == 1 then
					context:drawRectangle(-1, 1, x1, y1, x2, y2, Transparency)
				elseif Signal[period] == -1 then
					context:drawRectangle(-1, 2, x1, y1, x2, y2, Transparency)
				end
			end
		end
	end
end

function Next(period)
	local Return = 0
	local Max = 0
	local Min = 0

	for i = period, source:first(), -1 do
		if Signal[period] ~= Signal[i] then
			Return = i
			break
		end
	end

	if Return ~= 0 and period > Return then
		Min, Max = mathex.minmax(source, Return, period)
	end

	return Return, Min, Max
end
