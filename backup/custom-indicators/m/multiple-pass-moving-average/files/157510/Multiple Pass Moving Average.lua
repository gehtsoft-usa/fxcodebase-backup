-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75414

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic    |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- -- +------------------------------------------------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +------------------------------------------------+-----------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +------------------------------------------------+-----------------------------------------------+ 

-- Indicator profile initialization routine
function Init()
    indicator:name("Multiple Pass Moving Average (MPMA)");
    indicator:description("Applies a moving average filter multiple times to achieve higher smoothing.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    -- Parameters
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Window Size", "Number of periods for the moving average.", 14, 1, 1000);
    indicator.parameters:addInteger("P", "Number of Passes", "Number of times to apply the moving average.", 3, 1, 100);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Line Color", "Color of the MPMA line.", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line Width", "Width of the MPMA line.", 2, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "Style of the MPMA line.", core.LINE_SOLID);
end

-- Indicator instance initialization routine
function Prepare()
    local name = profile:id() .. "(" .. instance.source:name() .. ", " .. instance.parameters.N .. ", " .. instance.parameters.P .. ")";
    instance:name(name);
    source = instance.source;
    N = instance.parameters.N; -- Window size
    P = instance.parameters.P; -- Number of passes
    first = source:first() + N * P - 1; -- Ensures enough data for multiple passes
    
    -- Create a stream for the final MPMA line
    mpma = instance:addStream("MPMA", core.Line, name, "MPMA", instance.parameters.clr, first);
    mpma:setWidth(instance.parameters.width);
    mpma:setStyle(instance.parameters.style);
    
    -- Create intermediate streams for the multiple passes
    passes = {};
    for i = 1, P do
        passes[i] = instance:addInternalStream(first, 0);
    end
end

-- Indicator calculation routine
function Update(period, mode)
    -- First pass: simple moving average
    if period >= source:first() + N - 1 then
        local sum = 0;
        for i = period - N + 1, period do
            sum = sum + source.close[i];
        end
        passes[1][period] = sum / N;
    end
    
    -- Subsequent passes: apply moving average on the result of the previous pass
    for p = 2, P do
        if period >= source:first() + N * p - 1 then
            local sum = 0;
            for i = period - N + 1, period do
                sum = sum + passes[p - 1][i];
            end
            passes[p][period] = sum / N;
        end
    end
    
    -- Final result is the last pass
    if period >= first then
        mpma[period] = passes[P][period];
    end
end
-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2024, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- +------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic    |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- +------------------------------------------------------------------------------------------------+
-- |                                                                    We appreciate your support. |
-- +------------------------------------------------------------------------------------------------+
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- -- +------------------------------------------------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +------------------------------------------------+-----------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +------------------------------------------------+-----------------------------------------------+ 