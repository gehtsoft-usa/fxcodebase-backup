-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62724

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--|                         https://AppliedMachineLearning.systems   |
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
	indicator:name("Heikin-Ashi Extreme TMA line indicator")
	indicator:description("Heikin-Ashi Extreme TMA line indicator")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator:setTag("replaceSource", "t")

	indicator.parameters:addGroup("Mode")
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live")
	indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addString("Price", "Price Source", "", "Chart")
	indicator.parameters:addStringAlternative("Price", "Chart", "", "Chart")
	indicator.parameters:addStringAlternative("Price", "HA", "", "HA")

	indicator.parameters:addInteger("TMA_Period", "TMA period", "", 56)
	indicator.parameters:addInteger("ATR_Period", "ATR period", "", 100)
	indicator.parameters:addDouble("ATR_Mult", "ATR multiplier", "", 2)
	indicator.parameters:addDouble("TrendThreshold", "TrendThreshold", "", 0.5)
	indicator.parameters:addBoolean("ShowTMA", "Show TMA", "", true)
	indicator.parameters:addBoolean("Redraw", "Redraw", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("TMA_NEclr", "TMA neutral Color", "TMA neutral Color", core.rgb(128, 128, 128))
	indicator.parameters:addColor("TMA_UPclr", "TMA UP Color", "TMA UP Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("TMA_DNclr", "TMA DN Color", "TMA DN Color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("TMAwidth", "TMA width", "TMA width", 2, 1, 5)
	indicator.parameters:addInteger("TMAstyle", "TMA style", "TMA style", core.LINE_SOLID)
	indicator.parameters:setFlag("TMAstyle", core.FLAG_LINE_STYLE)
	indicator.parameters:addColor("Bandclr", "Band Color", "Band Color", core.rgb(128, 128, 0))
	indicator.parameters:addInteger("Bandwidth", "Band width", "Band width", 1, 1, 5)
	indicator.parameters:addInteger("Bandstyle", "Band style", "Band style", core.LINE_DASH)
	indicator.parameters:setFlag("Bandstyle", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Alert Style")
	indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100)

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)

	indicator.parameters:addGroup("Alerts Email")
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
	indicator.parameters:addString("Email", "Email", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false)

	Parameters(1, "Trend Change")
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

local first
local source = nil
local TMA_Period
local ATR_Period
local ATR_Mult
local TrendThreshold
local ShowTMA
local Redraw
local TMA = nil
local ATR
local Upper = nil
local Lower = nil
local open, close, high, low
local Price, isource

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
local HA

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

	Price = instance.parameters.Price

	source = instance.source
	TMA_Period = instance.parameters.TMA_Period
	ATR_Period = instance.parameters.ATR_Period
	ATR_Mult = instance.parameters.ATR_Mult
	TrendThreshold = instance.parameters.TrendThreshold
	ShowTMA = instance.parameters.ShowTMA
	Redraw = instance.parameters.Redraw

	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TMA_Period .. ", " .. instance.parameters.ATR_Period ..
		", " .. instance.parameters.ATR_Mult .. ", " .. instance.parameters.TrendThreshold .. ")"
	instance:name(name)
	if (nameOnly) then
		return
	end

	font = core.host:execute("createFont", "Wingdings", Size, false, false)

	Initialization()

	if Price == "Chart" then
		isource = source.close
		ATR = core.indicators:create("ATR", source, ATR_Period)
	else
		HA = core.indicators:create("HA", source)
		isource = HA.close
		ATR = core.indicators:create("ATR", HA:getCandleOutput(0))
	end

	first = math.max(ATR.DATA:first(), TMA_Period)

	if ShowTMA then
		TMA = instance:addStream("TMA", core.Line, name .. ".TMA", "TMA", instance.parameters.TMA_NEclr, first)
		TMA:setWidth(instance.parameters.TMAwidth)
		TMA:setStyle(instance.parameters.TMAstyle)
	else
		TMA = instance:addInternalStream(first, 0)
	end

	Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Bandclr, first)
	Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Bandclr, first)

	Upper:setWidth(instance.parameters.Bandwidth)
	Upper:setStyle(instance.parameters.Bandstyle)
	Lower:setWidth(instance.parameters.Bandwidth)
	Lower:setStyle(instance.parameters.Bandstyle)

	open = instance:addStream("open", core.Line, name .. ".open", "open", core.rgb(0, 0, 0), first)
	high = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(0, 0, 0), first)
	low = instance:addStream("low", core.Line, name, "low" .. ".low", core.rgb(0, 0, 0), first)
	close = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(0, 0, 0), first)
	instance:createCandleGroup(name, "HA", open, high, low, close)
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

function Update(period, mode)
	Calculation(period, mode)

	core.host:execute("removeLabel", source:serial(period))

	if (period < first) then
		return
	end

	Activate(1, period)
end

function Calculation(period, mode)
	ATR:update(mode)
	if HA ~= nil then
		HA:update(mode)

		open[period] = HA.open[period]
		close[period] = HA.close[period]
		high[period] = HA.high[period]
		low[period] = HA.low[period]
	else
		core.host:trace("test");
		open[period] = source.open[period]
		close[period] = source.close[period]
		high[period] = source.high[period]
		low[period] = source.low[period]
	end

	if (period < first) then
		return
	end

	local i
	local ii = TMA_Period
	local LastPeriod
	if period == source:size() - 1 then
		LastPeriod = true
	else
		LastPeriod = false
	end
	while ii > 0 do
		if not (LastPeriod) then
			ii = 0
		else
			ii = ii - 1
		end

		local Sum = 0
		local SumW = (TMA_Period + 2) * (TMA_Period + 1) / 2
		for i = 0, TMA_Period, 1 do
			Sum = Sum + (TMA_Period - i + 1) * isource[period - i]
			if Redraw then
				if i <= source:size() - 1 - period and i > 0 then
					Sum = Sum + (TMA_Period - i + 1) * isource[period + i]
					SumW = SumW + (TMA_Period - i + 1)
				end
			end
		end
		TMA[period] = Sum / SumW

		period = period - 1
	end

	local ii = TMA_Period
	local LastPeriod
	if period == source:size() - 1 then
		LastPeriod = true
	else
		LastPeriod = false
	end

	while ii > 0 do
		if not (LastPeriod) then
			ii = 0
		else
			ii = ii - 1
		end

		local Slope = (TMA[period] - TMA[period - 1]) / (0.1 * ATR.DATA[period])

		if Slope > TrendThreshold then
			TMA:setColor(period, instance.parameters.TMA_UPclr)
		elseif Slope < -TrendThreshold then
			TMA:setColor(period, instance.parameters.TMA_DNclr)
		else
			TMA:setColor(period, instance.parameters.TMA_NEclr)
		end
		local range = ATR.DATA[period] * ATR_Mult
		Upper[period] = TMA[period] + range
		Lower[period] = TMA[period] - range

		period = period - 1
	end
end

function ReleaseInstance()
	core.host:execute("deleteFont", font)
end

function Activate(id, period)
	local Shift = 0

	if Live ~= "Live" then
		period = period - 1
		Shift = 1
	end

	if id == 1 and ON[id] then
		if close[period] > open[period] and close[period - 1] < open[period - 1] and close[period] < Lower[period] then
			core.host:execute(
				"drawLabel1",
				source:serial(period),
				source:date(period),
				core.CR_CHART,
				low[period],
				core.CR_CHART,
				core.H_Center,
				core.V_Bottom,
				font,
				UpTrendColor,
				"\225"
			)

			D[id] = nil

			if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
				OnlyOnceFlag = false
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Up ", period)
				SendAlert(" Up ")

				Pop(Label[id], " Up ")
			end
		elseif close[period] < open[period] and close[period - 1] > open[period - 1] and close[period] > Upper[period] then
			core.host:execute(
				"drawLabel1",
				source:serial(period),
				source:date(period),
				core.CR_CHART,
				high[period],
				core.CR_CHART,
				core.H_Center,
				core.V_Top,
				font,
				DownTrendColor,
				"\226"
			)

			U[id] = nil

			if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
				OnlyOnceFlag = false
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Down ", period)

				Pop(Label[id], " Down ")
				SendAlert(" Down ")
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

	--  Alert:invoke("ShowAlert", message);
	terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW))
end

function SoundAlert(Sound)
	if not PlaySound then
		return
	end

	if OnlyOnce and OnlyOnceFlag == false then
		return
	end

	-- Alert:invoke( "PlaySound", Sound, RecurrentSound);
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

	-- Alert:invoke( "SendEmail", Email, profile:id(),  text );
	terminal:alertEmail(Email, profile:id(), text)
end
