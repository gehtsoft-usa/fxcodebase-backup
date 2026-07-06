-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=44546

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+


-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

local indi_alerts = {};
indi_alerts.Version = "2.2";
indi_alerts.inverted_arrows = false;
local o, r1, r2, r3, r4, s1, s2, s3, s4
local source = nil
local alerts = 
{ 
    {
        Stage = 102,
        UpCondition = function (period)
			if r1 == nil or r1:size() < 2 then
				return false;
			end
			return core.crossesOver(source.close, r1, period);
        end,
        DownCondition = function (period)
			if r1 == nil or r1:size() < 2 then
				return false;
			end
			return core.crossesUnder(source.close, r1, period);
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "R1 cross"
    },
    {
        Stage = 102,
        UpCondition = function (period)
			if r2 == nil or r2:size() < 2 then
				return false;
			end
			return core.crossesOver(source.close, r2, period);
        end,
        DownCondition = function (period)
			if r2 == nil or r2:size() < 2 then
				return false;
			end
			return core.crossesUnder(source.close, r2, period);
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "R2 cross"
    },
    {
        Stage = 102,
        UpCondition = function (period)
			if r3 == nil or r3:size() < 2 then
				return false;
			end
			return core.crossesOver(source.close, r3, period);
        end,
        DownCondition = function (period)
			if r3 == nil or r3:size() < 2 then
				return false;
			end
			return core.crossesUnder(source.close, r3, period);
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "R3 cross"
    },
    {
        Stage = 102,
        UpCondition = function (period)
			if r4 == nil or r4:size() < 2 then
				return false;
			end
			return core.crossesOver(source.close, r4, period);
        end,
        DownCondition = function (period)
			if r4 == nil or r4:size() < 2 then
				return false;
			end
			return core.crossesUnder(source.close, r4, period);
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "R4 cross"
    },
    {
        Stage = 102,
        UpCondition = function (period)
			if s1 == nil or s1:size() < 2 then
				return false;
			end
			return core.crossesOver(source.close, s1, period);
        end,
        DownCondition = function (period)
			if s1 == nil or s1:size() < 2 then
				return false;
			end
			return core.crossesUnder(source.close, s1, period);
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "S1 cross"
    },
    {
        Stage = 102,
        UpCondition = function (period)
			if s2 == nil or s2:size() < 2 then
				return false;
			end
			return core.crossesOver(source.close, s2, period);
        end,
        DownCondition = function (period)
			if s2 == nil or s2:size() < 2 then
				return false;
			end
			return core.crossesUnder(source.close, s2, period);
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "S2 cross"
    },
    {
        Stage = 102,
        UpCondition = function (period)
			if s3 == nil or s3:size() < 2 then
				return false;
			end
			return core.crossesOver(source.close, s3, period);
        end,
        DownCondition = function (period)
			if s3 == nil or s3:size() < 2 then
				return false;
			end
			return core.crossesUnder(source.close, s3, period);
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "S3 cross"
    },
    {
        Stage = 102,
        UpCondition = function (period)
			if s4 == nil or s4:size() < 2 then
				return false;
			end
			return core.crossesOver(source.close, s4, period);
        end,
        DownCondition = function (period)
			if s4 == nil or s4:size() < 2 then
				return false;
			end
			return core.crossesUnder(source.close, s4, period);
        end,
        FormatMessage = function(source, period, level, label, isUp, metadata)
            return string.format(
                "Label: %s\013\010" ..
                "Instrument: %s\013\010" ..
                "Time Frame: %s\013\010" ..
                "Price: %s\013\010" .. 
                "Date: %s", 
                isUp and (label .. " Bull pattern") or (label .. " Bear pattern"), 
                source:instrument(), 
                source:barSize(), 
                win32.formatNumber(source:isBar() and source.close[NOW] or source[NOW], false, source:getPrecision()), 
                core.formatDate(core.now()));
        end,
        FilterConsecutive = false,
        OnChange = true,
        Name = "S3 cross"
    },
};

function Init()
	indicator:name("Percentage Change")
	indicator:description("Percentage Change")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addString("TF", "Time Frame", "", "D1")
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS)
	indicator.parameters:addBoolean("Historical", "Show Historical", "Show Historical", true)

	indicator.parameters:addString("Type", "Price Source", "", "Last")
	indicator.parameters:addStringAlternative("Type", "Last", "", "Last")
	indicator.parameters:addStringAlternative("Type", "Previous", "", "Previous")

	indicator.parameters:addGroup("Levels")
	indicator.parameters:addDouble("R4", "4. Resistance (%)", "4. Resistance", 1, 0, 100)
	indicator.parameters:addDouble("R3", "3. Resistance (%)", "3. Resistance", 0.50, 0, 100)
	indicator.parameters:addDouble("R2", "2. Resistance (%)", "2. Resistance", 0.25, 0, 100)
	indicator.parameters:addDouble("R1", "1. Resistance (%)", "1. Resistance", 0.1, 0, 100)

	indicator.parameters:addDouble("S1", "1. Support (%)", "1. Support", 0.1, 0, 100)
	indicator.parameters:addDouble("S2", "2. Support (%)", "2. Support", 0.25, 0, 100)
	indicator.parameters:addDouble("S3", "3. Support (%)", "3. Support", 0.5, 0, 100)
	indicator.parameters:addDouble("S4", "4. Support (%)", "4. Support", 1, 0, 100)

	indicator.parameters:addGroup("Resistance Line")

	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Day Open Line")
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_DASH)
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)

	indicator.parameters:addGroup("Support Line")

	indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)
    indi_alerts:AddParameters(indicator.parameters);
    for i,alert in ipairs(alerts) do
        indi_alerts:AddAlert(alert.Name);
    end
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Historical
local TF
local Show
local first
local Source
-- Streams block
local S1, S2, S3, S4, R1, R2, R3, R4
local dayoffset, weekoffset
local loading
local level = {}
local label = {"o", "r1", "r2", "r3", "r4", "s1", "s2", "s3", "s4"}
local label2 = {"O", "R1", "R2", "R3", "R4", "S1", "S2", "S3", "S4"}
local Percentages
local Color = {}
local Style = {}
local Width = {}
local Type
-- Routine
function Prepare(nameOnly)
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);
	Percentages = instance.parameters.Percentages
	Type = instance.parameters.Type
	TF = instance.parameters.TF
	S1 = instance.parameters.S1
	S2 = instance.parameters.S2
	S3 = instance.parameters.S3
	S4 = instance.parameters.S4
	R1 = instance.parameters.R1
	R2 = instance.parameters.R2
	R3 = instance.parameters.R3
	R4 = instance.parameters.R4
	Show = instance.parameters.Show
	Historical = instance.parameters.Historical

	local i

	for i = 1, 9, 1 do
		if i == 1 then
			Color[i] = instance.parameters:getInteger("color" .. 1)
			Style[i] = instance.parameters:getInteger("style" .. 1)
			Width[i] = instance.parameters:getInteger("width" .. 1)
		elseif i > 1 and i < 5 then
			Color[i] = instance.parameters:getInteger("color" .. 2)
			Style[i] = instance.parameters:getInteger("style" .. 2)
			Width[i] = instance.parameters:getInteger("width" .. 2)
		else
			Color[i] = instance.parameters:getInteger("color" .. 3)
			Style[i] = instance.parameters:getInteger("style" .. 3)
			Width[i] = instance.parameters:getInteger("width" .. 3)
		end
	end

	dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")

	source = instance.source
	first = source:first()

	local s, e, S, E
	s, e = core.getcandle(source:barSize(), core.now(), 0, 0)
	S, E = core.getcandle(TF, core.now(), 0, 0)
	assert((e - s) <= (E - S), "The chosen time frame must be equal to or bigger than the chart time frame!")

	local name = profile:id() .. "(" .. source:name() .. ", " .. TF .. ")"
	instance:name(name)

	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101)
	loading = true

	if Historical then
		o = instance:addStream("O", core.Line, name, "O", Color[1], first)
		o:setWidth(Width[1])
		o:setStyle(Style[1])

		r1 = instance:addStream("R1", core.Line, name, "R1", Color[2], first)
		r1:setWidth(Width[2])
		r1:setStyle(Style[2])

		r2 = instance:addStream("R2", core.Line, name, "R2", Color[3], first)
		r2:setWidth(Width[3])
		r2:setStyle(Style[3])

		r3 = instance:addStream("R3", core.Line, name, "R3", Color[4], first)
		r3:setWidth(Width[4])
		r3:setStyle(Style[4])

		r4 = instance:addStream("R4", core.Line, name, "R4", Color[5], first)
		r4:setWidth(Width[5])
		r4:setStyle(Style[5])

		s1 = instance:addStream("S1", core.Line, name, "S1", Color[6], first)
		s1:setWidth(Width[6])
		s1:setStyle(Style[6])

		s2 = instance:addStream("S2", core.Line, name, "S2", Color[7], first)
		s2:setWidth(Width[7])
		s2:setStyle(Style[7])

		s3 = instance:addStream("S3", core.Line, name, "S3", Color[8], first)
		s3:setWidth(Width[8])
		s3:setStyle(Style[8])

		s4 = instance:addStream("S4", core.Line, name, "S4", Color[9], first)
		s4:setWidth(Width[9])
		s4:setStyle(Style[9])
	end
end

function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	if period < first then
		return
	end

	local p = Initialization(period)

	if not p then
		return
	end

	if Type ~= "Last" then
		p = p - 1
	end
	if Historical then
		if o[period - 1] ~= Source.open[p] then
			o[period] = Source.open[p]
			o:setBreak(period, true)
			level[1] = Source.open[p]

			level[2] = o[period] * (1 + (R1 / 100))
			r1[period] = level[2]
			r1:setBreak(period, true)

			level[3] = o[period] * (1 + (R2 / 100))
			r2[period] = level[3]
			r2:setBreak(period, true)

			level[4] = o[period] * (1 + (R3 / 100))
			r3[period] = level[4]
			r3:setBreak(period, true)

			level[5] = o[period] * (1 + (R4 / 100))
			r4[period] = level[5]
			r4:setBreak(period, true)

			level[6] = o[period] * (1 - (S1 / 100))
			s1[period] = level[6]
			s1:setBreak(period, true)

			level[7] = o[period] * (1 - (S2 / 100))
			s2[period] = level[7]
			s2:setBreak(period, true)

			level[8] = o[period] * (1 - (S3 / 100))
			s3[period] = level[8]
			s3:setBreak(period, true)

			level[9] = o[period] * (1 - (S4 / 100))
			s4[period] = level[9]
			s4:setBreak(period, true)
		else
			o[period] = o[period - 1]
			r1[period] = r1[period - 1]
			r2[period] = r2[period - 1]
			r3[period] = r3[period - 1]
			r4[period] = r4[period - 1]
			s1[period] = s1[period - 1]
			s2[period] = s2[period - 1]
			s3[period] = s3[period - 1]
			s4[period] = s4[period - 1]
		end
		if Show then
			local i
			if period == source:size() - 1 then
				for i = 1, 9, 1 do
					core.host:execute("drawLabel", i, source:date(period), level[i], label[i])
				end
			end
		end
	else
		if level[1] ~= Source.open[p] then
			level[1] = Source.open[p]
			level[2] = level[1] * (1 + (R1 / 100))
			level[3] = level[1] * (1 + (R2 / 100))
			level[4] = level[1] * (1 + (R3 / 100))
			level[5] = level[1] * (1 + (R4 / 100))
			level[6] = level[1] * (1 - (S1 / 100))
			level[7] = level[1] * (1 - (S2 / 100))
			level[8] = level[1] * (1 - (S3 / 100))
			level[9] = level[1] * (1 - (S4 / 100))
		end

		if period == source:size() - 1 then
			core.host:execute("setStatus", " " .. label2[1] .. "  " .. level[1] .. ", " .. label2[2] ..
				"  " .. level[2] .. ", " .. label2[3] .. "  " .. level[3] .. ", " .. label2[4] .. "  " ..
				level[4] .. ", " .. label2[5] .. "  " .. level[5] .. ", " .. label2[6] .. "  " .. level[6] ..
				", " .. label2[7] .. "  " .. level[7] .. ", " .. label2[8] .. "  " .. level[8] .. ", " .. label2[9] .. "  " .. level[9]
			)

			local S, E
			S, E = core.getcandle(TF, core.now(), 0, 0)

			for i = 1, 9, 1 do
				core.host:execute("drawLine", i + 10, S, level[i], E, level[i], Color[i], Style[i], Width[i])

				core.host:execute("drawLabel", i, E, level[i], label[i])
			end
		end
	end
    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end


function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        return;
    end
    local isUp, upMetadata = alert.UpCondition(period);
    if isUp then
        if alert.OnChange then
            local isUpPrev, _ = alert.UpCondition(period - 1);
            if isUpPrev then
                return;
            end
        end
        if source:isBar() then
            alert:UpAlert(source, period, source.high[period], historical_period, upMetadata);
        else
            alert:UpAlert(source, period, source[period], historical_period, upMetadata);
        end
        return;
    end
    local isDown, downMetadata = alert.DownCondition(period);
    if isDown then
        if alert.OnChange then
            local isDownPrev, _ = alert.DownCondition(period - 1);
            if isDownPrev then
                return;
            end
        end
        if source:isBar() then
            alert:DownAlert(source, period, source.low[period], historical_period, downMetadata);
        else
            alert:DownAlert(source, period, source[period], historical_period, downMetadata);
        end
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
	if cookie == 100 then
		loading = false
		instance:updateFrom(0)
	elseif cookie == 101 then
		loading = true
	end
end

function Initialization(period)
	local Candle
	Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset)

	if loading or Source:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local p = core.findDate(Source, Candle, false)

	-- candle is not found
	if p < 0 then
		return false
	else
		return p
	end
end

indi_alerts.last_id = 0;
indi_alerts._alerts = {};
indi_alerts._advanced_alert_timer = nil;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Alert Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    indicator.parameters:addBoolean("strategy_output", "Output for strategies", "Used by the strategies", false);

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false);
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    
    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    indicator.parameters:addGroup("External Alerts");
    indicator.parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	indicator.parameters:addString("advanced_alert_key", "Advanced Alert Key",
		"You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for Discord/other platform keys", "")
end

function indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2) if cookie == self._advanced_alert_timer and #self._alerts > 0 then if self._advanced_alert_key == nil then return; end local data = self:ArrayToJSON(self._alerts); self._alerts = {}; local req = http_lua.createRequest(); local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}', self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data); req:setRequestHeader("Content-Type", "application/json"); req:setRequestHeader("Content-Length", tostring(string.len(query))); req:start("http://profitrobots.com/api/v1/notification", "POST", query); end end
function indi_alerts:ToJSON(item)
    local json = {};
    function json:AddStr(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value)); end
    function json:AddNumber(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0); end
    function json:AddBool(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false"); end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    local first = true; for idx,t in pairs(item) do  local stype = type(t) if stype == "number" then json:AddNumber(idx, t); elseif stype == "string" then json:AddStr(idx, t); elseif stype == "boolean" then json:AddBool(idx, t); elseif stype == "function" or stype == "table" then else core.host:trace(tostring(idx) .. " " .. tostring(stype)); end end
    return json:ToString();
end
function indi_alerts:ArrayToJSON(arr) local str = "["; for i, t in ipairs(self._alerts) do local json = self:ToJSON(t); if str == "[" then str = str .. json; else str = str .. "," .. json; end end return str .. "]"; end
function indi_alerts:AddAlert(label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. label .." Alert" , "", true);

    indicator.parameters:addString("drawing_mode" .. self.last_id, "Drawing mode", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Arrows", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Vertical lines", "", "vlines");

    indicator.parameters:addFile("Up" .. self.last_id, label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Up Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Up Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addFile("Down" .. self.last_id, label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("DownSymbol" .. self.last_id, "Down Symbol", "", 218);
    indicator.parameters:addColor("DownColor" .. self.last_id, "Down Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addString("Label" .. self.last_id, "Label", "", label);
end

function indi_alerts:AddSingleAlert(Label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. Label .." Alert" , "", true);

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addString("Label" .. self.last_id, "Label", "", Label);
end

function indi_alerts:DrawAlert(context, alert, period)
    if not alert.Alert:hasData(period) then
        return;
    end

    if alert.Alert[period] == 1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self._stages[alert.Stage].FONT_ID, alert.UpSymbol, 0);
            local x1 = x - width / 2;
            local x2 = x + width / 2;
            local y1, y2;
            if self.inverted_arrows then
                y1 = y;
                y2 = y + height;
            else
                y1 = y - height;
                y2 = y;
            end
			context:drawText(self._stages[alert.Stage].FONT_ID, alert.UpSymbol, alert.UpColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.UpLinePen, x, context:top(), x, context:bottom());
        end
	elseif alert.Alert[period] == -1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self._stages[alert.Stage].FONT_ID, alert.DownSymbol, 0);
            local x1 = x - width / 2;
            local x2 = x + width / 2;
            local y1, y2;
            if self.inverted_arrows then
                y1 = y - height;
                y2 = y;
            else
                y1 = y;
                y2 = y + height;
            end
            context:drawText(self._stages[alert.Stage].FONT_ID, alert.DownSymbol, alert.DownColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.DownLinePen, x, context:top(), x, context:bottom());
        end
    end
end
indi_alerts.NextId = 1;
indi_alerts._stages = {};
function indi_alerts:Draw(stage, context)
    if self._stages[stage] == nil then
        self._stages[stage] = {};
        self._stages[stage].createFont = false;
        for _, level in ipairs(self.Alerts) do
            if level.Stage == stage then
                if level.DrawingMode == "vlines" then
                    level.UpLinePen = self.NextId;
                    self.NextId = self.NextId + 1;
                    level.DownLinePen = self.NextId;
                    self.NextId = self.NextId + 1;
                    context:createPen(level.UpLinePen, context.SOLID, 1, level.UpColor);
                    context:createPen(level.DownLinePen, context.SOLID, 1, level.DownColor);
                else
                    self._stages[stage].createFont = true;
                end
            end
        end
        if self._stages[stage].createFont and self._stages[stage].FONT_ID == nil then
            self._stages[stage].FONT_ID = self.NextId;
			self.NextId = self.NextId + 1;
            context:createFont(self._stages[stage].FONT_ID, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0);
        end
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size()-1), 1 do
        for _, level in ipairs(self.Alerts) do
            if level.Stage == stage then
                self:DrawAlert(context, level, period);
            end
        end
    end
end
indi_alerts.Alerts = {};
function indi_alerts:GetTimezone()
    local tz = instance.parameters.ToTime;
    if tz == 1 then
        return core.TZ_EST
    elseif tz == 2 then
        return core.TZ_UTC
    elseif tz == 3 then
        return core.TZ_LOCAL
    elseif tz == 4 then
        return core.TZ_SERVER
    elseif tz == 5 then
        return core.TZ_FINANCIAL
    elseif tz == 6 then
        return core.TZ_TS
    end
end
function indi_alerts:Prepare()
    self.Show = instance.parameters.Show;
    self.Live = instance.parameters.Live;
    self.ShowAlert = instance.parameters.ShowAlert;
    self.ToTime = self:GetTimezone();
    
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    for i = 1, 100 do 
        local on = instance.parameters:getBoolean("ON" .. i);
        if on == nil then
            break;
        end 
        local alert = {};
        alert.id = i;
        alert.UpCondition = alerts[i].UpCondition;
        alert.FormatMessage = alerts[i].FormatMessage;
        alert.DownCondition = alerts[i].DownCondition;
        alert.OnChange = alerts[i].OnChange;
        alert.Stage = alerts[i].Stage;
        alert.FilterConsecutive = alerts[i].FilterConsecutive;
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = on;
        alert.DrawingMode = instance.parameters:getString("drawing_mode" .. i);
        alert.UpSymbol = string.char(instance.parameters:getInteger("UpSymbol" .. i));
        local down_symbol = instance.parameters:getInteger("DownSymbol" .. i);
        if down_symbol ~= nil then
            alert.DownSymbol = string.char(down_symbol);
        end
        alert.UpColor = instance.parameters:getColor("UpColor" .. i);
        alert.DownColor = instance.parameters:getColor("DownColor" .. i);
        alert.Up = self.PlaySound and instance.parameters:getString("Up" .. i) or nil;
        alert.Down = self.PlaySound and instance.parameters:getString("Down" .. i) or nil;
        if alert.DownSymbol == nil then
            alert.DownSymbol = alert.UpSymbol;
            alert.DownColor = alert.UpColor;
            alert.Down = alert.Up;
        end
        assert(not(self.PlaySound) or (self.PlaySound and alert.Up ~= "") or (self.PlaySound and alert.Up ~= ""), "Sound file must be chosen"); 
        assert(not(self.PlaySound) or (self.PlaySound and alert.Down ~= "") or (self.PlaySound and alert.Down ~= ""), "Sound file must be chosen");
        alert.U = nil;
        alert.D = nil;
        if instance.parameters.strategy_output then
            alert.Alert = instance:addStream("strat_signal_" .. i, core.Dot, "strat_signal_" .. i, "Strategy signal #" .. i, core.rgb(0, 0, 0), 0, 0);
        else
            alert.Alert = instance:addInternalStream(0, 0);
        end
        alert.AlertLevel = instance:addInternalStream(0, 0);
        function alert:Clear(period)
            local bookmark = self.Alert:getBookmark(i);
            if bookmark ~= period then
                return;
            end
            local i = 1;
            while (bookmark ~= -1) do
                bookmark = self.Alert:getBookmark(i + 1);
                self.Alert:setBookmark(i, bookmark);
                i = i + 1;
            end
        end
        function alert:AddBookmark(period)
            local i = 1;
            local bookmark = self.Alert:getBookmark(i);
            if bookmark == period then
                return;
            end
            self.Alert:setBookmark(1, period);
            while (bookmark ~= -1) do
                local last_bookmark = self.Alert:getBookmark(i + 1);
                self.Alert:setBookmark(i + 1, bookmark);
                bookmark = last_bookmark;
                i = i + 1;
            end
        end
        function alert:DownAlert(source, period, level, historical_period, metadata)
            if self.FilterConsecutive then
                local last_signal = self:GetLast(period - 1);
                if last_signal == -1 then
                    return;
                end
            end
            local text = self.FormatMessage(source, period, level, self.Label, false, metadata);
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = -1;
            self:AddBookmark(period);
            self.AlertLevel[period] = level;
            self.U = nil;
            if self.D ~= source:date(period) and period == source:size() - 1 - shift then
                self.D = source:date(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Down);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:UpAlert(source, period, level, historical_period, metadata)
            if self.FilterConsecutive then
                local last_signal = self:GetLast(period - 1);
                if last_signal == 1 then
                    return;
                end
            end
            local text = self.FormatMessage(source, period, level, self.Label, true, metadata);
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = 1;
            self:AddBookmark(period);
            self.AlertLevel[period] = level;
            self.D = nil;
            if self.U ~= source:date(period) and period == source:size() - 1 - shift then
                self.U = source:date(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Up);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:GetLast(period)
            local index = self.Alert:getBookmark(1);
            if index == -1 then
                return nil;
            end
            return self.Alert[index], index, self.AlertLevel[index];
        end
        self.Alerts[#self.Alerts + 1] = alert;
    end

    self.Email = self.SendEmail and instance.parameters.Email or nil;
    assert(not(self.SendEmail) or (self.SendEmail and self.Email ~= ""), "E-mail address must be specified");
    self.RecurrentSound = instance.parameters.RecurrentSound;

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = 1234;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, self.source:instrument() .. " " .. label .. " : " .. note);
end

function indi_alerts:SoundAlert(Sound)
    if not self.PlaySound then
        return;
    end
    terminal:alertSound(Sound, self.RecurrentSound);
end

function indi_alerts:EmailAlert(label, Subject, period)
    if not self.SendEmail then
        return
    end

    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;   
    local Symbol = "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(self.Email, profile:id(), text);
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return;
    end
    
    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;
    local Symbol= "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW));
end

function indi_alerts:AlertTelegram(message, instrument, timeframe) local alert = {}; alert.Text = message or ""; alert.Instrument = instrument or ""; alert.TimeFrame = timeframe or ""; self._alerts[#self._alerts + 1] = alert; end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+