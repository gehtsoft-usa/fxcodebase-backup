-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76008

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
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
function Init()
    indicator:name("RSI Trend Line");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period", "", 14, 2, 1000);
    indicator.parameters:addInteger("x", "High/low period", "", 10);
    indicator.parameters:addInteger("y", "Multiplier", "", 2);
    indicator.parameters:addInteger("z", "Exclude periods", "", 14);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRSI", "Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRSI", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleRSI", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("high_trend", "High trend color", "", core.colors().Green);
    indicator.parameters:addColor("low_trend", "Low trend color", "", core.colors().Red);
    
    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought level", "", 70, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold level", "", 30, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Level width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Level style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Level color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local pos = nil;
local neg = nil;

-- Streams block
local RSI = nil;
local x, y, z;

-- Routine
function Prepare()
    n = instance.parameters.N;
    z = instance.parameters.z;
    x = instance.parameters.x;
    y = instance.parameters.y;
    source = instance.source;
    first = source:first() + n;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);

    pos = instance:addInternalStream(0, 0);
    neg = instance:addInternalStream(0, 0);

    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.clrRSI, first);
    RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2);
    
    RSI:addLevel(0);
    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RSI:addLevel(50);
    RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    RSI:addLevel(100);

    instance:ownerDrawn(true)
end

local init = false;
local low_pen = 2;
local high_pen = 1;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(high_pen, context.SOLID, 1, instance.parameters.high_trend);
        context:createPen(low_pen, context.SOLID, 1, instance.parameters.low_trend);
    end
    period = source:size() - 1;
    if (period < x * y - 1) then
        return;
    end
    local hh1, hh1_period = mathex.max(RSI, core.rangeTo(period, x));
    local hh2, hh2_period = mathex.max(RSI, core.rangeTo(period - z, x * y));
    local x1 = context:positionOfBar(hh1_period);
    local _, x2 = context:positionOfBar(hh2_period);
    local _, y1 = context:pointOfPrice(hh1);
    local _, y2 = context:pointOfPrice(hh2);
    context:drawLine(high_pen, x1, y1, x2, y2);

    local ll1, ll1_period = mathex.min(RSI, core.rangeTo(period, x));
    local ll2, ll2_period = mathex.min(RSI, core.rangeTo(period - z, x * y));
    x1 = context:positionOfBar(ll1_period);
    _, x2 = context:positionOfBar(ll2_period);
    _, y1 = context:pointOfPrice(ll1);
    _, y2 = context:pointOfPrice(ll2);
    context:drawLine(low_pen, x1, y1, x2, y2);
end

-- Indicator calculation routine
function Update(period)
    if period < first then
        return;
    end
    local i = 0;
    local sump = 0;
    local sumn = 0;
    local positive = 0;
    local negative = 0;
    local diff = 0;
    if (period == first) then
        for i = period - n + 1, period do
            diff = source[i] - source[i - 1];
            if (diff >= 0) then
                sump = sump + diff;
            else
                sumn = sumn - diff;
            end
        end
        positive = sump / n;
        negative = sumn / n;
    else
        diff = source[period] - source[period - 1];
        if (diff > 0) then 
            sump = diff;
        else
            sumn = -diff;
        end
        positive = (pos[period - 1] * (n - 1) + sump) / n;
        negative = (neg[period - 1] * (n - 1) + sumn) / n;
    end
    pos[period] = positive;
    neg[period] = negative;
    if (negative == 0) then
        RSI[period] = 0;
    else
        RSI[period] = 100 - (100 / (1 + positive / negative));
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76008

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
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