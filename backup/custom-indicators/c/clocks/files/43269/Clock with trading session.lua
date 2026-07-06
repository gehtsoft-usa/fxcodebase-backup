-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25168

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

function Add(id, Flag, TimeShift)
	local i
	local Labels = {
		"EST",
		"UTC",
		"Local",
		"Chart",
		"Server",
		"Financial",
		"Sydney",
		"Tokyo",
		"London",
		"New York",
		"Omsk",
		"Zagreb"
	}

	indicator.parameters:addGroup(id .. ". Clock")

	indicator.parameters:addBoolean("USE" .. id, "Use this Clock", "", Flag)
	indicator.parameters:addInteger("Label" .. id, "Label", "", id)
	for i = 1, 12, 1 do
		indicator.parameters:addIntegerAlternative("Label" .. id, Labels[i], "", i)
	end
	if id > 6 then
		indicator.parameters:addInteger("TimeShift" .. id, "Shift", "", TimeShift)
	end
end

function Init()
	indicator:name("Clock")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	Add(1, false, 0)
	Add(2, false, 0)
	Add(3, true, 0)
	Add(4, false, 0)
	Add(5, false, 0)
	Add(6, true, 0)
	Add(7, true, 15)
	Add(8, true, 13)
	Add(9, true, 4)
	Add(10, true, 0)
	Add(11, true, 11)
	Add(12, true, 5)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addBoolean("Show", "Show Seconds", "", true)
	indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0))
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10)
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0, 10000)

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", core.TZ_TS);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", core.TZ_EST);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", core.TZ_UTC);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", core.TZ_LOCAL);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", core.TZ_SERVER);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", core.TZ_FINANCIAL);
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", core.TZ_TS);
    
	indicator.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
	indicator.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Labels = {
	"EST",
	"UTC",
	"Local",
	"Chart",
	"Server",
	"Financial",
	"Sydney",
	"Tokyo",
	"London",
	"New York",
	"Omsk",
	"Zagreb"
}
local source = nil
local L = {}
local SourceData = {}
local Size
local USE = {}
local Count = 12
local Number
local id
local Size, LabelColor
local Shift
local Hour = {}
local TimeShift = {}
local Label = {}
local Arial
local Show
--()()()()()()Customized segment ()()()()()()()

--()()()()()()()()()()()()()()()()()()()()()()()()

function ReleaseInstance()
	core.host:execute("deleteFont", Arial)
end

local start_time;
local end_time;
local ToTime;
-- Routine
function Prepare(nameOnly)
	Show = instance.parameters.Show
	source = instance.source
	local e, s
	s, e = core.getcandle("H1", core.now(), 0, 0)
	Hour = e - s

	LabelColor = instance.parameters.LabelColor
	Shift = instance.parameters.Shift
	Size = instance.parameters.Size

	local i
	local name = profile:id() .. "(" .. source:name()

	Number = 0

	for i = 1, Count, 1 do
		USE[i] = instance.parameters:getBoolean("USE" .. i)

		if USE[i] then
			Number = Number + 1

			Label[Number] = instance.parameters:getInteger("Label" .. i)

			if i > 6 then
				TimeShift[Number] = instance.parameters:getInteger("TimeShift" .. i)
			else
				TimeShift[Number] = 0
			end

			L[Number] = Labels[Label[Number]]
			name = name .. ", " .. "(" .. L[Number] .. ")"
		end
	end
	name = name .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	start_time, valid = ParseTime(instance.parameters.StartTime);
	assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
	end_time, valid = ParseTime(instance.parameters.StopTime);
	assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");
	ToTime = instance.parameters.ToTime;

	Arial = core.host:execute("createFont", "Arial", Size, true, false)
	core.host:execute("setTimer", 1, 0)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	if period < source:size() - 1 then
		return
	end
end

function Calculation(i)
	local server = core.host:execute("getServerTime")
	local date = core.host:execute("convertTime", core.TZ_EST, Label[i], server) + TimeShift[i] * Hour
	local tab = core.dateToTable(date)
	local str
	if Show then
		str = string.format("%02i:%02i:%02i", tab.hour, tab.min, tab.sec)
	else
		str = string.format("%02i:%02i", tab.hour, tab.min)
	end

	id = id + 1
	core.host:execute("drawLabel1", id, -i * 75, core.CR_RIGHT, 25 + Shift, core.CR_TOP, core.H_Right,
		core.V_Bottom, Arial, LabelColor, Labels[Label[i]])

	id = id + 1
	core.host:execute("drawLabel1", id, -i * 75, core.CR_RIGHT, 25 + Shift + Size * 2, core.CR_TOP,
		core.H_Right, core.V_Bottom, Arial, LabelColor, str)
end

function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

function AsyncOperationFinished(cookie, success, message)
	local now = core.host:execute("convertTime", core.TZ_EST, ToTime, core.host:execute("getServerTime"));
	now = now - math.floor(now);
	if not InRange(now, start_time, end_time) then
		id = 0
		for i = 1, Number, 1 do
			core.host:execute("removeLabel", id + 1);
			core.host:execute("removeLabel", id + 2);
			id = id + 2;
		end
	else
		id = 0
		for i = 1, Number, 1 do
			Calculation(i)
		end
	end
	if cookie == 1 then
		return core.ASYNC_REDRAW
	end

	return 0
end

function ReleaseInstance()
	core.host:execute("killTimer", 1)
end
