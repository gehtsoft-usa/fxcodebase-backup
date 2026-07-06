-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64970
-- Id: 18800
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
	indicator:name("Advanced Fractal Based Support/Resistance lines breakout alert")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 5, 99)
	indicator.parameters:addBoolean("ShowLine", "Show Lines", "", false)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("R_color", "Up fractal color", "Up fractal color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("S_color", "Down fractal color", "Down fractal color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5)

	indicator.parameters:addGroup("Alert Parameters")
	indicator.parameters:addString("Live", "Execution", "", "Live")
	indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
	indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
	indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
	indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
	indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
	indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)

	indicator.parameters:addString(
		"ALLOWEDSIDE",
		"Allowed side",
		"Allowed side for trading or signaling, can be Sell, Buy or Both",
		"Both"
	)
	indicator.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
	indicator.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
	indicator.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

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

	Parameters(1, "AFBSR Break")

	indicator.parameters:addBoolean("strategy_output", "Strategy output", "", false)
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
local font
local ShowAlert
local ToTime

local Shift = 0
local Alert = {}
local AlertLevel = {}
-- Routine

local source
local S, R
local frame = 0
local Rez = 0
local ShowLine

local ALLOWEDSIDE

local output;

function Prepare()
	source = instance.source
	ShowLine = instance.parameters.ShowLine

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

	frame = instance.parameters.Frame
	ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE

	OnlyOnceFlag = true
	FIRST = true
	OnlyOnce = instance.parameters.OnlyOnce
	ShowAlert = instance.parameters.ShowAlert
	Show = instance.parameters.Show
	Live = instance.parameters.Live
	UpTrendColor = instance.parameters.UpTrendColor
	DownTrendColor = instance.parameters.DownTrendColor
	Size = instance.parameters.Size

	if math.mod(frame, 2) ~= 0 then
		frame = frame + 1
	end

	first = source:first()

	local name = profile:id() .. " ( " .. frame - 1 .. " )"
	instance:name(name)

	if nameOnly then
		return;
	end
	if ShowLine then
		R = instance:addStream("R", core.Dot, name .. ".R", "R", instance.parameters.R_color, first)
		S = instance:addStream("S", core.Dot, name .. ".S", "S", instance.parameters.S_color, first)
		R:setWidth(instance.parameters.widthLinReg)
		S:setWidth(instance.parameters.widthLinReg)
	else
		R = instance:addInternalStream(first, 0)
		S = instance:addInternalStream(first, 0)
	end
	output = instance:addStream("OUTPUT", core.Line, name .. ".OUTPUT", "OUTPUT", instance.parameters.R_color, first)

	for i = 1, Number, 1 do
		Alert[i] = instance:addInternalStream(0, 0)
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
				if Alert[Level][period] == 1 and ALLOWEDSIDE ~= "Sell" then
					visible, y = context:pointOfPrice(AlertLevel[Level][period])

					width, height = context:measureText(1, "\225", 0)
					context:drawText(1, "\225", UpTrendColor, -1, x - width / 2, y, x + width / 2, y + height, 0)
				elseif Alert[Level][period] == -1 and ALLOWEDSIDE ~= "Buy" then
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

function Update(period, mode)
	if period < first then
		return
	end

	local test = 0

	local hof = frame
	local i
	local count = 0

	for i = 1, frame, 1 do
		if hof > 1 then
			hof = hof - 2
			count = count + 1
		else
			count = count - 1
			break
		end
	end

	if (period < frame) then
		return
	end

	local x = period - count * 2

	local curr = source.high[period - count]

	for i = x, period, 1 do
		if curr > source.high[i] and i ~= (period - count) then
			test = test + 1
		end
	end

	if test == period - x then
		R[period - 2] = curr
		R[period - 1] = curr
		R[period] = curr
	else
		if R:hasData(period - 1) then
			R[period] = R[period - 1]
		end
	end

	test = 0

	curr = source.low[period - count]

	for i = x, period, 1 do
		if curr < source.low[i] and i ~= (period - count) then
			test = test + 1
		end
	end

	if test == period - x then
		S[period - 2] = curr
		S[period - 1] = curr
		S[period] = curr
	else
		if S:hasData(period - 1) then
			S[period] = S[period - 1]
		end
	end

	if Live ~= "Live" then
		period = period - 1
		Shift = 1
	else
		Shift = 0
	end

	if period < first then
		return
	end

	Activate(1, period)
end

function Activate(id, period)
	Alert[id][period] = 0

	if id == 1 and ON[id] then
		if source.close[period] > R[period] and source.close[period - 1] <= R[period - 1] and R[period] == R[period - 1] then
			Alert[id][period] = 1
			AlertLevel[id][period] = source.low[period]

			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)

				if ALLOWEDSIDE ~= "Sell" then
					SoundAlert(Up[id])
					EmailAlert(Label[id], " Cross Over ")
					SendAlert(Label[id], " Crossed over ")
					Pop(Label[id], " Cross Over ", period)
				end
				output[period] = 1;

				OnlyOnceFlag = false
			end
		elseif source.close[period] < S[period] and source.close[period - 1] >= S[period - 1] and S[period] == S[period - 1] then
			Alert[id][period] = -1
			AlertLevel[id][period] = source.high[period]

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)

				if ALLOWEDSIDE ~= "Buy" then
					SoundAlert(Down[id])
					EmailAlert(Label[id], " Cross Under ")
					Pop(Label[id], " Cross Under ", period)
					SendAlert(Label[id], " Crossed under ")
				end
				output[period] = -1;

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

function Pop(label, Subject)
	if not Show then
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

	core.host:execute("prompt", 1, label, text)
end

function SendAlert(label, Subject)
	if not ShowAlert then
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

	terminal:alertMessage(source:instrument(), source[NOW], text, now)
end
