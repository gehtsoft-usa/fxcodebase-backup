-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=153592#p153592
-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
 

function Init()
	indicator:name("Time of a candle")
	indicator:description("The indicator draws twelve vertical lines at the specified times")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	local function addLineParameters(groupNum, defaultHour, defaultMinute, defaultDay)
		indicator.parameters:addGroup(groupNum .. ". Line Parameters")
		indicator.parameters:addInteger(
			"hour" .. groupNum,
			"Hour (EST)",
			"Hour at start of which the line must be drawn",
			defaultHour,
			0,
			23
		)
		indicator.parameters:addInteger(
			"minute" .. groupNum,
			"Minutes",
			"Minute at start of which the line must be drawn",
			defaultMinute,
			0,
			59
		)
		indicator.parameters:addInteger("day" .. groupNum, "Day", "", defaultDay)
		indicator.parameters:addIntegerAlternative("day" .. groupNum, "No Line", "", 0)
		indicator.parameters:addIntegerAlternative("day" .. groupNum, "Any Day", "", -1)
		indicator.parameters:addIntegerAlternative("day" .. groupNum, "Monday", "", 2)
		indicator.parameters:addIntegerAlternative("day" .. groupNum, "Tuesday", "", 3)
		indicator.parameters:addIntegerAlternative("day" .. groupNum, "Wednesday", "", 4)
		indicator.parameters:addIntegerAlternative("day" .. groupNum, "Thursday", "", 5)
		indicator.parameters:addIntegerAlternative("day" .. groupNum, "Friday", "", 6)
		indicator.parameters:addIntegerAlternative("day" .. groupNum, "Sunday", "", 1)
	end

	local function addLineStyle(groupNum)
		indicator.parameters:addGroup(groupNum .. ". Line Style")
		indicator.parameters:addColor("clr" .. groupNum, "Color", "", core.rgb(0, 127, 0))
		indicator.parameters:addInteger("width" .. groupNum, "Width", "", 1, 1, 5)
		indicator.parameters:addInteger("style" .. groupNum, "Style", "", core.LINE_DOT)
		indicator.parameters:setFlag("style" .. groupNum, core.FLAG_LEVEL_STYLE)
	end

	for i = 1, 12 do
		addLineParameters(i, 8, 0, 0)
	end

	indicator.parameters:addGroup("Selector")
	indicator.parameters:addBoolean("Day", "Daily Line", "", false)
	indicator.parameters:addBoolean("Weekly", "Weekly Line", "", false)
	indicator.parameters:addBoolean("Monthly", "Monthly Line", "", false)
	indicator.parameters:addBoolean("Quarter", "Quarterly Line", "", false)
	indicator.parameters:addBoolean("Year", "Yearly Line", "", true)

	for i = 1, 12 do
		addLineStyle(i)
	end

	local function addSpecialLineStyle(suffix, groupName, defaultWidth)
		indicator.parameters:addGroup(groupName .. " Line Style")
		indicator.parameters:addColor("clr" .. suffix, "Color", "", core.rgb(0, 127, 0))
		indicator.parameters:addInteger("width" .. suffix, "Width", "", defaultWidth, 1, 5)
		indicator.parameters:addInteger("style" .. suffix, "Style", "", core.LINE_DOT)
		indicator.parameters:setFlag("style" .. suffix, core.FLAG_LEVEL_STYLE)
	end

	addSpecialLineStyle("D", "Daily", 5)
	addSpecialLineStyle("W", "Weekly", 5)
	addSpecialLineStyle("M", "Monthly", 5)
	addSpecialLineStyle("Q", "Quarterly", 5)
	addSpecialLineStyle("Y", "Yearly", 5)
end

local Day, styleD, widthD, clrD
local Year, styleY, widthY, clrY
local Quarter, styleQ, widthQ, clrQ
local source
local dummy, host
local days = {}
local hours = {}
local minutes = {}
local clrs = {}
local widths = {}
local styles = {}
local DSize, WSize, MSize
local Monthly, styleM, styleW
local Weekly
local widthM, clrM
local widthW, clrW
local Size, HSize
local dayoffset
local weekoffset

function Prepare(onlyname)
	Day = instance.parameters.Day
	widthD = instance.parameters.widthD
	styleD = instance.parameters.styleD
	clrD = instance.parameters.clrD

	Year = instance.parameters.Year
	widthY = instance.parameters.widthY
	styleY = instance.parameters.styleY
	clrY = instance.parameters.clrY

	Quarter = instance.parameters.Quarter
	widthQ = instance.parameters.widthQ
	styleQ = instance.parameters.styleQ
	clrQ = instance.parameters.clrQ

	Monthly = instance.parameters.Monthly
	Weekly = instance.parameters.Weekly

	source = instance.source

	styleW = instance.parameters.styleW
	styleM = instance.parameters.styleM
	widthW = instance.parameters.widthW
	widthM = instance.parameters.widthM
	clrW = instance.parameters.clrW
	clrM = instance.parameters.clrM

	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	local s1, e1
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
	Size = e1 - s1

	s1, e1 = core.getcandle("D1", 0, 0, 0)
	DSize = e1 - s1

	s1, e1 = core.getcandle("W1", 0, 0, 0)
	WSize = e1 - s1

	s1, e1 = core.getcandle("M1", 0, 0, 0)
	MSize = e1 - s1

	s1, e1 = core.getcandle("H1", 0, 0, 0)
	HSize = e1 - s1

	for i = 1, 12 do
		days[i] = instance.parameters["day" .. i]
		hours[i] = instance.parameters["hour" .. i]
		minutes[i] = instance.parameters["minute" .. i]
		clrs[i] = instance.parameters["clr" .. i]
		widths[i] = instance.parameters["width" .. i]
		styles[i] = instance.parameters["style" .. i]
	end

	local name = profile:id() .. "(" .. source:name()
	for i = 1, 12 do
		name = name .. " (" .. Decode(days[i]) .. "," .. hours[i] .. "," .. minutes[i] .. ")"
	end
	instance:name(name)

	if onlyname then
		return
	end

	dummy = instance:addStream("D", core.Line, name .. ".D", "D", clrs[1], 0)
end

function Decode(day)
	if day == 0 then
		return "No Line"
	elseif day == -1 then
		return "Any"
	elseif day == 2 then
		return "Monday"
	elseif day == 3 then
		return "Tuesday"
	elseif day == 4 then
		return "Wednesday"
	elseif day == 5 then
		return "Thursday"
	elseif day == 6 then
		return "Friday"
	else
		return "Not Supported"
	end
end

local last_s = nil
local id = 0

function Update(period, mode)
	if period == 0 then
		core.host:execute("removeAll")
		id = 0
	end

	local s = source:serial(period)
	if last_s ~= nil and s == last_s then
		return
	end
	last_s = s

	local date = source:date(period)
	local pdate = source:date(period - 1)
	local t = core.dateToTable(date)
	local p = core.dateToTable(pdate)

	for i = 1, 12 do
		if t.min == minutes[i] and t.hour == hours[i] and (t.wday == days[i] or days[i] == -1) and days[i] ~= 0 and Size <= HSize then
			id = id + 1
			core.host:execute(
				"drawLine",
				id,
				date,
				0,
				date,
				100000,
				clrs[i],
				styles[i],
				widths[i],
				core.formatDate(core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, date))
			)
			if days[i] == -1 then
				core.host:execute(
					"drawLine",
					10 + id,
					date + DSize,
					0,
					date + DSize,
					100000,
					clrs[i],
					styles[i],
					widths[i],
					core.formatDate(core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, date))
				)
			else
				core.host:execute(
					"drawLine",
					10 + id,
					date + DSize * 7,
					0,
					date + DSize * 7,
					100000,
					clrs[i],
					styles[i],
					widths[i],
					core.formatDate(core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, date + DSize * 7))
				)
			end
		end
	end

	if t.month ~= p.month and Monthly and Size < MSize then
		id = id + 1
		core.host:execute("drawLine", id, date, 0, date, 100000, clrM, styleM, widthM)
	end

	if t.wday ~= p.wday and Day and t.wday > p.wday and Size < DSize then
		id = id + 1
		core.host:execute("drawLine", id, date, 0, date, 100000, clrW, styleW, widthW)
	end
	if source:barSize() == "M1" then
		if Year and t.month == 12 and p.month == 11 then
			id = id + 1
			core.host:execute("drawLine", id, date, 0, date, 100000, clrY, styleY, widthY)
		end
	else
		if Year and t.month == 1 and p.month == 12 then
			id = id + 1
			core.host:execute("drawLine", id, date, 0, date, 100000, clrY, styleY, widthY)
		end
	end

	if source:barSize() == "M1" then
		if
			(t.month == 3 and p.month == 2 and Quarter) or (t.month == 6 and p.month == 5 and Quarter) or
			(t.month == 9 and p.month == 8 and Quarter) or
			(t.month == 12 and p.month == 11 and Quarter)
		 then
			id = id + 1
			core.host:execute("drawLine", id, date, 0, date, 100000, clrQ, styleQ, widthQ)
		end
	else
		if
			(t.month == 4 and p.month == 3 and Quarter) or (t.month == 7 and p.month == 6 and Quarter) or
			(t.month == 10 and p.month == 9 and Quarter) or
			(t.month == 1 and p.month == 12 and Quarter)
		 then
			id = id + 1
			core.host:execute("drawLine", id, date, 0, date, 100000, clrQ, styleQ, widthQ)
		end
	end

	if Weekly and t.wday == 2 and p.wday == 1 then
		id = id + 1
		core.host:execute("drawLine", id, date, 0, date, 100000, clrQ, styleQ, widthQ)
	end
end
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=153592#p153592
-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 