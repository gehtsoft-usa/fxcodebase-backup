-- Id: 15169
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62945

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
	indicator:name("Expansion Retracement Levels")
	indicator:description("Expansion Retracement Levels")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addBoolean("On" .. 1, "Show Level", "", true)
	indicator.parameters:addDouble("Delta" .. 1, "Start Line Price", "Price", 0)
	indicator.parameters:addColor("Color" .. 1, "Line Color", "", core.rgb(0, 0, 255))

	indicator.parameters:addString("Method", "Method", "Method", "Long")
	indicator.parameters:addStringAlternative("Method", "Long", "Long", "Long")
	indicator.parameters:addStringAlternative("Method", "Short", "Short", "Short")

	AddLevel(2, 10)
	AddLevel(3, 20)
	AddLevel(4, 30)
	AddLevel(5, 40)
	AddLevel(6, 50)
	AddLevel(7, 60)
	AddLevel(8, 70)
	AddLevel(9, 80)
	AddLevel(10, 90)
	AddLevel(11, 100)

	indicator.parameters:addGroup("Alerts")
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true)
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false)
	indicator.parameters:addFile("CrossOver", "Cross Over Sound File", "", "")
	indicator.parameters:setFlag("CrossOver", core.FLAG_SOUND)
	indicator.parameters:addFile("CrossUnder", "Cross Under Sound File", "", "")
	indicator.parameters:setFlag("CrossUnder", core.FLAG_SOUND)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)

	indicator.parameters:addGroup("Alerts Email")
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true)
	indicator.parameters:addString("Email", "Email", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)
end

function AddLevel(id, Level)
	indicator.parameters:addGroup(id .. ". Level")
	indicator.parameters:addBoolean("On" .. id, "Show Level", "", true)
	indicator.parameters:addDouble("Delta" .. id, "Delta (in Pips)", "Delta", Level)
	indicator.parameters:addColor("Color" .. id, "Line Color", "", core.rgb(0, 0, 0))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Flag = {}
local PlaySound, RecurrentSound
local ShowAlert
local first
local source = nil
local init = false
local transparency
local CrossOver, CrossUnder
local Level = {}
local Color = {}
local On = {}
local SendEmail, Email
local Method
-- Routine
function Prepare(nameOnly)
	SendEmail = instance.parameters.SendEmail
	Method = instance.parameters.Method
	Email = instance.parameters.Email
	source = instance.source
	first = source:first()

	for i = 1, 11, 1 do
		On[i] = instance.parameters:getBoolean("On" .. i)
		if i == 1 then
			Level[i] = instance.parameters:getDouble("Delta" .. i)
		else
			if Method == "Long" then
				Level[i] = instance.parameters:getDouble("Delta" .. 1) + instance.parameters:getDouble("Delta" .. i) * source:pipSize()
			else
				Level[i] = instance.parameters:getDouble("Delta" .. 1) - instance.parameters:getDouble("Delta" .. i) * source:pipSize()
			end
		end
		Color[i] = instance.parameters:getColor("Color" .. i)
	end

	Flag = {}

	ShowAlert = instance.parameters.ShowAlert
	PlaySound = instance.parameters.PlaySound
	if PlaySound then
		CrossOver = instance.parameters.CrossOver
		CrossUnder = instance.parameters.CrossUnder
	else
		CrossOver = nil
		CrossUnder = nil
	end

	local name = profile:id() .. " : " .. source:name() .. " : " .. Level[1]
	instance:name(name)

	if (nameOnly) then
		return
	end

	assert(not (PlaySound) or (PlaySound and CrossUnder ~= ""), "Sound file must be chosen")
	assert(not (PlaySound) or (PlaySound and CrossOver ~= ""), "Sound file must be chosen")
	RecurrentSound = instance.parameters.RecurrentSound

	instance:ownerDrawn(true)
end

function SendAlert(message)
	if not ShowAlert then
		return
	end

	terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW))
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

function SoundAlert(SoundFile)
	if not PlaySound then
		return
	end

	terminal:alertSound(SoundFile, RecurrentSound)
end

function EmailAlert(label, Subject, period)
	if not SendEmail then
		return
	end

	local date = source:date(period)
	local DATA = core.dateToTable(date)

	local delim = "\013\010"
	local Note = label .. delim .. " Alert : " .. Subject
	local Symbol = "Instrument : " .. source:instrument()
	local Time =
		" Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec

	text = Note .. delim .. Symbol .. delim .. Time

	terminal:alertEmail(Email, profile:id(), text)
end

function Update(period)
	if period < source:size() - 1 then
		return
	end

	for i = 1, 11, 1 do
		if On[i] then
			if source[source:size() - 1] > Level[i] and source[source:size() - 2] <= Level[i] and Flag[i] ~= 1 then
				Flag[i] = 1
				Pop(i .. ". Support Resistance Levels ", " Cross Over ")
				SoundAlert(CrossOver)
				SendAlert(" Cross Over ")
				EmailAlert(i .. ". Support Resistance Levels ", " Cross Over ", period)
			elseif source[source:size() - 1] < Level[i] and source[source:size() - 2] >= Level[i] and Flag[i] ~= -1 then
				Flag[i] = -1
				Pop(i .. ". Support Resistance Levels ", " Cross Under ")
				SoundAlert(CrossUnder)
				SendAlert(" Cross Under ")
				EmailAlert(i .. ". Support Resistance Levels ", " Cross Under ", period)
			end
		end
	end
end

local FONT = 12;

function Draw(stage, context)
	if stage ~= 2 then
		return
	end

	if not init then
		for i = 1, 11, 1 do
			context:createPen(i, context.SOLID, 1, Color[i])
		end
		context:createFont(FONT, "Arial", 0, context:pointsToPixels(12), 0);
		init = true
	end

	for i = 1, 11, 1 do
		if On[i] then
			visible, y = context:pointOfPrice(Level[i])
			if visible then
				context:drawLine(i, context:right(), y, context:left(), y, 0)
				
				local message = win32.formatNumber(Level[i], false,  5 );
				local w, h = context:measureText(FONT, message, 0);
				context:drawText(FONT, message, Color[i], -1, context:right() - w, y - h, context:right(), y, 0);
			end
		end
	end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
