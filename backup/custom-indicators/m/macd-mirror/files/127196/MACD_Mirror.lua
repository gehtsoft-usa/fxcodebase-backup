-- Id: 25442
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68619

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
    indicator:name("MACD Mirror");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("ShortPeriod", "Period", "", 7);
    indicator.parameters:addInteger("SignalPeriod", "Signal MACD period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_Clr", "MACD Color", "MACD Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthMACD", "MACD width", "MACD width", 1, 1, 5);
    indicator.parameters:addInteger("styleMACD", "MACD style", "MACD style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMACD", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("mirror_MACD_Clr", "Mirror MACD Color", "MACD Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("mirror_widthMACD", "Mirror MACD width", "MACD width", 1, 1, 5);
    indicator.parameters:addInteger("mirror_styleMACD", "Mirror MACD style", "MACD style", core.LINE_SOLID);
    indicator.parameters:setFlag("mirror_styleMACD", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_Clr", "Signal Color", "Signal Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSignal", "Signal width", "Signal width", 1, 1, 5);
    indicator.parameters:addInteger("styleSignal", "Signal style", "Signal style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSignal", core.FLAG_LINE_STYLE);
end

local ShortPeriod, LongPeriod, SignalPeriod
local MACD, Signal, Mirror_MACD
local ema_o, ema_c, mva
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    ShortPeriod = instance.parameters.ShortPeriod;
    SignalPeriod = instance.parameters.SignalPeriod;

    local first = 0;
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_Clr, first);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.widthMACD);
    MACD:setStyle(instance.parameters.styleMACD);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_Clr, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.widthSignal);
    Signal:setStyle(instance.parameters.styleSignal);
    Mirror_MACD = instance:addStream("Mirror_MACD", core.Line, name .. ".Mirror_MACD", "Mirror_MACD", instance.parameters.mirror_MACD_Clr, first);
    Mirror_MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    Mirror_MACD:setWidth(instance.parameters.mirror_widthMACD);
    Mirror_MACD:setStyle(instance.parameters.mirror_styleMACD);
    
    ema_o = core.indicators:create("EMA", source.open, ShortPeriod);
    ema_c = core.indicators:create("EMA", source.close, ShortPeriod);
    mva = core.indicators:create("MVA", MACD, SignalPeriod);
end

function Update(period, mode)
    ema_o:update(mode)
    ema_c:update(mode)
    mva:update(mode)

    MACD[period] = ema_c.DATA[period] - ema_o.DATA[period];
    Mirror_MACD[period] = ema_o.DATA[period] - ema_c.DATA[period];
    Signal[period] = mva.DATA[period];
end