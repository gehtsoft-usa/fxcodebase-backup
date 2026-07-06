-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11079

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
    indicator:name("Day of week separator")
    indicator:description("Day of week separator")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("BeginTime", "Begin time of the day", "", "00:00:00")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Line Color", "Line Color", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("Width", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("Style", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE)

    indicator.parameters:addFile("SoundFile", "Sound File", "", "")
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    indicator.parameters:addBoolean("RecurrentSound", "RecurrentSound", "", false)
end

local first
local source = nil
local BeginT, CandleTime

local Color
local Width
local Style

local SoundFile, RecurrentSound

function Prepare(nameOnly)
    source = instance.source
    Color = instance.parameters.Color
    SoundFile = instance.parameters.SoundFile
    RecurrentSound = instance.parameters.RecurrentSound

    first = source:first() + 2
    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    local BeginTime = instance.parameters.BeginTime
    Color = instance.parameters.Color
    Width = instance.parameters.Width
    Style = instance.parameters.Style

    local Pos = string.find(BeginTime, ":")
    local BeginH = tonumber(string.sub(BeginTime, 1, Pos - 1))
    local restOfTheTime = string.sub(BeginTime, Pos + 1);
    Pos = string.find(restOfTheTime, ":")
    local BeginM = tonumber(string.sub(restOfTheTime, 1, Pos - 1))
    local BeginS = tonumber(string.sub(restOfTheTime, Pos + 1))
    BeginT = (60 * BeginH + BeginM) * 60 + BeginS

    instance:setLabelColor(Color)
    instance:ownerDrawn(true)
end

function DayNumber(period)
    local D = source:date(period)
    local T = core.dateToTable(D)
    local wday = T.wday
    CandleTime = 60 * T.hour + T.min
    if CandleTime < BeginT then
        wday = wday - 1
        if wday < 1 then
            wday = 7
        end
    end
    return wday
end

local Last = ""
function Update(period, mode)
    if period < source:size() - 1 then
        --Will prevent initial alert, when user adds an indicator to the chart.
        return
    end

    local D = source:date(period)
    local T = core.dateToTable(D)
    CandleTime = (60 * T.hour + T.min) * 60

    if CandleTime == BeginT and Last ~= source:serial(period) then
        --Will prevent repeated alerts for the same candle.
        terminal:alertSound(SoundFile, RecurrentSound)
        Last = source:serial(period)
    end
end

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    local First, Last
    First = math.max(context:firstBar(), first)
    Last = math.min(context:lastBar(), source:size())
    local Max = mathex.max(source, First, Last) * 2

    local period
    for period = First, Last, 1 do
        if (period > first) then
            local DN = DayNumber(period)
            local DN2 = DayNumber(period - 1)
            if DN2 ~= DN then
                core.host:execute(
                    "drawLine",
                    period,
                    source:date(period),
                    0,
                    source:date(period),
                    Max,
                    Color,
                    Style,
                    Width
                )
            end
        end
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
