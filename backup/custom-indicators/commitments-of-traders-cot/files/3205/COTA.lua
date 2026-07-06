-- Id: 3780
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--+------------------------------------------------------------------+

local currencies = {
    ["CAD"] = "!090741",
    ["CHF"] = "!092741",
    ["MXN"] = "!095741",
    ["GBP"] = "!096742",
    ["JPY"] = "!097741",
    ["USD"] = "!098662",
    ["EUR"] = "!099741",
    ["NZD"] = "!112741",
    ["AUD"] = "!232741",
    ["RUB"] = "!089741"
}

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("COTA")
    indicator:description("Commitments of Traders Autoselect")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addBoolean("Cumulative", "Combined", "Combined", true)
    indicator.parameters:addBoolean("Relative", "Relative", "Relative", false)
    indicator.parameters:addString("segment", "Investor Type", "Investor Type", "Noncommercial")
    indicator.parameters:addStringAlternative(
        "segment",
        "Investor Type Noncommercial",
        "Investor Type Noncommercial",
        "Noncommercial"
    )
    indicator.parameters:addStringAlternative(
        "segment",
        "Investor Type Commercial",
        "Investor Type Commercial",
        "Commercial"
    )

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("COTl", "COT Long", "Color for Long values of COT indicator", core.rgb(255, 0, 0))
    indicator.parameters:addColor("COTs", "COT Short", "Color for Short values of COT indicator.", core.rgb(0, 255, 0))
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local COTl
local COTs
local host = "www.fxcodebase.com"
local Cumulative
local Relative
local segment

local first
local source = nil

-- Streams block
local COT = nil
local COTLong = nil
local COTShort = nil

local COT1 = nil
local COT2 = nil
local instrument1, instrument2
local pauto = "(%a%a%a)/(%a%a%a)"

-- Routine
function Prepare(nameOnly)
    COTl = instance.parameters.COTl
    COTs = instance.parameters.COTs
    Cumulative = instance.parameters.Cumulative
    Relative = instance.parameters.Relative
    segment = instance.parameters.segment
    source = instance.source
    first = source:first()

    local crncy1, crncy2 = string.match(source:name(), pauto)

    instrument1 = currencies[crncy1]
    instrument2 = currencies[crncy2]

    if instrument1 == nil and instrument2 == nil then
        error("Unsupported instrument.")
    end

    local label = ""
    if instrument1 ~= nil then
        label = crncy1
        assert(core.indicators:findIndicator("COT") ~= nil, "COT" .. " indicator must be installed")
        COT1 = core.indicators:create("COT", source, instrument1, Cumulative, false, segment)
        first = math.max(first, COT1.DATA:first())
    end
    if instrument2 ~= nil then
        label = label .. "-" .. crncy2
        COT2 = core.indicators:create("COT", source, instrument2, Cumulative, false, segment)
        first = math.max(first, COT2.DATA:first())
    end

    local name =
        profile:id() ..
        "(" ..
            label ..
                ", " ..
                    segment ..
                        ", " ..
                            (Relative and "Relative" or "Absolute") ..
                                ", " .. (Cumulative and "Combined" or "Separated") .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    if Cumulative then
        COT = instance:addStream("COT", core.Bar, name .. ".COT", "COT", instance.parameters.COTl, first)
        COT:setPrecision(math.max(2, instance.source:getPrecision()))
    else
        COTLong =
            instance:addStream("COTLong", core.Bar, name .. ".COTLong", "COTLong", instance.parameters.COTl, first)
        COTShort =
            instance:addStream("COTShort", core.Bar, name .. ".COTShort", "COTShort", instance.parameters.COTs, first)

        COTLong:setPrecision(math.max(2, instance.source:getPrecision()))
        COTShort:setPrecision(math.max(2, instance.source:getPrecision()))
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    --core.host:execute ("setStatus", instrument1)
    if period < first then
        return
    end

    if COT1 ~= nil then
        COT1:update(mode)
    end
    if COT2 ~= nil then
        COT2:update(mode)
    end

    if period < first then
        return
    end

    local denominator = 0

    if Cumulative then
        COT[period] = 0
        if COT1 ~= nil then
            COT[period] = COT1.DATA[period]
            denominator = math.abs(COT1.DATA[period])
        end
        if COT2 ~= nil then
            COT[period] = COT[period] - COT2.DATA[period]
            denominator = denominator + math.abs(COT2.DATA[period])
        end

        if Relative then
            denominator = denominator / 100
            COT[period] = COT[period] / denominator
        end
    else
        COTLong[period] = 0
        COTShort[period] = 0
        if COT1 ~= nil then
            COTLong[period] = COT1:getStream(0)[period]
            denominator = math.abs(COT1:getStream(0)[period])
            COTShort[period] = COT1:getStream(1)[period]
            denominator = denominator + math.abs(COT1:getStream(1)[period])
        end
        if COT2 ~= nil then
            COTLong[period] = COTLong[period] - COT2:getStream(1)[period]
            denominator = denominator + math.abs(COT2:getStream(1)[period])
            COTShort[period] = (COTShort[period] - COT2:getStream(0)[period])
            denominator = denominator + math.abs(COT2:getStream(0)[period])
        end

        if Relative then
            denominator = denominator / 100
            COTShort[period] = COTShort[period] / denominator
            COTLong[period] = COTLong[period] / denominator
        end
    end
end
