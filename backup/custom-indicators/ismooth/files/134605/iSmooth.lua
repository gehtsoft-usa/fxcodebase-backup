-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69966

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("iSmooth")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("length", "Length", "", 7)
    indicator.parameters:addInteger("phase", "Phase", "", 100)

    indicator.parameters:addColor("out_color", "Color", "Color", core.colors().Red)
    indicator.parameters:addInteger("out_width", "Width", "Width", 1, 1, 5)
    indicator.parameters:addInteger("out_style", "Style", "Style", core.LINE_SOLID)
    indicator.parameters:setFlag("out_style", core.FLAG_LINE_STYLE)
end

local source, length, out, buffer0, buffer1, buffer2, buffer3, bsmax, bsmin, volty, vsum, avolty, phase
function Prepare(nameOnly)
    source = instance.source
    local name = string.format("%s(%s)", profile:id(), source:name())
    instance:name(name)
    if nameOnly then
        return
    end
    phase = instance.parameters.phase;
    length = instance.parameters.length
    out = instance:addStream("out", core.Line, "Out", "Out", instance.parameters.out_color, 0, 0)
    out:setWidth(instance.parameters.out_width)
    out:setStyle(instance.parameters.out_style)
    buffer0 = instance:addInternalStream(0, 0);
    buffer1 = instance:addInternalStream(0, 0);
    buffer2 = instance:addInternalStream(0, 0);
    buffer3 = instance:addInternalStream(0, 0);
    bsmax = instance:addInternalStream(0, 0);
    bsmin = instance:addInternalStream(0, 0);
    volty = instance:addInternalStream(0, 0);
    vsum = instance:addInternalStream(0, 0);
    avolty = instance:addInternalStream(0, 0);
end

function Update(period, mode)
    if period == 0 then
        buffer0[period] = source[period]
        buffer1[period] = source[period]
        buffer2[period] = source[period]
        buffer3[period] = source[period]
        out[period] = source[period]
        bsmax[period] = source[period]
        bsmin[period] = source[period]
        volty[period] = 0
        vsum[period] = 0
        avolty[period] = 0
        return
    end
    local len1 = math.max(math.log(math.sqrt(0.5 * (length - 1))) / math.log(2.0) + 2.0, 0)
    local pow1 = math.max(len1 - 2.0, 0.5)
    local del1 = source[period] - bsmax[period - 1]
    local del2 = source[period] - bsmin[period - 1]
    local div = 1.0 / (10.0 + 10.0 * (math.min(math.max(length - 10, 0), 100)) / 100)
    local forBar = math.min(period, 10)
    volty[period] = 0
    if (math.abs(del1) > math.abs(del2)) then
        volty[period] = math.abs(del1)
    end
    if (math.abs(del1) < math.abs(del2)) then
        volty[period] = math.abs(del2)
    end
    vsum[period] = vsum[period - 1] + (volty[period] - volty[period - forBar]) * div
    avolty[period] = avolty[period - 1] + (2.0 / (math.max(4.0 * length, 30) + 1.0)) * (vsum[period] - avolty[period - 1])
    local dVolty = 0
    if (avolty[period] > 0) then
        dVolty = volty[period] / avolty[period]
    end
    if (dVolty > math.pow(len1, 1.0 / pow1)) then
        dVolty = math.pow(len1, 1.0 / pow1)
    end
    if (dVolty < 1) then
        dVolty = 1.0
    end
    local pow2 = math.pow(dVolty, pow1)
    local len2 = math.sqrt(0.5 * (length - 1)) * len1
    local Kv = math.pow(len2 / (len2 + 1), math.sqrt(pow2))
    if (del1 > 0) then
        bsmax[period] = source[period]
    else
        bsmax[period] = source[period] - Kv * del1
    end
    if (del2 < 0) then
        bsmin[period] = source[period]
    else
        bsmin[period] = source[period] - Kv * del2
    end
    local R = math.max(math.min(phase, 100), -100) / 100.0 + 1.5
    local beta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    local alpha = math.pow(beta, pow2)
    buffer0[period] = source[period] + alpha * (buffer0[period - 1] - source[period])
    buffer1[period] = (source[period] - buffer0[period]) * (1 - beta) + beta * buffer1[period - 1]
    buffer2[period] = (buffer0[period] + R * buffer1[period])
    buffer3[period] = (buffer2[period] - out[period - 1]) * math.pow((1 - alpha), 2) + math.pow(alpha, 2) * buffer3[period - 1]
    out[period] = (out[period - 1] + buffer3[period])
end
