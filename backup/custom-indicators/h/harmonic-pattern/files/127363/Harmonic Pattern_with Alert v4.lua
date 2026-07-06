-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68312

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

local Modules = {};

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

	signaler:Init(indicator.parameters);
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
function AsyncOperationFinished(cookie, success, message, message1, message2)
	signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
end

function Prepare(nameOnly)
	signaler:Prepare(nameOnly);
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
		signaler:Signal(_L);
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

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.6";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};
signaler._commands = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and (self.last_req == nil or not self.last_req:loading()) then
        if #self._alerts > 0 then
            local data = self:ArrayToJSON(self._alerts);
            self._alerts = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
        end
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(message, source)
    if source == nil then
        if instance.source ~= nil then
            source = instance.source;
        elseif instance.bid ~= nil then
            source = instance.bid;
        else
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
    end
end

function signaler:SendCommand(command)
    if self._external_executer_key == nil or core.host.Trading:getTradingProperty("isSimulation") or command == "" then
        return;
    end
    local command = 
    {
        Text = command
    };
    self._commands[#self._commands + 1] = command;
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
    end
    if instance.parameters.external_executer_key ~= "" and instance.parameters.use_external_executer then
        self._external_executer_key = instance.parameters.external_executer_key;
    end
    if self.external_executer_key ~= nil or self._advanced_alert_key ~= nil then
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);