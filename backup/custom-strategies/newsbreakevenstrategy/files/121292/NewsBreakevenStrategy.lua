-- Id: 22358
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=66679
 
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
    strategy:name("NewsBreakevenStrategy");
    strategy:description("");
           
    strategy.parameters:addString("Indicator", "Indicator", "", "NEWS");
    strategy.parameters:setFlag("Indicator",core.FLAG_INDICATOR);	

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
    
    strategy.parameters:addInteger("BreakevenPeriod", "BreakevenPeriod", "Depends on BreakevenPeriodType(ex BreakevenPeriod = 1 / BreakevenPeriodType = Hour  - Breakeven will be set one hour before the news)", 1, 0, 100);   
    strategy.parameters:addString("BreakevenPeriodType", "BreakevenPeriodType", "Type of time period" , "Hour");
    strategy.parameters:addStringAlternative("BreakevenPeriodType", "Min", "Min" , "Min");
    strategy.parameters:addStringAlternative("BreakevenPeriodType", "Hour", "Hour" , "Hour");
 
    strategy.parameters:addGroup("Settings");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	strategy.parameters:addDouble("Profit", "Min Profit (in pips)", "", 10.0);
    strategy.parameters:addString("Account", "Account", "Account to monitor open positions for.", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
end

local Account;
local BaseSize;
local CanClose;
local Offer;
local Amount;
local Profit;
local IndiInstance = nil;
local news = {}
local deltaTime = 0;
local request_id = {}
local used_stop_orders = {}

function Prepare(nameOnly)
  
    local name;
    name = profile:id() .. "( " .. instance.bid:name();
	name = name .. ", " .. instance.parameters.Profit
    name = name  ..  " )";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    local news_time_frame = "H1"

    if instance.parameters.BreakevenPeriodType == "Min" then
        deltaTime = 60; --sec
    elseif  instance.parameters.BreakevenPeriodType == "Hour" then
        deltaTime = 60 * 60; --sec and min
    end
    
    deltaTime = instance.parameters.BreakevenPeriod * deltaTime * 1 / 86400;
    
    
    PrepareTrading();	    
    Source = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
    Source = ExtSubscribe(2, nil, news_time_frame, instance.parameters.Type == "Bid", "bar"); 

    local profile = core.indicators:findIndicator(instance.parameters.Indicator);
    local params = instance.parameters:getCustomParameters("Indicator");
    IndiInstance = profile:createInstance(Source, params);
end

function PrepareTrading()
    
    Profit= instance.parameters.Profit;
    Account = instance.parameters.Account;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
    
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID; 
    Amount = instance.parameters:getInteger("Amount"); 
end

local Period;
local outputStreamsCount
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
	if id == 2 or not instance.parameters.AllowTrade then
        return;
	end
	
    local now = core.host:execute("getServerTime");
    local t_now = core.dateToTable (now);
    local t_now_next =  t_now;
    t_now_next.min =  t_now_next.min + 1;
    
    local date_next = core.tableToDate(t_now_next);
    
    
    IndiInstance:update(core.UpdateAll);
    UpdateNewsData(news, now)
    CheckNews(now, deltaTime)   
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 200 then
        if  not success then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. message, instance.bid:date(instance.bid:size() - 1));
        end
    end   
end

function UpdateNewsData(news, now)

    local t_now = core.dateToTable (now)
    local streamsCount = IndiInstance:getTextOutputCount();   	
    for i = 0, streamsCount - 1  do
        local textOutput = IndiInstance:getTextOutput(i);
        for j = 0, textOutput:size() - 1  do
           if (textOutput:hasData(j) == true) then
                level, label, tooltip = textOutput:get(j);
                
                inst, date, text = parseTooltip(tooltip, t_now);
                if (date > now) then
                    instNews = news[inst];
                    data = {date = date, text = text};
                    if instNews == nil then
                        newsArray = {};
                        table.insert(newsArray, data);
                        news[inst] = newsArray;
                    else
                        if has_date(instNews, date) == false then
                            table.insert(instNews, data);              
                        end
                    end
                end
           end
        end
    end
end

function has_date(tab, date)

    for index, value in ipairs(tab) do
        if value.date == date then
            return true
        end
    end
    
    return false
end

function CheckNews(now, deltaTime)  
    for instrument, events in pairs(news) do
        for index, event in pairs(events) do
            if (event.date - now > 0 and event.date - now <= deltaTime) then
                CheckTrades(instrument);
                news[instrument][index] = nil
            end
        end
    end
end

function CheckTrades(instrument)

    enum = core.host:findTable("trades"):enumerator();
    tradeRow = enum:next();
    while (tradeRow ~= nil) do
        if tradeRow.AccountID == Account and string.match(tradeRow.Instrument,instrument)then
            Breakevent(tradeRow)
        end
        tradeRow = enum:next();
    end
end

function parseTooltip(tooltip, t_now)

    M, d, h, m, instr, text   = string.match(tooltip, "(%d+)/(%d+) (%d+):(%d+) (%a+) (.+)");
    M = tonumber(M);
    d = tonumber(d);
    h = tonumber(h);
    m = tonumber(m);
    
    y = M >= t_now.month and t_now.year or t_now.year - 1;
                      
    local tdate = {year = y, month = M, day = d, hour = h, min = m, sec = 0};
    local date = core.tableToDate(tdate);
       
    return instr, date, text
end

function Breakevent(trade)
    
    local offer = getOffer(trade.Instrument)
    local stopValue;

    if trade.BS == "B"  then
        if trade.PL > Profit then
            stopValue = offer.Ask - trade.PL * offer.PointSize; 
        else
            return ;
        end
        
        if stopValue >= offer.Bid then                 
            return ;
        end
    else
        if trade.PL > Profit  then
            stopValue = offer.Bid  + trade.PL * offer.PointSize; 
        else
            return ;
        end
        if stopValue <= offer.Ask then                   
            return ;
        end
    end

    moveStop(stopValue, trade)
end

function getOffer(instrument)
    local row, enum;   

    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        if string.match(row.Instrument, instrument) then
            return row;
        end
        row = enum:next();
    end

    return nil;
end

function moveStop(stop_rate, trade)
    local order = findStopOrder(trade);
    if order == nil then
        return createStopOrder(stop_rate, trade);
    else
        return changeOrder(stop_rate, order);
    end
end

function findStopOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
            order_id = trade.StopOrderID;
        elseif request_id[trade.TradeID] ~= nil then
            local order = core.host:findTable("orders"):find("RequestID", request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and isStopOrderType(row.Type) and used_stop_orders[row.OrderID] ~= true then
                used_stop_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function createStopOrder(stop_rate, trade, trailing)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = stop_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end

    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "S";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
        valuemap.TrailUpdatePips = trailing;
    else
        valuemap.OrderType = "SE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end

    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        local message = "Failed create stop " .. msg;
        core.host:trace(message);
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    request_id[trade.TradeID] = msg;
    return res;
end


function changeOrder(rate, order)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(rate - order.Rate) > min_change then
        core.host:trace(string.format("Changing an order to %s", tostring(rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.TrailUpdatePips = order.TrlMinMove ~= 0 and order.TrlMinMove or nil;
        valuemap.Rate = rate;
        
        local success, msg = terminal:execute(200, valuemap);
        if not(success) then
            local message = "Failed change order " .. msg;
            core.host:trace(message);
            local res = {};
            res.Finished = true;
            res.Success = false;
            res.Error = message;
            return res;
        end
        local res = {};
        res.Finished = false;
        res.RequestID = msg;
        return res;
    end
    local res = {};
    res.Finished = true;
    res.Success = true;
    return res;
end

function isStopOrderType(order_type) return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE"; end

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. message , instance.bid:date(NOW));
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");