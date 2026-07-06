-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70663

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
local Modules = {};
-- Indicator profile initialization routine
function Init()
    indicator:name("ZigZag with counter_v9");
    indicator:description("ZigZag with counts of Bars, Pips, Ticks Volumes, Swing %, Fibonacci Levels and Highest/Lowest prices");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Depth", "Depth", "The minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
    indicator.parameters:addColor("Zig_color", "Up swing color", "Up swing color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Zag_color", "Down swing color", "Down swing color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthZigZag", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleZigZag", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Displaying for information");
    indicator.parameters:addColor("Text_color_Top", "Top Label Text color", "Top Label Text color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Text_color_Bottom", "Bottom Label Text color", "Bottom Label Text color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TextSize", "Text size", "Text size of the label", 12);
    indicator.parameters:addDouble("V_Shift", "Vertical Label shift", "Vertical Label shift relative to the price", 0.0);
    indicator.parameters:addBoolean("LabelBars", "Bars Counting", "Select true to see the number of bars in the label and false to not see them", false);
    indicator.parameters:addBoolean("LabelPips", "Pips Counting", "Select true to see the number of pips in the label and false to not see them", false);
    indicator.parameters:addBoolean("LabelVols", "Volumes Counting", "Select true to see the volumes of ticks in the label and false to not see them", false);
    indicator.parameters:addBoolean("LabelSwing", "Swing % Calculation", "Select true to see the swing percentage in the label and false to not see it", false);
    indicator.parameters:addBoolean("LabelHLp", "Highest/Lowest Prices", "Select true to see the highest / lowest prices in the label and false to not see them", false);
	indicator.parameters:addBoolean("LabelFibo", "Fibonacci Levels", "Select true to see the Fibonacci levels in the label and false to not see them", true);
	indicator.parameters:addGroup("Export");
	indicator.parameters:addFile("export_file", "Exoport file", "", core.app_path() .. "\\log\\ZZCV9.csv");
    signaler:Init(indicator.parameters);
end

local Depth;
local Deviation;
local Backstep;

local first;
local source = nil;

-- Streams block
local ZigC;
local ZagC;
local out;
local HighMap = nil;
local LowMap = nil;
local TextBuff= nil;
local pipSize;
local TF_Bar = nil;
local TopPos = nil;			--2;		--1;	-- to place a line from the top of candle to better seeing for function Update()
local BottomPos = nil;		--2;		--1;	-- to place a line from the bottom of candle to better seeing for function Update()
local V_Shift;
local DisplayBars;
local DisplayPips;
local DisplayVols;
local DisplaySwng;
local DisplayHLp;
local DisplayFibo;
local PricePrecision;
local EXPORT_COMMAND_ID = 1;
local export_file;
local dist;

function Prepare(nameOnly)
    signaler:Prepare(nameOnly);
	export_file = instance.parameters.export_file;
	Depth = instance.parameters.Depth;
	Deviation = instance.parameters.Deviation;
	Backstep = instance.parameters.Backstep;
	source = instance.source;
	first = source:first();
	PricePrecision = source:getPrecision();

	local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
	instance:name(name);

	if   (nameOnly) then
        return;
    end

    dist = instance:addInternalStream(0, 0);

	out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first);
	out:setWidth(instance.parameters.widthZigZag);
	out:setStyle(instance.parameters.styleZigZag);
    zz = CreateZigZag(out, Depth, Deviation, Backstep, instance.parameters.Zig_color, instance.parameters.Zag_color);
	TF_Bar = source:barSize();

	TextBuff_Top 	= instance:createTextOutput ("Text", "Text", "Arial", instance.parameters.TextSize, core.H_Center, core.V_Top, instance.parameters.Text_color_Top, first);
	TextBuff_Bottom 	= instance:createTextOutput ("Text", "Text", "Arial", instance.parameters.TextSize, core.H_Center, core.V_Bottom, instance.parameters.Text_color_Bottom, first);

	pipSize=source:pipSize();

	V_Shift = instance.parameters.V_Shift*pipSize;

	DisplayBars	= instance.parameters.LabelBars;
	DisplayPips	= instance.parameters.LabelPips;
	DisplayVols	= instance.parameters.LabelVols;
	DisplaySwng	= instance.parameters.LabelSwing;
	DisplayHLp	= instance.parameters.LabelHLp;
	DisplayFibo	= instance.parameters.LabelFibo;

	assert(not(DisplayBars==false and DisplayPips==false and DisplayVols==false and DisplaySwng==false and DisplayHLp==false and DisplayFibo==false), "At least one information must be turned on");
	core.host:execute("addCommand", EXPORT_COMMAND_ID, "Export", "Export");
end

function CreateZigZag(stream, Depth, Deviation, Backstep, ZigC, ZagC)
    local searchBoth = 0
    local searchPeak = 1
    local searchLawn = -1
    local zz = {};
    zz.out = stream;
    zz.Depth = Depth;
    zz.Deviation = Deviation;
    zz.Backstep = Backstep;
    zz.TotalPeaks = 0;
    zz.SearchMode = instance:addInternalStream(0, 0)
    zz.Peak = instance:addInternalStream(0, 0)
    zz.HighMap = instance:addInternalStream(0, 0)
    zz.LowMap = instance:addInternalStream(0, 0)
    function zz:ClearStreams(period)
        self.SearchMode:setNoData(period);
        self.Peak:setNoData(period);
        self.out:setNoData(period);
		TextBuff_Top:setNoData(period);
		TextBuff_Bottom:setNoData(period);
    end
    function zz:RemoveLast()
        local index = 1;
        local bookmark = self.out:getBookmark(index);
        if bookmark == -1 then
            return;
        end
        self:ClearStreams(bookmark);
        while (bookmark ~= -1) do
            local nextBookmark = self.out:getBookmark(index + 1);
            self.out:setBookmark(index, nextBookmark);
            bookmark = nextBookmark;
            index = index + 1;
        end
        self.TotalPeaks = self.TotalPeaks - 1;
    end
    function zz:DrawLine()
        local period = self.out:getBookmark(1);
        local last = self.out:getBookmark(2);
        if last == -1 then
            return;
        end
        if self.SearchMode[period] == -1 then
            core.drawLine(self.out, core.range(last, period), self.Peak[last], last, self.Peak[period], period, ZigC)
            self.out:setColor(last, ZagC)
        else
            core.drawLine(self.out, core.range(last, period), self.Peak[last], last, self.Peak[period], period, ZagC)
            self.out:setColor(last, ZigC)
        end
    end
    function zz:RegisterPeak(period, mode, peak)
        local index = 1;
        local bookmark = self.out:getBookmark(index);
        if (bookmark == period) then
            if mode ~= self.SearchMode[period] then
                self:RemoveLast();
                self:ReplaceLastPeak(period, mode, peak);
            end
            return;
        end
        while (bookmark ~= -1) do
            local nextBookmark = self.out:getBookmark(index + 1);
            self.out:setBookmark(index + 1, bookmark)
            bookmark = nextBookmark;
            index = index + 1;
        end

        self.TotalPeaks = index - 1;
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
		self:DrawLine();

        local first = period;
		local second = self.out:getBookmark(2);
        local third = self.out:getBookmark(3);
        local last = 3;
        while third ~= -1 do
            if mode ~= 1 then
                dist[first] = (self.Peak[first] - self.Peak[second]) / source:pipSize();
                TextBuff_Top:set(first, self.Peak[first] + V_Shift,
                    TextFormat(last - 2, first - second, self.Peak[first] - self.Peak[second], self.Peak[second] - self.Peak[third],
                        RegisterTicksVolume(second, first), "+ " .. string.format("%.4f", ((self.Peak[first] / self.Peak[second]) - 1) * 100),
                        "Highest = " .. string.format("%5." .. source:getPrecision() .. "f", self.Peak[first])));
                TextBuff_Bottom:setNoData(first)
            else
                dist[first] = (self.Peak[first] - self.Peak[second]) / source:pipSize();
                TextBuff_Bottom:set(first, self.Peak[first] - V_Shift,
                    TextFormat(last - 2, first - second, self.Peak[second] - self.Peak[first], self.Peak[third] - self.Peak[second],
                        RegisterTicksVolume(second, first), "- " .. string.format("%.4f", (self.Peak[second] - self.Peak[first]) / self.Peak[second] * 100),
                        "Lowest = " .. string.format("%5." .. source:getPrecision() .. "f", self.Peak[first])));
                TextBuff_Top:setNoData(first)
            end
            mode = mode * (-1)
            last = last + 1;
            first = second;
            second = third;
            third = self.out:getBookmark(last);
        end
    end
    function zz:EnumPeaks()
        local enum = {};
        enum.zz = self;
        enum.Index = 0;
        function enum:Next()
            self.Index = self.Index + 1;
            return self.Index <= self.zz.TotalPeaks;
        end
        function enum:GetData()
            local period = self.zz.out:getBookmark(self.Index);
            if period == -1 then
                return nil;
            end
            return period, self.zz.Peak[period], self.zz.SearchMode[period];
        end
        return enum;
    end
    function zz:ReplaceLastPeak(period, mode, peak)
        local last = self.out:getBookmark(1);
        if last ~= -1 then
            self:ClearStreams(last);
        end
        self.out:setBookmark(1, period)
        self.SearchMode[period] = mode
        self.Peak[period] = peak
		self:DrawLine();

		local first = period;
		local second = self.out:getBookmark(2);
        local third = self.out:getBookmark(3);
        local last = 3;
        while third ~= -1 do
            if mode ~= 1 then
                dist[first] = (self.Peak[first] - self.Peak[second]) / source:pipSize();
                TextBuff_Top:set(first, self.Peak[first] + V_Shift,
                    TextFormat(last - 2, first - second, self.Peak[first] - self.Peak[second], self.Peak[second] - self.Peak[third],
                        RegisterTicksVolume(second, first), "+ " .. string.format("%.4f", ((self.Peak[first] / self.Peak[second]) - 1) * 100),
                        "Highest = " .. string.format("%5." .. source:getPrecision() .. "f", self.Peak[first])));
                TextBuff_Bottom:setNoData(first)
            else
                dist[first] = (self.Peak[first] - self.Peak[second]) / source:pipSize();
                TextBuff_Bottom:set(first, self.Peak[first] - V_Shift,
                    TextFormat(last - 2, first - second, self.Peak[second] - self.Peak[first], self.Peak[third] - self.Peak[second],
					RegisterTicksVolume(second, first), "- " .. string.format("%.4f", (self.Peak[second] - self.Peak[first]) / self.Peak[second] * 100),
                    "Lowest = " .. string.format("%5." .. source:getPrecision() .. "f", self.Peak[first])));
					TextBuff_Top:setNoData(first)
            end
            mode = mode * (-1)
            last = last + 1;
            first = second;
            second = third;
            third = self.out:getBookmark(last);
        end
    end
    function zz:Clear()
        self.lastlow = nil
        self.lasthigh = nil
        self.TotalPeaks = 0;
    end
    function zz:Calc(period)
        if (period < self.Depth) then
            return;
        end
        local range = period - self.Depth + 1;
        local val = mathex.min(source.low, range, period)
        if val ~= self.lastlow then
            self.lastlow = val
            if (source.low[period] - val) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.LowMap[i] ~= 0) and (self.LowMap[i] > val) then
                        self.LowMap[i] = 0
                    end
                end
            end
            if source.low[period] == val then
                self.LowMap[period] = val
            else
                self.LowMap[period] = 0
            end
        end
        val = mathex.max(source.high, range, period)
        if val ~= lasthigh then
            self.lasthigh = val
            if (val - source.high[period]) > (source:pipSize() * self.Deviation) then
                val = nil
            else
                -- check for the previous backstep lows
                for i = period - 1, period - self.Backstep + 1, -1 do
                    if (self.HighMap[i] ~= 0) and (self.HighMap[i] < val) then
                        self.HighMap[i] = 0
                    end
                end
            end
            if source.high[period] == val then
                self.HighMap[period] = val
            else
                self.HighMap[period] = 0
            end
        end

        local prev_peak = self.out:getBookmark(2)
        local start = self.Depth
        local last_peak_i = self.out:getBookmark(1)
        if last_peak_i ~= -1 then
            start = last_peak_i
        end

        for i = start, period, 1 do
            if last_peak_i == -1 then
                if (self.HighMap[i] ~= 0) then
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                elseif (self.LowMap[i] ~= 0) then
                    last_peak_i = i
                    self:RegisterPeak(i, searchPeak, self.LowMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchPeak then
                if (self.LowMap[i] ~= 0 and self.LowMap[i] < self.Peak[last_peak_i]) then
                    last_peak_i = i
                    self:ReplaceLastPeak(i, searchPeak, self.LowMap[i])
                end
                if self.HighMap[i] ~= 0 and self.LowMap[i] == 0 then
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchLawn, self.HighMap[i])
                end
            elseif self.SearchMode[last_peak_i] == searchLawn then
                if (self.HighMap[i] ~= 0 and self.HighMap[i] > self.Peak[last_peak_i]) then
                    last_peak_i = i
                    self:ReplaceLastPeak(i, searchLawn, self.HighMap[i])
                end
                if self.LowMap[i] ~= 0 and self.HighMap[i] == 0 then
                    prev_peak = last_peak_i
                    last_peak_i = i
                    self:RegisterPeak(i, searchPeak, self.LowMap[i])
                end
            end
        end
    end

    return zz;
end
local lastperiod = -1;

function TextFormat(index, bars, pips, pips2, tickvol, percent1, HLprice)	-- called by lines at end of code
	-- Modified for printing text with "RETURN" & "NEW LINE" in accordance with the LUA Language ; with also TopPos and BottomPos (see function Update() below)
	-- percent1 is the percentage returned by the following calculation : Pips / Current Close Price

	-- Formatting labels to be displayed


	local TextLabel = "Peak: " .. index;

	if DisplayBars then TextLabel 	= TextLabel .. "\r\n" .. "Bars: " .. math.abs(bars)+1; end
	if DisplayPips then TextLabel 	= TextLabel .. "\r\n" .. "Pips: " .. math.floor(math.abs(pips)/pipSize*10+0.5)/10; end
	if DisplayVols then TextLabel 	= TextLabel .. "\r\n" .. "Vols: ".. tickvol; end
	if DisplaySwng then TextLabel	= TextLabel .. "\r\n" .. percent1 .. " %"; end
	if DisplayHLp then TextLabel 	= TextLabel .. "\r\n" .. HLprice; end
---------------------------------********************-------------------------------------------------------

	if DisplayFibo then
        return TextLabel .. "\r\n" .. "Fibo: " .. math.floor(math.abs(pips/pips2)*1000+0.5)/1000;
	end
---------------------------------********************-------------------------------------------------------
end

function RegisterTicksVolume(from, period)
	return mathex.sum(source.volume, from, period);
end

function Update(period, mode)
    period = period - 1
    if period < 0 or source:serial(period) == lastserial then
        return
    end

    if mode == core.UpdateAll then
        zz:Clear();
    end

    lastserial = source:serial(period);
    zz:Calc(period);
    if period == source:size() - 1 then
        local peaks = zz:EnumPeaks();
		while (peaks:Next()) do
			local peakPeriod, peak, searchMode = peaks:GetData();
            if lastSignal ~= peakPeriod and dist:hasData(peakPeriod) then
                if dist[period] > threshold then
                    lastSignal = peakPeriod;
                    if searchMode == 1 then
                        signaler:Signal("Sell signal", source);
                    else
                        signaler:Signal("Buy signal", source);
                    end
                end
            end
        end
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
	if cookie == EXPORT_COMMAND_ID then
		local index = 0;
		local splitter = ";";
		log_file = io.open(export_file, "w");
		log_file:write("Index");
		log_file:write(splitter);
		log_file:write("Bars");
		log_file:write(splitter);
		log_file:write("Pips");
		log_file:write(splitter);
		log_file:write("Vols");
		log_file:write(splitter);
		log_file:write("%");
		log_file:write(splitter);
		log_file:write("Lo/Hi");
		log_file:write(splitter);
		log_file:write("Fib");
		log_file:write(splitter);
		log_file:write("\n");
		local peaks = zz:EnumPeaks();
		while (peaks:Next()) do
			local peakPeriod, peak, searchMode = peaks:GetData();
			if last_peak_2 ~= nil then
				log_file:write(tostring(index));
				log_file:write(splitter);
				log_file:write(tostring(last_peakPeriod_2 - last_peakPeriod_1 + 1));
				log_file:write(splitter);
				local pips = math.floor(math.abs(last_peak_2 - last_peak_1) / source:pipSize() * 10 + 0.5) / 10;
				log_file:write(tostring(pips));
				log_file:write(splitter);
				log_file:write(tostring(RegisterTicksVolume(last_peakPeriod_1, last_peakPeriod_2)));
				log_file:write(splitter);
				if searchMode ~= -1 then
					log_file:write("- " .. string.format("%.4f", (last_peak_1 - last_peak_2) / last_peak_1 * 100));
					log_file:write(splitter);
				else
					log_file:write("+ " .. string.format("%.4f", ((last_peak_2 / last_peak_1) - 1) * 100));
					log_file:write(splitter);
				end
				log_file:write(string.format("%5." .. source:getPrecision() .. "f", last_peak_1));
				log_file:write(splitter);
				local pips2 = math.floor(math.abs(last_peak_1 - peak) / source:pipSize() * 10 + 0.5) / 10;
				if math.abs(pips) ~= math.abs(pips2) then
					log_file:write(string.format(math.floor(math.abs(pips / pips2) * 1000 + 0.5) / 1000));
				end
				log_file:write(splitter);
				log_file:write("\n");
				index = index + 1;
			end
			last_peakPeriod_2 = last_peakPeriod_1;
			last_peak_2 = last_peak_1;
			last_peakPeriod_1 = peakPeriod;
			last_peak_1 = peak;
		end

		log_file:write("\n");
		log_file:flush();
		log_file:close();
	end
end

function ReleaseInstance()
    signaler:ReleaseInstance()
end

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.7";

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

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
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
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end

    parameters:addGroup("  Telegram/Discord/Other platforms");
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");

    parameters:addGroup("  Trade coping");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
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