-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2640

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
	indicator:name("Market Profile")
	indicator:description("Market Profile")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 5)
	indicator.parameters:addInteger("Val", "Value Area Percentage", "", 70)
	indicator.parameters:addBoolean("Consolidated", "Consolidated", "", true)
	indicator.parameters:addBoolean("Hide", "Hide TPO", "", false)
	indicator.parameters:addString("Type", "Alphabet", "", "Alphabet")
	indicator.parameters:addStringAlternative("Type", "Alphabet", "", "Alphabet")
	indicator.parameters:addBoolean("LAST", "Show Only Last Period", "", true)
	indicator.parameters:addInteger("days", "Days to show", "", 5)
	indicator.parameters:addBoolean("ShowValueArea", "Show Value Area", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addStringAlternative("Type", "Dots", "", "Dot")
	indicator.parameters:addColor("POC", "POC Color", "", core.rgb(127, 127, 127))
	indicator.parameters:addInteger("Size", "Font Size", "", 8)
	indicator.parameters:addColor("VA_color", "VA Color", "", core.rgb(127, 127, 127))
	indicator.parameters:addInteger("VA_transp", "VA transparency, %", "", 50, 0, 100)
	indicator.parameters:addColor("initial_balance_color", "Initial Balance Color", "", core.rgb(255, 0, 0))
end

local Size
local BoxSize
local source
local first
local Consolidated
local Hide
local Value
local s
local e
local ValueArea
local Type
local BOX
local ShowValueArea
local LAST, days

local ABC = {
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"10"
}
local PocMark
local BarSize
local vah
local val
-- Routine
function Prepare(nameOnly)
	Value = instance.parameters.Val
	BoxSize = instance.parameters.BoxSize
	Hide = instance.parameters.Hide
	Consolidated = instance.parameters.Consolidated
	Type = instance.parameters.Type
	Size = instance.parameters.Size
	LAST = instance.parameters.LAST
	ShowValueArea = instance.parameters.ShowValueArea

	source = instance.source
	first = source:first()

	BOX = BoxSize * source:pipSize()
	days = instance.parameters.days;

	local name = profile:id() .. "(" .. source:name() .. ", " .. BoxSize .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	if not ShowValueArea then
		vah = instance:addStream("VAH", core.LINE_NONE, "VAH", "VAH", instance.parameters.VA_color, 0)
		val = instance:addStream("VAL", core.LINE_NONE, "VAL", "VAL", instance.parameters.VA_color, 0)
	else
		vah = instance:addStream("VAH", core.Line, "VAH", "VAH", instance.parameters.VA_color, 0)
		val = instance:addStream("VAL", core.Line, "VAL", "VAL", instance.parameters.VA_color, 0)
		instance:createChannelGroup("VA", "VA", vah, val, instance.parameters.VA_color, instance.parameters.VA_transp)
	end

	PocMark =
		instance:createTextOutput("POC", "POC", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.POC, 0)
	local s1, e2
	s1, e2 = core.getcandle(source:barSize(), core.now(), 0, 0)
	BarSize = e2 - s1
	instance:ownerDrawn(true);
end

local date
local Filter
local FLAG

function Update(period)
	date = source:date(period)
	local Table = core.dateToTable(date)
	local Last = source:date(source:size() - 1)
	local LastTable = core.dateToTable(Last)

	if LAST then
		if Table.month == LastTable.month and Table.day == LastTable.day then
			MP(period, Table.month * 31 + Table.day)
		end
		if FLAG ~= Table.day then
			FLAG = Table.day
			core.host:execute("removeAll")
		end
	else
		if Last - date <= days then
			MP(period, Table.month * 31 + Table.day)
		end
	end
end

function CalcVAMinMax(profile, poc, area)
	local max = poc
	local min = poc
	local summ = profile[poc]
	while (summ < area) do
		local up = profile[max + 1] or 0
		local down = profile[min - 1] or 0
		if up > down then
			summ = summ + up
			max = max + 1
		else
			summ = summ + down
			min = min - 1
		end
	end
	return min, max
end

local init = false;
local tpo_ll, tpo_hh, tpo_ll_hh_date;
local PEN = 1;
function Draw(stage, context)
	if stage ~= 2 then
		return;
	end
	if not init then
		context:createPen(PEN, context.SOLID, 1, instance.parameters.initial_balance_color);
		init = true;
	end
	if tpo_hh == nil then
		return;
	end
	local x_, x = context:positionOfDate(tpo_ll_hh_date);
	local _, y1 = context:pointOfPrice(tpo_ll);
	local _, y2 = context:pointOfPrice(tpo_hh);
	context:drawLine(PEN, x, y1, x, y2);
end

function MP(period, n)
	local s, e = core.getcandle("D1", date, 0, 0)
	local start = core.findDate(source, s, false)
	local finish = core.findDate(source, e, false)
	if period < finish or start <= first or finish > source:size() - 1 then
		return
	end
	local min, max = mathex.minmax(source, start, finish)
	local POC
	local Profile = {}
	local Label = {}
	local Total = 0
	for j = start, finish, 1 do
		local Count = 0
		for price = min, max, BOX do
			Count = Count + 1
			if Profile[Count] == nil then
				Profile[Count] = 0
			end

			if Label[Count] == nil then
				Label[Count] = " "
			end

			if not Consolidated then
				if price > source.high[j] or price + BOX < source.low[j] then
					Label[Count] = Label[Count] .. "  "
				end
			end

			if
				price >= source.low[j] and price + BOX <= source.high[j] or price <= source.low[j] and price + BOX >= source.low[j] or
					price <= source.high[j] and price + BOX >= source.high[j]
			 then
				Profile[Count] = Profile[Count] + 1
				if 1 + finish - start > 60 or Type == "Dot" then
					Label[Count] = Label[Count] .. "."
				else
					Label[Count] = Label[Count] .. ABC[1 + j - start]
				end
				if Total == 0 then
					tpo_ll = source.low[j];
					tpo_hh = source.high[j];
				elseif Total == 1 then
					tpo_ll = math.min(tpo_ll, source.low[j]);
					tpo_hh = math.max(tpo_hh, source.high[j]);
				end
				Total = Total + 1
			end
			tpo_ll_hh_date = source:date(start) - BarSize;
			if price == min then
				POC = Count
			elseif Profile[POC] < Profile[Count] then
				core.host:execute(
					"drawLabel",
					n * 1000 + 200 + POC,
					source:date(start) - BarSize,
					min + POC * BOX,
					tostring(Profile[POC])
				)
				POC = Count
			end

			ValueArea = Value * (Total / 100)
			if Count == POC then
				core.host:execute(
					"drawLabel",
					n * 1000 + 200 + Count,
					source:date(start) - BarSize,
					min + Count * BOX,
					"(" .. Profile[POC] .. ")"
				)
			else
				core.host:execute(
					"drawLabel",
					n * 1000 + 200 + Count,
					source:date(start) - BarSize,
					min + Count * BOX,
					tostring(Profile[Count])
				)
			end

			if not Hide then
				core.host:execute("drawLabel", n * 1000 + 100 + Count, source:date(start), min + Count * BOX, Label[Count])
			end
		end

		PocMark:set(j, min + POC * BOX, "\108")
		local va_min, va_max = CalcVAMinMax(Profile, POC, ValueArea)
		vah[j] = min + va_max * BOX
		val[j] = min + va_min * BOX
	end

	if 1 + period - start > 60 or Type == "Dot" then
		core.host:execute(
			"drawLabel",
			n * 1000 + 1,
			source:date(start),
			max + 2 * BOX,
			" TSO Count (" ..
				Total .. "), Value Area(" .. ValueArea .. "), Last TSO " .. "(.)" .. ", POC (" .. min + POC * BOX .. ")"
		)
	else
		core.host:execute(
			"drawLabel",
			n * 1000 + 1,
			source:date(start),
			max + 2 * BOX,
			" TSO Count (" ..
				Total ..
					"), Value Area(" .. ValueArea .. "), Last TSO (" .. ABC[1 + period - start] .. "), POC (" .. min + POC * BOX .. ")"
		)
	end
end
