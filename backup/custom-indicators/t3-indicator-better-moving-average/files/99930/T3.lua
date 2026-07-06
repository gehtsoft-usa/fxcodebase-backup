
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62129

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


-- Source: Tillson, Tim: Smoothing Techniques for More Accurate Signals. In S&C 57425 (1998), Nr. 1, P. 57
-- Implemented for FXCM's Trading Station by STS Trading on April 2015
-- Contact via twitter: https://twitter.com/ststradingblog

-- General global used variables.
local N;
local V;
local C;

-- Source stream.
local Source = nil;
local First;
local TFirst;

-- External indicators and output stream.
local EMA = {};
local EMAStream = {};
local T;

-- Prepare the user input parameters.
function Init()
    indicator:name("T3");
    indicator:description("Moving average with vigorous smoothing and scant retardation.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("n", "Period", "Number of periods." , 3, 1, 1000);
    indicator.parameters:addDouble("v", "Velocity", "Velocity factor." , 0.618, 0.001, 100.000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color", "Color of T3 line.", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Width", "Width", "Width of T3 line.", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Style", "Style of T3 line.", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
end

-- Read the parameters and set up the global variables, indicators and 
-- output stream.
function Prepare(nameOnly)
    N = instance.parameters.n;
    V = instance.parameters.v;
    C = {-1 * math.pow(V, 3), 
         3 * math.pow(V, 2) + 3 * math.pow(V, 3), 
         -6 * math.pow(V, 2) - 3 * V - 3 * math.pow(V, 3), 
         1 + 3 * V + math.pow(V, 3) + 3 * math.pow(V, 2)};

    Source = instance.source; 
    First = Source:first();
    TFirst = First + 6 * math.floor(1.5 * N);

    local name = profile:id() .. "(" .. Source:name() .. ", " .. N .. ", " .. V .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
        EMA[1] = core.indicators:create("EMA", Source.close, N);
        EMAStream[1] = EMA[1]:getStream(0);
        for i = 2, 6 do
            EMA[i] = core.indicators:create("EMA", EMAStream[i - 1], N);
            EMAStream[i] = EMA[i]:getStream(0);
        end
        T = instance:addStream("T", core.Line, name .. ".T", "T", instance.parameters.Color, First);
        T:setWidth(instance.parameters.Width);
        T:setStyle(instance.parameters.Style);
  
end

-- Main loop calculating the output stream.
function Update(Period, Mode)
    if Period < First then
        return;
    end

    -- Update the external indicators.
    for i = 1, 6 do
        EMA[i]:update(core.UpdateLast);
    end

    -- Calculate the T3 line:
    -- T3(n) = GD(GD(GD(n))) and GD(n,v) = EMA(n) * (1 + v) - EMA(EMA(n)) * v
    -- Implemented as followed:
    -- EMA[1] = EMA(Source, n) and EMA[i] = EMA(EMA, i - 1)
    -- T3 = -v^3 * EMA[6] + (3 * v^2 + 3 * v^3) * EMA[5] + 
    --      (-6 * v^2 - 3 * v - 3 * v^3) * EMA[4] + 
    --      (1 + 3 * v + v^3 + 3 * v^2) * EMA[3]
    if Period >= TFirst then
        T[Period] = 0;
        for i = 1, 4 do
            T[Period] = T[Period] + C[i]* EMAStream[7 - i][Period];
        end
    end
end
