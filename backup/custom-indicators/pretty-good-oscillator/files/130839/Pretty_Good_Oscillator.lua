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
 
    tr = instance:addInternalStream(0, 0);
    ema1 = core.indicators:create("EMA", tr, instance.parameters.length);
 

    pgo = instance:addStream("PGO", core.Line, "PGO", "PGO", instance.parameters.pgo1_color, 0, 0);
    pgo:setWidth(instance.parameters.pgo1_width);
    pgo:setStyle(instance.parameters.pgo1_style);

 
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
    ema1:update(mode); 
	
    pgo[period] = (source.close[period] - sma1.DATA[period]) / ema1.DATA[period];
 
end
