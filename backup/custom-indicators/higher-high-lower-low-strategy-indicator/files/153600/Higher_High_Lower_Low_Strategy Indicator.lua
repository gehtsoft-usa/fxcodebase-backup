-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74417

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
    indicator:name("Higher High Lower Low Strategy");
    indicator:description("Higher High Lower Low Strategy");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Left Bars", "", 5);
    indicator.parameters:addInteger("param2", "Right Bars", "", 5);
    indicator.parameters:addBoolean("param3", "Support/Resistance", "", true);
    indicator.parameters:addColor("param4", "", "", core.colors().Lime);
    indicator.parameters:addColor("param5", "", "", core.colors().Red);
    indicator.parameters:addString("param6", "Line Style/Width", "", "dotted");
    indicator.parameters:addStringAlternative("param6", "Solid", "", "solid");
    indicator.parameters:addStringAlternative("param6", "Dashed", "", "dashed");
    indicator.parameters:addStringAlternative("param6", "Dotted", "", "dotted");
    indicator.parameters:addInteger("param7", "", "", 3);
    indicator.parameters:addBoolean("param8", "Change Bar Color", "", true);
    indicator.parameters:addColor("param9", "", "", core.colors().Blue);
    indicator.parameters:addColor("param10", "", "", core.colors().Black);
end

local source;
local vars = {};
local plot1;
local plot2;
local plot3;
local plot4;
local res;
local sup;
local plot5_open;
local plot5_high;
local plot5_low;
local plot5_close;
function Create_findprevious()
    local local_vars = {};
    hl = instance:addInternalStream(0, 0);
    zz = instance:addInternalStream(0, 0);
    return {
        GetValue = function(period, mode)
            ehl = ((((hl:hasData(period) and hl:tick(period) or nil) == 1)) and ((-1)) or (1));
            loc1 = 0.0;
            loc2 = 0.0;
            loc3 = 0.0;
            loc4 = 0.0;
            xx = 0;
            for x = 1, 1000, 1 do
                if hl:first() > period - x then return; end
                if zz:first() > period - x then return; end
                if ((hl:hasData(period - x) and hl:tick(period - x) or nil) == ehl) and not ((zz:hasData(period - x) and zz:tick(period - x) or nil) == nil) then
                    if zz:first() > period - x then return; end
                    loc1 = (zz:hasData(period - x) and zz:tick(period - x) or nil);
                    xx = x + 1;
                    break;
                end
            end
            ehl = (hl:hasData(period) and hl:tick(period) or nil);
            for x = xx, 1000, 1 do
                if hl:first() > period - x then return; end
                if zz:first() > period - x then return; end
                if ((hl:hasData(period - x) and hl:tick(period - x) or nil) == ehl) and not ((zz:hasData(period - x) and zz:tick(period - x) or nil) == nil) then
                    if zz:first() > period - x then return; end
                    loc2 = (zz:hasData(period - x) and zz:tick(period - x) or nil);
                    xx = x + 1;
                    break;
                end
            end
            ehl = ((((hl:hasData(period) and hl:tick(period) or nil) == 1)) and ((-1)) or (1));
            for x = xx, 1000, 1 do
                if hl:first() > period - x then return; end
                if zz:first() > period - x then return; end
                if ((hl:hasData(period - x) and hl:tick(period - x) or nil) == ehl) and not ((zz:hasData(period - x) and zz:tick(period - x) or nil) == nil) then
                    if zz:first() > period - x then return; end
                    loc3 = (zz:hasData(period - x) and zz:tick(period - x) or nil);
                    xx = x + 1;
                    break;
                end
            end
            ehl = (hl:hasData(period) and hl:tick(period) or nil);
            for x = xx, 1000, 1 do
                if hl:first() > period - x then return; end
                if zz:first() > period - x then return; end
                if ((hl:hasData(period - x) and hl:tick(period - x) or nil) == ehl) and not ((zz:hasData(period - x) and zz:tick(period - x) or nil) == nil) then
                    if zz:first() > period - x then return; end
                    loc4 = (zz:hasData(period - x) and zz:tick(period - x) or nil);
                    break;
                end
            end
            return loc1, loc2, loc3, loc4;
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
    vars["lb"] = instance.parameters.param1;
    vars["rb"] = instance.parameters.param2;
    vars["showsupres"] = instance.parameters.param3;
    vars["supcol"] = instance.parameters.param4;
    vars["rescol"] = instance.parameters.param5;
    vars["srlinestyle"] = instance.parameters.param6;
    vars["srlinewidth"] = instance.parameters.param7;
    vars["changebarcol"] = instance.parameters.param8;
    vars["bcolup"] = instance.parameters.param9;
    vars["bcoldn"] = instance.parameters.param10;
    vars["__pivothigh1"] = CreatePivotHigh(source.high, vars["lb"], vars["rb"]);
    vars["__pivotlow1"] = CreatePivotLow(source.low, vars["lb"], vars["rb"]);
    vars["__valuewhen1"] = CreateValueWhen();
    vars["__valuewhen2"] = CreateValueWhen();
    vars["__valuewhen3"] = CreateValueWhen();
    vars["__valuewhen4"] = CreateValueWhen();
    vars["__valuewhen5"] = CreateValueWhen();
    vars["__valuewhen6"] = CreateValueWhen();
    vars["__valuewhen7"] = CreateValueWhen();
    vars["__valuewhen8"] = CreateValueWhen();
    vars["findpreviousFunc1"] = Create_findprevious();
    plot1 = instance:createTextOutput("plot1", "Higher Low", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Lime);
    plot2 = instance:createTextOutput("plot2", "Higher High", "Arial", 12, core.H_Center, core.V_Top, core.colors().Lime);
    plot3 = instance:createTextOutput("plot3", "Lower Low", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Red);
    plot4 = instance:createTextOutput("plot4", "Lower High", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red);
    res = instance:addInternalStream(0, 0);
    sup = instance:addInternalStream(0, 0);
    plot5_open = instance:addStream("plot5_open", core.Line, "Open", "open", core.rgb(0, 0, 0), 0)
    plot5_high = instance:addStream("plot5_high", core.Line, "High", "high", core.rgb(0, 0, 0), 0)
    plot5_low = instance:addStream("plot5_low", core.Line, "Low", "low", core.rgb(0, 0, 0), 0)
    plot5_close = instance:addStream("plot5_close", core.Line, "Close", "close", core.rgb(0, 0, 0), 0)
    instance:createCandleGroup("plot5", "plot5", plot5_open, plot5_high, plot5_low, plot5_close);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        vars["resline"] = nil;
        vars["supline"] = nil;
    else
    end
    ph = vars["__pivothigh1"]:get(period);
    pl = vars["__pivotlow1"]:get(period);
    hl_value = ((ph) and (1) or (((pl) and ((-1)) or (nil))));
    if hl_value then
        hl[period] = hl_value;
    else
        hl:setNoData(period);
    end
    zz_value = ((ph) and (ph) or (((pl) and (pl) or (nil))));
    if zz_value then
        zz[period] = zz_value;
    else
        zz:setNoData(period);
    end
    zz_value = ((pl and ((hl:hasData(period) and hl:tick(period) or nil) == (-1)) and (vars["__valuewhen1"]:set(period, (hl:hasData(period) and hl:tick(period) or nil), (hl:hasData(period) and hl:tick(period) or nil), 1) == (-1)) and SafeGreater(pl, vars["__valuewhen2"]:set(period, (zz:hasData(period) and zz:tick(period) or nil), (zz:hasData(period) and zz:tick(period) or nil), 1))) and (nil) or ((zz:hasData(period) and zz:tick(period) or nil)));
    if zz_value then
        zz[period] = zz_value;
    else
        zz:setNoData(period);
    end
    zz_value = ((ph and ((hl:hasData(period) and hl:tick(period) or nil) == 1) and (vars["__valuewhen3"]:set(period, (hl:hasData(period) and hl:tick(period) or nil), (hl:hasData(period) and hl:tick(period) or nil), 1) == 1) and SafeLess(ph, vars["__valuewhen4"]:set(period, (zz:hasData(period) and zz:tick(period) or nil), (zz:hasData(period) and zz:tick(period) or nil), 1))) and (nil) or ((zz:hasData(period) and zz:tick(period) or nil)));
    if zz_value then
        zz[period] = zz_value;
    else
        zz:setNoData(period);
    end
    hl_value = ((((hl:hasData(period) and hl:tick(period) or nil) == (-1)) and (vars["__valuewhen5"]:set(period, (hl:hasData(period) and hl:tick(period) or nil), (hl:hasData(period) and hl:tick(period) or nil), 1) == 1) and SafeGreater((zz:hasData(period) and zz:tick(period) or nil), vars["__valuewhen6"]:set(period, (zz:hasData(period) and zz:tick(period) or nil), (zz:hasData(period) and zz:tick(period) or nil), 1))) and (nil) or ((hl:hasData(period) and hl:tick(period) or nil)));
    if hl_value then
        hl[period] = hl_value;
    else
        hl:setNoData(period);
    end
    hl_value = ((((hl:hasData(period) and hl:tick(period) or nil) == 1) and (vars["__valuewhen7"]:set(period, (hl:hasData(period) and hl:tick(period) or nil), (hl:hasData(period) and hl:tick(period) or nil), 1) == (-1)) and SafeLess((zz:hasData(period) and zz:tick(period) or nil), vars["__valuewhen8"]:set(period, (zz:hasData(period) and zz:tick(period) or nil), (zz:hasData(period) and zz:tick(period) or nil), 1))) and (nil) or ((hl:hasData(period) and hl:tick(period) or nil)));
    if hl_value then
        hl[period] = hl_value;
    else
        hl:setNoData(period);
    end
    zz_value = (((hl:hasData(period) and hl:tick(period) or nil) == nil) and (nil) or ((zz:hasData(period) and zz:tick(period) or nil)));
    if zz_value then
        zz[period] = zz_value;
    else
        zz:setNoData(period);
    end
    a = nil;
    b = nil;
    c = nil;
    d = nil;
    e = nil;
    if not ((hl:hasData(period) and hl:tick(period) or nil) == nil) then
        loc1, loc2, loc3, loc4 = vars["findpreviousFunc1"].GetValue(period, mode);
        a = (zz:hasData(period) and zz:tick(period) or nil);
        b = loc1;
        c = loc2;
        d = loc3;
        e = loc4;
    end
    _hh = (zz:hasData(period) and zz:tick(period) or nil) and (SafeGreater(a, b) and SafeGreater(a, c) and SafeGreater(c, b) and SafeGreater(c, d));
    _ll = (zz:hasData(period) and zz:tick(period) or nil) and (SafeLess(a, b) and SafeLess(a, c) and SafeLess(c, b) and SafeLess(c, d));
    _hl = (zz:hasData(period) and zz:tick(period) or nil) and (((SafeGE(a, c) and (SafeGreater(b, c) and SafeGreater(b, d) and SafeGreater(d, c) and SafeGreater(d, e))) or (SafeLess(a, b) and SafeGreater(a, c) and SafeLess(b, d))));
    _lh = (zz:hasData(period) and zz:tick(period) or nil) and (((SafeLE(a, c) and (SafeLess(b, c) and SafeLess(b, d) and SafeLess(d, c) and SafeLess(d, e))) or (SafeGreater(a, b) and SafeLess(a, c) and SafeGreater(b, d))));
    plot1_series = _hl;
    if plot1_series then
        plot1:set(period, source.low:tick(period), "HL", "HL");
    else
        plot1:setNoData(period);
    end
    plot2_series = _hh;
    if plot2_series then
        plot2:set(period, source.high:tick(period), "HH", "HH");
    else
        plot2:setNoData(period);
    end
    plot3_series = _ll;
    if plot3_series then
        plot3:set(period, source.low:tick(period), "LL", "LL");
    else
        plot3:setNoData(period);
    end
    plot4_series = _lh;
    if plot4_series then
        plot4:set(period, source.high:tick(period), "LH", "LH");
    else
        plot4:setNoData(period);
    end
    res_value = nil;
    if res_value then
        res[period] = res_value;
    else
        res:setNoData(period);
    end
    sup_value = nil;
    if sup_value then
        sup[period] = sup_value;
    else
        sup:setNoData(period);
    end
    if res:first() > period - 1 then return; end
    res_value = ((_lh) and ((zz:hasData(period) and zz:tick(period) or nil)) or ((res:hasData(period - 1) and res:tick(period - 1) or nil)));
    if res_value then
        res[period] = res_value;
    else
        res:setNoData(period);
    end
    if sup:first() > period - 1 then return; end
    sup_value = ((_hl) and ((zz:hasData(period) and zz:tick(period) or nil)) or ((sup:hasData(period - 1) and sup:tick(period - 1) or nil)));
    if sup_value then
        sup[period] = sup_value;
    else
        sup:setNoData(period);
    end
    trend = nil;
    trend = ((SafeGreater(source.close:tick(period), (res:hasData(period) and res:tick(period) or nil))) and (1) or (((SafeLess(source.close:tick(period), (sup:hasData(period) and sup:tick(period) or nil))) and ((-1)))));
    res_value = (((((trend == 1) and _hh) or ((trend == (-1)) and _lh))) and ((zz:hasData(period) and zz:tick(period) or nil)) or ((res:hasData(period) and res:tick(period) or nil)));
    if res_value then
        res[period] = res_value;
    else
        res:setNoData(period);
    end
    sup_value = (((((trend == 1) and _hl) or ((trend == (-1)) and _ll))) and ((zz:hasData(period) and zz:tick(period) or nil)) or ((sup:hasData(period) and sup:tick(period) or nil)));
    if sup_value then
        sup[period] = sup_value;
    else
        sup:setNoData(period);
    end
    if res:first() > period - 1 then return; end
    rechange = ((res:hasData(period) and res:tick(period) or nil) ~= (res:hasData(period - 1) and res:tick(period - 1) or nil));
    if sup:first() > period - 1 then return; end
    suchange = ((sup:hasData(period) and sup:tick(period) or nil) ~= (sup:hasData(period - 1) and sup:tick(period - 1) or nil));
    if vars["showsupres"] then
        if rechange then
            Line:SetX2(vars["resline"], period);
            Line:SetExtend(vars["resline"], "none");
            vars["resline"] = Line:New(period - vars["rb"], (res:hasData(period) and res:tick(period) or nil), period, (res:hasData(period) and res:tick(period) or nil)):SetColor(vars["rescol"]):SetExtend("right"):SetStyle(vars["srlinestyle"]);
        end
        if suchange then
            Line:SetX2(vars["supline"], period);
            Line:SetExtend(vars["supline"], "none");
            vars["supline"] = Line:New(period - vars["rb"], (sup:hasData(period) and sup:tick(period) or nil), period, (sup:hasData(period) and sup:tick(period) or nil)):SetColor(vars["supcol"]):SetExtend("right"):SetStyle(vars["srlinestyle"]);
        end
    end
    plot5_open[period] = source.open[period];
    plot5_high[period] = source.high[period];
    plot5_low[period] = source.low[period];
    plot5_close[period] = source.close[period];
    plot5_open:setColor(period, ((vars["changebarcol"]) and ((((trend == 1)) and (vars["bcolup"]) or (vars["bcoldn"]))) or (nil)));
end
function Draw(stage, context)
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
function CreateValueWhen()
    local vw = {};
    vw._stream = instance:addInternalStream(0, 0); 
    vw._count = 0;
    function vw:set(period, condition, value, occurrence)
        if self._count > 0 and self._stream:getBookmark(self._count) == period then
            self._stream:setBookmark(self._count, -1);
        end
        if condition then
            if self._count == 0 or self._stream:getBookmark(self._count) ~= -1 then
                self._count = self._count + 1;
            end
            self._stream:setBookmark(self._count, period);
            if value == nil then
                self._stream:setNoData(period);
            else
                self._stream[period] = value;
            end
        end
        if self._count <= occurrence then
            return nil;
        end
        return self._stream[self._stream:getBookmark(self._count - occurrence)];
    end
    return vw;
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
        self.Color = clr;
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
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        _, y1 = context:pointOfPrice(self.Y1);
        _, x1 = context:positionOfBar(self.X1);
        _, y2 = context:pointOfPrice(self.Y2);
        _, x2 = context:positionOfBar(self.X2);
        context:drawLine(self.PenId, x1, y1, x2, y2);
        if self.Extend == "right" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:right() + c;
            context:drawLine(self.PenId, x2, y2, context:right(), y3);
        end
        if self.Extend == "left" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:left() + c;
            context:drawLine(self.PenId, x1, y1, context:left(), y3);
        end
    end
    self.AllLines[#self.AllLines + 1] = newLine;
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