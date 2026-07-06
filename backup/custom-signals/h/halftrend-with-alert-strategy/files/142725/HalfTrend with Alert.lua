-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=29&t=70747

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("HalfTrend")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Amplitude", "Period", "", 2, 2, 5000)
	indicator.parameters:addBoolean("strategy_mode", "Strategy mode", "", false);

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("UpColor", "Up Trend color", "Line Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("DownColor", "Down Trend color", "Line Color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width1", "Line Line width", "Line width", 1, 1, 5)
	indicator.parameters:addInteger("style1", "Line Line style", "Line style", core.LINE_SOLID)

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

	Parameters(1, "Alert")
end

function Parameters(id, Label)
	indicator.parameters:addGroup(Label .. " Alert")

	indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true)

	indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "")
	indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND)

	indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "")
	indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND)

	indicator.parameters:addString("Label" .. id, "Label", "", Label)
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
local ShowAlert
local Alert = {}
local AlertLevel = {}
local ToTime
local Shift = 0

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first
local source
local Amplitude
local HalfTrend
local High, Low
--local up, dowm;
local UpColor, DownColor
local minhighprice, maxlowprice
local trend
-- Routine
function Prepare()
	Amplitude = instance.parameters.Amplitude
	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor
	source = instance.source

	local name = profile:id() .. "(" .. source:name() .. ", " .. Amplitude .. ")"
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

	High = core.indicators:create("MVA", source.high, Amplitude)
	Low = core.indicators:create("MVA", source.low, Amplitude)
	first = Low.DATA:first()
	trend = instance:addInternalStream(0, 0)
	minhighprice = instance:addInternalStream(0, 0)
	maxlowprice = instance:addInternalStream(0, 0)

	HalfTrend = instance:addStream("HalfTrend", core.Line, name .. ".HalfTrend", "HalfTrend", UpColor, first)
	HalfTrend:setWidth(instance.parameters.width1)
	HalfTrend:setStyle(instance.parameters.style1)

	for i = 1, Number, 1 do
		if instance.parameters.strategy_mode then
			Alert[i] = instance:addStream("signal", core.Line, name .. ".Signal", "Signal", UpColor, first)
		else
			Alert[i] = instance:addInternalStream(0, 0)
		end
		AlertLevel[i] = instance:addInternalStream(0, 0)
	end

	Initialization()
	instance:ownerDrawn(true)
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
	Low:update(mode)
	High:update(mode)

	if period == first then
		minhighprice[period - 1] = source.low[period]
		maxlowprice[period - 1] = source.high[period]
	end

	if period < first then
		return
	end

	local min, max = mathex.minmax(source, period - Amplitude + 1, period)
	trend[period] = trend[period - 1]
	maxlowprice[period] = maxlowprice[period - 1]
	minhighprice[period] = minhighprice[period - 1]

	if trend[period - 1] == 0 then
		maxlowprice[period] = math.max(min, maxlowprice[period - 1])

		if (High.DATA[period] < maxlowprice[period] and source.close[period] < source.low[period - 1]) then
			trend[period] = 1.0
			minhighprice[period] = max
		end
	else
		minhighprice[period] = math.min(max, minhighprice[period - 1])

		if (Low.DATA[period] > minhighprice[period] and source.close[period] > source.high[period - 1]) then
			trend[period] = 0.0
			maxlowprice[period] = min
		end
	end
	if (trend[period] == 0.0) then
		if (trend[period - 1] ~= 0.0) then
			HalfTrend[period] = HalfTrend[period - 1]
		else
			HalfTrend[period] = math.max(maxlowprice[period], HalfTrend[period - 1])
		end
	else
		if (trend[period - 1] ~= 1.0) then
			HalfTrend[period] = HalfTrend[period - 1]
		else
			HalfTrend[period] = math.min(minhighprice[period], HalfTrend[period - 1])
		end
	end

	if trend[period] == 0 then
		HalfTrend:setColor(period, UpColor)
	else
		HalfTrend:setColor(period, DownColor)
	end

	if Live ~= "Live" then
		period = period - 1
		Shift = 1
	else
		Shift = 0
	end

	Activate(1, period)
end

function Activate(id, period)
	Alert[id][period] = 0

	if id == 1 and ON[id] then
		if trend[period] == 0 and trend[period - 1] ~= 0 then
			Alert[id][period] = 1
			AlertLevel[id][period] = HalfTrend[period]

			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Cross Over ")
				SendAlert(Label[id], " Crossed over ")
				Pop(Label[id], " Cross Over ", period)
				OnlyOnceFlag = false
			end
		elseif trend[period] == 1 and trend[period - 1] ~= 1 then
			Alert[id][period] = -1
			AlertLevel[id][period] = HalfTrend[period]

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Cross Under ")
				Pop(Label[id], " Cross Under ", period)
				SendAlert(Label[id], " Crossed under ")
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
