-- Id: 24192
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67452

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

-- Indicator profile initialization routine

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
    indicator:name("Gadi OBV")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addBoolean("DrawChannel", "Draw Channel", "", true);
    indicator.parameters:addInteger("StartHour", "Start Hour", "", 0);
    indicator.parameters:addInteger("StartMinute", "Start Minute", "", 0);
    indicator.parameters:addInteger("EndHour", "End Hour", "", 7);
    indicator.parameters:addInteger("EndMinute", "End Minute", "", 0);
    InitStyle("1", "Line 1", core.rgb(0, 0, 255), core.LINE_SOLID, 1);
    InitStyle("2", "Line 2", core.rgb(0, 0, 255), core.LINE_SOLID, 1);
    InitStyle("3", "Line 3", core.rgb(0, 0, 255), core.LINE_SOLID, 1);
end

local source = nil
local DrawChannel;
local StartHour;
local StartMinute;
local EndHour;
local EndMinute;
local out1;
local out2;
local out3;
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name)
    if (nameOnly) then
        return
    end
    DrawChannel = instance.parameters.DrawChannel;
    StartHour = instance.parameters.StartHour;
    StartMinute = instance.parameters.StartMinute;
    EndHour = instance.parameters.EndHour;
    EndMinute = instance.parameters.EndMinute;

    source = instance.source;
    out1 = instance:addStream("out1", core.Line, name, name, GetColor("1"), 0);
    out1:setPrecision(math.max(2, instance.source:getPrecision()));
    SetStyle("1", out1);

    out2 = instance:addStream("out2", core.Line, "Channel High", "Channel High", GetColor("2"), 0);
    out2:setPrecision(math.max(2, instance.source:getPrecision()));
    SetStyle("2", out2);

    out3 = instance:addStream("out3", core.Line, "Channel Low", "Channel Low", GetColor("3"), 0);
    out3:setPrecision(math.max(2, instance.source:getPrecision()));
    SetStyle("3", out3);
end

-- Indicator calculation routine
function Update(period, mode)
    if (period == 0) then
        out1[period] = source.volume[period];
        return;
    end
    local current_close = source.close[period];
    local previous_close = source.close[period - 1];
    out1[period] = out1[period - 1];
    if (current_close < previous_close) then
        if source.high[period] > source.low[period] then
            local val = (source.open[period] - source.close[period]) / (source.high[period] - source.low[period]);
            out1[period] = out1[period - 1] - source.volume[period] * val;
        end
    elseif source.high[period] > source.low[period] then
        local val = (source.close[period] - source.open[period]) / (source.high[period] - source.low[period]);
        out1[period] = out1[period - 1] + source.volume[period] * val;
    end
    if DrawChannel then
        local date = math.floor(source:date(period));
        local dateStart = date + StartHour / 24 + StartMinute / 1440;
        local dateEnd = date + EndHour / 24 + EndMinute / 1440;
        local periodStart = core.findDate(source, dateStart, false);
        local periodEnd = math.min(period, core.findDate(source, dateEnd, false));
        if periodStart == -1 or periodEnd == -1 then
            return;
        end
        local range = core.range(periodStart, periodEnd);
        local min, max = mathex.minmax(out1, range);
        core.drawLine(out2, range, max, periodStart, max, periodEnd);
        core.drawLine(out3, range, min, periodStart, min, periodEnd);
    end
end
