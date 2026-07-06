-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=139

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Gann Hi-lo Activator SSL")
    indicator:description("When red line is above the candle, sell.When red line is below the canle, buy.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("N", "Number of periods", "The number of periods.", 10, 1, 1000)

    indicator.parameters:addGroup("Style")

    indicator.parameters:addColor("Up", "Up Line Color", "Color of the Up line.", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Dn", "Up Line Color", "Color of the Up line.", core.rgb(255, 0, 0))

    indicator.parameters:addInteger("width", " Grid Line Width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", " Grid Style", " ", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams

-- Parameters block
local first
local source = nil
local pips

-- Streams block
local SSL = nil

-- Internal streams and indicators
local maHigh = nil
local maLow = nil
local hlvStream = nil

-- Routine
function Prepare(nameOnly)
    source = instance.source
    local n = instance.parameters.N
    first = n + source:first()

    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    maHigh = core.indicators:create("MVA", source.high, n)
    maLow = core.indicators:create("MVA", source.low, n)

    SSL = instance:addStream("SSL", core.Line, name, "SSL", instance.parameters.Up, first)
    SSL:setWidth(instance.parameters.width)
    SSL:setStyle(instance.parameters.style)
    hlvStream = instance:addInternalStream(first - 1)
end

-- Indicator calculation routine
function Update(period, mode)
    maHigh:update(mode)
    maLow:update(mode)

    if period >= first then
        local close = source.close[period]
        local maHighVal = maHigh.DATA[period - 1]
        local maLowVal = maLow.DATA[period - 1]
        local hld = 0
        local hlv

        if close > maHighVal then
            hld = 1
        elseif close < maLowVal then
            hld = -1
        end

        SSL:setColor(period, SSL:colorI(period - 1))

        hlv = hlvStream[period - 1]
        if hld ~= 0 then
            hlv = hld
        end

        hlvStream[period] = hlv

        if hlv == -1 then
            SSL[period] = maHighVal
            SSL:setColor(period, instance.parameters.Dn)
        elseif hlv == 1 then
            SSL[period] = maLowVal
            SSL:setColor(period, instance.parameters.Up)
        end
    else
        hlvStream[period] = 0
    end
end
