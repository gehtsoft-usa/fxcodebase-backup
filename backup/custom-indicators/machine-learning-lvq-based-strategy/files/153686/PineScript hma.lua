-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74446

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