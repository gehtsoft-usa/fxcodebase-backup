-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68312

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
	indicator:name("Harmonic Pattern")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator:setTag("group", "Swing")

	indicator.parameters:addGroup("Pattern Selector")
	indicator.parameters:addBoolean("Bat", "Bat", "", true)
	indicator.parameters:addBoolean("Gartley", "Gartley", "", true)
	indicator.parameters:addBoolean("Crab", "Crab", "", true)
	indicator.parameters:addBoolean("Butterfly", "Butterfly", "", true)
	indicator.parameters:addBoolean("ABCD", "AB=CD", "", true)
	indicator.parameters:addBoolean("Drives", "Three Drives", "", true)

	indicator.parameters:addDouble("Correction", "correction", "", 25, 0, 33)

	indicator.parameters:addGroup("Zig Zag Calculation")
	indicator.parameters:addInteger("Depth", "Depth", "", 12, 1, 10000)
	indicator.parameters:addInteger("Deviation", "Deviation", "", 5, 1, 1000)
	indicator.parameters:addInteger("Backstep", "Backstep", "", 3, 1, 10000)

	indicator.parameters:addGroup("Zig Zag Style")
	indicator.parameters:addColor("Zig_color", "Zig Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Zag_color", "Zag Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("widthZigZag", "Line Width", "", 1, 1, 5)
	indicator.parameters:addInteger("styleZigZag", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE)

	indicator.parameters:addGroup("Price Target Lines Style")
	indicator.parameters:addColor("Ratio_color", "Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("style", "style", "style", core.LINE_DOT)
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5)

	indicator.parameters:addInteger("Transparency", "Transparency", "", 40, 0, 100)
	indicator.parameters:addColor("Bull", "Color of Bull", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Bear", "Color of Bear", "", core.rgb(255, 0, 0))

	indicator.parameters:addGroup("Line Selector")
	indicator.parameters:addBoolean("Show", "Show Price Targets", "", false)
	indicator.parameters:addBoolean("ShowZigZag", "Show Zig Zag Line", "", true)
	indicator.parameters:addBoolean("ShowOutput", "Show output", "", false)

	indicator.parameters:addGroup("Alerts Sound")
	indicator.parameters:addBoolean("ChartAlert", "Chart alert", "", true)
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false)
	indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)
	indicator.parameters:addFile("AlertSound", "Alert Sound", "", "")
	indicator.parameters:setFlag("AlertSound", core.FLAG_SOUND)
	indicator.parameters:addBoolean("SendEmail", "Send email", "", false)
	indicator.parameters:addString("Email", "Email address", "", "")
	indicator.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth
local Deviation
local Backstep

local Correction

local Selector = {}
--local correctionA,correctionB;

local Bull, Bear

local first
local source = nil

-- Streams block
local ZigC
local ZagC
local out
local line_id = 1
local label_id = 1

local LAST = {}

local Show
local ShowZigZag
local LastAlertTime
local LastMsg

local A, B, C, D, X

local XA
local AB
local BC
local CD

local XB
local XD
local AC
local BD
local AD
local Transparency

local Up = {}
local Down = {}

local One = {}
local Two = {}
local SIGNAL, SIGNAL_PERIOD;

-- Routine
function AsyncOperationFinished(cookie)
end

function Prepare(nameOnly)
	Correction = instance.parameters.Correction
	Correction = Correction / 100

	Selector["Bat"] = instance.parameters.Bat
	Selector["Gartley"] = instance.parameters.Gartley
	Selector["Crab"] = instance.parameters.Crab
	Selector["Butterfly"] = instance.parameters.Butterfly
	Selector["AB=CD"] = instance.parameters.ABCD
	Selector["Drives"] = instance.parameters.Drives

	Bull = instance.parameters.Bull
	Bear = instance.parameters.Bear

	Transparency = instance.parameters.Transparency
	ShowZigZag = instance.parameters.ShowZigZag
	Depth = instance.parameters.Depth
	Deviation = instance.parameters.Deviation
	Backstep = instance.parameters.Backstep
	source = instance.source

	Show = instance.parameters.Show

	Transparency = 100 - Transparency

	local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	ZIGZAG = core.indicators:create("ZIGZAG", source, Depth, Deviation, Backstep)
	first = ZIGZAG.DATA:first()

	if ShowZigZag then
		out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Ratio_color, first)
		out:setWidth(instance.parameters.widthZigZag)
		out:setStyle(instance.parameters.styleZigZag)
	else
		out = instance:addInternalStream(0, 0)
	end
	ZigC = instance.parameters.Zig_color
	ZagC = instance.parameters.Zag_color

	Up["Bat"] = instance:addStream("UpBat", core.Line, name, "", instance.parameters.Zig_color, first)
	Down["Bat"] = instance:addStream("DownBat", core.Line, name, "", instance.parameters.Zig_color, first)
	instance:createChannelGroup("Group", "Group", Up["Bat"], Down["Bat"], Bull, Transparency)

	Up["Gartley"] = instance:addStream("UpGartley", core.Line, name, "", instance.parameters.Zig_color, first)
	Down["Gartley"] = instance:addStream("DownGartley", core.Line, name, "", instance.parameters.Zig_color, first)
	instance:createChannelGroup("Group", "Group", Up["Gartley"], Down["Gartley"], Bull, Transparency)

	Up["Crab"] = instance:addStream("UpCrab", core.Line, name, "", instance.parameters.Zig_color, first)
	Down["Crab"] = instance:addStream("DownCrab", core.Line, name, "", instance.parameters.Zig_color, first)
	instance:createChannelGroup("Group", "Group", Up["Crab"], Down["Crab"], Bull, Transparency)

	Up["Butterfly"] = instance:addStream("UpButterfly", core.Line, name, "", instance.parameters.Zig_color, first)
	Down["Butterfly"] = instance:addStream("DownButterfly", core.Line, name, "", instance.parameters.Zig_color, first)
	instance:createChannelGroup("Group", "Group", Up["Butterfly"], Down["Butterfly"], Bull, Transparency)

	One["AB=CD"] = instance:addStream("One", core.Line, name, "", instance.parameters.Zig_color, first)
	Two["AB=CD"] = instance:addStream("Two", core.Line, name, "", instance.parameters.Zig_color, first)
	Down["AB=CD"] = instance:addStream("DownABCD", core.Line, name, "", instance.parameters.Zig_color, first)
	instance:createChannelGroup("Group", "Group", One["AB=CD"], Down["AB=CD"], Bull, Transparency)
	instance:createChannelGroup("Group", "Group", Two["AB=CD"], out, Bull, Transparency)

	Up["Drives"] = instance:addStream("UpDrives", core.Line, name, "", instance.parameters.Zig_color, first)
	Down["Drives"] = instance:addStream("DownDrives", core.Line, name, "", instance.parameters.Zig_color, first)
	instance:createChannelGroup("Group", "Group", Up["Drives"], Down["Drives"], Bull, Transparency)

	if instance.parameters.ShowOutput then
		SIGNAL = instance:addStream("SIGNAL", core.Line, name, "", instance.parameters.Zig_color, first)
		SIGNAL_PERIOD = instance:addStream("SIGNAL_PERIOD", core.Line, name, "", instance.parameters.Zig_color, first)
	end

	line_id = 1
	label_id = 1
end

function Update(period, mode)
	if period < first + 5 then
		return
	end

	local i
	local _L

	ZIGZAG:update(mode)

	if ZIGZAG.DATA[period - 3] ~= 0 then
		out[period - 3] = ZIGZAG.DATA[period - 3]
	end

	if period < source:size() - 1 then
		return
	end

	line_id = 1
	label_id = 1
	local signal_period;
	local code;
	for i = 1, period, 1 do
		Up[i] = nil
		Down[i] = nil

		if ShowZigZag then
			if out[i] ~= nil then
				if out[i] > out[i - 1] then
					out:setColor(i, ZigC)
				else
					out:setColor(i, ZagC)
				end
			end
		end

		if i == 1 then
			LAST["HighFour"] = nil
			LAST["HighThree"] = nil
			LAST["HighTwo"] = nil
			LAST["HighOne"] = nil
			LAST["LowFour"] = nil
			LAST["LowThree"] = nil
			LAST["LowTwo"] = nil
			LAST["LowOne"] = nil
		end

		if out[i] > source.high[i] - source:pipSize() * 0.001 and out[i] < source.high[i] + source:pipSize() * 0.001 then
			LAST["HighFour"] = LAST["HighThree"]
			LAST["HighThree"] = LAST["HighTwo"]
			LAST["HighTwo"] = LAST["HighOne"]
			LAST["HighOne"] = i

			if LAST["HighFour"] ~= nil then
				_L, code, p = Lengt(false)
				signal_period = i;
				if code ~= nil and SIGNAL ~= nil then
					if out:getBookmark(code, p) < p then
						SIGNAL[period] = code;
						out:setBookmark(code, p)
					end
					SIGNAL_PERIOD[period] = signal_period;
				end
			end
		elseif out[i] > source.low[i] - source:pipSize() * 0.001 and out[i] < source.low[i] + source:pipSize() * 0.001 then
			LAST["LowFour"] = LAST["LowThree"]
			LAST["LowThree"] = LAST["LowTwo"]
			LAST["LowTwo"] = LAST["LowOne"]
			LAST["LowOne"] = i

			if LAST["LowFour"] ~= nil then
				_L, code, p = Lengt(true)
				signal_period = i;
				if code ~= nil and SIGNAL ~= nil then
					if out:getBookmark(code, p) < p then
						SIGNAL[period] = code;
						out:setBookmark(code, p)
					end
					SIGNAL_PERIOD[period] = signal_period;
				end
			end
		end
	end

	if _L ~= nil and signal_period>=period-3 then
		Signal(_L, signal_period)
	end
end

function Signal(Msg, period)
	if LastAlertTime ~= nil and LastAlertTime >= source:date(period) then
		return;
	end
	LastAlertTime = source:date(period);
	if instance.parameters.ChartAlert then
		core.host:execute("prompt", 1, "Alert", Msg)
	end

	if instance.parameters.PlaySound then
		terminal:alertSound(instance.parameters.AlertSound, instance.parameters.RecurrentSound)
	end

	if instance.parameters.SendEmail then
		terminal:alertEmail(instance.parameters.Email, "Harmonic pattern Alert", Msg)
	end
end

function Lengt(FLAG)
	if LAST["LowFour"] == nil or LAST["HighFour"] == nil then
		return
	end

	if FLAG then
		D = LAST["LowOne"]
		B = LAST["LowTwo"]
		X = LAST["LowThree"]
		C = LAST["HighOne"]
		A = LAST["HighTwo"]
	else
		D = LAST["HighOne"]
		B = LAST["HighTwo"]
		X = LAST["HighThree"]
		C = LAST["LowOne"]
		A = LAST["LowTwo"]
	end

	XA = math.abs(out[X] - out[A])
	AB = math.abs(out[A] - out[B])
	BC = math.abs(out[B] - out[C])
	CD = math.abs(out[C] - out[D])

	XB = math.abs(out[X] - out[B])
	XD = math.abs(out[X] - out[D])
	BD = math.abs(out[B] - out[D])
	AC = math.abs(out[A] - out[C])

	AD = math.abs(out[A] - out[D])

	local label, code, p = DECODE(FLAG)
	if label ~= nil then
		DRAW(label)
		return label, code, p
	else
		return nil
	end
end

function DRAW(label)
	local Color

	if X == A or A == B or B == C or C == D then
		return
	end

	if label == "Bull Three Drives" or label == "Bear Three Drives" then
		if Selector["Drives"] then
			if out[X] < out[A] then
				Color = Bull
				drawline(D, out[D] + AD * 1.272, D + (D - A), out[D] + AD * 1.272, Color)
				drawline(D, out[D] + XA, D + (A - X), out[D] + XA, Color)
			else
				Color = Bear
				drawline(D, out[D] + AD * 1.272, D + (D - A), out[D] + AD * 1.272, Color)
				drawline(D, out[D] + XA, D + (A - X), out[D] + XA, Color)
			end

			core.drawLine(Up["Drives"], core.range(X, B), out[X], X, out[B], B, Color)
			core.drawLine(Up["Drives"], core.range(B, D), out[B], B, out[D], D, Color)
			Up["Drives"]:setColor(X, Color)

			core.host:execute("drawLabel", label_id, source:date(X), math.max(out[X], out[A]), "" .. label .. "")
			label_id = label_id + 1

			core.drawLine(Down["Drives"], core.range(X, A), out[X], X, out[A], A, Color)
			core.drawLine(Down["Drives"], core.range(A, B), out[A], A, out[B], B, Color)
			core.drawLine(Down["Drives"], core.range(B, C), out[B], B, out[C], C, Color)
			core.drawLine(Down["Drives"], core.range(C, D), out[C], C, out[D], D, Color)
		end
	elseif label == "Bull Bat" or label == "Bear Bat" then
		if Selector["Bat"] then
			if out[X] < out[A] then
				Color = Bull
				drawline(D, out[D] + AD * 1.272, D + (D - A), out[D] + AD * 1.272, Color)
				drawline(D, out[D] + XA, D + (A - X), out[D] + XA, Color)
			else
				Color = Bear
				drawline(D, out[D] - AD * 1.272, D + (D - A), out[D] - AD * 1.272, Color)
				drawline(D, out[D] - XA, D + (A - X), out[D] - XA, Color)
			end

			core.drawLine(Up["Bat"], core.range(X, D), out[X], X, out[D], D, Color)
			Up["Bat"]:setColor(X, Color)

			core.host:execute("drawLabel", label_id, source:date(X), math.max(out[A], out[B]), "" .. label .. "")
			label_id = label_id + 1
			core.drawLine(Down["Bat"], core.range(X, A), out[X], X, out[A], A, Color)
			core.drawLine(Down["Bat"], core.range(A, B), out[A], A, out[B], B, Color)
			core.drawLine(Down["Bat"], core.range(B, C), out[B], B, out[C], C, Color)
			core.drawLine(Down["Bat"], core.range(C, D), out[C], C, out[D], D, Color)
		end
	elseif label == "Bull Gartley" or label == "Bear Gartley" then
		if Selector["Gartley"] then
			if out[X] < out[A] then
				Color = Bull
				drawline(D, out[D] + AD * 1.272, D + (D - A), out[D] + AD * 1.272, Color)
				drawline(D, out[D] + XA, D + (A - X), out[D] + XA, Color)
			else
				Color = Bear
				drawline(D, out[D] - AD * 1.272, D + (D - A), out[D] - AD * 1.272, Color)
				drawline(D, out[D] - XA, D + (A - X), out[D] - XA, Color)
			end

			core.drawLine(Up["Gartley"], core.range(X, D), out[X], X, out[D], D, Color)
			Up["Gartley"]:setColor(X, Color)

			core.host:execute("drawLabel", label_id, source:date(X), math.max(out[A], out[B]), "" .. label .. "")
			label_id = label_id + 1
			core.drawLine(Down["Gartley"], core.range(X, A), out[X], X, out[A], A, Color)
			core.drawLine(Down["Gartley"], core.range(A, B), out[A], A, out[B], B, Color)
			core.drawLine(Down["Gartley"], core.range(B, C), out[B], B, out[C], C, Color)
			core.drawLine(Down["Gartley"], core.range(C, D), out[C], C, out[D], D, Color)
		end
	elseif label == "Bull Crab" or label == "Bear Crab" then
		if Selector["Crab"] then
			if out[X] < out[A] then
				Color = Bull
				drawline(D, out[D] + AD * 1.272, D + (D - A), out[D] + AD * 1.272, Color)
				drawline(D, out[D] + XA, D + (A - X), out[D] + XA, Color)
			else
				Color = Bear
				drawline(D, out[D] - AD * 1.272, D + (D - A), out[D] - AD * 1.272, Color)
				drawline(D, out[D] - XA, D + (A - X), out[D] - XA, Color)
			end

			core.drawLine(Up["Crab"], core.range(X, D), out[X], X, out[D], D, Color)
			Up["Crab"]:setColor(X, Color)

			core.host:execute("drawLabel", label_id, source:date(X), math.max(out[A], out[B]), "" .. label .. "")
			label_id = label_id + 1
			core.drawLine(Down["Crab"], core.range(X, A), out[X], X, out[A], A, Color)
			core.drawLine(Down["Crab"], core.range(A, B), out[A], A, out[B], B, Color)
			core.drawLine(Down["Crab"], core.range(B, C), out[B], B, out[C], C, Color)
			core.drawLine(Down["Crab"], core.range(C, D), out[C], C, out[D], D, Color)
		end
	elseif label == "Bull Butterfly" or label == "Bear Butterfly" then
		if Selector["Butterfly"] then
			if out[X] < out[A] then
				Color = Bull
				drawline(D, out[D] + AD * 1.272, D + (D - A), out[D] + AD * 1.272, Color)
				drawline(D, out[D] + XA, D + (A - X), out[D] + XA, Color)
			else
				Color = Bear
				drawline(D, out[D] - AD * 1.272, D + (D - A), out[D] - AD * 1.272, Color)
				drawline(D, out[D] - XA, D + (A - X), out[D] - XA, Color)
			end

			core.drawLine(Up["Butterfly"], core.range(X, D), out[X], X, out[D], D, Color)
			Up["Butterfly"]:setColor(X, Color)

			core.host:execute("drawLabel", label_id, source:date(X), math.max(out[A], out[B]), "" .. label .. "")
			label_id = label_id + 1
			core.drawLine(Down["Butterfly"], core.range(X, A), out[X], X, out[A], A, Color)
			core.drawLine(Down["Butterfly"], core.range(A, B), out[A], A, out[B], B, Color)
			core.drawLine(Down["Butterfly"], core.range(B, C), out[B], B, out[C], C, Color)
			core.drawLine(Down["Butterfly"], core.range(C, D), out[C], C, out[D], D, Color)
		end
	elseif label ~= "Bull AB=CD" or label ~= "Bear AB=CD" then
		if Selector["AB=CD"] then
			if out[A] > out[B] then
				Color = Bull
				drawline(D, out[D] + AB * 1.272, D + (B - A), out[D] + AB * 1.272, Color)
				drawline(D, out[D] + AD, D + (D - A), out[D] + AD, Color)
			else
				Color = Bear
				drawline(D, out[D] - AB * 1.272, D + (B - A), out[D] - AB * 1.272, Color)
				drawline(D, out[D] - AD, D + (D - A), out[D] - AD, Color)
			end

			core.drawLine(One["AB=CD"], core.range(A, C), out[A], A, out[C], C, Color)
			core.drawLine(Two["AB=CD"], core.range(B, D), out[B], B, out[D], D, Color)
			One["AB=CD"]:setColor(X, Color)

			core.host:execute("drawLabel", label_id, source:date(X), math.max(out[X], out[A]), "" .. label .. "")
			label_id = label_id + 1
			core.drawLine(Down["AB=CD"], core.range(X, A), out[X], X, out[A], A, Color)
			core.drawLine(Down["AB=CD"], core.range(A, B), out[A], A, out[B], B, Color)
			core.drawLine(Down["AB=CD"], core.range(B, C), out[B], B, out[C], C, Color)
			core.drawLine(Down["AB=CD"], core.range(C, D), out[C], C, out[D], D, Color)
		end
	end
end
local BullThreeDrives = 1;
local BullABCD = 2;
local BullBat = 3;
local BullGartley = 4;
local BullCrab = 5;
local BullButterfly = 6;
local BearThreeDrives = -1;
local BearABCD = -2;
local BearBat = -3;
local BearGartley = -4;
local BearCrab = -5;
local BearButterfly = -6;
function DECODE(FLAG)
	if FLAG then
		if
			(out[X] - (1.27 - Correction / 3) * XA) >= out[B] and (out[X] - (1.618 + Correction / 3) * XA) <= out[B] and
				(out[B] - (1.27 - Correction / 3) * XA) >= out[D] and
				(out[B] - (1.618 + Correction / 3) * XA) <= out[D]
		 then
			return "Bull Three Drives", BullThreeDrives, math.max(X, B, D)
		end

		if
			(out[A] - (0.618 - Correction / 3) * AB) >= out[C] and (out[A] - (0.786 + Correction / 3) * AB) <= out[C] and
				(out[A] - (1.27 - Correction / 3) * AB) >= out[D] and
				(out[A] - (1.618 + Correction / 3) * AB) <= out[D]
		 then
			return "Bull AB=CD", BullABCD, math.max(A, C, D)
		end

		if
			(out[A] - (0.382 - Correction) * XA) >= out[B] and (out[A] - (0.5 + Correction) * XA) <= out[B] and
				(out[A] - (0.382 - Correction) * AB) >= out[C] and
				(out[A] - (0.886 + Correction) * AB) <= out[C] and
				(out[A] + (1.618 - Correction) * AB) >= out[D] and
				(out[A] + (2.618 + Correction) * AB) <= out[D] and
				(out[A] - (0.886 - Correction) * XA) >= out[D] and
				(out[A] - (0.886 + Correction) * XA) >= out[D]
		 then
			return "Bull Bat", BullBat, math.max(A, B, C, D)
		end

		if
			(out[A] - (0.618 - Correction) * XA) >= out[B] and (out[A] - (0.618 + Correction) * XA) <= out[B] and
				(out[A] - (0.382 - Correction) * AB) >= out[C] and
				(out[A] - (0.886 + Correction) * AB) <= out[C] and
				(out[A] + (1.27 - Correction) * AB) >= out[D] and
				(out[A] + (1.618 + Correction) * AB) <= out[D] and
				(out[A] - (0.786 - Correction) * XA) >= out[D] and
				(out[A] - (0.786 + Correction) * XA) <= out[D]
		 then
			return "Bull Gartley", BullGartley, math.max(A, B, C, D);
		end

		if
			(out[A] - (0.382 - Correction) * XA) >= out[B] and (out[A] - (0.618 + Correction) * XA) <= out[B] and
				(out[A] - (0.382 - Correction) * AB) >= out[C] and
				(out[A] - (0.886 + Correction) * AB) <= out[C] and
				(out[A] - (2.24 - Correction) * AB) >= out[D] and
				(out[A] - (3.618 + Correction) * AB) <= out[D] and
				(out[A] - (1.618 - Correction) * XA) >= out[D] and
				(out[A] - (1.618 + Correction) * XA) <= out[D]
		 then
			return "Bull Crab", BullCrab, math.max(A, B, C, D)
		end

		if
			(out[A] - (0.786 - Correction) * XA) >= out[B] and (out[A] - (0.786 + Correction) * XA) <= out[B] and
				(out[A] - (0.382 - Correction) * AB) >= out[C] and
				(out[A] - (0.886 + Correction) * AB) <= out[C] and
				(out[A] - (1.618 - Correction) * AB) >= out[D] and
				(out[A] - (2.618 + Correction) * AB) <= out[D] and
				(out[A] - (1.27 - Correction) * XA) >= out[D] and
				(out[A] - (1.618 + Correction) * XA) <= out[D]
		 then
			return "Bull Butterfly", BullButterfly, math.max(A, B, C, D)
		end
	elseif not FLAG then
		if
			(out[X] + (1.27 - Correction / 3) * XA) <= out[B] and (out[X] + (1.618 + Correction / 3) * XA) >= out[B] and
				(out[B] + (1.27 - Correction / 3) * XA) <= out[D] and
				(out[B] + (1.618 + Correction / 3) * XA) >= out[D]
		 then
			return "Bear Three Drives", BearThreeDrives, math.max(X, B, D)
		end

		if
			(out[A] + (0.618 - Correction / 3) * AB) <= out[C] and (out[A] + (0.786 + Correction / 3) * AB) >= out[C] and
				(out[A] + (1.27 - Correction / 3) * AB) <= out[D] and
				(out[A] + (1.618 + Correction / 3) * AB) >= out[D]
		 then
			return "Bear AB=CD", BearABCD, math.max(A, C, D)
		end

		if
			(out[A] + (0.382 - Correction) * XA) <= out[B] and (out[A] + (0.5 + Correction) * XA) >= out[B] and
				(out[A] + (0.382 - Correction) * AB) <= out[C] and
				(out[A] + (0.886 + Correction) * AB) >= out[C] and
				(out[A] - (1.618 - Correction) * AB) <= out[D] and
				(out[A] - (2.618 + Correction) * AB) >= out[D] and
				(out[A] + (0.886 - Correction) * XA) <= out[D] and
				(out[A] + (0.886 + Correction) * XA) >= out[D]
		 then
			return "Bear Bat", BearBat, math.max(A, B, C, D)
		end

		if
			(out[A] + (0.618 - Correction) * XA) <= out[B] and (out[A] + (0.618 + Correction) * XA) >= out[B] and
				(out[A] + (0.382 - Correction) * AB) <= out[C] and
				(out[A] + (0.886 + Correction) * AB) >= out[C] and
				(out[A] - (1.27 - Correction) * AB) <= out[D] and
				(out[A] - (1.618 + Correction) * AB) >= out[D] and
				(out[A] + (0.786 - Correction) * XA) <= out[D] and
				(out[A] + (0.786 + Correction) * XA) >= out[D]
		 then
			return "Bear Gartley", BearGartley, math.max(A, B, C, D)
		end

		if
			(out[A] + (0.382 - Correction) * XA) <= out[B] and (out[A] + (0.618 + Correction) * XA) >= out[B] and
				(out[A] + (0.382 - Correction) * AB) <= out[C] and
				(out[A] + (0.886 + Correction) * AB) >= out[C] and
				(out[A] + (2.24 - Correction) * AB) <= out[D] and
				(out[A] + (3.618 + Correction) * AB) >= out[D] and
				(out[A] + (1.618 - Correction) * XA) <= out[D] and
				(out[A] + (1.618 + Correction) * XA) >= out[D]
		 then
			return "Bear Crab", BearCrab, math.max(A, B, C, D)
		end

		if
			(out[A] + (0.786 - Correction) * XA) <= out[B] and (out[A] + (0.786 + Correction) * XA) >= out[B] and
				(out[A] + (0.382 - Correction) * AB) <= out[C] and
				(out[A] + (0.886 + Correction) * AB) >= out[C] and
				(out[A] + (1.618 - Correction) * AB) <= out[D] and
				(out[A] + (2.618 + Correction) * AB) >= out[D] and
				(out[A] + (1.27 - Correction) * XA) <= out[D] and
				(out[A] + (1.618 + Correction) * XA) >= out[D]
		 then
			return "Bear Butterfly", BearButterfly, math.max(A, B, C, D)
		end
	end

	return nil
end

function drawline(x1, y1, x2, y2, color)
	if
		x1 == nil or x2 == nil or x1 == 0 or x2 == 0 or x1 >= source:size() - 1 or x2 >= source:size() - 1 or
			x1 <= source:first() or
			x2 <= source:first()
	 then
		return
	end

	if not Show then
		return
	end
	local date1 = source:date(x1)
	local date2 = source:date(x2)

	core.host:execute(
		"drawLine",
		line_id,
		date1,
		y1,
		date2,
		y2,
		color,
		instance.parameters.style,
		instance.parameters.width
	)

	line_id = line_id + 1
end

function Distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
end
