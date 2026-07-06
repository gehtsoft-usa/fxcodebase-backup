-- Id: 529
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=876

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("FX5 Divergence Trend");
    indicator:description("Shows MACD Divergence trends");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("MACD_Short", "Period of short EMA for MACD", "", 12);
    indicator.parameters:addInteger("MACD_Long", "Period of long EMA for MACD", "", 26);
    indicator.parameters:addInteger("MACD_Signal", "Signal period of MACD", "", 9);
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;

-- Streams block
local lineid = nil;
local dummy;

-- Routine
function Prepare(nameOnly)
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MACD_Short .. ", " .. instance.parameters.MACD_Long .. ", " .. instance.parameters.MACD_Signal .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator("FX5") ~= nil, "FX5" .. " indicator must be installed");
    MACD = core.indicators:create("FX5", source, instance.parameters.MACD_Short,instance.parameters.MACD_Long,instance.parameters.MACD_Signal, false);
    first = MACD.DATA:first();
    dummy = instance:addStream("D", core.Line, name .. ".D", "D", UP_color, 0);
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)
    local l;
    -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    pperiod1 = source:serial(period)
    period = period - 1;

    MACD:update(mode);

    if MACD:getStream(1):hasData(period - 2) then
        l = math.abs(MACD:getStream(1)[period - 2]);
        local prev = period - 2 - l;
        line_id = line_id + 1;
        core.host:execute("drawLine", line_id, source:date(prev), source.high[prev], source:date(period - 2), source.high[period - 2], UP_color);
    end
    if MACD:getStream(2):hasData(period - 2) then
        l = math.abs(MACD:getStream(2)[period - 2]);
        local prev = period - 2 - l;
        line_id = line_id + 1;
        core.host:execute("drawLine", line_id, source:date(prev), source.low[prev], source:date(period - 2), source.low[period - 2], DN_color);
    end
end

