-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74296

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
    indicator:name("ADX Colored Slope")
    indicator:description("ADX Colored Slope")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("LP", " Period", " Period", 14)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Pozitiv", "Color of Up Trend", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Negativ", "Color of Down Trend ", "", core.rgb(255, 0, 0))
end

local LP

local first
local source = nil

local Short = nil
local Long = nil
local Indicator = {}
local Count

function Prepare(nameOnly)
    LP = instance.parameters.LP

    source = instance.source
    Count = 0

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(LP) .. ")"
    instance:name(name)

    if nameOnly then
        return;
    end
    Indicator["ADX"] = core.indicators:create("ADX", source, LP)
    first = Indicator["ADX"].DATA:first()
    Long = instance:addStream("Long", core.Line, name .. ".Long", "Long", core.rgb(0, 0, 0), first)
end

function Update(period, mode)
    if period < first or not source:hasData(period) then
        return
    end
    Indicator["ADX"]:update(mode)

    Long[period] = Indicator["ADX"].DATA[period]

    if not Indicator["ADX"].DATA:hasData(period - 1) or Indicator["ADX"].DATA[period] > Indicator["ADX"].DATA[period - 1] then
        Long:setColor(period, instance.parameters.Pozitiv)
    else
        Long:setColor(period, instance.parameters.Negativ)
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