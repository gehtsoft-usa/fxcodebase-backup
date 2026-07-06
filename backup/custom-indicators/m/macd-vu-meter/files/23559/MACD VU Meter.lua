-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11772
-- Id: 5563

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("MACD VU Meter")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Price Type")
	indicator.parameters:addString("PriceType", "Price", "", "close")
	indicator.parameters:addStringAlternative("PriceType", "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("PriceType", "OPEN", "", "open")
	indicator.parameters:addStringAlternative("PriceType", "HIGH", "", "high")
	indicator.parameters:addStringAlternative("PriceType", "LOW", "", "low")
	indicator.parameters:addStringAlternative("PriceType", "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("PriceType", "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("PriceType", "WEIGHTED", "", "weighted")

	indicator.parameters:addBoolean("Lock", "Lock", "", false)

	indicator.parameters:addString("Type", "Lock Type", "", "Frame")
	indicator.parameters:addStringAlternative("Type", "Time Frame", "", "Frame")
	indicator.parameters:addStringAlternative("Type", "Instrument", "", "Instrument")

	Parameters(1, "H1")
	Parameters(2, "H1")
	Parameters(3, "H1")
	Parameters(4, "H1")
	Parameters(5, "H1")

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("Mode", "Mode", "", "L")
	indicator.parameters:addStringAlternative("Mode", "Live", "", "L")
	indicator.parameters:addStringAlternative("Mode", "End of Turn", "", "E")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addInteger("HEIGHT", "Height", "", 200)

	indicator.parameters:addString("Algo", "Absolute/Relative", "", "Absolute")
	indicator.parameters:addStringAlternative("Algo", "Relative", "", "Relative")
	indicator.parameters:addStringAlternative("Algo", "Absolute", "", "Absolute")

	indicator.parameters:addBoolean("V", "Show Values", "", true)
	indicator.parameters:addBoolean("P", "Show Percentages", "", true)
	indicator.parameters:addColor("IN", "Indicator color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("NE", "Neutral color", "", core.rgb(0, 0, 0))
	indicator.parameters:addColor("LABEL", "Label color", "", core.COLOR_LABEL)
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1, 20)
end

function Parameters(id, FRAME, DEFAULT)
	indicator.parameters:addGroup(id .. ". MACD Calculation")
	indicator.parameters:addInteger("ShortPeriod" .. id, "Short Periods", "", 12)
	indicator.parameters:addInteger("LongPeriod" .. id, "Long Periods", "", 26)
	indicator.parameters:addInteger("SignalPeriod" .. id, "Signal Periods", "", 9)

	indicator.parameters:addBoolean("ON" .. id, "Use This TimeFrame", "", true)
	indicator.parameters:addInteger("N" .. id, "Periods", "", 14)

	local iPair = {"EUR/USD", "USD/JPY", "GBP/USD", "USD/CHF", "AUD/USD"}
	indicator.parameters:addString("INSTRUMENT" .. id, "Instrumet", "", iPair[id])
	indicator.parameters:setFlag("INSTRUMENT" .. id, core.FLAG_INSTRUMENTS)

	indicator.parameters:addString("B" .. id, "Time frame", "", FRAME)
	indicator.parameters:setFlag("B" .. id, core.FLAG_PERIODS)
end

local Algo
local Lock
local Type

local source

local day_offset, week_offset

local host
local first

local INSTRUMENT = {}
local Label = {}
local FRAME = {}
local FrameLabel = {}
local ON = {}

local COUNT = 0
local PERIOD = {}

local HEIGHT
local font1, font2
local fisrt, source
local IN, NE, LABEL
--local Placement;
local Size
local Mode
local V, P
local MACD = {}
local stream = {}
local loading = {}
local id
local PriceType
local Number
function Prepare(nameOnly)
	Algo = instance.parameters.Algo
	Lock = instance.parameters.Lock
	Type = instance.parameters.Type
	source = instance.source
	first = source:first()
	host = core.host
	PriceType = instance.parameters.PriceType

	--Placement= instance.parameters.Placement;
	V = instance.parameters.V
	P = instance.parameters.P
	Size = instance.parameters.Size
	HEIGHT = instance.parameters.HEIGHT
	IN = instance.parameters.IN
	NE = instance.parameters.NE
	LABEL = instance.parameters.LABEL
	Mode = instance.parameters.Mode

	local name = profile:id()
	instance:name(name)
	if nameOnly then
		return;
	end

	local i

	for i = 1, 5, 1 do
		if (instance.parameters:getInteger("LongPeriod" .. i) <= instance.parameters:getInteger("ShortPeriod" .. i)) then
			error("The short EMA period must be smaller than long EMA period")
		end

		ON[i] = instance.parameters:getBoolean("ON" .. i)

		if ON[i] then
			COUNT = COUNT + 1

			PERIOD[COUNT] = instance.parameters:getInteger("N" .. i)

			if instance.parameters:getString("INSTRUMENT" .. i) == "" then
				INSTRUMENT[COUNT] = source:instrument()
			else
				INSTRUMENT[COUNT] = instance.parameters:getString("INSTRUMENT" .. i)
			end

			if Lock and Type == "Instrument" then
				INSTRUMENT[COUNT] = INSTRUMENT[1]
			else
				INSTRUMENT[COUNT] = INSTRUMENT[COUNT]
			end

			if Lock and Type == "Instrument" and i ~= 1 then
				Label[COUNT] = ""
			else
				Label[COUNT] = INSTRUMENT[COUNT]
			end

			FRAME[COUNT] = instance.parameters:getString("B" .. i)

			if Lock and Type == "Frame" then
				FRAME[COUNT] = FRAME[1]
			end

			if Lock and Type == "Frame" and i ~= 1 then
				FrameLabel[COUNT] = ""
			else
				FrameLabel[COUNT] = FRAME[COUNT]
			end
		end
	end

	Number = COUNT

	font1 = core.host:execute("createFont", "Arial", Size, false, false)
	font2 = core.host:execute("createFont", "Wingdings", 9, false, false)

	day_offset = host:execute("getTradingDayOffset")
	week_offset = host:execute("getTradingWeekOffset")

	for i = 1, COUNT, 1 do
		stream[i] = core.host:execute("getSyncHistory", INSTRUMENT[i], FRAME[i], source:isBid(), PERIOD[i], 200 + i, 100 + i)
		loading[i] = true
		MACD[i] =
			core.indicators:create(
			"MACD",
			stream[i][PriceType],
			instance.parameters:getInteger("ShortPeriod" .. i),
			instance.parameters:getInteger("LongPeriod" .. i),
			instance.parameters:getInteger("SignalPeriod" .. i)
		)
	end
end

function Update(period, mode)
	if period < source:size() - 1 then
		return
	end

	local Flag = false

	for i = 1, Number, 1 do
		if loading[i] then
			Flag = true
		end
	end

	if Flag then
		return
	end

	local Shift
	if Mode == "E" then
		Shift = 1
	else
		Shift = 0
	end

	local min = nil
	local max = nil
	id = 1

	for i = 1, COUNT, 1 do
		MACD[i]:update(mode)

		if MACD[i].DATA:hasData(MACD[i].DATA:size() - 1 - Shift) then
			--Absolute/Relative

			if Algo == "Relative" then
				min, max = mathex.minmax(MACD[i].DATA, MACD[i].DATA:first(), MACD[i].DATA:size() - 1 - Shift)

				core.host:execute(
					"drawLabel1",
					id,
					-75 + (-200) * i,
					core.CR_RIGHT,
					-50 + 20,
					core.CR_BOTTOM,
					core.H_Right,
					core.V_Bottom,
					font1,
					LABEL,
					"(" .. FRAME[i] .. "," .. Label[i] .. ")"
				)
				id = id + 1
				DRAW(max, min, MACD[i].DATA[MACD[i].DATA:size() - 1 - Shift], HEIGHT, i * 200, 50, "vertical")
			end

			if Algo == "Absolute" then
				if min == nil or max == nil then
					min = MACD[i].DATA[MACD[i].DATA:size() - 1 - Shift]
					max = MACD[i].DATA[MACD[i].DATA:size() - 1 - Shift]
				end

				if min > MACD[i].DATA[MACD[i].DATA:size() - 1 - Shift] then
					min = MACD[i].DATA[MACD[i].DATA:size() - 1 - Shift]
				end

				if max < MACD[i].DATA[MACD[i].DATA:size() - 1 - Shift] then
					max = MACD[i].DATA[MACD[i].DATA:size() - 1 - Shift]
				end
			end
		end
	end

	if Algo == "Absolute" then
		for i = 1, COUNT, 1 do
			if MACD[i].DATA:hasData(MACD[i].DATA:size() - 1 - Shift) then
				core.host:execute(
					"drawLabel1",
					id,
					-75 + (-200) * i,
					core.CR_RIGHT,
					-50 + 20,
					core.CR_BOTTOM,
					core.H_Right,
					core.V_Bottom,
					font1,
					LABEL,
					"(" .. FRAME[i] .. "," .. Label[i] .. ")"
				)
				id = id + 1
				DRAW(max, min, MACD[i].DATA[MACD[i].DATA:size() - 1 - Shift], HEIGHT, i * 200, 50, "vertical")
			end
		end
	end
end

function DRAW(max, min, value, Height, X, Y, Z)
	--local id=1;
	local i, j
	local Range = max - min
	local Percentage = Range / 100
	local Value = (value - min) / Percentage
	local Index = 100 / Height
	local Color = IN

	if Z == "horizontal" then
		--	id=0;
		if V then
			core.host:execute(
				"drawLabel1",
				id,
				-Y - Height + (Value / Index),
				core.CR_RIGHT,
				-X - 33,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", (value))
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y,
				core.CR_RIGHT,
				-X - 45,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", max)
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y - Height,
				core.CR_RIGHT,
				-X - 45,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", min)
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y - Height / 2,
				core.CR_RIGHT,
				-X - 45,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", min + (max - min) / 2)
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y - (Height / 4) * 1,
				core.CR_RIGHT,
				-X - 45,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", (min + ((max - min) / 4) * 3))
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y - (Height / 4) * 3,
				core.CR_RIGHT,
				-X - 45,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", (min + ((max - min) / 4) * 1))
			)
			id = id + 1
		end
		if P then
			core.host:execute(
				"drawLabel1",
				id,
				-Y - Height + (Value / Index),
				core.CR_RIGHT,
				-X - 14 + 23,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 2 .. "f", (Value))
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y,
				core.CR_RIGHT,
				-X + 20,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				"100"
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y - (Height / 4) * 1,
				core.CR_RIGHT,
				-X + 20,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				"75"
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y - Height / 2,
				core.CR_RIGHT,
				-X + 20,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				"50"
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y - (Height / 4) * 3,
				core.CR_RIGHT,
				-X + 20,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				"25"
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-Y - Height,
				core.CR_RIGHT,
				-X + 20,
				core.CR_BOTTOM,
				core.H_Right,
				core.V_Bottom,
				font1,
				LABEL,
				"0"
			)
			id = id + 1
		end

		for i = 1, Height, 10 do
			Color = IN

			if Index * i >= Value then
				Color = NE
			end

			for j = 1, 25, 5 do
				core.host:execute(
					"drawLabel1",
					id,
					-Y - Height + i,
					core.CR_RIGHT,
					-X - j,
					core.CR_BOTTOM,
					core.H_Left,
					core.V_Bottom,
					font2,
					Color,
					"\108"
				)
				id = id + 1
			end
		end
	elseif Z == "vertical" then
		--	id=0;
		if V then
			core.host:execute(
				"drawLabel1",
				id,
				-X - 30,
				core.CR_RIGHT,
				-Y - Value / Index,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", (value))
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X - 30,
				core.CR_RIGHT,
				-Y,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", min)
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X - 30,
				core.CR_RIGHT,
				-Y - Height,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", max)
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X - 30,
				core.CR_RIGHT,
				-Y - Height / 2,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", min + (max - min) / 2)
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X - 30,
				core.CR_RIGHT,
				-Y - (Height / 4) * 3,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", (min + ((max - min) / 4) * 3))
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X - 30,
				core.CR_RIGHT,
				-Y - (Height / 4) * 1,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				string.format("%." .. 4 .. "f", (min + ((max - min) / 4) * 1))
			)
			id = id + 1
		end
		if P then
			if
				round(Value, 1) ~= 100 and round(Value, 1) ~= 75 and round(Value, 1) ~= 50 and round(Value, 1) ~= 25 and
					round(Value, 1) ~= 100
			 then
				core.host:execute(
					"drawLabel1",
					id,
					-X - 14 + 20,
					core.CR_RIGHT,
					-Y - Value / Index,
					core.CR_BOTTOM,
					core.H_Right,
					core.V_Bottom,
					font1,
					LABEL,
					string.format("%." .. 2 .. "f", (Value))
				)
				id = id + 1
			end

			core.host:execute(
				"drawLabel1",
				id,
				-X + 20,
				core.CR_RIGHT,
				-Y,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				"0"
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X + 20,
				core.CR_RIGHT,
				-Y - (Height / 4) * 1,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				"25"
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X + 20,
				core.CR_RIGHT,
				-Y - Height / 2,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				"50"
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X + 20,
				core.CR_RIGHT,
				-Y - (Height / 4) * 3,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				"75"
			)
			id = id + 1

			core.host:execute(
				"drawLabel1",
				id,
				-X + 20,
				core.CR_RIGHT,
				-Y - Height,
				core.CR_BOTTOM,
				core.H_Left,
				core.V_Bottom,
				font1,
				LABEL,
				"100"
			)
			id = id + 1
		end

		for i = 1, Height, 10 do
			Color = NE

			if Index * i <= Value then
				Color = IN
			end

			for j = 1, 25, 5 do
				core.host:execute(
					"drawLabel1",
					id,
					-X - j,
					core.CR_RIGHT,
					-Y - i,
					core.CR_BOTTOM,
					core.H_Left,
					core.V_Bottom,
					font2,
					Color,
					"\108"
				)
				id = id + 1
			end
		end
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local j
	local Flag = false
	local Count = 0

	for j = 1, Number, 1 do
		if cookie == (100 + j) then
			loading[j] = true
		elseif cookie == (200 + j) then
			loading[j] = false
		end

		if loading[j] then
			Count = Count + 1
			Flag = true
		end
	end

	if Flag then
		core.host:execute("setStatus", " Loading " .. (Number - Count) .. "/" .. Number)
	else
		core.host:execute("setStatus", " Loaded " .. (Number - Count) .. "/" .. Number)
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

function ReleaseInstance()
	core.host:execute("deleteFont", font1)
	core.host:execute("deleteFont", font2)
end

function round(num, idp)
	if idp and idp > 0 then
		local mult = 10 ^ idp
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end
