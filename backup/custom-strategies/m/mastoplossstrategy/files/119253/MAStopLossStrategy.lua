-- Id: 21397
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=66126

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
    strategy:name("MA StopLoss Strategy");
    strategy:description("");

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Trade", "(non-FIFO) Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);

    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addString("Period", "MA Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addString("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addInteger("MAPeriod", "MA Period", "", 10);        
    
	strategy.parameters:addString("Price", "MA Price Source", "", "close");
	strategy.parameters:addStringAlternative("Price", "Open", "", "open");
	strategy.parameters:addStringAlternative("Price", "High", "", "high");
	strategy.parameters:addStringAlternative("Price", "Low", "", "low");
	strategy.parameters:addStringAlternative("Price", "Close", "", "close");
	strategy.parameters:addStringAlternative("Price", "Median", "", "median");
	strategy.parameters:addStringAlternative("Price", "Typical", "", "typical");
	strategy.parameters:addStringAlternative("Price", "Weighted", "", "weighted");
	
    strategy.parameters:addString("MAType", "Smoothing type", "", "MVA");
    strategy.parameters:addStringAlternative("MAType", "MVA", "MVA", "MVA");
    strategy.parameters:addStringAlternative("MAType", "EMA", "EMA", "EMA");
	strategy.parameters:addStringAlternative("MAType" , "LWMA", "", "LWMA");	
	strategy.parameters:addStringAlternative("MAType" , "KAMA", "", "KAMA");	
	strategy.parameters:addStringAlternative("MAType" , "SMMA", "", "SMMA");	
	strategy.parameters:addStringAlternative("Type" , "TMA", "", "TMA");	
	strategy.parameters:addStringAlternative("MAType" , "VIDYA", "", "VIDYA");	
	strategy.parameters:addStringAlternative("MAType" , "WMA", "", "WMA");	

	strategy.parameters:addInteger("Profit", "Min Profit", "", 30, 0, 1000000);   
end

local Account;
local Offer;
local CanClose;

local tradeId
local Limit;

local Indi;
local indiSource;
local gSource;
local Trigger;

--function Prepare(nameOnly)
function Prepare(onlyName)
 

    name = profile:id() .. "(" .. instance.bid:instrument() .. "," .. instance.parameters.Trade .. "," .. instance.parameters.Type .. "[" .. 
        instance.parameters.Price .. ","  .. instance.parameters.Period .. "," .. instance.parameters.MAPeriod .. "], "  .. instance.parameters.Profit .. ")";

    tradeId = instance.parameters.Trade   
    local trade = core.host:findTable("trades"):find("TradeID", tradeId);
    assert(trade ~= nil, "Trade can not be found")

    Account = trade.AccountID;
    Limit = instance.parameters.Profit* instance.bid:pipSize();    
    
    Offer   = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)    
    DistTradeStop = core.host:execute("getTradingProperty", "conditionalDistanceStopForTrade", instance.bid:instrument());
    
    instance:name(name);
    if onlyName then
        return ;
    end 
    
    gSource = ExtSubscribe(1, nil, "t1", true, "close");
    local iSource = ExtSubscribe(2, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
        
    if instance.parameters.Price=="close" then
        indiSource = iSource.close;
    elseif instance.parameters.Price=="open" then
        indiSource = iSource.open;
    elseif instance.parameters.Price=="high" then
        indiSource = iSource.high;
    elseif instance.parameters.Price=="low" then
        indiSource = iSource.low;
    elseif instance.parameters.Price=="median" then
        indiSource = iSource.median;
    elseif instance.parameters.Price=="typical" then
        indiSource = iSource.typical;
    else
        indiSource = iSource.weighted;
    end 

    assert(core.indicators:findIndicator(instance.parameters.MAType) ~= nil, instance.parameters.MAType .. " indicator must be installed");
    Indi = core.indicators:create(instance.parameters.MAType, indiSource, instance.parameters.MAPeriod);  
    first = Indi.DATA:first();
    Trigger = false;
end

function ExtUpdate(id, source, period)
    if not instance.parameters.AllowTrade then
        return;
    end
    if id ~= 1 then
       Indi:update(core.UpdateLast);
	   return;
	end
	
    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end

	if first >  Indi.DATA:size() then
	   return;
	end	
  
    local trade; 
    trade = core.host:findTable("trades"):find("TradeID", tradeId);
    
    if isTradeExist(trade) == false then
        return;
    end 
    
    local stopValue = nil;
    if trade.BS == "B"  then
           if instance.ask[NOW] >= trade.Open + Limit  
           and instance.ask[NOW] < Indi.DATA[NOW]
		   then         
          
                    closeTrade("B", trade);
                     
           
           end
           
      
    else
        if instance.bid[NOW] <= trade.Open - Limit  
          and instance.ask[NOW] > Indi.DATA[NOW] 
		  then         
                     
                   closeTrade("S", trade);
               
           
        
        end
    end       
end

function isTradeExist(trade)
    if trade == nil then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Trade " .. instance.parameters.Trade .. " disappear", instance.bid:date(NOW));
        core.host:execute("stop");
        return false;
    end
    
    return true;
end 

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. message , instance.bid:date(NOW));
        end
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function closeTrade(BuySell, row)
    local valuemap, success, msg;

    valuemap = core.valuemap();

    -- switch the direction since the order must be in oppsite direction
    if BuySell == "B" then
        BuySell = "S";
    else
        BuySell = "B";
    end
    valuemap.OrderType = "CM";
    valuemap.OfferID= row.OfferID;
    valuemap.AcctID = Account;
    valuemap.NetQtyFlag = "N";
    valuemap.TradeID= row.TradeID;
    valuemap.Quantity= row.Lot;
    valuemap.BuySell = BuySell;
    success, msg = terminal:execute(101, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");