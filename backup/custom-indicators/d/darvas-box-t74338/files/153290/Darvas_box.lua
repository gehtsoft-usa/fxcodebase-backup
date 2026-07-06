-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74338

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
    indicator:name("Darvas box (with alerts)");
    indicator:description("Darvas box (with alerts)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Box Length", "", 5);
end

local source;
local params = {};
local k1;
local Left;
local TopBox;
local BottomBox;
local draw_boxFunc1_param1;
local draw_boxFunc1_param2;
local draw_boxFunc1_param3;
local draw_boxFunc1_param4;
function Create_draw_box(left, top, right, bottom)
    return {
        GetValue = function(period)
            color = ((source.close[period] > top:tick(period)) and core.colors().Green or ((source.close[period] < bottom:tick(period)) and core.colors().Red or core.colors().Yellow));
            box = Box:New(core.formatDate(source:date(left:tick(period))) .. "_1", left:tick(period), top:tick(period), right:tick(period), bottom:tick(period));
            box:SetBorderColor(color);
            box:SetBGColor(core.rgb((color % 256), (math.floor(color / 256) % 256), (math.floor(color / 65536) % 256)) + math.floor(95 / 100 * 256) * 16777216);
            return box;
        end
    };
end
local vars = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["boxp"] = instance.parameters.param1;
    vars["__valuewhen1"] = CreateValueWhen();
    k1 = instance:addInternalStream(0, 0);
    vars["__valuewhen2"] = CreateValueWhen();
    vars["__barssince1"] = CreateBarsSince();
    vars["__valuewhen3"] = CreateValueWhen();
    vars["__barssince2"] = CreateBarsSince();
    Left = instance:addInternalStream(0, 0);
    TopBox = instance:addInternalStream(0, 0);
    BottomBox = instance:addInternalStream(0, 0);
    draw_boxFunc1_param1 = instance:addInternalStream(0, 0);
    draw_boxFunc1_param2 = instance:addInternalStream(0, 0);
    draw_boxFunc1_param3 = instance:addInternalStream(0, 0);
    draw_boxFunc1_param4 = instance:addInternalStream(0, 0);
    vars["draw_boxFunc1"] = Create_draw_box(draw_boxFunc1_param1, draw_boxFunc1_param2, draw_boxFunc1_param3, draw_boxFunc1_param4);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    Left[period] = period == 0 and 0 or Left:tick(period - 1);
    if source.low:first() > period - vars["boxp"] then return; end
    LL = mathex.min(source.low, core.rangeTo(period, vars["boxp"]));
    if source.high:first() > period - vars["boxp"] then return; end
    k1[period] = mathex.max(source.high, core.rangeTo(period, vars["boxp"]));
    if source.high:first() > period - vars["boxp"] - 1 then return; end
    k2 = mathex.max(source.high, core.rangeTo(period, vars["boxp"] - 1));
    if source.high:first() > period - vars["boxp"] - 2 then return; end
    k3 = mathex.max(source.high, core.rangeTo(period, vars["boxp"] - 2));
    if k1:first() > period - 1 then return; end
    NH = vars["__valuewhen1"]:set(period, (source.high[period] > k1[period - 1]), source.high[period], 0);
    box1 = (k3 < k2);
    if k1:first() > period - 1 then return; end
    TopBox[period] = vars["__valuewhen2"]:set(period, (vars["__barssince1"]:set(period, (source.high[period] > k1:tick(period - 1))) == vars["boxp"] - 2) and box1, NH, 0);
    if k1:first() > period - 1 then return; end
    BottomBox[period] = vars["__valuewhen3"]:set(period, (vars["__barssince2"]:set(period, (source.high[period] > k1:tick(period - 1))) == vars["boxp"] - 2) and box1, LL, 0);
    if TopBox:first() > period - 1 then return; end
    if BottomBox:first() > period - 1 then return; end
    if (((TopBox[period] == 0) or (TopBox[period] ~= TopBox[period - 1])) or (BottomBox[period] ~= BottomBox[period - 1])) then
        Left[period] = period;
    end
    if TopBox:first() > period - 1 then return; end
    if BottomBox:first() > period - 1 then return; end
    if (((TopBox:tick(period) ~= TopBox:tick(period - 1)) or (BottomBox:tick(period) ~= BottomBox:tick(period - 1))) or period == source:size() - 1) then
        if Left:first() > period - 1 then return; end
        if TopBox:first() > period - 1 then return; end
        if BottomBox:first() > period - 1 then return; end
        draw_boxFunc1_param1[period] = Left:tick(period - 1);
        draw_boxFunc1_param2[period] = TopBox:tick(period - 1);
        draw_boxFunc1_param3[period] = (period == source:size() - 1 and period or period - 1);
        draw_boxFunc1_param4[period] = BottomBox:tick(period - 1);
        vars["draw_boxFunc1"].GetValue(period);
    end
end
function Draw(stage, context)
    Box:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
            self._stream[period] = value;
        end
        if self._count <= occurrence then
            return nil;
        end
        return self._stream[self._stream:getBookmark(self._count - occurrence)];
    end
    return vw;
end
function CreateBarsSince()
    local bs = {};
    bs.last_period = nil;
    function bs:set(period, condition)
        if condition then
            self.last_period = period;
        end
        if self.last_period == nil then
            return nil;
        end
        return period - self.last_period;
    end
    return bs;
end
Graphics = {};
Graphics.NextId = 2;
Graphics.Pens = {};
Graphics.Brushes = {};
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

Box = {};
Box.AllBoxs = {};
function Box:New(id, left, top, right, bottom)
    local newBox = {};
    newBox.Left = left;
    newBox.Top = top;
    newBox.Right = right;
    newBox.Bottom = bottom;
    newBox.BorderColor = core.colors().Blue;
    newBox.BgColor = core.colors().Blue;
    newBox.BorderWidth = 1;
    newBox.BorderStyle = core.LINE_SOLID;
    function newBox:SetBGColor(clr)
        self.BgColorTransparency = (math.floor(clr / 16777216) % 256);
        self.BgColor = clr - self.BgColorTransparency * 16777216;
        self.BrushId = nil;
    end
    function newBox:SetBorderColor(clr)
        self.BorderColor = clr;
        self.PenId = nil;
    end
    function newBox:Draw(stage, context)
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.BorderWidth, self.BorderColor, self.BorderStyle, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.BgColor, context);
        end
        _, y1 = context:pointOfPrice(self.Top);
        _, x1 = context:positionOfBar(self.Left);
        _, y2 = context:pointOfPrice(self.Bottom);
        _, x2 = context:positionOfBar(self.Right);
        context:drawRectangle(self.PenId, self.BrushId, x1, y1, x2, y2, self.BgColorTransparency)
        context:drawRectangle(self.PenId, -1, x1, y1, x2, y2)
    end
    self.AllBoxs[id] = newBox;
    return newBox;
end
function Box:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for id, Box in pairs(self.AllBoxs) do
        Box:Draw(stage, context);
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