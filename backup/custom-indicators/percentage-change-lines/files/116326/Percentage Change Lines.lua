-- Id: 19877

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65425

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Percentage Change Lines")
	indicator:description("Percentage Change Lines")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1")
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS)

	indicator.parameters:addString("Instrument", "Instrument", "", "EUR/USD")
	indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5)

	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5)

	indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5)

	indicator.parameters:addColor("color4", "Mid Line Color", "", core.rgb(128, 128, 128))
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_DASH)
	indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width4", "Line Width", "", 1, 1, 5)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local TF
local dayoffset
local weekoffset
local Instrument
local Source2
local loading2 = false

local Source1
local loading1 = false

-- Streams block

-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()

	TF = instance.parameters.TF
	Instrument = instance.parameters.Instrument

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Instrument) .. ", " .. tostring(TF) .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	local s1, e1, s2, e2
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
	s2, e2 = core.getcandle(TF, 0, 0, 0)
	assert((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!")

	Source2 = core.host:execute("getSyncHistory", Instrument, TF, source:isBid(), 0, 200, 201)
	loading2 = true

	Source1 = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101)
	loading1 = true

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading1 = false
	elseif cookie == 101 then
		loading1 = true
	end

	if cookie == 200 then
		loading2 = false
	elseif cookie == 201 then
		loading2 = true
	end

	if not loading1 and not loading2 then
		instance:updateFrom(0)
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 or loading1 or loading2 then
		return
	end

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style1),
			instance.parameters.width1,
			instance.parameters.color1
		)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.style2),
			instance.parameters.width2,
			instance.parameters.color2
		)
		context:createPen(
			3,
			context:convertPenStyle(instance.parameters.style3),
			instance.parameters.width3,
			instance.parameters.color3
		)
		context:createPen(
			4,
			context:convertPenStyle(instance.parameters.style4),
			instance.parameters.width4,
			instance.parameters.color4
		)
	end

	for p2 = Source2:first(), Source2:size() - 1, 1 do
		Change = (Source2.close[p2] - Source2.open[p2]) / (Source2.open[p2] / 100)
		S, E = core.getcandle(TF, Source2:date(p2), dayoffset, weekoffset)
		x1, x = context:positionOfDate(S)
		x2, x = context:positionOfDate(E)

		p1 = core.findDate(Source1, S, false)

		visible, y1 = context:pointOfPrice(Source1.open[p1] + (Source1.open[p1] / 100) * Change)
		visible, y2 = context:pointOfPrice(Source1.open[p1] - (Source1.open[p1] / 100) * Change)
		visible, y3 = context:pointOfPrice(Source1.open[p1])
		visible, y4 = context:pointOfPrice(Source1.open[p1] + (Source1.open[p1] / 100) * Change / 2)
		visible, y5 = context:pointOfPrice(Source1.open[p1] - (Source1.open[p1] / 100) * Change / 2)

		context:drawLine(1, x1, y1, x2, y1)
		context:drawLine(2, x1, y2, x2, y2)
		context:drawLine(3, x1, y3, x2, y3)
		context:drawLine(4, x1, y4, x2, y4)
		context:drawLine(4, x1, y5, x2, y5)
	end
end
