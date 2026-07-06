-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63679

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Support resistance  Profile")
    indicator:description("The indicator calculates how often the price appears in the historical data")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 5)
    indicator.parameters:addInteger("Period", "Period, Zero for all available data", "", 10)

    indicator.parameters:addString("Price", "Wick/Body", "", "Wick")
    indicator.parameters:addStringAlternative("Price", "Wick", "", "Wick")
    indicator.parameters:addStringAlternative("Price", "Body", "", "Body")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addInteger("transparency", "Transparency", "Transparency", 50)
    indicator.parameters:addInteger("Per", "Number of points", "Number of points to display histogram", 50)
    indicator.parameters:addColor("SC", "Support Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("RC", "Resistance Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addBoolean(
        "DisplayOnlyHighest",
        "Display only highest(supp. vs resis.)",
        "Display only the highest number of points (support vs resistance)",
        false
    )
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local BoxSize
local Per
local hTPO = {}
local lTPO = {}
local source = nil
local SC, RC
local first
local Period
local Price
local DisplayOnlyHighest = false

-- Routine
function Prepare(nameOnly)
    BoxSize = instance.parameters.BoxSize
    Period = instance.parameters.Period
    Price = instance.parameters.Price
    DisplayOnlyHighest = instance.parameters.DisplayOnlyHighest

    Per = instance.parameters.Per
    SC = instance.parameters.SC
    RC = instance.parameters.RC
    source = instance.source
    first = source:first()
    source = instance.source
    local name = profile:id() .. "(" .. source:name() .. ", " .. BoxSize .. ")"
    instance:name(name)

    instance:ownerDrawn(true)
end

local prevDate = -1
local Smax = 0
local Rmax = 0
-- Indicator calculation routine
function Update(period)
    if
        (period >= first and Period == 0) or
            ((source:size() - 1 - Period) >= first and period > (source:size() - 1 - Period) and Period ~= 0)
     then
        local date = source:date(period)
        if date < prevDate then
            hTPO = {}
            lTPO = {}
            Smax = 0
            Rmax = 0
        elseif date == prevDate then
            return
        end

        prevDate = date

        -- express in pips

        local High, Low
        if Price == "Wick" then
            High = source.high[period] / source:pipSize()
        else
            High = math.max(source.open[period], source.close[period]) / source:pipSize()
        end

        High = High - High % BoxSize
        local v = rawget(hTPO, High)
        if v == nil then
            v = 0
        end
        v = v + 1
        if v > Rmax then
            Rmax = v
        end
        local v = rawset(hTPO, High, v)

        if Price == "Wick" then
            Low = source.low[period] / source:pipSize()
        else
            Low = math.min(source.open[period], source.close[period]) / source:pipSize()
        end

        Low = Low - Low % BoxSize
        local v = rawget(lTPO, Low)
        if v == nil then
            v = 0
        end
        v = v + 1
        if v > Smax then
            Smax = v
        end
        local v = rawset(lTPO, Low, v)
    end
end

local init = false
local transparency

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        transparency = context:convertTransparency(instance.parameters.transparency)
        context:createSolidBrush(1, SC)
        context:createSolidBrush(2, SC)

        context:createSolidBrush(3, RC)
        context:createSolidBrush(4, RC)
        init = true
    end

    local Max = math.max(Smax, Rmax)

    if DisplayOnlyHighest == true then
        filterHighest(lTPO, hTPO, Max)
    end

    for k, v in pairs(lTPO) do
        local length = v / Max * Per
        visible, y1 = context:pointOfPrice(k * source:pipSize() + BoxSize * source:pipSize())
        visible, y2 = context:pointOfPrice(k * source:pipSize())
        context:drawRectangle(1, 2, context:right() - Per, y1, context:right() - Per + length, y2, transparency)
    end

    for k, v in pairs(hTPO) do
        local length = v / Max * Per
        visible, y1 = context:pointOfPrice(k * source:pipSize() + BoxSize * source:pipSize())
        visible, y2 = context:pointOfPrice(k * source:pipSize())
        context:drawRectangle(3, 4, context:right() - Per - length, y1, context:right() - Per, y2, transparency)
    end
end

function filterHighest(TPO1, TPO2, Max)
    for k1, v1 in pairs(TPO1) do
        for k2, v2 in pairs(TPO2) do
            if k1 == k2 then
                local length1 = v1 / Max * Per
                local length2 = v2 / Max * Per

                if length1 > length2 then
                    TPO2[k2] = nil;
                elseif length1 < length2 then
                    TPO1[k1] = nil;
                else
                    TPO1[k1] = nil;
                    TPO2[k2] = nil;
                end
            end
        end
    end
end
