-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64657
-- Id: 18149

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

function Init()
	indicator:name("Night Volume Overlay")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Start", "Session Start", "", 0, 0, 24)
	indicator.parameters:addDouble("Period", "Session Period", "", 8.5, 0, 24)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255))

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addInteger("extension", "Extension Line style", "", core.LINE_DOT)
	indicator.parameters:setFlag("extension", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first
local source = nil
local Volume
local Period
local Hour
local Start

-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	Start = instance.parameters.Start

	source = instance.source
	first = source:first()
	Hour = 1 / 24

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	Volume = instance:addInternalStream(0, 0)

	instance:ownerDrawn(true)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.color
		)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.extension),
			instance.parameters.width,
			instance.parameters.color
		)
		init = true
	end

	local First = context:firstBar()
	local Last = context:lastBar()

	local min = nil
	local max = nil
	local p1 = nil
	local p2 = nil

	for period = First, Last, 1 do
		if Volume[period] == 0 then
			min = nil
			max = nil
			p1 = nil
			p2 = nil
		else
			if min == nil then
				p1 = period
				p2 = period
				min = source.low[period]
				max = source.high[period]
			else
				min = math.min(source.low[period], min)
				max = math.max(source.high[period], max)
				p2 = period
			end

			if p1 ~= nil and ((period + 1) < (source:size() - 1) and Volume[period + 1] == 0) then
				visible, y1 = context:pointOfPrice(min)
				visible, y2 = context:pointOfPrice(max)

				date_table = core.dateToTable(source:date(period))
				p3 = core.datetime(date_table.year, date_table.month, date_table.day + 1, 0, 0, 0)

				x1, x = context:positionOfBar(p1)
				x2, x = context:positionOfBar(p2)
				x3, x = context:positionOfDate(p3)
				context:drawLine(1, x1, y1, x2, y1)
				context:drawLine(2, x2, y1, x3, y1)

				context:drawLine(1, x1, y2, x2, y2)
				context:drawLine(2, x2, y2, x3, y2)
			end
		end
	end
end

function Update(period)
	if period < first then
		return
	end

	Volume[period] = 0

	date_table = core.dateToTable(source:date(period))
	start_time = core.datetime(date_table.year, date_table.month, date_table.day, Start, 0, 0)
	end_time = start_time + Period * Hour

	local p1 = core.findDate(source, start_time, false)
	local p2 = core.findDate(source, end_time, false)

	if p1 == -1 or p2 == -1 then
		return
	end

	if period >= p1 and period <= p2 then
		Volume[period] = mathex.sum(source.volume, p1, period)
	end
end
