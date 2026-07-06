-- Id: 4212
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4906

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
	indicator:name("Two Instrument Stochastic")
	indicator:description("Two Instrument Stochastic")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	Parameters(1, "EUR/USD")
	Parameters(2, "USD/JPY")

	Stlye(1, core.rgb(0, 255, 0))
	Stlye(2, core.rgb(255, 0, 0))

	indicator.parameters:addGroup("OB/OS Levels")
	indicator.parameters:addDouble("overbought", "Overbought Level", "", 80)
	indicator.parameters:addDouble("oversold", "Oversold Level", "", 20)
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(128, 128, 128))
	indicator.parameters:addInteger("level_overboughtsold_width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE)
end
function Stlye(id, Color)
	indicator.parameters:addGroup(id .. ".  Line Style")
	indicator.parameters:addColor("Color" .. id, "First Line Color", "", Color)
	indicator.parameters:addInteger("Width" .. id, "Line Width (in pixels)", "", 1, 1, 5)
	indicator.parameters:addInteger("Style" .. id, "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("Style" .. id, core.FLAG_LEVEL_STYLE)
end

function Parameters(id, Instrument)
	indicator.parameters:addGroup(id .. ". Instrument")

	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument)
	indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS)

	indicator.parameters:addInteger("K" .. id, "Number of periods for %K", "", 5, 2, 1000)
	indicator.parameters:addInteger("SD" .. id, "%D slowing periods", "", 3, 2, 1000)
	indicator.parameters:addInteger("D" .. id, "The number of periods for %D.", "", 3, 2, 1000)

	indicator.parameters:addString("KS" .. id, "Smoothing type for %K", "", "MVA")
	indicator.parameters:addStringAlternative("KS" .. id, "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("KS" .. id, "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("KS" .. id, "MT4", "", "FS")

	indicator.parameters:addString("DS" .. id, "Smoothing type for %D", "", "MVA")
	indicator.parameters:addStringAlternative("DS" .. id, "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("DS" .. id, "EMA", "", "EMA")
end

local Number = 2
local K = {}
local SD = {}
local D = {}
local KS = {}
local DS = {}
local out = {}
local source
local Indicator = {}
local Instrument = {}
local first
local loading = {}
local offset, weekoffset
local SourceData = {}
local Color = {}
local Style = {}
local Width = {}

function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	offset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	local name = profile:id()

	local i

	for i = 1, 2, 1 do
		Instrument[i] = instance.parameters:getString("Instrument" .. i)
		K[i] = instance.parameters:getInteger("K" .. i)
		SD[i] = instance.parameters:getInteger("SD" .. i)
		D[i] = instance.parameters:getInteger("D" .. i)
		KS[i] = instance.parameters:getString("KS" .. i)
		DS[i] = instance.parameters:getString("DS" .. i)

		Color[i] = instance.parameters:getColor("Color" .. i)
		Style[i] = instance.parameters:getInteger("Style" .. i)
		Width[i] = instance.parameters:getInteger("Width" .. i)

		name =
			name ..
			", (" .. Instrument[i] .. ", " .. K[i] .. ", " .. SD[i] .. ", " .. D[i] .. ", " .. KS[i] .. ", " .. DS[i] .. " )"
	end

	instance:name(name)
	if nameOnly then
		return;
	end

	for i = 1, 2, 1 do
		Test = core.indicators:create("STOCHASTIC", source.close, K[i], SD[i], D[i], KS[i], DS[i])

		first = Test.DATA:first()

		SourceData[i] =
			core.host:execute(
			"getSyncHistory",
			Instrument[i],
			source:barSize(),
			source:isBid(),
			math.min(first * 2, 300),
			200 + i,
			100 + i
		)
		Indicator[i] = core.indicators:create("STOCHASTIC", SourceData[i], K[i], SD[i], D[i], KS[i], DS[i])
		loading[i] = true

		out[i] =
			instance:addStream(
			"out" .. i,
			core.Line,
			i .. " STOCHASTIC",
			tostring(Instrument[i]),
			Color[i],
			Indicator[i].DATA:first()
		)
		out[i]:setWidth(Width[i])
		out[i]:setStyle(Style[i])
		out[i]:setPrecision(2)
	end

	out[1]:addLevel(
		instance.parameters.oversold,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		instance.parameters.level_overboughtsold_color
	)
	out[1]:addLevel(
		instance.parameters.overbought,
		instance.parameters.level_overboughtsold_style,
		instance.parameters.level_overboughtsold_width,
		instance.parameters.level_overboughtsold_color
	)
end

function Update(period, mode)
	for i = 1, 2, 1 do
		Calculation(i, period, mode)
	end
end

function Calculation(id, period, mode)
	Indicator[id]:update(mode)

	local p = Initialization(period, id)

	if not p then
		return
	end

	out[id][period] = Indicator[id].DATA[p]
end

function Initialization(period, id)
	local Candle
	Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset)

	if loading[id] or SourceData[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local P = core.findDate(SourceData[id], Candle, false)

	-- candle is not found
	if P < 0 then
		return false
	else
		return P
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local j
	local Flag = true
	local Count = 0

	for j = 1, Number, 1 do
		if cookie == (100 + j) then
			loading[j] = true
		elseif cookie == (200 + j) then
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
