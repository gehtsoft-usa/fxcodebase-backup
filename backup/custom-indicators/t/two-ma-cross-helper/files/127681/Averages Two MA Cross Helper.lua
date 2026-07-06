-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68734

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Averages Two MA Cross Helper")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("1. MA Calculation")

	indicator.parameters:addString("Price1", "Price Source", "", "close")
	indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open")
	indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high")
	indicator.parameters:addStringAlternative("Price1", "LOW", "", "low")
	indicator.parameters:addStringAlternative("Price1", "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted")

	indicator.parameters:addInteger("Period1", "Period", "", 14)

	indicator.parameters:addString("Method1", "Method", "", "MVA")
	indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder")
	indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA")
	indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA")
	indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA")
	indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA")
	indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA")
	indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA")
	indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA")
	indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA")
	indicator.parameters:addStringAlternative("Method1", "T3", "", "T3")
	indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend")
	indicator.parameters:addStringAlternative("Method1", "Median", "", "Median")
	indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean")
	indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA")
	indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS")
	indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2")
	indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen")
	indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth")
	indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA")
	indicator.parameters:addStringAlternative("Method1", "ARSI", "", "ARSI")
	indicator.parameters:addStringAlternative("Method1", "VIDYA", "", "VIDYA")
	indicator.parameters:addStringAlternative("Method1", "HPF", "", "HPF")
	indicator.parameters:addStringAlternative("Method1", "VAMA", "", "VAMA")

	indicator.parameters:addGroup("2. MA Calculation")

	indicator.parameters:addInteger("Period2", "Period", "", 28)
	indicator.parameters:addString("Price2", "Price Source", "", "close")
	indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open")
	indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high")
	indicator.parameters:addStringAlternative("Price2", "LOW", "", "low")
	indicator.parameters:addStringAlternative("Price2", "CLOSE", "", "close")
	indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median")
	indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical")
	indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted")

	indicator.parameters:addString("Method2", "Method", "", "MVA")
	indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder")
	indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA")
	indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA")
	indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA")
	indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA")
	indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA")
	indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA")
	indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA")
	indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA")
	indicator.parameters:addStringAlternative("Method2", "T3", "", "T3")
	indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend")
	indicator.parameters:addStringAlternative("Method2", "Median", "", "Median")
	indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean")
	indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA")
	indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS")
	indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2")
	indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen")
	indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth")
	indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA")
	indicator.parameters:addStringAlternative("Method2", "ARSI", "", "ARSI")
	indicator.parameters:addStringAlternative("Method2", "VIDYA", "", "VIDYA")
	indicator.parameters:addStringAlternative("Method2", "HPF", "", "HPF")
	indicator.parameters:addStringAlternative("Method2", "VAMA", "", "VAMA")

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("SV", "Show Vertical Line", "", true)
	indicator.parameters:addBoolean("Historical", "Historical", "", true)
	indicator.parameters:addBoolean("one", "Show First Line", "", true)
	indicator.parameters:addBoolean("two", "Show Secind Line", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up_color", "Color of Up", "Color", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down_color", "Color of Down", "Color", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("1. Line Style")
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5)

	indicator.parameters:addGroup("2. Line Style")
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5)

	indicator.parameters:addGroup("Candle Style")
	indicator.parameters:addBoolean("ShowCandle", "Show Candle", "", true)
	indicator.parameters:addColor("UpColor", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("DownColor", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("NeutralColor", "Neutral color", "", core.rgb(0, 0, 255))

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

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

	indicator.parameters:addGroup("Alerts Email")
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false)
	indicator.parameters:addString("Email", "Email", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

	Parameters(1, "MA")
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
local UpColor, DownColor, NeutralColor, ShowCandle
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
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Historical
-- Streams block
local MA1, MA2
local Signal
local one, two
local ma1, ma2
local SV

local open = nil
local close = nil
local high = nil
local low = nil

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

-- Routine
function Prepare(nameOnly)
	Historical = instance.parameters.Historical

	SV = instance.parameters.SV
	source = instance.source
	one = instance.parameters.one
	two = instance.parameters.two
	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor
	NeutralColor = instance.parameters.NeutralColor
	ShowCandle = instance.parameters.ShowCandle

	local name = profile:id() .. "(" .. source:name() .. ")"
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

	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator")

	Signal = instance:addInternalStream(0, 0)

	MA1 =
		core.indicators:create(
		"AVERAGES",
		source[instance.parameters.Price1],
		instance.parameters.Method1,
		instance.parameters.Period1
	)
	MA2 =
		core.indicators:create(
		"AVERAGES",
		source[instance.parameters.Price2],
		instance.parameters.Method2,
		instance.parameters.Period2
	)

	first = math.max(MA1.DATA:first(), MA2.DATA:first()) + 1

	if one then
		ma1 = instance:addStream("ma1", core.Line, " ma1", " ma1", instance.parameters.color1, first)
		ma1:setWidth(instance.parameters.width1)
		ma1:setStyle(instance.parameters.style1)
		ma1:setPrecision(math.max(2, source:getPrecision()))
	else
		ma1 = instance:addInternalStream(0, 0)
	end

	if two then
		ma2 = instance:addStream("ma2", core.Line, " ma2", " ma2", instance.parameters.color2, first)
		ma2:setWidth(instance.parameters.width2)
		ma2:setStyle(instance.parameters.style2)
		ma2:setPrecision(math.max(2, source:getPrecision()))
	else
		ma2 = instance:addInternalStream(0, 0)
	end

	if ShowCandle then
		open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
		high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
		low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
		close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
		instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)
	else
		open = instance:addInternalStream(0, 0)
		high = instance:addInternalStream(0, 0)
		low = instance:addInternalStream(0, 0)
		close = instance:addInternalStream(0, 0)
	end

	Initialization()
	instance:ownerDrawn(true)
end

local init = false

function Draw(stage, context)
	if stage ~= 2 or not SV then
		return
	end

	if not init then
		context:createPen(
			1,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.Up_color
		)
		context:createPen(
			2,
			context:convertPenStyle(instance.parameters.style),
			instance.parameters.width,
			instance.parameters.Down_color
		)
		init = true
	end

	local HistoricalCount = 0

	if Historical then
		FirstPeriod = source:size() - 1
	else
		FirstPeriod = math.min(context:lastBar(), source:size() - 1)
	end

	for period = FirstPeriod, math.max(context:firstBar(), first), -1 do
		if Signal[period] == 1 then
			x, x1, x2 = context:positionOfBar(period)
			context:drawLine(1, x, context:top(), x, context:bottom())

			HistoricalCount = HistoricalCount + 1
		elseif Signal[period] == -1 then
			x, x1, x2 = context:positionOfBar(period)
			context:drawLine(2, x, context:top(), x, context:bottom())

			HistoricalCount = HistoricalCount + 1
		end

		if Historical and HistoricalCount >= 2 then
			break
		end
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	MA1:update(mode)
	MA2:update(mode)

	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first or not source:hasData(period) then
		open:setColor(period, Neutral)
		return
	end

	ma1[period] = MA1.DATA[period]
	ma2[period] = MA2.DATA[period]

	if MA1.DATA[period] > MA2.DATA[period] and MA1.DATA[period - 1] <= MA2.DATA[period - 1] then
		Signal[period] = 1
	elseif MA1.DATA[period] < MA2.DATA[period] and MA1.DATA[period - 1] >= MA2.DATA[period - 1] then
		Signal[period] = -1
	else
		Signal[period] = 0
	end

	if MA1.DATA[period] > MA2.DATA[period] then
		open:setColor(period, UpColor)
	elseif MA1.DATA[period] < MA2.DATA[period] then
		open:setColor(period, DownColor)
	else
		open:setColor(period, NeutralColor)
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
		if Signal[period] == 1 and Signal[period - 1] ~= 1 then
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
		elseif Signal[period] == -1 and Signal[period - 1] ~= -1 then
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
