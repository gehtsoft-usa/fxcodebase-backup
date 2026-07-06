-- Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75327

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
local vars = {};
function Init()
    indicator:name("ZigZag with Fibonacci Levels");
    indicator:description("ZigZag with Fibonacci Levels");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "ZigZag Period", "", 15, 2, 50);
    indicator.parameters:addBoolean("param2", "Show Zig Zag", "", true);
    indicator.parameters:addBoolean("param3", "Show Fibonacci Ratios", "", true);
    indicator.parameters:addColor("param4", "Text Color for Fibo Levels", "", core.colors().Blue);
    indicator.parameters:addColor("param5", "Line Color for Fibo Levels", "", core.colors().Lime);
    indicator.parameters:addColor("param6", "Zigzag Colors", "", core.colors().Lime);
    indicator.parameters:addColor("param7", "", "", core.colors().Red);
    indicator.parameters:addString("param8", "Label Location", "", "Left");
    indicator.parameters:addStringAlternative("param8", "Left", "", "Left");
    indicator.parameters:addStringAlternative("param8", "Right", "", "Right");
    indicator.parameters:addBoolean("param9", "Enable Level 0.236", "", true);
    indicator.parameters:addBoolean("param10", "Enable Level 0.382", "", true);
    indicator.parameters:addBoolean("param11", "Enable Level 0.500", "", true);
    indicator.parameters:addBoolean("param12", "Enable Level 0.618", "", true);
    indicator.parameters:addBoolean("param13", "Enable Level 0.786", "", true);
end

local source;
function Create_add_to_zigzag_f_si(value, bindex)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            vars["zigzag"]:Unshift(SafeGetFloat(bindex, period));
            vars["zigzag"]:Unshift(SafeGetFloat(value, period));
            if SafeGreater(vars["zigzag"]:Size(), SafeGetFloat(vars["max_array_size"], period)) then
                Array:Pop(vars["zigzag"]);
                return Array:Pop(vars["zigzag"]);
            end
        end
    };
end
function Create_update_zigzag_f_si(value, bindex)
    local local_vars = {};
    local_vars["add_to_zigzagFunc3_param2"] = instance:addInternalStream(0, 0);
    local_vars["add_to_zigzagFunc3"] = Create_add_to_zigzag_f_si(value, local_vars["add_to_zigzagFunc3_param2"]);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["add_to_zigzagFunc3"].Clear();
            else
            end
            if (vars["zigzag"]:Size() == 0) then
                SafeSetFloat(local_vars["add_to_zigzagFunc3_param2"], period, SafeGetFloat(bindex, period));
                return local_vars["add_to_zigzagFunc3"].GetValue(period, mode);
            else
                if (((SafeGetFloat(vars["dir"], period) == 1) and SafeGreater(SafeGetFloat(value, period), Array:Get(vars["zigzag"], 0))) or ((SafeGetFloat(vars["dir"], period) == (-1)) and SafeLess(SafeGetFloat(value, period), Array:Get(vars["zigzag"], 0)))) then
                    Array:Set(vars["zigzag"], 0, SafeGetFloat(value, period));
                    Array:Set(vars["zigzag"], 1, SafeGetFloat(bindex, period));
                end
                return 0.;
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
    vars["prd"] = instance.parameters.param1;
    vars["showzigzag"] = instance.parameters.param2;
    vars["showfibo"] = instance.parameters.param3;
    vars["labelcol"] = instance.parameters.param4;
    vars["fibolinecol"] = instance.parameters.param5;
    vars["upcol"] = instance.parameters.param6;
    vars["dncol"] = instance.parameters.param7;
    vars["labelloc"] = instance.parameters.param8;
    vars["enable236"] = instance.parameters.param9;
    vars["enable382"] = instance.parameters.param10;
    vars["enable500"] = instance.parameters.param11;
    vars["enable618"] = instance.parameters.param12;
    vars["enable786"] = instance.parameters.param13;
    vars["shownlevels"] = instance:addInternalStream(0, 0);
    vars["__IsFirst1"] = CreateIsFirst();
    vars["__highestbars1"] = CreateHighestBars(source.high, vars["prd"]);
    vars["__lowestbars1"] = CreateLowestBars(source.low, vars["prd"]);
    vars["dir"] = instance:addInternalStream(0, 0);
    vars["max_array_size"] = instance:addInternalStream(0, 0);
    vars["add_to_zigzagFunc1_param1"] = instance:addInternalStream(0, 0);
    vars["add_to_zigzagFunc1_param2"] = instance:addInternalStream(0, 0);
    vars["add_to_zigzagFunc1"] = Create_add_to_zigzag_f_si(vars["add_to_zigzagFunc1_param1"], vars["add_to_zigzagFunc1_param2"]);
    vars["update_zigzagFunc2_param1"] = instance:addInternalStream(0, 0);
    vars["update_zigzagFunc2_param2"] = instance:addInternalStream(0, 0);
    vars["update_zigzagFunc2"] = Create_update_zigzag_f_si(vars["update_zigzagFunc2_param1"], vars["update_zigzagFunc2_param2"]);
    Line:Prepare(300);
    Label:Prepare(50);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        vars["fibo_ratios"] = Array:NewFloat(0, nil);
        SafeSetFloat(vars["shownlevels"], period, 1);
        vars["__IsFirst1"]:Clear();
        SafeSetFloat(vars["dir"], period, 0);
        SafeSetFloat(vars["max_array_size"], period, 10);
        vars["zigzag"] = Array:NewFloat(0, nil);
        vars["add_to_zigzagFunc1"].Clear();
        vars["update_zigzagFunc2"].Clear();
            vars["zzline"] = nil;
        vars["fibolines"] = Array:NewLine(0, nil);
        vars["fibolabels"] = Array:NewLabel(0, nil);
    else
        SafeSetFloat(vars["shownlevels"], period, SafeGetFloat(vars["shownlevels"], period - 1));
        SafeSetFloat(vars["dir"], period, SafeGetFloat(vars["dir"], period - 1));
        SafeSetFloat(vars["max_array_size"], period, SafeGetFloat(vars["max_array_size"], period - 1));
    end
    if vars["__IsFirst1"]:IsFirst() then
        vars["fibo_ratios"]:Push(0.000);
        if vars["enable236"] then
            vars["fibo_ratios"]:Push(0.236);
            SafeSetFloat(vars["shownlevels"], period, SafeGetFloat(vars["shownlevels"], period) + 1);
        end
        if vars["enable382"] then
            vars["fibo_ratios"]:Push(0.382);
            SafeSetFloat(vars["shownlevels"], period, SafeGetFloat(vars["shownlevels"], period) + 1);
        end
        if vars["enable500"] then
            vars["fibo_ratios"]:Push(0.500);
            SafeSetFloat(vars["shownlevels"], period, SafeGetFloat(vars["shownlevels"], period) + 1);
        end
        if vars["enable618"] then
            vars["fibo_ratios"]:Push(0.618);
            SafeSetFloat(vars["shownlevels"], period, SafeGetFloat(vars["shownlevels"], period) + 1);
        end
        if vars["enable786"] then
            vars["fibo_ratios"]:Push(0.786);
            SafeSetFloat(vars["shownlevels"], period, SafeGetFloat(vars["shownlevels"], period) + 1);
        end
        local for1_from = 1;
        local for1_to = 5;
        local for1_step = for1_from < for1_to and 1 or -1;
        if not for1_from or not for1_to then return; end
        for x = for1_from, for1_to, for1_step do
            vars["fibo_ratios"]:Push(x);
            vars["fibo_ratios"]:Push(x + 0.272);
            vars["fibo_ratios"]:Push(x + 0.414);
            vars["fibo_ratios"]:Push(x + 0.618);
        end
    end
    ph = Triary((vars["__highestbars1"]:get(period) == 0), source.high:tick(period), nil);
    pl = Triary((vars["__lowestbars1"]:get(period) == 0), source.low:tick(period), nil);
    SafeSetFloat(vars["dir"], period, Triary(NumberToBool(ph) and pl == nil, 1, Triary(NumberToBool(pl) and ph == nil, (-1), SafeGetFloat(vars["dir"], period))));
    oldzigzag = Array:Copy(vars["zigzag"]);
    if vars["dir"]:first() > period - (1) then return; end
    dirchanged = ((SafeGetFloat(vars["dir"], period) ~= SafeGetFloat(vars["dir"], period - 1)));
    if (NumberToBool(ph) or NumberToBool(pl)) then
        if dirchanged then
            SafeSetFloat(vars["add_to_zigzagFunc1_param1"], period, Triary((SafeGetFloat(vars["dir"], period) == 1), ph, pl));
            SafeSetFloat(vars["add_to_zigzagFunc1_param2"], period, period);
            vars["add_to_zigzagFunc1"].GetValue(period, mode);
        else
            SafeSetFloat(vars["update_zigzagFunc2_param1"], period, Triary((SafeGetFloat(vars["dir"], period) == 1), ph, pl));
            SafeSetFloat(vars["update_zigzagFunc2_param2"], period, period);
            vars["update_zigzagFunc2"].GetValue(period, mode);
        end
    end
    if vars["showzigzag"] and SafeGE(vars["zigzag"]:Size(), 4) and SafeGE(oldzigzag:Size(), 4) then
        if ((Array:Get(vars["zigzag"], 0) ~= Array:Get(oldzigzag, 0)) or (Array:Get(vars["zigzag"], 1) ~= Array:Get(oldzigzag, 1))) then
            if (Array:Get(vars["zigzag"], 2) == Array:Get(oldzigzag, 2)) and (Array:Get(vars["zigzag"], 3) == Round(Array:Get(oldzigzag, 3))) then
                Line:Delete(vars["zzline"]);
            end
            vars["zzline"] = Line:New(Round(Array:Get(vars["zigzag"], 1)), Array:Get(vars["zigzag"], 0), Round(Array:Get(vars["zigzag"], 3)), Array:Get(vars["zigzag"], 2)):SetColor(Triary((SafeGetFloat(vars["dir"], period) == 1), vars["upcol"], vars["dncol"])):SetWidth(2);
        end
    end
    if vars["showfibo"] and SafeGE(vars["zigzag"]:Size(), 6) and period == source:size() - 1 then
        if SafeGreater(vars["fibolines"]:Size(), 0) then
            local for2_from = 0;
            local for2_to = SafeMinus(vars["fibolines"]:Size(), 1);
            local for2_step = for2_from < for2_to and 1 or -1;
            if not for2_from or not for2_to then return; end
            for x = for2_from, for2_to, for2_step do
                Line:Delete(Array:Get(vars["fibolines"], x));
                Label:Delete(Array:Get(vars["fibolabels"], x));
            end
        end
        diff = SafeMinus(Array:Get(vars["zigzag"], 4), Array:Get(vars["zigzag"], 2));
        vars["stopit"] = false;
        local for3_from = 0;
        local for3_to = SafeMinus(vars["fibo_ratios"]:Size(), 1);
        local for3_step = for3_from < for3_to and 1 or -1;
        if not for3_from or not for3_to then return; end
        for x = for3_from, for3_to, for3_step do
            if vars["stopit"] and (x > SafeGetFloat(vars["shownlevels"], period)) then
                break;
            end
            vars["fibolines"]:Unshift(Line:New(Round(Array:Get(vars["zigzag"], 5)), SafePlus(Array:Get(vars["zigzag"], 2), SafeMultiply(diff, Array:Get(vars["fibo_ratios"], x))), period, SafePlus(Array:Get(vars["zigzag"], 2), SafeMultiply(diff, Array:Get(vars["fibo_ratios"], x)))):SetColor(vars["fibolinecol"]):SetExtend("right"));
            label_x_loc = Triary((vars["labelloc"] == "Left"), SafeMinus(Round(Array:Get(vars["zigzag"], 5)), 1), period + 15);
            label_1_x = label_x_loc;
            vars["fibolabels"]:Unshift(Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, SafePlus(Array:Get(vars["zigzag"], 2), SafeMultiply(diff, Array:Get(vars["fibo_ratios"], x)))):SetText(SafeConcat(SafeConcat(SafeConcat(Str:ToString(Array:Get(vars["fibo_ratios"], x), "#.###"), "("), Str:ToString(Round(SafePlus(Array:Get(vars["zigzag"], 2), SafeMultiply(diff, Array:Get(vars["fibo_ratios"], x))), source:getPrecision()))), ")")):SetTextColor(vars["labelcol"]):SetStyle("none"));
            if (((SafeGetFloat(vars["dir"], period) == 1) and SafeGreater(SafePlus(Array:Get(vars["zigzag"], 2), SafeMultiply(diff, Array:Get(vars["fibo_ratios"], x))), Array:Get(vars["zigzag"], 0))) or ((SafeGetFloat(vars["dir"], period) == (-1)) and SafeLess(SafePlus(Array:Get(vars["zigzag"], 2), SafeMultiply(diff, Array:Get(vars["fibo_ratios"], x))), Array:Get(vars["zigzag"], 0)))) then
                vars["stopit"] = true;
            end
        end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
function Array:NewArray(size, initialValue)
    local newArray = {};
    newArray.arr = {};
    newArray.size = size;
    for i = 1, size, 1 do
        newArray.arr[i] = initialValue;
    end
    function newArray:Push(item) self.size = self.size + 1; self.arr[#self.arr + 1] = item; end
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
    function newArray:Sum()
        local sum = 0;
        for i, v in ipairs(self.arr) do
            sum = sum + v;
        end
        return sum;
    end
    function newArray:Copy()
        local arrayCopy = Array:NewArray(self.size, nil);
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
    return Array:NewArray(size, initialValue);
end
function Array:NewInt(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewFloat(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewLabel(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewString(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewBox(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function CreateIsFirst()
    local is_first = {};
    is_first.first = true;
    function is_first:IsFirst()
        local val = self.first;
        self.first = false;
        return val;
    end
    function is_first:Clear()
        self.first = true;
    end
    return is_first;
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
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
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

function CreateHighestBars(source, length)
    local highestbars = {};
    highestbars.Source = source;
    highestbars.Length = length;
    function highestbars:get(period)
        if period < self.Length then
            return nil;
        end
        local _, pos = mathex.max(self.Source, core.rangeTo(period, self.Length));
        return period - pos;
    end
    return highestbars;
end
function CreateLowestBars(source, length)
    local lowestbars = {};
    lowestbars.Source = source;
    lowestbars.Length = length;
    function lowestbars:get(period)
        if period < self.Length then
            return nil;
        end
        local _, pos = mathex.min(self.Source, core.rangeTo(period, self.Length));
        return period - pos;
    end
    return lowestbars;
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
        if self.Y1 == nil or self.Y2 == nil or self.X1 == nil or self.X2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        local x1 = self:converXToPoints(context, self.X1);
        local x2 = self:converXToPoints(context, self.X2);
        local _, y1 = context:pointOfPrice(self.Y1);
        local _, y2 = context:pointOfPrice(self.Y2);
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            local y3 = a * context:right() + c;
            context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
        end
        if self.Extend == "left" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            local y3 = a * context:left() + c;
            context:drawLine(self.PenId, x1, y1, context:left(), y3, self.ColorTransparency);
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
    newLabel.Style = "down";
    function newLabel:SetStyle(style)
        self.Style = style;
        return self;
    end
    function newLabel:getCoordinates(context, W, H)
        local visible, y = context:pointOfPrice(self.Y);
        local x1, x = context:positionOfBar(self.X)
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
    if pattern == nil then
        return tostring(value);
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

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
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