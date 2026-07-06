-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76481
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.

local vars = {};
function Init()
    indicator:name("Initial Balance Breakout Signals [LuxAlgo]");
    indicator:description("Initial Balance Breakout Signals [LuxAlgo]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Display Last X IBs", "", 10, 1);
    indicator.parameters:addBoolean("param2", "Display All", "", true);
    vars["SIX_PER_EM_SPACE"] = " ";
    vars["initialBalanceSpacing"] = vars["SIX_PER_EM_SPACE"] .. vars["SIX_PER_EM_SPACE"];
    indicator.parameters:addString("param3", "Initial Balance" .. vars["initialBalanceSpacing"], "", "0830-0930");
    indicator.parameters:addBoolean("param4", "Auto", "", true);
    indicator.parameters:addBoolean("param5", "Breakouts", "", true);
    indicator.parameters:addString("param6", "", "", "0930-0830");
    indicator.parameters:addBoolean("param7", "Auto", "", true);
    vars["EM_SPACE"] = " ";
    vars["EN_SPACE"] = " ";
    vars["extensionSpacing"] = vars["EM_SPACE"] .. vars["EN_SPACE"] .. vars["SIX_PER_EM_SPACE"];
    indicator.parameters:addBoolean("param8", "Top Extension %" .. vars["extensionSpacing"], "", true);
    indicator.parameters:addInteger("param9", "", "", 50, 1);
    indicator.parameters:addBoolean("param10", "Bottom Extension %", "", true);
    indicator.parameters:addInteger("param11", "", "", 50, 1);
    indicator.parameters:addBoolean("param12", "Display Fibonnaci", "", true);
    indicator.parameters:addBoolean("param13", "Reverse", "", false);
    indicator.parameters:addBoolean("param14", "", "", true);
    indicator.parameters:addDouble("param15", "", "", 0.786);
    vars["SILVER_50"] = core.colors().Silver + math.floor(50 / 100 * 255) * 16777216;
    indicator.parameters:addColor("param16", "", "", Graphics:GetColor(vars["SILVER_50"]));
    vars["DASHED"] = "Dashed";
    indicator.parameters:addString("param17", "", "", vars["DASHED"]);
    vars["DOTTED"] = "Dotted";
    indicator.parameters:addStringAlternative("param17", vars["DOTTED"], "", vars["DOTTED"]);
    indicator.parameters:addStringAlternative("param17", vars["DASHED"], "", vars["DASHED"]);
    vars["SOLID"] = "Solid";
    indicator.parameters:addStringAlternative("param17", vars["SOLID"], "", vars["SOLID"]);
    indicator.parameters:addBoolean("param18", "", "", true);
    indicator.parameters:addDouble("param19", "", "", 0.618);
    indicator.parameters:addColor("param20", "", "", Graphics:GetColor(vars["SILVER_50"]));
    indicator.parameters:addString("param21", "", "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param21", vars["DOTTED"], "", vars["DOTTED"]);
    indicator.parameters:addStringAlternative("param21", vars["DASHED"], "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param21", vars["SOLID"], "", vars["SOLID"]);
    indicator.parameters:addBoolean("param22", "", "", true);
    indicator.parameters:addDouble("param23", "", "", 0.500);
    indicator.parameters:addColor("param24", "", "", Graphics:GetColor(vars["SILVER_50"]));
    indicator.parameters:addString("param25", "", "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param25", vars["DOTTED"], "", vars["DOTTED"]);
    indicator.parameters:addStringAlternative("param25", vars["DASHED"], "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param25", vars["SOLID"], "", vars["SOLID"]);
    indicator.parameters:addBoolean("param26", "", "", true);
    indicator.parameters:addDouble("param27", "", "", 0.382);
    indicator.parameters:addColor("param28", "", "", Graphics:GetColor(vars["SILVER_50"]));
    indicator.parameters:addString("param29", "", "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param29", vars["DOTTED"], "", vars["DOTTED"]);
    indicator.parameters:addStringAlternative("param29", vars["DASHED"], "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param29", vars["SOLID"], "", vars["SOLID"]);
    indicator.parameters:addBoolean("param30", "", "", true);
    indicator.parameters:addDouble("param31", "", "", 0.236);
    indicator.parameters:addColor("param32", "", "", Graphics:GetColor(vars["SILVER_50"]));
    indicator.parameters:addString("param33", "", "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param33", vars["DOTTED"], "", vars["DOTTED"]);
    indicator.parameters:addStringAlternative("param33", vars["DASHED"], "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param33", vars["SOLID"], "", vars["SOLID"]);
    vars["FOUR_PER_EM_SPACE"] = " ";
    indicator.parameters:addBoolean("param34", "Display Labels" .. vars["FOUR_PER_EM_SPACE"], "", false);
    indicator.parameters:addInteger("param35", "|" .. vars["FOUR_PER_EM_SPACE"] .. " Text Size" .. vars["FOUR_PER_EM_SPACE"], "", 10);
    vars["forecastSpacing"] = vars["EM_SPACE"] .. vars["FOUR_PER_EM_SPACE"] .. vars["FOUR_PER_EM_SPACE"];
    indicator.parameters:addBoolean("param36", "Display Forecast" .. vars["forecastSpacing"], "", true);
    vars["FORECAST1"] = "IB Against Previous Open";
    vars["forecastMethodTooltip"] = "Select the forecast method.\nIB Against Previous Open calculates the average difference between the IB high and low and the previous day's IB open price.\nFilter by Current Day of Week option calculates the average difference between the IB high and low and the IB open price for the same day of the week.";
    indicator.parameters:addString("param37", "", vars["forecastMethodTooltip"], vars["FORECAST1"]);
    indicator.parameters:addStringAlternative("param37", vars["FORECAST1"], "", vars["FORECAST1"]);
    vars["FORECAST2"] = "Filter By Current Day Of Week";
    indicator.parameters:addStringAlternative("param37", vars["FORECAST2"], "", vars["FORECAST2"]);
    vars["forecastLengthTooltip"] = "The number of data points used to calculate the average.";
    indicator.parameters:addInteger("param38", "Forecast Memory", vars["forecastLengthTooltip"], 10, 2);
    vars["forecastMultTooltip"] = "This multiplier will be applied to the average. Bigger numbers will result in wider predicted ranges.";
    indicator.parameters:addDouble("param39", "Forecast Multiplier", vars["forecastMultTooltip"], 1.0, 0.1);
    vars["GREEN"] = Graphics:AddTransparency(core.rgb(8, 153, 129), 0);
    indicator.parameters:addColor("param40", "Forecast Top Color", "", Graphics:GetColor(vars["GREEN"]));
    vars["RED"] = Graphics:AddTransparency(core.rgb(242, 54, 69), 0);
    indicator.parameters:addColor("param41", "Forecast Bottom Color", "", Graphics:GetColor(vars["RED"]));
    indicator.parameters:addString("param42", "Forecast Style", "", vars["DOTTED"]);
    indicator.parameters:addStringAlternative("param42", vars["DOTTED"], "", vars["DOTTED"]);
    indicator.parameters:addStringAlternative("param42", vars["DASHED"], "", vars["DASHED"]);
    indicator.parameters:addStringAlternative("param42", vars["SOLID"], "", vars["SOLID"]);
    indicator.parameters:addColor("param43", "IB Top Color", "", Graphics:GetColor(vars["GREEN"]));
    indicator.parameters:addColor("param44", "IB Bottom Color", "", Graphics:GetColor(vars["RED"]));
    indicator.parameters:addInteger("param45", "Extension Transparency", "", 80, 0, 100);
end

local source;
local time;
local plot1;
local plot2;
function CreateType_initialBalance(period, startTimeValue, endTimeValue, dayOfWeekValue, openPriceValue, topValue, bottomValue, endOfSessionValue, linesValue, backgroundValue, fibosValue, labelsValue, forecastValue, forecastTopValue, forecastBottomValue)
    return {
        startTime = startTimeValue,
        endTime = endTimeValue,
        dayOfWeek = dayOfWeekValue,
        openPrice = openPriceValue,
        top = topValue,
        bottom = bottomValue,
        endOfSession = endOfSessionValue,
        lines = linesValue,
        background = backgroundValue,
        fibos = fibosValue,
        labels = labelsValue,
        forecast = forecastValue,
        forecastTop = forecastTopValue,
        forecastBottom = forecastBottomValue,
    };
end
function initialBalance_GetstartTime(self)
    if self == nil then return nil; end
    return self.startTime;
end
function initialBalance_SetstartTime(self, val)
    if self == nil then return nil; end
    self.startTime = val;
end
function initialBalance_GetendTime(self)
    if self == nil then return nil; end
    return self.endTime;
end
function initialBalance_SetendTime(self, val)
    if self == nil then return nil; end
    self.endTime = val;
end
function initialBalance_GetdayOfWeek(self)
    if self == nil then return nil; end
    return self.dayOfWeek;
end
function initialBalance_SetdayOfWeek(self, val)
    if self == nil then return nil; end
    self.dayOfWeek = val;
end
function initialBalance_GetopenPrice(self)
    if self == nil then return nil; end
    return self.openPrice;
end
function initialBalance_SetopenPrice(self, val)
    if self == nil then return nil; end
    self.openPrice = val;
end
function initialBalance_Gettop(self)
    if self == nil then return nil; end
    return self.top;
end
function initialBalance_Settop(self, val)
    if self == nil then return nil; end
    self.top = val;
end
function initialBalance_Getbottom(self)
    if self == nil then return nil; end
    return self.bottom;
end
function initialBalance_Setbottom(self, val)
    if self == nil then return nil; end
    self.bottom = val;
end
function initialBalance_GetendOfSession(self)
    if self == nil then return nil; end
    return self.endOfSession;
end
function initialBalance_SetendOfSession(self, val)
    if self == nil then return nil; end
    self.endOfSession = val;
end
function initialBalance_Getlines(self)
    if self == nil then return nil; end
    return self.lines;
end
function initialBalance_Setlines(self, val)
    if self == nil then return nil; end
    self.lines = val;
end
function initialBalance_Getbackground(self)
    if self == nil then return nil; end
    return self.background;
end
function initialBalance_Setbackground(self, val)
    if self == nil then return nil; end
    self.background = val;
end
function initialBalance_Getfibos(self)
    if self == nil then return nil; end
    return self.fibos;
end
function initialBalance_Setfibos(self, val)
    if self == nil then return nil; end
    self.fibos = val;
end
function initialBalance_Getlabels(self)
    if self == nil then return nil; end
    return self.labels;
end
function initialBalance_Setlabels(self, val)
    if self == nil then return nil; end
    self.labels = val;
end
function initialBalance_Getforecast(self)
    if self == nil then return nil; end
    return self.forecast;
end
function initialBalance_Setforecast(self, val)
    if self == nil then return nil; end
    self.forecast = val;
end
function initialBalance_GetforecastTop(self)
    if self == nil then return nil; end
    return self.forecastTop;
end
function initialBalance_SetforecastTop(self, val)
    if self == nil then return nil; end
    self.forecastTop = val;
end
function initialBalance_GetforecastBottom(self)
    if self == nil then return nil; end
    return self.forecastBottom;
end
function initialBalance_SetforecastBottom(self, val)
    if self == nil then return nil; end
    self.forecastBottom = val;
end
function CreateType_forecastData(period, topValue, bottomValue)
    return {
        top = topValue,
        bottom = bottomValue,
    };
end
function forecastData_Gettop(self)
    if self == nil then return nil; end
    return self.top;
end
function forecastData_Settop(self, val)
    if self == nil then return nil; end
    self.top = val;
end
function forecastData_Getbottom(self)
    if self == nil then return nil; end
    return self.bottom;
end
function forecastData_Setbottom(self, val)
    if self == nil then return nil; end
    self.bottom = val;
end
function CreateType_forecastArray(period, topsValue, bottomsValue)
    return {
        tops = topsValue,
        bottoms = bottomsValue,
    };
end
function forecastArray_Gettops(self)
    if self == nil then return nil; end
    return self.tops;
end
function forecastArray_Settops(self, val)
    if self == nil then return nil; end
    self.tops = val;
end
function forecastArray_Getbottoms(self)
    if self == nil then return nil; end
    return self.bottoms;
end
function forecastArray_Setbottoms(self, val)
    if self == nil then return nil; end
    self.bottoms = val;
end
function Create_addForecastData()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(top, bottom, openPrice, dayOfWeek, period, mode)
            local_vars["f_orecastArray"] = Triary(not (dayOfWeek == nil), Array:Get(vars["dayOfWeekForecastArray"]:Get(period), dayOfWeek), vars["simpleForecastArray"]:Get(period));
            Array:Push(forecastArray_Gettops(local_vars["f_orecastArray"]), SafeMinus(top, openPrice));
            Array:Push(forecastArray_Getbottoms(local_vars["f_orecastArray"]), SafeMinus(bottom, openPrice));
            if SafeGreater(Array:Size(forecastArray_Gettops(local_vars["f_orecastArray"])), vars["forecastLengthInput"]) then
                forecastArray_Gettops(local_vars["f_orecastArray"]):Shift();
                forecastArray_Getbottoms(local_vars["f_orecastArray"]):Shift();
                return forecastArray_Getbottoms(local_vars["f_orecastArray"]):Shift();
            end
        end
    };
end
function Create_gatherForecastData()
    local local_vars = {};
    local_vars["addForecastDataFunc3"] = Create_addForecastData();
    local_vars["addForecastDataFunc4"] = Create_addForecastData();
    local_vars["addForecastDataFunc5"] = Create_addForecastData(nil);
    local_vars["addForecastDataFunc6"] = Create_addForecastData(nil);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["addForecastDataFunc3"].Clear();
                local_vars["addForecastDataFunc4"].Clear();
                local_vars["addForecastDataFunc5"].Clear();
                local_vars["addForecastDataFunc6"].Clear();
            else
            end
            local_vars["top"] = 0;
            local_vars["bottom"] = 0;
            if SafeGE(Array:Size(vars["initialBalances"]:Get(period)), 2) then
                local_vars["currentInitialBalance"] = Array:Get(vars["initialBalances"]:Get(period), (-1));
                if vars["forecastFilter"] then
                    local_vars["addForecastDataFunc3"].GetValue(initialBalance_Gettop(local_vars["currentInitialBalance"]), initialBalance_Getbottom(local_vars["currentInitialBalance"]), initialBalance_GetopenPrice(local_vars["currentInitialBalance"]), initialBalance_GetdayOfWeek(local_vars["currentInitialBalance"]), period, mode);
                    return local_vars["addForecastDataFunc4"].GetValue(initialBalance_Gettop(local_vars["currentInitialBalance"]), initialBalance_Getbottom(local_vars["currentInitialBalance"]), initialBalance_GetopenPrice(local_vars["currentInitialBalance"]), initialBalance_GetdayOfWeek(local_vars["currentInitialBalance"]), period, mode);
                else
                    local_vars["lastInitialBalance"] = Array:Get(vars["initialBalances"]:Get(period), (-2));
                    local_vars["addForecastDataFunc5"].GetValue(initialBalance_Gettop(local_vars["currentInitialBalance"]), initialBalance_Getbottom(local_vars["currentInitialBalance"]), initialBalance_GetopenPrice(local_vars["lastInitialBalance"]), period, mode);
                    return local_vars["addForecastDataFunc6"].GetValue(initialBalance_Gettop(local_vars["currentInitialBalance"]), initialBalance_Getbottom(local_vars["currentInitialBalance"]), initialBalance_GetopenPrice(local_vars["lastInitialBalance"]), period, mode);
                end
            end
        end
    };
end
function Create_updateCurrentForecast()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            if SafeGreater(Array:Size(vars["initialBalances"]:Get(period)), 0) then
                local_vars["f_orecastArray"] = Triary(vars["forecastFilter"], Array:Get(vars["dayOfWeekForecastArray"]:Get(period), Time:DayOfWeek(source, period)), vars["simpleForecastArray"]:Get(period));
                local_vars["openPrice"] = Triary(vars["forecastFilter"], source.open:tick(period), initialBalance_GetopenPrice(Array:Get(vars["initialBalances"]:Get(period), (-1))));
                forecastData_Settop(vars["currentForecast"]:Get(period), SafePlus(local_vars["openPrice"], SafeMultiply(vars["forecastMultiplierInput"], Array:Avg(forecastArray_Gettops(local_vars["f_orecastArray"])))));
                forecastData_Setbottom(vars["currentForecast"]:Get(period), SafePlus(local_vars["openPrice"], SafeMultiply(vars["forecastMultiplierInput"], Array:Avg(forecastArray_Getbottoms(local_vars["f_orecastArray"])))));
                return forecastData_Getbottom(vars["currentForecast"]:Get(period));
            end
        end
    };
end
function Create_gatherData()
    local local_vars = {};
    local_vars["gatherForecastDataFunc2"] = Create_gatherForecastData();
    local_vars["updateCurrentForecastFunc7"] = Create_updateCurrentForecast();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["gatherForecastDataFunc2"].Clear();
                local_vars["updateCurrentForecastFunc7"].Clear();
            else
            end
            if vars["initialBalanceStart"] then
                if vars["forecastInput"] then
                    local_vars["gatherForecastDataFunc2"].GetValue(period, mode);
                    local_vars["updateCurrentForecastFunc7"].GetValue(period, mode);
                end
                Array:Push(vars["initialBalances"]:Get(period), CreateType_initialBalance(period, time:tick(period), time:tick(period), Time:DayOfWeek(source, period), source.open:tick(period), source.high:tick(period), source.low:tick(period), time:tick(period), Array:New(0, nil), nil, Array:New(0, nil), Array:New(0, nil), Array:New(0, nil), forecastData_Gettop(vars["currentForecast"]:Get(period)), forecastData_Getbottom(vars["currentForecast"]:Get(period))));
            end
            if SafeGreater(Array:Size(vars["initialBalances"]:Get(period)), 0) then
                local_vars["currentInitialBalance"] = Array:Last(vars["initialBalances"]:Get(period));
                initialBalance_SetendOfSession(local_vars["currentInitialBalance"], time:tick(period));
                if vars["insideInitialBalance"] then
                    initialBalance_SetendTime(local_vars["currentInitialBalance"], time:tick(period));
                    initialBalance_Settop(local_vars["currentInitialBalance"], SafeMax(initialBalance_Gettop(local_vars["currentInitialBalance"]), source.high:tick(period)));
                    initialBalance_Setbottom(local_vars["currentInitialBalance"], SafeMin(initialBalance_Getbottom(local_vars["currentInitialBalance"]), source.low:tick(period)));
                    return initialBalance_Getbottom(local_vars["currentInitialBalance"]);
                end
            end
        end
    };
end
function Create_breakouts()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            local_vars["bullishBreakout"] = false;
            local_vars["bearishBreakout"] = false;
            if vars["breakoutsInput"] and SafeGreater(Array:Size(vars["initialBalances"]:Get(period)), 0) and vars["insideBreakoutsSession"] then
                local_vars["currentInitialBalance"] = Array:Last(vars["initialBalances"]:Get(period));
                local_vars["bullishBreakout"] = SafeLess(source.close:tick(period - 1), initialBalance_Gettop(local_vars["currentInitialBalance"])) and SafeGreater(source.close:tick(period), initialBalance_Gettop(local_vars["currentInitialBalance"]));
                local_vars["bearishBreakout"] = SafeGreater(source.close:tick(period - 1), initialBalance_Getbottom(local_vars["currentInitialBalance"])) and SafeLess(source.close:tick(period), initialBalance_Getbottom(local_vars["currentInitialBalance"]));
            end
            return local_vars["bullishBreakout"], local_vars["bearishBreakout"];
        end
    };
end
function Create_style_s(style)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            if vars["DOTTED"] then
                return "dotted";
            elseif vars["DASHED"] then
                return "dashed";
            elseif vars["SOLID"] then
                return "solid";
            end
        end
    };
end
function Create_drawForecast()
    local local_vars = {};
    Line:Prepare(500);
    local_vars["styleFunc12"] = Create_style_s(vars["forecastStyleInput"]);
    local_vars["styleFunc13"] = Create_style_s(vars["forecastStyleInput"]);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(currentInitialBalance, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["styleFunc12"].Clear();
                local_vars["styleFunc13"].Clear();
            else
            end
            for _, eachLine in ipairs(Array:Enum(initialBalance_Getforecast(currentInitialBalance))) do
                Line:Delete(eachLine);
            end
            Array:Push(initialBalance_Getforecast(currentInitialBalance), Line:NewCP(ChartPoint:New(initialBalance_GetstartTime(currentInitialBalance), nil, initialBalance_GetforecastTop(currentInitialBalance)), ChartPoint:New(initialBalance_GetendOfSession(currentInitialBalance), nil, initialBalance_GetforecastTop(currentInitialBalance))):SetColor(vars["forecastTopColorInput"]):SetExtend("none"):SetStyle(local_vars["styleFunc12"].GetValue(period, mode)):SetWidth(1):SetXLocInit("bar_time"));
            return Array:Push(initialBalance_Getforecast(currentInitialBalance), Line:NewCP(ChartPoint:New(initialBalance_GetstartTime(currentInitialBalance), nil, initialBalance_GetforecastBottom(currentInitialBalance)), ChartPoint:New(initialBalance_GetendOfSession(currentInitialBalance), nil, initialBalance_GetforecastBottom(currentInitialBalance))):SetColor(vars["forecastBottomColorInput"]):SetExtend("none"):SetStyle(local_vars["styleFunc13"].GetValue(period, mode)):SetWidth(1):SetXLocInit("bar_time"));
        end
    };
end
function Create_drawFibonacciLevel_b_f(drawLevel, fibonacciLevel, fibonacciColor)
    local local_vars = {};
    Label:Prepare(500);
    return {
        Clear = function()
        end,
        GetValue = function(currentInitialBalance, fibonacciStyle, period, mode)
            if drawLevel then
                local_vars["fibonacciRange"] = Round(SafeMultiply(fibonacciLevel, (SafeMinus(initialBalance_Gettop(currentInitialBalance), initialBalance_Getbottom(currentInitialBalance)))), source:getPrecision());
                local_vars["priceLevel"] = Triary(vars["fiboReverseInput"], SafePlus(initialBalance_Getbottom(currentInitialBalance), local_vars["fibonacciRange"]), SafeMinus(initialBalance_Gettop(currentInitialBalance), local_vars["fibonacciRange"]));
                local_vars["lastPoint"] = ChartPoint:New(initialBalance_GetendOfSession(currentInitialBalance), nil, local_vars["priceLevel"]);
                Array:Push(initialBalance_Getfibos(currentInitialBalance), Line:NewCP(ChartPoint:New(initialBalance_GetstartTime(currentInitialBalance), nil, local_vars["priceLevel"]), local_vars["lastPoint"]):SetColor(fibonacciColor):SetExtend("none"):SetStyle(fibonacciStyle):SetWidth(1):SetXLocInit("bar_time"));
                if vars["fibosLabelsInput"] then
                    label_1_point = local_vars["lastPoint"];
                    Array:Push(initialBalance_Getlabels(currentInitialBalance), Label:New(core.formatDate(Label:GetSerial(label_1_x, source, "bar_time") or 0) .. "_1", "1", label_1_point.x, label_1_point.y):SetText(Str:Format("{0} ({1})", fibonacciLevel, local_vars["priceLevel"])):SetColor(Color(nil)):SetTextColor(fibonacciColor):SetStyle("left"):SetSize(vars["fibosLabelSizeInput"]):SetXLoc("bar_time"));
                end
            end
        end
    };
end
function Create_drawFibonnaciLevels()
    local local_vars = {};
    local_vars["drawFibonacciLevelFunc15"] = Create_drawFibonacciLevel_b_f(vars["fiboLevel1DisplayInput"], vars["fiboLevel1Input"], vars["fiboLevel1ColorInput"]);
    local_vars["styleFunc16"] = Create_style_s(vars["fiboLevel1StyleInput"]);
    local_vars["drawFibonacciLevelFunc17"] = Create_drawFibonacciLevel_b_f(vars["fiboLevel2DisplayInput"], vars["fiboLevel2Input"], vars["fiboLevel2ColorInput"]);
    local_vars["styleFunc18"] = Create_style_s(vars["fiboLevel2StyleInput"]);
    local_vars["drawFibonacciLevelFunc19"] = Create_drawFibonacciLevel_b_f(vars["fiboLevel3DisplayInput"], vars["fiboLevel3Input"], vars["fiboLevel3ColorInput"]);
    local_vars["styleFunc20"] = Create_style_s(vars["fiboLevel3StyleInput"]);
    local_vars["drawFibonacciLevelFunc21"] = Create_drawFibonacciLevel_b_f(vars["fiboLevel4DisplayInput"], vars["fiboLevel4Input"], vars["fiboLevel4ColorInput"]);
    local_vars["styleFunc22"] = Create_style_s(vars["fiboLevel4StyleInput"]);
    local_vars["drawFibonacciLevelFunc23"] = Create_drawFibonacciLevel_b_f(vars["fiboLevel5DisplayInput"], vars["fiboLevel5Input"], vars["fiboLevel5ColorInput"]);
    local_vars["styleFunc24"] = Create_style_s(vars["fiboLevel5StyleInput"]);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(currentInitialBalance, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["styleFunc16"].Clear();
                local_vars["drawFibonacciLevelFunc15"].Clear();
                local_vars["styleFunc18"].Clear();
                local_vars["drawFibonacciLevelFunc17"].Clear();
                local_vars["styleFunc20"].Clear();
                local_vars["drawFibonacciLevelFunc19"].Clear();
                local_vars["styleFunc22"].Clear();
                local_vars["drawFibonacciLevelFunc21"].Clear();
                local_vars["styleFunc24"].Clear();
                local_vars["drawFibonacciLevelFunc23"].Clear();
            else
            end
            for _, eachLine in ipairs(Array:Enum(initialBalance_Getfibos(currentInitialBalance))) do
                Line:Delete(eachLine);
            end
            for _, eachLabel in ipairs(Array:Enum(initialBalance_Getlabels(currentInitialBalance))) do
                Label:Delete(eachLabel);
            end
            local_vars["drawFibonacciLevelFunc15"].GetValue(currentInitialBalance, local_vars["styleFunc16"].GetValue(period, mode), period, mode);
            local_vars["drawFibonacciLevelFunc17"].GetValue(currentInitialBalance, local_vars["styleFunc18"].GetValue(period, mode), period, mode);
            local_vars["drawFibonacciLevelFunc19"].GetValue(currentInitialBalance, local_vars["styleFunc20"].GetValue(period, mode), period, mode);
            local_vars["drawFibonacciLevelFunc21"].GetValue(currentInitialBalance, local_vars["styleFunc22"].GetValue(period, mode), period, mode);
            return local_vars["drawFibonacciLevelFunc23"].GetValue(currentInitialBalance, local_vars["styleFunc24"].GetValue(period, mode), period, mode);
        end
    };
end
function Create_drawInitialBalanceLevel_b_i(extension, multiplier, c_olor)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(currentInitialBalance, level, period, mode)
            Array:Push(initialBalance_Getlines(currentInitialBalance), Line:NewCP(ChartPoint:New(initialBalance_GetstartTime(currentInitialBalance), nil, level), ChartPoint:New(initialBalance_GetendOfSession(currentInitialBalance), nil, level)):SetColor(c_olor):SetExtend("none"):SetStyle("solid"):SetWidth(1):SetXLocInit("bar_time"));
            if extension then
                local_vars["extensionLevel"] = Round(SafePlus(level, SafeMultiply(multiplier, (SafeMinus(initialBalance_Gettop(currentInitialBalance), initialBalance_Getbottom(currentInitialBalance))))), source:getPrecision());
                Array:Push(initialBalance_Getlines(currentInitialBalance), Line:NewCP(ChartPoint:New(initialBalance_GetstartTime(currentInitialBalance), nil, local_vars["extensionLevel"]), ChartPoint:New(initialBalance_GetendOfSession(currentInitialBalance), nil, local_vars["extensionLevel"])):SetColor(c_olor):SetExtend("none"):SetStyle("solid"):SetWidth(1):SetXLocInit("bar_time"));
                Linefill:New(Array:Get(initialBalance_Getlines(currentInitialBalance), (-1)), Array:Get(initialBalance_Getlines(currentInitialBalance), (-2))):SetColor(c_olor + math.floor(vars["transparencyInput"] / 100 * 255) * 16777216);
                return Linefill:New(Array:Get(initialBalance_Getlines(currentInitialBalance), (-1)), Array:Get(initialBalance_Getlines(currentInitialBalance), (-2))):SetColor(c_olor + math.floor(vars["transparencyInput"] / 100 * 255) * 16777216);
            end
        end
    };
end
function Create_drawInitialBalanceLevel_b(extension, c_olor)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(currentInitialBalance, level, multiplier, period, mode)
            Array:Push(initialBalance_Getlines(currentInitialBalance), Line:NewCP(ChartPoint:New(initialBalance_GetstartTime(currentInitialBalance), nil, level), ChartPoint:New(initialBalance_GetendOfSession(currentInitialBalance), nil, level)):SetColor(c_olor):SetExtend("none"):SetStyle("solid"):SetWidth(1):SetXLocInit("bar_time"));
            if extension then
                local_vars["extensionLevel"] = Round(SafePlus(level, SafeMultiply(multiplier, (SafeMinus(initialBalance_Gettop(currentInitialBalance), initialBalance_Getbottom(currentInitialBalance))))), source:getPrecision());
                Array:Push(initialBalance_Getlines(currentInitialBalance), Line:NewCP(ChartPoint:New(initialBalance_GetstartTime(currentInitialBalance), nil, local_vars["extensionLevel"]), ChartPoint:New(initialBalance_GetendOfSession(currentInitialBalance), nil, local_vars["extensionLevel"])):SetColor(c_olor):SetExtend("none"):SetStyle("solid"):SetWidth(1):SetXLocInit("bar_time"));
                Linefill:New(Array:Get(initialBalance_Getlines(currentInitialBalance), (-1)), Array:Get(initialBalance_Getlines(currentInitialBalance), (-2))):SetColor(c_olor + math.floor(vars["transparencyInput"] / 100 * 255) * 16777216);
                return Linefill:New(Array:Get(initialBalance_Getlines(currentInitialBalance), (-1)), Array:Get(initialBalance_Getlines(currentInitialBalance), (-2))):SetColor(c_olor + math.floor(vars["transparencyInput"] / 100 * 255) * 16777216);
            end
        end
    };
end
function Create_drawInitialBalance()
    local local_vars = {};
    local_vars["drawForecastFunc11"] = Create_drawForecast();
    local_vars["drawFibonnaciLevelsFunc14"] = Create_drawFibonnaciLevels();
    local_vars["drawInitialBalanceLevelFunc25"] = Create_drawInitialBalanceLevel_b_i(vars["topExtensionInput"], vars["topMultiplierInput"], vars["ibTopColorInput"]);
    local_vars["drawInitialBalanceLevelFunc26"] = Create_drawInitialBalanceLevel_b(vars["bottomExtensionInput"], vars["ibBottomColorInput"]);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(currentInitialBalance, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["drawForecastFunc11"].Clear();
                local_vars["drawFibonnaciLevelsFunc14"].Clear();
                local_vars["drawInitialBalanceLevelFunc25"].Clear();
                local_vars["drawInitialBalanceLevelFunc26"].Clear();
            else
            end
            if vars["forecastInput"] then
                local_vars["drawForecastFunc11"].GetValue(currentInitialBalance, period, mode);
            end
            if vars["fibonacciInput"] then
                local_vars["drawFibonnaciLevelsFunc14"].GetValue(currentInitialBalance, period, mode);
            end
            for _, eachLine in ipairs(Array:Enum(initialBalance_Getlines(currentInitialBalance))) do
                Line:Delete(eachLine);
            end
            local_vars["drawInitialBalanceLevelFunc25"].GetValue(currentInitialBalance, initialBalance_Gettop(currentInitialBalance), period, mode);
            local_vars["drawInitialBalanceLevelFunc26"].GetValue(currentInitialBalance, initialBalance_Getbottom(currentInitialBalance), SafeMultiply((-1), vars["bottomMultiplierInput"]), period, mode);
            Box:Delete(initialBalance_Getbackground(currentInitialBalance));
            initialBalance_Setbackground(currentInitialBalance, Box:NewCP(source, "1", ChartPoint:New(initialBalance_GetstartTime(currentInitialBalance), nil, initialBalance_Gettop(currentInitialBalance)), ChartPoint:New(initialBalance_GetendTime(currentInitialBalance), nil, initialBalance_Getbottom(currentInitialBalance))):SetBgColor(core.colors().Silver + math.floor(90 / 100 * 255) * 16777216):SetBorderColor(core.colors().Silver + math.floor(90 / 100 * 255) * 16777216):SetXLoc("bar_time"));
            return initialBalance_Getbackground(currentInitialBalance);
        end
    };
end
function Create_drawInitialBalances_i(initialBalanceNumber)
    local local_vars = {};
    local_vars["drawInitialBalanceFunc10"] = Create_drawInitialBalance();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["drawInitialBalanceFunc10"].Clear();
            else
            end
            local_vars["size"] = Array:Size(vars["initialBalances"]:Get(period));
            if SafeGreater(local_vars["size"], 0) then
                local_vars["startIndex"] = SafeMinus(local_vars["size"], (Triary(vars["displayAllInput"], local_vars["size"], initialBalanceNumber)));
                for _, currentInitialBalance in ipairs(Array:Enum(vars["initialBalances"]:Get(period):Slice(local_vars["startIndex"], local_vars["size"]))) do
                    local_vars["drawInitialBalanceFunc10"].GetValue(currentInitialBalance, period, mode);
                end
            end
        end
    };
end
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["initialBalanceSizeInput"] = instance.parameters.param1;
    vars["displayAllInput"] = instance.parameters.param2;
    vars["initialBalanceAutoInput"] = instance.parameters.param4;
    vars["breakoutsInput"] = instance.parameters.param5;
    vars["breakoutsAutoInput"] = instance.parameters.param7;
    vars["topExtensionInput"] = instance.parameters.param8;
    vars["bottomExtensionInput"] = instance.parameters.param10;
    vars["fibonacciInput"] = instance.parameters.param12;
    vars["fiboReverseInput"] = instance.parameters.param13;
    vars["fiboLevel5DisplayInput"] = instance.parameters.param14;
    vars["fiboLevel5Input"] = instance.parameters.param15;
    vars["SILVER_50"] = core.colors().Silver + math.floor(50 / 100 * 255) * 16777216;
    vars["fiboLevel5ColorInput"] = Graphics:AddTransparency(instance.parameters.param16, Graphics:GetTransparencyPercent(vars["SILVER_50"]));
    vars["fiboLevel5StyleInput"] = instance.parameters.param17;
    vars["fiboLevel4DisplayInput"] = instance.parameters.param18;
    vars["fiboLevel4Input"] = instance.parameters.param19;
    vars["fiboLevel4ColorInput"] = Graphics:AddTransparency(instance.parameters.param20, Graphics:GetTransparencyPercent(vars["SILVER_50"]));
    vars["fiboLevel4StyleInput"] = instance.parameters.param21;
    vars["fiboLevel3DisplayInput"] = instance.parameters.param22;
    vars["fiboLevel3Input"] = instance.parameters.param23;
    vars["fiboLevel3ColorInput"] = Graphics:AddTransparency(instance.parameters.param24, Graphics:GetTransparencyPercent(vars["SILVER_50"]));
    vars["fiboLevel3StyleInput"] = instance.parameters.param25;
    vars["fiboLevel2DisplayInput"] = instance.parameters.param26;
    vars["fiboLevel2Input"] = instance.parameters.param27;
    vars["fiboLevel2ColorInput"] = Graphics:AddTransparency(instance.parameters.param28, Graphics:GetTransparencyPercent(vars["SILVER_50"]));
    vars["fiboLevel2StyleInput"] = instance.parameters.param29;
    vars["fiboLevel1DisplayInput"] = instance.parameters.param30;
    vars["fiboLevel1Input"] = instance.parameters.param31;
    vars["fiboLevel1ColorInput"] = Graphics:AddTransparency(instance.parameters.param32, Graphics:GetTransparencyPercent(vars["SILVER_50"]));
    vars["fiboLevel1StyleInput"] = instance.parameters.param33;
    vars["fibosLabelsInput"] = instance.parameters.param34;
    vars["fibosLabelSizeInput"] = instance.parameters.param35;
    vars["forecastInput"] = instance.parameters.param36;
    vars["forecastModeInput"] = instance.parameters.param37;
    vars["forecastLengthInput"] = instance.parameters.param38;
    vars["forecastMultiplierInput"] = instance.parameters.param39;
    vars["GREEN"] = Graphics:AddTransparency(core.rgb(8, 153, 129), 0);
    vars["forecastTopColorInput"] = Graphics:AddTransparency(instance.parameters.param40, Graphics:GetTransparencyPercent(vars["GREEN"]));
    vars["RED"] = Graphics:AddTransparency(core.rgb(242, 54, 69), 0);
    vars["forecastBottomColorInput"] = Graphics:AddTransparency(instance.parameters.param41, Graphics:GetTransparencyPercent(vars["RED"]));
    vars["forecastStyleInput"] = instance.parameters.param42;
    vars["ibTopColorInput"] = Graphics:AddTransparency(instance.parameters.param43, Graphics:GetTransparencyPercent(vars["GREEN"]));
    vars["ibBottomColorInput"] = Graphics:AddTransparency(instance.parameters.param44, Graphics:GetTransparencyPercent(vars["RED"]));
    vars["transparencyInput"] = instance.parameters.param45;
    vars["initialBalances"] = Variable:Create();
    vars["currentForecast"] = Variable:Create();
    vars["simpleForecastArray"] = Variable:Create();
    vars["dayOfWeekForecastArray"] = Variable:Create();
    vars["autoIBStartTime"] = Variable:Create();
    time = instance:addInternalStream(0, 0);
    vars["!insideInitialBalance_stream"] = instance:addInternalStream(0, 0);
    vars["gatherDataFunc1"] = Create_gatherData();
    vars["breakoutsFunc8"] = Create_breakouts();
    plot1 = instance:createTextOutput("plot1", "Bullish Breakout", "Wingdings", 12, core.H_Center, core.V_Bottom, vars["ibTopColorInput"]);
    plot2 = instance:createTextOutput("plot2", "Bearish Breakout", "Wingdings", 12, core.H_Center, core.V_Top, vars["ibBottomColorInput"]);
    vars["drawInitialBalancesFunc9"] = Create_drawInitialBalances_i(vars["initialBalanceSizeInput"]);
    vars["drawInitialBalanceFunc27"] = Create_drawInitialBalance();
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        Linefill:Clear();
        Box:Clear();
        vars["initialBalances"]:Clear();
        vars["currentForecast"]:Clear();
        vars["simpleForecastArray"]:Clear();
        vars["dayOfWeekForecastArray"]:Clear();
        vars["autoIBStartTime"]:Clear();
        time[period] = source:date(period) * 86400000;
        vars["gatherDataFunc1"].Clear();
        vars["breakoutsFunc8"].Clear();
        vars["drawInitialBalancesFunc9"].Clear();
        vars["drawInitialBalanceFunc27"].Clear();
    else
        time[period] = source:date(period) * 86400000;
    end
    vars["GREEN"] = Graphics:AddTransparency(core.rgb(8, 153, 129), 0);
    vars["RED"] = Graphics:AddTransparency(core.rgb(242, 54, 69), 0);
    vars["SILVER_50"] = core.colors().Silver + math.floor(50 / 100 * 255) * 16777216;
    vars["DOTTED"] = "Dotted";
    vars["DASHED"] = "Dashed";
    vars["SOLID"] = "Solid";
    vars["FORECAST1"] = "IB Against Previous Open";
    vars["FORECAST2"] = "Filter By Current Day Of Week";
    vars["EM_SPACE"] = " ";
    vars["EN_SPACE"] = " ";
    vars["FOUR_PER_EM_SPACE"] = " ";
    vars["SIX_PER_EM_SPACE"] = " ";
    vars["initialBalanceSpacing"] = vars["SIX_PER_EM_SPACE"] .. vars["SIX_PER_EM_SPACE"];
    vars["extensionSpacing"] = vars["EM_SPACE"] .. vars["EN_SPACE"] .. vars["SIX_PER_EM_SPACE"];
    vars["forecastSpacing"] = vars["EM_SPACE"] .. vars["FOUR_PER_EM_SPACE"] .. vars["FOUR_PER_EM_SPACE"];
    vars["EXTENSION_GROUP"] = "EXTENSIONS";
    vars["FIBONACCI_GROUP"] = "FIBONACCI LEVELS";
    vars["FORECAST_GROUP"] = "FORECAST";
    vars["STYLE_GROUP"] = "STYLE";
    vars["forecastMethodTooltip"] = "Select the forecast method.\nIB Against Previous Open calculates the average difference between the IB high and low and the previous day's IB open price.\nFilter by Current Day of Week option calculates the average difference between the IB high and low and the IB open price for the same day of the week.";
    vars["forecastLengthTooltip"] = "The number of data points used to calculate the average.";
    vars["forecastMultTooltip"] = "This multiplier will be applied to the average. Bigger numbers will result in wider predicted ranges.";
    vars["initialBalanceInput"] = instance.parameters.param3;
    vars["breakoutsSessionInput"] = instance.parameters.param6;
    vars["topMultiplierInput"] = instance.parameters.param9 / 100;
    vars["bottomMultiplierInput"] = instance.parameters.param11 / 100;
    if not vars["initialBalances"]:IsInitialized() then
        vars["initialBalances"]:Set(period, Array:New(0, nil));
    end
    if not vars["currentForecast"]:IsInitialized() then
        vars["currentForecast"]:Set(period, CreateType_forecastData(period, nil, nil));
    end
    if not vars["simpleForecastArray"]:IsInitialized() then
        vars["simpleForecastArray"]:Set(period, CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil)));
    end
    if not vars["dayOfWeekForecastArray"]:IsInitialized() then
        vars["dayOfWeekForecastArray"]:Set(period, Array:New():Push(CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil))):Push(CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil))):Push(CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil))):Push(CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil))):Push(CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil))):Push(CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil))):Push(CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil))):Push(CreateType_forecastArray(period, Array:New(0, nil), Array:New(0, nil))));
    end
    vars["forecastFilter"] = (vars["forecastModeInput"] == vars["FORECAST2"]);
    if not vars["autoIBStartTime"]:IsInitialized() then
        vars["autoIBStartTime"]:Set(period, time:tick(period));
    end
    vars["autoIBStartTime"]:Set(period, Triary(Session:IsFirstBarRegular(source, period), time:tick(period), vars["autoIBStartTime"]:Get(period)));
    vars["autoIBEndTime"] = vars["autoIBStartTime"]:Get(period) + 3600000;
    vars["insideAutoInitialBalance"] = (time:tick(period) >= vars["autoIBStartTime"]:Get(period)) and (time:tick(period) < vars["autoIBEndTime"]);
    vars["insideAutoBreakoutsSession"] = (time:tick(period) >= vars["autoIBEndTime"]);
    vars["insideInitialBalance"] = Triary(vars["initialBalanceAutoInput"], vars["insideAutoInitialBalance"], not (PineScriptUtils:Time(period, Timeframe:Period(), vars["initialBalanceInput"], "America/New_York") == nil));
    SafeSetBool(vars["!insideInitialBalance_stream"], period, vars["insideInitialBalance"]);
    vars["!insideInitialBalance_stream_index1"] = 1;
    vars["initialBalanceStart"] = vars["insideInitialBalance"] and not (SafeGetBool(vars["!insideInitialBalance_stream"], period - vars["!insideInitialBalance_stream_index1"]));
    vars["insideBreakoutsSession"] = Triary(vars["breakoutsAutoInput"], vars["insideAutoBreakoutsSession"], not (PineScriptUtils:Time(period, Timeframe:Period(), vars["breakoutsSessionInput"], "America/New_York") == nil));
    vars["gatherDataFunc1"].GetValue(period, mode);
    bullishBreakout_ret_val, bearishBreakout_ret_val = vars["breakoutsFunc8"].GetValue(period, mode);
    vars["bullishBreakout"] = bullishBreakout_ret_val;
    vars["bearishBreakout"] = bearishBreakout_ret_val;
    PlotShape:SetValue(plot1, period, source, vars["bullishBreakout"], "\217", "", "belowbar", vars["ibTopColorInput"]);
    PlotShape:SetValue(plot2, period, source, vars["bearishBreakout"], "\218", "", "abovebar", vars["ibBottomColorInput"]);
    if period == source:size() - 2 then
        vars["drawInitialBalancesFunc9"].GetValue(period, mode);
    end
    if period == source:size() - 1 then
        vars["drawInitialBalanceFunc27"].GetValue(Array:Last(vars["initialBalances"]:Get(period)), period, mode);
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
    Linefill:Draw(stage, context);
    Box:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
Graphics = {};
Graphics.NextId = 1;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
    if color == nil then
        return -1;
    end
    for i, pen in ipairs(Graphics.Pens) do
        if pen.Width == width and pen.Color == color then
            context:createPen(pen.Id, context:convertPenStyle(style), width, color);
            return pen.Id;
        end
    end
    local newPen = {};
    newPen.Id = Graphics.NextId;
    newPen.Width = width;
    newPen.Color = color;

    context:createPen(newPen.Id, context:convertPenStyle(style), width, color);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Pens[#Graphics.Pens + 1] = newPen;
    return newPen.Id;
end
function Graphics:FindBrush(color, context)
    if color == nil then
        return -1;
    end
    for i, brush in ipairs(Graphics.Brushes) do
        if brush.Color == color then
            context:createSolidBrush(brush.Id, color)
            return brush.Id;
        end
    end
    local newBrush = {};
    newBrush.Id = Graphics.NextId;
    newBrush.Color = color;
    context:createSolidBrush(newBrush.Id, color)
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Brushes[#Graphics.Brushes + 1] = newBrush;
    return newBrush.Id;
end
function Graphics:FindFont(font, xSize, ySize, corner, context)
    for i, font in ipairs(self.Fonts) do
        if font.xSize == xSize and font.Name == font then
            return font.Id;
        end
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    newFont.xSize = xSize;
    newFont.Name = font;
    context:createFont(newFont.Id, font, 0, xSize, context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Graphics:SplitColorAndTransparency(clr)
    if clr == nil then
        return nil, nil;
    end
    local transparency = (math.floor(clr / 16777216) % 255);
    local color = clr - transparency * 16777216;
    return color, transparency;
end
function Graphics:GetColor(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return color;
end
function Graphics:GetTransparency(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return transparency;
end
function Graphics:GetTransparencyPercent(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    if transparency == nil then
        return nil;
    end
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil or transp == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
Variable = {};
function Variable:Create()
    local var = {};
    var._init = false;
    var._hist = {};
    var._last_period = nil;
    function var:Clear()
        self._init = false;
        self._value = nil;
        self._hist = {};
    end
    function var:Get(period, shift)
        if (shift ~= nil) then
            local target_period = period - shift;
            local found_value = nil;
            for k, v in pairs(self._hist) do
                if k > target_period then
                    return found_value;
                end
                found_value = v;
            end
            return found_value;
        end
        return self._value;
    end
    function var:Set(period, value)
        if (self._last_period ~= period and self._last_period ~= nil) then
            self._hist[self._last_period] = self._value;
        end
        self._value = value;
        self._last_period = period;
        self._init = true;
    end
    function var:IsInitialized()
        return self._init;
    end
    return var;
end
Array = {};
function Array:Enum(array)
    if array == nil then
        return {};
    end
    return array:ToEnum();
end
function Array:Clear(array)
    if array == nil then
        return;
    end
    array:Clear();
end
function Array:Copy(array)
    if array == nil then
        return;
    end
    return array:Copy();
end
function Array:Get(array, index)
    if array == nil then
        return;
    end
    return array:Get(index);
end
function Array:Join(array, separator)
    if array == nil then
        return;
    end
    return array:Join(separator);
end
function Array:Reverse(array)
    if array == nil then
        return;
    end
    return array:Reverse();
end
function Array:Remove(array, index)
    if array == nil then
        return;
    end
    return array:Remove(index);
end
function Array:Sum(array)
    if array == nil or array:Size() == 0 then
        return;
    end
    local sum = array:Get(0);
    for i = 1, array:Size() - 1 do
        local v = array:Get(i);
        if (sum == nil) then
            sum = v;
        elseif (v ~= nil or sum == nil) then
            sum = sum + v;
        end
    end
    return sum;
end
function Array:Avg(array)
    if array == nil or array:Size() == 0 then
        return;
    end
    return Array:Sum(array) / array:Size();
end
function Array:Max(array)
    if array == nil or array:Size() == 0 then
        return;
    end
    local maxVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if maxVal == nil or (val ~= nil and maxVal < val) then
            maxVal = val;
        end
    end
    return maxVal;
end
function Array:Min(array)
    if array == nil or array:Size() == 0 then
        return;
    end
    local minVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if minVal == nil or (val ~= nil and minVal > val) then
            minVal = val;
        end
    end
    return minVal;
end
function Array:Pop(array)
    if array == nil or array:Size() == 0 then
        return nil;
    end
    return array:Pop();
end
function Array:Set(array, index, value)
    if array == nil then
        return;
    end
    array:Set(index, value);
end
function Array:Fill(array, value, from, to)
    if array == nil then
        return;
    end
    array:Fill(value, from, to);
end
function Array:IndexOf(array, value)
    if array == nil then
        return -1;
    end
    return array:IndexOf(value);
end
function Array:Includes(array, value)
    if array == nil then
        return nil;
    end
    return array:Includes(value);
end
function Array:Median(array)
    if array == nil then
        return nil;
    end
    return array:Median();
end
function Array:First(array, value)
    if array == nil then
        return nil;
    end
    return array:First(value);
end
function Array:Last(array, value)
    if array == nil then
        return nil;
    end
    return array:Last(value);
end
function Array:New(size, initialValue)
    local newArray = {};
    newArray.arr = {};
    if size ~= nil then
        newArray.size = size;
        for i = 1, size, 1 do
            newArray.arr[i] = initialValue;
        end
    else
        newArray.size = 0;
    end
    function newArray:ToEnum() return self.arr end
    function newArray:Push(item) self.size = self.size + 1; self.arr[#self.arr + 1] = item; return self; end
    function newArray:Get(index)
        if index == nil then 
            return nil; 
        end 
        if index < 0 then
            return self.arr[self:Size() + index]; 
        end
        return self.arr[index + 1]; 
    end
    function newArray:Set(index, value) self.arr[index + 1] = value; end
    function newArray:Max() return Array:Max(self); end
    function newArray:Min() return Array:Min(self); end
    function newArray:Size() return self.size; end
    function newArray:Clear()
        self.arr = {};
        self.size = 0;
    end
    function newArray:Pop()
        local lastVal = self.arr[self.size];
        table.remove(self.arr, self.size);
        self.size = self.size - 1;
        return lastVal;
    end
    function newArray:Fill(value, from, to)
        if to == nil then
            to = self.size - 1;
        end
        for i = from, to, 1 do
            self.arr[i + 1] = value;
        end
    end
    function newArray:IndexOf(value)
        for i, v in ipairs(self.arr) do
            if v == value then
                return i;
            end
        end
        return -1;
    end
    function newArray:Includes(value)
        for i, v in ipairs(self.arr) do
            if v == value then
                return true;
            end
        end
        return false;
    end
    function newArray:Sum()
        local sum = 0;
        for i, v in ipairs(self.arr) do
            sum = sum + v;
        end
        return sum;
    end
    function newArray:Median()
        local items = {};
        for i, v in ipairs(self.arr) do
            items[i] = v;
        end
        table.sort(items);
        local center = self.size / 2;
        if self.size % 2 == 1 then
            return items[center];
        else
            return (items[center] + items[center + 1]) / 2;
        end
    end
    function newArray:First()
        if self.size == 0 then
            return;
        end
        return self.arr[1];
    end
    function newArray:Last()
        if self.size == 0 then
            return;
        end
        return self.arr[self.size];
    end
    function newArray:Copy()
        local arrayCopy = Array:New(self.size, nil);
        for i = 1, self.size, 1 do
            arrayCopy.arr[i] = self.arr[i];
        end
        return arrayCopy;
    end
    function newArray:Reverse()
        local half = math.floor(self.size / 2);
        for i = 1, half, 1 do
            local swapped = self.arr[self.size - i + 1];
            self.arr[self.size - i + 1] = self.arr[i];
            self.arr[i] = swapped;
        end
    end
    function newArray:Unshift(value)
        local nextValue = value;
        for i = 1, self.size, 1 do
            local current = self.arr[i];
            self.arr[i] = nextValue;
            nextValue = current;
        end
        self.arr[self.size + 1] = nextValue;
        self.size = self.size + 1;
    end
    function newArray:Join(separator)
        if self.size == 0 then
            return "";
        end
        local str = tostring(self.arr[1]);
        for i = 2, self.size, 1 do
            if self.arr[i] ~= nil then
                str = str .. separator .. tostring(self.arr[i]);
            end
        end
        return str;
    end
    function newArray:Shift()
        local value = self.arr[1];
        table.remove(self.arr, 1);
        self.size = self.size - 1;
        return value;
    end
    function newArray:Remove(index)
        local value = self.arr[index];
        table.remove(self.arr, index);
        self.size = self.size - 1;
        return value;
    end
    function newArray:Slice(from, to)
        local slice = {};
        slice.Parent = self;
        slice.From = from;
        slice.To = to;
        function slice:Get(index)
            return self.Parent:Get(index + self.From);
        end
        function slice:Size()
            return self.To - self.From;
        end
        function slice:Max()
            return Array:Max(self);
        end
        function slice:Min()
            return Array:Min(self);
        end
        function slice:ToEnum()
            local arrCopy = {};
            for i = 0, self:Size() - 1, 1 do
                arrCopy[#arrCopy + 1] = self:Get(i);
            end
            return arrCopy;
        end
        return slice;
    end
    return newArray;
end
function Array:NewLine(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewInt(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewFloat(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewLabel(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewString(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewBox(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewBool(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewColor(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:Size(arr)
    if arr == nil then
        return nil;
    end
    return arr:Size();
end
function Array:Push(arr, val)
    if arr == nil then
        return nil;
    end
    return arr:Push(val);
end
function SafeMinus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left - right;
end
function SafeMultiply(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left * right;
end
function SafePlus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left + right;
end
function SafeConcat(left, right)
    if left == nil then
        return right;
    end
    if right == nil then
        return left;
    end
    return left .. right;
end
function SafeDivide(left, right)
    if left == nil or right == nil or right == 0 then
        return nil;
    end
    return left / right;
end
function SafeGreater(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left > right;
end
function SafeGE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left >= right;
end
function SafeLess(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left < right;
end
function SafeLE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left <= right;
end
function SafeMax(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.max(left, right);
end
function SafeMin(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.min(left, right);
end
function SafeAbs(value)
    if value == nil then
        return nil;
    end
    return math.abs(value);
end
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function SafeSetBool(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or period == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil or period == nil then
        return nil;
    end
    if not stream:hasData(period) then
        return nil;
    end
    return stream[period];
end
function Float(number)
    return number and number or nil;
end
function Int(number)
    return number and number or nil;
end
function Color(color)
    return color and color or nil;
end
function ToLine(line)
    return line;
end
function ToBox(box)
    return box;
end
function Round(num, idp)
    if num == nil then
        return nil;
    end
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
function Nz(value, defaultValue)
    if defaultValue == nil then
        defaultValue = 0;
    end
    return value and value or defaultValue;
end
function Triary(condition, trueValue, falseValue)
    if condition == nil or condition == false then
        return falseValue;
    end
    return trueValue;
end
function SafeCrossesUnder(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesUnder(val1, val2, period);
end
function SafeCrossesOver(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesOver(val1, val2, period);
end
function SafeCrosses(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crosses(val1, val2, period);
end
function SafeCos(val)
    if val == nil then
        return nil;
    end
    return math.cos(val);
end
function SafeSin(val)
    if val == nil then
        return nil;
    end
    return math.sin(val);
end
function SafeMathExMax(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.max(source, core.rangeTo(period, length));
end
function SafeMathExMin(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.min(source, core.rangeTo(period, length));
end
function SafeMathExStdev(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.stdev(source, core.rangeTo(period, length));
end
function SafeSqrt(value)
    if value == nil then
        return nil;
    end
    return math.sqrt(value);
end
function SafeExp(value)
    if value == nil then
        return nil;
    end
    return math.exp(value);
end
Session = {};

function Session:IsFirstBarRegular(source, period)
    if period <= 0 then
        return false;
    end
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    local currentDate = core.getcandle("D1", source:date(period), tradingDayOffset, tradingWeekOffset);
    local prevDate = core.getcandle("D1", source:date(period - 1), tradingDayOffset, tradingWeekOffset);
    return currentDate ~= prevDate;
end
PineScriptUtils = {};
PineScriptUtils.Sources = {};
function PineScriptUtils:CreateSource(source, sourceType)
    if sourceType ~= "ohlc4" then
        return source[sourceType];
    end
    local newSource = {};
    newSource.Stream = instance:addInternalStream(0, 0);
    function newSource:Update(period, mode)
        self.Stream[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
    end
    self.Sources[#self.Sources + 1] = newSource;
    return newSource.Stream;
end
function PineScriptUtils:UpdateSources(period, mode)
    for i, src in ipairs(self.Sources) do
        src:Update(period, mode);
    end
end
function PineScriptUtils:TimeframeFromLength(length)
    if length == "t" then
        return "t1"
    elseif length == "D" then
        return "D1";
    elseif length == "W" then
        return "W1";
    elseif length == "M" then
        return "M1";
    end
    local length_number = tonumber(length);
    if length_number < 3600 then
        return "m" .. tostring(length_number / 60);
    end
    return "H" .. tostring(length_number / 3600)
end
function PineScriptUtils:ParseSession(session)
    local session_info = {};
    local _, _, from_hour, from_minute, to_hour, to_minute = string.find(session, "(%d%d)(%d%d)-(%d%d)(%d%d)");
    session_info.from_hour = from_hour and tonumber(from_hour) or 0;
    session_info.from_minute = from_minute and tonumber(from_minute) or 0;
    session_info.from = (session_info.from_hour * 60.0 + session_info.from_minute) * 60.0;
    session_info.to_hour = to_hour and tonumber(to_hour) or 23;
    session_info.to_minute = to_minute and tonumber(to_minute) or 59;
    session_info.to = (session_info.to_hour * 60.0 + session_info.to_minute) * 60.0;
    function session_info:IsInRange(time)
        time = math.floor(time * 86400 + 0.5);
        if self.from < self.to then
            return time >= self.from and time <= self.to;
        end
        if self.from > self.to then
            return time > self.from or time < self.to;
        end
    
        return time == self.from;
    end
    return session_info;
end
function PineScriptUtils:Time(period, timeframe_length, session, timezone)
    local timeframe = PineScriptUtils:TimeframeFromLength(timeframe_length);
    if PineScriptUtils.tradingWeekOffset == nil then
        PineScriptUtils.tradingWeekOffset = core.host:execute("getTradingWeekOffset");
        PineScriptUtils.tradingDayOffset = core.host:execute("getTradingDayOffset");
    end
    local s, e = core.getcandle(timeframe, instance.source:date(period), PineScriptUtils.tradingDayOffset, PineScriptUtils.tradingWeekOffset);
    local session_info = PineScriptUtils:ParseSession(session);
    if not session_info:IsInRange(s % 1) then
        return nil;
    end
    
    return s * 86400000;
end
function PineScriptUtils:WeekOfYear(time, timezone)
    local time_ole = time / 86400000;
    local date_table = core.dateToTable(time_ole)
    date_table.month = 1;
    date_table.day = 1;
    date_table.hour = 0;
    date_table.min = 0;
    date_table.sec = 0;
    local first_day_ole = core.tableToDate(date_table);
    date_table = core.dateToTable(first_day_ole);
    first_day_ole = first_day_ole - date_table.wday + 1;
    return math.floor(time_ole - first_day_ole / 7);
end

function Timestamp(year, month, day, hour, minute, second, tz)
    local date = {};
    date.month = month;
    date.day = day;
    date.year = year;
    date.hour = hour;
    date.min = minute;
    date.sec = second;
    return core.tableToDate(date) * 86400000;
end

function BarSizeInMS(barSize)
    local s, e = core.getcandle(barSize, core.now(), 0, 0)
    return (e - s) * 86400000;
end

function NumberToBool(n)
    return n ~= nil and n ~= 0;
end

function GetTrueRange(source, period)
    if period == 0 then
        return nil;
    end
    local num1 = math.abs(source.high[period] - source.low[period]);
    local num2 = math.abs(source.high[period] - source.close[period - 1]);
    local num3 = math.abs(source.close[period - 1] - source.low[period]);
    return math.max(num1, num2, num3);
end
Timeframe = {};
function Timeframe:Period()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "t";
    elseif string.sub(bar_size, 1, 1) == "m" then
        local minutes = tonumber(string.sub(bar_size, 2));
        return tostring(minutes * 60);
    elseif string.sub(bar_size, 1, 1) == "H" then
        local minutes = 60 * tonumber(string.sub(bar_size, 2));
        return tostring(minutes * 60);
    elseif string.sub(bar_size, 1, 1) == "D" then
        return "D";
    elseif string.sub(bar_size, 1, 1) == "W" then
        return "D";
    elseif string.sub(bar_size, 1, 1) == "M" then
        return "M";
    end
    return "0";
end
function Timeframe:IsIntraday()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return true;
    elseif string.sub(bar_size, 1, 1) == "m" then
        return true;
    elseif string.sub(bar_size, 1, 1) == "H" then
        return true;
    end
    return false;
end
function Timeframe:Interval()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "0";
    elseif string.sub(bar_size, 1, 1) == "m" then
        return tonumber(string.sub(bar_size, 2));
    elseif string.sub(bar_size, 1, 1) == "H" then
        return tonumber(string.sub(bar_size, 2));
    elseif string.sub(bar_size, 1, 1) == "D" then
        return "1";
    elseif string.sub(bar_size, 1, 1) == "W" then
        return "1";
    elseif string.sub(bar_size, 1, 1) == "M" then
        return "1";
    end
    return "0";
end
function Timeframe:InSeconds(timeframe, source)
    if timeframe == "M" then
        return 86400 * 30;
    elseif timeframe == "D" then
        return 86400;
    elseif timeframe == "t" then
        return 1;
    else
        local minutes = tonumber(timeframe);
        if minutes == nil then
            return nil;
        end
        return minutes * 60;
    end
    return nil;
end
function Timeframe:GetBarSize(timeframe)
    if timeframe == "M" then
        return "M1";
    elseif timeframe == "D" then
        return "D1";
    elseif timeframe == "t" then
        return "t1";
    else
        local minutes = tonumber(timeframe);
        if minutes == 1 then
            return "m1";
        elseif minutes == 5 then
            return "m5";
        elseif minutes == 15 then
            return "m15";
        elseif minutes == 30 then
            return "m30";
        elseif minutes == 60 then
            return "h1";
        elseif minutes == 120 then
            return "h2";
        elseif minutes == 180 then
            return "h3";
        elseif minutes == 240 then
            return "h4";
        elseif minutes == 360 then
            return "h6";
        elseif minutes == 480 then
            return "h8";
        end
    end
    return nil;
end
function Timeframe:Change(timeframe, source, period)
    if period <= 0 then
        return false;
    end
    local barSize = Timeframe:GetBarSize(timeframe);
    if barSize == nil then
        return false;
    end
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    local currentDate = core.getcandle(barSize, source:date(period), tradingDayOffset, tradingWeekOffset);
    local prevDate = core.getcandle(barSize, source:date(period - 1), tradingDayOffset, tradingWeekOffset);
    return currentDate ~= prevDate;
end
Time = {};
function Time:DayOfWeek(source, period)
    local d = core.dateToTable(source:date(period));
    return d.wday - 1;
end
PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location, color)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if not value or transp == 100 or clr == nil then
        plot:setNoData(period);
        return nil;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label, clr);
        return source.high[period];
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label, clr);
        return source.low[period];
    end
    plot:set(period, value, text, label, clr);
    return value;
end
Line = {};
Line.AllLines = {};
function Line:GetAll()
    local array = {};
    array.arr = Line.AllLines;
    return array;
end
function Line:Clear()
    Line.AllLines = {};
end
function Line:Prepare(max_lines_count)
    Line.max_lines_count = max_lines_count;
end
function Line:GetPrice(line, x)
    if line == nil then
        return nil;
    end
    return line:GetPrice(x);
end
function Line:SetXY1(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY1(x, y);
end
function Line:SetXY2(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY2(x, y);
end
function Line:SetX1(line, x)
    if line == nil then
        return;
    end
    line:SetX1(x);
end
function Line:SetX2(line, x)
    if line == nil then
        return;
    end
    line:SetX2(x);
end
function Line:SetY1(line, y)
    if line == nil then
        return;
    end
    line:SetY1(y);
end
function Line:SetY2(line, y)
    if line == nil then
        return;
    end
    line:SetY2(y);
end
function Line:GetX1(line)
    if line == nil then
        return;
    end
    return line:GetX1();
end
function Line:GetX2(line)
    if line == nil then
        return;
    end
    return line:GetX2();
end
function Line:GetY1(line)
    if line == nil then
        return;
    end
    return line:GetY1();
end
function Line:GetY2(line)
    if line == nil then
        return;
    end
    return line:GetY2();
end
function Line:SetColor(line, clr)
    if line == nil then
        return;
    end
    line:SetColor(clr);
end
function Line:SetWidth(line, width)
    if line == nil then
        return;
    end
    line:SetWidth(width);
end
function Line:SetStyle(line, style)
    if line == nil then
        return;
    end
    line:SetStyle(style);
end
function Line:SetExtend(line, extend)
    if line == nil then
        return;
    end
    line:SetExtend(extend);
end
function Line:SetXLoc(line, x1, x2, xloc)
    if line == nil then
        return;
    end
    line:SetXLoc(x1, x2, xloc);
end
function Line:SetXLocInit(line, xloc)
    if line == nil then
        return;
    end
    line:SetXLocInit(xloc);
end
function Line:Copy(line)
    if line == nil then
        return nil;
    end
    local newLine = Line:New(line.X1, line.Y1, line.X2, line.Y2);
    newLine.XLoc = line.XLoc;
    newLine.Color = line.Color;
    newLine.Width = line.Width;
    newLine.Extend = line.Extend;
    newLine.Style = line.Style;
    return newLine;
end
function Line:NewCP(p1, p2)
    local x1 = p1.x or p1.t;
    local x2 = p2.x or p2.t;
    return Line:New(x1, p1.y, x2, p2.y);
end
function ToIndicoreTime(pineScriptTime)
    return pineScriptTime / 86400000.;
end
function Line:New(x1, y1, x2, y2)
    local newLine = {};
    newLine.X1 = x1;
    newLine.Y1 = y1;
    newLine.X2 = x2;
    newLine.Y2 = y2;
    function newLine:SetXY1(x, y)
        self.X1 = x;
        self.Y1 = y;
        return self;
    end
    function newLine:SetXY2(x, y)
        self.X2 = x;
        self.Y2 = y;
        return self;
    end
    function newLine:SetX1(x)
        self.X1 = x;
        return self;
    end
    function newLine:SetX2(x)
        self.X2 = x;
        return self;
    end
    newLine.XLoc = "bar_index";
    function newLine:SetXLoc(x1, x2, xloc)
        newLine.X1 = x1;
        newLine.X2 = x2;
        newLine.XLoc = xloc;
        return self;
    end
    function newLine:SetXLocInit(xloc)
        newLine.XLoc = xloc;
        return self;
    end
    function newLine:SetY1(y)
        self.Y1 = y;
        return self;
    end
    function newLine:SetY2(y)
        self.Y2 = y;
        return self;
    end
    function newLine:GetX1()
        return self.X1;
    end
    function newLine:GetX2()
        return self.X2;
    end
    function newLine:GetY1()
        return self.Y1;
    end
    function newLine:GetY2()
        return self.Y2;
    end
    newLine.Color = core.colors().Blue;
    function newLine:SetColor(clr)
        self.ColorTransparency = (math.floor(clr / 16777216) % 255);
        self.Color = clr - self.ColorTransparency * 16777216;
        self.PenId = nil;
        return self;
    end
    newLine.Width = 1;
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenId = nil;
        return self;
    end
    newLine.Extend = "none";
    function newLine:SetExtend(extend)
        self.Extend = extend;
        return self;
    end
    newLine.Style = "solid";
    function newLine:SetStyle(style)
        self.Style = style;
        self.PenId = nil;
        return self;
    end
    function newLine:GetPrice(x)
        local a, c = math2d.lineEquation(self.X1, self.Y1, self.X2, self.Y2);
        return a * x + c;
    end
    function newLine:getStyleForContext()
        if self.Style == "solid" or self.Style == "arrow_left" or self.Style == "arrow_both" or self.Style == "arrow_right" then
            return core.LINE_SOLID;
        elseif self.Style == "dotted" then
            return core.LINE_DOT;
        elseif self.Style == "dashed" then
            return core.LINE_DASH;
        end
        return core.LINE_SOLID;
    end
    function newLine:converXToPoints(context, x)
        if self.XLoc == "bar_time" then
            return context:positionOfDate(x / 86400000);
        end
        local _, x1 = context:positionOfBar(x);
        return x1;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil or self.X1 == nil or self.X2 == nil or self.Width == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        local x1;
        local x2;
        if (self.XLoc == "bar_time") then
            _, x1 = context:positionOfDate(ToIndicoreTime(self.X1))
            _, x2 = context:positionOfDate(ToIndicoreTime(self.X2))
        else
            x1 = self:converXToPoints(context, self.X1);
            x2 = self:converXToPoints(context, self.X2);
        end
        local _, y1 = context:pointOfPrice(self.Y1);
        local _, y2 = context:pointOfPrice(self.Y2);
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            if x1 == x2 then
                if y1 >= y2 then
                    context:drawLine(self.PenId, x1, y1, x1, context:top(), self.ColorTransparency);
                else
                    context:drawLine(self.PenId, x1, y1, x1, context:bottom(), self.ColorTransparency);
                end
            else
                local a, c = math2d.lineEquation(x1, y1, x2, y2);
                if a ~= nil and c ~= nil then
                    local y3 = a * context:right() + c;
                    context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
                end
            end
        end
        if self.Extend == "left" or self.Extend == "both" then
            if x1 == x2 then
                if y1 >= y2 then
                    context:drawLine(self.PenId, x1, y2, x1, context:bottom(), self.ColorTransparency);
                else
                    context:drawLine(self.PenId, x1, y2, x1, context:top(), self.ColorTransparency);
                end
            else
                local a, c = math2d.lineEquation(x1, y1, x2, y2);
                if a ~= nil and c ~= nil then
                    local y3 = a * context:left() + c;
                    context:drawLine(self.PenId, x1, y1, context:left(), y3, self.ColorTransparency);
                end
            end
        end
    end
    Line:AddNewLine(newLine);
    return newLine;
end
function Line:AddNewLine(newLine)
    self.AllLines[#self.AllLines + 1] = newLine;
    if #self.AllLines > self.max_lines_count then
        table.remove(self.AllLines, 1);
    end
end
function Line:Delete(line)
    for i = 1, #self.AllLines do
        if self.AllLines[i] == line then
            table.remove(self.AllLines, i);
            return;
        end
    end
end
function Line:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLines) do
        value:Draw(stage, context);
    end
end
ChartPoint = {};
function ChartPoint:New(time, index, price)
    local point = {};
    point.t = time;
    point.x = index;
    point.y = price;
    return point;
end
function ChartPoint:FromIndex(index, price)
    local point = {};
    point.x = index;
    point.y = price;
    return point;
end
function chartpoint_Getprice(chartPoint)
    if chartPoint == nil then
        return nil;
    end
    return chartPoint.y;
end
function chartpoint_Getindex(chartPoint)
    if chartPoint == nil then
        return nil;
    end
    return chartPoint.x;
end
function chartpoint_Gettime(chartPoint)
    if chartPoint == nil then
        return nil;
    end
    return chartPoint.t;
end
Label = {};
Label.AllLabelsInOrder = {};
Label.AllSeries = {};
function Label:Clear()
    Label.AllSeries = {};
    Label.AllLabelsInOrder = {};
end
function Label:Prepare(max_labels_count)
    Label.max_labels_count = max_labels_count;
end
function Label:GetSerial(value, source, xloc)
    if value == nil then
        return nil;
    end
    if xloc == "bar_time" then
        return value / 86400000.;
    end
    if value < 0 or value >= source:size() then
        return nil;
    end
    return source:date(value);
end
function Label:Get(label, index)
    if label == nil then
        return;
    end
    return label:Get(index);
end
function Label:SetText(label, text)
    if label == nil then
        return;
    end
    label:SetText(text);
end
function Label:SetTooltip(label, text)
    if label == nil then
        return;
    end
    label:SetTooltip(text);
end
function Label:SetSize(label, size)
    if label == nil then
        return;
    end
    label:SetSize(size);
end
function Label:SetX(label, x)
    if label == nil then
        return;
    end
    label:SetX(x);
end
function Label:SetXLoc(label, x, xloc)
    if label == nil then
        return;
    end
    label:SetX(x);
    label:SetXLoc(xloc);
end
function Label:SetXY(label, x, y)
    if label == nil then
        return;
    end
    label:SetX(x);
    label:SetY(y);
end
function Label:SetY(label, y)
    if label == nil then
        return;
    end
    label:SetY(y);
end
function Label:GetX(label)
    if label == nil then
        return;
    end
    return label:GetX();
end
function Label:GetY(label)
    if label == nil then
        return;
    end
    return label:GetY();
end
function Label:SetStyle(label, style)
    if label == nil then
        return;
    end
    return label:SetStyle(style);
end
function Label:New(id, seriesId, period, price)
    local newLabel = {};
    newLabel.SeriesId = seriesId;
    newLabel.X = period;
    function newLabel:SetX(x)
        self.X = x;
        return self;
    end
    function newLabel:SetXLoc(val)
        self.xloc = val;
        return self;
    end
    function newLabel:GetX()
        return self.X;
    end
    newLabel.Y = price;
    function newLabel:SetY(y)
        self.Y = y;
        return self;
    end
    function newLabel:GetY()
        return self.Y;
    end
    newLabel.Text = "";
    function newLabel:SetText(text)
        self.Text = text;
        return self;
    end
    newLabel.BGColor = nil;
    function newLabel:SetColor(clr)
        if clr ~= nil then
            self.BgColorTransparency = (math.floor(clr / 16777216) % 256);
            self.BGColor = clr - self.BgColorTransparency * 16777216;
        else
            self.BgColorTransparency = nil;
            self.BGColor = nil;
        end
        self.BGPenId = nil;
        self.BGBrushId = nil;
        return self;
    end
    newLabel.TextColor = core.colors().Black;
    function newLabel:SetTextColor(clr)
        self.TextColor = clr;
        return self;
    end
    function newLabel:SetTooltip(tooltip)
        return self;
    end
    newLabel.Style = "down";
    function newLabel:SetStyle(style)
        self.Style = style;
        return self;
    end
    function newLabel:getCoordinates(context, W, H)
        local visible, y = context:pointOfPrice(self.Y);
        local x1, x;
        if self.xloc == "bar_index" then
            x1, x = context:positionOfBar(self.X)
        else
            x1, x = context:positionOfDate(self.X / 86400000.);
        end
        if self.Style == "left" then
            return x1, y - H / 2, x1 + W, y + H / 2;
        end
        if self.Style == "down" then
            return x1 - W / 2, y - H, x1 + W / 2, y;
        end
        if self.Style == "up" then
            return x1 - W / 2, y, x1 + W / 2, y + H;
        end
        return x1 - W / 2, y - H / 2, x1 + W / 2, y + H / 2;
    end
    newLabel.Size = "auto";
    function newLabel:SetSize(size)
        self.Size = size;
        return self;
    end
    function newLabel:GetDefaultSize()
        if self.Size == "tiny" then
            return 7, 7;
        end
        if self.Size == "auto" or self.Size == "small" then
            return 10, 10;
        end
        if self.Size == "normal" then
            return 12, 12;
        end
        if self.Size == "large" then
            return 14, 14;
        end
        return 16, 16;
    end
    function newLabel:Draw(stage, context)
        if self.X == nil or self.Y == nil then
            return;
        end
        if self.FontId == nil then
            local defFontSize = self:GetDefaultSize();
            self.FontId = Graphics:FindFont("Arial", 0, defFontSize, context.LEFT, context);
        end
        local W, H;
        if self.Text == nil or self.Text == "" then
            W, H = self:GetDefaultSize()
        else
            W, H = context:measureText(self.FontId, self.Text, context.LEFT);
        end
        local x_from, y_from, x_to, y_to = self:getCoordinates(context, W, H);
        if self.BGColor ~= nil then
            if self.BGPenId == nil then
                self.BGPenId = Graphics:FindPen(1, self.BGColor, core.LINE_SOLID, context);
            end
            if self.BGBrushId == nil then
                self.BGBrushId = Graphics:FindBrush(self.BGColor, context);
            end
            if self.Style == "down" then
                local ySize = math.abs(y_from - y_to);
                y_from = y_from - ySize / 2;
                y_to = y_to - ySize / 2;
                local points = context:createPoints();
                points:add(x_from, y_to);
                points:add(x_to, y_to);
                points:add((x_to + x_from) / 2, y_to + ySize / 2);
                context:drawPolygon(self.BGPenId, self.BGBrushId, points, self.BgColorTransparency);
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            elseif self.Style == "up" then
                local ySize = math.abs(y_from - y_to);
                y_from = y_from + ySize / 2;
                y_to = y_to + ySize / 2;
                local points = context:createPoints();
                points:add(x_from, y_from - 1);
                points:add(x_to, y_from - 1);
                points:add((x_to + x_from) / 2, y_from - ySize / 2);
                context:drawPolygon(self.BGPenId, self.BGBrushId, points, self.BgColorTransparency);
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            elseif self.Style == "none" then
            else
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            end
        end
        context:drawText(self.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
    end
    function newLabel:Get(index)
        return Label.AllSeries[self.SeriesId][index + 1];
    end
    self.AllLabelsInOrder[#self.AllLabelsInOrder + 1] = newLabel
    if #self.AllLabelsInOrder > self.max_labels_count then
        Label:Delete(self.AllLabelsInOrder[1]);
    end
    if self.AllSeries[seriesId] == nil then
        self.AllSeries[seriesId] = {};
    end
    table.insert(self.AllSeries[seriesId], 1, newLabel);
    return newLabel;
end
function Label:Delete(label)
    if label == nil then
        return;
    end
    self:removeFromAllLabelsByOrder(label);
    self:removeFromSeries(label);
end
function Label:removeFromSeries(label)
    for i = 1, #self.AllSeries[label.SeriesId] do
        if self.AllSeries[label.SeriesId][i] == label then
            table.remove(self.AllSeries[label.SeriesId], i);
            return;
        end
    end
end
function Label:removeFromAllLabelsByOrder(label)
    for i = 1, #self.AllLabelsInOrder do
        if self.AllLabelsInOrder[i] == label then
            table.remove(self.AllLabelsInOrder, i);
            return;
        end
    end
end
function Label:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i = 1, #self.AllLabelsInOrder do
        self.AllLabelsInOrder[i]:Draw(stage, context);
    end
end
Str = {};
function Str:NewVar(value)
    local var = {};
    var.items = {};
    var.items[0] = value;
    function var:Get(period)
        if period < 0 then
            return nil;
        end
        return self.items[period];
    end
    function var:Set(period, value)
        self.items[period] = value;
    end
    return var;
end
function Str:Clear()
end
function Str:doFormat(pattern, values)
    local tokens = core.parseCsv(pattern, ",");
    local value = values[tonumber(tokens[0])];
    if value == nil then
        return "";
    end
    if tokens[1] == "number" then
        if tokens[2] == "percent" then
            return tostring(math.floor(value + 0.5)) .. "%";
        end
    end
    return tostring(value);
end
function Str:Format(pattern, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
    local values = {};
    values[0] = value0;
    values[1] = value1;
    values[2] = value2;
    values[3] = value3;
    values[4] = value4;
    values[5] = value5;
    values[6] = value6;
    values[7] = value7;
    values[8] = value8;
    values[9] = value9;

    local tokens = core.parseCsv(pattern, "{");
    local result = "";
    for i, token in ipairs(tokens) do
        local subtokens, c = core.parseCsv(token, "}");
        if c == 1 then
            result = result .. token;
        else
            result = result .. Str:doFormat(subtokens[0], values) .. subtokens[1];
        end
    end
    return result;
end
function Str:ToString(value, pattern)
    if value == nil then
        return "";
    end
    if pattern == nil then
        return tostring(value);
    end
    if pattern == "percent" then
        return win32.formatNumber(value, false, 2);
    end
    local luaPattern = "";
    local waitNumber = false;
    local digits = 0;
    for i = 1, #pattern do
        local char = string.sub(pattern, i, i);
        if not waitNumber then
            if char == "#" then
                waitNumber = true;
                luaPattern = luaPattern .. "%";
            else
                luaPattern = luaPattern .. char;
            end
        else
            if char == "." then
                luaPattern = luaPattern .. ".";
            elseif char == "#" then
                digits = digits + 1;
            else
                luaPattern = luaPattern .. digits .. "f";
                waitNumber = false;
                digits = 0;
            end
        end
    end
    if waitNumber then
        luaPattern = luaPattern .. digits .. "f";
        waitNumber = false;
        digits = 0;
    end
    
    return string.format(luaPattern, value);
end
function Str:Length(str)
    if str == nil then
        return 0;
    end
    return string.len(str);
end
function Str:ReplaceAll(str, from, to)
    if str == nil then
        return nil;
    end
    return string.gsub(str, from, to);
end
function Str:Upper(str)
    if str == nil then
        return nil;
    end
    return string.upper(str);
end
function Str:StartsWith(str, item)
    if str == nil then
        return nil;
    end
    return string.find(str, item) == 1;
end
function Str:Split(str, separator)
    if str == nil then
        return nil;
    end
    local items, c = core.parseCsv(str, separator);
    local arr = Array:NewString(0);
    for i = 0, c - 1 do
        arr:Push(items[i]);
    end
    return arr;
end
function SafeSetString(str, period, value)
    if str == nil then
        return;
    end
    str:Set(period, value);
end
function SafeGetString(str, period)
    if str == nil then
        return;
    end
    return str:Get(period);
end
Linefill = {};
Linefill.AllLinefills = {};
function Linefill:Clear()
    Linefill.AllLinefills = {};
end
function Linefill:SetColor(Linefill, clr)
    if Linefill == nil then
        return;
    end
    Linefill:SetColor(clr);
end
function Linefill:New(line1, line2)
    for i, fill in ipairs(Linefill.AllLinefills) do
        if fill.Line1 == line1 and fill.Line2 == line2 then
            return fill;
        end
    end
    local newLinefill = {};
    newLinefill.Line1 = line1;
    newLinefill.Line2 = line2;
    newLinefill.Color = core.colors().Blue;
    function newLinefill:SetColor(clr, transparency)
        self.Color = clr;
        if clr ~= nil then
            self.ColorTransparency = transparency and transparency or (math.floor(clr / 16777216) % 255);
        else
            self.ColorTransparency = nil;
        end
        self.PenId = nil;
        self.BrushId = nil;
    end
    function newLinefill:Draw(stage, context)
        if self.Line1 == nil or self.Line2 == nil then
            return;
        end
        local l1_y1 = self.Line1:GetY1();
        local l1_y2 = self.Line1:GetY2();
        local l1_x1 = self.Line1:GetX1();
        local l1_x2 = self.Line1:GetX2();
        if (l1_y1 == nil or l1_y2 == nil or l1_x1 == nil or l1_x2 == nil) then
            return;
        end
        local l2_y1 = self.Line2:GetY1();
        local l2_y2 = self.Line2:GetY2();
        local l2_x1 = self.Line2:GetX1();
        local l2_x2 = self.Line2:GetX2();
        if (l2_y1 == nil or l2_y2 == nil or l2_x1 == nil or l2_x2 == nil) then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(1, self.Color, core.LINE_SOLID, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.Color, context);
        end
        
        local points = context:createPoints();
        _, y1 = context:pointOfPrice(l1_y1);
        _, x1 = context:positionOfBar(l1_x1);
        _, y2 = context:pointOfPrice(l1_y2);
        _, x2 = context:positionOfBar(l1_x2);
        points:add(x1, y1);
        points:add(x2, y2);
        _, y1 = context:pointOfPrice(l2_y1);
        _, x1 = context:positionOfBar(l2_x1);
        _, y2 = context:pointOfPrice(l2_y2);
        _, x2 = context:positionOfBar(l2_x2);
        points:add(x2, y2);
        points:add(x1, y1);
        context:drawPolygon(self.PenId, self.BrushId, points, self.ColorTransparency);
    end
    self.AllLinefills[#self.AllLinefills + 1] = newLinefill;
    return newLinefill;
end
function Linefill:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLinefills) do
        value:Draw(stage, context);
    end
end
Box = {};
Box.AllBoxs = {};
Box.AllSeries = {};
function Box:Clear()
    Box.AllBoxs = {};
    Box.AllSeries = {};
end
function ToIndicoreTime(pineScriptTime)
    return pineScriptTime / 86400000.;
end
function Box:GetSerial(value, source, xloc)
    if value == nil then
        return nil;
    end
    if xloc == "bar_time" then
        return ToIndicoreTime(value);
    end
    if value < 0 or value >= source:size() then
        return nil;
    end
    return source:date(value);
end
function Box:SetLeftTop(box, left, top)
    if box == nil then
        return;
    end
    box:SetLeft(left);
    box:SetTop(top);
end
function Box:SetRightBottom(box, right, bottom)
    if box == nil then
        return;
    end
    box:SetRight(right);
    box:SetBottom(bottom);
end
function Box:SetRight(box, right)
    if box == nil then
        return;
    end
    box:SetRight(right);
end
function Box:SetTop(box, top)
    if box == nil then
        return;
    end
    box:SetTop(top);
end
function Box:SetBottom(box, bottom)
    if box == nil then
        return;
    end
    box:SetBottom(bottom);
end
function Box:SetLeft(box, left)
    if box == nil then
        return;
    end
    box:SetLeft(left);
end
function Box:GetBottom(box)
    if box == nil then
        return nil;
    end
    return box:GetBottom();
end
function Box:GetTop(box)
    if box == nil then
        return nil;
    end
    return box:GetTop();
end
function Box:GetLeft(box)
    if box == nil then
        return nil;
    end
    return box:GetLeft();
end
function Box:GetRight(box)
    if box == nil then
        return nil;
    end
    return box:GetRight();
end
function Box:SetText(box, text)
    if box == nil then
        return;
    end
    box:SetText(text);
end
function Box:SetTextColor(box, text_color)
    if box == nil then
        return;
    end
    box:SetTextColor(text_color);
end
function Box:SetTextHAlign(box, text_halign)
    if box == nil then
        return;
    end
    box:SetTextHAlign(text_halign);
end
function Box:SetTextSize(box, text_size)
    if box == nil then
        return;
    end
    box:SetTextSize(text_size);
end
function Box:SetBorderStyle(box, style)
    if box == nil then
        return;
    end
    box:SetBorderStyle(style);
end
function Box:NewCP(source, seriesId, left_top, right_bottom)
    local id = "";
    local x1 = left_top.x or left_top.t;
    local x2 = right_bottom.x or right_bottom.t;
    if left_top.t ~= nil then
        id = core.formatDate(ToIndicoreTime(left_top.t));
    elseif left_top.x ~= nil then
        id = core.formatDate(source:date(x1));
    else
        id = core.formatDate(source:date(0));
    end
    return Box:New(id, seriesId, x1, left_top.y, x2, right_bottom.y);
end
function Box:New(id, seriesId, left, top, right, bottom)
    local newBox = {};
    newBox.SeriesId = seriesId;
    newBox.Left = left;
    function newBox:SetLeft(left)
        self.Left = left;
        return self;
    end
    function newBox:SetXLoc(val)
        self.XLoc = val;
        return self;
    end
    function newBox:GetLeft()
        return self.Left;
    end
    newBox.Top = top;
    function newBox:SetTop(top)
        self.Top = top;
        return self;
    end
    function newBox:GetTop()
        return self.Top;
    end
    newBox.Right = right;
    function newBox:SetRight(right)
        self.Right = right;
        return self;
    end
    function newBox:GetRight()
        return self.Right;
    end
    newBox.Bottom = bottom;
    function newBox:SetBottom(bottom)
        self.Bottom = bottom;
        return self;
    end
    function newBox:GetBottom()
        return self.Bottom;
    end
    newBox.BorderWidth = 1;
    newBox.BgColor = core.colors().Blue;
    function newBox:SetBgColor(clr)
        color, transparency = Graphics:SplitColorAndTransparency(clr);
        self.BgColorTransparency = transparency;
        self.BgColor = color;
        self.BrushId = nil;
        return self;
    end
    newBox.BorderColor = core.colors().Blue;
    function newBox:SetBorderColor(clr)
        color, transparency = Graphics:SplitColorAndTransparency(clr);
        self.BorderColor_transparency = transparency;
        self.BorderColor = color;
        self.PenId = nil;
        return self;
    end
    newBox.BorderStyle = "solid";
    newBox.BorderStyleIndicore = core.LINE_SOLID;
    function newBox:SetBorderStyle(style)
        self.BorderStyle = style;
        if style == "solid" or style == "arrow_right" or style == "arrow_left" or style == "arrow_both" then
            newBox.BorderStyleIndicore = core.LINE_SOLID;
        elseif style == "dotted" then
            newBox.BorderStyleIndicore = core.LINE_DOT;
        elseif style == "dashed" then
            newBox.BorderStyleIndicore = core.LINE_DASH;
        end
        self.PenId = nil;
        return self;
    end
    newBox.Text = nil;
    function newBox:SetText(text)
        self.Text = text;
        return self;
    end
    newBox.TextColor = nil;
    function newBox:SetTextColor(text_color)
        self.TextColor = text_color;
        return self;
    end
    newBox.TextHAlign = nil;
    function newBox:SetTextHAlign(text_halign)
        self.TextHAlign = text_halign;
        return self;
    end
    newBox.TextSize = nil;
    function newBox:SetTextSize(text_size)
        self.TextSize = text_size;
        return self;
    end
    function newBox:getCoordinates(context, x, y, W, H)
        return x - W / 2, y - H / 2, x + W / 2, y + H / 2;
    end
    function newBox:Draw(stage, context)
        if self.Top == nil or self.Left == nil or self.Bottom == nil or self.Right == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.BorderWidth, self.BorderColor, self.BorderStyleIndicore, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.BgColor, context);
        end
        local x1, x2;
        if self.XLoc == "bar_index" then
            _, x1 = context:positionOfBar(self.Left);
            _, x2 = context:positionOfBar(self.Right);
        else
            _, x1 = context:positionOfDate(ToIndicoreTime(self.Left));
            _, x2 = context:positionOfDate(ToIndicoreTime(self.Right));
        end
        _, y1 = context:pointOfPrice(self.Top);
        _, y2 = context:pointOfPrice(self.Bottom);
        if (x1 == x2) then
            x2 = x1 + 1;
        end
        if (y1 == y2) then
            y2 = y1 + 1
        end
        context:drawRectangle(self.PenId, self.BrushId, x1, y1, x2, y2, self.BgColorTransparency)
        context:drawRectangle(self.PenId, -1, x1, y1, x2, y2)
        if self.Text ~= nil and self.Text ~= "" then
            if self.FontId == nil then
                self.FontId = Graphics:FindFont("Arial", 10, 0, context.LEFT, context);
            end
            local W, H = context:measureText(self.FontId, self.Text, context.LEFT);
            local x_from, y_from, x_to, y_to = self:getCoordinates(context, (x1 + x2) / 2, (y1 + y2) / 2, W, H);
            context:drawText(self.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
        end
    end
    function newBox:Get(index)
        return Box.AllSeries[self.SeriesId][index + 1];
    end
    self.AllBoxs[id .. "_" .. seriesId] = newBox;
    if self.AllSeries[seriesId] == nil then
        self.AllSeries[seriesId] = {};
    end
    table.insert(self.AllSeries[seriesId], 1, newBox);
    return newBox;
end
function Box:Delete(box)
    if box == nil then
        return;
    end
    self:removeFromAllBoxes(box);
    self:removeFromSeries(box);
end
function Box:removeFromSeries(box)
    for i = 1, #self.AllSeries[box.SeriesId] do
        if self.AllSeries[box.SeriesId][i] == box then
            table.remove(self.AllSeries[box.SeriesId], i);
            return;
        end
    end
end
function Box:removeFromAllBoxes(box)
    for key, value in pairs(self.AllBoxs) do
        if value == box then
            self.AllBoxs[key] = nil;
            return;
        end
    end
end
function Box:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for id, Box in pairs(self.AllBoxs) do
        Box:Draw(stage, context);
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76481
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.