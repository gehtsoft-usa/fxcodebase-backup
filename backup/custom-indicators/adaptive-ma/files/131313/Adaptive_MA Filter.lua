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
    indicator:name("Adaptive MA Filter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("Length", "Length", "", 10);
    indicator.parameters:addDouble("Pcnt", "Pcnt", "", 2);

    indicator.parameters:addColor("amaf_color", "AMA Filter Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("amaf_width", "AMA Filter Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("amaf_style", "AMA Filter Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("amaf_style", core.FLAG_LINE_STYLE);
end

local ama, amaf, data;
local source, Length, Pcnt;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Pcnt = instance.parameters.Pcnt;
    Length = instance.parameters.Length;
    local profile = core.indicators:findIndicator("ADAPTIVE_MA");
    assert(profile ~= nil, "Please, download and install " .. "ADAPTIVE_MA" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    ama = core.indicators:create("ADAPTIVE_MA", source, instance.parameters.Length)

    amaf = instance:addStream("AMAF", core.Line, "AMAF", "AMAF", instance.parameters.amaf_color, 0, 0);
    amaf:setWidth(instance.parameters.amaf_width);
    amaf:setStyle(instance.parameters.amaf_style);

    data = instance:addInternalStream(0, 0);
end

function Update(period, mode)
    ama:update(mode);
    if period < 1 or not ama.DATA:hasData(period - 1) then
        return;
    end
    data[period] = ama.DATA[period] - ama.DATA[period - 1];
    if period < Length then
        return;
    end
    amaf[period] = mathex.stdev(data, period - Length, period) * Pcnt;
end