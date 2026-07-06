-- Id: 18783

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64965

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
	indicator:name("N Period High and Low")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "MA Period", "MA Period", 14)
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1")
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("Size", "Label Size", "Label Size", 15)

	indicator.parameters:addGroup("Placement")
	indicator.parameters:addString("Y", " Y Placement", "", "Top")
	indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
	indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Type
local Color, Size
local source = nil
local Period
local Y

local SourceData
local loading = false
local TF
local dayoffset
local weekoffset

-- Routine
function Prepare(nameOnly)
	source = instance.source

	Color = instance.parameters.Color
	Size = instance.parameters.Size
	Period = instance.parameters.Period

	Y = instance.parameters.Y

	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")
	TF = instance.parameters.TF

	local s1, e1, s2, e2
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
	s2, e2 = core.getcandle(TF, 0, 0, 0)
	assert((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!")

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(TF) .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	SourceData =
		core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(Period, 300), 100, 101)
	loading = true

	if (not (nameOnly)) then
		instance:ownerDrawn(true)
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

function iY(context, height, Shift, x)
	if Y == "Top" then
		return context:top() + Shift * height + height * (x - 1) + height
	else
		return context:bottom() - (Shift + 2) * height + height * (x - 1)
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if SourceData:size() - 1 < Period or loading then
		return
	end

	local min, max, minpos, maxpos = mathex.minmax(SourceData, SourceData:size() - 1 - Period + 1, SourceData:size() - 1)

	local High = " High  : " .. win32.formatNumber(max, false, source:getPrecision())
	local Low = " Low  : " .. win32.formatNumber(min, false, source:getPrecision())

	if not init then
		context:createFont(1, "Arial", Size, Size, 0)

		init = true
	end

	x1, x = context:positionOfDate(SourceData:date(minpos))
	x2, x = context:positionOfDate(SourceData:date(maxpos))

	visible, y1 = context:pointOfPrice(min)
	visible, y2 = context:pointOfPrice(max)

	width, height = context:measureText(1, "Low", 0)
	context:drawText(1, "Low", Color, -1, x1 - width / 2, y1, x1 + width / 2, y1 + width, 0)

	width, height = context:measureText(1, "High", 0)
	context:drawText(1, "High", Color, -1, x2 - width / 2, y2 - width, x2 + width / 2, y2, 0)

	local date1 = SourceData:date(minpos)
	local DATA1 = core.dateToTable(date1)

	local date2 = SourceData:date(maxpos)
	local DATA2 = core.dateToTable(date2)

	local delim = "\013\010"

	local Time1 =
		" Date : " ..
		DATA1.month .. " / " .. DATA1.day .. " Time:  " .. DATA1.hour .. " / " .. DATA1.min .. " / " .. DATA1.sec
	local Time2 =
		" Date : " ..
		DATA2.month .. " / " .. DATA2.day .. " Time:  " .. DATA2.hour .. " / " .. DATA2.min .. " / " .. DATA2.sec

	width, height = context:measureText(1, High .. " : " .. Time2, 0)
	context:drawText(
		1,
		High .. " : " .. Time2,
		Color,
		-1,
		context:right() - width,
		iY(context, height, 0, 1),
		context:right(),
		iY(context, height, 0, 2),
		0
	)

	width, height = context:measureText(1, Low .. " : " .. Time1, 0)
	context:drawText(
		1,
		Low .. " : " .. Time1,
		Color,
		-1,
		context:right() - width,
		iY(context, height, 1, 1),
		context:right(),
		iY(context, height, 1, 2),
		0
	)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading = false
		instance:updateFrom(0)
	elseif cookie == 101 then
		loading = true
	end
end
