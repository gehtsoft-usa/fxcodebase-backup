-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75541

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

local vars = {};
function Init()
    indicator:name("SuperTrend Extended");
    indicator:description("SuperTrend Extended");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "1 = use ATR, 2 = Use standard deviation, 3 = Use standard error", "", 1);
end

local source;
local plot1;
local plot2;
local plot3;
local plot4;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["multiplier"] = 2.236;
    vars["period"] = 66;
    vars["type_"] = instance.parameters.param1;
    vars["midperiod"] = 10;
    vars["ATR1"] = core.indicators:create("ATR", source, vars["period"]);
    local profile = core.indicators:findIndicator("VARIANCE");
    assert(profile ~= nil, "Please, download and install " .. "VARIANCE" .. ".LUA indicator");
    vars["VARIANCE1"] = core.indicators:create("VARIANCE", source.close, vars["period"]);
    vars["trend"] = instance:addInternalStream(0, 0);
    vars["up"] = instance:addInternalStream(0, 0);
    vars["dn"] = instance:addInternalStream(0, 0);
    plot1 = instance:createTextOutput("plot1", "", "Wingdings", 12, core.H_Center, core.V_Top, core.colors().Blue);
    plot2 = instance:createTextOutput("plot2", "", "Wingdings", 12, core.H_Center, core.V_Top, core.colors().Blue);
    plot3 = instance:addStream("plot3", core.Line, "SuperTrend Extended 1", "SuperTrend Extended 1", core.rgb(0, 191, 255) + math.floor(50 / 100 * 255) * 16777216, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    vars["p1"] = plot3;
    plot4 = instance:addStream("plot4", core.Line, "SuperTrend Extended 2", "SuperTrend Extended 2", core.rgb(0, 191, 255) + math.floor(50 / 100 * 255) * 16777216, 0, 0);
    plot4:setWidth(1);
    plot4:setStyle(core.LINE_SOLID);
    vars["p2"] = plot4;
    channel1_color = core.colors().Blue;
    instance:createChannelGroup("channel1", "channel1", vars["p1"], vars["p2"], Graphics:GetColor(channel1_color), 50, true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        SafeSetFloat(vars["trend"], period, 1);
    else
        SafeSetFloat(vars["trend"], period, SafeGetFloat(vars["trend"], period - 1));
    end
    vars["ATR1"]:update(mode);
    if source.close:first() > period - (vars["period"]) then return; end
    vars["VARIANCE1"]:update(mode);
    moy = Triary((vars["type_"] == 1), vars["ATR1"].DATA:tick(period), Triary((vars["type_"] == 2), mathex.stdev(source.close, core.rangeTo(period, vars["period"])), Triary((vars["type_"] == 3), vars["VARIANCE1"].DATA:tick(period), nil)));
    if source.high:first() > period - (vars["midperiod"]) then return; end
    if source.low:first() > period - (vars["midperiod"]) then return; end
    price = SafeDivide((SafePlus(mathex.max(source.high, core.rangeTo(period, vars["midperiod"])), mathex.min(source.low, core.rangeTo(period, vars["midperiod"])))), 2);
    SafeSetFloat(vars["up"], period, SafePlus(price, vars["multiplier"] * moy));
    SafeSetFloat(vars["dn"], period, SafeMinus(price, vars["multiplier"] * moy));
    if vars["up"]:first() > period - (1) then return; end
    if vars["dn"]:first() > period - (1) then return; end
    if SafeGreater(source.close:tick(period), SafeGetFloat(vars["up"], period - 1)) then
        SafeSetFloat(vars["trend"], period, 1);
    elseif SafeLess(source.close:tick(period), SafeGetFloat(vars["dn"], period - 1)) then
        SafeSetFloat(vars["trend"], period, (-1));
    end
    if vars["trend"]:first() > period - (1) then return; end
    flag = (SafeGetFloat(vars["trend"], period) < 0) and SafeGreater(SafeGetFloat(vars["trend"], period - 1), 0);
    if vars["trend"]:first() > period - (1) then return; end
    flagh = (SafeGetFloat(vars["trend"], period) > 0) and SafeLess(SafeGetFloat(vars["trend"], period - 1), 0);
    if vars["dn"]:first() > period - (1) then return; end
    if (SafeGetFloat(vars["trend"], period) > 0) and SafeLess(SafeGetFloat(vars["dn"], period), SafeGetFloat(vars["dn"], period - 1)) then
        if vars["dn"]:first() > period - (1) then return; end
        SafeSetFloat(vars["dn"], period, SafeGetFloat(vars["dn"], period - 1));
    end
    if vars["up"]:first() > period - (1) then return; end
    if (SafeGetFloat(vars["trend"], period) < 0) and SafeGreater(SafeGetFloat(vars["up"], period), SafeGetFloat(vars["up"], period - 1)) then
        if vars["up"]:first() > period - (1) then return; end
        SafeSetFloat(vars["up"], period, SafeGetFloat(vars["up"], period - 1));
    end
    if flag then
        SafeSetFloat(vars["up"], period, SafePlus(price, vars["multiplier"] * moy));
    end
    if flagh then
        SafeSetFloat(vars["dn"], period, SafeMinus(price, vars["multiplier"] * moy));
    end
    mysupertrend = Triary((SafeGetFloat(vars["trend"], period) == 1), SafeGetFloat(vars["dn"], period), SafeGetFloat(vars["up"], period));
    offset = Triary((SafeGetFloat(vars["trend"], period) == 1), moy, (-moy));
    clr = Triary((SafeGetFloat(vars["trend"], period) == 1), core.rgb(0, 191, 255) + math.floor(50 / 100 * 255) * 16777216, core.rgb(255, 69, 0) + math.floor(50 / 100 * 255) * 16777216);
    if vars["trend"]:first() > period - (1) then return; end
    PlotShape:SetValue(plot1, period, source, (SafeGetFloat(vars["trend"], period) == 1) and (SafeGetFloat(vars["trend"], period - 1) ~= 1), "\233", "", "abovebar");
    if vars["trend"]:first() > period - (1) then return; end
    PlotShape:SetValue(plot2, period, source, (SafeGetFloat(vars["trend"], period) == (-1)) and (SafeGetFloat(vars["trend"], period - 1) ~= (-1)), "\234", "", "abovebar");
    plot3[period] = mysupertrend;
    plot3:setColor(period, core.rgb(0, 191, 255) + math.floor(50 / 100 * 255) * 16777216);
    plot4[period] = SafePlus(mysupertrend, offset);
    plot4:setColor(period, core.rgb(0, 191, 255) + math.floor(50 / 100 * 255) * 16777216);
    vars["p1"]:setColor(period, clr);
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

PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location)
    if not value then
        plot:setNoData(period);
        return;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label);
        return;
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label);
        return;
    end
    plot:set(period, value, text, label);
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

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75541

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 