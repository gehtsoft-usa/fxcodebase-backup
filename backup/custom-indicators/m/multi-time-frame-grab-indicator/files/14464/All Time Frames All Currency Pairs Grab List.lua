-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6256

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
	indicator:name("All Time Frames All  Currency Pairs Grab List")
	indicator:description("All Time Frames All  Currency Pairs Grab List")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	Parameters(1, "m1", false)
	Parameters(2, "m15", false)
	Parameters(3, "m30", false)
	Parameters(4, "H1", true)
	Parameters(5, "H2", false)
	Parameters(6, "H3", false)
	Parameters(7, "H4", false)
	Parameters(8, "H8", false)
	Parameters(9, "D1", true)
	Parameters(10, "W1", true)
	Parameters(11, "M1", true)

	indicator.parameters:addGroup("Common Parameters")
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10)
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0, 10000)
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255))
end

function Parameters(id, FRAME, IsOn)
	indicator.parameters:addGroup(id .. ". Time Frame")
	indicator.parameters:addBoolean("On" .. id, "Show  This Time Frame", "", IsOn)

	indicator.parameters:addString("TF" .. id, "Time frame", "", FRAME)
	indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)

	indicator.parameters:addInteger("Period" .. id, "Period", "Period", 34)

	indicator.parameters:addString("Method" .. id, "Method", "Method", "EMA")
	indicator.parameters:addStringAlternative("Method" .. id, "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("Method" .. id, "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("Method" .. id, "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("Method" .. id, "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("Method" .. id, "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("Method" .. id, "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("Method" .. id, "WMA", "WMA", "WMA")
end

local loading = {}
local SourceData = {}
local High = {}
local Low = {}
local Pair
local font, Wingdings, Bold
local Size
local source
local TF = {}
local host
local first
local Test = {}
local Count
local Up, Down, No, LabelColor
local N = {}
local Shift
--local On={};
local Num
local Method = {}
local Period = {}
local id
function ReleaseInstance()
	core.host:execute("deleteFont", font)
	core.host:execute("deleteFont", Wingdings)
	core.host:execute("deleteFont", Bold)
	core.host:execute("killTimer", 1)
end

function Prepare(nameOnly)
	Shift = instance.parameters.Shift
	source = instance.source

	host = core.host

	Size = instance.parameters.ArrowSize
	local name = "(" .. profile:id() .. "," .. instance.source:name() .. "," .. source:barSize() .. ")"
	instance:name(name)
	if (nameOnly) then
		return
	end

	local i, j

	Up = instance.parameters.Up
	Down = instance.parameters.Down
	No = instance.parameters.No
	LabelColor = instance.parameters.Label

	Pair, Count = getInstrumentList()

	Num = 0

	for i = 1, 11, 1 do
		if instance.parameters:getBoolean("On" .. i) then
			Num = Num + 1
			--On[Num]=  instance.parameters:getBoolean ("On"..i);
			TF[Num] = instance.parameters:getString("TF" .. i)
			Method[Num] = instance.parameters:getString("Method" .. i)
			Period[Num] = instance.parameters:getInteger("Period" .. i)
		end
	end

	font = core.host:execute("createFont", "Courier", Size, false, false)
	Wingdings = core.host:execute("createFont", "Wingdings", Size + 1, false, false)
	Bold = core.host:execute("createFont", "Courier", Size + 1, false, true)

	local ID = 0

	for j = 1, Count, 1 do
		SourceData[j] = {}
		High[j] = {}
		Low[j] = {}
		loading[j] = {}

		for i = 1, Num, 1 do
			ID = ID + 1
			assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed")
			Test = core.indicators:create(Method[i], source, Period[i], Method[i])
			first = Test.DATA:first() * 2

			SourceData[j][i] =
				core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(first, 300), 20000 + ID, 10000 + ID)
			loading[j][i] = true

			High[j][i] = core.indicators:create(Method[i], SourceData[j][i].high, Period[i], Method[i])
			Low[j][i] = core.indicators:create(Method[i], SourceData[j][i].low, Period[i], Method[i])
		end
	end

	core.host:execute("setTimer", 1, 1)
end

function Update(period, mode)
	if period < source:size() - 1 then
		return
	end

	local FLAG = false

	local i, j
	id = 1
	local Number = 0

	for j = 1, Count, 1 do
		for i = 1, Num, 1 do
			if loading[j][i] then
				FLAG = true
				Number = Number + 1
			end
		end
	end

	if FLAG then
		return
	end

	for i = 1, Num, 1 do
		core.host:execute(
			"drawLabel1",
			id,
			Size * 5 + (i) * Size * 3,
			core.CR_LEFT,
			Size * 2 + Shift,
			core.CR_TOP,
			core.H_Left,
			core.V_Center,
			Bold,
			LabelColor,
			TF[i]
		)
		id = id + 1
	end

	for j = 1, Count, 1 do
		core.host:execute(
			"drawLabel1",
			id,
			Size * 5,
			core.CR_LEFT,
			Size * 2 + (j) * Size * 1.1 + Shift,
			core.CR_TOP,
			core.H_Left,
			core.V_Center,
			Bold,
			LabelColor,
			Pair[j]
		)
		id = id + 1

		for i = 1, Num, 1 do
			Draw(i, j)
		end
	end
end

function Draw(i, j)
	if
		not SourceData[j][i].close:hasData(SourceData[j][i].close:size() - 1) or
			not SourceData[j][i].close:hasData(SourceData[j][i].close:size() - 2) or
			not Low[j][i].DATA:hasData(Low[j][i].DATA:size() - 1) or
			not High[j][i].DATA:hasData(High[j][i].DATA:size() - 1)
	 then
		return
	end

	local Color = No
	local Style = nil

	Style = SourceData[j][i].close[SourceData[j][i].close:size() - 1]

	if SourceData[j][i].close[SourceData[j][i].close:size() - 1] > High[j][i].DATA[High[j][i].DATA:size() - 1] then
		Color = Up
		if
			SourceData[j][i].close[SourceData[j][i].close:size() - 1] > SourceData[j][i].close[SourceData[j][i].close:size() - 2]
		 then
			Style = "\225"
		else
			Style = "\226"
		end
	elseif SourceData[j][i].close[SourceData[j][i].close:size() - 1] < Low[j][i].DATA[Low[j][i].DATA:size() - 1] then
		Color = Down
		if
			SourceData[j][i].close[SourceData[j][i].close:size() - 1] > SourceData[j][i].close[SourceData[j][i].close:size() - 2]
		 then
			Style = "\225"
		else
			Style = "\226"
		end
	else
		if
			SourceData[j][i].close[SourceData[j][i].close:size() - 1] > SourceData[j][i].close[SourceData[j][i].close:size() - 2]
		 then
			Style = "\225"
		else
			Style = "\226"
		end
		Color = No
	end

	if Style ~= nil then
		core.host:execute(
			"drawLabel1",
			id,
			Size * 5 + (i) * Size * 3,
			core.CR_LEFT,
			Size * 2 + (j) * Size * 1.1 + Shift,
			core.CR_TOP,
			core.H_Left,
			core.V_Center,
			Wingdings,
			Color,
			Style
		)
		id = id + 1
	end
end

function getInstrumentList()
	local list = {}

	local count = 0
	local row, enum

	enum = core.host:findTable("offers"):enumerator()
	row = enum:next()
	while row ~= nil do
		count = count + 1
		list[count] = row.Instrument
		row = enum:next()
	end

	return list, count
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local i, j
	local ID = 0
	for j = 1, Count, 1 do
		for i = 1, Num, 1 do
			ID = ID + 1
			if cookie == (10000 + ID) then
				loading[j][i] = true
			elseif cookie == (20000 + ID) then
				loading[j][i] = false
			end
		end
	end

	local FLAG = false
	local Number = 0

	for j = 1, Count, 1 do
		for i = 1, Num, 1 do
			if loading[j][i] then
				FLAG = true
				Number = Number + 1
			end
		end
	end

	if not FLAG and cookie == 1 then
		for j = 1, Count, 1 do
			for i = 1, Num, 1 do
				High[j][i]:update(core.UpdateLast)
				Low[j][i]:update(core.UpdateLast)
			end
		end
	end

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. ((Count * Num) - Number) .. " / " .. (Count * Num))
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end
