-- Id: 17900
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=64558

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Stochastic Min Max")
	indicator:description("Shows the location of the  high/low price achieved between two Stochastic crosses")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("K", "Number of periods for %K", "", 25, 2, 1000)
	indicator.parameters:addInteger("SD", "%D slowing periods", "", 25, 2, 1000)
	indicator.parameters:addInteger("D", "The number of periods for %D.", "", 25, 2, 1000)

	indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA")
	indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("KS", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("KS", "FS", "", "FS")

	indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA")
	indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA")

	indicator.parameters:addBoolean("TrendFilter", "Use Trend Filter", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Period Max Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Period Min Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("Size", "Font Size", "", 15, 1, 1000)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Up, Down
local DS, KS
local K, SD, D
local Size
local Stochastic = nil
local font
local Trend
local TrendFilter
function Prepare(nameOnly)
	TrendFilter = instance.parameters.TrendFilter
	DS = instance.parameters.DS
	KS = instance.parameters.KS
	K = instance.parameters.K
	SD = instance.parameters.SD
	D = instance.parameters.D
	Size = instance.parameters.Size
	Up = instance.parameters.Up
	Down = instance.parameters.Down

	source = instance.source

	local name =
		profile:id() ..
		"(" ..
			source:name() .. ", " .. source:barSize() .. ", " .. K .. ", " .. SD .. ", " .. D .. ", " .. KS .. ", " .. DS .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Stochastic = core.indicators:create("STOCHASTIC", source, K, SD, D, KS, DS)
	first = Stochastic.D:first()
	Trend = instance:addInternalStream(first, 0)

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period, mode)
	period = period - 1
	Stochastic:update(mode)

	if Stochastic.K[period] > Stochastic.D[period] and Stochastic.K[period - 1] <= Stochastic.D[period - 1] then
		Trend[period] = 1
	end

	if Stochastic.K[period] < Stochastic.D[period] and Stochastic.K[period - 1] >= Stochastic.D[period - 1] then
		Trend[period] = -1
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createFont(1, "Wingdings", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
		init = true
	end

	local min, max, minpos, maxpos
	local from

	for period = math.max(first, context:firstBar()), math.min(context:lastBar(), source:size() - 1), 1 do
		if Trend:hasData(period) then
			if Trend[period] == 1 or Trend[period] == -1 then
				from = Find(period)
				min, max, minpos, maxpos = mathex.minmax(source, from, period - 1)

				if (Trend[period] ~= 1 and TrendFilter) or not TrendFilter then
					x1, x = context:positionOfBar(maxpos)
					visible, y1 = context:pointOfPrice(max)
					Text = "\225"
					width, height = context:measureText(1, Text, 0)
					context:drawText(1, Text, Up, -1, x1 - width / 2, y1 - height, x1 + width / 2, y1, 0)
				end
				if (Trend[period] ~= -1 and TrendFilter) or not TrendFilter then
					x2, x = context:positionOfBar(minpos)
					visible, y2 = context:pointOfPrice(min)
					Text = "\226"
					width, height = context:measureText(1, Text, 0)
					context:drawText(1, Text, Down, -1, x2 - width / 2, y2, x2 + width / 2, y2 + height, 0)
				end
			end
		end
	end
end

function Find(Start)
	local from

	for period = Start - 1, first, -1 do
		if Trend[period] == 1 or Trend[period] == -1 then
			from = period
			break
		end
	end

	return from
end
