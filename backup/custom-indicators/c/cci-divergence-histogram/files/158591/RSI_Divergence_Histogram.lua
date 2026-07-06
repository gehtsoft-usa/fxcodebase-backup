-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=158539#p158539

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
function Init()
    indicator:name("CCI Divergence Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("N", "Periods for RSI Indicator ", "", 7);

    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
end

local source;
local indi;
local hist;
local up_color;
local down_color;
local N;
function Prepare(nameOnly)
    source = instance.source;
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;
    N = instance.parameters.N;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    local profile = core.indicators:findIndicator("RSI_DIVERGENCE");
    assert(profile ~= nil, "Please, download and install " .. "RSI_DIVERGENCE" .. ".LUA indicator");
    indi = core.indicators:create("RSI_DIVERGENCE", source, instance.parameters.N, false);
    hist = instance:addStream("HIST", core.Bar, "Histogram", "HIST", up_color, 0, 0);
end

function Update(period, mode)
    if period < N then
        return;
    end
    indi:update(mode);

    for i = 0, N do
        if indi.DN:hasData(period - i) then
            if source.close[period] > source.close[period - i] then
                hist[period] = 1;
                hist:setColor(period, up_color);
            end
        elseif indi.UP:hasData(period - i) then
            if source.close[period] < source.close[period - i] then
                hist[period] = -1;
                hist:setColor(period, down_color);
            end
        end
    end
end
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=158539#p158539

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