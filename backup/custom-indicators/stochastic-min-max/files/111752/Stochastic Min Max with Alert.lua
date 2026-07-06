-- Id: 18673
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=64558

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Stochastic Min Max")
	indicator:description("Shows the location of the  high/low price achieved between two Stochastic crosses")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("iK", "Number of periods for %K", "", 25, 2, 1000)
	indicator.parameters:addInteger("iSD", "%D slowing periods", "", 25, 2, 1000)
	indicator.parameters:addInteger("iD", "The number of periods for %D.", "", 25, 2, 1000)

	indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA")
	indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("KS", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("KS", "FS", "", "FS")

	indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA")
	indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA")

	indicator.parameters:addBoolean("TrendFilter", "Use Trend Filter", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("UpColor", "Period Max Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("DownColor", "Period Min Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("Size", "Font Size", "", 15, 1, 1000)

	indicator.parameters:addGroup("Alert Parameters")
	indicator.parameters:addString("Live", "Execution", "", "Live")
	indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false)
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)

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

	indicator.parameters:addFile("Up" .. id, Label .. " Max Sound", "", "")
	indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND)

	indicator.parameters:addFile("Down" .. id, Label .. " Min Sound", "", "")
	indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND)

	indicator.parameters:addString("Label" .. id, "Label", "", Label)
end

local Number = 1
local Up = {}
local Down = {}
local Label = {}
local ON = {}

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

local OnlyOnceFlag
local font
local ShowAlert

local Shift = 0
local Alert = {}
local AlertLevel = {}

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local UpColor, DownColor
local DS, KS
local iK, iSD, iD
local Size
local Stochastic = nil
local font
local Trend
local TrendFilter
function Prepare(nameOnly)
	OnlyOnceFlag = true
	FIRST = true
	OnlyOnce = instance.parameters.OnlyOnce
	ShowAlert = instance.parameters.ShowAlert
	Show = instance.parameters.Show
	Live = instance.parameters.Live

	TrendFilter = instance.parameters.TrendFilter
	DS = instance.parameters.DS
	KS = instance.parameters.KS
	iK = instance.parameters.iK
	iSD = instance.parameters.iSD
	iD = instance.parameters.iD
	Size = instance.parameters.Size
	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor

	source = instance.source

	local name =
		profile:id() ..
		"(" ..
			source:name() ..
				", " .. source:barSize() .. ", " .. iK .. ", " .. iSD .. ", " .. iD .. ", " .. KS .. ", " .. DS .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Stochastic = core.indicators:create("STOCHASTIC", source, iK, iSD, iD, KS, DS)
	first = Stochastic.D:first()
	Trend = instance:addInternalStream(0, 0)

	instance:ownerDrawn(true)

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
	period = period - 1
	Stochastic:update(mode)

	if Stochastic.K[period] > Stochastic.D[period] and Stochastic.K[period - 1] <= Stochastic.D[period - 1] then
		Trend[period] = 1
	end

	if Stochastic.K[period] < Stochastic.D[period] and Stochastic.K[period - 1] >= Stochastic.D[period - 1] then
		Trend[period] = -1
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
	if id == 1 and ON[id] then
		if Trend[period] == 1 and Trend[period - 1] ~= 1 then
			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 2 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Max ", period)
				SendAlert(Label[id], " Max ", period)
				Pop(Label[id], " Max ", period)
				OnlyOnceFlag = false
			end
		elseif Trend[period] == -1 and Trend[period - 1] ~= -1 then
			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 2 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Min ", period)
				Pop(Label[id], " Min ", period)
				SendAlert(Label[id], " Min ", period)
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

function EmailAlert(label, Subject, period)
	if not SendEmail then
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

function Pop(label, Subject, period)
	if not Show then
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

	core.host:execute("prompt", 1, label, text)
end

function SendAlert(label, Subject, period)
	if not ShowAlert then
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

	terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW))
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

	local min, max, minpos, maxpos
	local from

	for period = math.max(first + 1, context:firstBar()), math.min(context:lastBar(), source:size() - 1), 1 do
		if Trend:hasData(period) then
			if Trend[period] == 1 or Trend[period] == -1 then
				from = Find(period)
				min, max, minpos, maxpos = mathex.minmax(source, from, period - 1)

				if (Trend[period] ~= 1 and TrendFilter) or not TrendFilter then
					x1, x = context:positionOfBar(maxpos)
					visible, y1 = context:pointOfPrice(max)
					Text = "\225"
					width, height = context:measureText(1, Text, 0)
					context:drawText(1, Text, UpColor, -1, x1 - width / 2, y1 - height, x1 + width / 2, y1, 0)
				end
				if (Trend[period] ~= -1 and TrendFilter) or not TrendFilter then
					x2, x = context:positionOfBar(minpos)
					visible, y2 = context:pointOfPrice(min)
					Text = "\226"
					width, height = context:measureText(1, Text, 0)
					context:drawText(1, Text, DownColor, -1, x2 - width / 2, y2, x2 + width / 2, y2 + height, 0)
				end
			end
		end
	end
end

function Find(Start)
	local from

	for period = Start - 1, first, -1 do
		if Trend[period] == 1 or Trend[period] == -1 then
			from = period
			break
		end
	end

	return from
end
