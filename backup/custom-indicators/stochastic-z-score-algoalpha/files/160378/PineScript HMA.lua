-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76274

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
    indicator:name("PineScript HMA")
    indicator:description("Hull Moving Average")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Frame", "Period", "Period", 20, 1, 2000)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Color of HMA", "", core.rgb(0, 255, 0))
end

local source = nil
local HMA = nil
local full = nil
local half = nil
local sqrt = nil
local sqrt_source = nil

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame
    source = instance.source

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    full = core.indicators:create("LWMA", source, Frame)
    half = core.indicators:create("LWMA", source, Frame / 2)
    sqrt_source = instance:addInternalStream(0, 0)
    sqrt = core.indicators:create("LWMA", sqrt_source, math.sqrt(Frame))

    HMA = instance:addStream("HMA", core.Line, name, "HMA", instance.parameters.Color, sqrt.DATA:first())
    HMA:setPrecision(math.max(2, source:getPrecision()))
end

function Update(period, mode)
    half:update(mode)
    full:update(mode)

    if not half.DATA:hasData(period) or not full.DATA:hasData(period) then
        return
    end

    sqrt_source[period] = 2 * half.DATA[period] - full.DATA[period]
    if period < sqrt.DATA:first() then
        return
    end
    sqrt:update(mode)

    HMA[period] = sqrt.DATA[period]
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76274

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