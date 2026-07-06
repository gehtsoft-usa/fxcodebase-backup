
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65091

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+


function Init()
    strategy:name("Manual Trailing Stop");
    strategy:description("");

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addString("Trade", "(non-FIFO) Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);

    strategy.parameters:addGroup("Trailing Stop Parameters");
    strategy.parameters:addInteger("TPLevel1", "Trade Profit level1 (pips)", "", 20, 0.1, 1000);  
    strategy.parameters:addInteger("TPLevel2", "Trade Profit level2 (pips)", "", 20, 0.1, 1000);
    strategy.parameters:addInteger("TPLevel3", "Trade Profit level3 (pips)", "", 20, 0.1, 1000);
    strategy.parameters:addInteger("TPLevel4", "Trade Profit level4 (pips)", "", 20, 0.1, 1000);
    strategy.parameters:addInteger("TPLevel5", "Trade Profit level5 (pips)", "", 30, 0.1, 1000);  

    strategy.parameters:addInteger("TPShift", "Trade Profit shift (pips)", "", 5);  
end

local Account;
local Offer;
local CanClose;

local orderId_stop;
local orderId_limit;
local tradeId
local requestId_stop;
local requestId_limit;
local isStopExist = false;

local TPShift;

local ProfitLevelsCount = 5;
local ProfitLevels = {}
local Limit = 0;
local Stop = 0;
local minChange;
local DistTradeStop;

function Prepare(nameOnly)
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Trade   .. "], " .. instance.parameters.TPLevel1 .. "," .. 
        instance.parameters.TPLevel2 .. "," .. instance.parameters.TPLevel3 .. "," .. instance.parameters.TPLevel4 .. ","  .. instance.parameters.TPLevel5 .. ")";

    tradeId = instance.parameters.Trade;
    
    local trade = core.host:findTable("trades"):find("TradeID", tradeId);
    assert(trade ~= nil, "Trade can not be found")

    Account = trade.AccountID
    Offer   = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)    
    DistTradeStop = core.host:execute("getTradingProperty", "conditionalDistanceStopForTrade", instance.bid:instrument());

    TPShift = instance.parameters.TPShift * instance.bid:pipSize();

    instance:name(name);
    if onlyName then
        return ;
    end 
      
    minChange = math.pow(10, -instance.bid:getPrecision()); 
    Limit = instance.parameters:getInteger("TPLevel1") * instance.bid:pipSize();   
    for i = 1, ProfitLevelsCount - 1 do      
       ProfitLevels[i] = instance.parameters:getInteger("TPLevel" .. i) * instance.bid:pipSize();
    end

    ExtSetupSignal(name .. ":", true);
    Source = ExtSubscribe(1, nil, "t1", true, "close");
    
    first = Source:first()-1;    
end

function ExtUpdate(id, source, period)
    if id ~= 1 then
       return;
    end
    
    if period < first  then
       return;
    end    
    
    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end

    local trade; 
    trade = core.host:findTable("trades"):find("TradeID", tradeId);
    
    if isTradeExist(trade) == false then
        return;
    end 
    
    if requestId_stop ~= nil then
        local order = core.host:findTable("orders"):find("RequestID", requestId_stop);
        if order ~= nil then
            orderId_stop = order.OrderID;
            requestId_stop = nil;
        end
    end
    if requestId_limit ~= nil then
        local order = core.host:findTable("orders"):find("RequestID", requestId_limit);
        if order ~= nil then
            orderId_limit = order.OrderID;
            requestId_limit = nil;
        end
    end
        
    local stopValue = nil;
    local limitValue = nil;
    if trade.BS == "B"  then
        stopValue = trade.Open + Stop;
        limitValue = trade.Open + Limit + TPShift;
        if instance.ask[NOW] >= trade.Open + Limit then
            if #ProfitLevels > 0 then
                Stop = Stop + Limit;
                Limit = Limit + ProfitLevels[1];
                table.remove(ProfitLevels, 1)
            else
                closeTrade("B", trade);
                return ;
            end
        else
            return ;
        end

        if stopValue > instance.bid[NOW] - DistTradeStop * instance.bid:pipSize() then                 
            stopValue = instance.bid[NOW] - DistTradeStop * instance.bid:pipSize() - minChange;
        end        
      
        stopSide = "S";
        if stopValue >= instance.bid[NOW] then
            return ;
        end
    else
        stopValue = trade.Open - Stop;
        limitValue = trade.Open - Limit - TPShift;
        if instance.bid[NOW] <= trade.Open - Limit then
            if #ProfitLevels > 0 then
                Stop = Stop + Limit;
                Limit = Limit + ProfitLevels[1];
                table.remove(ProfitLevels, 1)
            else
                closeTrade("S", trade);
                return ;
            end               
        else
            return ;
        end
               
        if stopValue < instance.ask[NOW] + DistTradeStop * instance.ask:pipSize()  then                 
            stopValue = instance.ask[NOW] + DistTradeStop * instance.ask:pipSize() + minChange;
        end         
 
        stopSide = "B";
        if stopValue <= instance.ask[NOW] then
            return ;
        end
    end
          
    moveStop(stopValue, stopSide);
    moveLimit(limitValue, stopSide);
end

function isTradeExist(trade)
    if trade == nil then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Trade " .. instance.parameters.Trade .. " disappear", instance.bid:date(NOW));
        core.host:execute("stop");
        return false;
    end
    
    return true;
end 

function moveStop(rate, side)
    if requestId_stop ~= nil then
        return;
    end
    -- Check that order is stil exist
    local order = nil;
    if orderId_stop ~= nil then
        order = core.host:findTable("orders"):find("OrderID", orderId_stop);
    end

    if order == nil then
        -- =======================================================================
        --                           CREATE NEW ORDER                           --
        -- =======================================================================

        valuemap = core.valuemap();
        valuemap.Command = "CreateOrder";
        valuemap.OfferID = Offer;
        valuemap.Rate = rate;
        valuemap.BuySell = side;
        
        if CanClose then
            local trade = core.host:findTable("trades"):find("TradeID", tradeId);

            valuemap.OrderType = "S";
            valuemap.AcctID  = trade.AccountID;
            valuemap.TradeID = trade.TradeID;
            valuemap.Quantity = trade.Lot;
        else
            valuemap.OrderType = "SE"
            valuemap.AcctID  = Account;
            valuemap.NetQtyFlag = "Y"
        end
        

        success, msg = terminal:execute(200, valuemap);
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create stop " .. msg, instance.bid:date(NOW));
            requestId_stop = nil;
        else
            requestId_stop = core.parseCsv(msg)[0]
        end
    else
        -- =======================================================================
        --                      CHANGE EXISTING ORDER                           --
        -- =======================================================================
        if math.abs(rate - order.Rate) > minChange then
            -- stop exists
            valuemap = core.valuemap();
            valuemap.Command = "EditOrder";
            valuemap.AcctID  = order.AccountID;
            valuemap.OrderID = order.OrderID;
            valuemap.Rate = rate;
            
            success, msg = terminal:execute(200, valuemap);
            if not(success) then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed change stop " .. msg, instance.bid:date(NOW));
            end
        end
    end
end

function moveLimit(rate, side)
    if requestId_limit ~= nil then
        return;
    end
    -- Check that order is stil exist
    local order = nil;

    if orderId_limit ~= nil then
        order = core.host:findTable("orders"):find("OrderID", orderId_limit);
    end

    if order == nil then
        -- =======================================================================
        --                           CREATE NEW ORDER                           --
        -- =======================================================================

        valuemap = core.valuemap();
        valuemap.Command = "CreateOrder";
        valuemap.OfferID = Offer;
        valuemap.Rate = rate;
        valuemap.BuySell = side;
        
        if CanClose then
            local trade = core.host:findTable("trades"):find("TradeID", tradeId);

            valuemap.OrderType = "L";
            valuemap.AcctID  = trade.AccountID;
            valuemap.TradeID = trade.TradeID;
            valuemap.Quantity = trade.Lot;
        else
            valuemap.OrderType = "LE"
            valuemap.AcctID  = Account;
            valuemap.NetQtyFlag = "Y"
        end

        success, msg = terminal:execute(201, valuemap);
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create limit " .. msg, instance.bid:date(NOW));
            requestId_limit = nil;
        else
            requestId_limit = core.parseCsv(msg)[0]
        end
    else
        -- =======================================================================
        --                      CHANGE EXISTING ORDER                           --
        -- =======================================================================
        if math.abs(rate - order.Rate) > minChange then
            -- stop exists
            valuemap = core.valuemap();
            valuemap.Command = "EditOrder";
            valuemap.AcctID  = order.AccountID;
            valuemap.OrderID = order.OrderID;
            valuemap.Rate = rate;
            
            success, msg = terminal:execute(201, valuemap);
            if not(success) then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed change limit " .. msg, instance.bid:date(NOW));
            end
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. message , instance.bid:date(NOW));
            requestId_stop = nil;
        end
    end
    if id == 201 then
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change limit " .. message , instance.bid:date(NOW));
            requestId_limit = nil;
        end
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function closeTrade(BuySell, row)
    local valuemap, success, msg;

    valuemap = core.valuemap();

    -- switch the direction since the order must be in oppsite direction
    if BuySell == "B" then
        BuySell = "S";
    else
        BuySell = "B";
    end
    valuemap.OrderType = "CM";
    valuemap.OfferID=row.OfferID;
    valuemap.AcctID = Account;
    valuemap.NetQtyFlag = "N";
    valuemap.TradeID=row.TradeID;
    valuemap.Quantity=row.Lot;
    valuemap.BuySell = BuySell;
    success, msg = terminal:execute(101, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");