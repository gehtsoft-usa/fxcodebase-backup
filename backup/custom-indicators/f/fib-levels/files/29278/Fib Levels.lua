-- Id: 6258
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15534

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

function Init()
	indicator:name("Fibonacci Levels")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1")
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS)
	indicator.parameters:addBoolean(
		"YTD",
		"Show yesterday band",
		"Choose yes to show yesterday band and no to show today band",
		false
	)
	indicator.parameters:addBoolean("Historical", "Show Historical", "", false)
	indicator.parameters:addString(
		"OC",
		"Price Source",
		"Choose yes to show open/close band instead of high/low band",
		"HIGH"
	)
	indicator.parameters:addStringAlternative("OC", "High/Low", "", "HIGH")
	indicator.parameters:addStringAlternative("OC", "Open/Close", "", "CLOSE")

	indicator.parameters:addGroup("Levels")
	indicator.parameters:addDouble("HEL", "Upper Extension Line", "", 27.2, 0, 1000)
	indicator.parameters:addDouble("HML", "1. Line", "", 61.8, 0, 100)
	indicator.parameters:addDouble("ML", "2. Line", "", 50, 0, 100)
	indicator.parameters:addDouble("LML", "3. Line", "", 38.2, 0, 100)
	indicator.parameters:addDouble("LEL", "Lower Extension Line ", "", 27.2, 0, 1000)

	indicator.parameters:addGroup("Price Levels")
	indicator.parameters:addBoolean("Show", "Show Price Levels", "", true)
	indicator.parameters:addBoolean("ShowDifferences", "Show Differences", "", false)
	indicator.parameters:addInteger("ArrowSize", "Font SIze", "", 10)
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))

	indicator.parameters:addGroup("High Extension Line Style")
	indicator.parameters:addColor("color6", "Color", "", core.rgb(255, 128, 64))
	indicator.parameters:addInteger("style6", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width6", "Line Width", "", 1, 1, 5)

	indicator.parameters:addGroup("High Line Style")
	indicator.parameters:addColor("color1", "Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5)

	indicator.parameters:addGroup("High  Mid Line Style")
	indicator.parameters:addColor("color4", "Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width4", "Line Width", "", 1, 1, 5)

	indicator.parameters:addGroup("Mid Line Style")
	indicator.parameters:addColor("color3", "Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5)

	indicator.parameters:addGroup("Low Mid Line Style")
	indicator.parameters:addColor("color5", "Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("style5", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width5", "Line Width", "", 1, 1, 5)

	indicator.parameters:addGroup("Low Line Style")
	indicator.parameters:addColor("color2", "Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5)

	indicator.parameters:addGroup("Low Extension Line Style")
	indicator.parameters:addColor("color7", "Color", "", core.rgb(255, 128, 1))
	indicator.parameters:addInteger("style7", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style7", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width7", "Line Width", "", 1, 1, 5)
end
local LE, HE
local HEL, LEL, ML, HML, LML
local source  -- the source
local hilo_data = nil -- the high/low data
local TF
local BSLen
local dayoffset
local weekoffset
local candles  -- stream of the candle's dates
local YTD
local OC
local Show
local Label
local ArrowSize
local ShowDifferences
local loading
local Historical
function Prepare(nameOnly)
	ArrowSize = instance.parameters.ArrowSize
	Label = instance.parameters.Label
	ShowDifferences = instance.parameters.ShowDifferences
	HEL = instance.parameters.HEL
	LEL = instance.parameters.LEL
	ML = instance.parameters.ML
	HML = instance.parameters.HML
	LML = instance.parameters.LML
	TF = instance.parameters.TF

	Show = instance.parameters.Show
	Historical = instance.parameters.Historical
	source = instance.source

	YTD = instance.parameters.YTD
	OC = (instance.parameters.OC == "CLOSE")

	local YTDn, OCn

	if YTD then
		YTDn = "prev"
	else
		YTDn = "curr"
	end

	if OC then
		OCn = "O/C"
	else
		OCn = "H/L"
	end

	local name = profile:id() .. "(" .. source:name() .. "," .. TF .. "," .. YTDn .. "," .. OCn .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	local l1, l2
	local s, e

	s, e = core.getcandle(source:barSize(), core.now(), 0)
	l1 = e - s
	s, e = core.getcandle(TF, core.now(), 0)
	l2 = e - s
	BSLen = l2 -- remember length of the period
	assert(l1 <= l2, "The chosen time frame must be the same of longer than the chart time frame")

	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 1, 100, 101)
	loading = true

	instance:ownerDrawn(true)
end

function Initialization(period)
	local Candle
	Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset)

	if loading or Source:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local p = core.findDate(Source, Candle, false)

	-- candle is not found
	if p < 0 then
		return false
	else
		return p
	end
end

-- the function which is called to calculate the period
function Update(period)
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

local init = false

function Draw(stage, context)
	if stage ~= 2 or loading then
		return
	end

	if not init then
		context:createFont(8, "Arial", context:pointsToPixels(ArrowSize), context:pointsToPixels(ArrowSize), 0)
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
		context:createPen(
			5,
			context:convertPenStyle(instance.parameters.style5),
			instance.parameters.width5,
			instance.parameters.color5
		)
		context:createPen(
			6,
			context:convertPenStyle(instance.parameters.style6),
			instance.parameters.width6,
			instance.parameters.color6
		)
		context:createPen(
			7,
			context:convertPenStyle(instance.parameters.style7),
			instance.parameters.width7,
			instance.parameters.color7
		)
		init = true
	end

	local p

	for period = math.max(context:firstBar(), source:first()), math.min(context:lastBar(), source:size() - 1), 1 do
		p = Initialization(period)

		if (Historical or (not Historical and p == Source:size() - 1)) then
			if YTD then
				p = p - 1
			end

			if OC then
				H = math.max(Source.open[p], Source.close[p])
				L = math.min(Source.open[p], Source.close[p])
				M = L + ((H - L) / 100) * ML
				HM = L + ((H - L) / 100) * HML
				LM = L + ((H - L) / 100) * LML
				HE = H + ((H - L) / 100) * HEL
				LE = L - ((H - L) / 100) * LEL
			else
				H = Source.high[p]
				L = Source.low[p]
				M = L + ((H - L) / 100) * ML
				HM = L + ((H - L) / 100) * HML
				LM = L + ((H - L) / 100) * LML
				HE = H + ((H - L) / 100) * HEL
				LE = L - ((H - L) / 100) * LEL
			end

			visible, y1 = context:pointOfPrice(H)
			visible, y2 = context:pointOfPrice(L)
			visible, y3 = context:pointOfPrice(M)
			visible, y4 = context:pointOfPrice(HM)
			visible, y5 = context:pointOfPrice(LM)
			visible, y6 = context:pointOfPrice(HE)
			visible, y7 = context:pointOfPrice(LE)

			if TF == source:barSize() then
				date1 = source:date(period)
				date2 = source:date(period - 1)
			else
				date1, date2 = core.getcandle(TF, source:date(period), dayoffset, weekoffset)
			end

			index1 = core.findDate(source, date1, false)
			index2 = core.findDate(source, date2, false)

			if index1 ~= -1 and index2 ~= -1 then
				x1, x = context:positionOfBar(index1)
				x2, x = context:positionOfBar(index2)

				context:drawLine(1, x1, y1, x2, y1)
				context:drawLine(2, x1, y2, x2, y2)
				context:drawLine(3, x1, y3, x2, y3)
				context:drawLine(4, x1, y4, x2, y4)
				context:drawLine(5, x1, y5, x2, y5)
				context:drawLine(6, x1, y6, x2, y6)
				context:drawLine(7, x1, y7, x2, y7)
			end

			if period == source:size() - 1 and Show then
				if ShowDifferences then
					Label1 =
						string.format("%." .. 5 .. "f", H) ..
						" (" .. string.format("%." .. 2 .. "f", ((H - HM) / source:pipSize())) .. ")" .. " (" .. TF .. ")"
					Label4 =
						string.format("%." .. 5 .. "f", HM) ..
						" (" .. string.format("%." .. 2 .. "f", ((HM - M) / source:pipSize())) .. ")"
					Label3 =
						string.format("%." .. 5 .. "f", M) ..
						" (" .. string.format("%." .. 2 .. "f", ((M - LM) / source:pipSize())) .. ")"
					Label5 =
						string.format("%." .. 5 .. "f", LM) ..
						" (" .. string.format("%." .. 2 .. "f", ((LM - L) / source:pipSize())) .. ")"
					Label2 =
						string.format("%." .. 5 .. "f", L) ..
						" (" .. string.format("%." .. 2 .. "f", ((L - LE) / source:pipSize())) .. ")"
					Label6 =
						string.format("%." .. 5 .. "f", HE) ..
						" (" .. string.format("%." .. 2 .. "f", ((HE - H) / source:pipSize())) .. ")"
					Label7 = string.format("%." .. 5 .. "f", LE)
				else
					Label1 = string.format("%." .. 5 .. "f", H) .. " (" .. TF .. ")"
					Label4 = string.format("%." .. 5 .. "f", HM)
					Label3 = string.format("%." .. 5 .. "f", M)
					Label5 = string.format("%." .. 5 .. "f", LM)
					Label2 = string.format("%." .. 5 .. "f", L)
					Label6 = string.format("%." .. 5 .. "f", HE)
					Label7 = string.format("%." .. 5 .. "f", LE)
				end

				width1, height1 = context:measureText(8, Label1, 0)
				width2, height2 = context:measureText(8, Label2, 0)
				width3, height3 = context:measureText(8, Label3, 0)
				width4, height4 = context:measureText(8, Label4, 0)
				width5, height5 = context:measureText(8, Label5, 0)
				width6, height6 = context:measureText(8, Label6, 0)
				width7, height7 = context:measureText(8, Label7, 0)

				x, x1, x2 = context:positionOfBar(period)

				x = x + 50

				context:drawText(8, Label1, Label, -1, x, y1 - height1, x + width1, y1, 0)
				context:drawText(8, Label2, Label, -1, x, y2 - height2, x + width2, y2, 0)
				context:drawText(8, Label3, Label, -1, x, y3 - height3, x + width3, y3, 0)
				context:drawText(8, Label4, Label, -1, x, y4 - height4, x + width4, y4, 0)
				context:drawText(8, Label5, Label, -1, x, y5 - height5, x + width5, y5, 0)
				context:drawText(8, Label6, Label, -1, x, y6 - height6, x + width6, y6, 0)
				context:drawText(8, Label7, Label, -1, x, y7 - height7, x + width7, y7, 0)
			end
		end
	end
end
