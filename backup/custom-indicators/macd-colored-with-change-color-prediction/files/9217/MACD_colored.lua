-- Id: 3483

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3789

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("Colored MACD");
    indicator:description("Colored MACD with sensitivity and an ability to predict how much pips market shall move to change the color of the bar");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FEMA", "Fast EMA periods", "", 5);
    indicator.parameters:addInteger("SEMA", "Slow EMA periods", "", 13);
    indicator.parameters:addInteger("SMA", "Signal SMA periods", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addDouble("SENS", "Change Color Sensitivity (in pips)", "", 0);
    indicator.parameters:addColor("UP", "Higher Bars Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Lower Bars Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("EQ", "Equal Bar color", "", core.rgb(0, 0, 255));
    indicator.parameters:addBoolean("ShowSignal", "Show Signal Line", "", false);
    indicator.parameters:addColor("SC", "Signal Bar color", "", core.rgb(255, 255, 0));
end

local source;               -- source
local first;                -- first histogram
local firsts;               -- first signal
local fema, sema, diff;     -- fast EMA and slow EMA buffers
local fa, sa;               -- fast alpha, slow alpha
local hist, signal;         -- histogram and signal buffers
local sens;                 -- sensitivity
local sma;                  -- signal MVA
local EQ, UP, DN;           -- colors for histogram
local alive;                -- is price alive?
local point;

function Prepare(nameOnly) 
    local name;

    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.FEMA .. "," .. instance.parameters.SEMA .. "," .. instance.parameters.SMA .. ")";
    instance:name(name);
    if nameOnly then
        return ;
    end

    source = instance.source;
    alive = source:isAlive();
    point = source:pipSize();

    fa = 2 / (instance.parameters.FEMA + 1);
    sa = 2 / (instance.parameters.SEMA + 1);
    sma = instance.parameters.SMA;
    first = source:first();
    firsts = first + sma - 1;

    EQ = instance.parameters.EQ;
    UP = instance.parameters.UP;
    DN = instance.parameters.DN;
    sens = instance.parameters.SENS;

    fema = instance:addInternalStream(first, 0);
    sema = instance:addInternalStream(first, 0);

    hist = instance:addStream("H", core.Bar, name .. ".H", "H", EQ, first);
    hist:setPrecision(math.max(2, instance.source:getPrecision()));
    if instance.parameters.ShowSignal then
        signal = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.SC, firsts);
    signal:setPrecision(math.max(2, instance.source:getPrecision()));
    else
        signal = nil;
    end
end

function Update(period, mode)
    if period < first then
        return ;
    end

    local price = source[period];

    -- calculate fast and slow EMA
    if period == first then
        fema[period] = price;
        sema[period] = price;
    else
        fema[period] = fa * price + (1 - fa) * fema[period - 1];
        sema[period] = sa * price + (1 - sa) * sema[period - 1];
    end

    -- calculate histogram
    hist[period] = fema[period] - sema[period];

    if period > first then
        -- colorize histogram
        if math.abs(hist[period] - hist[period - 1]) / point > sens then
            if hist[period] > hist[period - 1] then
                hist:setColor(period, UP);
            else
                hist:setColor(period, DN);
            end
        else
            hist:setColor(period, EQ);
        end
    end

    if signal ~= nil and period >= firsts then
        if period == firsts then
            if sma == 1 then
                signal[period] = hist[period];
            else
                signal[period] = mathex.avg(hist, period - sma + 1, period);
            end
        else
            signal[period] = signal[period - 1] - hist[period - sma] / sma + hist[period] / sma;
        end
    end

    if alive and period == source:size() - 1 and period > 1 then
        -- find how much pips must be skept to change the color of the bar
        local x = math.floor(((hist[period - 1] - ((1 - fa) * fema[period - 1] - (1 - sa) * sema[period - 1])) / (fa - sa)) / point * 10) / 10;
        if x >= 0.1 then
            core.host:execute("setStatus", string.format("%.1f pips", x - price / point));
        else
            core.host:execute("setStatus", "");
        end
    end
end




