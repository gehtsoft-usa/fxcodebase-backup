-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58665
-- Id: 18183

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

function Init()
	indicator:name("MTF MCP Volume MA")
	indicator:description("MTF MCP Volume MA")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	Parameters(1, "m1", "MVA")
	Parameters(2, "m15", "MVA")
	Parameters(3, "m30", "MVA")
	Parameters(4, "H1", "MVA")
	Parameters(5, "H2", "MVA")
	Parameters(6, "H3", "MVA")
	Parameters(7, "H4", "MVA")
	Parameters(8, "H8", "MVA")
	Parameters(9, "D1", "MVA")
	Parameters(10, "W1", "MVA")
	Parameters(11, "M1", "MVA")

	indicator.parameters:addGroup("Filter")
	indicator.parameters:addInteger("FilterMethod", "Filter Method", "Method", 0)
	indicator.parameters:addIntegerAlternative("FilterMethod", "Do NOT Use", " ", 0)
	indicator.parameters:addIntegerAlternative("FilterMethod", "m1", " ", 1)
	indicator.parameters:addIntegerAlternative("FilterMethod", "m15", " ", 2)
	indicator.parameters:addIntegerAlternative("FilterMethod", "m30", " ", 3)
	indicator.parameters:addIntegerAlternative("FilterMethod", "H1", " ", 4)
	indicator.parameters:addIntegerAlternative("FilterMethod", "H2", " ", 5)
	indicator.parameters:addIntegerAlternative("FilterMethod", "H3", " ", 6)
	indicator.parameters:addIntegerAlternative("FilterMethod", "H4", " ", 7)
	indicator.parameters:addIntegerAlternative("FilterMethod", "H8", " ", 8)
	indicator.parameters:addIntegerAlternative("FilterMethod", "D1", " ", 9)
	indicator.parameters:addIntegerAlternative("FilterMethod", "W1", " ", 10)
	indicator.parameters:addIntegerAlternative("FilterMethod", "M1", " ", 11)

	indicator.parameters:addGroup("Common Parameters")
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10)
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0, 10000)
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255))
end

function Parameters(id, FRAME, Method)
	indicator.parameters:addGroup(id .. ". Time Frame")
	indicator.parameters:addBoolean("On" .. id, "Show  This Time Frame", "", true)

	indicator.parameters:addString("TF" .. id, "Time frame", "", FRAME)
	indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)

	indicator.parameters:addString("TYPE" .. id, "Indicaton Type MA of Volume / Volume", "", "MA")
	indicator.parameters:addStringAlternative("TYPE" .. id, "MA of Volume", "", "MA")
	indicator.parameters:addStringAlternative("TYPE" .. id, "Volume", "", "RAW")

	indicator.parameters:addString("Method" .. id, "MA Method", "Method", "MVA")
	indicator.parameters:addStringAlternative("Method" .. id, "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("Method" .. id, "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("Method" .. id, "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("Method" .. id, "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("Method" .. id, "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("Method" .. id, "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("Method" .. id, "VIDYA", "VIDYA", "VIDYA")
	indicator.parameters:addStringAlternative("Method" .. id, "WMA", "WMA", "WMA")

	indicator.parameters:addInteger("Period" .. id, "Period", "", 14)

	indicator.parameters:addString("Type" .. id, "Indicaton Type", "", "Numeric")
	indicator.parameters:addStringAlternative("Type" .. id, "Numeric", "", "Numeric")
	indicator.parameters:addStringAlternative("Type" .. id, "Trend", "", "Trend")
end

local loading = {}
local SourceData = {}
local Indicator = {}
local Pair
local font, Wingdings, Bold
local Size
local source
local TF = {}
local host
local first = {}
local Test = {}
local Count
local Up, Down, No, LabelColor
local N = {}
local Shift
local On = {}
local Num

local Method = {}
local Type = {}
local TYPE = {}
local Lock = {}
local Period = {}
local FilterMethod
local KEY
local Raw = {}
function ReleaseInstance()
	core.host:execute("deleteFont", font)
	core.host:execute("deleteFont", Wingdings)
	core.host:execute("deleteFont", Bold)
end

function Prepare(nameOnly)
	Shift = instance.parameters.Shift
	source = instance.source

	host = core.host

	Size = instance.parameters.ArrowSize
	local name = "(" .. profile:id() .. "," .. instance.source:name() .. "," .. source:barSize() .. ")"

	local i, j

	Up = instance.parameters.Up
	Down = instance.parameters.Down
	No = instance.parameters.No
	LabelColor = instance.parameters.Label
	FilterMethod = instance.parameters.FilterMethod

	Pair, Count = getInstrumentList()

	Num = 0

	for i = 1, 11, 1 do
		On[i] = instance.parameters:getBoolean("On" .. i)

		if On[i] then
			Num = Num + 1

			if not On[i] and FilterMethod == i then
				FilterMethod = 0
			elseif On[i] and FilterMethod == i then
				FilterMethod = Num
			end

			Method[Num] = instance.parameters:getString("Method" .. i)
			Period[Num] = instance.parameters:getString("Period" .. i)
			TYPE[Num] = instance.parameters:getString("TYPE" .. i)
			TF[Num] = instance.parameters:getString("TF" .. i)
			Type[Num] = instance.parameters:getString("Type" .. i)

			if not nameOnly then
    assert(core.indicators:findIndicator(Method[Num]) ~= nil, Method[Num] .. " indicator must be installed");
				Test[Num] = core.indicators:create(Method[Num], source.volume, Period[Num])

				first[Num] = Test[Num].DATA:first() * 2
			end

			name = name .. ", (" .. TF[Num] .. ", " .. Method[Num] .. ", " .. Period[Num] .. ")"
		end
	end

	instance:name(name)
	if nameOnly then
		return;
	end

	font = core.host:execute("createFont", "Courier", Size, false, false)
	Wingdings = core.host:execute("createFont", "Wingdings", Size + 1, false, false)
	Bold = core.host:execute("createFont", "Courier", Size + 1, false, true)

	local ID = 0

	for j = 1, Count, 1 do
		SourceData[j] = {}
		-- Raw[j] = {};
		loading[j] = {}
		Indicator[j] = {}

		for i = 1, Num, 1 do
			ID = ID + 1

			SourceData[j][i] =
				core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.max(300, first[i]), 20000 + ID, 10000 + ID)
			loading[j][i] = true

    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
			Indicator[j][i] = core.indicators:create(Method[i], SourceData[j][i].volume, Period[i])
		end
	end

	core.host:execute("setTimer", 100, 10)
end

function ReleaseInstance()
	core.host:execute("killTimer", 100)
end

function Update(period, mode)
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

function BubbleSortKey(index)
	local Key = {}
	local Temp
	local Sort = true

	for i = 1, Count, 1 do
		Key[i] = i
	end

	while Sort do
		Sort = false

		for i = 2, Count, 1 do
			if TYPE[index] == "MA" then
				if
					Indicator[Key[i]][index].DATA[Indicator[Key[i]][index].DATA:size() - 1] <
						Indicator[Key[i - 1]][index].DATA[Indicator[Key[i - 1]][index].DATA:size() - 1]
				 then
					Sort = true

					Temp = Key[i]
					Key[i] = Key[i - 1]
					Key[i - 1] = Temp
				end
			else
				if
					SourceData[Key[i]][index].volume[SourceData[Key[i]][index].volume:size() - 1] <
						SourceData[Key[i - 1]][index].volume[SourceData[Key[i - 1]][index].volume:size() - 1]
				 then
					Sort = true

					Temp = Key[i]
					Key[i] = Key[i - 1]
					Key[i - 1] = Temp
				end
			end
		end

		if Sort == false then
			break
		end
	end

	return Key
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

	if not FLAG and cookie == 100 then
		for j = 1, Count, 1 do
			for i = 1, Num, 1 do
				if TYPE[i] == "MA" then
					Indicator[j][i]:update(core.UpdateLast)
				end
			end
		end

		---------------------------------------------------------
		--Filter
		-------------------------------------------------------------

		if FilterMethod == 0 then
			KEY = {}
			for i = 1, Count, 1 do
				KEY[i] = i
			end
		else
			KEY = nil
			KEY = BubbleSortKey(FilterMethod)
		end
		---------------------------------------------------------
		--Calculation
		-------------------------------------------------------------

		local id = 0

		for i = 1, Num, 1 do
			core.host:execute(
				"drawLabel1",
				id,
				200 + (i - 1) * 110,
				core.CR_LEFT,
				40 + Shift,
				core.CR_TOP,
				core.H_Left,
				core.V_Center,
				Bold,
				LabelColor,
				TF[i]
			)
			id = id + 1
		end

		for k = 1, Count, 1 do
			j = KEY[k]
			x = k

			core.host:execute(
				"drawLabel1",
				id,
				80,
				core.CR_LEFT,
				60 + (j - 1) * 15 + Shift,
				core.CR_TOP,
				core.H_Left,
				core.V_Center,
				Bold,
				LabelColor,
				Pair[j]
			)
			id = id + 1

			for i = 1, Num, 1 do
				--close

				if TYPE[i] == "MA" then
					--	Indicator[j][i]:update(core.UpdateLast);

					if
						Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size() - 1) and
							Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size() - 2)
					 then
						local Color = nil
						local Style = nil
						local Font = nil

						Style = Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size() - 1]

						if
							Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size() - 1] >
								Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size() - 2]
						 then
							Color = Up
							Style = "\225"
						elseif
							Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size() - 1] <
								Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size() - 2]
						 then
							Color = Down
							Style = "\226"
						else
							Style = "\158"
							Color = No
						end

						if Type[i] ~= "Trend" then
							Font = font
							Style = string.format("%." .. 0 .. "f", Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size() - 1])
						else
							Font = Wingdings
						end

						if Style ~= nil then
							core.host:execute(
								"drawLabel1",
								id,
								200 + (i - 1) * 110,
								core.CR_LEFT,
								60 + (x - 1) * 15 + Shift,
								core.CR_TOP,
								core.H_Left,
								core.V_Center,
								Font,
								Color,
								Style
							)
							id = id + 1
						end
					end
				else
					if
						SourceData[j][i].volume:hasData(SourceData[j][i].volume:size() - 1) and
							SourceData[j][i].volume:hasData(SourceData[j][i].volume:size() - 2)
					 then
						local Color = nil
						local Style = nil
						local Font = nil

						Style = SourceData[j][i].volume[SourceData[j][i].volume:size() - 1]

						if
							SourceData[j][i].volume[SourceData[j][i].volume:size() - 1] >
								SourceData[j][i].volume[SourceData[j][i].volume:size() - 2]
						 then
							Color = Up
							Style = "\225"
						elseif
							SourceData[j][i].volume[SourceData[j][i].volume:size() - 1] <
								SourceData[j][i].volume[SourceData[j][i].volume:size() - 2]
						 then
							Color = Down
							Style = "\226"
						else
							Style = "\158"
							Color = No
						end

						if Type[i] ~= "Trend" then
							Font = font
							Style = string.format("%." .. 0 .. "f", SourceData[j][i].volume[SourceData[j][i].volume:size() - 1])
						else
							Font = Wingdings
						end

						if Style ~= nil then
							core.host:execute(
								"drawLabel1",
								id,
								200 + (i - 1) * 110,
								core.CR_LEFT,
								60 + (x - 1) * 15 + Shift,
								core.CR_TOP,
								core.H_Left,
								core.V_Center,
								Font,
								Color,
								Style
							)
							id = id + 1
						end
					end
				end
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
