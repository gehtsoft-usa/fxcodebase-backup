-- Id: 18684

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=31&t=64918

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
    strategy:name("Multiple Entry Orders Strategy");
    strategy:description("");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "MEOS");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addString("Instrument", "Instrument", "", "");
    strategy.parameters:setFlag("Instrument",core.FLAG_INSTRUMENTS);  
    strategy.parameters:addDouble("TradeStart", "Start Rate", "", 0, 0, 1000000);    
    strategy.parameters:addInteger("TradeSide", "Comparison Method", "Comparison method between Current Rate and StartRate", 0);
    strategy.parameters:addIntegerAlternative("TradeSide", "Above", "Current Rate > StartRate", 0);
    strategy.parameters:addIntegerAlternative("TradeSide", "Below", "Current Rate < StartRate", 1);
   
    strategy.parameters:addDouble("RateStep", "Rate Step(pip)", "", 1, 1, 100);
    strategy.parameters:addInteger("OrdersAmount", "Amount Orders(pcs.)", "", 5, 1, 100);
    strategy.parameters:addInteger("OrderLiveTime", "The Order Lifetime(min)", "", "2");  
    strategy.parameters:addBoolean("Repetition", "Is Repeat orders creation?", "", true);  
    
    strategy.parameters:addGroup("Order Parameters");
    strategy.parameters:addInteger("Amount", "Amount", "", 1, 1, 100);	    
    strategy.parameters:addString("Side", "Side", "Side for trading or signaling, can be Sell, Buy", "Buy");
    strategy.parameters:addStringAlternative("Side", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("Side", "Sell", "", "Sell");
	
    strategy.parameters:addBoolean("isNeedStop", "Use stop?", "", true);
    strategy.parameters:addInteger("Stop", "Stop", "", 5, 1, 10000);	
    strategy.parameters:addBoolean("isNeedLimit", "Use limit?", "", true);
    strategy.parameters:addInteger("Limit", "Limit", "", 10, 1, 10000);	

    strategy.parameters:addBoolean("isNeedTrailing", "Use trailing?", "", false);
    strategy.parameters:addBoolean("isNeedDynamicTrailing", "  Dynamic trailing mode", "", false);
    strategy.parameters:addInteger("TrailingStop", "  Fixed trailing stop (pips)", "", 10, 10, 300);
end


local Account;
local BaseSize;
local CanClose;
local CustomID;
local TickSource;
local Offer;
local Side;
local TradeStart;    
local RateStep;
local OrdersAmount;

local isNeedLimit;
local isNeedStop;
local isNeedTrailing;
local isNeedDynamicTrailing;
local Limit;
local TrailingStop;
local TradeSide;
local Repetition;

local OrderLiveTimeSec;

local RequestIDs = {}
local OrderIDs = {}

function Prepare(nameOnly)
    local name;
    name = profile:id() .. "( " .. instance.bid:name();
	
	name = name ..  ", " .. instance.parameters.TradeStart .. ", " .. instance.parameters.RateStep .. ", " .. 
           instance.parameters.OrdersAmount.. ", " .. instance.parameters.OrderLiveTime
    
    
    name = name  ..  " )";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    PrepareTrading();

	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");	
end

function PrepareTrading()

    CustomID = instance.parameters.CustomID;
    Account = instance.parameters.Account;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
     
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
 
    Side = (instance.parameters:getString("Side") == "Buy") and "B" or "S";                     
        
    Amount = instance.parameters:getInteger("Amount");
    Stop = instance.parameters:getInteger("Stop");
    Limit = instance.parameters:getInteger("Limit");
        
    isNeedLimit = instance.parameters:getBoolean("isNeedLimit");
    isNeedStop = instance.parameters:getBoolean("isNeedStop");
    isNeedTrailing = instance.parameters:getBoolean("isNeedTrailing");
    isNeedDynamicTrailing = instance.parameters:getBoolean("isNeedDynamicTrailing");
    Limit = instance.parameters:getInteger("Limit");

    TrailingStop = instance.parameters:getInteger("TrailingStop");    

    local rate = instance.parameters:getDouble("TradeStart");
    assert(rate > 0, "Please, Specify TradeStart");          
    TradeStart = rate;
    
    OrderLiveTimeSec = instance.parameters:getInteger("OrderLiveTime")*60;
    RateStep = instance.parameters:getDouble("RateStep");
    OrdersAmount = instance.parameters:getInteger("OrdersAmount");
    TradeSide = instance.parameters:getInteger("TradeSide");
    Repetition = instance.parameters:getBoolean("Repetition");
end

local Period;
local OrderCreationTime = nil;

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if not instance.parameters.AllowTrade then
        return;
    end
    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end

    local currentRate = TickSource[NOW];
    
    local isRateReached = false;
    
    if TradeSide == 0 then 
        isRateReached = currentRate > TradeStart;
    else 
        isRateReached = currentRate < TradeStart;
    end
    
    if isRateReached == true and OrderCreationTime == nil then 
        CreateOrders(currentRate, RateStep, OrdersAmount);
        OrderCreationTime = TickSource:date(NOW);
    end
    
    if OrderCreationTime ~= nil then
        local timeDiff = math.floor((TickSource:date(NOW) - OrderCreationTime) * 86400); 
        if timeDiff >= OrderLiveTimeSec then
            DeleteOrders();
        end
    end            
end

function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    end
end

function CreateOrders(currentRate, rateStep, ordersAmount)

	for i = 1, ordersAmount do 	

        local req = CreateOrder(currentRate)
        if req ~= false then
            RequestIDs[#RequestIDs + 1] = req;
        end
        currentRate = currentRate + rateStep * TickSource:pipSize();
	end
end

function CreateOrder(rate)

    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    
    if Side == "B" then
        if instance.ask[NOW] > rate then
            valuemap.OrderType = "LE";
        else
            valuemap.OrderType = "SE";
        end
    else
        if instance.bid[NOW] < rate then
            valuemap.OrderType = "LE";
        else
            valuemap.OrderType = "SE";
        end
    end

    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.Rate = rate;
    valuemap.CustomID = CustomID;
    valuemap.BuySell = Side;

    if isNeedStop then
        -- add stop/limit
        valuemap.PegTypeStop = "O";
        if Side == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop;
        else
            valuemap.PegPriceOffsetPipsStop = Stop;
        end
    end
    
    if isNeedLimit then
        valuemap.PegTypeLimit = "O";
        if Side == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit;
        end
    end

    if isNeedTrailing then
        valuemap.TrailStepStop = ( isNeedDynamicTrailing and 1 or TrailingStop);
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = 'Y'
    end

    success, msg = terminal:execute(200, valuemap);
    
    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end
    
    return msg;
end

function DeleteNoTriggeredOrders(OrderIDs)

    for k in pairs (OrderIDs) do
        local orderID = OrderIDs[k];
        local found = findOrderIDByOrderID(orderID)
        if found == true then
            DeleteOrder(orderID);
        end
        OrderIDs[k] = nil;
    end
end


function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 200 then
        if  not success then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. message, instance.bid:date(instance.bid:size() - 1));
        else
           for k in pairs (RequestIDs) do
                local found, orderID;
                found, orderID = findOrderID(RequestIDs[k])
                if found == true then
                    RequestIDs[k] = nil;
                    OrderIDs[k] = orderID;
                end
           end
        end
    end
end

function DeleteOrders()    
    DeleteNoTriggeredOrders(OrderIDs)
    for k in pairs (RequestIDs) do
        RequestIDs[k] = nil;
    end
    
    if Repetition == true then
        OrderCreationTime = nil;
    end
    --core.host:trace("CloseOrders");
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function findOrderID(requestID)
   local enum, row;
   local found = false;
   local orderID = nil;
   enum = core.host:findTable("orders"):enumerator();
   row = enum:next();
   while (not found) and (row ~= nil) do
       if row.RequestID == requestID and
          row.PrimaryOrderId == "" then
           found = true;
           orderID = row.OrderID;
           break;
       end
       row = enum:next();
   end

   return found, orderID;
end

function DeleteNoTriggeredOrders(OrderIDs)

    for k in pairs (OrderIDs) do
        local orderID = OrderIDs[k];
        local found = findOrderIDByOrderID(orderID)
        if found == true then
            DeleteOrder(orderID);
        end
        OrderIDs[k] = nil;
    end
end

function findOrderIDByOrderID(orderID)
   local enum, row;
   local found = false;
   enum = core.host:findTable("orders"):enumerator();
   row = enum:next();
   while (not found) and (row ~= nil) do
       if row.OrderID == orderID then
           found = true;
           break;
       end
       row = enum:next();
   end

   return found;
end

function DeleteOrder(orderId)
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OrderID = orderId;

    local success, msg = terminal:execute(201, valuemap);
    
    if not(success) then
        terminal:alertMessage("", 0, "Delete order to server failed! '" .. msg .. "'", core.now());
        return false;
    end
    
    return msg;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");