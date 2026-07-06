-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68714

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
    indicator:name("Minor Trend Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addDouble("min_pips", "Threshold, pips", "", 2);
    indicator.parameters:addColor("up_color", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("down_color", "Down Color", "Down Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("up_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("up_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("up_style", core.FLAG_LINE_STYLE);
end

local out;
local up_color, down_color;
local hh, ll, min_pips;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;
    min_pips = instance.parameters.min_pips;
    out = instance:addStream("out", core.Line, "Trend", "Trend", up_color, 0, 0);
    out:setWidth(instance.parameters.up_width);
    out:setStyle(instance.parameters.up_style);

    hh = instance:addInternalStream(0, 0);
    ll = instance:addInternalStream(0, 0)
end

function IsUpTrend(period)
    if (out:color(period - 1) ~= down_color) then
        return hh[period - 1] < source.high[period] and ll[period - 1] < source.low[period];
    end
    return (source.high[period] - hh[period - 1]) / source:pipSize() >= min_pips
        and ll[period - 1] < source.low[period];
end

function IsDownTrend(period)
    if (out:color(period - 1) ~= up_color) then
        return hh[period - 1] > source.high[period] and ll[period - 1] > source.low[period];
    end
    return (ll[period - 1] - source.high[period]) / source:pipSize() >= min_pips
        and hh[period - 1] > source.high[period];
end

function Update(period, mode)
    if (period < 1) then
        hh[period] = source.high[period];
        ll[period] = source.low[period];
        return;
    end

    if IsUpTrend(period) then
        out[period] = source.high[period];
        out:setColor(period, up_color);
        hh[period] = source.high[period];
        ll[period] = source.low[period];
    elseif IsDownTrend(period) then
        out[period] = source.low[period];
        out:setColor(period, down_color);
        hh[period] = source.high[period];
        ll[period] = source.low[period];
    else
        out[period] = out[period - 1];
        hh[period] = hh[period - 1];
        ll[period] = ll[period - 1];
        out:setColor(period, out:color(period - 1));
    end
end