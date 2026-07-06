-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76402
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
    indicator:name("Radius Trend [ChartPrime]");
    indicator:description("Radius Trend [ChartPrime]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addDouble("param1", "Radius Step", "", 0.15);
    indicator.parameters:addDouble("param2", "Start Points Distance", "", 2);
	
	indicator.parameters:addColor("color1", "1. Line Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color2", "2. Line Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color3", "3. Line Color","", core.rgb(0, 0, 255));	
	indicator.parameters:addColor("color4", "Channel Color","", core.rgb(128, 128, 128));	
end

local source;
local plot1;
local plot2;
local plot3;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["step"] = instance.parameters.param1;
    vars["multi"] = instance.parameters.param2;
    vars["trend"] = instance:addInternalStream(0, 0);
    vars["multi1"] = instance:addInternalStream(0, 0);
    vars["multi2"] = instance:addInternalStream(0, 0);
    vars["band"] = instance:addInternalStream(0, 0);
    vars["MVA1_source"] = instance:addInternalStream(0, 0);
    vars["MVA1"] = core.indicators:create("MVA", vars["MVA1_source"], 100);
    vars["MVA2_source"] = instance:addInternalStream(0, 0);
    vars["MVA2"] = core.indicators:create("MVA", vars["MVA2_source"], 100);
    vars["!Change1_trend"] = instance:addInternalStream(0, 0);
    vars["!Change2_trend"] = instance:addInternalStream(0, 0);
    vars["n"] = 3;
    vars["MVA3"] = core.indicators:create("MVA", vars["band"], vars["n"]);
    vars["MVA4_source"] = instance:addInternalStream(0, 0);
    vars["MVA4"] = core.indicators:create("MVA", vars["MVA4_source"], vars["n"]);
    vars["MVA5_source"] = instance:addInternalStream(0, 0);
    vars["MVA5"] = core.indicators:create("MVA", vars["MVA5_source"], vars["n"]);
    plot1 = instance:addStream("plot1", core.Line, "", "", instance.parameters.color1, 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    vars["!Change3_trend"] = instance:addInternalStream(0, 0);
    plot2 = instance:addStream("plot2", core.Line, "", "", instance.parameters.color2, 0, 0);
    plot2:setWidth(1);
    vars["p1"] = plot2;
    vars["MVA6_source"] = instance:addInternalStream(0, 0);
    vars["MVA6"] = core.indicators:create("MVA", vars["MVA6_source"], 20);
    plot3 = instance:addStream("plot3", core.Line, "", "", instance.parameters.color3, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    vars["p2"] = plot3;
    vars["MVA7_source"] = instance:addInternalStream(0, 0);
    vars["MVA7"] = core.indicators:create("MVA", vars["MVA7_source"], 20);
    vars["channel1_top"] = instance:addStream("channel1_top", core.Line, "", "", instance.parameters.color4, 0, 0);
    vars["channel1_bottom"] = instance:addInternalStream(0, 0);
    channel1_color = instance.parameters.color4;
    instance:createChannelGroup("channel1", "channel1", vars["channel1_top"], vars["channel1_bottom"], channel1_color, 50, true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        SafeSetFloat(vars["multi1"], period, 0.);
        SafeSetFloat(vars["multi2"], period, 0.);
        SafeSetFloat(vars["band"], period, 0.);
    else
        SafeSetFloat(vars["multi1"], period, SafeGetFloat(vars["multi1"], period - 1));
        SafeSetFloat(vars["multi2"], period, SafeGetFloat(vars["multi2"], period - 1));
        SafeSetFloat(vars["band"], period, SafeGetFloat(vars["band"], period - 1));
    end
    SafeSetBool(vars["trend"], period, nil);
    vars["n"] = 3;
    SafeSetFloat(vars["MVA1_source"], period, math.abs(source.high:tick(period) - source.low:tick(period)));
    vars["MVA1"]:update(mode);
    vars["distance"] = SafeMultiply(vars["MVA1"].DATA:tick(period), vars["multi"]);
    SafeSetFloat(vars["MVA2_source"], period, math.abs(source.high:tick(period) - source.low:tick(period)));
    vars["MVA2"]:update(mode);
    vars["distance1"] = SafeMultiply(vars["MVA2"].DATA:tick(period), 0.2);
    if (period == 101) then
        SafeSetBool(vars["trend"], period, true);
        SafeSetFloat(vars["band"], period, source.low:tick(period) * 0.8);
    end
    if SafeLess(source.close:tick(period), SafeGetFloat(vars["band"], period)) then
        SafeSetBool(vars["trend"], period, false);
    end
    if SafeGreater(source.close:tick(period), SafeGetFloat(vars["band"], period)) then
        SafeSetBool(vars["trend"], period, true);
    end
    SafeSetBool(vars["!Change1_trend"], period, SafeGetBool(vars["trend"], period));
    if (SafeGetBool(vars["trend"], period - 1) == false) and Change(vars["!Change1_trend"], 1, period) then
        SafeSetFloat(vars["band"], period, SafeMinus(source.low:tick(period), vars["distance"]));
    end
    SafeSetBool(vars["!Change2_trend"], period, SafeGetBool(vars["trend"], period));
    if (SafeGetBool(vars["trend"], period - 1) == true) and Change(vars["!Change2_trend"], 1, period) then
        SafeSetFloat(vars["band"], period, SafePlus(source.high:tick(period), vars["distance"]));
    end
    if ((period % vars["n"]) == 0) and SafeGetBool(vars["trend"], period) then
        SafeSetFloat(vars["multi1"], period, 0);
        SafeSetFloat(vars["multi2"], period, SafeGetFloat(vars["multi2"], period) + vars["step"]);
        SafeSetFloat(vars["band"], period, SafePlus(SafeGetFloat(vars["band"], period), SafeMultiply(vars["distance1"], SafeGetFloat(vars["multi2"], period))));
    end
    if ((period % vars["n"]) == 0) and not (SafeGetBool(vars["trend"], period)) then
        SafeSetFloat(vars["multi1"], period, SafeGetFloat(vars["multi1"], period) + vars["step"]);
        SafeSetFloat(vars["multi2"], period, 0);
        SafeSetFloat(vars["band"], period, SafeMinus(SafeGetFloat(vars["band"], period), SafeMultiply(vars["distance1"], SafeGetFloat(vars["multi1"], period))));
    end
    vars["MVA3"]:update(mode);
    vars["Sband"] = vars["MVA3"].DATA:tick(period);
    vars["color"] = Triary(SafeGetBool(vars["trend"], period), Graphics:AddTransparency(core.rgb(84, 182, 212), 0), Graphics:AddTransparency(core.rgb(207, 43, 43), 0));
    SafeSetFloat(vars["MVA4_source"], period, SafePlus(SafeGetFloat(vars["band"], period), SafeMultiply(vars["distance"], 0.5)));
    vars["MVA4"]:update(mode);
    vars["band_upper"] = vars["MVA4"].DATA:tick(period);
    SafeSetFloat(vars["MVA5_source"], period, SafeMinus(SafeGetFloat(vars["band"], period), SafeMultiply(vars["distance"], 0.5)));
    vars["MVA5"]:update(mode);
    vars["band_lower"] = vars["MVA5"].DATA:tick(period);
    vars["band1"] = Triary(SafeGetBool(vars["trend"], period), vars["band_upper"], vars["band_lower"]);
    plot1[period] = vars["band1"];
    --plot1:setColor(period, Triary(((period % 2) == 0), core.COLOR_LABEL + math.floor(50 / 100 * 255) * 16777216, nil));
    SafeSetBool(vars["!Change3_trend"], period, SafeGetBool(vars["trend"], period));
    plot2[period] = Triary(Change(vars["!Change3_trend"], 1, period), nil, vars["Sband"]);
    SafeSetFloat(vars["MVA6_source"], period, (source.high:tick(period) + source.low:tick(period)) / 2);
    vars["MVA6"]:update(mode);
    plot3[period] = vars["MVA6"].DATA:tick(period);
    SafeSetFloat(vars["MVA7_source"], period, (source.high:tick(period) + source.low:tick(period)) / 2);
    vars["MVA7"]:update(mode);
    vars["channel1_top"][period] = vars["p1"][period];
    vars["channel1_bottom"][period] = vars["p2"][period];
    channel1_avg = (vars["channel1_top"][period] + vars["channel1_bottom"][period]) / 2;
    vars["channel1_top_value"] = SafeGetFloat(vars["band"], period);
    vars["channel1_bottom_value"] = vars["MVA7"].DATA:tick(period);
    --if (channel1_avg <= vars["channel1_top_value"] and channel1_avg >= vars["channel1_bottom_value"]) then
     --   vars["channel1_top"]:setColor(period, Color:FromGradient(channel1_avg, vars["channel1_bottom_value"], vars["channel1_top_value"], nil, vars["color"] + math.floor(60 / 100 * 255) * 16777216));
    --end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
function Change(source, length, period)
    if period < length then
        return nil;
    end
    if not source:hasData(period) or not source:hasData(period - length) then
        return nil;
    end
    return source[period] - source[period - length];
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
Color = {};
function Color:GetR(color)
    return color % 256;
end
function Color:GetG(color)
    local R = Color:GetR(color);
    return ((color - R) / 256) % 256;
end
function Color:GetB(color)
    local R = Color:GetR(color);
    local G = Color:GetG(color);
    return ((color - R - G*256) /(256 * 256)) % 256;
end
function Color:GetRGB(color)
    local R = Color:GetR(color);
    local G = Color:GetG(color);
    return R, G, ((color - R - G*256) /(256 * 256)) % 256;
end
function Color:FromGradient(value, bottom_value, top_value, bottom_color, top_color)
    if bottom_color == nil then
        if top_color == nil then
            return nil;
        end
        bottom_color =  Graphics:AddTransparency(Graphics:GetColor(top_color), 0);
    end
    if top_color == nil then
        top_color =  Graphics:AddTransparency(Graphics:GetColor(bottom_color), 0);
    end
    if (value == nil or top_value == nil) then
        return bottom_color;
    end
    if (bottom_value == nil) then
        return top_color;
    end
    local range = top_value - bottom_value;
    local rate = (value - bottom_value) / range;
    if (rate > 1) then
        return bottom_color;
    end
    if (rate < 0) then
        return top_color;
    end
    
    local bottomR, bottomG, bottomB = Color:GetRGB(bottom_color);
    local topR, topG, topB = Color:GetRGB(top_color);
    return core.rgb(bottomR + math.floor(rate * (topR - bottomR)), 
        bottomG + math.floor(rate * (topG - bottomG)), 
        bottomB + math.floor(rate * (topB - bottomB)), 0);
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76402
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