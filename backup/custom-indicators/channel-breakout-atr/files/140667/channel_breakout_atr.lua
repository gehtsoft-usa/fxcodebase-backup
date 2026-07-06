-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70912

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC |
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
    indicator:name("Channel Breakout ATR")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("Range2", "Range 2", "", 20)
    indicator.parameters:addInteger("Range3", "Range 3", "", 55)
    indicator.parameters:addDouble("atr_factor", "ATR Factor", "", 2)
    indicator.parameters:addInteger("atr_range", "ATR Range", "", 14)
    indicator.parameters:addDouble("add_atr_factor", "Add ATR Factor", "", 0.5)
    indicator.parameters:addDouble("spread", "Spread", "", 0.5)
end

local source,
    UpBuffer2,
    DnBuffer2,
    UpBuffer3,
    DnBuffer3,
    RISK_NxATR,
    add_atr1,
    add_atr2,
    add_atr3,
    atr_range,
    add_atr_factor,
    spread,
    atr_factor,
    Range2,
    Range3
function Prepare(nameOnly)
    Range3 = instance.parameters.Range3
    Range2 = instance.parameters.Range2
    atr_factor = instance.parameters.atr_factor
    spread = instance.parameters.spread
    atr_range = instance.parameters.atr_range
    add_atr_factor = instance.parameters.add_atr_factor
    source = instance.source
    local name = string.format("%s(%s)", profile:id(), source:name())
    instance:name(name)
    if nameOnly then
        return
    end
    UpBuffer2 = instance:addInternalStream(0, 0)
    DnBuffer2 = instance:addInternalStream(0, 0)
    UpBuffer3 = instance:addInternalStream(0, 0)
    DnBuffer3 = instance:addInternalStream(0, 0)
    RISK_NxATR = instance:addInternalStream(0, 0)

    add_atr1 =
        instance:createTextOutput(
        "add_atr1",
        "2nd pos",
        "Wingdings",
        12,
        core.H_Center,
        core.V_Bottom,
        core.colors().DarkOrange
    )
    add_atr2 =
        instance:createTextOutput(
        "add_atr2",
        "3rd pos",
        "Wingdings",
        12,
        core.H_Center,
        core.V_Bottom,
        core.colors().Green
    )
    add_atr3 =
        instance:createTextOutput(
        "add_atr3",
        "4th pos",
        "Wingdings",
        12,
        core.H_Center,
        core.V_Bottom,
        core.colors().Plum
    )
    atr = core.indicators:create("ATR", source, atr_range)
end

function Update(period, mode)
    atr:update(mode)
    if period < Range2 + 1 then
        return
    end
    local min, max = mathex.minmax(source, core.rangeTo(period - 1, Range2))
    UpBuffer2[period] = max
    DnBuffer2[period] = min
    if period < Range3 + 1 then
        return
    end
    min, max = mathex.minmax(source, core.rangeTo(period - 1, Range3))
    UpBuffer3[period] = max
    DnBuffer3[period] = min

    RISK_NxATR[period] = atr_factor * atr.DATA[period] / source:pipSize()

    if core.crossesOver(source.high, UpBuffer2, period) then
        add_atr1:set(period, UpBuffer2[period] + atr.DATA[period] * add_atr_factor, "\159");
        add_atr2:set(period, UpBuffer2[period] + atr.DATA[period] * add_atr_factor * 2, "\159");
        add_atr3:set(period, UpBuffer2[period] + atr.DATA[period] * add_atr_factor * 3, "\159");
    end
    if core.crossesOver(source.high, UpBuffer3, period) then
        add_atr1:set(period, UpBuffer3[period] + atr.DATA[period] * add_atr_factor, "\159");
        add_atr2:set(period, UpBuffer3[period] + atr.DATA[period] * add_atr_factor * 2, "\159");
        add_atr3:set(period, UpBuffer3[period] + atr.DATA[period] * add_atr_factor * 3, "\159");
    end
    if core.crossesUnder(source.low, UpBuffer2, period) then
        add_atr1:set(period, DnBuffer2[period] - (atr.DATA[period] * add_atr_factor) + (spread * source:pipSize()), "\159");
        add_atr2:set(period, DnBuffer2[period] - (atr.DATA[period] * add_atr_factor * 2) + (spread * source:pipSize()), "\159");
        add_atr3:set(period, DnBuffer2[period] - (atr.DATA[period] * add_atr_factor * 3) + (spread * source:pipSize()), "\159");
    end
    if core.crossesUnder(source.low, UpBuffer3, period) then
        add_atr1:set(period, DnBuffer3[period] - (atr.DATA[period] * add_atr_factor) + (spread * source:pipSize()), "\159");
        add_atr2:set(period, DnBuffer3[period] - (atr.DATA[period] * add_atr_factor * 2) + (spread * source:pipSize()), "\159");
        add_atr3:set(period, DnBuffer3[period] - (atr.DATA[period] * add_atr_factor * 3) + (spread * source:pipSize()), "\159");
    end
end
