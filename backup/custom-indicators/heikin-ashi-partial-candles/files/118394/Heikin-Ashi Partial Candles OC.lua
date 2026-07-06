-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65832

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Heikin-Ashi Partial Candles OC")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator:setTag("replaceSource", "t")

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("Type", "Type of candles", "", "OHLC")
    indicator.parameters:addStringAlternative("Type", "OHLC", "", "OHLC")
    indicator.parameters:addStringAlternative("Type", "OLC", "", "OLC")
    indicator.parameters:addStringAlternative("Type", "OHC", "", "OHC")
    indicator.parameters:addStringAlternative("Type", "OHL", "", "OHL")
    indicator.parameters:addStringAlternative("Type", "HLC", "", "HLC")
    indicator.parameters:addStringAlternative("Type", "HC", "", "HC")
    indicator.parameters:addStringAlternative("Type", "LC", "", "LC")
    indicator.parameters:addStringAlternative("Type", "OL", "", "OL")
    indicator.parameters:addStringAlternative("Type", "OH", "", "OH")
    indicator.parameters:addStringAlternative("Type", "OC", "", "OC")
    indicator.parameters:addStringAlternative("Type", "OC with Min/Max", "", "OC_max_max")
    indicator.parameters:addStringAlternative("Type", "C", "", "C")
    indicator.parameters:addStringAlternative("Type", "O", "", "O")
end

local first
local source = nil
local type
local HA

function Prepare()
    source = instance.source
    type = instance.parameters.Type
    first = source:first()
    local name = profile:id() .. "(" .. source:name() .. " " .. type .. ")"
    instance:name(name)
    HA = core.indicators:create("HA", source)
    open = instance:addInternalStream(first, 0)
    close = instance:addInternalStream(first, 0)
    high = instance:addInternalStream(first, 0)
    low = instance:addInternalStream(first, 0)
    instance:createCandleGroup("Partial candles", "", open, high, low, close)
end

local last_serial;

function Update(period, mode)
    HA:update(mode)
    if (period > first) then
        if type == "OHLC" then
            open[period]  = HA.open[period]
            close[period] = HA.close[period]
            high[period]  = HA.high[period]
            low[period]   = HA.low[period]
        elseif type == "OLC" then
            open[period]  = HA.open[period]
            close[period] = HA.close[period]
            high[period]  = math.max(open[period], close[period])
            low[period]   = HA.low[period]
        elseif type == "OHC" then
            open[period]  = HA.open[period]
            close[period] = HA.close[period]
            high[period]  = HA.high[period]
            low[period]   = math.min(open[period], close[period])
        elseif type == "OHL" then
            open[period]  = HA.open[period]
            close[period] = open[period]
            high[period]  = HA.high[period]
            low[period]   = HA.low[period]
        elseif type == "HLC" then
            close[period] = HA.close[period]
            open[period]  = close[period]
            high[period]  = HA.high[period]
            low[period]   = HA.low[period]
        elseif type == "HC" then
            close[period] = HA.close[period]
            open[period]  = close[period]
            high[period]  = HA.high[period]
            low[period]   = close[period]
        elseif type == "LC" then
            close[period] = HA.close[period]
            open[period]  = close[period]
            high[period]  = close[period]
            low[period]   = HA.low[period]
        elseif type == "OL" then
            open[period]  = HA.open[period]
            close[period] = open[period]
            high[period]  = open[period]
            low[period]   = HA.low[period]
        elseif type == "OH" then
            open[period]  = HA.open[period]
            close[period] = open[period]
            high[period]  = HA.high[period]
            low[period]   = open[period]
        elseif type == "OC" then
            open[period]  = HA.open[period]
            close[period] = HA.close[period]
            high[period]  = math.max(open[period], close[period])
            low[period]   = math.min(open[period], close[period])
        elseif type == "OC_max_max" then
            open[period]  = HA.open[period]
            close[period] = HA.close[period]
            if last_serial ~= source:serial(period) then
                high[period] = math.max(open[period], close[period])
                low[period]  = math.min(open[period], close[period])
                last_serial = source:serial(period)
                if period > first then
                    high[period - 1] = math.max(open[period - 1], close[period - 1])
                    low[period - 1]  = math.min(open[period - 1], close[period - 1])
                end
            else
                high[period] = math.max(high[period], math.max(open[period], close[period]))
                low[period]  = math.min(low[period], math.min(open[period], close[period]))
            end
        elseif type == "C" then
            close[period] = HA.close[period]
            open[period]  = close[period]
            high[period]  = close[period]
            low[period]   = close[period]
        elseif type == "O" then
            open[period]  = HA.open[period]
            close[period] = open[period]
            high[period]  = open[period]
            low[period]   = open[period]
        end
    end
end
