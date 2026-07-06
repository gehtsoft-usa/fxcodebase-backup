-- Id: 21965
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=66496

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
    strategy:name("Tuesday Turnaround Strategy");
    strategy:description("");
           
    strategy.parameters:addString("Symbol", "Symbol", "", "GER30");
    strategy.parameters:setFlag("Symbol", core.FLAG_INSTRUMENTS );

    strategy.parameters:addString("TF", "Time frame", "", "D1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    
    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("AveragePeriod","MVA Period","", 34);

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "TuesdayTurnaroundStrategy");

    strategy.parameters:addGroup("Strategy Parameters");    
    strategy.parameters:addInteger("Amount", "Amount", "", 1, 1, 100);	        

    strategy.parameters:addGroup("Time Parameters");
    strategy.parameters:addString("OpenTime", "Time for open position on Monday", "", "17:00:00");
    strategy.parameters:addString("CloseTime", "Time for close position on Tuesday", "", "17:00:00");
end

local Account;
local BaseSize;
local CanClose;
local CustomID;
local Offer;
local Amount;
local First;
local AveragePeriod;

local Source;
local MA;
local OpenTime;
local CloseTime;
local OpenRequestID;
local TradeID;

local check_flag;
local need_to_create_order;

function Prepare(nameOnly)
  
    local name;
    name = profile:id() .. "( " .. instance.bid:name();
	
	name = name .. ", " .. instance.parameters.TF .. ", " .. instance.parameters.AveragePeriod .. ", " .. 
           instance.parameters.OpenTime .. ", "  .. instance.parameters.CloseTime
	         
    name = name  ..  ")";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    PrepareTrading();
	       
	minSource = ExtSubscribe(1, nil, "m1", instance.parameters.Type == "Bid", "close");
	Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");
	
    First=Source:first();
    
    AveragePeriod = instance.parameters.AveragePeriod
    
    MA = core.indicators:create("MVA", Source.close, instance.parameters.AveragePeriod)
    check_flag = false;
    need_to_create_order = false;
    OpenRequestID = nil;
    TradeID = nil;
end

function PrepareTrading()
    
    OpenTime, valid = ParseTime(instance.parameters.OpenTime);
    assert(valid, "TimeToOpen " .. instance.parameters.OpenTime .. " is invalid");

    CloseTime, valid = ParseTime(instance.parameters.CloseTime);
    assert(valid, "TimeToClose " .. instance.parameters.CloseTime .. " is invalid");
  
    CustomID = instance.parameters.CustomID;
    Account = instance.parameters.Account;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
     
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID; 
    Amount = instance.parameters:getInteger("Amount"); 
end


local Period;
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
   
    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end
    
    if id == 2 then
        return;
	end

    MA:update(core.UpdateLast);
    
    if period < First + AveragePeriod then
        return 
    end  
    
    date = core.dateToTable(source:date(period));  
    day_of_week = core.dateToTable(source:date(period))
    
    local now = core.host:execute("getServerTime");
    now = now - math.floor(now);

    if day_of_week.wday == 2 then --Monday
    
        if now >= OpenTime and TradeID == nil and need_to_create_order == true then
            local req = CreateMarketOrder("B");
            if req ~= false then
               OpenRequestID = req;
            end
            need_to_create_order = false;
        end
        
        if check_flag == false then
            check_flag = true;
            local friday = core.tableToDate(day_of_week) - 3; --get Friday
            local friday_bar = core.findDate(Source, friday, false);
            local friday_average_bar = core.findDate(MA.DATA, friday, false);
            local friday_bar_close = Source.close[friday_bar];
            local friday_average_bar_close = MA.DATA[friday_average_bar];
            if friday_average_bar_close > friday_bar_close then
               need_to_create_order = true;
            end
        end
    elseif day_of_week.wday == 3 then --Tuesday
        need_to_create_order = false;
        check_flag = false
    
        if now >= CloseTime and TradeID ~= nil then
            CloseTrade(TradeID);
            if req ~= false then
                TradeID = nil
            end
        end        
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 200 then
        if  not success then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. message, instance.bid:date(instance.bid:size() - 1));
        else
            if OpenRequestID ~= nil then               
                found, TradeID = findTradeIDByRequestID(OpenRequestID)
                if found == true then 
                   OpenRequestID = nil
                end
            end
        end
    end   
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

function CreateMarketOrder(side)
    if not instance.parameters.AllowTrade then
        return;
    end
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

function CloseTrade(trade_id)
    if not instance.parameters.AllowTrade then
        return;
    end
    local valuemap, success, msg;
    valuemap = core.valuemap();

    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        if row.TradeID == trade_id then
           break;
        end
        row = enum:next();
    end
    
    if row ~= nil then
        -- switch the direction since the order must be in oppsite direction
        if row.BS == "B" then
            valuemap.BuySell = "S";
        else
            valuemap.BuySell = "B";
        end
            
        valuemap.OrderType = "CM";
        valuemap.OfferID = row.OfferID;
        valuemap.AcctID = Account;
        valuemap.NetQtyFlag = "N";
        valuemap.TradeID = row.TradeID;
        valuemap.Quantity = row.Lot;
        success, msg = terminal:execute(101, valuemap);

        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close trade failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        end
    end
end

function findTradeIDByRequestID(request_id)
   local enum, row;
   local found = false;
   local trade_id = nil;
   
   enum = core.host:findTable("trades"):enumerator();
   row = enum:next();
   while (not found) and (row ~= nil) do
       if row.OpenOrderReqID == request_id then
           found = true;
           trade_id = row.TradeID;
           break;
       end
       row = enum:next();
   end

   return found, trade_id;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");