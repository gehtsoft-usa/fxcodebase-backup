-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60884
-- Id: 18212

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
	indicator:name("Consecutive Candle Scanner")
	indicator:description("  ")

	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Level", "Level", "", 5)
	indicator.parameters:addGroup("Selector")

	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector", "All currency pair")
	indicator.parameters:addStringAlternative("Type", "Chart", "Chart", "Chart")
	indicator.parameters:addStringAlternative(
		"Type",
		"Multiple currency pair",
		"Multiple currency pair",
		"Multiple currency pair"
	)
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair", "All currency pair")

	for i = 1, 20, 1 do
		indicator.parameters:addGroup(i .. ". Currency Pair ")
		Add(i)
	end

	indicator.parameters:addGroup("Time Frame Selector")
	AddTimeFrame(1, "m1", true)
	AddTimeFrame(2, "m5", true)
	AddTimeFrame(3, "m15", true)
	AddTimeFrame(4, "m30", true)
	AddTimeFrame(5, "H1", true)
	AddTimeFrame(6, "H2", true)
	AddTimeFrame(7, "H3", true)
	AddTimeFrame(8, "H4", true)
	AddTimeFrame(9, "H6", true)
	AddTimeFrame(10, "H8", true)
	AddTimeFrame(11, "D1", true)
	AddTimeFrame(12, "W1", true)
	AddTimeFrame(13, "M1", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0))
	indicator.parameters:addColor("SelectColor", "Alert Color", "Alert Color", core.rgb(255, 0, 0))

	indicator.parameters:addBoolean("ShowCells", "Show Cells", "", false)
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100)
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70, 0, 100)

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

	indicator.parameters:addGroup("Alerts Email")
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
	indicator.parameters:addString("Email", "Email", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)

	ParametersAlert("Alert")
end

function ParametersAlert(Label)
	indicator.parameters:addGroup(Label)

	indicator.parameters:addBoolean("ON", "Show " .. Label, "", true)

	indicator.parameters:addFile("Sound", Label .. " Sound", "", "")
	indicator.parameters:setFlag("Sound", core.FLAG_SOUND)

	indicator.parameters:addString("Labels", "Label", "", Label)

	--id
end

function AddTimeFrame(id, FRAME, DEFAULT)
	indicator.parameters:addBoolean("Use" .. id, "Show " .. FRAME, "", DEFAULT)
end

function getInstrumentList()
	local list = {}
	local point = {}

	local count = 0
	local row, enum

	enum = core.host:findTable("offers"):enumerator()
	row = enum:next()
	while row ~= nil do
		count = count + 1
		list[count] = row.Instrument
		point[count] = row.PointSize
		row = enum:next()
	end

	return list, count, point
end

function Add(id)
	local Init = {
		"EUR/USD",
		"USD/JPY",
		"GBP/USD",
		"USD/CHF",
		"EUR/CHF",
		"AUD/USD",
		"USD/CAD",
		"NZD/USD",
		"EUR/GBP",
		"EUR/JPY",
		"GBP/JPY",
		"CHF/JPY",
		"GBP/CHF",
		"EUR/AUD",
		"EUR/CAD",
		"AUD/CAD",
		"AUD/JPY",
		"CAD/JPY",
		"NZD/JPY",
		"GBP/CAD"
	}

	if id <= 5 then
		indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", true)
	else
		indicator.parameters:addBoolean("Dodaj" .. id, "Use This Slot", "", false)
	end
	indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id])
	indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Filter
local Show
local iTF = {"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
local TF = {}
local pauto = "(%a%a%a)/(%a%a%a)"
local Color
local Source = {}
local Size
local transparency
local loading = {}
local source
local Pair = {}
local Count
local Type
local Dodaj = {}
local Point = {}
local Use = {}
local Num
local ShowCells
local Up, Down, Neutral
local Select
local SelectColor
local Last = {}
local Indicator = {}
local RecurrentSound, PlaySound, Sound, SendEmail, Email, Label, ON
-- Routine
function Prepare(nameOnly)
	Size = instance.parameters.Size
	Mode = instance.parameters.Mode
	Level = instance.parameters.Level
	SelectColor = instance.parameters.SelectColor
	Type = instance.parameters.Type
	ShowCells = instance.parameters.ShowCells
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Neutral = instance.parameters.Neutral
	source = instance.source

	local name = profile:id() .. "(" .. tostring(source:barSize()) .. ")"
	instance:name(name)
	if nameOnly then
		return;
	end

	assert(
		core.indicators:findIndicator("CONSECUTIVE CANDLE COUNT") ~= nil,
		"Please, download and install CONSECUTIVE CANDLE COUNT.LUA indicator"
	)

	if Type == "Multiple currency pair" then
		Count = 0
		for i = 1, 20, 1 do
			Dodaj[i] = instance.parameters:getBoolean("Dodaj" .. i)
			if Dodaj[i] then
				Count = Count + 1
				Pair[Count] = instance.parameters:getString("Pair" .. i)
				Point[Count] = core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize
			end
		end
	elseif Type == "All currency pair" then
		Pair, Count, Point = getInstrumentList()
	else
		Pair[1] = source:instrument()
		Point[1] = source:pipSize()
		Count = 1
	end

	Num = 0
	for i = 1, 13, 1 do
		Use[i] = instance.parameters:getBoolean("Use" .. i)

		if Use[i] then
			Num = Num + 1

			TF[Num] = iTF[i]
		end
	end

	local ID = 0
	Color = instance.parameters.Color

	for i = 1, Count, 1 do
		Source[i] = {}
		loading[i] = {}
		Indicator[i] = {}
		Last[i] = {}

		for j = 1, Num, 1 do
			ID = ID + 1

			Temp = core.indicators:create("CONSECUTIVE CANDLE COUNT", source, true)
			first = Temp.DATA:first() * 2
			Source[i][j] =
				core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(), math.max(300, first), 20000 + ID, 10000 + ID)
			loading[i][j] = true

			Indicator[i][j] = core.indicators:create("CONSECUTIVE CANDLE COUNT", Source[i][j], true)
		end
	end

	instance:ownerDrawn(true)

	core.host:execute("setTimer", 1, 5)

	Initialization()
end

function Initialization()
	SendEmail = instance.parameters.SendEmail

	local i
	Label = instance.parameters:getString("Labels")
	ON = instance.parameters:getBoolean("ON")

	if SendEmail then
		Email = instance.parameters.Email
	else
		Email = nil
	end
	assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

	PlaySound = instance.parameters.PlaySound
	if PlaySound then
		Sound = instance.parameters:getString("Sound")
	else
		Sound = nil
	end

	assert(not (PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen")

	RecurrentSound = instance.parameters.RecurrentSound
end

function ReleaseInstance()
	core.host:execute("killTimer", 1)
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local i
	local ID = 0

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			ID = ID + 1
			if cookie == (10000 + ID) then
				loading[i][j] = true
			elseif cookie == (20000 + ID) then
				loading[i][j] = false
			end
		end
	end

	local FLAG = false
	local Number = 0

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			if loading[i][j] then
				FLAG = true
				Number = Number + 1
			end
		end
	end

	if not FLAG and cookie == 1 then
		for i = 1, Count, 1 do
			for j = 1, Num, 1 do
				Indicator[i][j]:update(core.UpdateLast)

				if
					Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 1] > Level and
						Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 2] <= Level
				 then
					Activate(i, j, Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 1] .. ". Consecutive  Up Candles")
				elseif
					Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 1] < -Level and
						Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 2] >= -Level
				 then
					Activate(i, j, math.abs(Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 1]) .. ". Consecutive  Down Candles")
				end
			end
		end
	end

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. (Count * Num - Number) .. " / " .. Count * Num)
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

local top, bottom
local left, right
local xGap
local yGap

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	local Loading = false

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			if loading[i][j] then
				Loading = true
			end
		end
	end

	if Loading then
		return
	end

	if not init then
		context:createPen(1, context.SOLID, 1, Color)
		context:createSolidBrush(2, Color)
		context:createSolidBrush(3, SelectColor)

		transparency = context:convertTransparency(instance.parameters.transparency)

		init = true
	end

	left, right = context:left(), context:right()

	xGap = (right - left) / (Num + 1)
	yGap = (context:bottom() - context:top()) / (Count + 2)

	top = context:top() + yGap
	bottom = context:bottom()

	if xGap > 250 then
		xGap = 250
	end

	for i = 1, Count, 1 do
		for j = 1, Num, 1 do
			Calculate(context, i, j)
		end
	end
end

function Calculate(context, i, j)
	y1 = bottom - (i + 1) * yGap
	y2 = bottom - (i) * yGap

	x1 = left + (j - 1) * xGap
	x2 = left + (j) * xGap

	iwidth = ((xGap / 7) / 100) * Size
	iheight = (yGap / 100) * Size

	context:createFont(7, "Arial", iwidth, iheight, context.ITALIC)

	if j == 1 then
		width, height = context:measureText(7, Pair[i], context.CENTER)
		context:drawText(7, Pair[i], Color, -1, x1, y2, x2, context:right(), context.CENTER)
	end

	if i == Count then
		width, height = context:measureText(7, TF[j], 0)
		context:drawText(7, TF[j], Color, -1, x1 + xGap, y1, x2 + xGap, y2, context.CENTER)
	end

	if
		not Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size() - 1) or
			not Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size() - 2)
	 then
		return
	end

	ItIs = Indicator[i][j].DATA[Indicator[i][j].DATA:size() - 1]

	if math.abs(ItIs) > Level then
		Color2 = SelectColor
	else
		Color2 = -1
	end

	if ShowCells then
		context:drawRectangle(1, -1, x1 + xGap, y1 + yGap, x2 + xGap, y2 + yGap, transparency)
	end

	width, height = context:measureText(7, ItIs, context.CENTER)
	context:drawText(7, ItIs, Color, Color2, x1 + xGap, y1 + yGap, x2 + xGap, y2 + yGap, context.CENTER)
end

--///////////////////////////////////////////ALERT///////////////////////////////////////////////////////////////////////

function Activate(i, j, Text)
	if Last[i][j] == Source[i][j]:serial(Source[i][j]:size() - 1) then
		return
	end

	Last[i][j] = Source[i][j]:serial(Source[i][j]:size() - 1)

	SoundAlert(Sound)
	EmailAlert(i, j, Text)

	if Show then
		Pop(i, j, Text)
	end
end

function Pop(i, j, Text)
	local delim = "\013\010"
	local date = core.now()
	local DATA = core.dateToTable(date)

	local Date = DATA.month .. ", " .. DATA.day .. delim .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec

	core.host:execute(
		"prompt",
		1,
		Text,
		Date .. delim .. profile:id() .. delim .. Pair[i] .. delim .. TF[j] .. delim .. Text
	)
end

function SoundAlert(Sound)
	if not PlaySound then
		return
	end

	terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(i, j, Text)
	if not SendEmail then
		return
	end

	local date = core.now()
	local DATA = core.dateToTable(date)
	local delim = "\013\010"

	local Date = DATA.month .. ", " .. DATA.day .. delim .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec

	core.host:execute(
		"prompt",
		1,
		Text,
		Date .. delim .. profile:id() .. delim .. Pair[i] .. delim .. TF[j] .. delim .. Text
	)
end
