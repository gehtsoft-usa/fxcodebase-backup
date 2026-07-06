-- Id: 18677
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64915

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

function Init() -- The strategy profile initialization
    strategy:name("Richard Donchian's Strategy");
    strategy:description("");
    -- NG: optimizer/backtester hint
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email");
           
    strategy.parameters:addString("TF", "Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "RDS");

    strategy.parameters:addGroup("Strategy Parameters");    
    strategy.parameters:addInteger("Amount", "Amount", "", 1, 1, 100);	        

    strategy.parameters:addGroup("Time Parameters");
    strategy.parameters:addString("TimeToExecute", "TimeToExecute", "", "17:00:00");
end

local Account;
local BaseSize;
local CanClose;
local CustomID;
local Offer;
local Amount;

local TimeToExecute;
local ResetTime;
local TimerId;
local ExecuteFlag;

local RequestIDs = {}
local OrderIDs = {}

function Prepare(nameOnly)
  
    local name;
    name = profile:id() .. "( " .. instance.bid:name();
	
	name = name .. ", " .. instance.parameters.TF .. ", " .. instance.parameters.Type .. ", " .. instance.parameters.TimeToExecute
   
    name = name  ..  " )";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    PrepareTrading();
	    
    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");  
    TimerId = core.host:execute("setTimer", 100, 1);	
    ExecuteFlag = false;
end

function PrepareTrading()
    
    TimeToExecute, valid = ParseTime(instance.parameters.TimeToExecute);
    assert(valid, "Time " .. instance.parameters.TimeToExecute .. " is invalid");
    
    ResetTime, valid = ParseTime("0:05:00");
    assert(valid, "Reset Time is invalid");

    CustomID = instance.parameters.CustomID;
    Account = instance.parameters.Account;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
     
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID; 
    Amount = instance.parameters:getInteger("Amount"); 
end


local Period;
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.

    if AllowTrade or not instance.parameters.AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end

	local now = core.host:execute("getServerTime");
    -- get only time
    now = now - math.floor(now);
    -- check whether the time is in the exit time period
    if not(now >= TimeToExecute and ExecuteFlag == false)
	then            
        return ;
    end

    ExecuteFlag = true;
    DeleteNoTriggeredOrders(OrderIDs);
		
	if id~= 1 or  Source:size()-1 < 4 	then
        return;
	end
	   
    if haveTrades('B') == false and  haveTrades('S') == false then
    
        local req1 = CreateOrder(highest( 4,period), 'B');
        local req2 = CreateOrder(lowest( 4,period), 'S');
        
        if req1 ~= false then
           RequestIDs[#RequestIDs + 1] = req1;
        end
           
        if req2 ~= false then
           RequestIDs[#RequestIDs + 1] = req2;
        end
        
        return ;
    end
    
	
	
    if haveTrades('S') then
           local rate = highest( 4,period)
           --place buy stop close entry order at highest of previous 4 candles to close the short position 
           local req1 = CreateOrder(rate, 'B');           
           local req2 = CreateOrder(rate, 'B');
           
           if req1 ~= false then
               RequestIDs[#RequestIDs + 1] = req1;
           end
           
           if req2 ~= false then
               RequestIDs[#RequestIDs + 1] = req2;
           end
    end    
    
    if haveTrades('B') then
        local rate = lowest( 4,period)
        local req1 = CreateOrder(rate, 'S');           
        local req2 = CreateOrder(rate, 'S');
        
        if req1 ~= false then
           RequestIDs[#RequestIDs + 1] = req1;
        end
           
        if req2 ~= false then
           RequestIDs[#RequestIDs + 1] = req2;
        end
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
    elseif cookie == 100 then
    
       local now = core.host:execute("getServerTime");
       now = now - math.floor(now);
       if now <= ResetTime and ExecuteFlag == true then       
           ExecuteFlag = false
           clearTable(RequestIDs);
       end   
    end   
end

function tradesCount(BuySell) 
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and (row.BS == BuySell or BuySell == nil) then
            count = count + 1;
        end

        row = enum:next();
    end
    
    return count;
end

function haveTrades(BuySell) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end

    return found
end

function highest( count,period)
    local highest = 0;
	for i = 0, count -1 do
        local high = Source.high[period - count]; 	
	    if highest < high then
	        highest = high;
	    end
	end
	
	return highest
end

function lowest( count,period)
    local lowest = 0xffffffff;
	for i = 0, count -1 do
        local low = Source.low[period - count]; 	
	    if lowest > low then
	        lowest = low;
	    end
	end
	
	return lowest
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

function CreateOrder(rate, side)

    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    
    if side == "B" then
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
    valuemap.BuySell = side;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.Rate = rate;
    valuemap.CustomID = CustomID;

    success, msg = terminal:execute(200, valuemap);
    
    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end
    
    return msg;
end

function CreateMarketOrder(side)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.BuySell = side;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.CustomID = CustomID;
    
    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return msg;
end

function clearTable(table)
    for k in pairs (table) do
        table[k] = nil
    end
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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");