-- Id: 18825
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=64991

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Candlesticks BB Indicator")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("BB Calculation")
	indicator.parameters:addInteger("Period", "Period", "", 20)
	indicator.parameters:addInteger("Deviations", "Number of deviations", "", 2)

	--indicator.parameters:addBoolean("TrendFilter", "Use Trend Filter", "", true);

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

local Size
local Deviations, Period, Bid_BB, Ask_BB
local font
local bid, ask
local Trend
function Prepare(nameOnly)
	Period = instance.parameters.Period
	Deviations = instance.parameters.Deviations
	Size = instance.parameters.Size
	Up = instance.parameters.Up
	Down = instance.parameters.Down

	source = instance.source

	local name =
		profile:id() .. "(" .. source:name() .. ", " .. source:barSize() .. ", " .. Period .. ", " .. Deviations .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	if source:isBid() then
		bid = source
		ask = core.host:execute("getAskPrice")
	else
		ask = source
		bid = core.host:execute("getBidPrice")
	end

	Bid_BB = core.indicators:create("BB", bid.close, Period, Deviations)
	Ask_BB = core.indicators:create("BB", ask.close, Period, Deviations)
	first = Bid_BB.TL:first()
	Trend = instance:addInternalStream(first, 0)

	instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period, mode)
	Bid_BB:update(mode)
	Ask_BB:update(mode)

	--[[
	 
	Bar has touched or crossed lower BB
	Bar close price or open price (use the lower one) - Bar low > 2/3 * (bar high - bar low)
	OR
	Bar close ≥ Previous bar open
	USE ASK PRICES

	and vice versa

	Bar has touched or crossed upper BB
	Bar high - Bar close price or open price (use the higher one) > 2/3 * (bar high - bar low)
	OR
	Bar close ≤ Previous bar open
	USE BID PRICES
	 
	 ]]
	if
		(ask.high[period] > Ask_BB.BL[period] and ask.low[period] < Ask_BB.BL[period] and
			ask.close[period] >= ask.open[period - 1]) or
			(math.min(ask.close[period], ask.open[period]) - ask.low[period]) > ((2 / 3) * (ask.high[period] - ask.low[period]))
	 then
		Trend[period] = 1
	end

	if
		(bid.high[period] > Bid_BB.TL[period] and bid.low[period] < Bid_BB.TL[period] and
			bid.close[period] <= bid.open[period - 1]) or
			(bid.high[period] - math.max(bid.close[period], bid.open[period])) > ((2 / 3) * (bid.high[period] - bid.low[period]))
	 then
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
				if Trend[period] ~= 1 then
					x1, x = context:positionOfBar(period)
					visible, y1 = context:pointOfPrice(ask.high[period])
					Text = "\225"
					width, height = context:measureText(1, Text, 0)
					context:drawText(1, Text, Up, -1, x1 - width / 2, y1 - height, x1 + width / 2, y1, 0)
				end
				if Trend[period] ~= -1 then
					x2, x = context:positionOfBar(period)
					visible, y2 = context:pointOfPrice(bid.low[period])
					Text = "\226"
					width, height = context:measureText(1, Text, 0)
					context:drawText(1, Text, Down, -1, x2 - width / 2, y2, x2 + width / 2, y2 + height, 0)
				end
			end
		end
	end
end
