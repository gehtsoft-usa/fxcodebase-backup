-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76042

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
    indicator:name("Fractals Corridor Breakdown");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Red);
    indicator.parameters:addColor("dn_color", "Down color", "", core.colors().Green);
end

local source;
local up, down, o, h, l, c, v;
local fractal;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    fractal = core.indicators:create("FRACTAL", source);

    up = instance:addStream("up", core.Dot, "Up", "Up", instance.parameters.up_color, 0, 0);
    down = instance:addStream("down", core.Dot, "Down", "Down", instance.parameters.dn_color, 0, 0);

    o = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), 0)
    h = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), 0)
    l = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), 0)
    c = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), 0)
    v = instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), 0)
    instance:createCandleGroup(source:name(), source:name(), o, h, l, c, v);
end

function FindFractal(period)
    for i = period - 2, 0, -1 do
        if fractal:getTextOutput(0):hasData(i) then
            return 1, i, source.high[i];
        elseif fractal:getTextOutput(1):hasData(i) then
            return -1, i, source.low[i];
        end
    end
    return 0;
end

function Update(period, mode)
    if period == 0 then
        return;
    end
    fractal:update(mode);
    local result, pos, val = FindFractal(period);
    if result == 1 then
        up[period] = val;
        down[period] = down[period - 1];
    elseif result == -1 then
        down[period] = val;
        up[period] = up[period - 1];
    else
        down[period] = down[period - 1];
        up[period] = up[period - 1];
    end
    if source.low[period] < up[period] and source.high[period] > up[period] then
        o[period] = source.open[period];
        c[period] = source.close[period];
        h[period] = source.high[period];
        l[period] = source.low[period];
        v[period] = source.volume[period];
        o:setColor(period, instance.parameters.up_color);
    elseif source.low[period] < down[period] and source.high[period] > down[period] then
        o[period] = source.open[period];
        c[period] = source.close[period];
        h[period] = source.high[period];
        l[period] = source.low[period];
        v[period] = source.volume[period];
        o:setColor(period, instance.parameters.dn_color);
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76042

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