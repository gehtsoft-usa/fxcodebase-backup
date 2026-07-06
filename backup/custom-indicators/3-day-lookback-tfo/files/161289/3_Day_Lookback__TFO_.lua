-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76451
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
    indicator:name("3 Day Lookback [TFO]");
    indicator:description("3 Day Lookback [TFO]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addString("param1", "Above Range", "", "Above");
    indicator.parameters:addString("param2", "Inside Range", "", "Inside");
    indicator.parameters:addString("param3", "Below Range", "", "Below");
    indicator.parameters:addBoolean("param4", "Show Levels?", "", true);
    indicator.parameters:addBoolean("param5", "Show Labels?", "", true);
    indicator.parameters:addString("param6", "", "", "Left");
    indicator.parameters:addStringAlternative("param6", "Left", "", "Left");
    indicator.parameters:addStringAlternative("param6", "Right", "", "Right");
    indicator.parameters:addColor("param7", "", "", core.colors().Blue);
    indicator.parameters:addColor("param8", "", "", core.colors().Red);
    indicator.parameters:addString("param9", "Table Position", "", "Middle Right");
    indicator.parameters:addStringAlternative("param9", "Bottom Center", "", "Bottom Center");
    indicator.parameters:addStringAlternative("param9", "Bottom Left", "", "Bottom Left");
    indicator.parameters:addStringAlternative("param9", "Bottom Right", "", "Bottom Right");
    indicator.parameters:addStringAlternative("param9", "Middle Center", "", "Middle Center");
    indicator.parameters:addStringAlternative("param9", "Middle Left", "", "Middle Left");
    indicator.parameters:addStringAlternative("param9", "Middle Right", "", "Middle Right");
    indicator.parameters:addStringAlternative("param9", "Top Center", "", "Top Center");
    indicator.parameters:addStringAlternative("param9", "Top Left", "", "Top Left");
    indicator.parameters:addStringAlternative("param9", "Top Right", "", "Top Right");
    indicator.parameters:addString("param10", "Table Size", "", "Normal");
    indicator.parameters:addStringAlternative("param10", "Auto", "", "Auto");
    indicator.parameters:addStringAlternative("param10", "Tiny", "", "Tiny");
    indicator.parameters:addStringAlternative("param10", "Small", "", "Small");
    indicator.parameters:addStringAlternative("param10", "Normal", "", "Normal");
    indicator.parameters:addStringAlternative("param10", "Large", "", "Large");
    indicator.parameters:addStringAlternative("param10", "Huge", "", "Huge");
    indicator.parameters:addString("param11", "Label Size", "", "Normal");
    indicator.parameters:addStringAlternative("param11", "Auto", "", "Auto");
    indicator.parameters:addStringAlternative("param11", "Tiny", "", "Tiny");
    indicator.parameters:addStringAlternative("param11", "Small", "", "Small");
    indicator.parameters:addStringAlternative("param11", "Normal", "", "Normal");
    indicator.parameters:addStringAlternative("param11", "Large", "", "Large");
    indicator.parameters:addStringAlternative("param11", "Huge", "", "Huge");
    indicator.parameters:addInteger("param12", "Line Width", "", 1);
end

local source;
local time;
function Create_get_table_pos_s(pos)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            if (pos == "Bottom Center") then
                local_vars["result"] = "bottom_center";
            elseif (pos == "Bottom Left") then
                local_vars["result"] = "bottom_left";
            elseif (pos == "Bottom Right") then
                local_vars["result"] = "bottom_right";
            elseif (pos == "Middle Center") then
                local_vars["result"] = "middle_center";
            elseif (pos == "Middle Left") then
                local_vars["result"] = "middle_left";
            elseif (pos == "Middle Right") then
                local_vars["result"] = "middle_right";
            elseif (pos == "Top Center") then
                local_vars["result"] = "top_center";
            elseif (pos == "Top Left") then
                local_vars["result"] = "top_left";
            elseif (pos == "Top Right") then
                local_vars["result"] = "top_right";
            end
            return local_vars["result"];
        end
    };
end
function Create_get_size_s(size)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            if (size == "Tiny") then
                local_vars["result"] = "tiny";
            elseif (size == "Small") then
                local_vars["result"] = "small";
            elseif (size == "Normal") then
                local_vars["result"] = "normal";
            elseif (size == "Large") then
                local_vars["result"] = "large";
            elseif (size == "Huge") then
                local_vars["result"] = "huge";
            elseif (size == "Auto") then
                local_vars["result"] = "auto";
            end
            return local_vars["result"];
        end
    };
end
function Create_get_state_i(i)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            local_vars["result"] = vars["txt_stuck"];
            if SafeGreater(source.close:tick(period), Line:GetY1(Array:Get(vars["ph_lines"]:Get(), i - 1))) then
                local_vars["result"] = vars["txt_above"];
            elseif SafeLess(source.close:tick(period), Line:GetY1(Array:Get(vars["pl_lines"]:Get(), i - 1))) then
                local_vars["result"] = vars["txt_below"];
            end
            return local_vars["result"];
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
    vars["g1"] = Variable:Create();
    vars["txt_above"] = instance.parameters.param1;
    vars["txt_stuck"] = instance.parameters.param2;
    vars["txt_below"] = instance.parameters.param3;
    vars["g2"] = Variable:Create();
    vars["price_lines"] = instance.parameters.param4;
    vars["price_labels"] = instance.parameters.param5;
    vars["labels_xloc"] = instance.parameters.param6;
    vars["hi_color"] = instance.parameters.param7;
    vars["lo_color"] = instance.parameters.param8;
    vars["g3"] = Variable:Create();
    vars["get_table_posFunc1"] = Create_get_table_pos_s(instance.parameters.param9);
    vars["get_sizeFunc2"] = Create_get_size_s(instance.parameters.param10);
    vars["get_sizeFunc3"] = Create_get_size_s(instance.parameters.param11);
    vars["line_width"] = instance.parameters.param12;
    vars["d_hi"] = Variable:Create();
    vars["d_lo"] = Variable:Create();
    vars["d_hi_time"] = Variable:Create();
    time = instance:addInternalStream(0, 0);
    vars["d_lo_time"] = Variable:Create();
    vars["d_new_time"] = Variable:Create();
    vars["ph_lines"] = Variable:Create();
    vars["pl_lines"] = Variable:Create();
    vars["ph_labels"] = Variable:Create();
    vars["pl_labels"] = Variable:Create();
    vars["left_lbl"] = Variable:Create();
    Line:Prepare(50);
    Label:Prepare(50);
    vars["tbl"] = Variable:Create();
    vars["get_stateFunc4"] = Create_get_state_i(1);
    vars["get_stateFunc5"] = Create_get_state_i(2);
    vars["get_stateFunc6"] = Create_get_state_i(3);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        Table:Clear();
        vars["g1"]:Clear();
        vars["g2"]:Clear();
        vars["g3"]:Clear();
        vars["get_table_posFunc1"].Clear();
        vars["get_sizeFunc2"].Clear();
        vars["get_sizeFunc3"].Clear();
        vars["d_hi"]:Clear();
        vars["d_lo"]:Clear();
        vars["d_hi_time"]:Clear();
        time[period] = source:date(period) * 86400000;
        vars["d_lo_time"]:Clear();
        vars["d_new_time"]:Clear();
        vars["ph_lines"]:Clear();
        vars["pl_lines"]:Clear();
        vars["ph_labels"]:Clear();
        vars["pl_labels"]:Clear();
        vars["left_lbl"]:Clear();
        vars["tbl"]:Clear();
        vars["get_stateFunc4"].Clear();
        vars["get_stateFunc5"].Clear();
        vars["get_stateFunc6"].Clear();
    else
        time[period] = source:date(period) * 86400000;
    end
    if not vars["g1"]:IsInitialized() then
        vars["g1"]:Set("State");
    end
    if not vars["g2"]:IsInitialized() then
        vars["g2"]:Set("Highs & Lows");
    end
    if not vars["g3"]:IsInitialized() then
        vars["g3"]:Set("Style");
    end
    vars["tbl_pos"] = vars["get_table_posFunc1"].GetValue(period, mode);
    vars["tbl_size"] = vars["get_sizeFunc2"].GetValue(period, mode);
    vars["lbl_size"] = vars["get_sizeFunc3"].GetValue(period, mode);
    if not vars["d_hi"]:IsInitialized() then
        vars["d_hi"]:Set(source.high:tick(period));
    end
    if not vars["d_lo"]:IsInitialized() then
        vars["d_lo"]:Set(source.low:tick(period));
    end
    if not vars["d_hi_time"]:IsInitialized() then
        vars["d_hi_time"]:Set(time:tick(period));
    end
    if not vars["d_lo_time"]:IsInitialized() then
        vars["d_lo_time"]:Set(time:tick(period));
    end
    if not vars["d_new_time"]:IsInitialized() then
        vars["d_new_time"]:Set(time:tick(period));
    end
    if not vars["ph_lines"]:IsInitialized() then
        vars["ph_lines"]:Set(Array:New(0, nil));
    end
    if not vars["pl_lines"]:IsInitialized() then
        vars["pl_lines"]:Set(Array:New(0, nil));
    end
    if not vars["ph_labels"]:IsInitialized() then
        vars["ph_labels"]:Set(Array:New(0, nil));
    end
    if not vars["pl_labels"]:IsInitialized() then
        vars["pl_labels"]:Set(Array:New(0, nil));
    end
    if not vars["left_lbl"]:IsInitialized() then
        vars["left_lbl"]:Set((vars["labels_xloc"] == "Left"));
    end
    if Timeframe:Change("D", source, period) then
        vars["ph_lines"]:Get():Unshift(Line:New(vars["d_hi_time"]:Get(), vars["d_hi"]:Get(), time:tick(period), vars["d_hi"]:Get()):SetColor(Triary(vars["price_lines"], vars["hi_color"], core.rgb(255, 255, 0))):SetWidth(vars["line_width"]):SetXLoc(vars["d_hi_time"]:Get(), time:tick(period), "bar_time"));
        vars["pl_lines"]:Get():Unshift(Line:New(vars["d_lo_time"]:Get(), vars["d_lo"]:Get(), time:tick(period), vars["d_lo"]:Get()):SetColor(Triary(vars["price_lines"], vars["lo_color"], core.rgb(255, 255, 0))):SetWidth(vars["line_width"]):SetXLoc(vars["d_lo_time"]:Get(), time:tick(period), "bar_time"));
        if vars["price_labels"] and vars["price_lines"] then
            label_1_x = Triary(vars["left_lbl"]:Get(), vars["d_hi_time"]:Get(), time:tick(period));
            vars["ph_labels"]:Get():Unshift(Label:New(core.formatDate(Label:GetSerial(label_1_x, source, "bar_time") or 0) .. "_1", "1", label_1_x, vars["d_hi"]:Get()):SetText("1H"):SetColor(core.rgb(255, 255, 0)):SetTextColor(core.COLOR_LABEL):SetStyle(Triary(vars["left_lbl"]:Get(), "down", "left")):SetSize(vars["lbl_size"]):SetTooltip(Str:ToString(vars["d_hi"]:Get())):SetXLoc("bar_time"));
            label_2_x = Triary(vars["left_lbl"]:Get(), vars["d_lo_time"]:Get(), time:tick(period));
            vars["pl_labels"]:Get():Unshift(Label:New(core.formatDate(Label:GetSerial(label_2_x, source, "bar_time") or 0) .. "_2", "2", label_2_x, vars["d_lo"]:Get()):SetText("1L"):SetColor(core.rgb(255, 255, 0)):SetTextColor(core.COLOR_LABEL):SetStyle(Triary(vars["left_lbl"]:Get(), "up", "left")):SetSize(vars["lbl_size"]):SetTooltip(Str:ToString(vars["d_lo"]:Get())):SetXLoc("bar_time"));
        end
        if SafeGreater(vars["ph_labels"]:Get():Size(), 1) then
            Label:SetText(Array:Get(vars["ph_labels"]:Get(), 1), "2H");
            Label:SetText(Array:Get(vars["pl_labels"]:Get(), 1), "2L");
        end
        if SafeGreater(vars["ph_labels"]:Get():Size(), 2) then
            Label:SetText(Array:Get(vars["ph_labels"]:Get(), 2), "3H");
            Label:SetText(Array:Get(vars["pl_labels"]:Get(), 2), "3L");
        end
        if SafeGreater(vars["ph_lines"]:Get():Size(), 3) then
            Line:Delete(Array:Pop(vars["ph_lines"]:Get()));
            Line:Delete(Array:Pop(vars["pl_lines"]:Get()));
        end
        if SafeGreater(vars["ph_labels"]:Get():Size(), 3) then
            Label:Delete(Array:Pop(vars["ph_labels"]:Get()));
            Label:Delete(Array:Pop(vars["pl_labels"]:Get()));
        end
        vars["d_hi"]:Set(source.high:tick(period));
        vars["d_lo"]:Set(source.low:tick(period));
        vars["d_hi_time"]:Set(time:tick(period));
        vars["d_lo_time"]:Set(time:tick(period));
        vars["d_new_time"]:Set(time:tick(period));
    else
        if (source.high:tick(period) > vars["d_hi"]:Get()) then
            vars["d_hi"]:Set(source.high:tick(period));
            vars["d_hi_time"]:Set(time:tick(period));
        end
        if (source.low:tick(period) < vars["d_lo"]:Get()) then
            vars["d_lo"]:Set(source.low:tick(period));
            vars["d_lo_time"]:Set(time:tick(period));
        end
        for _, i, L in ipairs(Array:Enum(vars["ph_lines"]:Get())) do
            Line:SetX2(L, time:tick(period));
        end
        for _, i, L in ipairs(Array:Enum(vars["pl_lines"]:Get())) do
            Line:SetX2(L, time:tick(period));
        end
        if not (vars["left_lbl"]:Get()) then
            for _, i, L in ipairs(Array:Enum(vars["ph_labels"]:Get())) do
                Label:SetX(L, time:tick(period));
            end
            for _, i, L in ipairs(Array:Enum(vars["pl_labels"]:Get())) do
                Label:SetX(L, time:tick(period));
            end
        end
    end
    if period == source:size() - 1 then
        if not vars["tbl"]:IsInitialized() then
            vars["tbl"]:Set(Table:New("1", vars["tbl_pos"], 10, 10):SetBorderWidth(1):SetBgColor(core.COLOR_BACKGROUND):SetBorderColor(core.COLOR_LABEL):SetFrameColor(core.COLOR_LABEL):SetFrameWidth(2));
        end
        Table:CellText(vars["tbl"]:Get(), 0, 0, "Days Ago");
        Table:CellTextColor(vars["tbl"]:Get(), 0, 0, core.COLOR_LABEL);
        Table:CellTextSize(vars["tbl"]:Get(), 0, 0, vars["tbl_size"]);
        Table:CellTextHAlign(vars["tbl"]:Get(), 0, 0, "center");
        Table:CellText(vars["tbl"]:Get(), 1, 0, "State");
        Table:CellTextColor(vars["tbl"]:Get(), 1, 0, core.COLOR_LABEL);
        Table:CellTextSize(vars["tbl"]:Get(), 1, 0, vars["tbl_size"]);
        Table:CellTextHAlign(vars["tbl"]:Get(), 1, 0, "center");
        Table:CellText(vars["tbl"]:Get(), 0, 1, "1");
        Table:CellTextColor(vars["tbl"]:Get(), 0, 1, core.COLOR_LABEL);
        Table:CellTextSize(vars["tbl"]:Get(), 0, 1, vars["tbl_size"]);
        Table:CellTextHAlign(vars["tbl"]:Get(), 0, 1, "center");
        Table:CellText(vars["tbl"]:Get(), 0, 2, "2");
        Table:CellTextColor(vars["tbl"]:Get(), 0, 2, core.COLOR_LABEL);
        Table:CellTextSize(vars["tbl"]:Get(), 0, 2, vars["tbl_size"]);
        Table:CellTextHAlign(vars["tbl"]:Get(), 0, 2, "center");
        Table:CellText(vars["tbl"]:Get(), 0, 3, "3");
        Table:CellTextColor(vars["tbl"]:Get(), 0, 3, core.COLOR_LABEL);
        Table:CellTextSize(vars["tbl"]:Get(), 0, 3, vars["tbl_size"]);
        Table:CellTextHAlign(vars["tbl"]:Get(), 0, 3, "center");
        Table:CellText(vars["tbl"]:Get(), 1, 1, vars["get_stateFunc4"].GetValue(period, mode));
        Table:CellTextColor(vars["tbl"]:Get(), 1, 1, core.COLOR_LABEL);
        Table:CellTextSize(vars["tbl"]:Get(), 1, 1, vars["tbl_size"]);
        Table:CellTextHAlign(vars["tbl"]:Get(), 1, 1, "center");
        Table:CellText(vars["tbl"]:Get(), 1, 2, vars["get_stateFunc5"].GetValue(period, mode));
        Table:CellTextColor(vars["tbl"]:Get(), 1, 2, core.COLOR_LABEL);
        Table:CellTextSize(vars["tbl"]:Get(), 1, 2, vars["tbl_size"]);
        Table:CellTextHAlign(vars["tbl"]:Get(), 1, 2, "center");
        Table:CellText(vars["tbl"]:Get(), 1, 3, vars["get_stateFunc6"].GetValue(period, mode));
        Table:CellTextColor(vars["tbl"]:Get(), 1, 3, core.COLOR_LABEL);
        Table:CellTextSize(vars["tbl"]:Get(), 1, 3, vars["tbl_size"]);
        Table:CellTextHAlign(vars["tbl"]:Get(), 1, 3, "center");
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
    Table:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
Timeframe = {};
function Timeframe:Period()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "t";
    elseif string.sub(bar_size, 1, 1) == "m" then
        local seconds = tonumber(string.sub(bar_size, 2));
        return tostring(seconds);
    elseif string.sub(bar_size, 1, 1) == "H" then
        local seconds = 60 * tonumber(string.sub(bar_size, 2));
        return tostring(seconds);
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
    return Line:New(p1.x, p1.y, p2.x, p2.y);
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
Table = {};
Table.AllTables = {};
function Table:Clear()
    Table.AllTables = {};
end
function Table:MergeCells(table, start_column, start_row, end_column, end_row)
    if table == nil then
        return;
    end
    table:MergeCells(start_column, start_row, end_column, end_row);
end
function Table:CellText(table, column, row, text)
    if table == nil then
        return;
    end
    table:CellText(column, row, text)
end
function Table:CellTextColor(table, column, row, color)
    if table == nil then
        return;
    end
    table:CellTextColor(column, row, color)
end
function Table:CellBGColor(table, column, row, color)
    if table == nil then
        return;
    end
    table:CellBGColor(column, row, color)
end
function Table:CellTextSize(table, column, row, size)
    if table == nil then
        return;
    end
    table:CellTextSize(column, row, size)
end
function Table:CellTextHAlign(table, column, row, halign)
    if table == nil then
        return;
    end
    table:CellTextHAlign(column, row, halign)
end
function Table:New(id, position, columns, rows)
    local newTable = {};
    newTable.offset = 5;
    newTable.position = position;
    newTable.border_width = 1;
    function newTable:SetBorderWidth(width)
        self.border_width = width;
        return self;
    end
    newTable.bgcolor = nil;
    function newTable:SetBgColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.bgcolor = clr;
        self.bgcolor_transparency = transp;
        return self;
    end
    newTable.border_color = core.colors().Gray;
    newTable.border_style = core.LINE_SOLID;
    function newTable:SetBorderColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.border_color = clr;
        self.border_color_transparency = transp;
        return self;
    end
    newTable.frame_color = core.colors().Gray;
    function newTable:SetFrameColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.frame_color = clr;
        self.frame_color_transparency = transp;
        return self;
    end
    newTable.frame_width = 1;
    function newTable:SetFrameWidth(width)
        self.frame_width = width;
        return self;
    end
    newTable.rows = {};
    for i = 1, rows, 1 do
        newTable.rows[i] = {};
        for ii = 1, columns, 1 do
            local cell = {};
            cell.text = "";
            cell.text_color = core.COLOR_LABEL;
            cell.text_halign = "middle";
            cell.text_size = "normal";
            cell.cache = {};
            newTable.rows[i][ii] = cell;
        end
    end
    function newTable:CellText(column, row, text)
        if self.rows[row + 1][column + 1].text ~= text then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text = text;
        return self;
    end
    function newTable:CellTextColor(column, row, color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.rows[row + 1][column + 1].text_color = clr;
        return self;
    end
    function newTable:CellBGColor(column, row, color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.rows[row + 1][column + 1].bg_color = clr;
        return self;
    end
    function newTable:CellTextSize(column, row, size)
        if self.rows[row + 1][column + 1].text_size ~= size then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text_size = size;
        return self;
    end
    function newTable:CellTextHAlign(column, row, halign)
        if self.rows[row + 1][column + 1].text_halign ~= halign then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text_halign = halign;
        return self;
    end
    function newTable:MergeCells(start_column, start_row, end_column, end_row)
        for columnIndex = start_column + 1, end_column + 1 do
            for rowIndex = start_row + 1, end_row + 1 do
                if columnIndex ~= start_column + 1 or rowIndex ~= start_row + 1 then
                    self.rows[rowIndex][columnIndex].skip = true;
                else
                    self.rows[rowIndex][columnIndex].skip = nil;
                    self.rows[rowIndex][columnIndex].till_row = end_row + 1;
                    self.rows[rowIndex][columnIndex].till_column = end_column + 1;
                end
            end
        end
        return self;
    end
    function newTable:getRowDirection()
        if self.position == "top_left" or self.position == "top_right" or self.position == "top_middle" then
            return 1;
        end
        if self.position == "bottom_left" or self.position == "bottom_right" or self.position == "bottom_middle" then
            return -1;
        end
        return 0;
    end
    function newTable:getColumnDirection()
        if self.position == "top_left" or self.position == "bottom_left" or self.position == "middle_left" then
            return 1;
        end
        if self.position == "top_right" or self.position == "bottom_right" or self.position == "middle_right" then
            return -1;
        end
        return 0;
    end
    function newTable:measureCells(context)
        local columnWidths = {};
        local rowHeights = {};
        local total_height = 0;
        local total_width = 0;
        for row = 1, #self.rows do
            for column = 1, #self.rows[row] do
                local W, H;
                if self.rows[row][column].cache.W ~= nil then
                    W = self.rows[row][column].cache.W;
                    H = self.rows[row][column].cache.H;
                else
                    if self.rows[row][column].text ~= nil then
                        W, H = context:measureText(Table.FontId, self.rows[row][column].text, context.LEFT);
                        if W > 0 then
                            W = W + self.offset * 2;
                        end
                        if H > 0 then
                            H = H + self.offset * 2;
                        end
                    else
                        W, H = 0, 0;
                    end
                    self.rows[row][column].cache.W = W;
                    self.rows[row][column].cache.H = H;
                end
                if columnWidths[column] == nil or columnWidths[column] < W then
                    columnWidths[column] = W;
                end
                if rowHeights[row] == nil or rowHeights[row] < H then
                    rowHeights[row] = H;
                end
            end
            total_height = total_height + rowHeights[row];
        end
        for i = 1, #columnWidths do
            total_width = total_width + columnWidths[i];
        end
        return rowHeights, columnWidths, total_height, total_width;
    end
    function newTable:getCellWidth(row, column, columnWidths)
        local w = columnWidths[column];
        local shift = 0;
        if self.rows[row][column].till_column ~= nil and self.rows[row][column].till_column ~= column then
            for i = column + 1, self.rows[row][column].till_column do
                w = w + columnWidths[i];
                shift = shift + columnWidths[i];
            end
        end
        return w, shift;
    end
    function newTable:getCellHeight(row, column, rowHeights)
        local h = rowHeights[row];
        local shift = 0;
        if self.rows[row][column].till_row ~= nil and self.rows[row][column].till_row ~= row then
            for i = row + 1, self.rows[row][column].till_row do
                h = h + rowHeights[i];
                shift = shift + rowHeights[i];
            end
        end
        return h, shift;
    end
    function newTable:getLabelXCoordinates(rectangle_x1, rectangle_x2, width, align)
        local x = (rectangle_x1 + rectangle_x2) / 2;
        if align == "left" then
            local text_x1 = rectangle_x1;
            local text_x2 = text_x1 + width;
            return text_x1, text_x2;
        elseif align == "right" then
            local text_x2 = rectangle_x2;
            local text_x1 = text_x2 - width;
            return text_x1, text_x2;
        end
        local text_x1 = x - width / 2;
        local text_x2 = text_x1 + width;
        return text_x1, text_x2;
    end
    function newTable:drawCell(context, row, column, rowHeights, columnWidths, yStart, xStart, totalRows, totalColumns)
        local rectangle_x1;
        local rectangle_x2;
        local rectangle_y1;
        local rectangle_y2;
        local width, w_shift = self:getCellWidth(row, column, columnWidths);
        local height, h_shift = self:getCellHeight(row, column, rowHeights);
        rectangle_y1 = yStart;
        rectangle_y2 = yStart + height;
        rectangle_x1 = xStart;
        rectangle_x2 = xStart + width;
        local text_x1, text_x2 = self:getLabelXCoordinates(rectangle_x1, rectangle_x2, self.rows[row][column].cache.W,
            self.rows[row][column].text_halign);
        local y = (rectangle_y1 + rectangle_y2) / 2;
        local text_y1 = y - self.rows[row][column].cache.H / 2;
        local text_y2 = y + self.rows[row][column].cache.H;
        text_x1 = text_x1 + self.offset;
        text_x2 = text_x2 - self.offset;
        text_y1 = text_y1 + self.offset;
        text_y2 = text_y2 - self.offset;
        local bgBrush = self.BgBrushId;
        if self.rows[row][column].bg_color ~= nil then
            if self.rows[row][column].bg_brushId == nil then
                self.rows[row][column].bg_brushId = Graphics:FindBrush(self.rows[row][column].bg_color, context);
            end
            bgBrush = self.rows[row][column].bg_brushId;
        end
        if bgBrush ~= nil then
            context:drawRectangle(self.FramePenId, bgBrush, rectangle_x1, rectangle_y1, rectangle_x2, rectangle_y2, self.bgcolor_transparency)
        end
        if self.BorderPenId ~= nil then
            if totalRows ~= row then
                context:drawLine(self.BorderPenId, rectangle_x1, rectangle_y2, rectangle_x2, rectangle_y2);
            end
            if totalColumns ~= column then
                context:drawLine(self.BorderPenId, rectangle_x2, rectangle_y1, rectangle_x2, rectangle_y2);
            end
        end
        context:drawText(Table.FontId, self.rows[row][column].text, self.rows[row][column].text_color, -1, 
            text_x1, text_y1, text_x2, text_y2, 0);
    end
    function newTable:Draw(stage, context)
        if self.bgcolor ~= nil and self.BgBrushId == nil then
            self.BgBrushId = Graphics:FindBrush(self.bgcolor, context);
        end
        if self.FramePenId == nil and self.frame_color ~= nil then
            self.FramePenId = Graphics:FindPen(self.frame_width or 1, self.frame_color, self.frame_style or core.LINE_SOLID, context);
        end
        if self.BorderPenId == nil and self.border_color ~= nil then
            self.BorderPenId = Graphics:FindPen(self.border_width or 1, self.border_color, self.border_style or core.LINE_SOLID, context);
        end
        local rowHeights, columnWidths, total_height, total_width = self:measureCells(context);
        
        local rowDirection = self:getRowDirection();
        local columnDirection = self:getColumnDirection();
        local x = columnDirection == 1 and context:left() or (context:right() - total_width);
        local y = rowDirection == 1 and context:top() or context:bottom() - total_height;
        local maxX = x;
        local yStart = y;
        local totalRows = #self.rows;
        for rowIt = 1, totalRows do
            local row = rowIt;
            local xStart = x; 
            local totalCoumns = #self.rows[rowIt];
            for columnIt = 1, totalCoumns do
                local column = columnIt;
                if not self.rows[row][column].skip then
                    self:drawCell(context, row, column, rowHeights, columnWidths, yStart, xStart, totalRows, totalCoumns);
                end
                xStart = xStart + columnWidths[column];
            end
            maxX = math.max(maxX, xStart);
            yStart = yStart + rowHeights[row];
        end
        if self.FramePenId ~= nil then
            context:drawLine(self.FramePenId, x, y, x, yStart);
            context:drawLine(self.FramePenId, maxX, y, maxX, yStart);
            context:drawLine(self.FramePenId, x, y, maxX, y);
            context:drawLine(self.FramePenId, x, yStart, maxX, yStart);
        end
    end
    self.AllTables[id] = newTable;
    return newTable;
end
function Table:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if Table.FontId == nil then
        Table.FontId = Graphics:FindFont("Arial", 0, context:pointsToPixels(10), context.LEFT, context);
    end
    for id, table in pairs(self.AllTables) do
        table:Draw(stage, context);
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76451
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