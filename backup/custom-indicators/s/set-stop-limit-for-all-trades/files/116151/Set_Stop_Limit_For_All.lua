-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65384

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
    indicator:name("Set stop/limit for all");
    indicator:description("Set stop/limit for all");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addDouble("StopLevel", "Stop level", "Stop level for set stop command", 50);
    indicator.parameters:addDouble("LimitLevel", "Limit level", "Limit level for set limit command", 50);
    
    indicator.parameters:addString("Account", "Account", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
end

local source;
local CanClose;

function Prepare(nameOnly)
    local name = profile:id();
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    
    stub = instance:addStream("stub", core.Line, "stub", "stub", core.rgb(255, 0, 0), 0);
    
    core.host:execute("addCommand", 101, "Set limit");
    core.host:execute("addCommand", 102, "Set stop");

    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", source:instrument(), instance.parameters.Account);
end

function Update(period)
end

function SetLimit()
 local limitValue;
            
 local trades = core.host:findTable("trades");
 local enum = trades:enumerator();
 while true do
  local trade = enum:next();
  if trade == nil then break end
  if trade.Instrument==source:instrument() then
   if trade.BS == "B" then
    limitValue=trade.Open+instance.parameters.LimitLevel*source:pipSize();
    setLimit(trade, limitValue, "S");
   else
    limitValue=trade.Open-instance.parameters.LimitLevel*source:pipSize();
    setLimit(trade, limitValue, "B");
   end
  end
 end
end

function setLimit(trade, limitValue, limitSide)
 if CanClose then
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
   executing = true;
   success, msg = terminal:execute(200, valuemap);
   if not(success) then
    executing = false;
    terminal:alertMessage(source:instrument(), source[NOW], "Failed create limit " .. msg, source:date(NOW));
   end
  else
    valuemap = core.valuemap();
    valuemap.Command = "EditOrder";
    valuemap.AcctID = trade.AccountID;
    valuemap.OrderID = trade.LimitOrderID;
    valuemap.Rate = limitValue;
    executing = true;
    success, msg = terminal:execute(200, valuemap);
    if not(success) then
     executing = false;
     terminal:alertMessage(source:instrument(), source[NOW], "Failed change limit " .. msg, source:date(NOW));
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
   executing = true;
   success, msg = terminal:execute(200, valuemap);
   if not(success) then
    executing = false;
    terminal:alertMessage(source:instrument(), source[NOW], "Failed create limit " .. msg, source:date(NOW));
   end
  else
    valuemap = core.valuemap();
    valuemap.Command = "EditOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.OrderID = order;
    valuemap.Rate = limitValue;
    executing = true;
    success, msg = terminal:execute(200, valuemap);
    if not(success) then
     executing = false;
     terminal:alertMessage(source:instrument(), source[NOW], "Failed change limit " .. msg, source:date(NOW));
    end
  end
 end 

end

function SetStop()
 local stopValue;
            
 local trades = core.host:findTable("trades");
 local enum = trades:enumerator();
 while true do
  local trade = enum:next();
  if trade == nil then break end
  if trade.Instrument==source:instrument() then
   if trade.BS == "B" then
    stopValue=trade.Open-instance.parameters.StopLevel*source:pipSize();
    setStop(trade, stopValue, "S");
   else
    stopValue=trade.Open+instance.parameters.StopLevel*source:pipSize();
    setStop(trade, stopValue, "B");
   end
  end
 end
end

function setStop(trade, stopValue, stopSide)
 if CanClose then
  if trade.StopOrderID == "" or trade.StopOrderID == nil then
   valuemap = core.valuemap();
   valuemap.Command = "CreateOrder";
   valuemap.OrderType = "S";
   valuemap.OfferID = trade.OfferID;
   valuemap.AcctID = trade.AccountID;
   valuemap.TradeID = trade.TradeID;
   valuemap.Quantity = trade.Lot;
   valuemap.Rate = stopValue;
   valuemap.BuySell = stopSide;
   executing = true;
   success, msg = terminal:execute(200, valuemap);
   if not(success) then
    executing = false;
    terminal:alertMessage(source:instrument(), source[NOW], "Failed create stop " .. msg, source:date(NOW));
   end
  else
    valuemap = core.valuemap();
    valuemap.Command = "EditOrder";
    valuemap.AcctID = trade.AccountID;
    valuemap.OrderID = trade.StopOrderID;
    valuemap.Rate = stopValue;
    executing = true;
    success, msg = terminal:execute(200, valuemap);
    if not(success) then
     executing = false;
     terminal:alertMessage(source:instrument(), source[NOW], "Failed change stop " .. msg, source:date(NOW));
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
    row.BS == stopSide and
    row.NetQuantity and
    row.Type == "SE" then
  
    order = row.OrderID;
    rate = row.Rate;
   end
   row = enum:next();
  end
             
  if order == nil then
   valuemap = core.valuemap();
   valuemap.Command = "CreateOrder";
   valuemap.OrderType = "SE";
   valuemap.OfferID = trade.OfferID;
   valuemap.AcctID = trade.AccountID;
   valuemap.TradeID = trade.TradeID;
   valuemap.NetQtyFlag = "y";
   valuemap.Rate = stopValue;
   valuemap.BuySell = stopSide;
   executing = true;
   success, msg = terminal:execute(200, valuemap);
   if not(success) then
    executing = false;
    terminal:alertMessage(source:instrument(), source[NOW], "Failed create stop " .. msg, source:date(NOW));
   end
  else
    valuemap = core.valuemap();
    valuemap.Command = "EditOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.OrderID = order;
    valuemap.Rate = stopValue;
    executing = true;
    success, msg = terminal:execute(200, valuemap);
    if not(success) then
     executing = false;
     terminal:alertMessage(source:instrument(), source[NOW], "Failed change stop " .. msg, source:date(NOW));
    end
  end
 end 

end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 101 then
        SetLimit();
    elseif cookie == 102 then
        SetStop();
    end
end
