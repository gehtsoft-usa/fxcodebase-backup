-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75940

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
    indicator:name("3 MA Zone Candles")
    indicator:description("Colors candles depending on which MA zone the close price is in.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    for i = 1, 3 do
        indicator.parameters:addGroup("MA " .. i)
        indicator.parameters:addInteger("Period" .. i, "MA Period", "", 10 * i, 1, 500)
        indicator.parameters:addString("Method" .. i, "MA Method", "", "MVA")
        indicator.parameters:addStringAlternative("Method" .. i, "MVA", "", "MVA")
        indicator.parameters:addStringAlternative("Method" .. i, "EMA", "", "EMA")
        indicator.parameters:addStringAlternative("Method" .. i, "LWMA", "", "LWMA")
    end

    indicator.parameters:addGroup("Candle Colors")
    indicator.parameters:addColor("Color1", "Below all MAs", "", core.rgb(255, 0, 0))       -- Red
    indicator.parameters:addColor("Color2", "Between MA1 and MA2", "", core.rgb(255, 165, 0)) -- Orange
    indicator.parameters:addColor("Color3", "Between MA2 and MA3", "", core.rgb(0, 128, 255)) -- Blue
    indicator.parameters:addColor("Color4", "Above all MAs", "", core.rgb(0, 200, 0))       -- Green
end

local source, ma = {}, {}
local Period, Method = {}, {}
local open, high, low, close
local Color = {}

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)
    if nameOnly then return end

    source = instance.source

    for i = 1, 3 do
        Period[i] = instance.parameters:getInteger("Period" .. i)
        Method[i] = instance.parameters:getString("Method" .. i)
        ma[i] = core.indicators:create(Method[i], source.close, Period[i])
    end

    Color[1] = instance.parameters.Color1
    Color[2] = instance.parameters.Color2
    Color[3] = instance.parameters.Color3
    Color[4] = instance.parameters.Color4

    open  = instance:addStream("open",  core.Line, name .. ".open",  "open",  Color[1], source:first())
    high  = instance:addStream("high",  core.Line, name .. ".high",  "high",  Color[1], source:first())
    low   = instance:addStream("low",   core.Line, name .. ".low",   "low",   Color[1], source:first())
    close = instance:addStream("close", core.Line, name .. ".close", "close", Color[1], source:first())

    instance:createCandleGroup("Candles", "Candles", open, high, low, close)
end

function Update(period, mode)
    for i = 1, 3 do
        ma[i]:update(mode)
    end

    if not (ma[1].DATA:hasData(period) and ma[2].DATA:hasData(period) and ma[3].DATA:hasData(period)) then
        return
    end

    local closePrice = source.close[period]
    local maValues = {ma[1].DATA[period], ma[2].DATA[period], ma[3].DATA[period]}
    table.sort(maValues)

    local c
    if closePrice < maValues[1] then
        c = Color[1]
    elseif closePrice < maValues[2] then
        c = Color[2]
    elseif closePrice < maValues[3] then
        c = Color[3]
    else
        c = Color[4]
    end

    open[period]  = source.open[period]
    high[period]  = source.high[period]
    low[period]   = source.low[period]
    close[period] = source.close[period]
    open:setColor(period, c)
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75940


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