-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69293

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--|                         https://AppliedMachineLearning.systems   |
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
    indicator:name("PRC_Scalping with Parabolic SAR and Fibonacci");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("plotbar", "Bars duration for plotting the fib zones", "", 10);

    indicator.parameters:addColor("slow_color", "SAR Slow Color", "SAR Slow Color", core.colors().Red);
    indicator.parameters:addInteger("slow_width", "SAR Slow Width", "SAR Slow Width", 1, 1, 5);
    indicator.parameters:addInteger("slow_style", "SAR Slow Style", "SAR Slow Style", core.LINE_SOLID);
    indicator.parameters:setFlag("slow_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("fast_color", "SAR Fast Color", "SAR Fast Color", core.colors().Green);
    indicator.parameters:addInteger("fast_width", "SAR Fast Width", "SAR Fast Width", 1, 1, 5);
    indicator.parameters:addInteger("fast_style", "SAR Fast Style", "SAR Fast Style", core.LINE_SOLID);
    indicator.parameters:setFlag("fast_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("stop_color", "Stop color", "", core.colors().Red);
    indicator.parameters:addColor("limit_color", "Limit color", "", core.colors().Green);
end

local source, sarfast, sarslow, ll, hh, plotbar, fast, slow, stop, limit;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    plotbar = instance.parameters.plotbar;
    sarfast = core.indicators:create("SAR", source, 0.02, 0.02, 0.2);
    sarslow = core.indicators:create("SAR", source, 0.005, 0.005, 0.05);
    stop = instance:addInternalStream(0, 0);
    limit = instance:addInternalStream(0, 0);
    ll = instance:addInternalStream(0, 0);
    hh = instance:addInternalStream(0, 0);

    fast = instance:addStream("FAST", core.Dot, "FAST", "FAST", instance.parameters.fast_color, 0, 0);
    fast:setWidth(instance.parameters.fast_width);
    fast:setStyle(instance.parameters.fast_style);

    slow = instance:addStream("SLOW", core.Dot, "SLOW", "SLOW", instance.parameters.slow_color, 0, 0);
    slow:setWidth(instance.parameters.slow_width);
    slow:setStyle(instance.parameters.slow_style);
    instance:ownerDrawn(true);
end

local init = false;
local STOP_LINE = 1;
local LIMIT_LINE = 2;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(STOP_LINE, context.SOLID, 1, instance.parameters.stop_color);
        context:createPen(LIMIT_LINE, context.SOLID, 1, instance.parameters.limit_color);
        init = true;
    end

    local from_bar = math.max(source:first(), context:firstBar());
    local to_bar = math.min(context:lastBar(), source:size() - 1);
    for i = from_bar, to_bar, 1 do
        if stop:hasData(i) then
            local x_center = context:positionOfBar(i);
            local x_center_2 = context:positionOfBar(i + plotbar);
            local _, stop_y = context:pointOfPrice(stop[i]);
            local _, limit_y = context:pointOfPrice(limit[i]);
            context:drawLine(STOP_LINE, x_center, stop_y, x_center_2, stop_y);
            context:drawLine(LIMIT_LINE, x_center, limit_y, x_center_2, limit_y);
        end
    end
end

function Update(period, mode)
    sarfast:update(mode);
    sarslow:update(mode);
    if sarfast.UP:hasData(period) then
        fast[period] = sarfast.UP[period]
    else
        fast[period] = sarfast.DN[period];
    end
    if sarslow.UP:hasData(period) then
        slow[period] = sarslow.UP[period];
    else
        slow[period] = sarslow.DN[period];
    end
    if period == 0 then
        return;
    end
    if fast:hasData(period) then
        ll[period] = source.low[period];
        if ll:hasData(period - 1) and ll[period - 1] < ll[period] then
            ll[period] = ll[period - 1];
        end
    else
        hh[period] = source.high[period];
        if hh:hasData(period - 1) and hh[period - 1] > hh[period] then
            hh[period] = source.high[period - 1];
        end
    end
    if sarfast.UP:hasData(period) and sarfast.DN:hasData(period - 1) then
        local fibo0 = ll[period];
        ll[period] = slow[period];
        local irange = source.high[period] - fibo0;
        local entry = fibo0 + (irange / 2);
        limit[period] = fibo0 + irange * 1.618;
        stop[period] = fibo0 - 2 * source:pipSize();
    end
    if sarfast.DN:hasData(period) and sarfast.UP:hasData(period - 1) then
        local fibo0 = hh[period];
        hh[period] = nil;
        local irange = fibo0 - source.low[period];
        local entry = fibo0 - (irange / 2);
        limit[period] = fibo0 - irange * 1.618;
        stop[period] = fibo0 + 2 * source:pipSize();
    end
end

