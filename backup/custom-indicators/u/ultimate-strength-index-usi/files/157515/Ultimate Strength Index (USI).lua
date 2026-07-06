-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75416&p=157515#p157515

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic    |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- -- +------------------------------------------------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +------------------------------------------------+-----------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +------------------------------------------------+-----------------------------------------------+ 

--[[
    Title: Ultimate Strength Index (USI)
    Author: John F. Ehlers
    Translated for FXCM Trading Station 2
--]]

function Init()
    indicator:name("Ultimate Strength Index (USI)")
    indicator:description("Enhanced RSI with reduced lag.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addInteger("Length1", "USI Length", "Period for calculating the USI", 14, 1, 1000)
    indicator.parameters:addInteger("Length2", "Short Length", "Period for short smoothing", 4, 1, 1000)
    indicator.parameters:addColor("clrUSI", "USI Line Color", "Color for the USI line", core.rgb(55, 126, 184))
    indicator.parameters:addInteger("widthUSI", "USI Line Width", "Width of the USI line", 1, 1, 5)
    indicator.parameters:addInteger("styleUSI", "USI Line Style", "Style of the USI line", core.LINE_SOLID)
end

local length1
local length2
local src
local usi
local SU, SD, USU, USD

function Prepare()
    length1 = instance.parameters.Length1
    length2 = instance.parameters.Length2
    src = instance.source.close

    local name = "USI (" .. length1 .. ", " .. length2 .. ")"
    instance:name(name)

    SU = instance:addInternalStream(0, 0)
    SD = instance:addInternalStream(0, 0)
    avgSU = instance:addInternalStream(0, 0)
    avgSD = instance:addInternalStream(0, 0)	
    USU = instance:addInternalStream(0, 0)
    USD = instance:addInternalStream(0, 0)

    usi = instance:addStream("USI", core.Line, name, "USI", instance.parameters.clrUSI, src:first() + length1 + length2)
    usi:setWidth(instance.parameters.widthUSI)
    usi:setStyle(instance.parameters.styleUSI)
end

function Update(period)
    if period < src:first() + 1 then
        return
    end

    local diff = src[period] - src[period - 1]
    if diff > 0 then
        SU[period] = diff
        SD[period] = 0
    else
        SU[period] = 0
        SD[period] = -diff
    end

    if period >= src:first() + length2 then
        local sumSU = 0
        local sumSD = 0
        for i = 0, length2 - 1 do
            sumSU = sumSU + SU[period - i]
            sumSD = sumSD + SD[period - i]
        end
        avgSU[period] = sumSU / length2
        avgSD[period] = sumSD / length2

        USU[period] = UltimateSmoother(avgSU, period, USU, length1)
        USD[period] = UltimateSmoother(avgSD, period, USD, length1)

        if USU[period] + USD[period] ~= 0  then
            usi[period] = (USU[period] - USD[period]) / (USU[period] + USD[period])
        else
            usi[period] = 0
        end
    end
end

function UltimateSmoother(value, period, buffer, length)
    if period < src:first() + 2 then
        return 
    end

    local a1 = math.exp(-1.414 * math.pi / length)
    local b1 = 2 * a1 * math.cos(1.414 * math.pi / length)
    local c2 = b1
    local c3 = -a1 * a1
    local c1 = (1 + c2 - c3) / 4

    return (1 - c1) * value[period] + (2 * c1 - c2) * value[period - 1] - (c1 + c3) * value[period - 2] + c2 * buffer[period - 1] + c3 * buffer[period - 2]
end
-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic    |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- -- +------------------------------------------------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +------------------------------------------------+-----------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +------------------------------------------------+-----------------------------------------------+ 