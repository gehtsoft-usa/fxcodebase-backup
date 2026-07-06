-- Id: 21672
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65136

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
	indicator:name("Previous Period Wick")
	indicator:description("Previous Period Wick")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Time Frame Selector")
	AddTimeFrame(1, "m1", false)
	AddTimeFrame(2, "m5", false)
	AddTimeFrame(3, "m15", false)
	AddTimeFrame(4, "m30", false)
	AddTimeFrame(5, "H1", true)
	AddTimeFrame(6, "H2", false)
	AddTimeFrame(7, "H3", false)
	AddTimeFrame(8, "H4", false)
	AddTimeFrame(9, "H6", false)
	AddTimeFrame(10, "H8", false)
	AddTimeFrame(11, "D1", true)
	AddTimeFrame(12, "W1", true)
	AddTimeFrame(13, "M1", true)

	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100)
end

function AddTimeFrame(id, FRAME, DEFAULT)
	indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT)

	indicator.parameters:addColor(
		"ColorUp" .. id,
		"Color of High",
		"",
		core.rgb(0 + (255 / 13) * id, 255 - (255 / 13) * id, 0)
	)
	indicator.parameters:addColor(
		"ColorDown" .. id,
		"Color of Low",
		"",
		core.rgb(0 + (255 / 13) * id, 255 - (255 / 13) * id, 0)
	)
end
local iTF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
local Num
local Use = {}
local TF = {}
local source = nil
local Period
local Source = {}
local loading = {}
local transparency
local Up = {}
local Down = {}
function Prepare(nameOnly)
	source = instance.source
	Period = instance.parameters.Period
	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Num = 0
	for i = 1, 13, 1 do
		Use[i] = instance.parameters:getBoolean("Use" .. i)

		if Use[i] then
			Num = Num + 1
			Up[Num] = instance.parameters:getColor("ColorUp" .. i)
			Down[Num] = instance.parameters:getColor("ColorDown" .. i)
			TF[Num] = iTF[i]
		end
	end

	for i = 1, Num, 1 do
		Source[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], true, 2, 20000 + i, 10000 + i)
		loading[i] = true
	end

	instance:ownerDrawn(true)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local i

	for i = 1, Num, 1 do
		if cookie == (10000 + i) then
			loading[i] = true
		elseif cookie == (20000 + i) then
			loading[i] = false
		end
	end

	local FLAG = false
	local Number = 0

	for i = 1, Num, 1 do
		if loading[i] then
			FLAG = true
			Number = Number + 1
		end
	end

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. (Num - Number) .. " / " .. Num)
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

function Update(period)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	local FLAG = false
	local Number = 0

	for i = 1, Num, 1 do
		if loading[i] then
			Number = Number + 1
		end
	end

	if FLAG then
		return
	end

	if not init then
		for i = 1, Num, 1 do
			context:createPen(1, context.SOLID, 3, Up[i])
			context:createSolidBrush(2, Up[i])

			context:createPen(3, context.SOLID, 3, Down[i])
			context:createSolidBrush(4, Down[i])
		end

		transparency = context:convertTransparency(instance.parameters.transparency)
		init = true
	end

	local x1
	local y1
	local x2
	local y2

	local date = source:date(source:size() - 1)

	for i = 1, Num, 1 do
		if Source[i].close:hasData(Source[i].close:size() - 1 - 1) then
			local PreviousTradingDayClose = Source[i].close[Source[i].close:size() - 1 - 1]
			local PreviousTradingDayOpen = Source[i].open[Source[i].close:size() - 1 - 1]
			local PreviousTradingDayHigh = Source[i].high[Source[i].close:size() - 1 - 1]
			local PreviousTradingDayLow = Source[i].low[Source[i].close:size() - 1 - 1]

			local period_start, period_end =
				core.getcandle(TF[i], date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"))

			x1, x = context:positionOfDate(period_start)
			x2, x = context:positionOfDate(period_end)

			visible, y1 = context:pointOfPrice(PreviousTradingDayHigh)
			visible, y2 = context:pointOfPrice(math.max(PreviousTradingDayClose, PreviousTradingDayOpen))
			context:drawRectangle(1, 2, x1, y1, x2, y2, transparency)

			visible, y1 = context:pointOfPrice(PreviousTradingDayLow)
			visible, y2 = context:pointOfPrice(math.min(PreviousTradingDayClose, PreviousTradingDayOpen))
			context:drawRectangle(3, 4, x1, y1, x2, y2, transparency)
		end
	end
end
