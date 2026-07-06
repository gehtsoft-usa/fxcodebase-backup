-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=19945

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    strategy:name("Trailing limits");
    strategy:description("v2 2018-08-04");
    strategy:setTag("strategy_type", "Money management");

    strategy.parameters:addGroup("Limit Parameters");
    strategy.parameters:addInteger("LimitLevel", "Limit level", "", 100);
    strategy.parameters:addInteger("TrailingStep", "Trailing step", "", 20);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("Symbol", "Choose Symbol", "", "");
    strategy.parameters:setFlag("Symbol", core.FLAG_INSTRUMENTS);
    strategy.parameters:addBoolean("all_symbols", "Monitor all symbols", "", false);
end

local first = true;
local tsource = nil;
local timer;
local all_symbols;
local instruments = {};

function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Period  .. "]" ..
                           "," .. instance.parameters.LimitLevel .. "," ..
                           "," .. instance.parameters.TrailingStep .. "," ..
                           instance.parameters.Symbol .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    all_symbols = instance.parameters.all_symbols;

    ExtSetupSignal(name .. ":", true);
    tsource = ExtSubscribe(1, instance.parameters.Symbol, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
end

function SetLimitForTrade(trade)
    Offer = core.host:findTable("offers"):find("Instrument", trade.Instrument);
    local price;
    if instance.parameters.Type == "Bid" then
        price = Offer.Bid;
    else
        price = Offer.Ask;
    end
    if instruments[trade.Instrument] == nil then
        local data = {};
        data.minChange = math.pow(10, -Offer.PointSize);
        data.CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, instance.parameters.Account);
        instruments[trade.Instrument] = data;
    end
    
    if trade.BS == "B" then
        limitValue = price + instance.parameters.LimitLevel * Offer.PointSize;
        setLimit(trade, limitValue, "S");
    else
        limitValue = price - instance.parameters.LimitLevel * Offer.PointSize;
        setLimit(trade, limitValue, "B");
    end
end

function SetLimit(source, period)
    local trades = core.host:findTable("trades");
    local enum = trades:enumerator();
    local trade = enum:next();
    while trade ~= nil do
        if trade.Instrument == instance.parameters.Symbol or all_symbols then
            SetLimitForTrade(trade);
        end
        trade = enum:next();
    end
end

function setLimit(trade, limitValue, limitSide)
 if instruments[trade.Instrument].CanClose then
  if trade.LimitOrderID == "" or trade.LimitOrderID == nil then
   valuemap = core.valuemap();
   valuemap.Command = "CreateOrder";
   valuemap.OrderType = "L";
   valuemap.OfferID = trade.OfferID;
   valuemap.AcctID = trade.AccountID;
   valuemap.TradeID = trade.TradeID;
   valuemap.Quantity = trade.Lot;
   valuemap.Rate = limitValue;
   valuemap.BuySell = limitSide;
   success, msg = terminal:execute(200, valuemap);
   if not(success) then
    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create limit " .. msg, instance.bid:date(NOW));
   end
  else
   if trade.BS=="B" then
    if limitValue>trade.Limit-instance.parameters.TrailingStep*instance.bid:pipSize() then
     return;
    end
   else
    if limitValue<trade.Limit+instance.parameters.TrailingStep*instance.bid:pipSize() then
     return;
    end
   end
   if math.abs(limitValue - trade.Limit) > instruments[trade.Instrument].minChange then
    -- limit exists
    valuemap = core.valuemap();
    valuemap.Command = "EditOrder";
    valuemap.AcctID = trade.AccountID;
    valuemap.OrderID = trade.LimitOrderID;
    valuemap.Rate = limitValue;
    success, msg = terminal:execute(200, valuemap);
    if not(success) then
     terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed change limit " .. msg, instance.bid:date(NOW));
    end
   end
  end
 else
  local order = nil;
  local rate;
 
  local enum, row;
  enum = core.host:findTable("orders"):enumerator();
  row = enum:next();
  while (row ~= nil) do
   if row.OfferID == trade.OfferID and
    row.AccountID == trade.AccountID and
    row.BS == limitSide and
    row.NetQuantity and
    row.Type == "LE" then
  
    order = row.OrderID;
    rate = row.Rate;
   end
   row = enum:next();
  end
             
  if order == nil then
   valuemap = core.valuemap();
   valuemap.Command = "CreateOrder";
   valuemap.OrderType = "LE";
   valuemap.OfferID = trade.OfferID;
   valuemap.AcctID = trade.AccountID;
   valuemap.TradeID = trade.TradeID;
   valuemap.NetQtyFlag = "y";
   valuemap.Rate = limitValue;
   valuemap.BuySell = limitSide;
   success, msg = terminal:execute(200, valuemap);
   if not(success) then
    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create liit " .. msg, instance.bid:date(NOW));
   end
  else
   if trade.BS=="B" then
    if limitValue>rate-instance.parameters.TrailingStep*instance.bid:pipSize() then
     return;
    end
   else
    if limitValue<rate+instance.parameters.TrailingStep*instance.bid:pipSize() then
     return;
    end
   end
   if math.abs(limitValue - rate) > instruments[trade.Instrument].minChange then
    -- limit exists
    valuemap = core.valuemap();
    valuemap.Command = "EditOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.OrderID = order;
    valuemap.Rate = limitValue;
    success, msg = terminal:execute(200, valuemap);
    if not(success) then
     terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed change limit " .. msg, instance.bid:date(NOW));
    end
   end
  end
 end 

end

function ExtUpdate(id, source, period)
    if id == 1 then
        if period > tsource:first() then
            -- check whether trade exists
            local trade, order;
            SetLimit(source, period);
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change limit " .. message, instance.bid:date(NOW));
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");