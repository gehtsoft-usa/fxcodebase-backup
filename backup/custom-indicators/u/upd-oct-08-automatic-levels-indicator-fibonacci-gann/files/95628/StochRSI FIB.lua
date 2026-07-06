-- Id: 12377
-----------------------------------------------------------
-- Kaizen Confirm

-----------------------------------------------------------

local _gSubscription = {};
local _gUpdatePeriods = {};
local _gLastTime;

-----------------------------------------------------------
-- Standard strategy init handler for marketscope strategy
-----------------------------------------------------------
function Init()
    strategy:name("Kaizen Confirm");

    
    strategy:type(core.Both);
    
    strategy.parameters:addString("Account", "Account", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addBoolean("AllowTrade", "Allow trade", "", false);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("AllowedSide", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("AllowedSide", "Both", "", "Both");
    strategy.parameters:addStringAlternative("AllowedSide", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("AllowedSide", "Sell", "", "Sell");
    strategy.parameters:addBoolean("AllowMultiplePositions", "Allow multiple positions", "", true);
    strategy.parameters:addDouble("Stop", " Stop", "", 0);
    strategy.parameters:addDouble("Limit", " Limit", "", 0);
    strategy.parameters:addGroup("D1TIMER parameters")
    strategy.parameters:addInteger("D1TIMER_N", "Number of periods for RSI", "", 8, 1, 200);
    strategy.parameters:addInteger("D1TIMER_K", "%K Stochastic Periods", "", 5, 1, 200);
    strategy.parameters:addInteger("D1TIMER_KS", "%K Slowing Periods", "", 3, 1, 200);
    strategy.parameters:addInteger("D1TIMER_D", "%D Slowing Stochastic Periods", "", 3, 1, 200);
    strategy.parameters:addGroup("H1ASKTIMER parameters")
    strategy.parameters:addInteger("H1ASKTIMER_N", "Number of periods for RSI", "", 8, 1, 200);
    strategy.parameters:addInteger("H1ASKTIMER_K", "%K Stochastic Periods", "", 5, 1, 200);
    strategy.parameters:addInteger("H1ASKTIMER_KS", "%K Slowing Periods", "", 3, 1, 200);
    strategy.parameters:addInteger("H1ASKTIMER_D", "%D Slowing Stochastic Periods", "", 3, 1, 200);
    strategy.parameters:addGroup("H1BIDTIMER parameters")
    strategy.parameters:addInteger("H1BIDTIMER_N", "Number of periods for RSI", "", 8, 1, 200);
    strategy.parameters:addInteger("H1BIDTIMER_K", "%K Stochastic Periods", "", 5, 1, 200);
    strategy.parameters:addInteger("H1BIDTIMER_KS", "%K Slowing Periods", "", 3, 1, 200);
    strategy.parameters:addInteger("H1BIDTIMER_D", "%D Slowing Stochastic Periods", "", 3, 1, 200);
    strategy.parameters:addGroup("H1ASKEMA1 parameters")
    strategy.parameters:addInteger("H1ASKEMA1_N", "Number of periods", "The number of periods.", 5, 2, 10000);
    strategy.parameters:addGroup("H1BIDEMA1 parameters")
    strategy.parameters:addInteger("H1BIDEMA1_N", "Number of periods", "The number of periods.", 5, 2, 10000);
    strategy.parameters:addGroup("H1ASKEMA2 parameters")
    strategy.parameters:addInteger("H1ASKEMA2_N", "Number of periods", "The number of periods.", 40, 2, 10000);
    strategy.parameters:addGroup("H1BIDEMA2 parameters")
    strategy.parameters:addInteger("H1BIDEMA2_N", "Number of periods", "The number of periods.", 40, 2, 10000);
    strategy.parameters:addGroup("D1EMA1 parameters")
    strategy.parameters:addInteger("D1EMA1_N", "Number of periods", "The number of periods.", 5, 2, 10000);
    strategy.parameters:addGroup("D1EMA2 parameters")
    strategy.parameters:addInteger("D1EMA2_N", "Number of periods", "The number of periods.", 40, 2, 10000);
    
end

local mCID= "FXSW_STRATEGY";
local mAccount;
local mLotSize;
local mAllowTrade = false;
local mAllowedSide = "Both";
local mPlaySound = false;
local mReccurentSound = false;
local mSendEmail = false;
local mShowAlert = false;
local mEmail;
local mAllowMultiplePositions = true;
local D1 = "D1";

local H1 = "H1";

local m5 = "m5";

local symbol;
local D1ASK;
local id_D1ASK = 101;

local H1ASK;
local id_H1ASK = 102;

local m5ASK;
local id_m5ASK = 103;

local D1BID;
local id_D1BID = 104;

local H1BID;
local id_H1BID = 105;

local m5BID;
local id_m5BID = 106;

local Stop;
local Limit;
local D1TIMER_N;
local D1TIMER_K;
local D1TIMER_KS;
local D1TIMER_D;
local D1TIMER;
local H1ASKTIMER_N;
local H1ASKTIMER_K;
local H1ASKTIMER_KS;
local H1ASKTIMER_D;
local H1ASKTIMER;
local H1BIDTIMER_N;
local H1BIDTIMER_K;
local H1BIDTIMER_KS;
local H1BIDTIMER_D;
local H1BIDTIMER;
local H1ASKEMA1_N;
local H1ASKEMA1;
local H1BIDEMA1_N;
local H1BIDEMA1;
local H1ASKEMA2_N;
local H1ASKEMA2;
local H1BIDEMA2_N;
local H1BIDEMA2;
local D1EMA1_N;
local D1EMA1;
local D1EMA2_N;
local D1EMA2;
local D1LONG = false;

local D1SHORT = false;

local LONGEXIT = false;

local SHORTEXIT = false;

local H1LONG = false;

local H1SHORT = false;



-----------------------------------------------------------
-- Standard prepare handler for marketscope strategy
-----------------------------------------------------------
function Prepare(onlyName)
    
    

    -- collect parameters
    mAccount = instance.parameters.Account;
    mLotSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), mAccount);
    mAllowTrade = instance.parameters.AllowTrade;
    mAllowedSide = instance.parameters.AllowedSide;
    mAllowMultiplePositions = instance.parameters.AllowMultiplePositions;
    symbol = instance.bid:instrument();
    Stop = instance.parameters.Stop;
    Limit = instance.parameters.Limit;
    D1TIMER_N = instance.parameters.D1TIMER_N;
    D1TIMER_K = instance.parameters.D1TIMER_K;
    D1TIMER_KS = instance.parameters.D1TIMER_KS;
    D1TIMER_D = instance.parameters.D1TIMER_D;
    H1ASKTIMER_N = instance.parameters.H1ASKTIMER_N;
    H1ASKTIMER_K = instance.parameters.H1ASKTIMER_K;
    H1ASKTIMER_KS = instance.parameters.H1ASKTIMER_KS;
    H1ASKTIMER_D = instance.parameters.H1ASKTIMER_D;
    H1BIDTIMER_N = instance.parameters.H1BIDTIMER_N;
    H1BIDTIMER_K = instance.parameters.H1BIDTIMER_K;
    H1BIDTIMER_KS = instance.parameters.H1BIDTIMER_KS;
    H1BIDTIMER_D = instance.parameters.H1BIDTIMER_D;
    H1ASKEMA1_N = instance.parameters.H1ASKEMA1_N;
    H1BIDEMA1_N = instance.parameters.H1BIDEMA1_N;
    H1ASKEMA2_N = instance.parameters.H1ASKEMA2_N;
    H1BIDEMA2_N = instance.parameters.H1BIDEMA2_N;
    D1EMA1_N = instance.parameters.D1EMA1_N;
    D1EMA2_N = instance.parameters.D1EMA2_N;
    
    
    --set name
    instance:name(profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. ""  .. "))");
    
    if onlyName then
        return;
    end
    
    --datasources    
    D1ASK = ExtSubscribe(id_D1ASK, symbol, D1, false, "bar");
    H1ASK = ExtSubscribe(id_H1ASK, symbol, H1, false, "bar");
    m5ASK = ExtSubscribe(id_m5ASK, symbol, m5, false, "bar");
    D1BID = ExtSubscribe(id_D1BID, symbol, D1, true, "bar");
    H1BID = ExtSubscribe(id_H1BID, symbol, H1, true, "bar");
    m5BID = ExtSubscribe(id_m5BID, symbol, m5, true, "bar");
    
    
    --indicators
    assert(core.indicators:findIndicator("STOCHRSI8") ~= nil, "STOCHRSI8" .. " indicator must be installed");
    D1TIMER = core.indicators:create("STOCHRSI8", D1BID.close, D1TIMER_N, D1TIMER_K, D1TIMER_KS, D1TIMER_D, 65280, 1, 1, 255, 1, 1);
    _gUpdatePeriods[D1TIMER.DATA] = _gUpdatePeriods[D1BID.close];
    H1ASKTIMER = core.indicators:create("STOCHRSI8", H1ASK.close, H1ASKTIMER_N, H1ASKTIMER_K, H1ASKTIMER_KS, H1ASKTIMER_D, 65280, 1, 1, 255, 1, 1);
    _gUpdatePeriods[H1ASKTIMER.DATA] = _gUpdatePeriods[H1ASK.close];
    H1BIDTIMER = core.indicators:create("STOCHRSI8", H1BID.close, H1BIDTIMER_N, H1BIDTIMER_K, H1BIDTIMER_KS, H1BIDTIMER_D, 65280, 1, 1, 255, 1, 1);
    _gUpdatePeriods[H1BIDTIMER.DATA] = _gUpdatePeriods[H1BID.close];
    H1ASKEMA1 = core.indicators:create("EMA", H1ASK.close, H1ASKEMA1_N, 65280, 1, 1);
    _gUpdatePeriods[H1ASKEMA1.DATA] = _gUpdatePeriods[H1ASK.close];
    H1BIDEMA1 = core.indicators:create("EMA", H1BID.close, H1BIDEMA1_N, 65280, 1, 1);
    _gUpdatePeriods[H1BIDEMA1.DATA] = _gUpdatePeriods[H1BID.close];
    H1ASKEMA2 = core.indicators:create("EMA", H1ASK.close, H1ASKEMA2_N, 65280, 1, 1);
    _gUpdatePeriods[H1ASKEMA2.DATA] = _gUpdatePeriods[H1ASK.close];
    H1BIDEMA2 = core.indicators:create("EMA", H1BID.close, H1BIDEMA2_N, 65280, 1, 1);
    _gUpdatePeriods[H1BIDEMA2.DATA] = _gUpdatePeriods[H1BID.close];
    D1EMA1 = core.indicators:create("EMA", D1BID.close, D1EMA1_N, 65280, 1, 1);
    _gUpdatePeriods[D1EMA1.DATA] = _gUpdatePeriods[D1BID.close];
    D1EMA2 = core.indicators:create("EMA", D1BID.close, D1EMA2_N, 65280, 1, 1);
    _gUpdatePeriods[D1EMA2.DATA] = _gUpdatePeriods[D1BID.close];
    
    
    
end

-----------------------------------------------------------
-- 'Event handler' that is called when a datasource is updated
-----------------------------------------------------------
function ExtUpdate(id, updatedSource, period)
    if not checkReady("trades") or not checkReady("summary") then
        return;
    end
    
    -- update indicators values
    D1TIMER:update(core.UpdateLast);
    H1ASKTIMER:update(core.UpdateLast);
    H1BIDTIMER:update(core.UpdateLast);
    H1ASKEMA1:update(core.UpdateLast);
    H1BIDEMA1:update(core.UpdateLast);
    H1ASKEMA2:update(core.UpdateLast);
    H1BIDEMA2:update(core.UpdateLast);
    D1EMA1:update(core.UpdateLast);
    D1EMA2:update(core.UpdateLast);
    
    
    -- update expressions
    if id == id_D1ASK then --Updates handler of 'D1ASK' datasource ('D1'  timeframe)
        --Check that all data of used datasources is available
        if canCalculate( D1TIMER.K , D1TIMER.K:size() - 1 )  and canCalculate( D1TIMER.D , D1TIMER.D:size() - 1 )  then
            D1LONG = D1TIMER.K[getClosedPeriod(D1TIMER.K, D1TIMER.K:size() - 1) ] < 75  and  D1TIMER.K[getClosedPeriod(D1TIMER.K, D1TIMER.K:size() - 1) ] > D1TIMER.D[getClosedPeriod(D1TIMER.D, D1TIMER.D:size() - 1) ];
        end
        --Check that all data of used datasources is available
        if canCalculate( D1TIMER.K , D1TIMER.K:size() - 1 )  and canCalculate( D1TIMER.D , D1TIMER.D:size() - 1 )  then
            D1SHORT = D1TIMER.K[getClosedPeriod(D1TIMER.K, D1TIMER.K:size() - 1) ] > 25  and  D1TIMER.K[getClosedPeriod(D1TIMER.K, D1TIMER.K:size() - 1) ] < D1TIMER.D[getClosedPeriod(D1TIMER.D, D1TIMER.D:size() - 1) ];
        end
        --Check that all data of used datasources is available
        if canCalculate( D1EMA1.DATA , getClosedPeriod(D1EMA1.DATA, D1EMA1.DATA:size() - 1))  and canCalculate( D1EMA1.DATA , getClosedPeriod(D1EMA1.DATA, D1EMA1.DATA:size() - 1) - 1)  and canCalculate( D1EMA2.DATA , getClosedPeriod(D1EMA2.DATA, D1EMA2.DATA:size() - 1))  and canCalculate( D1EMA2.DATA , getClosedPeriod(D1EMA2.DATA, D1EMA2.DATA:size() - 1) - 1)  then
            LONGEXIT = core.crossesUnder(D1EMA1.DATA, D1EMA2.DATA, getClosedPeriod(D1EMA1.DATA, D1EMA1.DATA:size() - 1), getClosedPeriod(D1EMA2.DATA, D1EMA2.DATA:size() - 1));
        end
        --Check that all data of used datasources is available
        if canCalculate( D1EMA1.DATA , getClosedPeriod(D1EMA1.DATA, D1EMA1.DATA:size() - 1))  and canCalculate( D1EMA1.DATA , getClosedPeriod(D1EMA1.DATA, D1EMA1.DATA:size() - 1) - 1)  and canCalculate( D1EMA2.DATA , getClosedPeriod(D1EMA2.DATA, D1EMA2.DATA:size() - 1))  and canCalculate( D1EMA2.DATA , getClosedPeriod(D1EMA2.DATA, D1EMA2.DATA:size() - 1) - 1)  then
            SHORTEXIT = core.crossesOver(D1EMA1.DATA, D1EMA2.DATA, getClosedPeriod(D1EMA1.DATA, D1EMA1.DATA:size() - 1), getClosedPeriod(D1EMA2.DATA, D1EMA2.DATA:size() - 1));
        end
    end
    if id == id_H1ASK then --Updates handler of 'H1ASK' datasource ('H1'  timeframe)
        --Check that all data of used datasources is available
        if canCalculate( H1ASKTIMER.K , H1ASKTIMER.K:size() - 1 )  and canCalculate( H1ASKTIMER.K , getClosedPeriod(H1ASKTIMER.K, H1ASKTIMER.K:size() - 1))  and canCalculate( H1ASKTIMER.K , getClosedPeriod(H1ASKTIMER.K, H1ASKTIMER.K:size() - 1) - 1)  and canCalculate( H1ASKTIMER.D , getClosedPeriod(H1ASKTIMER.D, H1ASKTIMER.D:size() - 1))  and canCalculate( H1ASKTIMER.D , getClosedPeriod(H1ASKTIMER.D, H1ASKTIMER.D:size() - 1) - 1)  and canCalculate( H1ASKEMA1.DATA , getClosedPeriod(H1ASKEMA1.DATA, H1ASKEMA1.DATA:size() - 1))  and canCalculate( H1ASKEMA2.DATA , getClosedPeriod(H1ASKEMA2.DATA, H1ASKEMA2.DATA:size() - 1))  then
            H1LONG = H1ASKTIMER.K[getClosedPeriod(H1ASKTIMER.K, H1ASKTIMER.K:size() - 1) ] < 25  and  core.crossesOver(H1ASKTIMER.K, H1ASKTIMER.D, getClosedPeriod(H1ASKTIMER.K, H1ASKTIMER.K:size() - 1), getClosedPeriod(H1ASKTIMER.D, H1ASKTIMER.D:size() - 1))  and  H1ASKEMA1.DATA[getClosedPeriod(H1ASKEMA1.DATA, H1ASKEMA1.DATA:size() - 1)] > H1ASKEMA2.DATA[getClosedPeriod(H1ASKEMA2.DATA, H1ASKEMA2.DATA:size() - 1)];
        end
        --Check that all data of used datasources is available
        if canCalculate( H1BIDTIMER.K , H1BIDTIMER.K:size() - 1 )  and canCalculate( H1BIDTIMER.K , getClosedPeriod(H1BIDTIMER.K, H1BIDTIMER.K:size() - 1))  and canCalculate( H1BIDTIMER.K , getClosedPeriod(H1BIDTIMER.K, H1BIDTIMER.K:size() - 1) - 1)  and canCalculate( H1BIDTIMER.D , getClosedPeriod(H1BIDTIMER.D, H1BIDTIMER.D:size() - 1))  and canCalculate( H1BIDTIMER.D , getClosedPeriod(H1BIDTIMER.D, H1BIDTIMER.D:size() - 1) - 1)  and canCalculate( H1BIDEMA1.DATA , getClosedPeriod(H1BIDEMA1.DATA, H1BIDEMA1.DATA:size() - 1))  and canCalculate( H1BIDEMA2.DATA , getClosedPeriod(H1BIDEMA2.DATA, H1BIDEMA2.DATA:size() - 1))  then
            H1SHORT = H1BIDTIMER.K[getClosedPeriod(H1BIDTIMER.K, H1BIDTIMER.K:size() - 1) ] > 75  and  core.crossesUnder(H1BIDTIMER.K, H1BIDTIMER.D, getClosedPeriod(H1BIDTIMER.K, H1BIDTIMER.K:size() - 1), getClosedPeriod(H1BIDTIMER.D, H1BIDTIMER.D:size() - 1))  and  H1BIDEMA1.DATA[getClosedPeriod(H1BIDEMA1.DATA, H1BIDEMA1.DATA:size() - 1)] < H1BIDEMA2.DATA[getClosedPeriod(H1BIDEMA2.DATA, H1BIDEMA2.DATA:size() - 1)];
        end
    end
    
    
    -- processing of Activation points
    if id==id_H1ASK then --Updates handler of 'H1ASK' datasource ('H1'  timeframe)
            --'LONGOPEN' activation point logic 
            if D1LONG  and  H1LONG then
                if mAllowTrade then close("S", core.host:findTable("offers"):find("Instrument", symbol).OfferID); end
            if mAllowTrade then createTrueMarketOrder("B", 1, symbol, Stop, false, 0); end

            end
            --'SHORTOPEN' activation point logic 
            if D1SHORT  and  H1SHORT then
                if mAllowTrade then close("B", core.host:findTable("offers"):find("Instrument", symbol).OfferID); end
            if mAllowTrade then createTrueMarketOrder("S", 1, symbol, Stop, false, 0); end

            end
            --'LONGCLOSE' activation point logic 
            if LONGEXIT then
                if mAllowTrade then close("B", core.host:findTable("offers"):find("Instrument", symbol).OfferID); end
    

            end
            --'SHORTCLOSE' activation point logic 
            if SHORTEXIT then
                if mAllowTrade then close("S", core.host:findTable("offers"):find("Instrument", symbol).OfferID); end
    

            end
    end
    
end



function checkReady(tableName)
    return core.host:execute("isTableFilled", tableName);
end

-----------------------------------------------------------
--Enters to the market
--   side: B - BUY or S - SELL
--   amount: order amount
--   instrumentName: instrument of order
--   stop:  0, 1 or greater value 
--   isTrailingStop: true/false
--   limit: 0, 1 or greater value
-----------------------------------------------------------
function createTrueMarketOrder(side, amount, instrumentName, stop, isTrailingStop, limit)
    if not mAllowTrade then
        return;
    end
    
    local offerId = core.host:findTable("offers"):find("Instrument", instrumentName).OfferID;     
    
    if not (mAllowedSide == "Both" or (mAllowedSide == "Buy" and side == "B") or (mAllowedSide == "Sell" and side == "S")) then
        return;
    end
    
    if not mAllowMultiplePositions then
       if (side == 'B' and countLongPositions(instrumentName) > 0) then
           return;
       elseif (side == 'S' and countShortPositions(instrumentName) > 0) then
           return;
       end
    end
    
    
    local valuemap;
    
    valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = offerId;
    valuemap.AcctID = mAccount;
    valuemap.GTC = "FOK"; --Fill or Kill order to avoid partial execution
    valuemap.Quantity = amount * mLotSize;
    valuemap.BuySell = side;
    valuemap.CustomID = mCID;
    if stop >= 1 then
        valuemap.PegTypeStop = "M";
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = - stop;
        else
            valuemap.PegPriceOffsetPipsStop = stop;
        end
        if isTrailingStop then
           valuemap.TrailStepStop = 1;
        end
    end
    if limit >= 1 then
        valuemap.PegTypeLimit = "M";
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -limit;
        end
    end

    if (not canClose(instrumentName)) and (stop >= 1 or limit >= 1) then
        valuemap.EntryLimitStop = 'Y'
    end
    
    success, msg = terminal:execute(200, valuemap);
    assert(success, msg);
end



-----------------------------------------------------------
-- closes all positions of the specified direction (B for buy, S for sell)
-----------------------------------------------------------
function canClose(instrumentName)
    return core.host:execute("getTradingProperty", "canCreateMarketClose", instrumentName, mAccount);
end

function close(side, offer)
    local enum, row, valuemap;

    enum = core.host:findTable("trades"):enumerator();
    while true do
        row = enum:next();
        if row == nil then
            break;
        end
        if row.AccountID == mAccount and
           row.OfferID == offer and
           row.BS == side and
           row.QTXT == mCID then
            -- if trade has to be closed

            if canClose(row.Instrument) then
                -- create a close market order when hedging is allowed
                valuemap = core.valuemap();
                valuemap.OrderType = "CM";
                valuemap.OfferID = offer;
                valuemap.AcctID = mAccount;
                valuemap.Quantity = row.Lot;
                valuemap.TradeID = row.TradeID;
                valuemap.CustomID = mCID;
                if row.BS == "B" then
                    valuemap.BuySell = "S";
                else
                    valuemap.BuySell = "B";
                end
                success, msg = terminal:execute(200, valuemap);
                assert(success, msg);
            else                
                -- create an opposite market order when FIFO
                valuemap = core.valuemap();
                valuemap.OrderType = "OM";
                valuemap.OfferID = offer;
                valuemap.AcctID = mAccount;
                valuemap.Quantity = row.Lot;
                valuemap.CustomID = mCID;
                if row.BS == "B" then
                    valuemap.BuySell = "S";
                else
                    valuemap.BuySell = "B";
                end
                success, msg = terminal:execute(200, valuemap);
                assert(success, msg);
            end
        end
    end
end

-----------------------------------------------------------
--Handle command execution result
-----------------------------------------------------------
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        loaded = true;
    elseif cookie == 200 then
        assert(success, message);
    end
    
end

-----------------------------------------------------------
-- Helper functions
-----------------------------------------------------------
function getOppositeSide(side)
    if(side == "B") then
        return "S";
    else
        return "B";
    end
end

function getDSPeriod(ds, updatedSource, period)
    local p;
    if ds:isBar() then
        p = core.findDate(ds.open, updatedSource:date(period), false);
    else
        p = core.findDate(ds, updatedSource:date(period), false);
    end
    if (p > ds:size() - 1) then
        p = ds:size() - 1;
    elseif (p < ds:first()) then
        p = ds:first();
    end
    return p;
end


-----------------------------------------------------------
-- Allow to calculate last closed bar period for ds datasource
-- which has not tick frequency updates
-----------------------------------------------------------
function getClosedPeriod(ds, supposedPeriod)
    --Check if datasource lastdate is closed on updatePeriod or shift supposedPeriod to -1
    if _gUpdatePeriods[ds] == 't1' or _gUpdatePeriods[ds] == nil then
        return supposedPeriod;
    else
        return supposedPeriod - 1;
    end
end

-----------------------------------------------------------
--Helper functions to wrap the table's method call into the simple function call
-----------------------------------------------------------
function streamSize(stream)
    return stream:size();
end

function streamHasData(stream, period)
    return stream:hasData(period);
end

function canCalculate(stream, period)
    return (period >= 0) and (period > stream:first()) and streamHasData(stream, period);
end

-----------------------------------------------------------
-- Helper functions to be sure that you work with a tick stream
-----------------------------------------------------------
function getTickStreamOfPriceType(stream, priceType)
    if stream:isBar() then
        if priceType == "open" then
            return stream.open;
        elseif priceType == "high" then
            return stream.high;   
        elseif priceType == "low" then
            return stream.low;
        elseif priceType == "close" then
            return stream.close;
        elseif priceType == "typical" then
            return stream.typical;
        elseif priceType == "weighted" then
            return stream.weighted;
        elseif priceType == "volume" then
            return stream.volume;
        else
            return stream.close;
        end
    else
       return stream;
    end
end

function selectStream(safeStream, subStream)
    if safeStream:isBar() then
       return subStream;
    else
       return safeStream;
    end
end

---------------------------------------------------------
-- Subscription for updates by datasource timeframe
---------------------------------------------------------

-- subscribe for the price data
function ExtSubscribe(id, instrument, period, bid, type)
    local sub = {};
    if instrument == nil and period == "t1" then
        if bid then
            sub.stream = instance.bid;
        else
            sub.stream = instance.ask;
        end
        sub.tick = true;
        sub.loaded = true;
        sub.lastSerial = -1;
        _gSubscription[id] = sub;
    elseif instrument == nil then
        sub.stream = core.host:execute("getHistory", id, instance.bid:instrument(), period, 0, 0, bid);
        sub.tick = false;
        sub.loaded = false;
        sub.lastSerial = -1;
        _gSubscription[id] = sub;
    else
        sub.stream = core.host:execute("getHistory", id, instrument, period, 0, 0, bid);
        sub.tick = (period == "t1");
        sub.loaded = false;
        sub.lastSerial = -1;
        _gSubscription[id] = sub;
    end
    _gUpdatePeriods[sub.stream] = period;
    if sub.tick then
        return sub.stream;
    else
        if type == "open" then
            _gUpdatePeriods[sub.stream.open] = period;
            return sub.stream.open;
        elseif type == "high" then
            _gUpdatePeriods[sub.stream.high] = period;
            return sub.stream.high;
        elseif type == "low" then
            _gUpdatePeriods[sub.stream.low] = period;
            return sub.stream.low;
        elseif type == "close" then
            _gUpdatePeriods[sub.stream.close] = period;
            return sub.stream.close;
        elseif type == "bar" then
            _gUpdatePeriods[sub.stream.open] = period;
            _gUpdatePeriods[sub.stream.high] = period;
            _gUpdatePeriods[sub.stream.low] = period;
            _gUpdatePeriods[sub.stream.close] = period;
            _gUpdatePeriods[sub.stream.median] = period;
            _gUpdatePeriods[sub.stream.typical] = period;
            _gUpdatePeriods[sub.stream.volume] = period;
            _gUpdatePeriods[sub.stream.weighted] = period;
            return sub.stream;
        else
            assert(false, type .. " is unknown");
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
    local sub;
    sub = _gSubscription[cookie];
    if sub ~= nil then
        sub.loaded = true;
        if sub.stream:size() > 1 then
           sub.lastSerial = sub.stream:serial(sub.stream:size() - 1);
        end
    else
        -- unknown cookie
        if ExtAsyncOperationFinished ~= nil then
            ExtAsyncOperationFinished(cookie, success, message)
        end
    end
end

function Update()
    if instance.bid:size() > 0 then
        _gLastTime = instance.bid:date(instance.bid:size() - 1);
    end
    for k, v in pairs(_gSubscription) do
        if v.loaded and v.stream:size() > 1 then
            local s = v.stream:serial(v.stream:size() - 1);
            local p;
            if s ~= v.lastSerial then
                if v.tick then
                    p = v.stream:size() - 1;    -- the last tick
                else
                    p = v.stream:size() - 2;    -- the previous candle
                end
                ExtUpdate(k, v.stream, p);
                v.lastSerial = s;
            end
        end
    end
end

---------------------------------------------------------
-- Additional functions
---------------------------------------------------------
local mAccountRow = nil;
local mSummaries = {};

function checkAccountRow()
    if mAccountRow == nil then
        mAccountRow = core.host:findTable("accounts"):find("AccountID", mAccount);
    else
        mAccountRow:refresh();
    end
end

function checkSummaryRow(sInstrument)
    local sOfferID, summaryIter, summaryRow;
    
    if mSummaries[sInstrument] ~= nil then
        --try refresh
        if not (mSummaries[sInstrument]:refresh()) then
            mSummaries[sInstrument] = nil;
        end
    end
    
    --re-read all cache
    if mSummaries[sInstrument] == nil then
        sOfferID = core.host:findTable("offers"):find("Instrument", sInstrument).OfferID;
        summaryIter = core.host:findTable("summary"):enumerator();
        summaryRow = summaryIter:next();
        while summaryRow ~= nil do
            if summaryRow.OfferID == sOfferID then
                mSummaries[sInstrument] = summaryRow;
                break;
            end
            summaryRow = summaryIter:next();
        end
    end
end

function getEquity()
    
    checkAccountRow();
    return mAccountRow.Equity;
end

function getBalance()
    checkAccountRow();
    return mAccountRow.Balance;
end

function getProfit()
    checkAccountRow();
    return mAccountRow.Equity - mAccountRow.Balance;
end

function getAmountK(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.AmountK;
    end
end

function getGrossPL(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.GrossPL;
    end
end

function getNetPL(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.NetPL;
    end
end

function getSellAmountK(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.SellAmountK;
    end
end

function getBuyAmountK(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.BuyAmountK;
    end
end

function getBuyNetPLPip(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.BuyNetPLPip;
    end
end

function getSellNetPLPip(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.SellNetPLPip;
    end
end

function getBuyNetPL(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.BuyNetPL;
    end
end

function getSellNetPL(sInstrument)
    local res;
    checkSummaryRow(sInstrument);
    res = mSummaries[sInstrument];
    if res == nil then
        return 0;
    else
        return res.SellNetPL;
    end
end


function countPositions(sInstrument)
    local tradesIter, tradeRow, count, sOfferID;
    count = 0;
    if sInstrument ~= nil then
        sOfferID = core.host:findTable("offers"):find("Instrument", sInstrument).OfferID;
    end
    tradesIter = core.host:findTable("trades"):enumerator();
    tradeRow = tradesIter:next();
    while tradeRow ~= nil do
        if (sInstrument == nil or tradeRow.OfferID == sOfferID) then
            count = count + 1;
        end
        tradeRow = tradesIter:next();
    end
    return count;
end

function countLongPositions(sInstrument)
    local tradesIter, tradeRow, count, sOfferID;
    count = 0;
    if sInstrument ~= nil then
        sOfferID = core.host:findTable("offers"):find("Instrument", sInstrument).OfferID;
    end
    tradesIter = core.host:findTable("trades"):enumerator();
    tradeRow = tradesIter:next();
    while tradeRow ~= nil do
        if ((sInstrument==nil or tradeRow.OfferID == sOfferID) and tradeRow.BS == "B") then
            count = count + 1;
        end
        tradeRow = tradesIter:next();
    end
    return count;
end

function countShortPositions(sInstrument)
    local tradesIter, tradeRow, count, sOfferID;
    count = 0;
    if sInstrument ~= nil then
        sOfferID = core.host:findTable("offers"):find("Instrument", sInstrument).OfferID;
    end
    tradesIter = core.host:findTable("trades"):enumerator();
    tradeRow = tradesIter:next();
    while tradeRow ~= nil do
        if ((sInstrument == nil or tradeRow.OfferID == sOfferID) and tradeRow.BS == "S") then
            count = count + 1;
        end
        tradeRow = tradesIter:next();
    end
    return count;
end

function getLastUpdateTime()
    if (_gLastTime == nil) then
        return 0;
    else
        return _gLastTime;
    end
end

function time(hours, minutes, seconds)
    local dtLast;
    dtLast = core.dateToTable(_gLastTime);
    if seconds == nil then
        seconds = 0;
    end
    return core.datetime(dtLast.year, dtLast.month, dtLast.day, hours, minutes, seconds);
end

function isValidDate(checkDate)
   if (checkDate < 1) then
       return false;
   else
       return true;
   end
end

function parseTime(sTime)
    local iDelimHMPos = string.find(sTime, ":");
    local h = tonumber(string.sub(sTime, 1, iDelimHMPos - 1));
    local sTimeTile = string.sub(sTime, iDelimHMPos + 1);
    local iDelimMSPos = string.find(sTimeTile, ":");
    local m, s;
    s = 0;
    if iDelimMSPos == nil then
        m = tonumber(sTimeTile);
    else
        m = tonumber(string.sub(sTimeTile, 1, iDelimMSPos - 1));
        s = tonumber(string.sub(sTimeTile, iDelimMSPos + 1));
    end
    return time(h, m, s);
end

function getPipSize(sInstrument)
    return core.host:findTable("offers"):find("Instrument", sInstrument).PointSize;
end

