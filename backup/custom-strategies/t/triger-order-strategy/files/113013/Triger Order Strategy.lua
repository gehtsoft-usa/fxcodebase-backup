-- Id: 18488
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64815

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
    strategy:name("Triger Order Strategy");
    strategy:description("");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert,Account,CanTrade,Email,SendEmail");
    strategy:setTag("Version", "2");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "TSTTR");

    CreateOrderParameters("Order1");
    CreateOrderParameters("Order2");
    CreateOrderParameters("Order3");
end

function CreateOrderParameters(orderName)

    strategy.parameters:addGroup(orderName .. " Parameters");
    strategy.parameters:addString(orderName .. "Instrument", "Instrument", "", "");
    strategy.parameters:setFlag(orderName .. "Instrument",core.FLAG_INSTRUMENTS);
   
    strategy.parameters:addDouble(orderName .. "Rate", "Rate", "", 0, 0.1, 100); 
    
    strategy.parameters:addInteger(orderName .. "Amount", "Amount", "", 1, 1, 100);	
    
    strategy.parameters:addString(orderName .. "Side", "Side", "Side for trading or signaling, can be Sell, Buy", "Buy");
    strategy.parameters:addStringAlternative(orderName .. "Side", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative(orderName .. "Side", "Sell", "", "Sell");
	
    strategy.parameters:addBoolean(orderName .. "isNeedStop", "Use stop?", "", true);
    strategy.parameters:addInteger(orderName .. "Stop", "Stop", "", 5, 1, 10000);	
    strategy.parameters:addBoolean(orderName .. "isNeedLimit", "Use limit?", "", true);
    strategy.parameters:addInteger(orderName .. "Limit", "Limit", "", 10, 1, 10000);	

    strategy.parameters:addBoolean(orderName .. "isNeedTrailing", "Use trailing?", "", false);
    strategy.parameters:addBoolean(orderName .. "isNeedDynamicTrailing", "  Dynamic trailing mode", "", false);
    strategy.parameters:addInteger(orderName .. "TrailingStop", "  Fixed trailing stop (pips)", "", 10, 10, 300);
end


local Account;
local BaseSize;
local CanClose;
local OrderIDs = {"Order1", "Order2", "Order3"};
local OrdersParams = {};
local MonitoringOrder = nil;
local CustomID;
local LastRequestID;

function Prepare(nameOnly)
    local name;
   
    PrepareTrading();
    
    local name = profile:id() .. " ";
    for i = 1, #OrderIDs do
        local orderID = OrderIDs[i];
        name =  name .. OrderParamsToString(OrdersParams[orderID]) .. " - ";
    end
     
    instance:name(name);
    timerId = core.host:execute("setTimer", 100, 1);
    
    core.host:execute("subscribeTradeEvents", 1001, "trades");
end

function PrepareTrading()

    CustomID = instance.parameters.CustomID;
    Account = instance.parameters.Account;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)


    for i = 1, #OrderIDs do
        local order = {};
        local orderID = OrderIDs[i];
        
        local instrument = instance.parameters:getString(orderID .. "Instrument");
        order.Offer = core.host:findTable("offers"):find("Instrument", instrument);
 
        order.Side = (instance.parameters:getString(orderID .. "Side") == "Buy") and "B" or "S";                     

        local rate = instance.parameters:getDouble(orderID .. "Rate");
        assert(rate > 0, "Please, Specify rate for " .. orderID);          

        order.Rate = rate;
        
        order.Amount = instance.parameters:getInteger(orderID .. "Amount");
        order.Stop = instance.parameters:getInteger(orderID .. "Stop");
        order.Limit = instance.parameters:getInteger(orderID .."Limit");
        
        order.isNeedLimit = instance.parameters:getBoolean(orderID .. "isNeedLimit");
        order.isNeedStop = instance.parameters:getBoolean(orderID .. "isNeedStop");
        order.isNeedTrailing = instance.parameters:getBoolean(orderID .. "isNeedTrailing");
        order.isNeedDynamicTrailing = instance.parameters:getBoolean(orderID .. "isNeedDynamicTrailing");
        order.Limit = instance.parameters:getInteger(orderID .."Limit");

        order.TrailingStop = instance.parameters:getInteger(orderID .."TrailingStop");
    
        order.isExecution = false;        
        OrdersParams[orderID] = order;
    end
end

function OrderParamsToString(orderParam)
    local str = "Order(" .. orderParam.Offer.Instrument .. "," .. tostring(orderParam.Price) .. "," .. orderParam.Side .. "," ..
                tostring(orderParam.Amount) .. "," .. tostring(orderParam.Stop) .. "," .. tostring(orderParam.Limit) .. ")";
    return str;
end

function Update()
end

function CreateNext()

    for i = 1, #OrderIDs do
    
        local orderID = OrderIDs[i];
        local orderParams = OrdersParams[orderID];
        if orderParams.isExecution == false then
           return CreateOrder(orderParams);
        end
    end
    
    return nil;
end

function CheckOrder(order)

end

function CreateOrder(orderParams)
    if orderParams.Side == "B" then
        if orderParams.Offer.Ask >  orderParams.Rate then
           return CreateLEOrder(orderParams)
        else
           return CreateSEOrder(orderParams)
        end
    else
        if orderParams.Offer.Bid <  orderParams.Rate then
           return CreateLEOrder(orderParams)
        else
           return CreateSEOrder(orderParams)
        end
    end
end

function AsyncOperationFinished(id, success, msg)
   if id == 100 then
        
        if MonitoringOrder == nil then
            LastRequestID = CreateNext();
        else 
            if CheckExecution(MonitoringOrder) == true then
            
                for i = 1, #OrderIDs do
                
                    local orderID = OrderIDs[i];
                    local orderParams = OrdersParams[orderID];
                    if orderParams.isExecution == false then
                       orderParams.isExecution = true;                       
                       break;
                    end
                end 
                MonitoringOrder = nil;           
            end
        end
    elseif id == 200 then
        if success == true  then               
            found, MonitoringOrder = findOrderID(LastRequestID)
        end
    end
end

function CheckExecution(order)
    if core.host:findTable("trades"):find("OpenOrderID", MonitoringOrder) ~= nil then 
        return true;
    end 
    
    return false;
end

function CreateSEOrder(orderParams)
    if not instance.parameters.AllowTrade then
        return "";
    end
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "SE";
    valuemap.OfferID = orderParams.Offer.OfferID;
    valuemap.AcctID = Account;
    valuemap.BuySell = orderParams.Side;
    valuemap.Quantity = orderParams.Amount * BaseSize;
    valuemap.Rate = orderParams.Rate;
    valuemap.CustomID = CustomID;


    local stopSign  = (valuemap.BuySell == "B" and -1 or  1);
    local limitSign = -stopSign;

    if orderParams.isNeedLimit then
	    valuemap.PegTypeLimit = "O";
        valuemap.PegPriceOffsetPipsLimit = limitSign * orderParams.Limit;
    end

    if orderParams.isNeedStop then
	    valuemap.PegTypeStop = "O";
        valuemap.PegPriceOffsetPipsStop = stopSign * orderParams.Stop;
    end

    if orderParams.isNeedTrailing then
        valuemap.TrailStepStop = ( orderParams.isNeedDynamicTrailing and 1 or orderParams.TrailingStop);
    end

    success, msg = terminal:execute(200, valuemap);
    
    if not(success) then
        terminal:alertMessage("", 0, "Send Entry Stop to server failed! '" .. msg .. "'", core.now());
        return false;
    end
    
    return msg;
end

function CreateLEOrder(orderParams)
    if not instance.parameters.AllowTrade then
        return "";
    end
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "LE";
    valuemap.OfferID = orderParams.Offer.OfferID;
    valuemap.AcctID = Account;
    valuemap.BuySell = orderParams.Side;
    valuemap.Quantity = orderParams.Amount * BaseSize;
    valuemap.Rate = orderParams.Rate;
    valuemap.CustomID = CustomID;

    local stopSign  = (valuemap.BuySell == "B" and -1 or  1);
    local limitSign = -stopSign;

    if orderParams.isNeedLimit then
	    valuemap.PegTypeLimit = "O";
        valuemap.PegPriceOffsetPipsLimit = limitSign *orderParams.Limit;
    end

    if orderParams.isNeedStop then
	    valuemap.PegTypeStop = "O";
        valuemap.PegPriceOffsetPipsStop = stopSign *orderParams.Stop;
    end

    if orderParams.isNeedTrailing then
        valuemap.TrailStepStop = ( orderParams.isNeedDynamicTrailing and 1 or orderParams.TrailingStop);
    end

    success, msg = terminal:execute(200, valuemap);
    
    if not(success) then
        terminal:alertMessage("", 0, "Send Entry Stop to server failed! '" .. msg .. "'", core.now());
        return false;
    end
    
    return msg;
end

 function findOrderID(requestID)
       local enum, row;
       local found = false;
       enum = core.host:findTable("orders"):enumerator();
       row = enum:next();
       while (not found) and (row ~= nil) do
           if row.RequestID == requestID and
              row.PrimaryOrderId == "" then
               found = true;
               break;
           end
           row = enum:next();
       end
 
       return found, row.OrderID;
   end