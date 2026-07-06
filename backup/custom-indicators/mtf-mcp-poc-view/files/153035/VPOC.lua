-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74278
 
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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("VPOC")
    indicator:description("VPOC")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("BoxSize", "Size of price box", "", 5)
    indicator.parameters:addString("box_size_type", "Unit for size of price box", "", "pips");
    indicator.parameters:addStringAlternative("box_size_type", "In pips", "", "pips");
    indicator.parameters:addStringAlternative("box_size_type", "%", "", "percent");
    indicator.parameters:addInteger("bars_limit", "Bars limit", "0 for unlimited", 0, 0, 10000);

    indicator.parameters:addGroup("Style")

    indicator.parameters:addColor("POC", "POC Color", "", core.rgb(127, 127, 127))
    indicator.parameters:addInteger("Size", "Font Size", "", 8)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Size
local BoxSize
local box_size_type;
local source
local first
local s
local e
local BOX
local PocMark
local BarSize
local Signal
local bars_limit
-- Routine
function Prepare(nameOnly)
    BoxSize = instance.parameters.BoxSize
    box_size_type = instance.parameters.box_size_type;
    Size = instance.parameters.Size
    source = instance.source
    bars_limit = instance.parameters.bars_limit;
    first = source:first()

    BOX = BoxSize * source:pipSize()

    local name = profile:id() .. "(" .. source:name() .. ", " .. BoxSize .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
    PocMark = 
        instance:createTextOutput(
        "POC",
        "POC",
        "Wingdings",
        Size,
        core.H_Center,
        core.V_Center,
        instance.parameters.POC,
        0
    )
    Signal = instance:addStream("Signal", core.Line, " Signal", " Signal", instance.parameters.POC, first)
    Signal:setStyle(core.LINE_NONE)
    local s1, e2
    s1, e2 = core.getcandle(source:barSize(), core.now(), 0, 0)
    BarSize = e2 - s1
end

local date
local Filter
local FLAG
-- Indicator calculation routine
function Update(period)
    local Last, LastTable

    local Table

    date = source:date(period)
    Table = core.dateToTable(date)

    Last = source:date(source:size() - 1)
    LastTable = core.dateToTable(Last)

    MP(period, Table.month * 31 + Table.day)
end

function MP(p, n)
    local i, j
    local min, max

    s, e = core.getcandle("D1", date, 0, 0)
    local x = core.findDate(source, s, false)
    local y = core.findDate(source, e, false)
    local old_x = x;
    if bars_limit > 0 then
        x = math.max(old_x, y - bars_limit);
    end

    if (x <= 0 or y < 0) then
        return
    end

    if p < y then
        return
    end

    if not (date >= s and date <= e) then
        return
    end

    if (x <= first or y > source:size() - 1) then
        return
    end
    min, max = mathex.minmax(source, x, y)
    local d1_min, d1_max = mathex.minmax(source, old_x, y);

    local Profile = {}

    for j = x, y, 1 do
        local Count = 0
        local POC = 1
        local box = BOX;
        if box_size_type == "percent" then
            box = (d1_max - d1_min) * BoxSize / 100
        end
        for i = min, max, box do
            Count = Count + 1
            if Profile[Count] == nil then
                Profile[Count] = 0
            end

            if
                i >= source.low[j] and i + box <= source.high[j] or i <= source.low[j] and i + box >= source.low[j] or
                    i <= source.high[j] and i + box >= source.high[j]
             then
                Profile[Count] = Profile[Count] + 1
            end
            core.host:trace(tostring(POC) .. " " .. tostring(Count) .. " " .. tostring(Profile[POC]) .. " " .. tostring(Profile[Count]))
            if i == min then
                POC = Count
            elseif Profile[POC] < Profile[Count] then
                POC = Count
            end

            PocMark:set(j, min + POC * box, "\108")
            Signal[j] = min + POC * box
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