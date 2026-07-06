-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74420

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
function Init()
    indicator:name("Volume Profile");
    indicator:description("Volume Profile");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Volume Lookback Depth [10-1000]", "", 200);
    indicator.parameters:addInteger("param2", "Number of Bars [10-500]", "", 500);
    indicator.parameters:addInteger("param3", "Bar Length Multiplier [10-100]", "", 50);
    indicator.parameters:addInteger("param4", "Bar Horizontal Offset [0-100]", "", 30);
    indicator.parameters:addInteger("param5", "Bar Width [1-20]", "", 2);
    indicator.parameters:addString("param6", "Delta Type", "", "Both");
    indicator.parameters:addStringAlternative("param6", "Both", "", "Both");
    indicator.parameters:addStringAlternative("param6", "Bullish", "", "Bullish");
    indicator.parameters:addStringAlternative("param6", "Bearish", "", "Bearish");
    indicator.parameters:addBoolean("param7", "Show POC Line", "", true);
    indicator.parameters:addColor("param8", "Bar Color", "", core.colors().Gray);
    indicator.parameters:addColor("param9", "POC Color", "", core.colors().Orange);
end

local source;
local vars = {};
local vp_first;
local time;
local f_setup_barFunc1_param1;
function Create_f_setup_bar(n)
    local local_vars = {};
    Line:Prepare(500);
    return {
        GetValue = function(period, mode)
            if time:first() > period - vars["vp_lookback"] then return; end
            x1 = (((((vp_VmaxId == (n:hasData(period) and n:tick(period) or nil))) and vars["vp_poc_show"])) and (math.max(time:tick(period - vars["vp_lookback"]), (vp_first:hasData(period) and vp_first:tick(period) or nil))) or ((SafePlus(core.host:execute("getServerTime") * 86400000, Round(SafeMultiply(vp_change, (SafeMinus(vars["vp_bar_offset"], vp_a_W:Get((n:hasData(period) and n:tick(period) or nil))))))))));
            ys = vp_a_P:Get((n:hasData(period) and n:tick(period) or nil));
            return Line:New(x1, ys, vp_x_loc, ys):SetColor(((((vp_VmaxId == (n:hasData(period) and n:tick(period) or nil))) and (vars["vp_poc_color"]) or (vars["vp_bar_color"])))):SetExtend("none"):SetStyle("solid"):SetWidth(vars["vp_bar_width"]):SetXLoc(x1, vp_x_loc, "bar_time");
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
    vars["vp_lookback"] = instance.parameters.param1;
    vars["vp_max_bars"] = instance.parameters.param2;
    vars["vp_bar_mult"] = instance.parameters.param3;
    vars["vp_bar_offset"] = instance.parameters.param4;
    vars["vp_bar_width"] = instance.parameters.param5;
    vars["vp_delta_type"] = instance.parameters.param6;
    vars["vp_poc_show"] = instance.parameters.param7;
    vars["vp_bar_color"] = instance.parameters.param8 + math.floor(60 / 100 * 255) * 16777216;
    vars["vp_poc_color"] = instance.parameters.param9 + math.floor(10 / 100 * 255) * 16777216;
    vp_first = instance:addInternalStream(0, 0);
    time = instance:addInternalStream(0, 0);
    f_setup_barFunc1_param1 = instance:addInternalStream(0, 0);
    vars["f_setup_barFunc1"] = Create_f_setup_bar(f_setup_barFunc1_param1);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        time[period] = source:date(period) * 86400000;
        vp_first_value = time:tick(period);
        if vp_first_value then
            vp_first[period] = vp_first_value;
        else
            vp_first:setNoData(period);
        end
    else
        time[period] = source:date(period) * 86400000;
        vp_first_value = (vp_first:hasData(period - 1) and vp_first:tick(period - 1) or nil);
        if vp_first_value then
            vp_first[period] = vp_first_value;
        else
            vp_first:setNoData(period);
        end
    end
    vp_Vmax = 0.0;
    vp_VmaxId = 0;
    vp_N_BARS = vars["vp_max_bars"];
    vp_a_P = Array:NewFloat((vp_N_BARS + 1), 0.0);
    vp_a_V = Array:NewFloat(vp_N_BARS, 0.0);
    vp_a_D = Array:NewFloat(vp_N_BARS, 0.0);
    vp_a_W = Array:NewInt(vp_N_BARS, 0);
    if source.high:first() > period - vars["vp_lookback"] then return; end
    vp_HH = mathex.max(source.high, core.rangeTo(period, vars["vp_lookback"]));
    if source.low:first() > period - vars["vp_lookback"] then return; end
    vp_LL = mathex.min(source.low, core.rangeTo(period, vars["vp_lookback"]));
    if period == source:size() - 1 then
        vp_HL = (SafeMinus(vp_HH, vp_LL)) / vp_N_BARS;
        for j = 1, (vp_N_BARS + 1), 1 do
            Array:Set(vp_a_P, (j - 1), (SafePlus(vp_LL, vp_HL * j)));
        end
        for i = 0, (vars["vp_lookback"] - 1), 1 do
            Dc = 0;
            Array:Fill(vp_a_D, 0.0, 0, nil);
            for j = 0, (vp_N_BARS - 1), 1 do
                Pj = vp_a_P:Get(j);
                if SafeLess(source.low:tick(period - i), Pj) and SafeGreater(source.high:tick(period - i), Pj) and ((((vars["vp_delta_type"] == "Bullish")) and ((source.close:tick(period - i) >= source.open:tick(period - i))) or (((((vars["vp_delta_type"] == "Bearish")) and ((source.close:tick(period - i) <= source.open:tick(period - i))) or (true)))))) then
                    Dj = vp_a_D:Get(j);
                    dDj = SafePlus(Dj, Nz(source.volume:tick(period - i)));
                    Array:Set(vp_a_D, j, dDj);
                    Dc = Dc + 1;
                end
            end
            for j = 0, (vp_N_BARS - 1), 1 do
                Vj = vp_a_V:Get(j);
                Dj = vp_a_D:Get(j);
                dVj = SafePlus(Vj, (((((Dc > 0))) and ((SafeDivide(Dj, Dc))) or (0.0))));
                Array:Set(vp_a_V, j, dVj);
            end
        end
        vp_Vmax = vp_a_V:Max();
        vp_VmaxId = Array:IndexOf(vp_a_V, vp_Vmax);
        for j = 0, (vp_N_BARS - 1), 1 do
            Vj = vp_a_V:Get(j);
            Aj = Round(SafeDivide(SafeMultiply(vars["vp_bar_mult"], Vj), vp_Vmax));
            Array:Set(vp_a_W, j, Aj);
        end
    end
    if (period == 0 or mode == core.UpdateAll) then
        vp_first_value = time:tick(period);
        if vp_first_value then
            vp_first[period] = vp_first_value;
        else
            vp_first:setNoData(period);
        end
    end
    vp_change = Change(time, period, 1);
    vp_x_loc = SafePlus(core.host:execute("getServerTime") * 86400000, Round(SafeMultiply(vp_change, vars["vp_bar_offset"])));
    if period == source:size() - 1 then
        for i = 0, (vp_N_BARS - 1), 1 do
            f_setup_barFunc1_param1_value = i;
            if f_setup_barFunc1_param1_value then
                f_setup_barFunc1_param1[period] = f_setup_barFunc1_param1_value;
            else
                f_setup_barFunc1_param1:setNoData(period);
            end
            vars["f_setup_barFunc1"].GetValue(period, mode);
        end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
Array = {};
function Array:Max(array)
    local maxVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if maxVal == nil or maxVal < val then
            maxVal = val;
        end
    end
    return maxVal;
end
function Array:Min(array)
    local minVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if minVal == nil or minVal > val then
            minVal = val;
        end
    end
    return minVal;
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
    for i = 1, size, 1 do
        newArray.arr[i] = initialValue;
    end
    function newArray:Push(item) self.arr[#self.arr + 1] = item; end
    function newArray:Get(index) return self.arr[index + 1]; end
    function newArray:Set(index, value) self.arr[index + 1] = value; end
    function newArray:Max() return Array:Max(self); end
    function newArray:Min() return Array:Min(self); end
    function newArray:Size() return #self.arr; end
    function newArray:Fill(value, from, to)
        if to == nil then
            to = #self.arr - 1;
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
    function newArray:Unshift(value)
        local nextValue = value;
        for i = 1, #self.arr, 1 do
            local current = self.arr[i];
            self.arr[i] = nextValue;
            nextValue = current;
        end
        self.arr[#self.arr + 1] = nextValue;
    end
    function newArray:Shift(value)
        table.remove(self.arr, 1);
        self.arr[#self.arr + 1] = nextValue;
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
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function Float(number)
    return number and number or 0.0;
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
    if defaulValue == nil then
        defaulValue = 0;
    end
    return value and value or defaultValue;
end
function Change(source, period, length)
    if period < length then
        return nil;
    end
    if not source:hasData(period) or not source:hasData(period - length) then
        return nil;
    end
    return source[period] - source[period - length];
end
Graphics = {};
Graphics.NextId = 2;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
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
    if Graphics.Fonts[1] ~= nil then
        return Graphics.Fonts[1].Id;
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    context:createFont(newFont.Id, "Arial", 0, context:pointsToPixels(10), context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Color(color)
    if color == nil then
        return core.colors().Black + 4294967296;
    end
    return color;
end
Line = {};
Line.AllLines = {};
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
        _, x1 = context:positionOfBar(x);
        return x1;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil or self.X1 == nil or self.X2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        x1 = self:converXToPoints(context, self.X1);
        x2 = self:converXToPoints(context, self.X2);
        _, y1 = context:pointOfPrice(self.Y1);
        _, y2 = context:pointOfPrice(self.Y2);
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:right() + c;
            context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
        end
        if self.Extend == "left" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:left() + c;
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