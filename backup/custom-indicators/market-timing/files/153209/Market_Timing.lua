-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74321

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
    indicator:name("Market Timing");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addColor("h_color", "High column color", "", core.colors().Green)
    indicator.parameters:addColor("l_color", "Low column color", "", core.colors().Red)
end

local source;
local h1;
local market_profile = {};
local totalCount = 0;
local out1, out0, shift;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    h1 = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), 300, 1, 2);
    out1 = instance:addStream("out1", core.Line, "Out", "Out", core.colors().Blue, 0, 0);
    out0 = instance:addStream("out0", core.Line, "Out", "Out", core.colors().Blue, 0, 0);
    local date = core.now();
    shift = math.floor((core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, date) - date) * 24 + 0.5);
    out0:addLevel(-10, core.LINE_NONE);
    instance:ownerDrawn(true)
end

function Update(period, mode)
    out0[period] = 0;
    out1[period] = 100;
    if h1:size() == 0 then
        totalCount = 0;
        market_profile = {};
        for i = 0, 23, 1 do
            market_profile[i] = { h = 0, l = 0 };
        end
        return;
    end
    if source:size() - 1 == period and totalCount == 0 then
        for i = 23, h1:size() - 1 do
            if i % 23 == 0 then
                totalCount = totalCount + 1;
            end
            min, max, minpos, maxpos = mathex.minmax(h1, core.rangeTo(i, 24));
            if minpos == i then
                market_profile[core.dateToTable(h1:date(i)).hour].l = market_profile[core.dateToTable(h1:date(i)).hour].l + 1;
            end
            if maxpos == i then
                market_profile[core.dateToTable(h1:date(i)).hour].h = market_profile[core.dateToTable(h1:date(i)).hour].h + 1;
            end
        end
    end
end

local init = false;
local h_pen = 1;
local h_brush = 2;
local l_pen = 3;
local l_brush = 4;
local font = 5;
local brush = 6;
local pen = 7;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(h_pen, context:convertPenStyle(core.LINE_SOLID), 1, instance.parameters.h_color);
        context:createPen(l_pen, context:convertPenStyle(core.LINE_SOLID), 1, instance.parameters.l_color);
        context:createSolidBrush(h_brush, instance.parameters.h_color)
        context:createSolidBrush(l_brush, instance.parameters.l_color)
        context:createFont(font, "Arial", 0, context:pointsToPixels(8), context.LEFT);
    end
    if totalCount == 0 then
        return;
    end
    column_width = (context:right() - context:left()) / 24;
    local ll = 0;
    local hh = 0;
    for i = 0, 23, 1 do
        local hour = i + shift;
        if hour >= 24 then
            hour = hour - 24;
        end
        x1 = context:left() + hour * column_width + 1;
        x2 = x1 + column_width - 2;
        xm = (x1 + x2) / 2;
        _, y1 = context:pointOfPrice(0);
        _, y2 = context:pointOfPrice(100 * (market_profile[hour].h / totalCount))
        context:drawRectangle(h_pen, h_brush, x1, y1, xm, y2);
        _, y2 = context:pointOfPrice(100 * (market_profile[hour].l / totalCount))
        context:drawRectangle(l_pen, l_brush, xm, y1, x2, y2);
        
        local label = tostring(hour);
        local w, h = context:measureText(font, label, context.LEFT);
        local lx1 = (x1 + x2) / 2 - w / 2;
        local lx2 = lx1 + w;
        context:drawText(font, label, core.COLOR_LABEL, -1, lx1, y1, lx2, y1 + h, 0)
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1 then
        instance:updateFrom(0);
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