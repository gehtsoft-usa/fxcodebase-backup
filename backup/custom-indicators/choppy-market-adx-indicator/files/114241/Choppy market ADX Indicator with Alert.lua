-- Id: 18963
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=64999

function Init()
	indicator:name("Choppy market ADX Indicator")
	indicator:description("Choppy market ADX Indicator")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "", 14)
	indicator.parameters:addDouble("Alpha1", "Alpha1", "", 0.25)
	indicator.parameters:addDouble("Alpha2", "Alpha2", "", 0.33)
	indicator.parameters:addDouble("Level", "Level", "", 25)

	indicator.parameters:addInteger("Type", "Type", "", 1)
	indicator.parameters:addIntegerAlternative("Type", "Box", "", 1)
	indicator.parameters:addIntegerAlternative("Type", "Candle", "", 2)

	indicator.parameters:addGroup("Style")

	indicator.parameters:addColor("Zone", "Choppy Zone Color", "", core.rgb(255, 128, 0))

	indicator.parameters:addInteger("Transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 80, 0, 100)
	indicator.parameters:addInteger("Size", "Font Size", "", 20, 0, 100)

	indicator.parameters:addColor("UpColor", "Cross Over Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("DownColor", "Cross Under Color", "", core.rgb(255, 0, 0))

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Label Symbols")

	indicator.parameters:addInteger("U1", "1. Up Symbol", "", 217)
	indicator.parameters:addInteger("U2", "2. Up Symbol", "", 217)
	indicator.parameters:addInteger("D1", "1. Down Symbol", "", 218)
	indicator.parameters:addInteger("D2", "2. Down Symbol", "", 218)

	indicator.parameters:addGroup("Border Symbols")

	indicator.parameters:addBoolean("ShowBorder", "Show Border", "", true)
	indicator.parameters:addColor("B_Zone", "Choppy Zone Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("B_width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("B_style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("B_style", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Alert Parameters")
	indicator.parameters:addString("Live", "Execution", "", "Live")
	indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn")
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live")

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false)
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)

	indicator.parameters:addGroup("Alert Style")
	indicator.parameters:addInteger("U3", "1. Up Symbol", "", 217)
	indicator.parameters:addInteger("U4", "2. Up Symbol", "", 217)
	indicator.parameters:addInteger("D3", "1. Down Symbol", "", 218)
	indicator.parameters:addInteger("D4", "2. Down Symbol", "", 218)
	indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255))

	indicator.parameters:addColor("Up_Candle", "Up Candle Color", "", core.COLOR_UPCANDLE)
	indicator.parameters:addColor("Down_Candle", "Down Candle Color", "", core.COLOR_DOWNCANDLE)

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

	indicator.parameters:addGroup("Alerts Email")
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false)
	indicator.parameters:addString("Email", "Email", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)

	Parameters(1, "ADX/Level")
	Parameters(2, "DMI+/DMI-")
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
local font
local ShowAlert
local Shift = 0
local Alert = {}

local Type
local open = nil
local close = nil
local high = nil
local low = nil

local first
local source = nil
local Period
local Alpha1
local Alpha2
local Zone, B_Zone
local Transparency
local Signal
local Size
local UpColor, DownColor
local Cross
local Second
local U1, U2
local D1, D2
local U2, U2
local D4, D4
local Up_Candle, Down_Candle
local ShowBorder
function Prepare(nameOnly)
	source = instance.source
	Period = instance.parameters.Period
	Alpha1 = instance.parameters.Alpha1
	Alpha2 = instance.parameters.Alpha2
	Type = instance.parameters.Type

	OnlyOnceFlag = true
	FIRST = true
	OnlyOnce = instance.parameters.OnlyOnce
	ShowAlert = instance.parameters.ShowAlert
	Show = instance.parameters.Show
	Live = instance.parameters.Live
	UpTrendColor = instance.parameters.UpTrendColor
	DownTrendColor = instance.parameters.DownTrendColor

	U1 = string.char(instance.parameters.U1)
	U2 = string.char(instance.parameters.U2)
	D1 = string.char(instance.parameters.D1)
	D2 = string.char(instance.parameters.D2)

	U3 = string.char(instance.parameters.U3)
	U4 = string.char(instance.parameters.U4)
	D3 = string.char(instance.parameters.D3)
	D4 = string.char(instance.parameters.D4)

	Up_Candle = instance.parameters.Up_Candle
	Down_Candle = instance.parameters.Down_Candle

	ShowBorder = instance.parameters.ShowBorder

	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor

	Size = instance.parameters.Size

	Transparency = instance.parameters.Transparency
	Zone = instance.parameters.Zone
	B_Zone = instance.parameters.B_Zone

	Level = instance.parameters.Level

	local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Alpha1 .. ", " .. Alpha2 .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Second = instance:addInternalStream(0, 0)
	Signal = instance:addInternalStream(0, 0)
	Cross = instance:addInternalStream(0, 0)

	assert(core.indicators:findIndicator("SMOOTHED_ADX") ~= nil, "Please, download and install SMOOTHED_ADX.LUA indicator")

	Indicator = core.indicators:create("SMOOTHED_ADX", source, Period, Alpha1, Alpha2)

	first = Indicator.DATA:first()

	for i = 1, Number, 1 do
		Alert[i] = instance:addInternalStream(0, 0)
	end

	Initialization()

	instance:ownerDrawn(true)

	if Type == 2 then
		open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
		high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
		low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
		close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
		instance:createCandleGroup("ZONE", "", open, high, low, close)
	end
end

function Update(period, mode)
	if (period < first) then
		return
	end

	if Type == 2 then
		high[period] = source.high[period]
		low[period] = source.low[period]
		close[period] = source.close[period]
		open[period] = source.open[period]
	end

	Indicator:update(mode)

	if Indicator.ADX[period] < Level then
		Signal[period] = 1
	else
		Signal[period] = 0
	end

	if Indicator.DIP[period] > Indicator.DIM[period] and Indicator.DIP[period - 1] <= Indicator.DIM[period - 1] then
		Cross[period] = 1
	end

	if Indicator.DIP[period] < Indicator.DIM[period] and Indicator.DIP[period - 1] >= Indicator.DIM[period - 1] then
		Cross[period] = -1
	end

	Second[period] = 0

	local Line, X = Last(period)
	if X == 1 and source.close[period] > Line and source.close[period - 1] <= Line then
		Second[period] = 1
	end

	if X == -1 and source.close[period] < Line and source.close[period - 1] >= Line then
		Second[period] = -1
	end

	if Live ~= "Live" then
		period = period - 1
		Shift = 1
	else
		Shift = 0
	end

	Activate(1, period)
	Activate(2, period)
end

function Activate(id, period)
	Alert[id][period] = 0

	if id == 1 and ON[id] then
		if Indicator.ADX[period] > Level and Indicator.ADX[period - 1] <= Level then
			Alert[id][period] = 1

			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Cross Over ", period)
				SendAlert(Label[id], " Crossed over ", period)
				Pop(Label[id], " Cross Over ", period)
				OnlyOnceFlag = false
			end
		elseif Indicator.ADX[period] < Level and Indicator.ADX[period - 1] >= Level then
			Alert[id][period] = -1

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Cross Under ", period)
				Pop(Label[id], " Cross Under ", period)
				SendAlert(Label[id], " Crossed under ", period)
				OnlyOnceFlag = false
			end
		end
	end

	if id == 2 and ON[id] then
		if Indicator.DIP[period] > Indicator.DIM[period] and Indicator.DIP[period - 1] <= Indicator.DIM[period] then
			Alert[id][period] = 2

			D[id] = nil

			if
				U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				U[id] = source:serial(period)
				SoundAlert(Up[id])
				EmailAlert(Label[id], " Cross Over ", period)
				SendAlert(Label[id], " Crossed over ", period)
				Pop(Label[id], " Cross Over ", period)
				OnlyOnceFlag = false
			end
		elseif Indicator.DIP[period] < Indicator.DIM[period] and Indicator.DIP[period] >= Indicator.DIM[period] then
			Alert[id][period] = -2

			U[id] = nil

			if
				D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST and
					(not OnlyOnce or (OnlyOnce and OnlyOnceFlag ~= false))
			 then
				D[id] = source:serial(period)
				SoundAlert(Down[id])
				EmailAlert(Label[id], " Cross Under ", period)
				Pop(Label[id], " Cross Under ", period)
				SendAlert(Label[id], " Crossed under ", period)
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

function Last(period)
	local Line = nil
	local X = nil

	for p = period, first, -1 do
		if Signal[p] == 1 or Signal[p] == -1 then
			X = Signal[p]
			if Signal[p] == 1 then
				Line = source.high[p]
			else
				Line = source.low[p]
			end
			break
		end
	end

	return Line, X
end

local init = false

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	if not init then
		context:createSolidBrush(1, Zone)
		Transparency = context:convertTransparency(instance.parameters.Transparency)
		context:createFont(2, "Wingdings", context:pointsToPixels(Size), context:pointsToPixels(Size), 0)
		context:createPen(3, context:convertPenStyle(instance.parameters.style), instance.parameters.width, UpColor)
		context:createPen(
			4,
			context:convertPenStyle(instance.parameters.style),
			context:pointsToPixels(instance.parameters.width),
			DownColor
		)
		context:createPen(
			5,
			context:convertPenStyle(instance.parameters.B_style),
			context:pointsToPixels(instance.parameters.B_width),
			B_Zone
		)
		init = true
	end

	p1 = nil
	p2 = nil

	local iLevel

	for p = math.max(context:firstBar(), first + 1), math.min(context:lastBar(), source:size() - 1), 1 do
		if Type == 2 then
			if source.close[p] > source.open[p] then
				open:setColor(p, Up_Candle)
			else
				open:setColor(p, Down_Candle)
			end
		end

		p2 = nil

		if Signal[p] == 1 and Signal[p - 1] ~= 1 then
			p1 = p
			p2 = nil
		end

		if (Signal[p - 1] == 1 and Signal[p] ~= 1) or (Signal[p] == 1 and p == source:size() - 1) then
			p2 = p
		end

		if p1 ~= nil and p2 ~= nil then
			min, max, minpos, maxpos = mathex.minmax(source, p1, p2)

			visible, y1 = context:pointOfPrice(max)
			visible, y2 = context:pointOfPrice(min)

			x1, x = context:positionOfBar(math.min(p1, p2))
			x2, x = context:positionOfBar(math.max(p1, p2))
			if Type == 1 then
				if ShowBorder then
					context:drawRectangle(5, 1, x1, y1, x2, y2, Transparency)
				else
					context:drawRectangle(-1, 1, x1, y1, x2, y2, Transparency)
				end
			else
				for k = math.min(p1, p2), math.max(p1, p2), 1 do
					open:setColor(k, Zone)
				end
			end
		end

		if Cross[p] == 1 then
			visible, y = context:pointOfPrice(source.low[p])
			x = context:positionOfBar(p)
			Text = U1
			width, height = context:measureText(2, Text, 0)
			context:drawText(2, Text, UpColor, -1, x - width / 2, y, x + width / 2, y + height, 0)

			visible, y = context:pointOfPrice(source.high[p])

			x1 = x
			p2 = FindNext(p, source.high[p], 1)
			if p2 ~= nil then
				visible, y2 = context:pointOfPrice(source.low[p2])
				x2, x = context:positionOfBar(p2)
				Text = U2
				width, height = context:measureText(2, Text, 0)
				context:drawText(2, Text, UpColor, -1, x2 - width / 2, y2, x2 + width / 2, y2 + height, 0)
				context:drawLine(3, x1, y, x2, y)
			end
		end

		if Cross[p] == -1 then
			x = context:positionOfBar(p)
			visible, y = context:pointOfPrice(source.high[p])
			Text = D1
			width, height = context:measureText(2, Text, 0)
			context:drawText(2, Text, DownColor, -1, x - width / 2, y - height, x + width / 2, y, 0)

			visible, y = context:pointOfPrice(source.low[p])
			x1 = x
			p2 = FindNext(p, source.low[p], -1)
			if p2 ~= nil then
				x2, x = context:positionOfBar(p2)
				visible, y2 = context:pointOfPrice(source.high[p2])
				Text = D2
				width, height = context:measureText(2, Text, 0)
				context:drawText(2, Text, DownColor, -1, x2 - width / 2, y2 - height, x2 + width / 2, y2, 0)
				context:drawLine(4, x1, y, x2, y)
			end
		end

		for iLevel = 1, Number, 1 do
			if Alert[iLevel]:hasData(p) then
				if Alert[iLevel][p] == 1 then
					visible, y = context:pointOfPrice(source.low[p])
					x, o, o = context:positionOfBar(p)
					Text = U3
					width, height = context:measureText(2, Text, 0)
					context:drawText(2, Text, UpTrendColor, -1, x - width / 2, y, x + width / 2, y - height, 0)
				elseif Alert[iLevel][p] == -1 then
					visible, y = context:pointOfPrice(source.high[p])
					x, o, o = context:positionOfBar(p)
					Text = D3
					width, height = context:measureText(2, Text, 0)
					context:drawText(2, Text, DownTrendColor, -1, x - width / 2, y - height, x + width / 2, y, 0)
				end

				if Alert[iLevel][p] == 2 then
					visible, y = context:pointOfPrice(source.low[p])
					x, o, o = context:positionOfBar(p)
					Text = U4
					width, height = context:measureText(2, Text, 0)
					context:drawText(2, Text, UpTrendColor, -1, x - width / 2, y, x + width / 2, y - height, 0)
				elseif Alert[iLevel][p] == -2 then
					visible, y = context:pointOfPrice(source.high[p])
					x, o, o = context:positionOfBar(p)
					Text = D4
					width, height = context:measureText(2, Text, 0)
					context:drawText(2, Text, DownTrendColor, -1, x - width / 2, y - height, x + width / 2, y, 0)
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

function FindNext(p, cross_level, side)
	local Return = nil

	for i = p, source:size() - 1, 1 do
		if
			(source.close[i] > cross_level and source.close[i - 1] <= cross_level and side == 1) or
				(source.close[i] < cross_level and source.close[i - 1] >= cross_level and side == -1)
		 then
			Return = i
			break
		end
	end

	return Return
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
