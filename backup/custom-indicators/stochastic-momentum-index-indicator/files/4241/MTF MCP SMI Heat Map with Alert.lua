-- Id: 18977
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2071

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Add(id, TF, Flag, Instrument)
	indicator.parameters:addGroup(id .. ". Slot")
	indicator.parameters:addString("On" .. id, "Show This Slot", "", Flag)
	indicator.parameters:addStringAlternative("On" .. id, "View", "View", "View")
	indicator.parameters:addStringAlternative("On" .. id, "Alert Cross", "Alert", "Cross")
	indicator.parameters:addStringAlternative("On" .. id, "Alert OB/OS", "Alert", "OB/OS")
	indicator.parameters:addStringAlternative("On" .. id, "Off", "Off", "Off")

	indicator.parameters:addString("P6" .. id, "OB OS Alert Method", "Method", "SMI")
	indicator.parameters:addStringAlternative("P6" .. id, "SMI", "SMI", "SMI")
	indicator.parameters:addStringAlternative("P6" .. id, "Signal", "Signal", "Signal")

	indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF)
	indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS)

	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument)
	indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS)

	indicator.parameters:addInteger("P1" .. id, "Period_Q", "Period_Q", 2)
	indicator.parameters:addInteger("P2" .. id, "Period_R", "Period_R", 8)
	indicator.parameters:addInteger("P3" .. id, "Period_S", "Period_S", 5)
	indicator.parameters:addInteger("P4" .. id, "Period_Signal", "Period_Signal", 5)

	indicator.parameters:addString("P5" .. id, "MA Method", "Method", "EMA")
	indicator.parameters:addStringAlternative("P5" .. id, "MVA", "MVA", "MVA")
	indicator.parameters:addStringAlternative("P5" .. id, "EMA", "EMA", "EMA")
	indicator.parameters:addStringAlternative("P5" .. id, "LWMA", "LWMA", "LWMA")
	indicator.parameters:addStringAlternative("P5" .. id, "TMA", "TMA", "TMA")
	indicator.parameters:addStringAlternative("P5" .. id, "SMMA", "SMMA", "SMMA")
	indicator.parameters:addStringAlternative("P5" .. id, "KAMA", "KAMA", "KAMA")
	indicator.parameters:addStringAlternative("P5" .. id, "VIDYA", "VIDYA", "VIDYA")
	indicator.parameters:addStringAlternative("P5" .. id, "WMA", "WMA", "WMA")

	indicator.parameters:addDouble("ob_level" .. id, "OB Level", "", 40)
	indicator.parameters:addDouble("os_level" .. id, "OS Level", "", -40)
end

function Init()
	indicator:name("MTF MCP SMI Heat Map with Alert")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Override")

	indicator.parameters:addString("Method", "Override Method", "Method", "Chart Instrument")
	indicator.parameters:addStringAlternative("Method", "Independent", "Independent", "Independent")
	indicator.parameters:addStringAlternative("Method", "Chart Time Frame", "Chart Time Frame", "Chart Time Frame")
	indicator.parameters:addStringAlternative("Method", "Chart Instrument", "Chart Instrument", "Chart Instrument")

	Add(1, "m1", "Cross", "EUR/USD")
	Add(2, "m5", "Cross", "USD/JPY")
	Add(3, "m15", "Cross", "GBP/USD")
	Add(4, "m30", "Cross", "USD/CHF")
	Add(5, "H1", "Cross", "EUR/CHF")
	Add(6, "H2", "Cross", "AUD/USD")
	Add(7, "H3", "Cross", "USD/CAD")
	Add(8, "H4", "Cross", "NZD/USD")
	Add(9, "H6", "Cross", "NZD/USD")
	Add(10, "H8", "Cross", "EUR/JPY")
	Add(11, "D1", "Cross", "GBP/JPY")
	Add(12, "W1", "Cross", "CHF/JPY")
	Add(13, "M1", "Cross", "GBP/CHF")

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("OB", "OB Zone Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addColor("OS", "OS Zone Color", "", core.rgb(0, 0, 255))

	indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)", "", 5, 0, 50)
	indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)", "", 5, 0, 50)
	indicator.parameters:addDouble("Size", "Font Size (%)", "", 90, 50, 200)

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

	indicator.parameters:addFile("Sound", "Alert Sound", "", "")
	indicator.parameters:setFlag("Sound", core.FLAG_SOUND)
	indicator.parameters:addGroup("Alerts Dialog box")
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true)

	indicator.parameters:addGroup("Alerts Email")
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
	indicator.parameters:addString("Email", "Email", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)
end
local On = {}
local Method
local source
local day_offset, week_offset
local Label = {"First", "Second", "Third", "Fourth"}

local VSpace, HSpace
local Color
local Size
local SourceData = {}
local TF = {}
local loading = {}
local Number
local host
local RSI = {}
local Up, Down
local Instrument = {}

local P1 = {} --Integer
local P2 = {} --Integer
local P3 = {} --Integer
local P4 = {} --Integer
local P5 = {} --String
local P6 = {} --String
local Indicator = {}

local OB, OS

local Last = {}
---

local CalcMode
local Email
local SendEmail
local Sound
local RecurrentSound, SoundFile
local Show
local PlaySound
local Alert = nil
local Count
local AlertNumber

local ob_level = {}
local os_level = {}

function Prepare(nameOnly)
	source = instance.source
	VSpace = (instance.parameters.VSpace / 100)
	HSpace = (instance.parameters.HSpace / 100)
	Method = instance.parameters.Method

	Up = instance.parameters.Up
	Down = instance.parameters.Down
	OB = instance.parameters.OB
	OS = instance.parameters.OS

	host = core.host
	Size = instance.parameters.Size
	Color = instance.parameters.Color
	

	Last = {}

	day_offset = host:execute("getTradingDayOffset")
	week_offset = host:execute("getTradingWeekOffset")
	local Id = 0
	Number = 0
	local name = profile:id() .. " " .. source:name() .. " : " .. source:barSize()
	local ifirst
	local s1, e1, s2, e2
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)

	local iTF = {}
	for i = 1, 13, 1 do
		if Method == "Chart Time Frame" then
			iTF[i] = source:barSize()
		else
			iTF[i] = instance.parameters:getString("TF" .. i)
		end
	end
	assert(core.indicators:findIndicator("SMI") ~= nil, "Please, download and install SMI.LUA indicator")

	--AlertNumber=0;
	for i = 1, 13, 1 do
		s2, e2 = core.getcandle(iTF[i], 0, 0, 0)

		if instance.parameters:getString("On" .. i) ~= "Off" and (e1 - s1) <= (e2 - s2) then
			Number = Number + 1

			P1[Number] = instance.parameters:getInteger("P1" .. i)
			P2[Number] = instance.parameters:getInteger("P2" .. i)
			P3[Number] = instance.parameters:getInteger("P3" .. i)
			P4[Number] = instance.parameters:getInteger("P4" .. i)
			P5[Number] = instance.parameters:getString("P5" .. i)
			P6[Number] = instance.parameters:getString("P6" .. i)

			ob_level[Number] = instance.parameters:getDouble("ob_level" .. i)
			os_level[Number] = instance.parameters:getDouble("os_level" .. i)

			Label[Number] = ""
			On[Number] = instance.parameters:getString("On" .. i)

			if Method == "Chart Instrument" then
				Instrument[Number] = source:instrument()
				Label[Number] = ""
			else
				Instrument[Number] = instance.parameters:getString("Instrument" .. i)
				Label[Number] = Instrument[Number]
			end

			if Method == "Chart Time Frame" then
				TF[Number] = iTF[i]
			else
				TF[Number] = iTF[i]
				Label[Number] = Label[Number] .. " - " .. TF[Number]
			end

			if not nameOnly then
				Temp1 = core.indicators:create("SMI", source, P1[Number], P2[Number], P3[Number], P4[Number], P5[Number])
				ifirst = Temp1.DATA:first() * 2
			end

			Id = Id + 1
			if not nameOnly then
				SourceData[Number] =
					core.host:execute(
					"getSyncHistory",
					Instrument[Number],
					TF[Number],
					source:isBid(),
					math.min(300, ifirst),
					2000 + Id,
					1000 + Id
				)
				loading[Number] = true
				Indicator[Number] =
					core.indicators:create("SMI", SourceData[Number], P1[Number], P2[Number], P3[Number], P4[Number], P5[Number])
			end
		end
	end

	instance:name(name .. " : " .. Method .. " ")
	if nameOnly then
		return;
	end
	
	instance:setLabelColor(Color)
	instance:ownerDrawn(true)

	SendEmail = instance.parameters.SendEmail

	if SendEmail then
		Email = instance.parameters.Email
	else
		Email = nil
	end
	assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

	RecurrentSound = instance.parameters.RecurrentSound
	Show = instance.parameters.Show
	PlaySound = instance.parameters.PlaySound

	if PlaySound then
		Sound = instance.parameters.Sound
	else
		Sound = nil
	end

	assert(not (PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen")
	core.host:execute("setTimer", 1, 1)
end

function ReleaseInstance()
	core.host:execute("killTimer", 1)
end

function Initialization(period, id)
	local Candle
	Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset)

	if loading[id] or SourceData[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local P = core.findDate(SourceData[id], Candle, false)

	-- candle is not found
	if P < 0 then
		return false
	else
		return P
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local j
	local FLAG = false
	local Num = 0
	local Id = 0
	for j = 1, Number, 1 do
		Id = Id + 1
		if cookie == (1000 + Id) then
			loading[j] = true
		elseif cookie == (2000 + Id) then
			loading[j] = false
		end

		if loading[j] then
			FLAG = true
			Num = Num + 1
		end
	end

	if not FLAG and cookie == 1 then
		for i = 1, Number, 1 do
			Indicator[i]:update(core.UpdateLast)
		end

		if Method == "Chart Instrument" then
			for j = 1, Number, 1 do
				Evaluate(j)
			end
		end
	end

	if FLAG then
		core.host:execute("setStatus", "  Loading " .. ((Number) - Num) .. " / " .. (Number))
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0)
	end

	return core.ASYNC_REDRAW
end

function Update(period, mode)
end

local init = false

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

	local FLAG = false

	for j = 1, Number, 1 do
		if loading[j] then
			FLAG = true
		end
	end

	if FLAG then
		return
	end

	local style = context.SINGLELINE + context.CENTER + context.VCENTER

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())

	if not init then
		context:createPen(1, context.SOLID, 1, Color)
		context:createSolidBrush(2, Color)

		context:createPen(1, context.SOLID, 1, Color)
		context:createSolidBrush(2, Color)

		context:createPen(11, context.SOLID, 1, Up)
		context:createSolidBrush(12, Up)

		context:createPen(21, context.SOLID, 1, Down)
		context:createSolidBrush(22, Down)

		context:createPen(31, context.SOLID, 2, OB)
		context:createPen(41, context.SOLID, 2, OS)

		init = true
	end

	local first = math.max(source:first(), context:firstBar())
	local last = math.min(context:lastBar(), source:size() - 1)

	X0, X1, X2 = context:positionOfBar(source:size() - 1)
	HCellSize = (X2 - X1) * HSpace
	VCellSize = ((context:bottom() - context:top()) / (Number + 1))

	for i = first, last, 1 do
		x0, x1, x2 = context:positionOfBar(i)

		for j = 1, Number, 1 do
			p = Initialization(i, j)

			if p ~= false then
				if Indicator[j].SignalBuff:hasData(p) and Indicator[j].DataBuff:hasData(p) then
					if Indicator[j].DataBuff[p] > Indicator[j].SignalBuff[p] then
						C2 = 12

						if Indicator[j].DataBuff[p] > ob_level[j] then
							C1 = 31
						elseif Indicator[j].DataBuff[p] < os_level[j] then
							C1 = 41
						else
							C1 = 11
						end
					else
						C2 = 22

						if Indicator[j].DataBuff[p] > ob_level[j] then
							C1 = 31
						elseif Indicator[j].DataBuff[p] < os_level[j] then
							C1 = 41
						else
							C1 = 21
						end
					end
				else
					C1 = 1
					C2 = 2
				end
			else
				C1 = 1
				C2 = 2
			end
			context:drawRectangle(
				C1,
				C2,
				x1 + HCellSize,
				context:top() + VCellSize / 2 + VCellSize * (j - 1) + VCellSize * VSpace,
				x2 - HCellSize,
				context:top() + VCellSize / 2 + VCellSize * (j) - VCellSize * VSpace
			)

			if i == first then
				local width, height
				context:createFont(3, "Arial", ((X2 - X1) / 100) * Size, (VCellSize / 100) * Size, context.NORMAL)
				Value = tostring(Label[j])
				width, height = context:measureText(3, Value, style)
				context:drawText(
					3,
					Value,
					Color,
					-1,
					X2 + (X2 - X1),
					context:top() + VCellSize / 2 + VCellSize * (j - 1) + VCellSize * VSpace,
					X2 + (X2 - X1) + width,
					context:top() + VCellSize / 2 + VCellSize * (j) - VCellSize * VSpace,
					style
				)
			end
		end
	end
end

function Evaluate(j)
	if On[j] == "Off" or On[j] == "View" then
		return
	end

	local p = Initialization((source:size() - 1), j)

	if
		not Indicator[j].SignalBuff:hasData(p) or not Indicator[j].DataBuff:hasData(p) or
			not Indicator[j].SignalBuff:hasData(p - 1) or
			not Indicator[j].DataBuff:hasData(p - 1) or
			not p
	 then
		return
	end

	if On[j] == "Cross" then
		if
			Indicator[j].DataBuff[p] > Indicator[j].SignalBuff[p] and
				Indicator[j].DataBuff[p - 1] <= Indicator[j].SignalBuff[p - 1] and
				Last[j] ~= SourceData[j]:serial(p)
		 then
			Last[j] = SourceData[j]:serial(p)
			GiveAlert("Up Trend", j)
		elseif
			Indicator[j].DataBuff[p] < Indicator[j].SignalBuff[p] and
				Indicator[j].DataBuff[p - 1] >= Indicator[j].SignalBuff[p - 1] and
				Last[j] ~= SourceData[j]:serial(p)
		 then
			Last[j] = SourceData[j]:serial(p)
			GiveAlert("Down Trend", j)
		end
	else
		if P6[j] == "SMI" then
			if
				Indicator[j].DataBuff[p] > ob_level[j] and Indicator[j].DataBuff[p - 1] <= ob_level[j] and
					Last[j] ~= SourceData[j]:serial(p)
			 then
				Last[j] = SourceData[j]:serial(p)
				GiveAlert(" OB Alert ", j)
			elseif
				Indicator[j].DataBuff[p] < os_level[j] and Indicator[j].DataBuff[p - 1] >= os_level[j] and
					Last[j] ~= SourceData[j]:serial(p)
			 then
				Last[j] = SourceData[j]:serial(p)
				GiveAlert(" OS Alert ", j)
			end
		else
			if
				Indicator[j].SignalBuff[p] > ob_level[j] and Indicator[j].SignalBuff[p - 1] <= ob_level[j] and
					Last[j] ~= SourceData[j]:serial(p)
			 then
				Last[j] = SourceData[j]:serial(p)
				GiveAlert(" OB Alert ", j)
			elseif
				Indicator[j].SignalBuff[p] < os_level[j] and Indicator[j].SignalBuff[p - 1] >= os_level[j] and
					Last[j] ~= SourceData[j]:serial(p)
			 then
				Last[j] = SourceData[j]:serial(p)
				GiveAlert(" OS Alert ", j)
			end
		end
	end
end

function GiveAlert(Label, j)
	SoundAlert(Sound)
	Pop("Alert", Label, j)
	EmailAlert("Alert", Label, j)
end

function EmailAlert(label, Label, j)
	if not SendEmail then
		return
	end

	local DATA = core.dateToTable(core.now())

	local delim = "\013\010"

	local Time =
		" Date : " ..
		DATA.month .. " / " .. DATA.day .. delim .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

	local text =
		" Instrument : " ..
		Instrument[j] .. delim .. " Time Frame : " .. TF[j] .. delim .. Time .. delim .. Label .. " : " .. label

	terminal:alertEmail(Email, profile:id(), text)
end

function Pop(label, Label, j)
	if not Show then
		return
	end

	local DATA = core.dateToTable(core.now())

	local delim = "\013\010"

	local Time =
		" Date : " ..
		DATA.month .. " / " .. DATA.day .. delim .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

	local text =
		" Instrument : " ..
		Instrument[j] .. delim .. " Time Frame : " .. TF[j] .. delim .. Time .. delim .. label .. " : " .. Label

	core.host:execute("prompt", 1, profile:id(), text)
end

function SoundAlert(iAlert)
	if not PlaySound then
		return
	end

	terminal:alertSound(iAlert, RecurrentSound)
end
