-- Id: 
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
	indicator.parameters:addBoolean("Hide", "Hide TPO", "", false)
	indicator.parameters:addBoolean("LAST", "Show Only Last Period", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("POC", "POC Color", "", core.rgb(127, 127, 127))
	indicator.parameters:addInteger("Size", "Font Size", "", 8)
	indicator.parameters:addColor("VA_color", "VA Color", "", core.rgb(127, 127, 127))
	indicator.parameters:addInteger("VA_transp", "VA transparency, %", "", 50, 0, 100);
	indicator.parameters:addColor("label_color", "Label Color", "", core.rgb(127, 127, 127))
	indicator.parameters:addColor("profile_color", "Profile Color", "", core.rgb(127, 0, 0))
	indicator.parameters:addInteger("transp", "Profile Transparency", "", 50, 0, 100);
end

local Size
local BoxSize
local source
local first
local Hide
local Value
local s
local e
local ValueArea
local BOX
local day_offset, week_offset;
local LAST
local PocMark
local BarSize
local vah;
local val;
-- Routine
function Prepare(nameOnly)
	Value = instance.parameters.Val
	BoxSize = instance.parameters.BoxSize
	Hide = instance.parameters.Hide
	Size = instance.parameters.Size
	LAST = instance.parameters.LAST

	source = instance.source
	first = source:first()

	BOX = BoxSize * source:pipSize()

	local name = profile:id() .. "(" .. source:name() .. ", " .. BoxSize .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end
	day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");

	vah = instance:addStream("VAH", core.Line, "VAH", "VAH", instance.parameters.VA_color, 0)
	val = instance:addStream("VAL", core.Line, "VAL", "VAL", instance.parameters.VA_color, 0)
	instance:createChannelGroup("VA", "VA", vah, val, instance.parameters.VA_color, instance.parameters.VA_transp);

	PocMark = instance:createTextOutput("POC", "POC", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.POC, 0)
	local s1, e2
	s1, e2 = core.getcandle(source:barSize(), core.now(), 0, 0)
	BarSize = e2 - s1

	instance:ownerDrawn(true);
end

local init = false;
local FONT = 1;
local label_color;
local profile_color;
local PEN = 2;
local BRUSH = 3;
local transp;
local dates = {};

function Draw(stage, context)
	if stage ~= 2 then
		return;
	end
	if not init then
		label_color = instance.parameters.label_color;
		profile_color = instance.parameters.profile_color;
		context:createFont(FONT, "Arial", 0, context:pointsToPixels(10), 0);
		context:createPen(PEN, context.SOLID, 1, profile_color)
		context:createSolidBrush(BRUSH, profile_color)
		transp = context:convertTransparency(instance.parameters.transp);
		init = true;
	end
	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
	for _, data in pairs(dates) do
		local start_x = context:positionOfDate(source:date(data.start));
		local finish_x = context:positionOfDate(source:date(data.finish));

		for count, profile in ipairs(data.Profile) do
			local text;
			if count == data.POC then
				text = "(" .. profile .. ")";
			else
				text = profile;
			end
			local _, y = context:pointOfPrice(data.min + count * BOX);
			local _, y_next = context:pointOfPrice(data.min + (count + 1) * BOX);
			if text ~= nil then
				local x = context:positionOfDate(source:date(data.start) - BarSize);
				local width, height = context:measureText(FONT, tostring(text), 0);
				context:drawText(FONT, tostring(text), label_color, -1, x - width, y - height, x, y, 0);
			end
			
			if not Hide and profile > 0 then
				local coeff = profile / data.Total;
				context:drawRectangle(PEN, BRUSH, start_x, y, start_x + (finish_x - start_x) * coeff, y_next, transp);
			end
		end
		local text = " TSO Count (" .. data.Total .. "), Value Area(" .. data.ValueArea .. "), Last TSO " .. "(.)" .. ", POC (" .. data.min + data.POC * BOX .. ")";
		local width, height = context:measureText(FONT, tostring(text), 0);
		local _, y = context:pointOfPrice(data.max + 2 * BOX);
		context:drawText(FONT, tostring(text), label_color, -1, start_x, y - height, start_x + width, y, 0);
	end
end

local Filter
local FLAG

function Update(period)
	date = source:date(period)
	local Table = core.dateToTable(date)
	local Last = source:date(source:size() - 1)
	local LastTable = core.dateToTable(Last)

	if LAST then
		if Table.month == LastTable.month and Table.day == LastTable.day then
			dates = {};
			MP(period, Table.month * 31 + Table.day)
		end
	else
		MP(period, Table.month * 31 + Table.day)
	end
end

function CalcVAMinMax(profile, poc, area)
	local max = poc;
	local min = poc;
	local summ = profile[poc];
	while (summ < area) do
		local up = profile[max + 1] or 0;
		local down = profile[min - 1] or 0;
		if up == 0 and down == 0 then
			return min, max;
		end
		if up > down then
			summ = summ + up;
			max = max + 1;
		else
			summ = summ + down;
			min = min - 1;
		end
	end
	return min, max;
end

function MP(period, n)
	if period == source:size() - 1 then
		period = period - 1;
	end
	local s, e = core.getcandle("D1", source:date(period), day_offset, week_offset)
	local ns = core.getcandle("D1", source:date(period + 1), day_offset, week_offset)
	if s == ns and period ~= source:size() - 2 then
		return;
	end
	local start = core.findDate(source, s, false)
	if start <= 0 then
		return;
	end
	local finish = math.min(PocMark:size() - 1, core.findDate(source, e, false))
	local data = {};
	data.start = start;
	data.finish = finish;
	local min, max = mathex.minmax(source, start, finish)
	data.min = min;
	data.max = max;
	data.Profile = {}
	data.Total = 0
	for j = start, finish, 1 do
		local Count = 0
		for price = min, max, BOX do
			Count = Count + 1
			if data.Profile[Count] == nil then
				data.Profile[Count] = 0
			end

			if price >= source.low[j] and price + BOX <= source.high[j] 
				or price <= source.low[j] and price + BOX >= source.low[j] 
				or price <= source.high[j] and price + BOX >= source.high[j]
			then
				data.Profile[Count] = data.Profile[Count] + 1
				data.Total = data.Total + 1
			end

			if price == min then
				data.POC = Count
			elseif data.Profile[data.POC] < data.Profile[Count] then
				data.POC = Count
			end

			data.ValueArea = Value * (data.Total / 100)
		end
		PocMark:set(j, min + data.POC * BOX, "\108")
		local va_min, va_max = CalcVAMinMax(data.Profile, data.POC, data.ValueArea);
		vah[j] = min + va_max * BOX;
		val[j] = min + va_min * BOX;
	end
	dates[s] = data;
end
