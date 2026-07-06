-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3729
-- Id: 3436

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Cumulative Price Bar")
    indicator:description("Cumulative Price Bar")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addString("Type", "Type", "", "Smoothed")
    indicator.parameters:addStringAlternative("Type", "Smoothed", "", "Smoothed")
    indicator.parameters:addStringAlternative("Type", "Historic", "", "Historic")

    indicator.parameters:addInteger("FRAME", "Period", "", 4)

    indicator.parameters:addString("Method", "Method", "", "MVA")
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder")
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA")
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA")
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA")
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA")
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA")
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA")
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3")
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend")
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median")
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean")
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA")
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS")
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2")
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen")
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth")
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local FRAME
local Type

local first
local source = nil

local Indicator = {}

-- Streams block
local open, close, high, low

-- Routine
function Prepare(nameOnly)
    FRAME = instance.parameters.FRAME
    source = instance.source

    Type = instance.parameters.Type
    Method = instance.parameters.Method

    local name

    if Type == "Smoothed" then
        assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator")
        name =
            profile:id() ..
            "(" .. source:name() .. ", " .. tostring(FRAME) .. ", " .. tostring(Method) .. ", " .. tostring(Type) .. ")"
        instance:name(name)
        if nameOnly then
            return;
        end

        Indicator["O"] = core.indicators:create("AVERAGES", source.open, Method, FRAME, false)
        Indicator["C"] = core.indicators:create("AVERAGES", source.close, Method, FRAME, false)
        Indicator["H"] = core.indicators:create("AVERAGES", source.high, Method, FRAME, false)
        Indicator["L"] = core.indicators:create("AVERAGES", source.low, Method, FRAME, false)
        first = Indicator["L"].DATA:first()
    else
        name = profile:id() .. "(" .. source:name() .. ", " .. tostring(FRAME) .. ", " .. tostring(Type) .. ")"
        instance:name(name)
        first = source:first() + FRAME
		
		if nameOnly then
            return;
        end
    end

    
        open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), FRAME)
        high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), FRAME)
        low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), FRAME)
        close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), FRAME)
		
		open:setPrecision(math.max(2, instance.source:getPrecision()));
		high:setPrecision(math.max(2, instance.source:getPrecision()));
		low:setPrecision(math.max(2, instance.source:getPrecision()));
		close:setPrecision(math.max(2, instance.source:getPrecision()));
        instance:createCandleGroup("ZONE", "", open, high, low, close)
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= FRAME and source:hasData(period) then
        if Type == "Smoothed" then
            Indicator["O"]:update(mode)
            Indicator["C"]:update(mode)
            Indicator["H"]:update(mode)
            Indicator["L"]:update(mode)

            open[period] = Indicator["O"].DATA[period]
            close[period] = Indicator["C"].DATA[period]
            high[period] = Indicator["H"].DATA[period]
            low[period] = Indicator["L"].DATA[period]
        else
            open[period] = source.open[period - FRAME]
            close[period] = source.close[period]
            high[period] = mathex.max(source.high, period - FRAME, period)
            low[period] = mathex.min(source.low, period - FRAME, period)
        end
    end
end
