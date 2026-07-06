-- Id: 4216
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4914

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
	indicator:name("Two Instrument MACD")
	indicator:description("Two Instrument MACD")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	Parameters(1, "EUR/USD")
	Parameters(2, "USD/JPY")

	Stlye(1, core.rgb(0, 255, 0))
	Stlye(2, core.rgb(255, 0, 0))
end
function Stlye(id, Color)
	indicator.parameters:addGroup(id .. ".  Line Style")
	indicator.parameters:addColor("Color" .. id, "First Line Color", "", Color)
	indicator.parameters:addInteger("Width" .. id, "Line Width (in pixels)", "", 1, 1, 5)
	indicator.parameters:addInteger("Style" .. id, "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("Style" .. id, core.FLAG_LEVEL_STYLE)
end

function Parameters(id, Instrument)
	indicator.parameters:addGroup(id .. ". MACD")

	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument)
	indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS)

	indicator.parameters:addString("Price" .. id, "Price Source", "", "close")
	indicator.parameters:addStringAlternative("Price" .. id, "OPEN", "", "open")
	indicator.parameters:addStringAlternative("Price" .. id, "HIGH", "", "high")
	indicator.parameters:addStringAlternative("Price" .. id, "LOW", "", "low")
	indicator.parameters:addStringAlternative("Price" .. id, "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("Price" .. id, "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("Price" .. id, "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("Price" .. id, "WEIGHTED", "", "weighted")

	indicator.parameters:addInteger("SN" .. id, "Short EMA", "The period of the short EMA.", 12, 2, 1000)
	indicator.parameters:addInteger("LN" .. id, "Long EMA", "The period of the long EMA.", 26, 2, 1000)
	indicator.parameters:addInteger("IN" .. id, "Signal line", "The number of periods for the signal line.", 9, 2, 1000)
end

local Number = 2
local SN = {}
local LN = {}
local IN = {}
local Price = {}
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
		SN[i] = instance.parameters:getInteger("SN" .. i)
		LN[i] = instance.parameters:getInteger("LN" .. i)
		IN[i] = instance.parameters:getInteger("IN" .. i)
		Price[i] = instance.parameters:getString("Price" .. i)
		Color[i] = instance.parameters:getColor("Color" .. i)
		Style[i] = instance.parameters:getInteger("Style" .. i)
		Width[i] = instance.parameters:getInteger("Width" .. i)

		name = name .. ", (" .. Instrument[i] .. ", " .. SN[i] .. ", " .. LN[i] .. ", " .. IN[i] .. " )"
	end

	instance:name(name)
	if nameOnly then
		return;
	end

	for i = 1, 2, 1 do
		Test = core.indicators:create("MACD", source.close, SN[i], LN[i], IN[i])

		first = Test.DATA:first()

		SourceData[i] =
			core.host:execute(
			"getSyncHistory",
			Instrument[i],
			source:barSize(),
			source:isBid(),
			math.min(300, first * 2),
			200 + i,
			100 + i
		)
		Indicator[i] = core.indicators:create("MACD", SourceData[i][Price[i]], SN[i], LN[i], IN[i])
		loading[i] = true

		out[i] =
			instance:addStream("out" .. i, core.Line, i .. " MACD", tostring(Instrument[i]), Color[i], Indicator[i].DATA:first())
		out[i]:setWidth(Width[i])
		out[i]:setStyle(Style[i])
		out[i]:setPrecision(2)
	end
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
