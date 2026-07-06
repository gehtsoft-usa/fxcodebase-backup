-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64610
-- Id: 18021

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
	indicator:name("Correlation Coefficients")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "", 200, 1, 2000)

	indicator.parameters:addString("Instrument1", "1. Instrument", "", "EUR/USD")
	indicator.parameters:setFlag("Instrument1", core.FLAG_INSTRUMENTS)

	indicator.parameters:addString("Instrument2", "2. Instrument", "", "USD/JPY")
	indicator.parameters:setFlag("Instrument2", core.FLAG_INSTRUMENTS)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)

	indicator.parameters:addGroup("OB/OS Levels")
	indicator.parameters:addDouble("overbought1", "Strong Correlation", "", 0.5)
	indicator.parameters:addDouble("oversold1", "Strong Correlation", "", -0.5)

	indicator.parameters:addColor("level_overboughtsold_color1", "Strong Correlation Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("level_overboughtsold_width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE)

	indicator.parameters:addGroup("Signal Style")
	indicator.parameters:addColor("color1", "Correlation Trade Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("color2", "Reverse Trade Color", "", core.rgb(255, 0, 0))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Signal
local Period
local first
local source = nil
local Correlation
local Instrument = {}
local Source = {}
local loading = {}
local Number = 2
local dayoffset, weekoffset
local Show
-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period
	Show = instance.parameters.Show
	source = instance.source
	first = source:first() + Period

	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")
	for i = 1, Number, 1 do
		Instrument[i] = instance.parameters:getString("Instrument" .. i)
	end
	local name = profile:id() .. "(" .. Instrument[1] .. " / " .. Instrument[2] .. ", " .. Period .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	for i = 1, Number, 1 do
		Source[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), Period, 200 + i, 100 + i)
		loading[i] = true
	end

	Signal = instance:addInternalStream(0, 0)

	Correlation = instance:addStream("Correlation", core.Line, name .. ".Correlation", "Correlation", instance.parameters.color, source:first() + Period)
    Correlation:setPrecision(math.max(2, instance.source:getPrecision()));
	Correlation:setWidth(instance.parameters.width)
	Correlation:setStyle(instance.parameters.style)
	Correlation:addLevel(
		instance.parameters.oversold1,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		instance.parameters.level_overboughtsold_color1
	)
	Correlation:addLevel(
		instance.parameters.overbought1,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		instance.parameters.level_overboughtsold_color1
	)
	Correlation:addLevel(
		0,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		core.COLOR_LABEL
	)
	Correlation:addLevel(
		1,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		core.COLOR_LABEL
	)
	Correlation:addLevel(
		-1,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		core.COLOR_LABEL
	)
end

function Initialization(period, id)
	local Candle
	Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset)

	if loading[id] or Source[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local P = core.findDate(Source[id], Candle, false)

	-- candle is not found
	if P < 0 then
		return false
	else
		return P
	end
end

function Update(period)
	if period < first then
		return
	end

	local p1 = Initialization(period, 1)
	local p2 = Initialization(period, 2)

	if not p1 or not p2 or p1 < Period or p2 < Period then
		return
	end

	local XX_MA = mathex.avg(Source[1].close, p1 - Period + 1, p1)
	local YY_MA = mathex.avg(Source[2].close, p2 - Period + 1, p2)

	local XX = 0
	local YY = 0
	local XY = 0

	for i = 0, Period - 1, 1 do
		XX = XX + (Source[1].close[p1 - i] - XX_MA) ^ 2
		YY = YY + (Source[2].close[p2 - i] - YY_MA) ^ 2
		XY = XY + ((Source[1].close[p1 - i] - XX_MA) * (Source[2].close[p2 - i] - YY_MA))
	end

	Correlation[period] = XY / ((XX * YY) ^ (1 / 2))

	Signal[period] = 0

	if
		((Source[1].close[p1] > XX_MA and Source[2].close[p2] > YY_MA) or
			(Source[1].close[p1] < XX_MA and Source[2].close[p2] < YY_MA))
	 then
		Signal[period] = 1
	end

	if
		((Source[1].close[p1] > XX_MA and Source[2].close[p2] < YY_MA) or
			(Source[1].close[p1] < XX_MA and Source[2].close[p2] > YY_MA))
	 then
		Signal[period] = -1
	end

	if Signal[period] == 1 then
		Correlation:setColor(period, instance.parameters.color1)
	elseif Signal[period] == -1 then
		Correlation:setColor(period, instance.parameters.color2)
	else
		Correlation:setColor(period, instance.parameters.color)
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local j
	local Flag = true
	local Count = 0

	local id = 0

	for j = 1, Number, 1 do
		id = id + 1
		if cookie == (100 + id) then
			loading[j] = true
		elseif cookie == (200 + id) then
			loading[j] = false
		end

		if loading[j] then
			Count = Count + 1
			Flag = false
		end
	end

	if Flag then
		core.host:execute("setStatus", " ")
		instance:updateFrom(0)
	else
		core.host:execute("setStatus", " Loading " .. (Number - Count) .. "/" .. Number)
	end

	return core.ASYNC_REDRAW
end
