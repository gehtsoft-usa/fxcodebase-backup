-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75867&p=159059#p159059

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
    indicator:name("Fourier Oscillating Moving Average (FOMA)")
    indicator:description("Fourier Moving Average that oscillates around SMA")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Settings")
    indicator.parameters:addInteger("MAPeriod", "SMA Period", "", 14, 2, 200)
    indicator.parameters:addInteger("FourierPeriod", "Fourier Transform Period", "", 30, 10, 200)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("LineColor", "Line Color", "", core.rgb(0, 128, 255))
    indicator.parameters:addInteger("LineWidth", "Line Width", "", 2, 1, 5)
    indicator.parameters:addInteger("LineStyle", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE)
end

local source
local MAPeriod, FourierPeriod
local SMAStream
local FOMAStream

function Prepare(nameOnly)
    source = instance.source
    MAPeriod = instance.parameters.MAPeriod
    FourierPeriod = instance.parameters.FourierPeriod

    local name = "FOMA (" .. MAPeriod .. "," .. FourierPeriod .. ")"
    instance:name(name)

    if nameOnly then
        return
    end

    -- SMA stream
    SMAStream = instance:addInternalStream(source:first() + MAPeriod, 0)

    -- Fourier Oscillating Moving Average output
    FOMAStream = instance:addStream("FOMA", core.Line, name, "FOMA", instance.parameters.LineColor, source:first() + MAPeriod + FourierPeriod)
    FOMAStream:setWidth(instance.parameters.LineWidth)
    FOMAStream:setStyle(instance.parameters.LineStyle)
end

function Update(period, mode)
    if period < source:first() + math.max(MAPeriod, FourierPeriod) then
        return
    end

    -- Step 1: Calculate SMA
    local sum = 0
    for i = period - MAPeriod + 1, period do
        sum = sum + source.close[i]
    end
    local sma = sum / MAPeriod
    SMAStream[period] = sma

    -- Step 2: Calculate Fourier Oscillation (real part)
    local re = 0
    for i = 0, FourierPeriod - 1 do
        local angle = 2 * math.pi * i / FourierPeriod
        re = re + source.close[period - i] * math.cos(angle)
    end

    -- Step 3: Normalize oscillation
    local oscillation = re / FourierPeriod

    -- Step 4: Add oscillation around SMA
    FOMAStream[period] = SMAStream[period] + oscillation
end



-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75867&p=159059#p159059

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