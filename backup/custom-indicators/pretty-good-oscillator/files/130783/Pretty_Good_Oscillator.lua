-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69328

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
    indicator:name("Pretty Good Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("length", "Length", "", 89);

    indicator.parameters:addColor("pgo1_color", "Line 1 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("pgo1_width", "Line 1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("pgo1_style", "Line 1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("pgo1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addInteger("length2", "Length 2", "", 55);
    indicator.parameters:addColor("pgo2_color", "Line 2 Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("pgo2_width", "Line 2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("pgo2_style", "Line 2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("pgo2_style", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addInteger("length3", "Length 3", "", 23);
    indicator.parameters:addColor("pgo3_color", "Line 3 Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("pgo3_width", "Line 3 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("pgo3_style", "Line 3 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("pgo3_style", core.FLAG_LINE_STYLE);
end

local source, sma1, ema1, sma2, ema2, sma3, ema3, tr;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    sma1 = core.indicators:create("MVA", source.close, instance.parameters.length);
    sma2 = core.indicators:create("MVA", source.close, instance.parameters.length2);
    sma3 = core.indicators:create("MVA", source.close, instance.parameters.length3);
    tr = instance:addInternalStream(0, 0);
    ema1 = core.indicators:create("EMA", tr, instance.parameters.length);
    ema2 = core.indicators:create("EMA", tr, instance.parameters.length2);
    ema3 = core.indicators:create("EMA", tr, instance.parameters.length3);

    pgo = instance:addStream("PGO", core.Line, "PGO", "PGO", instance.parameters.pgo1_color, 0, 0);
    pgo:setWidth(instance.parameters.pgo1_width);
    pgo:setStyle(instance.parameters.pgo1_style);

    pgo2 = instance:addStream("PGO2", core.Line, "PGO2", "PGO2", instance.parameters.pgo2_color, 0, 0);
    pgo2:setWidth(instance.parameters.pgo2_width);
    pgo2:setStyle(instance.parameters.pgo2_style);

    pgo3 = instance:addStream("PGO3", core.Line, "PGO3", "PGO3", instance.parameters.pgo3_color, 0, 0);
    pgo3:setWidth(instance.parameters.pgo3_width);
    pgo3:setStyle(instance.parameters.pgo3_style);
end

function getTrueRange(period)
    local hl = math.abs(source.high[period] - source.low[period]);
    local hc = math.abs(source.high[period] - source.close[period - 1]);
    local lc = math.abs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

function Update(period, mode)
    tr[period] = getTrueRange(period);
    sma1:update(mode);
    sma2:update(mode);
    sma3:update(mode);
    ema1:update(mode);
    ema2:update(mode);
    ema3:update(mode);
    pgo[period] = (source.close[period] - sma1.DATA[period]) / ema1.DATA[period];
    pgo2[period] = (source.close[period] - sma2.DATA[period]) / ema2.DATA[period];
    pgo3[period] = (source.close[period] - sma3.DATA[period]) / ema3.DATA[period];
end
