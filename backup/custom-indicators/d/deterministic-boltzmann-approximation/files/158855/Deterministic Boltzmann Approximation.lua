-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=75788

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright � 2025, Gehtsoft USA LLC  | 
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
    indicator:name("Deterministic Boltzmann Approximation")
    indicator:description("Energetski indikator snage trenda bez random komponenti")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addInteger("Period", "Lookback Period", "", 14, 2, 200)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Positive", "Positive Energy Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Negative", "Negative Energy Color", "", core.rgb(255, 0, 0))
end

local Period
local Source
local EnergyOutput

function Prepare(nameOnly)
    Period = instance.parameters.Period
    Source = instance.source.close
    local name = "Energy (" .. Period .. ")"
    instance:name(name)

    if nameOnly then return end

    EnergyOutput = instance:addStream("Energy", core.Bar, name, "Energy", instance.parameters.Positive, Period)
end

function Update(period)
    if period < Period then return end

    local momentum = Source[period] - Source[period - Period + 1]
    local volatility = 0

    -- Računanje volatilnosti kao prosječne apsolutne promjene
    for i = period - Period + 2, period do
        volatility = volatility + math.abs(Source[i] - Source[i - 1])
    end
    volatility = volatility / (Period - 1)

    -- Energija trenda: odnos momentuma i volatilnosti
    local energy
    if volatility ~= 0 then
        energy = momentum / volatility
    else
        energy = 0
    end

    -- Spremanje rezultata u izlazni stream
    EnergyOutput[period] = energy

    -- Postavljanje boje bara ovisno o energiji
    if energy >= 0 then
        EnergyOutput:setColor(period, instance.parameters.Positive)
    else
        EnergyOutput:setColor(period, instance.parameters.Negative)
    end
end
-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=75788

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright � 2025, Gehtsoft USA LLC  | 
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