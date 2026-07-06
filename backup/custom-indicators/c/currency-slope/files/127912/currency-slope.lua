-- Id: 25822
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68792

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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

function Init()
    indicator:name("Currency Slope")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    AddAverages("averages_method", "Method", "MVA")
    indicator.parameters:addInteger("averages_period", "Period", "", 21)
    indicator.parameters:addInteger("atr_period", "ATR period", "", 100)

    indicator.parameters:addColor("color", "Color", "Color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5)
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default)
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA")
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA")
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder")
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA")
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA")
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA")
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA")
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA")
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA")
    indicator.parameters:addStringAlternative(id, "T3", "", "T3")
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend")
    indicator.parameters:addStringAlternative(id, "Median", "", "Median")
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean")
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA")
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS")
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2")
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen")
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth")
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA")
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI")
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA")
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF")
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA")
end

function CreateAverages(method, source, period)
    if
        method == "MVA" or method == "EMA" or method == "ARSI" or method == "KAMA" or method == "LWMA" or
            method == "SMMA" or
            method == "VIDYA"
     then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period)
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator")
    return core.indicators:create("AVERAGES", source, method, period)
end

local indi1, atr
local slope

function Prepare(nameOnly)
    source = instance.source
    local name = string.format("%s(%s)", profile:id(), source:name())
    instance:name(name)
    if nameOnly then
        return
    end

    slope = instance:addStream("slope", core.Line, "Slope", "Slope", instance.parameters.color, 0, 0)
    slope:setPrecision(math.max(2, instance.source:getPrecision()))
    slope:setWidth(instance.parameters.width)
    slope:setStyle(instance.parameters.style)

    atr = core.indicators:create("ATR", source, instance.parameters.atr_period)
    indi1 = CreateAverages(instance.parameters.averages_method, source, instance.parameters.averages_period)
end

function Update(period, mode)
    indi1:update(mode)
    atr:update(mode)
    if period < 1 or not indi1.DATA:hasData(period - 1) then
        return
    end

    local dblPrev = (indi1.DATA[period - 1] * 231 + source.close[period] * 20) / 251
    if atr.DATA[period] ~= nil then
        slope[period] = (indi1.DATA[period] - dblPrev) / atr.DATA[period]
    else
        slope[period] = 0
    end
end
