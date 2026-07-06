-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69035

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
    indicator:name("RSI Divergence Candles V2");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    -- TODO: parameters
	
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

    indicator.parameters:addBoolean("useHL", "Use high/low series for mapping the wicks?", "", false);
    indicator.parameters:addInteger("fast_length", "Fast Length", "", 8);
    indicator.parameters:addInteger("slow_length", "Slow Length", "", 55);
    indicator.parameters:addInteger("smooth", "Smooth", "", 10);
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 70);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 30);

    indicator.parameters:addColor("bull_exp", "Bull + Exp color", "", core.colors().Green);
    indicator.parameters:addColor("bull", "Bull color", "", core.colors().Red);
    indicator.parameters:addColor("exp", "Exp color", "", core.colors().Maroon);
    indicator.parameters:addColor("other", "Other color", "", core.colors().Gray);
end
local Price;
local o, h, l, c;
local source;
local fast_rsi, slow_rsi, smooth_fast_rsi, smooth_slow_rsi, fast_rsi_h, fast_rsi_l, slow_rsi_h, slow_rsi_l;
local useHL, bull_exp, bull, exp, other;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    other = instance.parameters.other;
	
	Price = instance.parameters.Price;
    exp = instance.parameters.exp;
    bull = instance.parameters.bull;
    bull_exp = instance.parameters.bull_exp;
    useHL = instance.parameters.useHL;
    if useHL then
        fast_rsi_h = core.indicators:create("RSI", source.high, instance.parameters.fast_length);
        fast_rsi_l = core.indicators:create("RSI", source.low, instance.parameters.fast_length);
        slow_rsi_h = core.indicators:create("RSI", source.high, instance.parameters.slow_length);
        slow_rsi_l = core.indicators:create("RSI", source.low, instance.parameters.slow_length);
    end
    fast_rsi = core.indicators:create("RSI", source[Price], instance.parameters.fast_length);
    slow_rsi = core.indicators:create("RSI", source[Price], instance.parameters.slow_length);
    smooth_fast_rsi = core.indicators:create("MVA", fast_rsi.DATA, instance.parameters.smooth);
    smooth_slow_rsi = core.indicators:create("MVA", slow_rsi.DATA, instance.parameters.smooth);

    o = instance:addStream("o", core.Line, "O", "O", core.rgb(0, 0, 0), 0, 0);
    h = instance:addStream("h", core.Line, "H", "H", core.rgb(0, 0, 0), 0, 0);
    l = instance:addStream("l", core.Line, "L", "L", core.rgb(0, 0, 0), 0, 0);
    c = instance:addStream("c", core.Line, "C", "C", core.rgb(0, 0, 0), 0, 0);
    instance:createCandleGroup("candle", "candle", o, h, l, c);
end

function Update(period, mode)
    fast_rsi:update(mode);
    slow_rsi:update(mode);
    smooth_fast_rsi:update(mode);
    smooth_slow_rsi:update(mode);
    local rsi_high;
    local rsi_low;
    if useHL then
        fast_rsi_h:update(mode);
        fast_rsi_l:update(mode);
        slow_rsi_h:update(mode);
        slow_rsi_l:update(mode);
        if not fast_rsi_h.DATA:hasData(period) or not slow_rsi_h.DATA:hasData(period) then
            return;
        end
        rsi_high = math.max(fast_rsi_h.DATA[period], slow_rsi_h.DATA[period])
        rsi_low = math.min(fast_rsi_l.DATA[period], slow_rsi_l.DATA[period])
    else
        if not fast_rsi.DATA:hasData(period) or not slow_rsi.DATA:hasData(period) then
            return;
        end
        rsi_high = math.max(fast_rsi.DATA[period], slow_rsi.DATA[period]);
        rsi_low = math.min(fast_rsi.DATA[period], slow_rsi.DATA[period]);
    end
    if not smooth_fast_rsi.DATA:hasData(period - 1) or not smooth_slow_rsi.DATA:hasData(period - 1) then
        return;
    end
    isBull = smooth_fast_rsi.DATA[period] >= smooth_slow_rsi.DATA[period];
    isExp = math.abs(smooth_fast_rsi.DATA[period] - smooth_slow_rsi.DATA[period]) >= 
        math.abs(smooth_fast_rsi.DATA[period - 1] - smooth_slow_rsi.DATA[period - 1]);
    o[period] = smooth_slow_rsi.DATA[period];
    h[period] = rsi_high;
    l[period] = rsi_low;
    c[period] = smooth_fast_rsi.DATA[period];
    if isBull and isExp then
        o:setColor(period, bull_exp);
    elseif isBull and not isExp then
        o:setColor(period, bull);
    elseif not isBull and isExp then
        o:setColor(period, exp);
    else
        o:setColor(period, other);
    end
end
