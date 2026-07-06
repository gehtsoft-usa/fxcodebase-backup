-- Id: 6865

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20429

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Heikin-Ashi Colors");
    indicator:description("The indicator colorizes the candles as the candles would be colored for Heikin-Ashi chart");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
    indicator:setTag("replaceSource", "t");
    indicator.parameters:addColor("Up", "Up-candle color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("Down", "Down-candle color", "", core.COLOR_DOWNCANDLE);
end

local source = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;
local volume = nil;
local open1 = nil;
local high1 = nil;
local low1 = nil;
local close1 = nil;

local first = 0;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first() + 1;

    local name = profile:id() .. "(" .. source:name() .. ")";

    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Line, name .. ".open", "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low" .. ".low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(0, 0, 0), first)
    volume = instance:addStream("volume", core.Line, name .. ".volume", "volume", core.rgb(0, 0, 0), first)

    open1 = instance:addInternalStream(first, 0);
    high1 = instance:addInternalStream(first, 0);
    low1 = instance:addInternalStream(first, 0);
    close1 = instance:addInternalStream(first, 0);

    instance:createCandleGroup(name, "HA", open, high, low, close, volume);
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= first then
        if (period == first) then
            open1[period] = (source.open[period - 1] + source.close[period - 1]) / 2;
        else
            open1[period] = (open1[period - 1] + close1[period - 1]) / 2;
        end
        close1[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
        high1[period] = math.max(open1[period], close1[period], source.high[period]);
        low1[period] = math.min(open1[period], close1[period], source.low[period]);

        open[period] = source.open[period];
        high[period] = source.high[period];
        low[period] = source.low[period];
        close[period] = source.close[period];
        volume[period] = source.volume[period];

        if open1[period] > close1[period] then
            open:setColor(period, instance.parameters.Down);
        else
            open:setColor(period, instance.parameters.Up);
        end
    end
end



