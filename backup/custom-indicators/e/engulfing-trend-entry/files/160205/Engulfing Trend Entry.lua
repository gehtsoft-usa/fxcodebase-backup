-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76228&sid=fc244519e47db378201178a1b926f1fe

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
function Init()
    indicator:name("Engulfing Trend Entry");
    indicator:description("Trend (MA1 vs MA2) + Engulfing entry, shows Buy/Sell with SL/TP points");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("pFast", "MA1 Period (fast)", "Fast MA length", 21, 1, 9999);
    indicator.parameters:addInteger("pSlow", "MA2 Period (slow)", "Slow MA length", 50, 1, 9999);
    indicator.parameters:addString("meth1", "MA1 Method", "EMA or SMA", "EMA");
    indicator.parameters:addStringAlternative("meth1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("meth1", "SMA", "", "SMA");
    indicator.parameters:addString("meth2", "MA2 Method", "EMA or SMA", "SMA");
    indicator.parameters:addStringAlternative("meth2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("meth2", "SMA", "", "SMA");
    indicator.parameters:addInteger("RR", "RR", "RR", 4, 1, 9999);	
	
    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("clrBuy", "Buy color", "", core.rgb(46, 204, 113));
    indicator.parameters:addColor("clrSell", "Sell color", "", core.rgb(231, 76, 60));
    indicator.parameters:addColor("clrSL", "SL color", "", core.rgb(243, 156, 18));
    indicator.parameters:addColor("clrTP", "TP color", "", core.rgb(52, 152, 219));
end

local src, pFast, pSlow, meth1, meth2;
local fastMA, slowMA;
local close_, open_, high_, low_;
local first;

local buySig, sellSig, slOut, tpOut;

local function createMA(method, source, period)
    if method == "EMA" then
        return core.indicators:create("EMA", source, period);
    else
        -- Simple = MVA
        return core.indicators:create("MVA", source, period);
    end
end

function Prepare()
    src = instance.source;
    open_ = src.open;
    high_ = src.high;
    low_  = src.low;
    close_= src.close;

    pFast = instance.parameters.pFast;
    pSlow = instance.parameters.pSlow;
    meth1 = instance.parameters.meth1;
    meth2 = instance.parameters.meth2;
	RR = instance.parameters.RR;

    fastMA = createMA(meth1, close_, pFast);
    slowMA = createMA(meth2, close_, pSlow);

    local name = profile:id() .. "(" .. src:name() .. ")";
    instance:name(name);

    buySig  = instance:addStream("BUY",  core.Line, name .. ".Buy",  "Buy",  instance.parameters.clrBuy, 0);
    buySig:setWidth(5);	
 

    sellSig = instance:addStream("SELL", core.Line, name .. ".Sell", "Sell", instance.parameters.clrSell, 0);
    sellSig:setWidth(5);	
 

    slOut   = instance:addStream("SL", core.Dot, "SL", "SL", instance.parameters.clrSL, 0);
    slOut:setWidth(5);		
    tpOut   = instance:addStream("TP", core.Dot, "TP", "TP", instance.parameters.clrTP, 0);
    tpOut:setWidth(5);	

    first = math.max(fastMA.DATA:first(), slowMA.DATA:first()) + 1; -- need previous candle too
end

local function isBullEngulf(i)
    -- prev bear, curr bull, body engulfs previous body
    local prevBear = close_[i-1] < open_[i-1];
    local currBull = close_[i]   > open_[i];
    local engulf   = (open_[i] <= close_[i-1]) and (close_[i] >= open_[i-1]);
    return prevBear and currBull and engulf;
end

local function isBearEngulf(i)
    local prevBull = close_[i-1] > open_[i-1];
    local currBear = close_[i]   < open_[i];
    local engulf   = (open_[i] >= close_[i-1]) and (close_[i] <= open_[i-1]);
    return prevBull and currBear and engulf;
end

function Update(period, mode)
    if period < first then
        buySig[period]  = nil;
        sellSig[period] = nil;
        slOut[period]   = nil;
        tpOut[period]   = nil;
        return;
    end

    fastMA:update(mode);
    slowMA:update(mode);

    local trendUp   = fastMA.DATA[period] > slowMA.DATA[period];
    local trendDown = fastMA.DATA[period] < slowMA.DATA[period];

    -- Signals only on closed bar
    local i = period;
    if core.now(mode) == core.Tick then return end

    -- LONG
    if trendUp and isBullEngulf(i) and close_[i] > fastMA.DATA[i] then
        local entry = close_[i];
        local sl    = math.min(low_[i], low_[i-1]);
        local risk  = entry - sl;
        if risk > 0 then
            local tp = entry + RR * risk;
            buySig[i] = entry;
            slOut[i]  = sl;
            tpOut[i]  = tp;
        end
    -- SHORT
    elseif trendDown and isBearEngulf(i) and close_[i] < fastMA.DATA[i] then
        local entry = close_[i];
        local sl    = math.max(high_[i], high_[i-1]);
        local risk  = sl - entry;
        if risk > 0 then
            local tp = entry - RR * risk;
            sellSig[i] = entry;
            slOut[i]   = sl;
            tpOut[i]   = tp;
        end
    else
        buySig[i]  = nil;
        sellSig[i] = nil;
        slOut[i]   = nil;
        tpOut[i]   = nil;
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76228&sid=fc244519e47db378201178a1b926f1fe

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 