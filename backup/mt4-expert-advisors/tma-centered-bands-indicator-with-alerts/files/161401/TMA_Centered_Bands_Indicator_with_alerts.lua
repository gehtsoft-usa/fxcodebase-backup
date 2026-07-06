-- Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76480
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
    indicator:name("TMA Centered Bands Indicator");
    indicator:description("TMA Centered Bands Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Centered TMA half period", "", 12);
    indicator.parameters:addString("param2", "Price to use", "", "Weighted");
    indicator.parameters:addStringAlternative("param2", "Close", "", "Close");
    indicator.parameters:addStringAlternative("param2", "Open", "", "Open");
    indicator.parameters:addStringAlternative("param2", "High", "", "High");
    indicator.parameters:addStringAlternative("param2", "Low", "", "Low");
    indicator.parameters:addStringAlternative("param2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("param2", "Typical", "", "Typical");
    indicator.parameters:addStringAlternative("param2", "Weighted", "", "Weighted");
    indicator.parameters:addStringAlternative("param2", "Average", "", "Average");
    indicator.parameters:addInteger("param3", "Average true range period", "", 100);
    indicator.parameters:addDouble("param4", "Average true range multiplier", "", 2);
    indicator.parameters:addInteger("param5", "Centered TMA angle caution", "", 4);
    indicator.parameters:addColor("param6", "Bear", "", Graphics:GetColor(core.colors().Red + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param7", "Bull", "", Graphics:GetColor(core.colors().Green + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param8", "Bands", "", Graphics:GetColor(core.rgb(178, 181, 190) + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addBoolean("param9", "Caution label", "", true);
    indicator.parameters:addBoolean("param10", "Crossing up", "", false);
    indicator.parameters:addBoolean("param11", "Crossing down", "", false);
    indicator.parameters:addBoolean("param12", "Coming back", "", false);
    indicator.parameters:addBoolean("param13", "On arrow down", "", false);
    indicator.parameters:addBoolean("param14", "On arrow up", "", false);
    signaler:Init(indicator.parameters);
end

local source;
local plot1;
local plot1_offset = 0;
local plot2;
local plot2_offset = 0;
local plot3;
local plot3_offset = 0;
function Create_Price()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(x, period, mode)
            if (vars["PriceType"] == "Close") then
                local_vars["price"] = SafeGetFloat(source.close, period - (x));
            elseif (vars["PriceType"] == "Open") then
                local_vars["price"] = SafeGetFloat(source.open, period - (x));
            elseif (vars["PriceType"] == "High") then
                local_vars["price"] = SafeGetFloat(source.high, period - (x));
            elseif (vars["PriceType"] == "Low") then
                local_vars["price"] = SafeGetFloat(source.low, period - (x));
            elseif (vars["PriceType"] == "Median") then
                local_vars["price"] = SafeDivide((SafePlus(SafeGetFloat(source.high, period - (x)), SafeGetFloat(source.low, period - (x)))), 2);
            elseif (vars["PriceType"] == "Typical") then
                local_vars["price"] = SafeDivide((SafePlus(SafePlus(SafeGetFloat(source.high, period - (x)), SafeGetFloat(source.low, period - (x))), SafeGetFloat(source.close, period - (x)))), 3);
            elseif (vars["PriceType"] == "Weighted") then
                local_vars["price"] = SafeDivide((SafePlus(SafePlus(SafePlus(SafeGetFloat(source.high, period - (x)), SafeGetFloat(source.low, period - (x))), SafeGetFloat(source.close, period - (x))), SafeGetFloat(source.close, period - (x)))), 4);
            elseif (vars["PriceType"] == "Average") then
                local_vars["price"] = SafeDivide((SafePlus(SafePlus(SafePlus(SafeGetFloat(source.high, period - (x)), SafeGetFloat(source.low, period - (x))), SafeGetFloat(source.close, period - (x))), SafeGetFloat(source.open, period - (x)))), 4);
            end
            return local_vars["price"];
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
    vars["GRP1"] = Variable:Create();
    vars["HalfLength"] = instance.parameters.param1;
    vars["PriceType"] = instance.parameters.param2;
    vars["AtrPeriod"] = instance.parameters.param3;
    vars["AtrMultiplier"] = instance.parameters.param4;
    vars["TMAangle"] = instance.parameters.param5;
    vars["pastTmac"] = Variable:Create();
    vars["pastTmau"] = Variable:Create();
    vars["pastTmad"] = Variable:Create();
    vars["alertSignal"] = Variable:Create();
    vars["GRP2"] = Variable:Create();
    vars["colorBuffer"] = Variable:Create();
    vars["colorDOWN"] = Graphics:AddTransparency(instance.parameters.param6, Graphics:GetTransparencyPercent(core.colors().Red + math.floor(0 / 100 * 255) * 16777216));
    vars["colorUP"] = Graphics:AddTransparency(instance.parameters.param7, Graphics:GetTransparencyPercent(core.colors().Green + math.floor(0 / 100 * 255) * 16777216));
    vars["colorBands"] = Graphics:AddTransparency(instance.parameters.param8, Graphics:GetTransparencyPercent(core.rgb(178, 181, 190) + math.floor(0 / 100 * 255) * 16777216));
    vars["cautionInput"] = instance.parameters.param9;
    vars["GRP3"] = Variable:Create();
    vars["crossUpInput"] = instance.parameters.param10;
    vars["crossDownInput"] = instance.parameters.param11;
    vars["comingBackInput"] = instance.parameters.param12;
    vars["onArrowDownInput"] = instance.parameters.param13;
    vars["onArrowUpInput"] = instance.parameters.param14;
    vars["PriceFunc1"] = Create_Price();
    vars["PriceFunc2"] = Create_Price();
    vars["PriceFunc3"] = Create_Price();
    signaler:Prepare(nameOnly);
    Line:Prepare(500);
    Label:Prepare(500);
    plot1_color = core.colors().Blue;
    plot1_offset = (-vars["HalfLength"]);
    plot1 = instance:addStream("plot1", core.Line, "TMA Up", "TMA Up", plot1_color or core.colors().Blue, plot1_offset);
    plot1:setWidth(1);
    if (plot1_color == nil) then
        plot1:setStyle(core.LINE_NONE);
    else
        plot1:setStyle(core.LINE_SOLID);
    end
    plot2_color = core.colors().Blue;
    plot2_offset = (-vars["HalfLength"]);
    plot2 = instance:addStream("plot2", core.Line, "TMA Mid", "TMA Mid", plot2_color or core.colors().Blue, plot2_offset);
    plot2:setWidth(1);
    if (plot2_color == nil) then
        plot2:setStyle(core.LINE_NONE);
    else
        plot2:setStyle(core.LINE_SOLID);
    end
    plot3_color = core.colors().Blue;
    plot3_offset = (-vars["HalfLength"]);
    plot3 = instance:addStream("plot3", core.Line, "TMA Down", "TMA Down", plot3_color or core.colors().Blue, plot3_offset);
    plot3:setWidth(1);
    if (plot3_color == nil) then
        plot3:setStyle(core.LINE_NONE);
    else
        plot3:setStyle(core.LINE_SOLID);
    end
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        vars["GRP1"]:Clear();
        vars["pastTmac"]:Clear();
        vars["pastTmau"]:Clear();
        vars["pastTmad"]:Clear();
        vars["alertSignal"]:Clear();
        vars["GRP2"]:Clear();
        vars["colorBuffer"]:Clear();
        vars["GRP3"]:Clear();
        vars["PriceFunc1"].Clear();
        vars["PriceFunc2"].Clear();
        vars["PriceFunc3"].Clear();
    else
    end
    if not vars["GRP1"]:IsInitialized() then
        vars["GRP1"]:Set(period, "Parameters");
    end
    vars["tmac"] = nil;
    vars["tmau"] = nil;
    vars["tmad"] = nil;
    if not vars["pastTmac"]:IsInitialized() then
        vars["pastTmac"]:Set(period, nil);
    end
    if not vars["pastTmau"]:IsInitialized() then
        vars["pastTmau"]:Set(period, nil);
    end
    if not vars["pastTmad"]:IsInitialized() then
        vars["pastTmad"]:Set(period, nil);
    end
    vars["tmau_temp"] = nil;
    vars["tmac_temp"] = nil;
    vars["tmad_temp"] = nil;
    vars["point"] = SymInfo:GetPointValue(source);
    vars["last"] = false;
    if not vars["alertSignal"]:IsInitialized() then
        vars["alertSignal"]:Set(period, "EMPTY");
    end
    if not vars["GRP2"]:IsInitialized() then
        vars["GRP2"]:Set(period, "Colors");
    end
    if not vars["colorBuffer"]:IsInitialized() then
        vars["colorBuffer"]:Set(period, nil);
    end
    if not vars["GRP3"]:IsInitialized() then
        vars["GRP3"]:Set(period, "Alerts (Needs to create alert manually after every change)");
    end
    vars["a_allLines"] = Line:GetAll();
    if SafeGreater(Array:Size(vars["a_allLines"]), 0) then
        local for1_from = 0;
        local for1_to = SafeMinus(Array:Size(vars["a_allLines"]), 1);
        if for1_to ~= nil and for1_from ~= nil then
        local for1_step = for1_from < for1_to and 1 or -1;
        for p = for1_from, for1_to, for1_step do
            Line:Delete(Array:Get(vars["a_allLines"], p));
        end
        end
    end
    local for2_from = vars["HalfLength"];
    local for2_to = 0;
    if for2_to ~= nil and for2_from ~= nil then
    local for2_step = for2_from < for2_to and 1 or -1;
    for i = for2_from, for2_to, for2_step do
        vars["atr"] = 0.0;
        local for3_from = 0;
        local for3_to = vars["AtrPeriod"] - 1;
        if for3_to ~= nil and for3_from ~= nil then
        local for3_step = for3_from < for3_to and 1 or -1;
        for j = for3_from, for3_to, for3_step do
            vars["atr"] = SafePlus(vars["atr"], SafeMinus(SafeMax(SafeGetFloat(source.high, period - (i + j + 10)), SafeGetFloat(source.close, period - (i + j + 11))), SafeMin(SafeGetFloat(source.low, period - (i + j + 10)), SafeGetFloat(source.close, period - (i + j + 11)))));
        end
        end
        vars["atr"] = SafeDivide(vars["atr"], vars["AtrPeriod"]);
        vars["sum"] = SafeMultiply((vars["HalfLength"] + 1), vars["PriceFunc1"].GetValue(i, period, mode));
        vars["sumw"] = (vars["HalfLength"] + 1);
        vars["k"] = vars["HalfLength"];
        local for4_from = 1;
        local for4_to = vars["HalfLength"];
        if for4_to ~= nil and for4_from ~= nil then
        local for4_step = for4_from < for4_to and 1 or -1;
        for j = for4_from, for4_to, for4_step do
            vars["sum"] = SafePlus(vars["sum"], SafeMultiply(vars["k"], vars["PriceFunc2"].GetValue(i + j, period, mode)));
            vars["sumw"] = vars["sumw"] + vars["k"];
            if ((j <= i)) then
                vars["sum"] = SafePlus(vars["sum"], SafeMultiply(vars["k"], vars["PriceFunc3"].GetValue(i - j, period, mode)));
                vars["sumw"] = vars["sumw"] + vars["k"];
            end
            vars["k"] = vars["k"] - 1;
        end
        end
        vars["tmac"] = SafeDivide(vars["sum"], vars["sumw"]);
        vars["tmau"] = SafePlus(vars["tmac"], SafeMultiply(vars["AtrMultiplier"], vars["atr"]));
        vars["tmad"] = SafeMinus(vars["tmac"], SafeMultiply(vars["AtrMultiplier"], vars["atr"]));
        if (i == 0) then
            if (SafeGreater(SafeGetFloat(source.high, period), vars["tmau"]) and (vars["alertSignal"]:Get(period) ~= "UP")) then
                if (vars["crossUpInput"] == true) then
                    if "once_per_bar" == "all" or vars["alert1_last_date"] ~= source:date(period) then
                        vars["alert1_last_date"] = source:date(period);
                        signaler:SignalEx(nil, "Crossing up Band", period, source);
                    end
                end
                vars["alertSignal"]:Set(period, "UP");
            end
        end
        if (vars["pastTmac"]:Get(period) ~= 0.0) then
            if SafeGreater(vars["tmac"], vars["pastTmac"]:Get(period)) then
                vars["colorBuffer"]:Set(period, vars["colorUP"]);
            end
            if SafeLess(vars["tmac"], vars["pastTmac"]:Get(period)) then
                vars["colorBuffer"]:Set(period, vars["colorDOWN"]);
            end
        end
        vars["reboundD"] = 0.0;
        vars["reboundU"] = 0.0;
        vars["caution"] = 0.0;
        if (vars["pastTmac"]:Get(period) ~= 0.0) then
            if (SafeGreater(SafeGetFloat(source.high, period - (i + 1)), vars["pastTmau"]:Get(period)) and SafeGreater(SafeGetFloat(source.close, period - (i + 1)), SafeGetFloat(source.open, period - (i + 1))) and SafeLess(SafeGetFloat(source.close, period - (i)), SafeGetFloat(source.open, period - (i)))) then
                vars["reboundD"] = SafePlus(SafeGetFloat(source.high, period - (i)), SafeDivide(SafeMultiply(vars["AtrMultiplier"], vars["atr"]), 2));
                if (SafeGreater(SafeMinus(vars["tmac"], vars["pastTmac"]:Get(period)), vars["TMAangle"] * vars["point"])) then
                    vars["caution"] = vars["reboundD"] + 10 * vars["point"];
                end
            end
            if (SafeLess(SafeGetFloat(source.low, period - (i + 1)), vars["pastTmad"]:Get(period)) and SafeLess(SafeGetFloat(source.close, period - (i + 1)), SafeGetFloat(source.open, period - (i + 1))) and SafeGreater(SafeGetFloat(source.close, period - (i)), SafeGetFloat(source.open, period - (i)))) then
                vars["reboundU"] = SafeMinus(SafeGetFloat(source.low, period - (i)), SafeDivide(SafeMultiply(vars["AtrMultiplier"], vars["atr"]), 2));
                if (SafeGreater(SafeMinus(vars["pastTmac"]:Get(period), vars["tmac"]), vars["TMAangle"] * vars["point"])) then
                    vars["caution"] = vars["reboundU"] - 10 * vars["point"];
                end
            end
        end
        if period == source:size() - 1 and (i == vars["HalfLength"]) then
            vars["last"] = true;
            vars["tmau_temp"] = vars["tmau"];
            vars["tmac_temp"] = vars["tmac"];
            vars["tmad_temp"] = vars["tmad"];
        end
        if period == source:size() - 1 and (i < vars["HalfLength"]) then
            Line:New(period - (i + 1), vars["pastTmau"]:Get(period), period - (i), vars["tmau"]):SetColor(vars["colorBands"]):SetExtend("none"):SetStyle("dotted"):SetWidth(2):SetXLocInit("bar_index");
            Line:New(period - (i + 1), vars["pastTmac"]:Get(period), period - (i), vars["tmac"]):SetColor(vars["colorBuffer"]:Get(period)):SetExtend("none"):SetStyle("dotted"):SetWidth(2):SetXLocInit("bar_index");
            Line:New(period - (i + 1), vars["pastTmad"]:Get(period), period - (i), vars["tmad"]):SetColor(vars["colorBands"]):SetExtend("none"):SetStyle("dotted"):SetWidth(2):SetXLocInit("bar_index");
        end
        if (vars["reboundD"] ~= 0) then
            label_1_x = period - (i);
            Label:New(core.formatDate(Label:GetSerial(label_1_x, source, "bar_index") or 0) .. "_1", "1", label_1_x, vars["reboundD"]):SetText("▼"):SetColor(nil):SetTextColor(vars["colorDOWN"]):SetXLoc("bar_index");
            if (i == 0) and (vars["onArrowDownInput"] == true) then
                if "once_per_bar" == "all" or vars["alert2_last_date"] ~= source:date(period) then
                    vars["alert2_last_date"] = source:date(period);
                    signaler:SignalEx(nil, "Down arrow", period, source);
                end
            end
            if (vars["caution"] ~= 0) and (vars["cautionInput"] == true) then
                label_2_x = period - (i);
                Label:New(core.formatDate(Label:GetSerial(label_2_x, source, "bar_index") or 0) .. "_2", "2", label_2_x, vars["reboundD"]):SetColor(vars["colorUP"]):SetTextColor(nil):SetStyle("xcross"):SetSize("tiny"):SetXLoc("bar_index");
            end
        end
        if (vars["reboundU"] ~= 0) then
            label_3_x = period - (i);
            Label:New(core.formatDate(Label:GetSerial(label_3_x, source, "bar_index") or 0) .. "_3", "3", label_3_x, vars["reboundU"]):SetText("▲"):SetColor(nil):SetTextColor(vars["colorUP"]):SetXLoc("bar_index");
            if (i == 0) and (vars["onArrowUpInput"] == true) then
                if "once_per_bar" == "all" or vars["alert3_last_date"] ~= source:date(period) then
                    vars["alert3_last_date"] = source:date(period);
                    signaler:SignalEx(nil, "UP arrow", period, source);
                end
            end
            if (vars["caution"] ~= 0) and (vars["cautionInput"] == true) then
                label_4_x = period - (i);
                Label:New(core.formatDate(Label:GetSerial(label_4_x, source, "bar_index") or 0) .. "_4", "4", label_4_x, vars["reboundU"]):SetColor(vars["colorDOWN"]):SetTextColor(nil):SetStyle("xcross"):SetSize("tiny"):SetXLoc("bar_index");
            end
        end
        vars["pastTmac"]:Set(period, vars["tmac"]);
        vars["pastTmau"]:Set(period, vars["tmau"]);
        vars["pastTmad"]:Set(period, vars["tmad"]);
        if (period == source:size() - 1 ~= true) then
            break;
        end
    end
    end
    Plot:SetValueWithColor(plot1, period + plot1_offset, Triary(vars["last"], vars["tmau_temp"], vars["tmau"]), Graphics:GetColor(vars["colorBands"]));
    Plot:SetValueWithColor(plot2, period + plot2_offset, Triary(vars["last"], vars["tmac_temp"], vars["tmac"]), Graphics:GetColor(vars["colorBuffer"]:Get(period)));
    Plot:SetValueWithColor(plot3, period + plot3_offset, Triary(vars["last"], vars["tmad_temp"], vars["tmad"]), Graphics:GetColor(vars["colorBands"]));
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
SymInfo = {};
function SymInfo:GetMintick()
    return instance.source:pipSize();
end
function SymInfo:GetPointValue()
    return 1;
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
Line = {};
Line.AllLines = {};
function Line:GetAll()
    local array = Array:New();
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
Plot = {};
function Plot:SetValueWithColor(plot, period, value, color)
    if period < 0 then
        return;
    end
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if transp == 100 or clr == nil then
        plot:setNoData(period);
        return nil;
    end
    if Plot:SetValue(plot, period, value) then
        plot:setColor(period, clr)
    end
end
function Plot:SetValue(plot, period, value)
    if period < 0 then
        return;
    end
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if not value then
        plot:setNoData(period);
        return false;
    end
    plot[period] = value;
    return true;
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76480
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