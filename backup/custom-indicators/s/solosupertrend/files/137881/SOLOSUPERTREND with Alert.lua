-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69993

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Solo Super Trend")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	
	indicator.parameters:addGroup("Up Parameters")
	indicator.parameters:addInteger("atr_period_up", "ATR period", "", 14)
	indicator.parameters:addString("mode_up", "Mode", "", "factor");
	indicator.parameters:addStringAlternative("mode_up", "Factor", "", "factor");
	indicator.parameters:addStringAlternative("mode_up", "Percentage", "", "%");
	indicator.parameters:addStringAlternative("mode_up", "Pips", "", "pips");
	indicator.parameters:addDouble("Factor_up", "Factor", "", 1.0)
	indicator.parameters:addDouble("percentage_up", "Percentage", "", 100)
	indicator.parameters:addDouble("pips_up", "Pips_up", "", 100)
	
	indicator.parameters:addGroup("Down Parameters")
	
		indicator.parameters:addInteger("atr_period_down", "ATR period", "", 14)
	indicator.parameters:addString("mode_down", "Mode", "", "factor");
	indicator.parameters:addStringAlternative("mode_down", "Factor", "", "factor");
	indicator.parameters:addStringAlternative("mode_down", "Percentage", "", "%");
	indicator.parameters:addStringAlternative("mode_down", "Pips", "", "pips");
	indicator.parameters:addDouble("Factor_down", "Factor", "", 1.0)
	indicator.parameters:addDouble("percentage_down", "Percentage", "", 100)
	indicator.parameters:addDouble("pips_down", "Pips_up", "", 100)
	
	indicator.parameters:addGroup("Style")

	indicator.parameters:addColor("SOLOST_color_Up", "SOLOST Color Up", "Color", core.colors().Green)
	indicator.parameters:addColor("SOLOST_color_Down", "SOLOST Color Down", "Color", core.colors().Red)
	indicator.parameters:addInteger("SOLOST_width", "SOLOST Width", "Width", 1, 1, 5)
	indicator.parameters:addInteger("SOLOST_style", "SOLOST Style", "Style", core.LINE_SOLID)
	indicator.parameters:setFlag("SOLOST_style", core.FLAG_LINE_STYLE)

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

	Parameters(1, "Trend")
	Parameters(2, "Price / Line")
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

local Number = 2
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

local source, atr, SOLOST, Factor
local Signal
local calcmode, percentage, pips
function Prepare(nameOnly)
	source = instance.source
	local name = string.format("%s(%s)", profile:id(), source:name())
	instance:name(name)
	if nameOnly then
		return
	end
	percentage_down = instance.parameters.percentage_down;
	calcmode_down = instance.parameters.mode_down;
	pips_down = instance.parameters.pips_down;
	
	percentage_up = instance.parameters.percentage_up;
	calcmode_up = instance.parameters.mode_up;
	pips_up = instance.parameters.pips_up;
	
	Factor_up = instance.parameters.Factor_up;
	Factor_down = instance.parameters.Factor_down;
	
	
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

	Factor = instance.parameters.Factor
	atr_up = core.indicators:create("ATR", source, instance.parameters.atr_period_up)
	atr_down = core.indicators:create("ATR", source, instance.parameters.atr_period_down)
	SOLOST =
		instance:addStream(
		"SOLOST",
		core.Line,
		"SOLOST",
		"SOLOST",
		instance.parameters.SOLOST_color_Up,
		math.max(atr_up.DATA:first(),atr_down.DATA:first()) + 1,
		0
	)
	SOLOST:setWidth(instance.parameters.SOLOST_width)
	SOLOST:setStyle(instance.parameters.SOLOST_style)

	Signal = instance:addInternalStream(0, 0)

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

function Update(period, mode)
	atr_up:update(mode)
	atr_down:update(mode)
	
	if period == 0 or not atr_up.DATA:hasData(period - 1) or not atr_down.DATA:hasData(period - 1)  then
		return
	end
	if calcmode_up == "factor" then
		Up = source.close[period] - Factor_up * atr_up.DATA[period - 1]
	 
	elseif calcmode_up == "%" then
		Up = source.close[period] - percentage_up * atr_up.DATA[period - 1] / 100
	 
	elseif calcmode_up == "pips" then
		Up = source.close[period] - pips_up * source:pipSize()
	 
	end
	
	
	if calcmode_down == "factor" then
		 
		Dn = source.close[period] + Factor_down * atr_down.DATA[period - 1]
	elseif calcmode_down == "%" then
	 
		Dn = source.close[period] + percentage_down * atr_down.DATA[period - 1] / 100
	elseif calcmode_down == "pips" then
	 
		Dn = source.close[period] + pips_down * source:pipSize()
	end
--atr
	Signal[period] = Signal[period - 1]

	if not SOLOST:hasData(period - 1) then
		SOLOST[period] = Up
	elseif source.close[period - 1] > SOLOST[period - 1] then
		SOLOST[period] = math.max(Up, SOLOST[period - 1])
		Signal[period] = 1
		SOLOST:setColor(period, instance.parameters.SOLOST_color_Up)
	else
		SOLOST[period] = math.min(SOLOST[period - 1], Dn)
		Signal[period] = -1
		SOLOST:setColor(period, instance.parameters.SOLOST_color_Down)
	end

	Activate(1, period)
	Activate(2, period)
end

function Activate(id, period)
	Alert[id][period] = 0

	if id == 1 and ON[id] then
		if Signal[period] == 1 and Signal[period - 1] ~= 1 then
			Alert[id][period] = 1
			AlertLevel[id][period] = SOLOST[period]

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
			AlertLevel[id][period] = SOLOST[period]

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
		if source.close[period] > SOLOST[period] and source.close[period - 1] <= SOLOST[period - 1] then
			Alert[id][period] = 1
			AlertLevel[id][period] = SOLOST[period]

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
		elseif source.close[period] < SOLOST[period] and source.close[period - 1] >= SOLOST[period - 1] then
			Alert[id][period] = -1
			AlertLevel[id][period] = SOLOST[period]

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
