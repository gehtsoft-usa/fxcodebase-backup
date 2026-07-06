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
    indicator:name("Main Trend Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addDouble("min_pips", "Threshold, pips", "", 2);
    indicator.parameters:addDouble("min_bars", "Number of bars", "", 3);
    indicator.parameters:addColor("up_color", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("down_color", "Down Color", "Down Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("up_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("up_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("up_style", core.FLAG_LINE_STYLE);
end

local out, indi;
local up_color, down_color, min_bars;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;
    min_bars = instance.parameters.min_bars;
    min_pips = instance.parameters.min_pips;
    
    local profile = core.indicators:findIndicator("MINOR-TREND LINE");
    assert(profile ~= nil, "Please, download and install " .. "MINOR-TREND LINE" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indicatorParams:setDouble("min_pips", min_pips);
    indicatorParams:setColor("up_color", up_color);
    indicatorParams:setColor("down_color", down_color);
    indi = core.indicators:create("MINOR-TREND LINE", source, indicatorParams)

    out = instance:addStream("out", core.Line, "Trend", "Trend", up_color, 0, 0);
    out:setWidth(instance.parameters.up_width);
    out:setStyle(instance.parameters.up_style);
end

function IsUpTrend(period)
    local last;
    local changes = 0;
    for i = period, 0, -1 do
        if not indi.DATA:hasData(i) or indi.DATA:color(i) ~= up_color then
            return false;
        end
        if last == nil then
            last = indi.DATA[i];
        elseif last ~= indi.DATA[i] then
            changes = changes + 1;
            if changes == min_bars then
                return out[period - 1] < indi.DATA[period];
            end
            last = indi.DATA[i];
        end
    end
    return false;
end

function IsDownTrend(period)
    local last;
    local changes = 0;
    for i = period, 0, -1 do
        if not indi.DATA:hasData(i) or indi.DATA:color(i) ~= down_color then
            return false;
        end
        if last == nil then
            last = indi.DATA[i];
        elseif last ~= indi.DATA[i] then
            changes = changes + 1;
            if changes == min_bars then
                return out[period - 1] > indi.DATA[period];
            end
            last = indi.DATA[i];
        end
    end
    return false;
end

function Update(period, mode)
    if (period < min_bars + 1) then
        return;
    end
    indi:update(mode);

    if IsUpTrend(period) then
        out[period] = source.high[period];
        out:setColor(period, up_color);
    elseif IsDownTrend(period) then
        out[period] = source.low[period];
        out:setColor(period, down_color);
    else
        out[period] = out[period - 1];
        out:setColor(period, out:color(period - 1));
    end
end