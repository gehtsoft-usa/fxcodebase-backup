-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 3469

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Hodrick-Prescott Filter");
    indicator:description("Hodrick-Prescott Filter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Filter", "HP Filter Period", "", 50);
    indicator.parameters:addInteger("Bars", "Max Bars to calculate", "", 300, 100, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("HPF_color", "Color of HPF", "Color of HPF", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "DEMA Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local bars;

local first;
local source = nil;

local HPF = nil;
local lambda;

-- Routine
function Prepare(nameOnly)
    Filter = instance.parameters.Filter;
    bars = instance.parameters.Bars;
    source = instance.source;
    first = source:first();

    lambda = 0.0625 / (math.sin(3.14159265 / Filter) ^ 4);

    local name = profile:id() .. "(" .. source:name() .. "," .. Filter .. "," .. bars .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    assert(source:first() == 0, "The indicator can be applied on the price data only");

    HPF = instance:addStream("HPF", core.Line, name, "HPF", instance.parameters.HPF_color, 0, -1);
    HPF:setWidth(instance.parameters.width);
    HPF:setStyle(instance.parameters.style);
end

local last = nil;
local last_period = 0;

function Update(period, mode)
    if last_period > period then
        last = nil;
    end
    last_period = period;

    -- update only on the last period and only once per bar
    if period == source:size() - 1 and period > 6 and (last == nil or last ~= source:serial(period)) then
        HPFF(period - 1, math.min(period - 1, bars));
        last = source:serial(period);
    end
end

function HPFF(N, max)
    local i;
    local h1 = 0;
    local h2 = 0;
    local h3 = 0;
    local h4 = 0;
    local h5 = 0;
    local hh1 = 0;
    local hh2 = 0;
    local hh3 = 0;
    local hh5 = 0;
    local hb = 0;
    local hc = 0;
    local z = 0;
    local a, b, c;
    local close = source.close;

    local ifirst;

    ifirst = N - max + 1;

    a = {};
    b = {};
    c = {};

    a[1] = 1 + lambda;
    b[1] = -2 * lambda;
    c[1] = lambda;

    for i = 2, max - 2, 1 do
        a[i] = 6 * lambda + 1;
        b[i] = -4 * lambda;
        c[i] = lambda;
    end

    a[2] = 5 * lambda + 1;
    a[max - 1] = 5 * lambda + 1;
    a[max] = 1 + lambda;

    b[max - 1] = -2 * lambda;
    b[max] = 0;

    c[max - 1] = 0;
    c[max] = 0;

    for i = 1, max, 1 do
        z = a[i] - h4 * h1 - hh5 * hh2;
        hb = b[i];
        hh1 = h1;

        if z ~= 0 then
            h1 = (hb - h4 * h2) / z;
        end

        b[i] = h1;
        hc = c[i];
        hh2 = h2;

        if z ~= 0 then
            h2 = hc / z;
        end

        c[i] = h2;

        if z ~= 0 then
            a[i] = (close[ifirst + i - 1] - hh3 * hh5 - h3 * h4) / z;
        end

        hh3 = h3;
        h3 = a[i];
        h4 = hb - h5 * hh1;
        hh5 = h5;
        h5 = hc;
    end

    h2 = 0;
    h1 = a[1];
    local j;
    for i = max, 1, -1 do
      j = ifirst + i - 1;
      HPF[j] = a[i] - b[i] * h1 - c[i] * h2;
      h2 = h1;
      h1 = HPF[j];
    end

    core.eraseStream(HPF, core.range(0, ifirst - 1));
end
