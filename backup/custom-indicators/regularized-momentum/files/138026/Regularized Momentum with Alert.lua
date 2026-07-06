-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66652

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

-- Indicator profile initialization routine

function Init()
	indicator:name("Regularized Momentum")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("Length", "Length", "", 14)
	indicator.parameters:addDouble("Lambda", "Lambda", "", 7)
	indicator.parameters:addInteger("MinMaxPeriod", "MinMaxPeriod", "", 15)
	indicator.parameters:addDouble("LevelUp", "Period", "", 90)
	indicator.parameters:addDouble("LevelDown", "Period", "", 10)
	indicator.parameters:addInteger("Multiplier", "Multiplier", "", 1)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5)

	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 255))
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5)

	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 255))
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5)

	indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5)

	indicator.parameters:addGroup("Alert Parameters")
	indicator.parameters:addString("Live", "Execution", "", "End of Turn")
	indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
	indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
	indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
	indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
	indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
	indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false)
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)

	indicator.parameters:addGroup("Alert Style")
	indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100)

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

	indicator.parameters:addGroup("Alerts Email")
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false)
	indicator.parameters:addString("Email", "Email", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

	Parameters(1, "Color Change")
	Parameters(2, "Top Line Cross")
	Parameters(3, "Center Line Cross")
	Parameters(4, "Bottom Line Cross")
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local LevelUp, LevelDown, Lambda, MinMaxPeriod, Length
local first
local source = nil
local alpha, regf1, regf2
local Oscillator, Data
local Top, Bottom, Central
local Multiplier
-- Routine

function Parameters(id, Label)
	indicator.parameters:addGroup(Label .. " Alert")

	indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true)

	indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "")
	indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND)

	indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "")
	indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND)

	indicator.parameters:addString("Label" .. id, "Label", "", Label)
end

local Number = 4
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
local ShowAlert
local Alert = {}
local AlertLevel = {}
local ToTime
local Shift = 0
local Signal

function Prepare(nameOnly)
	local name = profile:id() .. "(" .. instance.source:name() .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	ToTime = instance.parameters.ToTime

	if ToTime == 1 then
		ToTime = core.TZ_EST
	elseif ToTime == 2 then
		ToTime = core.TZ_UTC
	elseif ToTime == 3 then
		ToTime = core.TZ_LOCAL
	elseif ToTime == 4 then
		ToTime = core.TZ_SERVER
	elseif ToTime == 5 then
		ToTime = core.TZ_FINANCIAL
	elseif ToTime == 6 then
		ToTime = core.TZ_TS
	end

	OnlyOnceFlag = true
	FIRST = true
	OnlyOnce = instance.parameters.OnlyOnce
	ShowAlert = instance.parameters.ShowAlert
	Show = instance.parameters.Show
	Live = instance.parameters.Live
	UpTrendColor = instance.parameters.UpTrendColor
	DownTrendColor = instance.parameters.DownTrendColor
	Size = instance.parameters.Size

	LevelUp = instance.parameters.LevelUp
	LevelDown = instance.parameters.LevelDown
	Lambda = instance.parameters.Lambda
	MinMaxPeriod = instance.parameters.MinMaxPeriod
	Length = instance.parameters.Length
	Multiplier = instance.parameters.Multiplier

	alpha = 2.0 / (1.0 + Length)
	regf1 = (1.0 + Lambda * 2.0)
	regf2 = (1.0 + Lambda)

	Data = instance:addInternalStream(0, 0)

	source = instance.source
	first = source:first()

	Oscillator =
		instance:addStream("Oscillator", core.Line, " Oscillator", " Oscillator", instance.parameters.Up, first + 1)
	Oscillator:setWidth(instance.parameters.width)
	Oscillator:setStyle(instance.parameters.style)

	Top = instance:addStream("Top", core.Line, " Top", " Top", instance.parameters.color1, first + 1 + MinMaxPeriod)
	Top:setWidth(instance.parameters.width1)
	Top:setStyle(instance.parameters.style1)

	Bottom =
		instance:addStream("Bottom", core.Line, " Bottom", " Bottom", instance.parameters.color2, first + 1 + MinMaxPeriod)
	Bottom:setWidth(instance.parameters.width2)
	Bottom:setStyle(instance.parameters.style2)

	Central =
		instance:addStream("Central", core.Line, " Central", " Central", instance.parameters.color3, first + 1 + MinMaxPeriod)
	Central:setWidth(instance.parameters.width3)
	Central:setStyle(instance.parameters.style3)

	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()))
	Top:setPrecision(math.max(2, instance.source:getPrecision()))
	Bottom:setPrecision(math.max(2, instance.source:getPrecision()))
	Central:setPrecision(math.max(2, instance.source:getPrecision()))

	for i = 1, Number, 1 do
		Alert[i] = instance:addInternalStream(0, 0)
		AlertLevel[i] = instance:addInternalStream(0, 0)
	end

	Initialization()
	instance:ownerDrawn(true)

	Signal = instance:addInternalStream(0, 0)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		context:createFont(1, "Wingdings", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
		init = true
	end

	for period = math.max(context:firstBar(), source:first()), math.min(context:lastBar(), source:size() - 1), 1 do
		x, x1, x2 = context:positionOfBar(period)

		for Level = 1, Number, 1 do
			if Alert[Level]:hasData(period) then
				if Alert[Level][period] == 1 then
					visible, y = context:pointOfPrice(AlertLevel[Level][period])

					width, height = context:measureText(1, "\225", 0)
					context:drawText(1, "\225", UpTrendColor, -1, x - width / 2, y, x + width / 2, y + height, 0)
				elseif Alert[Level][period] == -1 then
					visible, y = context:pointOfPrice(AlertLevel[Level][period])
					width, height = context:measureText(1, "\226", 0)
					context:drawText(1, "\226", DownTrendColor, -1, x - width / 2, y - height, x + width / 2, y, 0)
				end
			end
		end
	end
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

	assert(not (SendEmail and (Email == "" or Email == nil)), "E-mail address must be specified")

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
		assert(not (PlaySound and (Up[i] == "" or Up[i] == nil)), "Sound file must be chosen")
		assert(not (PlaySoundand and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen")
	end

	RecurrentSound = instance.parameters.RecurrentSound

	for i = 1, Number, 1 do
		U[i] = nil
		D[i] = nil
	end
end

-- Indicator calculation routine
function Update(period, mode)
	if period < first then
		return
	end

	if period == first then
		Data[period] = source.median[period]
		return
	end

	if period < first + 1 then
		return
	end

	Data[period] =
		(regf1 * Data[period - 1] + alpha * (source.median[period] - Data[period - 1]) - Lambda * Data[period - 2]) / regf2
	Oscillator[period] = ((Data[period] - Data[period - 1]) / Data[period]) * Multiplier

	if Oscillator[period] > Oscillator[period - 1] then
		Oscillator:setColor(period, instance.parameters.Up)
		Signal[period] = 1
	elseif Oscillator[period] < Oscillator[period - 1] then
		Signal[period] = -1
		Oscillator:setColor(period, instance.parameters.Down)
	else
		Signal[period] = 0
		Oscillator:setColor(period, instance.parameters.Neutral)
	end

	if period < first + 1 + MinMaxPeriod then
		return
	end

	local min, max = mathex.minmax(Oscillator, period - MinMaxPeriod + 1, period)

	local range = max - min

	Top[period] = min + LevelUp * range / 100.0
	Bottom[period] = min + LevelDown * range / 100.0
	Central[period] = min + 0.5 * range

	if Live ~= "Live" then
		period = period - 1
		Shift = 1
	else
		Shift = 0
	end

	if period < first then
		return
	end

	Activate(1, period);
	Activate(2, period);
	Activate(3, period);
	Activate(4, period);
end

function Activate(id, period)
	Alert[id][period] = 0

	if id == 1 and ON[id] then
		if Signal[period] == 1 and Signal[period - 1] ~= 1 then
			Alert[id][period] = 1
			AlertLevel[id][period] = Oscillator[period]

			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Up Trend ")
				SendAlert(Label[id], " Up Trend ")
				Pop(Label[id], " Up Trend ", period)
				OnlyOnceFlag = false
			end
		elseif Signal[period] == -1 and Signal[period - 1] ~= -1 then
			Alert[id][period] = -1
			AlertLevel[id][period] = Oscillator[period]

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Down Trend ")
				Pop(Label[id], " Down Trend ", period)
				SendAlert(Label[id], " Down Trend ")
				OnlyOnceFlag = false
			end
		elseif Signal[period] == 0 and Signal[period - 1] ~= 0 then
			Alert[id][period] = -1
			AlertLevel[id][period] = Oscillator[period]

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Down Trend ")
				Pop(Label[id], " Down Trend ", period)
				SendAlert(Label[id], " Down Trend ")
				OnlyOnceFlag = false
			end
		end
	end
	if id == 2 and ON[id] then
		if core.crossesOver(Oscillator, Top, period) then
			Alert[id][period] = 1
			AlertLevel[id][period] = Oscillator[period]

			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Cross Over ")
				SendAlert(Label[id], " Cross Over ")
				Pop(Label[id], " Cross Over ", period)
				OnlyOnceFlag = false
			end
		elseif core.crossesUnder(Oscillator, Top, period) then
			Alert[id][period] = -1
			AlertLevel[id][period] = Oscillator[period]

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Cross Under ")
				Pop(Label[id], " Cross Under ", period)
				SendAlert(Label[id], " Cross Under ")
				OnlyOnceFlag = false
			end
		end
	end
	if id == 3 and ON[id] then
		if core.crossesOver(Oscillator, Central, period) then
			Alert[id][period] = 1
			AlertLevel[id][period] = Oscillator[period]

			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Cross Over ")
				SendAlert(Label[id], " Cross Over ")
				Pop(Label[id], " Cross Over ", period)
				OnlyOnceFlag = false
			end
		elseif core.crossesUnder(Oscillator, Central, period) then
			Alert[id][period] = -1
			AlertLevel[id][period] = Oscillator[period]

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Cross Under ")
				Pop(Label[id], " Cross Under ", period)
				SendAlert(Label[id], " Cross Under ")
				OnlyOnceFlag = false
			end
		end
	end
	if id == 4 and ON[id] then
		if core.crossesOver(Oscillator, Bottom, period) then
			Alert[id][period] = 1
			AlertLevel[id][period] = Oscillator[period]

			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Cross Over ")
				SendAlert(Label[id], " Cross Over ")
				Pop(Label[id], " Cross Over ", period)
				OnlyOnceFlag = false
			end
		elseif core.crossesUnder(Oscillator, Bottom, period) then
			Alert[id][period] = -1
			AlertLevel[id][period] = Oscillator[period]

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Cross Under ")
				Pop(Label[id], " Cross Under ", period)
				SendAlert(Label[id], " Cross Under ")
				OnlyOnceFlag = false
			end
		end
	end

	if FIRST then
		FIRST = false
	end
end

function AsyncOperationFinished(cookie, success, message)
end

function SoundAlert(Sound)
	if not PlaySound then
		return
	end

	terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(label, Subject)
	if not SendEmail then
		return
	end

	local now = core.host:execute("getServerTime")
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
	local DATA = core.dateToTable(now)

	local delim = "\013\010"
	local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject
	local Symbol = "Instrument : " .. source:instrument()
	local Time =
		" Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

	local TF = "Time Frame : " .. source:barSize()
	local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time

	terminal:alertEmail(Email, profile:id(), text)
end

function Pop(AlertLabel, AlertText, period)
	if not Show then
		return
	end

	local now = core.host:execute("getServerTime")
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
	local DATA = core.dateToTable(now)

	local delim = "\013\010"

	local Symbol = "Instrument : " .. source:instrument()
	local TF = "Time Frame : " .. source:barSize()
	local Time =
		"Date : " ..
		DATA.month .. " / " .. DATA.day .. delim .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec
	local Text = Symbol .. delim .. TF .. delim .. Time .. delim .. AlertLabel .. ":" .. AlertText
	core.host:execute("prompt", 1, profile:id(), Text)
end

function SoundAlert(Sound)
	if not PlaySound then
		return
	end

	terminal:alertSound(Sound, RecurrentSound)
end

function EmailAlert(AlertLabel, AlertText, period)
	if not SendEmail then
		return
	end

	local delim = "\013\010"

	local now = core.host:execute("getServerTime")
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
	local DATA = core.dateToTable(now)

	local Symbol = "Instrument : " .. source:instrument()
	local TF = "Time Frame : " .. source:barSize()
	local Time =
		"Date : " ..
		DATA.month .. " / " .. DATA.day .. delim .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

	local Text = Symbol .. delim .. TF .. delim .. Time .. delim .. AlertLabel .. ":" .. AlertText

	terminal:alertEmail(Email, profile:id(), Text)
end

function SendAlert(AlertLabel, AlertText, period)
	if not ShowAlert then
		return
	end

	local delim = "\013\010"

	local now = core.host:execute("getServerTime")
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
	local DATA = core.dateToTable(now)

	local Symbol = "Instrument : " .. source:instrument()
	local TF = "Time Frame : " .. source:barSize()
	local Time =
		"Date : " ..
		DATA.month .. " / " .. DATA.day .. delim .. "Time :" .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

	local Text = Symbol .. delim .. TF .. delim .. Time .. delim .. AlertLabel .. ":" .. AlertText

	terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW))
end
