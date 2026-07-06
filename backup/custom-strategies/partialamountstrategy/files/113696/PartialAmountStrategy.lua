-- Id: 18720
-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    strategy:name("Partial Amount Strategy");
    strategy:description("");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "PAS");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addString("Instrument", "Instrument", "", "");
    strategy.parameters:setFlag("Instrument",core.FLAG_INSTRUMENTS);  
    strategy.parameters:addDouble("OpenRate", "Open Rate", "Open Trade when above current ", 0, 0.1, 100000);
    strategy.parameters:addDouble("CloseRate", "Close Rate", "Close Trade when below current", 0, 0.1, 100000);
    strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1, 1, 100);
  
    strategy.parameters:addInteger("TradeSide", "Comparison Method", "Comparison method between Current Rate and OpentRate", 0);
    strategy.parameters:addIntegerAlternative("TradeSide", "Above", "Current Rate > OpenRate", 0);
    strategy.parameters:addIntegerAlternative("TradeSide", "Below", "Current Rate < OpenRate", 1);

    strategy.parameters:addGroup("Order Parameters");
    strategy.parameters:addInteger("OpenAmount", "Open Amount", "", 1, 1, 100);
    strategy.parameters:addInteger("CloseAmount", "Close Amount", "", 1, 1, 100);	    
    strategy.parameters:addString("Side", "Side", "Side for trading or signaling, can be Sell, Buy", "Buy");
    strategy.parameters:addStringAlternative("Side", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("Side", "Sell", "", "Sell");
	
    strategy.parameters:addBoolean("isNeedStop", "Use stop?", "", false);
    strategy.parameters:addInteger("Stop", "Stop", "", 5, 1, 10000);	
    strategy.parameters:addBoolean("isNeedLimit", "Use limit?", "", false);
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
local OpenRate;
local CloseRate    
local OpenAmount;
local CloseAmount;

local isNeedLimit;
local isNeedStop;
local isNeedTrailing;
local isNeedDynamicTrailing;
local Limit;
local TrailingStop;

local RequestIDs = {}
local OrderIDs = {}
local TradeSide;
local MaxNumberOfPosition;

function Prepare(nameOnly)
    local name;
    name = profile:id() .. "( " .. instance.bid:name();	
	name = name ..  ", " .. instance.parameters.OpenRate .. ", " .. instance.parameters.CloseRate .. ", " .. 
           instance.parameters.OpenAmount.. ", " .. instance.parameters.CloseAmount
    
    
    name = name  ..  " )";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    PrepareTrading();
	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
    if OpenRate > CloseRate then 
        TradeSide = 1;
    else
        TradeSide = 0;
    end	
end

function PrepareTrading()

    CustomID = instance.parameters.CustomID;
    Account = instance.parameters.Account;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
     
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
 
    Side = (instance.parameters:getString("Side") == "Buy") and "B" or "S";                     
        
    Stop = instance.parameters:getInteger("Stop");
    Limit = instance.parameters:getInteger("Limit");
        
    isNeedLimit = instance.parameters:getBoolean("isNeedLimit");
    isNeedStop = instance.parameters:getBoolean("isNeedStop");
    isNeedTrailing = instance.parameters:getBoolean("isNeedTrailing");
    isNeedDynamicTrailing = instance.parameters:getBoolean("isNeedDynamicTrailing");
    Limit = instance.parameters:getInteger("Limit");

    TrailingStop = instance.parameters:getInteger("TrailingStop");    
    
    local rate = instance.parameters:getDouble("OpenRate");
    assert(rate > 0, "Please, Specify Open Rate");          
    OpenRate = rate;
    
    rate = instance.parameters:getDouble("CloseRate");
    assert(rate > 0, "Please, Specify Close Rate");          
    CloseRate = rate;
    
    OrdersAmount = instance.parameters:getInteger("OrdersAmount");
    OpenAmount = instance.parameters:getInteger("OpenAmount");
    CloseAmount = instance.parameters:getInteger("CloseAmount");
    TradeSide = instance.parameters:getInteger("TradeSide");
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
    
    
    assert(OpenAmount > CloseAmount, "Please, check parameters, Open Amount > Close Amount");          
end

local OrderCreationTime = nil;
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if not instance.parameters.AllowTrade then
        return;
    end
    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end

    local currentRate = TickSource[NOW];
    local isOpenRateReached = false;
    local isCloseRateReached = false;
    
    if TradeSide == 0 then 
        isOpenRateReached = currentRate > OpenRate;
    else 
        isOpenRateReached = currentRate < OpenRate;
    end
    
    if TradeSide == 0 then 
        isCloseRateReached = currentRate > CloseRate;
    else 
        isCloseRateReached = currentRate < CloseRate;
    end
    
    if isOpenRateReached == true then 
        enter(Side);
    end
    
    if isCloseRateReached == true then 
        exit(Side);
    end     
end

function enter(side)
    if tradesCount(side) >= MaxNumberOfPosition
	then
        return true;
    end

    return CreateMarketOrder(side);
end

function CreateMarketOrder(side)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.BuySell = side;
    valuemap.Quantity = OpenAmount * BaseSize;
    valuemap.CustomID = CustomID;

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
    
    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open market order failed " .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end
    
    return msg;
end

function CreateCloseOrder(trade)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "CM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = CloseAmount * BaseSize;
    valuemap.CustomID = CustomID;
    valuemap.TradeID = trade.TradeID;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end
        
    success, msg = terminal:execute(201, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Close market order failed " .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end
    
    return msg;
end

function FindFirstOpenTrade()
    local enum, row, valuemap;

    enum = core.host:findTable("trades"):enumerator();

    while true do
        row = enum:next();
        if row == nil then
            return nil;
        end
        if row.AccountID == Account and
           row.OfferID == Offer and
           row.BS == Side and
           row.QTXT == CustomID then
            return  row;
        end
    end
    
    return nil;
end

function exit()
    local openTrade = FindFirstOpenTrade();
    if openTrade ~= nil then
        CreateCloseOrder(openTrade);
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 200 then
        if  not success then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. message, instance.bid:date(instance.bid:size() - 1));
        end
    end
    
    if cookie == 201 then
        if  not success then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Close order failed " .. message, instance.bid:date(instance.bid:size() - 1));
        end
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");