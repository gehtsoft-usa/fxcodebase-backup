-- Id: 20777
	
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=65864


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    strategy:name("OrderCopier.lua");
    strategy:description("");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "OrderCopier");

    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addInteger("RepetitionCount", "Count of repeat orders creation", "", 5, 1, 100);  
    
    strategy.parameters:addGroup("Order Parameters");
    strategy.parameters:addDouble("Rate", "Rate", "", 0);  
    strategy.parameters:setFlag("Rate", core.FLAG_PRICE);
    strategy.parameters:addInteger("Amount", "Amount", "", 1, 1, 100);	    
    strategy.parameters:addString("Side", "Side", "Side for trading or signaling, can be Sell, Buy", "Buy");
    strategy.parameters:addStringAlternative("Side", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("Side", "Sell", "", "Sell");
	
    strategy.parameters:addBoolean("isNeedStop", "Use stop?", "", true);
    strategy.parameters:addInteger("Stop", "Stop", "", 10, 1, 10000);	
    strategy.parameters:addBoolean("isNeedLimit", "Use limit?", "", true);
    strategy.parameters:addInteger("Limit", "Limit", "", 20, 1, 10000);	

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
local Rate;
local OrdersAmount;

local isNeedLimit;
local isNeedStop;
local isNeedTrailing;
local isNeedDynamicTrailing;
local Limit;
local TrailingStop;
local TradeSide;
local RepetitionCount;
local LimitForEntryDistance;
local RequestID = nil;
local OrderID = nil;
local OrderStopID = nil;
local OrderLimitID = nil;
local TradeID = nil;

function Prepare(nameOnly)
    local name;
    name = profile:id() .. "( " .. instance.bid:name();
	
	name = name ..  ", " .. instance.parameters.Rate .. ", " .. 
           instance.parameters.Amount.. ", " .. instance.parameters.Side ..  ", " .. instance.parameters.RepetitionCount;      
    
    name = name  ..  " )";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    PrepareTrading();

	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");

    core.host:execute("subscribeTradeEvents", 1002, "trades");	
end

function PrepareTrading()

    CustomID = instance.parameters.CustomID;
    Account = instance.parameters.Account;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)    
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument());
    LimitForEntryDistance = core.host:execute("getTradingProperty", "conditionalDistanceLimitForEntry", instance.bid:instrument(), Account);
 
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

    Rate = instance.parameters:getDouble("Rate");
    assert(Rate > 0, "Please, Specify Rate")
              
    RepetitionCount = instance.parameters:getInteger("RepetitionCount");
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
               
    if RepetitionCount > 0 then
        local sign = (Side == "B" and -1 or 1);
        local TrigeredRate = Rate + sign * (LimitForEntryDistance + 0.1) * Offer.PointSize;   
    
        if core.crosses(TickSource, TrigeredRate, NOW) and RequestID == nil and OrderID == nil and TradeID == nil then
   
            local req = CreateOrder(Rate)
            if req ~= false then
                RequestID = req;
                RepetitionCount = RepetitionCount - 1;
            end      
        end
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

    valuemap.OfferID = Offer.OfferID;
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
        valuemap.TrailStepStop = ( orderParams.isNeedDynamicTrailing and 1 or orderParams.TrailingStop);
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

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 200 then
        if  not success then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. message, instance.bid:date(instance.bid:size() - 1));
        else
            found, orderID, stopOrderID, limitOrderID = findCreatedOrders(RequestID)
            if found == true then
                RequestID = nil;
                OrderID = orderID;
                OrderStopID = stopOrderID;
                OrderLimitID = limitOrderID;
            end
        end
            
    elseif cookie == 1002 then
        if OrderID == message1 then
            OrderID = nil;
            TradeID = message;
        elseif OrderStopID == message1 then
            TradeID = nil;
            OrderStopID = nil;
            OrderLimitID = nil;
        elseif OrderLimitID == message1 then
            TradeID = nil;
            OrderStopID = nil;
            OrderLimitID = nil;
            
            local sign = (Side == "S" and -1 or 1);
            Rate = Rate + sign * Limit * Offer.PointSize;
            core.host:trace("TrigeredRate is " .. Rate);
        end
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function findCreatedOrders(requestID)
   local enum, row;
   local found = false;
   local orderID = nil;
   local limitOrderID = nil;
   local stopOrderID = nil;
       
   enum = core.host:findTable("orders"):enumerator();
   row = enum:next();
   while (not found) and (row ~= nil) do
       if row.RequestID == requestID and
          row.PrimaryOrderId == "" then
           found = true;
           orderID = row.OrderID;
           stopOrderID  = row.StopOrderID
           limitOrderID = row.LimitOrderID
           break;
       end
       row = enum:next();
   end

   return found, orderID, stopOrderID, limitOrderID;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");