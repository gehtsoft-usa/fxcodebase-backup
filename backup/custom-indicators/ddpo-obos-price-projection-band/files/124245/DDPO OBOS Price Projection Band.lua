-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67413

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

function InitStyle(id, name, color, style, width)
    indicator.parameters:addColor("color_" .. id, name .. " Color", "", color)
    indicator.parameters:addInteger("style_" .. id, name .. " Style", "", style)
    indicator.parameters:setFlag("style_" .. id, core.FLAG_LEVEL_STYLE)
    indicator.parameters:addInteger("width_" .. id, name .. " Width", "", width, 1, 5)
end

function GetColor(id)
    return instance.parameters:getColor("color_" .. id);
end

function SetStyle(id, stream)
    stream:setWidth(instance.parameters:getInteger("style_" .. id));
    stream:setStyle(instance.parameters:getInteger("width_" .. id));
end

function Init()
    indicator:name("DDPO")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("mva_period", "SMA period", "", 7)
    indicator.parameters:addDouble("sf", "Scaling factor", "", 1);
    indicator.parameters:addDouble("asf", "Scaling factor %avg", "", 90);
    indicator.parameters:addInteger("loopback_period", "Loopback periods", "", 100)
    indicator.parameters:addInteger("max_peaks", "Max peaks", "", 3);
    indicator.parameters:addInteger("min_peaks", "Min peaks", "", 3);

    indicator.parameters:addGroup("Line Style")
    InitStyle("max_ob", "Max.OB", core.rgb(0, 0, 255), core.LINE_SOLID, 1);
    InitStyle("avg_ob", "%Avg.OB", core.rgb(0, 0, 128), core.LINE_SOLID, 1);
    InitStyle("avg_os", "%Avg.OS", core.rgb(128, 0, 0), core.LINE_SOLID, 1);
    InitStyle("max_os", "Max.OS", core.rgb(255, 0, 0), core.LINE_SOLID, 1);
end

local source = nil
local indicator, indicator2;
local sf;
local asf;
local loopback_period;
local max_peaks;
local min_peaks;

local max_ob;
local max_os;
local avg_ob;
local avg_os;
local ddpo;
local mva_period;

function Prepare(nameOnly)
    sf = instance.parameters.sf;
    asf = instance.parameters.asf;
    loopback_period = instance.parameters.loopback_period;
    max_peaks = instance.parameters.max_peaks;
    min_peaks = instance.parameters.min_peaks;
    mva_period = instance.parameters.mva_period;

    local name = string.format("%s (%s)", profile:id(), instance.source:name());
    instance:name(name)
    if (nameOnly) then
        return
    end

    source = instance.source;
    indicator = core.indicators:create("MVA", source, instance.parameters.mva_period)
    indicator2 = core.indicators:create("MVA", source, instance.parameters.mva_period - 1)

    max_ob = instance:addStream("max_ob", core.Line, "Max OB", "Max OB", GetColor("max_ob"), 0, 1)
    SetStyle("max_ob", max_ob);
    max_os = instance:addStream("max_os", core.Line, "Max OS", "Max OS", GetColor("max_os"), 0, 1)
    SetStyle("max_os", max_os);

    avg_ob = instance:addStream("avg_ob", core.Line, "%Avg OB", "%Avg OB", GetColor("avg_ob"), 0, 1)
    SetStyle("avg_ob", avg_ob);
    avg_os = instance:addStream("avg_os", core.Line, "%Avg OS", "%Avg OS", GetColor("avg_os"), 0, 1)
    SetStyle("avg_os", avg_os);

    ddpo = instance:addInternalStream(0, 0);
end

local ob, os;

function IsRising(stream, period)
    return stream[period] > stream[period - 1]
end

function IsFalling(stream, period)
    return stream[period] < stream[period - 1]
end
local levels = {};

function Update(period, mode)
    indicator:update(mode);
    indicator2:update(mode);
    if not indicator.DATA:hasData(period) then
        return;
    end

    ddpo[period] = sf * (source[period] - indicator.DATA[period])
    if period < loopback_period then
        return;
    end
    ob = nil;
    os = nil;
    levels = {};
    for i = period - loopback_period, period do
        if ob == nil or ob < ddpo[i] then
            ob = ddpo[i];
        end
        if os == nil or os > ddpo[i] then
            os = ddpo[i];
        end
        if i ~= period and IsRising(ddpo, i) == IsFalling(ddpo, i + 1) then
            levels[#levels + 1] = ddpo[i];
        end
    end
    table.sort(levels);

    local summ = 0;
    for i = math.max(1, #levels - min_peaks + 1), #levels do
        summ = summ + levels[i];
    end
    max_ob[period + 1] = (levels[#levels] / sf) * (mva_period / (mva_period - 1)) + indicator2.DATA[period];
    avg_ob[period + 1] = asf * (summ / min_peaks) / 100 * (mva_period / (mva_period - 1)) + indicator2.DATA[period];
    
    summ = 0;
    for i = 1, math.min(#levels, max_peaks) do
        summ = summ + levels[i];
    end
    max_os[period + 1] = (levels[1] / sf) * (mva_period / (mva_period - 1)) + indicator2.DATA[period];
    avg_os[period + 1] = asf * (summ / max_peaks) / 100 * (mva_period / (mva_period - 1)) + indicator2.DATA[period];
end
