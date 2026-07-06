-- Id: 13681
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61870

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
	indicator:name("ZigZag Envelope")
	indicator:description("ZigZag Envelope")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Zig Zag Parameters")
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
	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("UpColor", "Up Color", "Up Color", core.rgb(128, 128, 128))
	indicator.parameters:addColor("DownColor", "Down Color", "Down Color", core.rgb(128, 128, 128))
	indicator.parameters:addDouble("Transparency", "Transparency", "Transparency", 50)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local UpColor, DownColor
-- Streams block
local ZigZag = nil
local Depth
local Deviation
local Backstep
local Trend
local Top = nil
local Bottom = nil
local Last
local Transparency
-- Routine
function Prepare(nameOnly)
	source = instance.source
	Depth = instance.parameters.Depth
	Deviation = instance.parameters.Deviation
	Backstep = instance.parameters.Backstep
	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (not (nameOnly)) then
		ZigZag = core.indicators:create("ZIGZAG", source, Depth, Deviation, Backstep)
		first = source:first()
		Trend = instance:addInternalStream(0, 0)
	end

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	if period < first or not source:hasData(period) then
		return
	end

	if Last ~= source:serial(source:size() - 1) and period == source:size() - 1 then
		Last = source:serial(period)
		ZigZag:update(core.UpdateAll)
	else
		ZigZag:update(mode)
	end

	for i = math.min(period, ZigZag.DATA:size() - 2), first, -1 do
		if Trend[i] == 1 or Trend[i] == -1 then
			break
		end

		if ZigZag.DATA[i] > ZigZag.DATA[i - 1] and ZigZag.DATA[i] > ZigZag.DATA[i + 1] and ZigZag.DATA[i] ~= nil then
			Trend[i] = 1
		end

		if ZigZag.DATA[i] < ZigZag.DATA[i - 1] and ZigZag.DATA[i] < ZigZag.DATA[i + 1] and ZigZag.DATA[i] ~= nil then
			Trend[i] = -1
		end
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		Transparency = context:convertTransparency(instance.parameters.Transparency)
		init = true
	end

	local X1, Y1, X2, Y2, X3, Y3

	for i = context:firstBar(), context:lastBar(), 1 do
		if Trend[i] == 1 then
			X1, Y1, X2, Y2, X3, Y3 = Calculate(i)
			if X1 ~= nil and X2 ~= nil and X3 ~= nil then
				visible, y1 = context:pointOfPrice(Y1)
				x1, x = context:positionOfBar(X1)
				visible, y2 = context:pointOfPrice(Y2)
				x2, x = context:positionOfBar(X2)
				visible, y3 = context:pointOfPrice(Y3)
				x3, x = context:positionOfBar(X3)
				context:drawGradientTriangle(x1, y1, UpColor, x2, y2, UpColor, x3, y3, UpColor, Transparency)
			end
		elseif Trend[i] == -1 then
			X1, Y1, X2, Y2, X3, Y3 = Calculate(i)
			if X1 ~= nil and X2 ~= nil and X3 ~= nil then
				visible, y1 = context:pointOfPrice(Y1)
				x1, x = context:positionOfBar(X1)
				visible, y2 = context:pointOfPrice(Y2)
				x2, x = context:positionOfBar(X2)
				visible, y3 = context:pointOfPrice(Y3)
				x3, x = context:positionOfBar(X3)
				context:drawGradientTriangle(x1, y1, DownColor, x2, y2, DownColor, x3, y3, DownColor, Transparency)
			end
		end
	end
end

function Calculate(i)
	local X = {}
	X[1] = nil
	X[2] = nil
	X[3] = nil

	local Y = {}
	local Count = 0

	for period = i, first, -1 do
		if Trend[period] == 1 or Trend[period] == -1 then
			Count = Count + 1
			X[Count] = period

			if Trend[i] == 1 then
				if Count == 1 then
					Y[Count] = source.high[period]
				elseif Count == 2 then
					Y[Count] = source.low[period]
				elseif Count == 3 then
					Y[Count] = source.high[period]
				end
			elseif Trend[i] == -1 then
				if Count == 1 then
					Y[Count] = source.low[period]
				elseif Count == 2 then
					Y[Count] = source.high[period]
				elseif Count == 3 then
					Y[Count] = source.low[period]
				end
			end
		end
	end

	return X[1], Y[1], X[2], Y[2], X[3], Y[3]
end
