-- Id: 25054
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68486

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("Regression Slope")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("period", "Regression Period", "", 7, 2, 100000)

    indicator.parameters:addGroup("Line Style")
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5)
end

local first
local source = nil
local out;
local indi;
-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end

    source = instance.source;

    local profile = core.indicators:findIndicator("REGRESSION");
    assert(profile ~= nil, "Please, download and install " .. "REGRESSION" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indicatorParams:setInteger("N", instance.parameters.period);
    indi = core.indicators:create("REGRESSION", source, indicatorParams)

    out = instance:addStream("Slope", core.Line, "Slope", "Slope", instance.parameters.color1, 0)
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    out:setWidth(instance.parameters.width1)
    out:setStyle(instance.parameters.style1)
end

function Update(period, mode)
    indi:update(mode)
    if period < 1 or not indi.DATA:hasData(period - 1) then
        return;
    end
    out[period] = indi.DATA[period] - indi.DATA[period - 1];
end