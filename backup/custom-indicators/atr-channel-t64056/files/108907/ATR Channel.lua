-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64056
-- Id: 16952

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
    indicator:name("ATR Channel")
    indicator:description(" ")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addString("Price", "Price Source", "", "open")
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

    indicator.parameters:addInteger("Period", "Period", "", 14)

    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 1)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color1", "Color of Up", "Color of Up", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("color2", "Color of Down", "Color of Down", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Period
local Multiplier
local Price
-- Streams block
local Up = nil
local Down = nil
local ATR

-- Routine
function Prepare(nameOnly)
    source = instance.source
    Price = instance.parameters.Price
    Multiplier = instance.parameters.Multiplier
    Period = instance.parameters.Period

    local name = profile:id() .. "(" .. source:name() .. ", " .. Price .. ", " .. Period .. ", " .. Multiplier .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end

    ATR = core.indicators:create("ATR", source, Period)

    first = ATR.DATA:first()

    if (not (nameOnly)) then
        Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.color1, first)
        Up:setWidth(instance.parameters.width1)
        Up:setStyle(instance.parameters.style1)

        Down = instance:addStream("Dowm", core.Line, name .. ".Down", "Down", instance.parameters.color2, first)
        Down:setWidth(instance.parameters.width2)
        Down:setStyle(instance.parameters.style2)
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    ATR:update(mode)

    if period < first then
        return
    end

    Up[period] = source[Price][period] + ATR.DATA[period] * Multiplier
    Down[period] = source[Price][period] - ATR.DATA[period] * Multiplier
end
