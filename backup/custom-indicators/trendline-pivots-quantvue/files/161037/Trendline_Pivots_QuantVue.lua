-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76404
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
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
    indicator:name("Trendline Pivots [QuantVue]");
    indicator:description("Trendline Pivots [QuantVue]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addColor("param1", "Down Trend Line Color", "", core.colors().Red);
    indicator.parameters:addColor("param2", "Up Trend Line Color", "", core.colors().Green);
    indicator.parameters:addColor("param3", "Crossed Line Color", "", core.colors().Orange);
    indicator.parameters:addBoolean("param4", "Extend Lines Until Crossed", "", false);
    indicator.parameters:addBoolean("param5", "Most Recent Line Only", "If multiple lines share pivot points, checking this will only show the most recent line.", false);
    indicator.parameters:addBoolean("param6", "Hide Crossed Lines", "", false);
    indicator.parameters:addBoolean("param7", "Show Crosses", "Hiding crossed lines will only leave trend lines on the chart that have not been breached by your selected source. Showing crosses will plot an \"X\" where price crosses the trendline based on your selected source.", true);
    indicator.parameters:addColor("param8", "Cross Below Color", "", core.colors().Red);
    indicator.parameters:addColor("param9", "Cross Above Color", "", core.colors().Lime);
    indicator.parameters:addInteger("param10", "Max Number of Crossed Lines to Show", "", 4, 0, 50);
    indicator.parameters:addString("param11", "Cross Source", "", "Close");
    indicator.parameters:addStringAlternative("param11", "Close", "", "Close");
    indicator.parameters:addStringAlternative("param11", "High/Low", "", "High/Low");
    indicator.parameters:addInteger("param12", "Max Line Length", "Will remove line if it is not crossed after selected amount of bars", 252);
    indicator.parameters:addInteger("param13", "Pivot Length", "", 9, 1);
    indicator.parameters:addBoolean("param14", "Log Scale", "Select this option if using a log chart.", false);
    signaler:Init(indicator.parameters);
end

local source;
function CreateType_pivot(pivTypeValue, x1Value, y1Value, x2Value, y2Value)
    return {
        pivType = pivTypeValue,
        x1 = x1Value,
        y1 = y1Value,
        x2 = x2Value,
        y2 = y2Value,
    };
end
function pivot_GetpivType(self)
    if self == nil then return nil; end
    return self.pivType;
end
function pivot_SetpivType(self, val)
    if self == nil then return nil; end
    self.pivType = val;
end
function pivot_Getx1(self)
    if self == nil then return nil; end
    return self.x1;
end
function pivot_Setx1(self, val)
    if self == nil then return nil; end
    self.x1 = val;
end
function pivot_Gety1(self)
    if self == nil then return nil; end
    return self.y1;
end
function pivot_Sety1(self, val)
    if self == nil then return nil; end
    self.y1 = val;
end
function pivot_Getx2(self)
    if self == nil then return nil; end
    return self.x2;
end
function pivot_Setx2(self, val)
    if self == nil then return nil; end
    self.x2 = val;
end
function pivot_Gety2(self)
    if self == nil then return nil; end
    return self.y2;
end
function pivot_Sety2(self, val)
    if self == nil then return nil; end
    self.y2 = val;
end
function Create_createLine_s(ptype)
    local local_vars = {};
    Line:Prepare(50);
    return {
        Clear = function()
        end,
        GetValue = function(x1, y1, x2, y2, period, mode)
            local_vars["piv"] = CreateType_pivot(ptype, x1, y1, x2, y2);
            local_vars["trendline"] = Line:New(x1, y1, x2, y2):SetColor(Triary((ptype == "ph"), vars["dtlColor"], vars["utlColor"])):SetExtend(Triary(vars["extendLine"], "right", "none")):SetWidth(2);
            if (ptype == "ph") then
                vars["dtlArray"]:Get():Unshift(local_vars["trendline"]);
            elseif (ptype == "pl") then
                vars["utlArray"]:Get():Unshift(local_vars["trendline"]);
            end
            return local_vars["piv"];
        end
    };
end
function Create_getSlope()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(line, period, mode)
            local_vars["slopePh"] = SafeDivide((SafeMinus(Line:GetY2(line), Line:GetY1(line))), (SafeMinus(Line:GetX2(line), Line:GetX1(line))));
            local_vars["extendedPh"] = SafeMinus(Line:GetY2(line), SafeMultiply(local_vars["slopePh"], (SafeMinus(Line:GetX2(line), period))));
            return local_vars["extendedPh"];
        end
    };
end
function Create_getSlopeLog()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(line, period, mode)
            local_vars["slopePh"] = SafeDivide((SafeMinus(math.log(Line:GetY2(line)), math.log(Line:GetY1(line)))), (SafeMinus(Line:GetX2(line), Line:GetX1(line))));
            local_vars["extendedPh"] = math.exp(SafeMinus(math.log(Line:GetY2(line)), SafeMultiply(local_vars["slopePh"], (SafeMinus(Line:GetX2(line), period)))));
            return local_vars["extendedPh"];
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
    vars["dtlColor"] = instance.parameters.param1;
    vars["utlColor"] = instance.parameters.param2;
    vars["pastColor"] = instance.parameters.param3;
    vars["extendLine"] = instance.parameters.param4;
    vars["onlyLast"] = instance.parameters.param5;
    vars["hideCrossed"] = instance.parameters.param6;
    vars["showCross"] = instance.parameters.param7;
    vars["crossDown"] = instance.parameters.param8;
    vars["crossUp"] = instance.parameters.param9;
    vars["maxLines"] = instance.parameters.param10;
    vars["crossSrc"] = instance.parameters.param11;
    vars["maxLineLen"] = instance.parameters.param12;
    vars["pivLen"] = instance.parameters.param13;
    vars["isLog"] = instance.parameters.param14;
    vars["dtlArray"] = Variable:Create();
    vars["utlArray"] = Variable:Create();
    vars["__pivothigh1"] = CreatePivotHigh(source.high, vars["pivLen"], vars["pivLen"]);
    vars["__pivotlow1"] = CreatePivotLow(source.low, vars["pivLen"], vars["pivLen"]);
    vars["utlX1"] = instance:addInternalStream(0, 0);
    vars["utlY1"] = instance:addInternalStream(0, 0);
    vars["utlX2"] = instance:addInternalStream(0, 0);
    vars["utlY2"] = instance:addInternalStream(0, 0);
    vars["dtlX2"] = instance:addInternalStream(0, 0);
    vars["dtlY2"] = instance:addInternalStream(0, 0);
    vars["dtlX1"] = instance:addInternalStream(0, 0);
    vars["dtlY1"] = instance:addInternalStream(0, 0);
    vars["createLineFunc1"] = Create_createLine_s("pl");
    vars["createLineFunc2"] = Create_createLine_s("ph");
    vars["getSlopeFunc3"] = Create_getSlope();
    vars["getSlopeLogFunc4"] = Create_getSlopeLog();
    vars["tempUtl"] = Variable:Create();
    vars["tempUL"] = Variable:Create();
    Label:Prepare(50);
    signaler:Prepare(nameOnly);
    vars["getSlopeFunc5"] = Create_getSlope();
    vars["getSlopeLogFunc6"] = Create_getSlopeLog();
    vars["tempDtl"] = Variable:Create();
    vars["tempDL"] = Variable:Create();
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        vars["dtlArray"]:Clear();
        vars["utlArray"]:Clear();
        SafeSetFloat(vars["utlX1"], period, nil);
        SafeSetFloat(vars["utlY1"], period, nil);
        SafeSetFloat(vars["utlX2"], period, nil);
        SafeSetFloat(vars["utlY2"], period, nil);
        SafeSetFloat(vars["dtlX2"], period, nil);
        SafeSetFloat(vars["dtlY2"], period, nil);
        SafeSetFloat(vars["dtlX1"], period, nil);
        SafeSetFloat(vars["dtlY1"], period, nil);
        vars["createLineFunc1"].Clear();
        vars["createLineFunc2"].Clear();
        vars["getSlopeFunc3"].Clear();
        vars["getSlopeLogFunc4"].Clear();
        vars["tempUtl"]:Clear();
        vars["tempUL"]:Clear();
        vars["getSlopeFunc5"].Clear();
        vars["getSlopeLogFunc6"].Clear();
        vars["tempDtl"]:Clear();
        vars["tempDL"]:Clear();
    else
        SafeSetFloat(vars["utlX1"], period, SafeGetFloat(vars["utlX1"], period - 1));
        SafeSetFloat(vars["utlY1"], period, SafeGetFloat(vars["utlY1"], period - 1));
        SafeSetFloat(vars["utlX2"], period, SafeGetFloat(vars["utlX2"], period - 1));
        SafeSetFloat(vars["utlY2"], period, SafeGetFloat(vars["utlY2"], period - 1));
        SafeSetFloat(vars["dtlX2"], period, SafeGetFloat(vars["dtlX2"], period - 1));
        SafeSetFloat(vars["dtlY2"], period, SafeGetFloat(vars["dtlY2"], period - 1));
        SafeSetFloat(vars["dtlX1"], period, SafeGetFloat(vars["dtlX1"], period - 1));
        SafeSetFloat(vars["dtlY1"], period, SafeGetFloat(vars["dtlY1"], period - 1));
    end
    vars["maxLines"] = Triary(vars["hideCrossed"], 0, vars["maxLines"]);
    if not vars["dtlArray"]:IsInitialized() then
        vars["dtlArray"]:Set(Array:New(0, nil));
    end
    if not vars["utlArray"]:IsInitialized() then
        vars["utlArray"]:Set(Array:New(0, nil));
    end
    vars["ph"] = vars["__pivothigh1"]:get(period);
    vars["pl"] = vars["__pivotlow1"]:get(period);
    if NumberToBool(vars["pl"]) then
        SafeSetFloat(vars["utlX1"], period, SafeGetFloat(vars["utlX2"], period));
        SafeSetFloat(vars["utlY1"], period, SafeGetFloat(vars["utlY2"], period));
        SafeSetFloat(vars["utlX2"], period, period - vars["pivLen"]);
        SafeSetFloat(vars["utlY2"], period, source.low:tick(period - vars["pivLen"]));
        if SafeLess(SafeGetFloat(vars["utlY1"], period), SafeGetFloat(vars["utlY2"], period)) then
            vars["createLineFunc1"].GetValue(SafeGetFloat(vars["utlX1"], period), SafeGetFloat(vars["utlY1"], period), SafeGetFloat(vars["utlX2"], period), SafeGetFloat(vars["utlY2"], period), period, mode);
        end
    end
    if NumberToBool(vars["ph"]) then
        SafeSetFloat(vars["dtlX1"], period, SafeGetFloat(vars["dtlX2"], period));
        SafeSetFloat(vars["dtlY1"], period, SafeGetFloat(vars["dtlY2"], period));
        SafeSetFloat(vars["dtlX2"], period, period - vars["pivLen"]);
        SafeSetFloat(vars["dtlY2"], period, source.high:tick(period - vars["pivLen"]));
        if SafeGreater(SafeGetFloat(vars["dtlY1"], period), SafeGetFloat(vars["dtlY2"], period)) then
            vars["createLineFunc2"].GetValue(SafeGetFloat(vars["dtlX1"], period), SafeGetFloat(vars["dtlY1"], period), SafeGetFloat(vars["dtlX2"], period), SafeGetFloat(vars["dtlY2"], period), period, mode);
        end
    end
    for _, l in ipairs(Array:Enum(vars["utlArray"]:Get())) do
        vars["src"] = Triary((vars["crossSrc"] == "Close"), source.close:tick(period), source.low:tick(period));
        vars["first"] = (l == Array:Get(vars["utlArray"]:Get(), 0));
        vars["extended"] = Triary(not (vars["isLog"]), vars["getSlopeFunc3"].GetValue(l, period, mode), vars["getSlopeLogFunc4"].GetValue(l, period, mode));
        Line:SetXY2(l, period, vars["extended"]);
        if SafeGreater(SafeMinus(Line:GetX2(l), Line:GetX1(l)), vars["maxLineLen"]) then
            Line:Delete(l);
        end
        if SafeGreater(vars["src"], Line:GetPrice(l, period)) and not (vars["first"]) and vars["onlyLast"] then
            Line:Delete(l);
        end
        if not vars["tempUtl"]:IsInitialized() then
            vars["tempUtl"]:Set(Array:New(vars["maxLines"] / 2, nil));
        end
        if not vars["tempUL"]:IsInitialized() then
            vars["tempUL"]:Set(Array:New(vars["maxLines"] / 2, nil));
        end
        if SafeLess(vars["src"], Line:GetPrice(l, period)) then
            vars["newLine"] = Line:New(Line:GetX1(l), Line:GetY1(l), Line:GetX2(l), Line:GetY2(l)):SetColor(vars["pastColor"]):SetStyle("dashed"):SetWidth(1);
            label_1_x = period;
            vars["crossLabel"] = Triary(vars["showCross"], Label:New(core.formatDate(Label:GetSerial(label_1_x, source, "bar_index") or 0) .. "_1", "1", label_1_x, source.low:tick(period)):SetText(" "):SetColor(vars["crossDown"]):SetStyle("xcross"):SetSize("tiny"):SetXLoc("bar_index"), nil);
            if "once_per_bar" == "all" or vars["alert1_last_date"] ~= source:date(period) then
                vars["alert1_last_date"] = source:date(period);
                signaler:SignalEx(nil, SafeConcat(Str:ToString(SymInfo:GetTicker()), " crossing below trendline"), period, source);
            end
            Line:Delete(l);
            vars["tempUtl"]:Get():Unshift(vars["newLine"]);
            vars["tempUL"]:Get():Unshift(vars["crossLabel"]);
        end
        if SafeGreater(vars["tempUtl"]:Get():Size(), (vars["maxLines"] / 2)) then
            Line:Delete(Array:Pop(vars["tempUtl"]:Get()));
            Label:Delete(Array:Pop(vars["tempUL"]:Get()));
        end
    end
    for _, l in ipairs(Array:Enum(vars["dtlArray"]:Get())) do
        vars["first"] = (l == Array:Get(vars["dtlArray"]:Get(), 0));
        vars["src"] = Triary((vars["crossSrc"] == "Close"), source.close:tick(period), source.high:tick(period));
        vars["extended"] = Triary(not (vars["isLog"]), vars["getSlopeFunc5"].GetValue(l, period, mode), vars["getSlopeLogFunc6"].GetValue(l, period, mode));
        Line:SetXY2(l, period, vars["extended"]);
        if SafeGreater(SafeMinus(Line:GetX2(l), Line:GetX1(l)), vars["maxLineLen"]) then
            Line:Delete(l);
        end
        if SafeLess(vars["src"], Line:GetPrice(l, period)) and not (vars["first"]) and vars["onlyLast"] then
            Line:Delete(l);
        end
        if not vars["tempDtl"]:IsInitialized() then
            vars["tempDtl"]:Set(Array:New(vars["maxLines"] / 2, nil));
        end
        if not vars["tempDL"]:IsInitialized() then
            vars["tempDL"]:Set(Array:New(vars["maxLines"] / 2, nil));
        end
        if SafeGreater(vars["src"], Line:GetPrice(l, period)) then
            vars["newLine"] = Line:New(Line:GetX1(l), Line:GetY1(l), Line:GetX2(l), Line:GetY2(l)):SetColor(vars["pastColor"]):SetStyle("dashed"):SetWidth(1);
            label_2_x = period;
            vars["crossLabel"] = Triary(vars["showCross"], Label:New(core.formatDate(Label:GetSerial(label_2_x, source, "bar_index") or 0) .. "_2", "2", label_2_x, source.high:tick(period)):SetText(""):SetColor(vars["crossUp"]):SetStyle("xcross"):SetSize("tiny"):SetXLoc("bar_index"), nil);
            if "once_per_bar" == "all" or vars["alert2_last_date"] ~= source:date(period) then
                vars["alert2_last_date"] = source:date(period);
                signaler:SignalEx(nil, SafeConcat(Str:ToString(SymInfo:GetTicker()), " crossing above trendline"), period, source);
            end
            Line:Delete(l);
            vars["tempDtl"]:Get():Unshift(vars["newLine"]);
            vars["tempDL"]:Get():Unshift(vars["crossLabel"]);
        end
        if SafeGreater(vars["tempDtl"]:Get():Size(), (vars["maxLines"] / 2)) then
            Line:Delete(Array:Pop(vars["tempDtl"]:Get()));
            Label:Delete(Array:Pop(vars["tempDL"]:Get()));
        end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
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
Variable = {};
function Variable:Create()
    local var = {};
    var._init = false;
    function var:Clear()
        self._init = false;
        self._value = nil;
    end
    function var:Get()
        return self._value;
    end
    function var:Set(value)
        self._value = value;
        self._init = true;
    end
    function var:IsInitialized()
        return self._value;
    end
    return var;
end
Array = {};
function Array:Enum(array)
    if array == nil then
        return {};
    end
    return array.arr;
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
function Array:Max(array)
    if array == nil then
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
    if array == nil then
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
    if array == nil then
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
    function newArray:Push(item) self.size = self.size + 1; self.arr[#self.arr + 1] = item; return self; end
    function newArray:Get(index) return self.arr[index + 1]; end
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
function CreatePivotHigh(source, leftbars, rightbars)
    local pivot = {};
    pivot.Source = source;
    pivot.LeftBars = leftbars;
    pivot.RightBars = rightbars;
    function pivot:get(period)
        if period - self.RightBars - self.LeftBars - 1 < 0 or not self.Source:hasData(period - self.RightBars) then
            return nil;
        end
        local ref = self.Source:tick(period - self.RightBars);
        for i = period - self.RightBars - self.LeftBars, period - self.RightBars - 1 do
            if not self.Source:hasData(i) or self.Source:tick(i) >= ref then
                return nil;
            end
        end
        for i = period - self.LeftBars + 1, period do
            if not self.Source:hasData(i) or self.Source:tick(i) >= ref then
                return nil;
            end
        end
        return ref;
    end
    return pivot;
end
function CreatePivotLow(source, leftbars, rightbars)
    local pivot = {};
    pivot.Source = source;
    pivot.LeftBars = leftbars;
    pivot.RightBars = rightbars;
    function pivot:get(period)
        if period - self.RightBars - self.LeftBars - 1 < 0 or not self.Source:hasData(period - self.RightBars) then
            return nil;
        end
        local ref = self.Source:tick(period - self.RightBars);
        for i = period - self.RightBars - self.LeftBars, period - self.RightBars - 1 do
            if not self.Source:hasData(i) or self.Source:tick(i) <= ref then
                return nil;
            end
        end
        for i = period - self.LeftBars + 1, period do
            if not self.Source:hasData(i) or self.Source:tick(i) <= ref then
                return nil;
            end
        end
        return ref;
    end
    return pivot;
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
    return core.tableToDate(date);
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
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
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
            _, x1 = context:positionOfDate(self.X1 / 86400000.0)
            _, x2 = context:positionOfDate(self.X2 / 86400000.0)
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
    self.AllLines[#self.AllLines + 1] = newLine;
    if #self.AllLines > self.max_lines_count then
        table.remove(self.AllLines, 1);
    end
    return newLine;
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
signaler.lastIndexSerial = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) 
    if modules == nil then
        self._ids_start = 100; 
        return;
    end
    for _, module in pairs(modules) do 
        self:OnNewModule(module); 
        module:OnNewModule(self); 
    end 
    modules[#modules + 1] = self; 
    self._ids_start = (#modules) * 100; 
end

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
function signaler:getSource(source)
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
    return source;
end
function signaler:SignalEx(index, message, period, source)
    source = self:getSource(source);
    if index ~= nil then
        if (self.lastIndexSerial[index] == source:serial(period)) then
            return;
        end
        self.lastIndexSerial[index] = source:serial(period);
    end
    local interval = string.find(message, "{{interval}}");
    if interval ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. source:barSize()
            .. string.sub(message, interval + string.len("{{interval}}"));
    end
    local close = string.find(message, "{{close}}");
    if close ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. win32.formatNumber(source.close[period], false, source:getDisplayPrecision())
            .. string.sub(message, interval + string.len("{{close}}"));
    end
    self:Signal(message, source);
end
function signaler:Signal(message, source)
    source = self:getSource(source);
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
SymInfo = {};
function SymInfo:GetMintick()
    return instance.source:pipSize();
end
function SymInfo:GetType()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    if offer.InstrumentType == 1 then
        return "forex";
    elseif offer.InstrumentType == 2 then
        return "index";
    elseif offer.InstrumentType == 3 then
        return "commodity";
    elseif offer.InstrumentType == 4 then
        return "";
    elseif offer.InstrumentType == 5 then
        return "";
    elseif offer.InstrumentType == 6 then
        return "";
    elseif offer.InstrumentType == 7 then
        return "";
    elseif offer.InstrumentType == 8 then
        return "";
    elseif offer.InstrumentType == 9 then
        return "crypto";
    end
    return "";
end
function SymInfo:GetBaseCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.ContractCurrency;
end
function SymInfo:GetCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.Instrument;
end
function SymInfo:GetTicker()
    return instance.source:instrument();
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76404
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
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