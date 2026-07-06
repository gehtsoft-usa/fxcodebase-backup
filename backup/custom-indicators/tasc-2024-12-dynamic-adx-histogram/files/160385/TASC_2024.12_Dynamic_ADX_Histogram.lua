//Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76277

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+
local vars = {};
function Init()
    vars["title"] = "TASC 2024.12 Dynamic ADX Histogram";
    indicator:name(vars["title"]);
    indicator:description(vars["title"]);
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("param1", "ADX Length", "", 10, 1);
    indicator.parameters:addDouble("param2", "Low Threshold", "", 15, 0);
    indicator.parameters:addDouble("param3", "High Threshold", "", 40, 0);
    indicator.parameters:addInteger("param4", "DMI Smoothing Length", "", 1, 1);
    vars["gu"] = "Colors, Up:";
    indicator.parameters:addColor("param5", vars["gu"], "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 255, 255), 0)));
    indicator.parameters:addColor("param6", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 139, 139), 0)));
    indicator.parameters:addColor("param7", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(9, 255, 0), 0)));
    indicator.parameters:addColor("param8", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(4, 128, 0), 0)));
    vars["gn"] = "Neutral:";
    indicator.parameters:addColor("param9", vars["gn"], "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(56, 56, 56), 0)));
    indicator.parameters:addColor("param10", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(0, 0, 0), 0)));
    vars["gd"] = "Down:";
    indicator.parameters:addColor("param11", vars["gd"], "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(104, 0, 0), 0)));
    indicator.parameters:addColor("param12", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 0, 0), 0)));
    indicator.parameters:addColor("param13", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(92, 0, 31), 0)));
    indicator.parameters:addColor("param14", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 0, 170), 0)));
end

local source;
local plot1;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["title"] = "TASC 2024.12 Dynamic ADX Histogram";
    vars["stitle"] = "DADX";
    vars["ADX_Length"] = instance.parameters.param1;
    vars["ADX_THLo"] = instance.parameters.param2;
    vars["ADX_THHi"] = instance.parameters.param3;
    vars["ADX_Smooth"] = instance.parameters.param4;
    vars["gu"] = "Colors, Up:";
    vars["gn"] = "Neutral:";
    vars["gd"] = "Down:";
    vars["col_OBUp"] = Graphics:AddTransparency(instance.parameters.param5, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(0, 255, 255), 0)));
    vars["col_OBWUp"] = Graphics:AddTransparency(instance.parameters.param6, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(0, 139, 139), 0)));
    vars["col_Up"] = Graphics:AddTransparency(instance.parameters.param7, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(9, 255, 0), 0)));
    vars["col_WUp"] = Graphics:AddTransparency(instance.parameters.param8, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(4, 128, 0), 0)));
    vars["col_NUp"] = Graphics:AddTransparency(instance.parameters.param9, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(56, 56, 56), 0)));
    vars["col_Ndn"] = Graphics:AddTransparency(instance.parameters.param10, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(0, 0, 0), 0)));
    vars["col_Wdn"] = Graphics:AddTransparency(instance.parameters.param11, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(104, 0, 0), 0)));
    vars["col_dn"] = Graphics:AddTransparency(instance.parameters.param12, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 0, 0), 0)));
    vars["col_OSWdn"] = Graphics:AddTransparency(instance.parameters.param13, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(92, 0, 31), 0)));
    vars["col_OSdn"] = Graphics:AddTransparency(instance.parameters.param14, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 0, 170), 0)));
    local profile = core.indicators:findIndicator("PINESCRIPT DMI");
    assert(profile ~= nil, "Please, download and install " .. "PINESCRIPT DMI" .. ".LUA indicator");
    vars["PINESCRIPT DMI1"] = core.indicators:create("PINESCRIPT DMI", source, vars["ADX_Length"], vars["ADX_Length"]);
    vars["DIA"] = instance:addInternalStream(0, 0);
    vars["MVA1_source"] = instance:addInternalStream(0, 0);
    vars["MVA1"] = core.indicators:create("MVA", vars["MVA1_source"], vars["ADX_Smooth"]);
    vars["MVA2_source"] = instance:addInternalStream(0, 0);
    vars["MVA2"] = core.indicators:create("MVA", vars["MVA2_source"], vars["ADX_Smooth"]);
    vars["col"] = Color(nil);
    vars["osc"] = nil;
    plot1 = instance:addStream("plot1", core.Bar, "ADXO", "ADXO", core.colors().Blue, 0, 0);
    plot1:setWidth(1);
    plot1:addLevel(vars["ADX_THHi"], core.LINE_SOLID, 1, core.colors().Blue);
    plot1:addLevel(vars["ADX_THLo"], core.LINE_SOLID, 1, core.colors().Blue);
    plot1:addLevel(0, core.LINE_SOLID, 1, core.colors().Blue);
    plot1:addLevel((-vars["ADX_THLo"]), core.LINE_SOLID, 1, core.colors().Blue);
    plot1:addLevel((-vars["ADX_THHi"]), core.LINE_SOLID, 1, core.colors().Blue);
end

function Update(period, mode)
    vars["PINESCRIPT DMI1"]:update(mode);
    SafeSetFloat(vars["DIA"], period, DIA_ret_val);
    DIP_ret_val, DIN_ret_val, DIA_ret_val = vars["PINESCRIPT DMI1"].DIP:tick(period), vars["PINESCRIPT DMI1"].DIM:tick(period), vars["PINESCRIPT DMI1"].ADX:tick(period);
    vars["DIP"] = DIP_ret_val;
    vars["DIN"] = DIN_ret_val;
    NADX = SafeNegative(SafeGetFloat(vars["DIA"], period));
    SafeSetFloat(vars["MVA1_source"], period, vars["DIP"]);
    vars["MVA1"]:update(mode);
    SP = vars["MVA1"].DATA:tick(period);
    SafeSetFloat(vars["MVA2_source"], period, vars["DIN"]);
    vars["MVA2"]:update(mode);
    SM = vars["MVA2"].DATA:tick(period);
    NET = SafeMinus(SP, SM);
    isDIAup = SafeGreater(SafeGetFloat(vars["DIA"], period), SafeGetFloat(vars["DIA"], period - 1));
    isDIAdn = SafeLess(SafeGetFloat(vars["DIA"], period), SafeGetFloat(vars["DIA"], period - 1));
    if isDIAup then
        vars["col"] = vars["col_NUp"];
    end
    if isDIAdn then
        vars["col"] = vars["col_Ndn"];
    end
    if SafeGE(NET, 0) then
        if SafeGE(SafeGetFloat(vars["DIA"], period), vars["ADX_THHi"]) then
            if isDIAup then
                vars["col"] = vars["col_OBUp"];
            end
            if isDIAdn then
                vars["col"] = vars["col_OBWUp"];
            end
        end
        if SafeGE(SafeGetFloat(vars["DIA"], period), vars["ADX_THLo"]) and SafeLE(SafeGetFloat(vars["DIA"], period), vars["ADX_THHi"]) then
            if isDIAup then
                vars["col"] = vars["col_Up"];
            end
            if isDIAdn then
                vars["col"] = vars["col_WUp"];
            end
        end
        vars["osc"] = SafeGetFloat(vars["DIA"], period);
    elseif SafeLess(NET, 0) then
        if SafeGE(SafeGetFloat(vars["DIA"], period), vars["ADX_THHi"]) then
            if isDIAup then
                vars["col"] = vars["col_OSdn"];
            end
            if isDIAdn then
                vars["col"] = vars["col_OSWdn"];
            end
        end
        if SafeGE(SafeGetFloat(vars["DIA"], period), vars["ADX_THLo"]) and SafeLE(SafeGetFloat(vars["DIA"], period), vars["ADX_THHi"]) then
            if isDIAup then
                vars["col"] = vars["col_dn"];
            end
            if isDIAdn then
                vars["col"] = vars["col_Wdn"];
            end
        end
        vars["osc"] = NADX;
    end
    plot1[period] = vars["osc"];
    plot1:setColor(period, vars["col"]);
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
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
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
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or not stream:hasData(period) then
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
    if stream == nil then
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76277

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+