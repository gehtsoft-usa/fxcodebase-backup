-- Id: 16248

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63599

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
	indicator:name("Doji Support Resistance")
	indicator:description(" ")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("Length", "Line Length", "", 100, 1, 1000)
	indicator.parameters:addDouble("Delta", "Max Open/Close difference as percentage of High/Low Range", "", 0, 1, 100)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Support Resistance color", "Support Resistance color", core.rgb(0, 0, 255))
	indicator.parameters:addColor("Zone", "Zone color", "Zone color", core.rgb(128, 128, 128))

	indicator.parameters:addDouble("transparency", "Zone Transparency", "Zone Transparency", 50)

	indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5)
	indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID)
	indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Alert Parameters")
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live")
	indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false)
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)

	indicator.parameters:addGroup("Alert Style")
	indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100)

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

	indicator.parameters:addGroup("Alerts Email")
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
	indicator.parameters:addString("Email", "Email", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

	Parameters(1, "MA Cross")
end

local source
local Rez = 0
local Size
local id
local Lenght
local DATE = {}
local Range
local Delta
local transparency

function Parameters(idn, Label)
	indicator.parameters:addGroup(Label .. " Alert")

	indicator.parameters:addBoolean("ON" .. idn, "Show " .. Label .. " Alert", "", true)

	indicator.parameters:addFile("Up" .. idn, Label .. " Cross Over Sound", "", "")
	indicator.parameters:setFlag("Up" .. idn, core.FLAG_SOUND)

	indicator.parameters:addFile("Down" .. idn, Label .. " Cross Under Sound", "", "")
	indicator.parameters:setFlag("Down" .. idn, core.FLAG_SOUND)

	indicator.parameters:addString("Label" .. idn, "Label", "", Label)
end

local Number = 1

local Up = {}
local Down = {}
local Label = {}
local ON = {}
local Size
local Email
local SendEmail
local RecurrentSound, SoundFile
local Show
local Alert
local PlaySound
local Live
local FIRST = true
local OnlyOnce
local U = {}
local D = {}
local UpTrendColor, DownTrendColor
local OnlyOnceFlag
local font
local ShowAlert
local Shift = 0
local Length

function Prepare(nameOnly)
	OnlyOnceFlag = true
	FIRST = true
	OnlyOnce = instance.parameters.OnlyOnce
	ShowAlert = instance.parameters.ShowAlert
	Show = instance.parameters.Show
	Live = instance.parameters.Live
	UpTrendColor = instance.parameters.UpTrendColor
	DownTrendColor = instance.parameters.DownTrendColor
	Size = instance.parameters.Size
	font = core.host:execute("createFont", "Wingdings", Size, false, false)

	source = instance.source
	Length = instance.parameters.Length
	Delta = instance.parameters.Delta

	first = source:first()

	local name = profile:id()
	instance:name(name)

	if (nameOnly) then
		return
	end

	Range = instance:addInternalStream(0, 0)

	instance:ownerDrawn(true)

	id = 0

	Initialization()
end

function Initialization()
	SendEmail = instance.parameters.SendEmail

	local i
	for i = 1, Number, 1 do
		Label[i] = instance.parameters:getString("Label" .. i)
		ON[i] = instance.parameters:getBoolean("ON" .. i)
	end

	if SendEmail then
		Email = instance.parameters.Email
	else
		Email = nil
	end
	assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

	PlaySound = instance.parameters.PlaySound
	if PlaySound then
		for i = 1, Number, 1 do
			Up[i] = instance.parameters:getString("Up" .. i)
			Down[i] = instance.parameters:getString("Down" .. i)
		end
	else
		for i = 1, Number, 1 do
			Up[i] = nil
			Down[i] = nil
		end
	end

	for i = 1, Number, 1 do
		assert(not (PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen")
		assert(not (PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen")
	end

	RecurrentSound = instance.parameters.RecurrentSound

	for i = 1, Number, 1 do
		U[i] = nil
		D[i] = nil
	end
end

function Update(period)
	if period < first then
		id = 0
		return
	end

	period = period - 1

	Range[period] = ((source.high[period] - source.low[period]) / 100) * Delta

	if (math.abs(source.open[period] - source.close[period]) <= Range[period]) then
		id = id + 1
		DATE[id] = source:date(period)
	end

	if period < source:size() - 2 then
		return
	end

	if Live ~= "Live" then
		period = period - 1
		Shift = 1
	else
		Shift = 0
	end

	local Index

	for i = 1, id, 1 do
		Index = core.findDate(source, DATE[i], false)

		if Index ~= -1 and (source:size() - 2 - Shift) <= (Index + Length) then
			Activate(i, period, source.close[Index])
		end
	end
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createPen(1, context.SOLID, 1, instance.parameters.Color)
		context:createPen(2, context.SOLID, 1, instance.parameters.Zone)
		transparency = context:convertTransparency(instance.parameters.transparency)
		context:createSolidBrush(3, instance.parameters.Zone)
		init = true
	end

	for i = 1, id, 1 do
		local Index = core.findDate(source, DATE[i], false)

		if Index ~= -1 then
			visible, y = context:pointOfPrice(source.close[Index])
			visible, y1 = context:pointOfPrice(source.high[Index])
			visible, y2 = context:pointOfPrice(source.low[Index])
			x, x1 = context:positionOfBar(Index)
			x, _, x2 = context:positionOfBar(Index + Length)
			context:drawLine(1, x1, y, x2, y)

			context:drawRectangle(2, 3, x1, y1, x2, y2, transparency)
		end
	end
end

function ReleaseInstance()
	core.host:execute("deleteFont", font)
end

function Activate(Activate_id, period, Level)
	--id

	if ON[1] then
		core.host:execute("removeLabel", Activate_id)

		if source.close[period] > Level and source.close[period - 1] <= Level then
			core.host:execute(
				"drawLabel1",
				Activate_id,
				source:date(period),
				core.CR_CHART,
				Level,
				core.CR_CHART,
				core.H_Center,
				core.V_Bottom,
				font,
				UpTrendColor,
				"\225"
			)

			D[Activate_id] = nil

			if U[Activate_id] ~= source:serial(period) and period == source:size() - 2 - Shift and not FIRST then
				OnlyOnceFlag = false
				U[Activate_id] = source:serial(period)
				SoundAlert(Up[1])
				EmailAlert(Label[1], " Cross Over", period)
				SendAlert("Crossed over")

				Pop(Label[1], " Cross Over ")
			end
		elseif source.close[period] < Level and source.close[period - 1] >= Level then
			core.host:execute(
				"drawLabel1",
				Activate_id,
				source:date(period),
				core.CR_CHART,
				Level,
				core.CR_CHART,
				core.H_Center,
				core.V_Top,
				font,
				DownTrendColor,
				"\226"
			)

			U[Activate_id] = nil

			if D[Activate_id] ~= source:serial(period) and period == source:size() - 2 - Shift and not FIRST then
				OnlyOnceFlag = false
				D[Activate_id] = source:serial(period)
				SoundAlert(Down[1])
				EmailAlert(Label[1], " Cross Under", period)

				Pop(Label[1], " Cross Under ")
				SendAlert("Crossed under")
			end
		end
	end

	if FIRST then
		FIRST = false
	end
end

function AsyncOperationFinished(cookie, success, message)
end

function Pop(label, note)
	if not Show then
		return
	end

	core.host:execute(
		"prompt",
		1,
		label,
		" ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " : " .. note
	)
end

function SendAlert(message)
	if not ShowAlert then
		return
	end

	terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW))
end

function SoundAlert(Sound)
	if not PlaySound then
		return
	end

	if OnlyOnce and OnlyOnceFlag == false then
		return
	end

	terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(label, Subject, period)
	if not SendEmail then
		return
	end

	if OnlyOnce and OnlyOnceFlag == false then
		return
	end

	local date = source:date(period)
	local DATA = core.dateToTable(date)

	local delim = "\013\010"
	local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
	local Symbol = "Instrument : " .. source:instrument()
	local Time =
		" Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

	local TF = "Time Frame : " .. source:barSize()
	local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time

	terminal:alertEmail(Email, profile:id(), text)
end
