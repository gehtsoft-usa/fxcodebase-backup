-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70268

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Forex Pecentages CEESO A");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("short_hour", "Start hour", "", 17);
    indicator.parameters:addInteger("mod", "Mod", "", 1);
    indicator.parameters:addColor("line1_color", "Open Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("line1_width", "Open Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("line1_style", "Open Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("line1_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("line2_color", "Line 2 Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("line2_width", "Line 2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("line2_style", "Line 2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("line2_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("line3_color", "Line 3 Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("line3_width", "Line 3 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("line3_style", "Line 3 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("line3_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("above_middle_color", "Above Middle Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("above_middle_width", "Above Middle Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("above_middle_style", "Above Middle Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("above_middle_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("below_middle_color", "Below Middle Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("below_middle_width", "Below Middle Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("below_middle_style", "Below Middle Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("below_middle_style", core.FLAG_LINE_STYLE);
end

local source, mod, tradingWeekOffset, tradingDayOffset, short_hour;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    short_hour = instance.parameters.short_hour;
    mod = instance.parameters.mod;
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = short_hour - 24;
    instance:ownerDrawn(true);
end

local init = false;
local line1_pen = 1;
local line2_pen = 2;
local line3_pen = 3;
local above_middle_pen = 4;
local below_middle_pen = 5;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(line1_pen, context:convertPenStyle(instance.parameters.line1_style), instance.parameters.line1_width, instance.parameters.line1_color);
        context:createPen(line2_pen, context:convertPenStyle(instance.parameters.line2_style), instance.parameters.line2_width, instance.parameters.line2_color);
        context:createPen(line3_pen, context:convertPenStyle(instance.parameters.line3_style), instance.parameters.line3_width, instance.parameters.line3_color);
        context:createPen(above_middle_pen, context:convertPenStyle(instance.parameters.above_middle_style), instance.parameters.above_middle_width, instance.parameters.above_middle_color);
        context:createPen(below_middle_pen, context:convertPenStyle(instance.parameters.below_middle_style), instance.parameters.below_middle_width, instance.parameters.below_middle_color);
    end
    local s, e = core.getcandle("D1", source:date(NOW), tradingDayOffset, tradingWeekOffset)
    local index = core.findDate(source, s, false);
    if index < 0 then
        return;
    end
    local DaOp = source.open[index];
    local A15 = 1.875 * mod;
    local A14 = 1.750 * mod;
    local A13 = 1.625 * mod;
    local A12 = 1.500 * mod;
    local A11 = 1.375 * mod;
    local A10 = 1.250 * mod;
    local A09 = 1.125 * mod;
    local A08 = 1.000 * mod;
    local A07 = 0.875 * mod;
    local A06 = 0.750 * mod;
    local A05 = 0.625 * mod;
    local A04 = 0.500 * mod;
    local A03 = 0.375 * mod;
    local A02 = 0.250 * mod;
    local A01 = 0.125 * mod;
    AA15 = DaOp + (DaOp * A15) / 100;
    AA14 = DaOp + (DaOp * A14) / 100;
    AA13 = DaOp + (DaOp * A13) / 100;
    AA12 = DaOp + (DaOp * A12) / 100;
    AA11 = DaOp + (DaOp * A11) / 100;

    AA10 = DaOp + (DaOp * A10) / 100;
    AA09 = DaOp + (DaOp * A09) / 100;
    AA08 = DaOp + (DaOp * A08) / 100;
    AA07 = DaOp + (DaOp * A07) / 100;
    AA06 = DaOp + (DaOp * A06) / 100;
    AA05 = DaOp + (DaOp * A05) / 100;
    AA04 = DaOp + (DaOp * A04) / 100;
    AA03 = DaOp + (DaOp * A03) / 100;
    AA02 = DaOp + (DaOp * A02) / 100;
    AA01 = DaOp + (DaOp * A01) / 100;

    MA00 = DaOp;
    BA01 = DaOp - (DaOp * A01) / 100;
    BA02 = DaOp - (DaOp * A02) / 100;
    BA03 = DaOp - (DaOp * A03) / 100;
    BA04 = DaOp - (DaOp * A04) / 100;
    BA05 = DaOp - (DaOp * A05) / 100;
    BA06 = DaOp - (DaOp * A06) / 100;
    BA07 = DaOp - (DaOp * A07) / 100;
    BA08 = DaOp - (DaOp * A08) / 100;
    BA09 = DaOp - (DaOp * A09) / 100;
    BA10 = DaOp - (DaOp * A10) / 100;
    BA11 = DaOp - (DaOp * A11) / 100;
    BA12 = DaOp - (DaOp * A12) / 100;
    BA13 = DaOp - (DaOp * A13) / 100;
    BA14 = DaOp - (DaOp * A14) / 100;
    BA15 = DaOp - (DaOp * A15) / 100;

    local x1 = context:positionOfDate(s);
    local x2 = context:positionOfDate(e);
    
    local _, y = context:pointOfPrice(AA15);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA14);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA13);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA12);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA11);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA10);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA09);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA08);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA07);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA06);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA05);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA04);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA03);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA02);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(AA01);
    context:drawLine(above_middle_pen, x1, y, x2, y);

    _, y = context:pointOfPrice(MA00);
    context:drawLine(line1_pen, x1, y, x2, y);

    _, y = context:pointOfPrice(BA01);
    context:drawLine(below_middle_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA02);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA03);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA04);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA05);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA06);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA07);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA08);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA09);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA10);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA11);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA12);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA13);
    context:drawLine(line2_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA14);
    context:drawLine(line3_pen, x1, y, x2, y);
    _, y = context:pointOfPrice(BA15);
    context:drawLine(line2_pen, x1, y, x2, y);
end

function Update(period, mode)
end