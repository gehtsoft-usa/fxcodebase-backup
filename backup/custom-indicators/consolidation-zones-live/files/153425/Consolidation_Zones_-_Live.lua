-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74377

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
    indicator:name("Consolidation Zones - Live");
    indicator:description("Consolidation Zones - Live");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Loopback Period", "", 10);
    indicator.parameters:addInteger("param2", "Min Consolidation Length", "", 5);
    indicator.parameters:addBoolean("param3", "Paint Consolidation Area ", "", true);
    indicator.parameters:addColor("param4", "Zone Color", "", core.colors().Blue);
end

local source;
local params = {};
local dir;
local zz;
local conscnt;
local condhigh;
local condlow;
local pp;
local plot1;
local plot2;
local vars = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["prd"] = instance.parameters.param1;
    vars["conslen"] = instance.parameters.param2;
    vars["paintcons"] = instance.parameters.param3;
    vars["zonecol"] = instance.parameters.param4;
    vars["__highestbars1"] = CreateHighestBars(source, vars["prd"]);
    vars["__lowestbars1"] = CreateLowestBars(source, vars["prd"]);
    dir = instance:addInternalStream(0, 0);
    zz = instance:addInternalStream(0, 0);
    conscnt = instance:addInternalStream(0, 0);
    condhigh = instance:addInternalStream(0, 0);
    condlow = instance:addInternalStream(0, 0);
    pp = instance:addInternalStream(0, 0);
    plot1 = instance:addStream("plot1", core.Line, "", "", core.colors().Blue, 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_NONE);
    plot2 = instance:addStream("plot2", core.Line, "", "", core.colors().Blue, 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_NONE);
    instance:createChannelGroup("channel1", "channel1", plot1, plot2, core.colors().Blue, 100 - 70, true);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        dir[period] = 0;
        conscnt[period] = 0;
        condhigh[period] = nil;
        condlow[period] = nil;
        Line:Clear();
    else
        dir[period] = dir:tick(period - 1);
        conscnt[period] = conscnt:tick(period - 1);
        condhigh[period] = condhigh:tick(period - 1);
        condlow[period] = condlow:tick(period - 1);
    end
    hb_ = (((vars["__highestbars1"]:get(period) == 0)) and (source.high[period]) or (nil));
    lb_ = (((vars["__lowestbars1"]:get(period) == 0)) and (source.low[period]) or (nil));
    zz[period] = nil;
    pp[period] = nil;
    dir[period] = ((hb_ and lb_ == nil) and (1) or (((lb_ and hb_ == nil) and ((-1)) or (dir:tick(period)))));
    if hb_ and lb_ then
        if (dir:tick(period) == 1) then
            zz[period] = hb_;
        else
            zz[period] = lb_;
        end
    else
        zz[period] = ((hb_) and (hb_) or (((lb_) and (lb_) or (nil))));
    end
    for x = 0, 1000, 1 do
        if dir:first() > period - x then return; end
        if (source.close == nil or (dir:tick(period) ~= dir:tick(period - x))) then
            break;
        end
        if zz:first() > period - x then return; end
        if (zz:tick(period - x) ~= 0) then
            if pp == nil then
                if zz:first() > period - x then return; end
                pp[period] = zz:tick(period - x);
            else
                if dir:first() > period - x then return; end
                if zz:first() > period - x then return; end
                if (dir:tick(period - x) == 1) and SafeGreater(zz:tick(period - x), pp:tick(period)) then
                    if zz:first() > period - x then return; end
                    pp[period] = zz:tick(period - x);
                end
                if dir:first() > period - x then return; end
                if zz:first() > period - x then return; end
                if (dir:tick(period - x) == (-1)) and SafeLess(zz:tick(period - x), pp:tick(period)) then
                    if zz:first() > period - x then return; end
                    pp[period] = zz:tick(period - x);
                end
            end
        end
    end
    if source:first() > period - vars["conslen"] then return; end
    H_ = mathex.max(source, core.rangeTo(period, vars["conslen"]));
    if source:first() > period - vars["conslen"] then return; end
    L_ = mathex.min(source, core.rangeTo(period, vars["conslen"]));
    vars["upline"] = nil;
    vars["dnline"] = nil;
    breakoutup = false;
    breakoutdown = false;
    if (Change(pp, period, 1) ~= 0) then
        if (conscnt:tick(period) > vars["conslen"]) then
            if SafeGreater(pp:tick(period), condhigh:tick(period)) then
                breakoutup = true;
            end
            if SafeLess(pp:tick(period), condlow:tick(period)) then
                breakoutdown = true;
            end
        end
        if (conscnt:tick(period) > 0) and SafeLE(pp:tick(period), condhigh:tick(period)) and SafeGE(pp:tick(period), condlow:tick(period)) then
            conscnt[period] = conscnt:tick(period) + 1;
        else
            conscnt[period] = 0;
        end
    else
        conscnt[period] = conscnt:tick(period) + 1;
    end
    if (conscnt:tick(period) >= vars["conslen"]) then
        if (conscnt:tick(period) == vars["conslen"]) then
            condhigh[period] = H_;
            condlow[period] = L_;
        else
            condhigh[period] = math.max(condhigh:tick(period), source.high[period]);
            condlow[period] = math.min(condlow:tick(period), source.low[period]);
        end
        upline = Line:New(period, condhigh:tick(period), period - conscnt:tick(period), condhigh:tick(period)):SetColor(core.colors().Red);
        dnline = Line:New(period, condlow:tick(period), period - conscnt:tick(period), condlow:tick(period)):SetColor(core.colors().Lime);
    end
    plot1[period] = condhigh:tick(period);
    plot2[period] = condlow:tick(period);
    plot1:setColor(period, ((vars["paintcons"] and (conscnt:tick(period) > vars["conslen"])) and (vars["zonecol"]) or (core.colors().White)));
end
function Draw(stage, context)
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
function Line:New(x1, y1, x2, y2)
    local newLine = {};
    newLine.X1 = x1;
    newLine.Y1 = y1;
    newLine.X2 = x2;
    newLine.Y2 = y2;
    function newLine:SetXY1(x, y)
        self.X1 = x;
        self.Y1 = y;
    end
    function newLine:SetXY2(x, y)
        self.X2 = x;
        self.Y2 = y;
    end
    newLine.Color = core.colors().Blue;
    function newLine:SetColor(clr)
        self.Color = clr;
        self.PenValid = false;
    end
    newLine.Width = 1;
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenValid = false;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil then
            return;
        end
        if not self.PenValid then
            self.PenId = Graphics:FindPen(self.Width, self.Color, core.LINE_SOLID, context);
            self.PenValid = true;
        end
        _, y1 = context:pointOfPrice(self.Y1);
        _, x1 = context:positionOfBar(self.X1);
        _, y2 = context:pointOfPrice(self.Y2);
        _, x2 = context:positionOfBar(self.X2);
        context:drawLine(self.PenId, x1, y1, x2, y2);
    end
    self.AllLines[#self.AllLines + 1] = newLine;
    return newLine;
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