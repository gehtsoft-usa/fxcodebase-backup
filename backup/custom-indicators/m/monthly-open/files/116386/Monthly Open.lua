-- Id: 19919

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65438

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
	indicator:name("Monthly Open ")
	indicator:description("Monthly Open ")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addString("TF", "Time frame", "", "M1")
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Label", "Line Color", "Line Color", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addBoolean("ShowH", "Show Horizontal Lines", "", true)
	indicator.parameters:addBoolean("ShowV", "Show Vertical Lines", "", true)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil

local Label
local Show
local TF

local Source
local loading

local dayoffset, weekoffset
-- Routine
function Prepare(nameOnly)
	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	source = instance.source
	first = source:first()
	Label = instance.parameters.Label
	TF = instance.parameters.TF

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 1, 200, 100)
	loading = true

	instance:ownerDrawn(true)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local i

	if cookie == (100) then
		loading = true
	elseif cookie == (200) then
		loading = false
	end

	if loading then
		core.host:execute("setStatus", "  Loading ")
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createPen(1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, Label)
		context:createSolidBrush(2, Label)
		init = true
	end

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	local first = math.max(first, context:firstBar())
	local last = math.min(context:lastBar(), source:size() - 1)

	local Start, End, Step

	for period = Source:first(), Source:size() - 1, 1 do
		DrawSession(context, period)
	end
end

function DrawSession(context, period)
	s, e = core.getcandle(TF, Source:date(period), dayoffset, weekoffset)
	visible, y = context:pointOfPrice(Source.open[period])

	x1, x = context:positionOfDate(s)
	x2, x = context:positionOfDate(e)

	if instance.parameters.ShowH then
		context:drawLine(1, x1, y, x2, y, 0)
	end

	if instance.parameters.ShowV then
		context:drawLine(1, x1, context:top(), x1, context:bottom(), 0)
		context:drawLine(1, x2, context:top(), x2, context:bottom(), 0)
	end
end

function Update(period)
end
