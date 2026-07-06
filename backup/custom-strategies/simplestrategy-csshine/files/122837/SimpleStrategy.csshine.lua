-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=67168

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
    strategy:name("SimpleStrategy");
    strategy:description("");
    
    strategy.parameters:addGroup("Indicator Parameters");       
    strategy.parameters:addString("TF", "Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    
    strategy.parameters:addString("Indicator", "Indicator", "", "RSI");
    strategy.parameters:setFlag("Indicator",core.FLAG_INDICATOR);	

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "SimpleStrategy.csshine");

    strategy.parameters:addGroup("Strategy Parameters");    
    strategy.parameters:addInteger("BullLevel", "Bull RSI Level", "", 80, 1, 1000);	        
    strategy.parameters:addInteger("BearLevel", "Bear RSI Level", "", 20, 1, 1000);
    strategy.parameters:addInteger("Amount", "Amount", "", 1, 1, 100000);	        
    
    strategy.parameters:addBoolean("SetStop", "Use stop?", "", false);
    strategy.parameters:addInteger("Stop", "Stop(pips)", "", 5, 1, 10000);	
    strategy.parameters:addBoolean("SetLimit", "Use limit?", "", true);
    strategy.parameters:addInteger("Limit", "Limit(pips)", "", 50, 1, 10000);	

    strategy.parameters:addBoolean("IsNeedTrailing", "Use trailing?", "", false);
    strategy.parameters:addBoolean("IsNeedDynamicTrailing", "  Dynamic trailing mode", "", false);
    strategy.parameters:addInteger("TrailingStop", "  Fixed trailing stop (pips)", "", 5, 5, 500);
end

local Account;
local BaseSize;
local CanClose;
local CustomID;
local Offer;
local Amount;

local SetLimit;
local Limit;
local SetStop;
local Stop;
local IsNeedTrailing;
local IsNeedDynamicTrailing;
local TrailingStop;
    
local BullLevel;
local BearLevel;
local IndicatorInstance;
local First;
local isBearTradingFlag;
local isBullTradingFlag;

local BullTrade = {};
local BearTrade = {};

function Prepare(nameOnly)
  
    local name;
    name = profile:id() .. "( " .. instance.bid:name();
	
	name = name .. ", " .. instance.parameters.TF .. ", " .. instance.parameters.BullLevel .. ", " .. instance.parameters.BearLevel;
   
    name = name  ..  " )";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
    
    core.host:execute("subscribeTradeEvents", 2000, "trades");  
    PrepareTrading();
	    
    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
    
    local indiProfile = core.indicators:findIndicator(instance.parameters:getString("Indicator"));
    local params = instance.parameters:getCustomParameters("Indicator");	          
    IndicatorInstance = indiProfile:createInstance(Source, params);
    First = IndicatorInstance.DATA:first(); 
end

function PrepareTrading()
    
    CustomID = instance.parameters.CustomID;
    Account = instance.parameters.Account;
    
    BullLevel = instance.parameters.BullLevel;
    BearLevel = instance.parameters.BearLevel;

    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)    
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID; 
    Amount = instance.parameters:getInteger("Amount"); 
    
    SetLimit = instance.parameters.SetLimit;
    Limit = instance.parameters.Limit;
    SetStop = instance.parameters.SetStop;
    Stop = instance.parameters.Stop;
    
    IsNeedTrailing = instance.parameters:getBoolean("IsNeedTrailing");
    IsNeedDynamicTrailing = instance.parameters:getBoolean("IsNeedDynamicTrailing");
    TrailingStop = instance.parameters:getInteger("TrailingStop");    

    BullTrade.isTradingFlag = false;
    BearTrade.isTradingFlag = false;
end


local Period;
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.

    if period < First + 1  then
        return ;
    end

    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end
    
    IndicatorInstance:update(mode);
    
    if BullTrade.isTradingFlag  == false and
        IndicatorInstance.DATA[period] > BullLevel and
        IndicatorInstance.DATA[period] > IndicatorInstance.DATA[period - 1] and 
        source.high[period] < source.high[period - 1] then
        openSell();
    end

    if BearTrade.isTradingFlag == false and
        IndicatorInstance.DATA[period] < BearLevel and
        IndicatorInstance.DATA[period] < IndicatorInstance.DATA[period - 1] and 
        source.high[period] > source.high[period - 1] then
        openBuy();
    end
end

function openSell()
    local success, requestID = MarketOrder("S");
    if success == true then
        BullTrade.RequestID = requestID;
        core.host:trace(string.format("Request %s for BullTrade is created", requestID));
    end
end

function openBuy()
    local success, requestID = MarketOrder("B");
    if success == true then
        BearTrade.isTradingFlag = true
        BearTrade.RequestID = requestID
        core.host:trace(string.format("Request %s for BearTrade is created", requestID));
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 200 then
        if  not success then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. message, instance.bid:date(instance.bid:size() - 1));
        end
    end
    
    local dateTime = instance.bid:date(instance.bid:size() - 1);
    if cookie == 2000 then    
        if message == BearTrade.TradeID then
            if CheckClosingTrade(BearTrade) == true then
                clearTable(BearTrade);
                BearTrade.isTradingFlag = false;
                core.host:trace(string.format("%s BearTrade %s is closed", core.formatDate(dateTime), message));
            end                
        elseif message == BullTrade.TradeID then
            if CheckClosingTrade(BullTrade) == true then
                clearTable(BullTrade);
                BullTrade.isTradingFlag = false;
                core.host:trace(string.format("%s BullTrade %s is closed", core.formatDate(dateTime), message));
            end        
        elseif message2 == BearTrade.RequestID then
            BearTrade.TradeID = message
            SetLimitAndStop(BearTrade)
            BearTrade.isTradingFlag = true;
            core.host:trace(string.format("%s BearTrade %s is created", core.formatDate(dateTime), message));
        elseif message2 == BullTrade.RequestID then
            BullTrade.TradeID = message;
            SetLimitAndStop(BullTrade)
            BullTrade.isTradingFlag = true;
            core.host:trace(string.format("%s BullTrade %s is created", core.formatDate(dateTime), message));
        end               
    end
end


function CheckClosingTrade(trade)  
    local enum, row;
    local found = false;
    enum = core.host:findTable("closed trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        if row.TradeID == trade.TradeID then
           found = true;
        end
        row = enum:next();
    end

    return found
end

function SetLimitAndStop(trade)
    
    local enum, row;
    local found = nil;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (found == nil) and (row ~= nil) do
        if row.TradeID == trade.TradeID then
           found = row;
        end
        row = enum:next();
    end

    if found ~= nil then
        trade.StopOrderID = found.StopOrderID;
        trade.LimitOrderID = found.LimitOrderID;
    end
end

-- enter into the specified direction
function MarketOrder(BuySell)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;
    valuemap.CustomID = CustomID;

    -- add stop/limit
    valuemap.PegTypeStop = "O";
    if SetStop then 
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop;
        else
            valuemap.PegPriceOffsetPipsStop = Stop;
        end
    end
    
    if IsNeedTrailing then
        valuemap.TrailStepStop = (IsNeedDynamicTrailing and 1 or TrailingStop);
    end

    valuemap.PegTypeLimit = "O";
    if SetLimit then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit;
        end
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = 'Y'
    end

    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false, msg;
    end

    return true, msg;
end

function clearTable(table)
    for k in pairs (table) do
        table[k] = nil
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");