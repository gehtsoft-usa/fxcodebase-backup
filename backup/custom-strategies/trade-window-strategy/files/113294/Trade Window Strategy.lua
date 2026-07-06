-- Id: 18580
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64871

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
    strategy:name("Trade Window Strategy");
    strategy:description("");
    -- NG: optimizer/backtester hint
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email");

    strategy.parameters:addGroup("Trade Window");  
    strategy.parameters:addDouble("TradeStart", "Start Rate", "", 0, 0.1, 100);    
    strategy.parameters:addDouble("TargetRate", "Target Rate", "", 0, 0.1, 100);
        
    T={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4"};
    Sec={60, 300, 900, 1800, 3600, 7200, 10800, 14400};
	local i;
	strategy.parameters:addInteger("RepeatPeriod", "RepeatPeriod", "", 1);
	for i = 1, 8 ,  1 do 	
        strategy.parameters:addIntegerAlternative("RepeatPeriod", T[i], "", Sec[i]);
	end
    
    strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position", "", 5, 1, 100);
       
    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "TSAAR");

    strategy.parameters:addGroup("Strategy Parameters");    
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
local TargetRate;

local RepeatPeriod;
local MaxNumberOfPosition;

local Amount;
local Stop;
local Limit;
        
local isNeedLimit;
local isNeedStop;
local isNeedTrailing;
local isNeedDynamicTrailing;
local Limit;
local TrailingStop;
local LastTradeDate;
local isTradingStart;

local Direct = nil;


function Prepare(nameOnly)
  
    local name;
    name = profile:id() .. "( " .. instance.bid:name();
	
	name = instance.parameters.TradeStart .. ", " .. instance.parameters.TargetRate .. ", " .. 
           instance.parameters.RepeatPeriod.. ", " .. instance.parameters.MaxNumberOfPosition
    
    
    name = name  ..  " )";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    PrepareTrading();
	    
	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");	
	isTradingStart = false;
	LastTradeDate = 0.0;	    
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

    local rate = instance.parameters:getDouble("TargetRate");
    assert(rate > 0, "Please, Specify TargetRate");          
    TargetRate = rate;

    RepeatPeriod = instance.parameters:getInteger("RepeatPeriod");
    MaxNumberOfPosition = instance.parameters:getInteger("MaxNumberOfPosition");
end


local Period;
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.

    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end

    local currentRate = TickSource[NOW];   
    local lastTradeDiff = math.floor((TickSource:date(NOW) - LastTradeDate) * 100000); 

    if TradeStart < TargetRate then
        if currentRate >= TradeStart and isTradingStart == false then
            isTradingStart = true;
        end
            
        if currentRate >= TargetRate and isTradingStart == true then
            isTradingStart = false;
        end
    else 
        if currentRate >= TradeStart and isTradingStart == false then
            isTradingStart = true;
        end
            
        if currentRate <= TargetRate and isTradingStart == true then
            isTradingStart = false;
        end     
    end

    if isTradingStart == true and tradesCount(Side) < MaxNumberOfPosition and lastTradeDiff >= RepeatPeriod then   
        MarketOrder(Amount, Limit, Stop, Side)
        LastTradeDate = TickSource:date(NOW);
    end
            
end

function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1));
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

function MarketOrder(Amount, Limit, Stop, BuySell)
    if not instance.parameters.AllowTrade then
        return;
    end
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;
    valuemap.CustomID = CustomID;

    if isNeedStop then
        -- add stop/limit
        valuemap.PegTypeStop = "O";
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop;
        else
            valuemap.PegPriceOffsetPipsStop = Stop;
        end
    end
    
    if isNeedLimit then
        valuemap.PegTypeLimit = "O";
        if BuySell == "B" then
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
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end


dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



