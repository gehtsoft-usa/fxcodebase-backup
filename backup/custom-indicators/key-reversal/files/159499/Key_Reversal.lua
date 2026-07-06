-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63114

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
    indicator:name("Key Reversal")
    indicator:description("Key Reversal")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addBoolean("Trend", "Use Trend Filter", "", true)
    indicator.parameters:addInteger("Period", "Trend Period", "", 2)
    indicator.parameters:addString("gap_filter", "Gap filter", "", "off");
    indicator.parameters:addStringAlternative("gap_filter", "Off", "", "off");
    indicator.parameters:addStringAlternative("gap_filter", "With out gap", "", "wogap");
    indicator.parameters:addStringAlternative("gap_filter", "With gap", "", "wgap");
    indicator.parameters:addInteger("Size", "Font Size", "", 10)
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0))
end

local ArrowSize
local source
local Up, Down
local font, Size
local Trend
local gap_filter
function Prepare(nameOnly)
    gap_filter = instance.parameters.gap_filter;
    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Size = instance.parameters.Size
    Trend = instance.parameters.Trend
    Period = instance.parameters.Period
    local name = profile:id() .. "," .. instance.source:name() .. "," .. Period
    instance:name(name)

    if (nameOnly) then
        return
    end

    font = core.host:execute("createFont", "Wingdings", Size, false, false)

    source = instance.source
    first = source:first()
end

function ReleaseInstance()
    core.host:execute("deleteFont", font)
end

function Update(period)
    core.host:execute("removeLabel", source:serial(period))

    if period < first then
        return
    end

    if Verification(period) == 1 then
        core.host:execute(
            "drawLabel1",
            source:serial(period),
            source:date(period),
            core.CR_CHART,
            source.low[period],
            core.CR_CHART,
            core.H_Center,
            core.V_Bottom,
            font,
            Up,
            "\225"
        )
    end
    if Verification(period) == -1 then
        core.host:execute(
            "drawLabel1",
            source:serial(period),
            source:date(period),
            core.CR_CHART,
            source.high[period],
            core.CR_CHART,
            core.H_Center,
            core.V_Top,
            font,
            Down,
            "\226"
        )
    end
end

function Verification(period)
    local Signal = 0
    if source.close[period] > source.high[period - 1] then
        Signal = 1
    end

    if source.close[period] < source.low[period - 1] then
        Signal = -1
    end

    if gap_filter == "wpag" then
        if Signal == 1 and source.open[period] >= source.close[period - 1] then
            Signal = 0;
        elseif Signal == -1 and source.open[period] <= source.close[period - 1] then
            Signal = 0;
        end
    elseif gap_filter == "wopag" then
        if source.open[period] == source.close[period - 1] then
            Signal = 0;
        end
    end

    if not Trend then
        return Signal
    end

    for i = 1, Period, 1 do
        if Signal == 1 and source.close[period - i] > source.open[period - i] then
            Signal = 0
            break
        end

        if Signal == -1 and source.close[period - i] < source.open[period - i] then
            Signal = 0
            break
        end
    end

    return Signal
end
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63114

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