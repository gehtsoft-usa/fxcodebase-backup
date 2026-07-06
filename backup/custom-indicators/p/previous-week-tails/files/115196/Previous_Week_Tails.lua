-- Id: 19157
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
	indicator:name("Previous Week Tails")
	indicator:description("Previous Week Tails")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100)
	indicator.parameters:addColor("D_Color", "Day Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("W_Color", "Week Color", "", core.rgb(255, 0, 0))
end

local source = nil
local Period
local DaySource
local WeekSource
local loading1
local loading2
local transparency
function Prepare(nameOnly)
	source = instance.source
	Period = instance.parameters.Period
	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	DaySource = core.host:execute("getSyncHistory", source:instrument(), "D1", true, 1, 2, 1)
	loading1 = true
	WeekSource = core.host:execute("getSyncHistory", source:instrument(), "W1", true, 2, 4, 3)
	loading2 = true

	instance:ownerDrawn(true)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local FLAG = false

	if cookie == 1 then
		loading1 = true
	elseif cookie == 2 then
		loading1 = false
	end

	if cookie == 3 then
		loading2 = true
	elseif cookie == 4 then
		loading2 = false
	end

	if loading1 or loading2 then
		FLAG = true
	end

	if not FLAG then
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

	if loading1 or loading2 then
		return
	end

	if not init then
		context:createPen(1, context.SOLID, 3, instance.parameters.D_Color)
		context:createSolidBrush(2, instance.parameters.D_Color)
		context:createPen(3, context.SOLID, 3, instance.parameters.W_Color)
		context:createSolidBrush(4, instance.parameters.W_Color)

		transparency = context:convertTransparency(instance.parameters.transparency)
		init = true
	end

	local x1
	local y1
	local x2
	local y2

	local PreviousTradingDayClose = DaySource.close[DaySource.close:size() - 1 - 1]
	local PreviousTradingDayOpen = DaySource.open[DaySource.close:size() - 1 - 1]
	local PreviousTradingDayHigh = DaySource.high[DaySource.close:size() - 1 - 1]
	local PreviousTradingDayLow = DaySource.low[DaySource.close:size() - 1 - 1]

	local PreviousTradingWeekClose = WeekSource.close[WeekSource.close:size() - 1 - 1]
	local PreviousTradingWeekOpen = WeekSource.open[WeekSource.close:size() - 1 - 1]
	local PreviousTradingWeekHigh = WeekSource.high[WeekSource.close:size() - 1 - 1]
	local PreviousTradingWeekLow = WeekSource.low[WeekSource.close:size() - 1 - 1]

	local date = source:date(source:size() - 1)
	local weekstart, weekend =
		core.getcandle("W1", date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"))
	local daystart, dayend =
		core.getcandle("D1", date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"))

	-- y1=  PreviousTradingWeekHigh;
	visible, y1 = context:pointOfPrice(PreviousTradingDayHigh)

	if (PreviousTradingDayClose > PreviousTradingDayOpen) then
		--y2=  PreviousTradingWeekClose;
		visible, y2 = context:pointOfPrice(PreviousTradingDayClose)
	else
		--y2 = PreviousTradingWeekOpen ;
		visible, y2 = context:pointOfPrice(PreviousTradingDayOpen)
	end

	--x1= weekstart;
	x1, x = context:positionOfDate(daystart)
	--x2= weekend;
	x2, x = context:positionOfDate(dayend)

	context:drawRectangle(1, 2, x1, y1, x2, y2, transparency)

	--	y1=  PreviousTradingWeekLow;
	visible, y1 = context:pointOfPrice(PreviousTradingWeekLow)
	if (PreviousTradingWeekClose < PreviousTradingWeekOpen) then
		--y2=  PreviousTradingWeekClose;
		visible, y2 = context:pointOfPrice(PreviousTradingWeekClose)
	else
		--y2 = PreviousTradingWeekOpen ;
		visible, y2 = context:pointOfPrice(PreviousTradingWeekOpen)
	end

	--x1= weekstart;
	x1, x = context:positionOfDate(weekstart)
	--x2= weekend;
	x2, x = context:positionOfDate(weekend)

	context:drawRectangle(3, 4, x1, y1, x2, y2, transparency)
end
